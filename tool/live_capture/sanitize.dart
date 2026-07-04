/// Deterministic sanitizer: staging captures → `test/fixtures/`.
///
/// Reads the UNSANITIZED staging tree produced by `capture.dart`, replaces
/// every sensitive value with a stable placeholder (the same input always maps
/// to the same output, so identities stay consistent across files), and writes
/// the result to `test/fixtures/<domain>/<name>.json`.
///
/// What is sanitized: API key/device token literals, the server host, server
/// name, usernames/friendly names, emails, machine/server identifiers,
/// plex.tv avatar hashes, plex.direct hostnames, ALL IPv4 addresses (LAN →
/// 192.0.2.x, public → 203.0.113.x, except documentation IPs like 8.8.8.8
/// that the campaign itself sends), file-system paths, geo-lookup results,
/// and any value under a credential-looking settings key.
/// What is kept (documented in test/fixtures/README.md): media titles, rating
/// keys, numeric ids, timestamps, transient session ids.
///
/// Usage:
///   dart run tool/live_capture/sanitize.dart          # staging → test/fixtures
///   dart run tool/live_capture/sanitize.dart --check  # audit fixtures for leaks
///
/// Requires the same TAUTULLI_* env vars as capture.dart (the secrets are
/// needed in order to find and REMOVE them). The value→placeholder map is
/// written to `<staging>/_log/sanitize_map.json` — it contains real values,
/// so it stays in staging and must never be committed.
library;

import 'dart:convert';
import 'dart:io';

/// Output directory; override with TAUTULLI_FIXTURES_DIR (e.g. for a dry run
/// into a temporary folder).
final _outDir =
    Platform.environment['TAUTULLI_FIXTURES_DIR'] ?? 'test/fixtures';

/// IPs the campaign itself sends as test inputs — not server data.
const _ipAllowlist = {'8.8.8.8', '127.0.0.1', '0.0.0.0', '8.8.4.4'};

/// URL hostname suffixes that are not operator-identifying: Plex/public
/// services and the fictional hosts used in Tautulli's own API docs. Any
/// other hostname found in a URL is aliased to `hostN.example.com`.
const _hostAllowlist = [
  'plex.tv',
  'plex.direct',
  'imgur.com',
  'nullrefer.com',
  'github.com',
  'castleblack.com', // Tautulli's own docs examples (Jon Snow)
  'example.com',
  'localhost',
  'themoviedb.org',
  'thetvdb.com',
  'imdb.com',
  'musicbrainz.org',
];

final _urlHost = RegExp(r'https?://([A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9])');

bool _isAllowedHost(String host) =>
    _ipv4.hasMatch(host) ||
    _hostAllowlist.any((a) => host == a || host.endsWith('.$a'));

const _userAliases = [
  'alice', 'bob', 'carol', 'dave', 'erin', 'frank', 'grace', 'henry',
  'ivy', 'jack', 'kara', 'liam', 'mona', 'nina', 'oscar', 'pete', //
];

// `hook` (not just `hook_url`) so agent-specific keys like `slack_hook` are
// caught — webhook URLs embed credentials in the path.
final _credentialKey = RegExp(
  r'password|passwd|secret|token|api_key|apikey|client_id|hook',
  caseSensitive: false,
);
final _pathKey = RegExp(r'(_dir|_path|_folder|^log_dir$|^backup_dir$)');
final _ipv4 = RegExp(r'\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b');
final _dashedIpPlexDirect = RegExp(
  r'(\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3})\.([0-9a-f]{6,})\.plex\.direct',
);
final _plexTvAvatar = RegExp(r'plex\.tv/users/([0-9a-f]{6,})/avatar');

late final String apiKey;
late final String deviceToken;
late final String serverHost;
late final Directory staging;

/// Generic library-name vocabulary. A section/library name made only of these
/// tokens (e.g. "4K Movies", "TV Shows") is kept; anything else (typically a
/// personal/family name) is aliased to "Library N".
const _genericLibraryWords = {
  'tv', 'shows', 'movie', 'movies', 'music', 'documentaries', 'docuseries',
  'photos', 'audiobooks', 'home', 'videos', '4k', 'comedy', 'specials',
  'theater', 'plays', 'fan', 'edits', 'kids', 'anime', 'sports', 'fitness',
  'concerts', 'holiday', 'library', 'collection', //
};

bool _isGenericLibraryName(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[()\[\]]'), '')
    .split(RegExp(r'\s+'))
    .every(_genericLibraryWords.contains);

// Deterministic value → placeholder maps, built in the collect pass.
final _userMap = <String, String>{}; // username/friendly_name → alias
final _libraryMap = <String, String>{}; // personal library names → Library N
final _hostMap = <String, String>{}; // operator hostnames → hostN.example.com
final _emailMap = <String, String>{};
final _idMap =
    <String, String>{}; // machine ids / identifiers → hex placeholder
final _ipMap = <String, String>{};
var _serverName = '';

Future<void> main(List<String> args) async {
  String req(String name) {
    final v = Platform.environment[name];
    if (v == null || v.isEmpty) {
      stderr.writeln('missing required env var: $name');
      exit(78);
    }
    return v;
  }

  apiKey = req('TAUTULLI_API_KEY');
  deviceToken = req('TAUTULLI_DEVICE_TOKEN');
  serverHost = Uri.parse(req('TAUTULLI_BASE_URL')).host;
  staging = Directory(req('TAUTULLI_STAGING_DIR'));

  if (args.contains('--check')) {
    exit(await _auditFixtures());
  }

  _collect();
  _assignPlaceholders();
  var written = 0;
  for (final file in _stagingFiles()) {
    _rewrite(file);
    written++;
  }
  _writeMapReport();
  stdout.writeln(
    'sanitized $written files -> $_outDir '
    '(${_userMap.length} users, ${_ipMap.length} IPs, ${_idMap.length} ids)',
  );
}

List<File> _stagingFiles() =>
    staging
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              !f.path.contains('/_log/') &&
              (f.path.endsWith('.json') || f.path.endsWith('.txt')),
        )
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

// ---------------------------------------------------------------------------
// Pass 1: collect sensitive values by key across all captures
// ---------------------------------------------------------------------------

void _collect() {
  for (final file in _stagingFiles()) {
    if (!file.path.endsWith('.json')) continue;
    final Object? root;
    try {
      root = jsonDecode(file.readAsStringSync());
    } on FormatException {
      continue;
    }
    _walk(root, (key, value) {
      if (value is! String || value.isEmpty || value.startsWith('dart-')) {
        return;
      }
      switch (key) {
        case 'username' || 'user' || 'friendly_name':
          if (value.length >= 3 && !value.contains(' Library')) {
            _userMap[value] = '';
          }
        case 'email':
          if (value.contains('@')) _emailMap[value] = '';
        case 'machine_id' ||
            'machine_identifier' ||
            'pms_identifier' ||
            'identifier' ||
            'server_id':
          if (value.length >= 16) _idMap[value] = '';
        case 'pms_name' || 'server_name':
          _serverName = value;
        case 'section_name' || 'library_name':
          if (!_isGenericLibraryName(value)) _libraryMap[value] = '';
        case 'ip_address' || 'ip_address_public' || 'lan_ip' || 'ip':
          if (_ipv4.hasMatch(value)) _ipMap[value] = '';
      }
    });
  }
  // Collect every IPv4 and every non-allowlisted URL hostname that appears
  // anywhere in any body.
  for (final file in _stagingFiles()) {
    final text = file.readAsStringSync();
    for (final m in _ipv4.allMatches(text)) {
      final ip = m.group(0)!;
      if (!_ipAllowlist.contains(ip) && _isValidIp(ip)) _ipMap[ip] = '';
    }
    for (final m in _urlHost.allMatches(text)) {
      final host = m.group(1)!;
      if (!_isAllowedHost(host) && host.contains('.')) _hostMap[host] = '';
    }
  }
}

bool _isValidIp(String ip) =>
    ip.split('.').every((o) => (int.tryParse(o) ?? 256) <= 255);

bool _isPrivateIp(String ip) {
  final o = ip.split('.').map(int.parse).toList();
  return o[0] == 10 ||
      (o[0] == 172 && o[1] >= 16 && o[1] <= 31) ||
      (o[0] == 192 && o[1] == 168) ||
      o[0] == 127;
}

void _assignPlaceholders() {
  var u = 0;
  for (final name in _userMap.keys.toList()..sort()) {
    _userMap[name] = u < _userAliases.length ? _userAliases[u] : 'user${u + 1}';
    u++;
  }
  for (final email in _emailMap.keys.toList()..sort()) {
    // Reuse the user alias when the email belongs to a known user; otherwise
    // give it its own stable alias.
    _emailMap[email] =
        '${_userAliases[(u++) % _userAliases.length]}'
        '@example.com';
  }
  var lib = 0;
  for (final name in _libraryMap.keys.toList()..sort()) {
    _libraryMap[name] = 'Library ${++lib}';
  }
  var h = 0;
  for (final host in _hostMap.keys.toList()..sort()) {
    _hostMap[host] = 'host${++h}.example.com';
  }
  var i = 0;
  for (final id in _idMap.keys.toList()..sort()) {
    i++;
    final hex = i.toRadixString(16).padLeft(2, '0');
    _idMap[id] = List.filled(
      id.length,
      'e',
    ).join().replaceRange(id.length - 2, id.length, hex);
  }
  var lan = 9, pub = 9;
  for (final ip in _ipMap.keys.toList()..sort()) {
    _ipMap[ip] = _isPrivateIp(ip) ? '192.0.2.${++lan}' : '203.0.113.${++pub}';
  }
}

// ---------------------------------------------------------------------------
// Pass 2: rewrite every file
// ---------------------------------------------------------------------------

void _rewrite(File file) {
  final rel = file.path.substring(staging.path.length + 1);
  final outFile = File('$_outDir/$rel');
  outFile.parent.createSync(recursive: true);

  var text = file.readAsStringSync();
  if (file.path.endsWith('.json')) {
    Object? root;
    try {
      root = jsonDecode(text);
    } on FormatException {
      root = null;
    }
    if (root != null) {
      root = _structural(rel, root);
      text = const JsonEncoder.withIndent('  ').convert(root);
    }
  }
  outFile.writeAsStringSync('${_textPass(text)}\n');
}

/// Structural (key-aware) scrubbing.
Object? _structural(String rel, Object? node) {
  if (node is Map<String, dynamic>) {
    final out = <String, dynamic>{};
    node.forEach((key, value) {
      if (_credentialKey.hasMatch(key) && value is String && value.isNotEmpty) {
        out[key] = 'REDACTED';
      } else if (rel.contains('get_settings') &&
          _pathKey.hasMatch(key) &&
          value is String &&
          value.isNotEmpty) {
        out[key] = '/config/redacted';
      } else if (key == 'file' && value is String && value.startsWith('/')) {
        // Media file path: keep the basename (title is kept anyway),
        // genericize the directory.
        out[key] = '/media${value.substring(value.lastIndexOf('/'))}';
      } else {
        out[key] = _structural(rel, value);
      }
    });
    if (rel.contains('get_geoip_lookup')) _fakeGeo(out);
    return out;
  }
  if (node is List) return node.map((e) => _structural(rel, e)).toList();
  return node;
}

void _fakeGeo(Map<String, dynamic> map) {
  const fake = <String, dynamic>{
    'city': 'Springfield',
    'region': 'Illinois',
    'country': 'United States',
    'postal_code': '62701',
    'latitude': 39.78,
    'longitude': -89.65,
  };
  fake.forEach((k, v) {
    if (map.containsKey(k)) map[k] = v;
  });
}

/// Text-level replacement of collected literals and pattern matches.
String _textPass(String text) {
  var out = text;
  out = out.replaceAll(apiKey, 'REDACTED_API_KEY');
  out = out.replaceAll(deviceToken, 'REDACTED_DEVICE_TOKEN');
  out = out.replaceAll(serverHost, '192.0.2.10');
  if (_serverName.isNotEmpty) {
    out = out.replaceAll(_serverName, 'TestServer');
  }
  // Longest-first so overlapping values (e.g. a username that is a prefix of
  // another) resolve deterministically.
  final users = _userMap.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final name in users) {
    out = out.replaceAll(name, _userMap[name]!);
  }
  final libraries = _libraryMap.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final name in libraries) {
    out = out.replaceAll(name, _libraryMap[name]!);
  }
  final hosts = _hostMap.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final host in hosts) {
    out = out.replaceAll(host, _hostMap[host]!);
  }
  _emailMap.forEach((email, alias) => out = out.replaceAll(email, alias));
  _idMap.forEach((id, ph) => out = out.replaceAll(id, ph));
  out = out.replaceAllMapped(_plexTvAvatar, (m) {
    return 'plex.tv/users/${'0' * m.group(1)!.length}/avatar';
  });
  out = out.replaceAllMapped(_dashedIpPlexDirect, (m) {
    return '192-0-2-10.${'0' * m.group(2)!.length}.plex.direct';
  });
  out = out.replaceAllMapped(_ipv4, (m) {
    final ip = m.group(0)!;
    if (_ipAllowlist.contains(ip) || !_isValidIp(ip)) return ip;
    return _ipMap[ip] ?? (_isPrivateIp(ip) ? '192.0.2.9' : '203.0.113.9');
  });
  return out;
}

void _writeMapReport() {
  final log = Directory('${staging.path}/_log')..createSync(recursive: true);
  File('${log.path}/sanitize_map.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'note': 'REAL VALUES — never commit this file',
      'server_name': _serverName,
      'users': _userMap,
      'libraries': _libraryMap,
      'hosts': _hostMap,
      'emails': _emailMap,
      'ids': _idMap,
      'ips': _ipMap,
    }),
  );
}

// ---------------------------------------------------------------------------
// --check: audit the fixture tree for leaks
// ---------------------------------------------------------------------------

Future<int> _auditFixtures() async {
  _collect(); // rebuild the sensitive-value list from staging
  final needles = <String, String>{
    apiKey: 'API key',
    deviceToken: 'device token',
    serverHost: 'server host',
    if (_serverName.isNotEmpty) _serverName: 'server name',
    for (final u in _userMap.keys) u: 'username',
    for (final l in _libraryMap.keys) l: 'library name',
    for (final h in _hostMap.keys) h: 'hostname',
    for (final e in _emailMap.keys) e: 'email',
    for (final id in _idMap.keys) id: 'identifier',
    for (final ip in _ipMap.keys) ip: 'IP address',
  };
  var hits = 0;
  final fixtures = Directory(_outDir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json') || f.path.endsWith('.txt'));
  for (final file in fixtures) {
    final text = file.readAsStringSync();
    needles.forEach((needle, kind) {
      if (text.contains(needle)) {
        stderr.writeln('LEAK [$kind] "$needle" in ${file.path}');
        hits++;
      }
    });
    for (final m in _ipv4.allMatches(text)) {
      final ip = m.group(0)!;
      if (_isValidIp(ip) &&
          _isPrivateIp(ip) &&
          !ip.startsWith('192.0.2.') &&
          !_ipAllowlist.contains(ip)) {
        stderr.writeln('LEAK [private IP] "$ip" in ${file.path}');
        hits++;
      }
    }
  }
  stdout.writeln(hits == 0 ? 'audit clean' : 'audit found $hits leak(s)');
  return hits == 0 ? 0 : 1;
}

void _walk(Object? node, void Function(String key, Object? value) visit) {
  if (node is Map<String, dynamic>) {
    node.forEach((k, v) {
      visit(k, v);
      _walk(v, visit);
    });
  } else if (node is List) {
    for (final e in node) {
      _walk(e, visit);
    }
  }
}
