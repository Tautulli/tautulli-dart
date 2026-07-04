/// Live-capture campaign runner.
///
/// Captures real Tautulli API responses (raw HTTP) into a staging directory
/// and drives mutation lifecycles through the package itself, so every fix is
/// exercised end-to-end. Staging output is UNSANITIZED — run `sanitize.dart`
/// to produce `test/fixtures/`. See `test/CAPTURING.md` for the full process.
///
/// Required environment:
///   TAUTULLI_BASE_URL      e.g. http://192.0.2.10:8181  (no trailing slash)
///   TAUTULLI_API_KEY       plain API key
///   TAUTULLI_DEVICE_TOKEN  device token from register_device
///   TAUTULLI_STAGING_DIR   absolute path OUTSIDE the repo for raw captures
///
/// Usage:
///   dart run tool/live_capture/capture.dart --phase auth
///   dart run tool/live_capture/capture.dart --phase reads [--only substring]
///   dart run tool/live_capture/capture.dart --phase stream
///   dart run tool/live_capture/capture.dart --phase mutations
///   dart run tool/live_capture/capture.dart --phase destructive
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tautulli/tautulli.dart';

import 'manifest.dart';

/// Browser notification agent (notifiers.py AGENT_IDS['browser']): the only
/// agent that accepts a notification with zero external configuration, making
/// it the sink for the notify lifecycle. A scripts-agent (15) sink without a
/// configured script fails with "Notification failed.".
const sinkAgentId = 17;
const newsletterAgentId = 0; // newsletters.py AGENT_IDS['recently_added']

late final String baseUrl;
late final String apiKey;
late final String deviceToken;
late final Directory staging;
late final TautulliClient pkg;

final _httpClient = http.Client();
final _placeholders = <String, String>{};

Future<void> main(List<String> args) async {
  String? phase;
  String? only;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--phase' && i + 1 < args.length) phase = args[++i];
    if (args[i] == '--only' && i + 1 < args.length) only = args[++i];
  }
  if (phase == null) {
    stderr.writeln('usage: --phase auth|reads|stream|mutations|destructive');
    exit(64);
  }

  _initEnv();
  // Stray async socket errors (e.g. leftover bytes on a keep-alive connection
  // after a download response) must not kill the sweep.
  await runZonedGuarded(
    () async {
      try {
        switch (phase) {
          case 'auth':
            await _runEntries(authEntries, phase!, only);
          case 'reads':
            await _discover();
            await _runEntries(readEntries, phase!, only);
          case 'stream':
            await _discover();
            await _phaseStream();
          case 'mutations':
            await _discover();
            await _phaseMutations(only);
          case 'destructive':
            await _discover();
            await _phaseDestructive();
          default:
            stderr.writeln('unknown phase: $phase');
            exit(64);
        }
      } finally {
        _httpClient.close();
        pkg.close();
      }
    },
    (error, stack) {
      stderr.writeln('async error (continuing): $error');
      _log({'async_error': '$error'});
    },
  );
}

void _initEnv() {
  String req(String name) {
    final v = Platform.environment[name];
    if (v == null || v.isEmpty) {
      stderr.writeln('missing required env var: $name');
      exit(78);
    }
    return v;
  }

  baseUrl = req('TAUTULLI_BASE_URL').replaceAll(RegExp(r'/+$'), '');
  apiKey = req('TAUTULLI_API_KEY');
  deviceToken = req('TAUTULLI_DEVICE_TOKEN');
  staging = Directory(req('TAUTULLI_STAGING_DIR'))..createSync(recursive: true);

  final base = Uri.parse(baseUrl);
  pkg = TautulliClient(
    connection: TautulliConnection(
      protocol: base.scheme,
      domain: base.hasPort ? '${base.host}:${base.port}' : base.host,
      path: base.path.isEmpty ? null : base.path,
      apiKey: apiKey,
    ),
  );
}

// ---------------------------------------------------------------------------
// Raw HTTP capture primitives
// ---------------------------------------------------------------------------

Uri _rawUri(String cmd, Map<String, String> params, AuthMode auth) {
  final q = <String, String>{'cmd': cmd, ...params};
  switch (auth) {
    case AuthMode.plain:
      q['apikey'] = apiKey;
    case AuthMode.deviceToken:
      q['apikey'] = deviceToken;
      q['app'] = 'true';
    case AuthMode.plainWithApp:
      q['apikey'] = apiKey;
      q['app'] = 'true';
    case AuthMode.tokenNoApp:
      q['apikey'] = deviceToken;
    case AuthMode.badKey:
      q['apikey'] = '0123456789abcdef0123456789abcdef';
    case AuthMode.noKey:
      break;
  }
  return Uri.parse('$baseUrl/api/v2').replace(queryParameters: q);
}

/// Performs one raw GET and writes the capture. Returns the decoded JSON
/// envelope when the body is JSON, else null.
Future<Map<String, dynamic>?> _capture(
  String domain,
  String name,
  String cmd, {
  Map<String, String> params = const {},
  AuthMode auth = AuthMode.plain,
  bool binary = false,
}) async {
  final sw = Stopwatch()..start();
  // Binary downloads get a one-shot client: Tautulli download responses can
  // leave stray bytes on a keep-alive connection, poisoning later requests.
  final client = binary ? http.Client() : _httpClient;
  final http.Response resp;
  try {
    resp = await client
        .get(_rawUri(cmd, params, auth))
        .timeout(const Duration(seconds: 90));
  } finally {
    if (binary) client.close();
  }
  sw.stop();
  final contentType = resp.headers['content-type'] ?? '';
  final dir = Directory('${staging.path}/$domain')..createSync(recursive: true);

  Map<String, dynamic>? envelope;
  if (binary || !contentType.contains('application/json')) {
    // Record metadata (and a text preview for non-binary bodies) instead of
    // dumping file bytes into a fixture.
    final isText =
        contentType.contains('text/') || contentType.contains('html');
    final meta = <String, dynamic>{
      'status': resp.statusCode,
      'content_type': contentType,
      'bytes': resp.bodyBytes.length,
      if (isText && resp.bodyBytes.length < 200000)
        'body_preview': resp.body.substring(
          0,
          resp.body.length < 2000 ? resp.body.length : 2000,
        ),
    };
    File(
      '${dir.path}/$name.meta.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(meta));
  } else {
    try {
      envelope = jsonDecode(resp.body) as Map<String, dynamic>;
      File(
        '${dir.path}/$name.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(envelope));
    } on FormatException {
      File('${dir.path}/$name.invalid.txt').writeAsStringSync(resp.body);
    }
  }

  _log({
    'name': '$domain/$name',
    'cmd': cmd,
    'params': params,
    'auth': auth.name,
    'status': resp.statusCode,
    'content_type': contentType,
    'bytes': resp.bodyBytes.length,
    'ms': sw.elapsedMilliseconds,
  });
  stdout.writeln(
    '  [$domain/$name] ${resp.statusCode} '
    '${resp.bodyBytes.length}B ${sw.elapsedMilliseconds}ms',
  );
  return envelope;
}

void _log(Map<String, dynamic> record) {
  final dir = Directory('${staging.path}/_log')..createSync(recursive: true);
  File('${dir.path}/run.jsonl').writeAsStringSync(
    '${jsonEncode({'ts': DateTime.now().toIso8601String(), ...record})}\n',
    mode: FileMode.append,
  );
}

/// Records a package-path result (success summary or typed exception).
void _pkgLog(String method, String outcome, [String detail = '']) {
  _log({'pkg': method, 'outcome': outcome, 'detail': detail});
  stdout.writeln('  [pkg] $method -> $outcome ${detail.isEmpty ? '' : detail}');
}

// ---------------------------------------------------------------------------
// Discovery: resolve {placeholders} from live server data
// ---------------------------------------------------------------------------

Future<Map<String, dynamic>?> _rawData(
  String cmd, [
  Map<String, String> params = const {},
]) async {
  final resp = await _httpClient
      .get(_rawUri(cmd, params, AuthMode.plain))
      .timeout(const Duration(seconds: 60));
  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  return (body['response'] as Map<String, dynamic>?);
}

Future<void> _discover() async {
  // PMS connection details.
  final serverInfo = await _rawData('get_server_info');
  final si = serverInfo?['data'] as Map<String, dynamic>? ?? {};
  _placeholders['pmsHost'] = '${si['pms_ip'] ?? ''}';
  _placeholders['pmsPort'] = '${si['pms_port'] ?? ''}';
  _placeholders['pmsIdentifier'] = '${si['pms_identifier'] ?? ''}';

  // Library sections: first movie + first show section.
  final libs = await _rawData('get_libraries');
  for (final lib in (libs?['data'] as List? ?? [])) {
    final l = lib as Map<String, dynamic>;
    final type = '${l['section_type']}';
    if (type == 'movie' && !_placeholders.containsKey('sectionId')) {
      _placeholders['sectionId'] = '${l['section_id']}';
      _placeholders['sectionName'] = '${l['section_name']}';
    }
    if (type == 'show' && !_placeholders.containsKey('sectionIdTv')) {
      _placeholders['sectionIdTv'] = '${l['section_id']}';
      _placeholders['sectionNameTv'] = '${l['section_name']}';
    }
  }

  // History: rating keys, row ids, user, search term.
  final hist = await _rawData('get_history', {'length': '50'});
  final rows =
      ((hist?['data'] as Map<String, dynamic>?)?['data'] as List? ?? []);
  for (final row in rows) {
    final r = row as Map<String, dynamic>;
    final mediaType = '${r['media_type']}';
    if (!_placeholders.containsKey('historyRowId')) {
      _placeholders['historyRowId'] = '${r['row_id']}';
      _placeholders['userId'] = '${r['user_id']}';
      _placeholders['username'] = '${r['user']}';
    }
    if (mediaType == 'movie' && !_placeholders.containsKey('ratingKey')) {
      _placeholders['ratingKey'] = '${r['rating_key']}';
      _placeholders['searchTerm'] = '${r['title']}';
    }
    if (mediaType == 'episode' &&
        !_placeholders.containsKey('episodeRatingKey')) {
      _placeholders['episodeRatingKey'] = '${r['rating_key']}';
      _placeholders['seasonRatingKey'] = '${r['parent_rating_key']}';
      _placeholders['showRatingKey'] = '${r['grandparent_rating_key']}';
    }
  }

  // Secondary user (for delete/undelete toggles) — any user other than the
  // primary one discovered above, excluding the Local user (id 0).
  final users = await _rawData('get_users');
  for (final user in (users?['data'] as List? ?? [])) {
    final u = user as Map<String, dynamic>;
    final id = '${u['user_id']}';
    if (id != '0' && id != _placeholders['userId']) {
      _placeholders['userId2'] = id;
      _placeholders['username2'] = '${u['username']}';
      break;
    }
  }

  stdout.writeln('discovered: $_placeholders');
}

String? _resolve(String value) {
  var out = value;
  for (final m in RegExp(r'\{(\w+)\}').allMatches(value)) {
    final key = m.group(1)!;
    final v = _placeholders[key];
    if (v == null || v.isEmpty || v == 'null') return null;
    out = out.replaceAll('{$key}', v);
  }
  return out;
}

Future<void> _runEntries(
  List<CaptureEntry> entries,
  String phase,
  String? only,
) async {
  stdout.writeln('=== phase: $phase (${entries.length} entries) ===');
  var skipped = 0;
  for (final e in entries) {
    if (only != null && !e.name.contains(only)) continue;
    final resolved = <String, String>{};
    var ok = true;
    e.params.forEach((k, v) {
      final r = _resolve(v);
      if (r == null) ok = false;
      resolved[k] = r ?? v;
    });
    if (!ok) {
      skipped++;
      _log({
        'name': '${e.domain}/${e.name}',
        'skipped': 'unresolved',
        'params': e.params,
      });
      stdout.writeln('  [${e.domain}/${e.name}] SKIP (unresolved placeholder)');
      continue;
    }
    try {
      await _capture(
        e.domain,
        e.name,
        e.cmd,
        params: resolved,
        auth: e.auth,
        binary: e.binary,
      );
    } on Exception catch (err) {
      _log({'name': '${e.domain}/${e.name}', 'error': '$err'});
      stdout.writeln('  [${e.domain}/${e.name}] ERROR $err');
    }
  }
  if (skipped > 0) stdout.writeln('skipped $skipped entries');
}

// ---------------------------------------------------------------------------
// Phase: stream (requires a user-coordinated throwaway stream)
// ---------------------------------------------------------------------------

Future<void> _phaseStream() async {
  final activity = await _rawData('get_activity');
  final sessions =
      ((activity?['data'] as Map<String, dynamic>?)?['sessions'] as List? ??
      []);
  if (sessions.isEmpty) {
    stderr.writeln(
      'No active sessions. Start a throwaway stream and re-run --phase stream.',
    );
    exit(2);
  }
  final s = sessions.first as Map<String, dynamic>;
  final sessionKey = '${s['session_key']}';
  final sessionId = '${s['session_id']}';
  stdout.writeln('active session: key=$sessionKey');

  await _capture('activity', 'get_activity__live', 'get_activity');
  await _capture(
    'activity',
    'get_activity__by_session_key',
    'get_activity',
    params: {'session_key': sessionKey},
  );
  await _capture(
    'activity',
    'get_activity__by_session_id',
    'get_activity',
    params: {'session_id': sessionId},
  );
  await _capture(
    'activity',
    'get_stream_data__session_key',
    'get_stream_data',
    params: {'session_key': sessionKey},
  );

  // Package-path checks against the live session.
  try {
    final a = await pkg.activity.getActivity();
    _pkgLog(
      'activity.getActivity',
      'OK',
      'streamCount=${a.streamCount} sessions=${a.sessions.length}',
    );
    final single = await pkg.activity.getActivity(
      sessionKey: int.parse(sessionKey),
    );
    _pkgLog(
      'activity.getActivity(sessionKey:)',
      'OK',
      'sessions=${single.sessions.length}',
    );
    final sd = await pkg.activity.getStreamData(
      sessionKey: int.parse(sessionKey),
    );
    _pkgLog('activity.getStreamData(sessionKey:)', 'OK', 'keys=${sd.length}');
  } on TautulliException catch (e) {
    _pkgLog('activity (stream window)', 'FAIL', '$e');
  }

  // Terminate the throwaway stream through the package (the fix under test).
  try {
    await pkg.activity.terminateSession(
      sessionKey: int.parse(sessionKey),
      message: 'tautulli-dart live capture: terminating test stream',
    );
    _pkgLog('activity.terminateSession', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('activity.terminateSession', 'FAIL', '$e');
  }
  await Future<void>.delayed(const Duration(seconds: 4));
  await _capture('activity', 'get_activity__after_terminate', 'get_activity');
}

// ---------------------------------------------------------------------------
// Phase: reversible mutations
// ---------------------------------------------------------------------------

Future<void> _phaseMutations([String? only]) async {
  bool want(String name) => only == null || name.contains(only);
  if (want('benign')) await _benignTriggers();
  if (want('notifier')) await _notifierLifecycle();
  if (want('newsletter')) await _newsletterLifecycle();
  if (want('export')) await _exportLifecycle();
  if (want('device')) await _deviceLifecycle();
  if (want('edit_user')) await _editUserRoundTrip();
  if (want('edit_library')) await _editLibraryRoundTrip();
  if (want('toggles')) await _deleteUndeleteToggles();
  if (want('logout')) await _logoutUserSession();
  if (want('media')) await _mediaMutations();
  if (want('image')) await _imageProxyChecks();
}

Future<void> _benignTriggers() async {
  stdout.writeln('--- benign triggers ---');
  await _capture('tautulli', 'backup_config', 'backup_config');
  await _capture('tautulli', 'backup_db', 'backup_db');
  await _capture('library', 'refresh_libraries_list', 'refresh_libraries_list');
  await _capture('user', 'refresh_users_list', 'refresh_users_list');
  await _capture('history', 'regroup_history', 'regroup_history');
  await _capture('tautulli', 'delete_temp_sessions', 'delete_temp_sessions');
  try {
    await pkg.tautulli.backupConfig();
    await pkg.tautulli.backupDb();
    await pkg.libraries.refreshLibrariesList();
    await pkg.users.refreshUsersList();
    await pkg.history.regroupHistory();
    await pkg.tautulli.deleteTempSessions();
    _pkgLog('benign triggers (6 methods)', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('benign triggers', 'FAIL', '$e');
  }
}

Future<int?> _newestNotifierId() async {
  final data = await _rawData('get_notifiers');
  final list = (data?['data'] as List? ?? []).cast<Map<String, dynamic>>();
  final sinks = list.where((n) => '${n['agent_name']}' == 'browser');
  if (sinks.isEmpty) return null;
  return sinks.map((n) => n['id'] as int).reduce((a, b) => a > b ? a : b);
}

Future<void> _notifierLifecycle() async {
  stdout.writeln('--- notifier lifecycle (browser sink, agent 17) ---');
  try {
    await pkg.notifications.addNotifierConfig(agentId: sinkAgentId);
    _pkgLog('notifications.addNotifierConfig', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('notifications.addNotifierConfig', 'FAIL', '$e');
    return;
  }
  final notifierId = await _newestNotifierId();
  if (notifierId == null) {
    _pkgLog('notifier lifecycle', 'FAIL', 'sink notifier not found after add');
    return;
  }
  await _capture('notification', 'get_notifiers__after_add', 'get_notifiers');
  await _capture(
    'notification',
    'get_notifier_config__sink',
    'get_notifier_config',
    params: {'notifier_id': '$notifierId'},
  );
  try {
    final cfg = await pkg.notifications.getNotifierConfig(
      notifierId: notifierId,
    );
    _pkgLog(
      'notifications.getNotifierConfig',
      'OK',
      'agent=${cfg.agentName} id=${cfg.notifierId}',
    );
    await pkg.notifications.setNotifierConfig(
      notifierId: notifierId,
      agentId: sinkAgentId,
      extraParams: {'friendly_name': 'dart-live-capture-sink'},
    );
    _pkgLog('notifications.setNotifierConfig', 'OK');
    // The §1.1 fix: notify with subject/body through the package.
    await pkg.notifications.notify(
      notifierId: notifierId,
      subject: 'tautulli-dart live capture',
      body: 'notify() through the fixed package',
    );
    _pkgLog('notifications.notify', 'OK', '(§ subject/body fix verified)');
  } on TautulliException catch (e) {
    _pkgLog('notifier lifecycle', 'FAIL', '$e');
  }
  await _capture(
    'notification',
    'notify',
    'notify',
    params: {
      'notifier_id': '$notifierId',
      'subject': 'tautulli-dart raw notify',
      'body': 'raw capture',
    },
  );
  await Future<void>.delayed(const Duration(seconds: 2));
  await _capture(
    'notification',
    'get_notification_log__after',
    'get_notification_log',
    params: {'length': '5'},
  );
  try {
    await pkg.notifications.deleteNotifier(notifierId: notifierId);
    _pkgLog('notifications.deleteNotifier', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('notifications.deleteNotifier', 'FAIL', '$e');
  }
}

Future<void> _newsletterLifecycle() async {
  stdout.writeln('--- newsletter lifecycle (agent 0) ---');
  try {
    await pkg.newsletters.addNewsletterConfig(agentId: newsletterAgentId);
    _pkgLog('newsletters.addNewsletterConfig', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('newsletters.addNewsletterConfig', 'FAIL', '$e');
    return;
  }
  final data = await _rawData('get_newsletters');
  final list = (data?['data'] as List? ?? []).cast<Map<String, dynamic>>();
  if (list.isEmpty) {
    _pkgLog('newsletter lifecycle', 'FAIL', 'no newsletter after add');
    return;
  }
  final newsletterId = list
      .map((n) => n['id'] as int)
      .reduce((a, b) => a > b ? a : b);
  await _capture('newsletter', 'get_newsletters__after_add', 'get_newsletters');
  await _capture(
    'newsletter',
    'get_newsletter_config__new',
    'get_newsletter_config',
    params: {'newsletter_id': '$newsletterId'},
  );
  try {
    final cfg = await pkg.newsletters.getNewsletterConfig(
      newsletterId: newsletterId,
    );
    _pkgLog('newsletters.getNewsletterConfig', 'OK', 'agent=${cfg.agentName}');
  } on TautulliException catch (e) {
    _pkgLog('newsletters.getNewsletterConfig', 'FAIL', '$e');
  }
  // Known server behavior: minimal set_newsletter_config 500s; capture it.
  await _capture(
    'newsletter',
    'set_newsletter_config__minimal_500',
    'set_newsletter_config',
    params: {
      'newsletter_id': '$newsletterId',
      'agent_id': '$newsletterAgentId',
    },
  );
  // notify_newsletter: succeeds or fails depending on SMTP config; both are
  // useful captures.
  await _capture(
    'newsletter',
    'notify_newsletter',
    'notify_newsletter',
    params: {'newsletter_id': '$newsletterId'},
  );
  try {
    await pkg.newsletters.deleteNewsletter(newsletterId: newsletterId);
    _pkgLog('newsletters.deleteNewsletter', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('newsletters.deleteNewsletter', 'FAIL', '$e');
  }
  await _capture('newsletter', 'delete_hosted_images', 'delete_hosted_images');
}

Future<void> _exportLifecycle() async {
  stdout.writeln('--- export lifecycle ---');
  final sectionId = _placeholders['sectionId'];
  if (sectionId == null) {
    _pkgLog('export lifecycle', 'SKIP', 'no movie section discovered');
    return;
  }
  try {
    await pkg.exports.exportMetadata(
      sectionId: int.parse(sectionId),
      fileFormat: 'csv',
      metadataLevel: 1,
      mediaInfoLevel: 0,
      thumbLevel: 0,
      artLevel: 0,
    );
    _pkgLog('exports.exportMetadata', 'OK', '(§ real params verified)');
  } on TautulliException catch (e) {
    _pkgLog('exports.exportMetadata', 'FAIL', '$e');
    return;
  }
  // Poll until the export completes.
  int? exportId;
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    final table = await _rawData('get_exports_table', {
      'section_id': sectionId,
      'order_column': 'timestamp',
      'order_dir': 'desc',
    });
    final rows =
        ((table?['data'] as Map<String, dynamic>?)?['data'] as List? ?? []);
    if (rows.isEmpty) continue;
    final newest = rows.first as Map<String, dynamic>;
    if ('${newest['complete']}' == '1') {
      exportId = newest['export_id'] as int;
      break;
    }
  }
  if (exportId == null) {
    _pkgLog('export lifecycle', 'FAIL', 'export never completed');
    return;
  }
  await _capture(
    'export',
    'get_exports_table__after',
    'get_exports_table',
    params: {'section_id': sectionId},
  );
  try {
    final bytes = await pkg.exports.downloadExport(exportId: exportId);
    _pkgLog('exports.downloadExport', 'OK', '${bytes.length} bytes');
  } on TautulliException catch (e) {
    _pkgLog('exports.downloadExport', 'FAIL', '$e');
  }
  try {
    await pkg.exports.deleteExport(exportId: exportId);
    _pkgLog('exports.deleteExport', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('exports.deleteExport', 'FAIL', '$e');
  }
  await _capture(
    'export',
    'get_exports_table__after_delete',
    'get_exports_table',
    params: {'section_id': sectionId},
  );
}

Future<void> _deviceLifecycle() async {
  stdout.writeln('--- device lifecycle ---');
  const testDeviceId = 'dart-live-capture-device';
  try {
    final result = await pkg.devices.registerDevice(
      deviceId: testDeviceId,
      deviceName: 'dart-live-capture',
    );
    _pkgLog(
      'devices.registerDevice',
      'OK',
      'pms=${result.pmsName} version=${result.tautulliVersion} '
          '(§ minimal-params fix verified)',
    );
  } on TautulliException catch (e) {
    _pkgLog('devices.registerDevice', 'FAIL', '$e');
  }
  await _capture(
    'device',
    'register_device',
    'register_device',
    params: {'device_id': testDeviceId, 'device_name': 'dart-live-capture'},
  );
  // min_version above the server version must raise TautulliVersionException.
  try {
    await pkg.devices.registerDevice(
      deviceId: testDeviceId,
      deviceName: 'dart-live-capture',
      minVersion: 'v99.0.0',
    );
    _pkgLog('devices.registerDevice(minVersion:v99)', 'FAIL', 'no exception');
  } on TautulliVersionException {
    _pkgLog(
      'devices.registerDevice(minVersion:v99)',
      'OK',
      'TautulliVersionException (§ version mapping verified)',
    );
  } on TautulliException catch (e) {
    _pkgLog('devices.registerDevice(minVersion:v99)', 'FAIL', 'wrong type $e');
  }
  await _capture(
    'device',
    'register_device__min_version_error',
    'register_device',
    params: {
      'device_id': testDeviceId,
      'device_name': 'dart-live-capture',
      'min_version': 'v99.0.0',
    },
  );
  try {
    await pkg.devices.deleteMobileDevice(deviceId: testDeviceId);
    _pkgLog('devices.deleteMobileDevice(deviceId:)', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('devices.deleteMobileDevice', 'FAIL', '$e');
  }
}

Future<void> _editUserRoundTrip() async {
  stdout.writeln('--- edit_user round trip (§ bool storage fix) ---');
  final userId = _placeholders['userId'];
  if (userId == null) {
    _pkgLog('edit_user round trip', 'SKIP', 'no user discovered');
    return;
  }
  final before = await _rawData('get_user', {'user_id': userId});
  final b = before?['data'] as Map<String, dynamic>? ?? {};
  final origFriendly = '${b['friendly_name'] ?? ''}';
  final origThumb = '${b['custom_thumb'] ?? ''}';
  bool asBool(dynamic v) => '$v' == '1' || '$v' == 'true';
  final origKeep = asBool(b['keep_history']);
  final origGuest = asBool(b['allow_guest']);
  final origNotify = asBool(b['do_notify']);

  try {
    await pkg.users.editUser(
      userId: int.parse(userId),
      friendlyName: 'dart-edit-check',
      customThumb: origThumb,
      keepHistory: true,
      allowGuest: false,
      doNotify: false,
    );
    _pkgLog('users.editUser', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('users.editUser', 'FAIL', '$e');
    return;
  }
  await _capture(
    'user',
    'get_user__after_edit',
    'get_user',
    params: {'user_id': userId},
  );
  // SQL oracle (only if api_sql is enabled): the fix stores real ints, not
  // the strings 'true'/'false'.
  await _capture(
    'tautulli',
    'sql__user_flags_after_edit',
    'sql',
    params: {
      'query':
          'SELECT keep_history, allow_guest, do_notify FROM users '
          'WHERE user_id = $userId',
    },
  );
  // Restore.
  try {
    await pkg.users.editUser(
      userId: int.parse(userId),
      friendlyName: origFriendly,
      customThumb: origThumb,
      keepHistory: origKeep,
      allowGuest: origGuest,
      doNotify: origNotify,
    );
    _pkgLog('users.editUser (restore)', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('users.editUser (restore)', 'FAIL', '$e');
  }
}

Future<void> _editLibraryRoundTrip() async {
  stdout.writeln('--- edit_library round trip ---');
  final sectionId = _placeholders['sectionId'];
  if (sectionId == null) {
    _pkgLog('edit_library round trip', 'SKIP', 'no section discovered');
    return;
  }
  final before = await _rawData('get_library', {'section_id': sectionId});
  final b = before?['data'] as Map<String, dynamic>? ?? {};
  bool asBool(dynamic v) => '$v' == '1' || '$v' == 'true';
  final origKeep = asBool(b['keep_history']);
  final origNotify = asBool(b['do_notify']);
  final origCreated = asBool(b['do_notify_created']);

  try {
    await pkg.libraries.editLibrary(
      sectionId: int.parse(sectionId),
      customThumb: '',
      customArt: '',
      keepHistory: true,
      doNotify: false,
      doNotifyCreated: false,
    );
    _pkgLog('libraries.editLibrary', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('libraries.editLibrary', 'FAIL', '$e');
    return;
  }
  await _capture(
    'tautulli',
    'sql__library_flags_after_edit',
    'sql',
    params: {
      'query':
          'SELECT keep_history, do_notify, do_notify_created '
          'FROM library_sections WHERE section_id = $sectionId',
    },
  );
  try {
    await pkg.libraries.editLibrary(
      sectionId: int.parse(sectionId),
      customThumb: '',
      customArt: '',
      keepHistory: origKeep,
      doNotify: origNotify,
      doNotifyCreated: origCreated,
    );
    _pkgLog('libraries.editLibrary (restore)', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('libraries.editLibrary (restore)', 'FAIL', '$e');
  }
}

Future<void> _deleteUndeleteToggles() async {
  stdout.writeln('--- delete/undelete toggles ---');
  final userId2 = _placeholders['userId2'];
  final username2 = _placeholders['username2'];
  if (userId2 != null && username2 != null) {
    try {
      await pkg.users.deleteUser(userId: int.parse(userId2));
      _pkgLog('users.deleteUser (toggle)', 'OK');
      await _capture('user', 'delete_user__toggle', 'get_users');
      await pkg.users.undeleteUser(
        userId: int.parse(userId2),
        username: username2,
      );
      _pkgLog('users.undeleteUser', 'OK');
    } on TautulliException catch (e) {
      _pkgLog('user delete/undelete toggle', 'FAIL', '$e');
    }
  }
  final sectionIdTv = _placeholders['sectionIdTv'];
  final sectionNameTv = _placeholders['sectionNameTv'];
  final serverId = _placeholders['pmsIdentifier'];
  if (sectionIdTv != null && sectionNameTv != null && serverId != null) {
    try {
      await pkg.libraries.deleteLibrary(
        serverId: serverId,
        sectionId: int.parse(sectionIdTv),
      );
      _pkgLog('libraries.deleteLibrary (toggle)', 'OK');
      await pkg.libraries.undeleteLibrary(
        sectionId: int.parse(sectionIdTv),
        sectionName: sectionNameTv,
      );
      _pkgLog('libraries.undeleteLibrary', 'OK');
    } on TautulliException catch (e) {
      _pkgLog('library delete/undelete toggle', 'FAIL', '$e');
    }
  }
}

Future<void> _logoutUserSession() async {
  stdout.writeln('--- logout_user_session (§ row_ids fix) ---');
  final logins = await _rawData('get_user_logins', {'length': '5'});
  final rows =
      ((logins?['data'] as Map<String, dynamic>?)?['data'] as List? ?? []);
  if (rows.isEmpty) {
    _pkgLog(
      'tautulli.logoutUserSession',
      'SKIP',
      'login log empty — log into the web UI once to populate it',
    );
    return;
  }
  final rowId = (rows.first as Map<String, dynamic>)['row_id'] as int;
  try {
    await pkg.tautulli.logoutUserSession(rowIds: [rowId]);
    _pkgLog('tautulli.logoutUserSession', 'OK', '(§ row_ids fix verified)');
  } on TautulliException catch (e) {
    _pkgLog('tautulli.logoutUserSession', 'FAIL', '$e');
  }
  await _capture(
    'user',
    'get_user_logins__after_logout',
    'get_user_logins',
    params: {'length': '5'},
  );
}

Future<void> _mediaMutations() async {
  stdout.writeln('--- media mutations ---');
  final ratingKey = _placeholders['ratingKey'];
  if (ratingKey == null) return;
  try {
    await pkg.media.updateMetadataDetails(
      oldRatingKey: int.parse(ratingKey),
      newRatingKey: int.parse(ratingKey),
      mediaType: 'movie',
    );
    _pkgLog('media.updateMetadataDetails', 'OK', '(same-key no-op)');
  } on TautulliException catch (e) {
    _pkgLog('media.updateMetadataDetails', 'FAIL', '$e');
  }
  try {
    await pkg.media.deleteLookupInfo(
      ratingKey: int.parse(ratingKey),
      service: 'themoviedb',
    );
    _pkgLog('media.deleteLookupInfo', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('media.deleteLookupInfo', 'FAIL', '$e');
  }
}

Future<void> _imageProxyChecks() async {
  stdout.writeln('--- pms_image_proxy fallback (§ param-name fix) ---');
  final ratingKey = _placeholders['ratingKey'];
  if (ratingKey == null) return;
  final good = pkg.images.buildImageUrl(
    img: '/library/metadata/$ratingKey/thumb',
    width: 100,
    height: 150,
    fallback: ImageFallback.poster,
  );
  final goodResp = await _httpClient.get(good);
  _pkgLog(
    'images.buildImageUrl (valid img)',
    goodResp.statusCode == 200 ? 'OK' : 'FAIL',
    'status=${goodResp.statusCode} type=${goodResp.headers['content-type']} '
        'bytes=${goodResp.bodyBytes.length}',
  );
  final bogus = pkg.images.buildImageUrl(
    img: '/library/metadata/999999999/thumb',
    width: 100,
    height: 150,
    fallback: ImageFallback.poster,
  );
  final bogusResp = await _httpClient.get(bogus);
  _pkgLog(
    'images.buildImageUrl (bogus img + fallback)',
    bogusResp.statusCode == 200 &&
            (bogusResp.headers['content-type'] ?? '').contains('image')
        ? 'OK'
        : 'FAIL',
    'status=${bogusResp.statusCode} type=${bogusResp.headers['content-type']} '
        'bytes=${bogusResp.bodyBytes.length} (fallback poster served)',
  );
}

// ---------------------------------------------------------------------------
// Phase: destructive (disposable server only; ordered least → most)
// ---------------------------------------------------------------------------

Future<void> _phaseDestructive() async {
  stdout.writeln('--- destructive tier ---');

  // 1. delete_history with real row ids (§ row_ids fix).
  final hist = await _rawData('get_history', {
    'length': '1',
    'order_column': 'date',
    'order_dir': 'asc',
  });
  final rows =
      ((hist?['data'] as Map<String, dynamic>?)?['data'] as List? ?? []);
  if (rows.isNotEmpty) {
    final rowId = (rows.first as Map<String, dynamic>)['row_id'] as int;
    await _capture(
      'history',
      'get_history__predelete',
      'get_history',
      params: {'length': '3', 'order_column': 'date', 'order_dir': 'asc'},
    );
    try {
      await pkg.history.deleteHistory(rowIds: [rowId]);
      _pkgLog('history.deleteHistory', 'OK', '(§ row_ids fix verified)');
    } on TautulliException catch (e) {
      _pkgLog('history.deleteHistory', 'FAIL', '$e');
    }
    await _capture(
      'history',
      'get_history__after_delete',
      'get_history',
      params: {'length': '3', 'order_column': 'date', 'order_dir': 'asc'},
    );
  }

  // 2. Log/cache purges.
  try {
    await pkg.notifications.deleteNotificationLog();
    await pkg.newsletters.deleteNewsletterLog();
    await pkg.logs.deleteLoginLog();
    await pkg.tautulli.deleteImageCache();
    await pkg.tautulli.deleteCache();
    await pkg.libraries.deleteRecentlyAdded();
    _pkgLog('purges (6 methods)', 'OK');
  } on TautulliException catch (e) {
    _pkgLog('purges', 'FAIL', '$e');
  }
  await _capture(
    'notification',
    'get_notification_log__purged',
    'get_notification_log',
    params: {'length': '5'},
  );

  // 3. Sacrificial entity destruction.
  final userId2 = _placeholders['userId2'];
  final username2 = _placeholders['username2'];
  if (userId2 != null && username2 != null) {
    try {
      await pkg.users.deleteAllUserHistory(
        userId: int.parse(userId2),
        username: username2,
      );
      _pkgLog('users.deleteAllUserHistory', 'OK');
      await pkg.users.deleteUser(userId: int.parse(userId2));
      _pkgLog('users.deleteUser (final)', 'OK');
    } on TautulliException catch (e) {
      _pkgLog('user destruction', 'FAIL', '$e');
    }
  }
  final sectionIdTv = _placeholders['sectionIdTv'];
  final serverId = _placeholders['pmsIdentifier'];
  if (sectionIdTv != null && serverId != null) {
    try {
      await pkg.libraries.deleteAllLibraryHistory(
        serverId: serverId,
        sectionId: int.parse(sectionIdTv),
      );
      _pkgLog('libraries.deleteAllLibraryHistory', 'OK');
      await pkg.libraries.deleteLibrary(
        serverId: serverId,
        sectionId: int.parse(sectionIdTv),
      );
      _pkgLog('libraries.deleteLibrary (final)', 'OK');
    } on TautulliException catch (e) {
      _pkgLog('library destruction', 'FAIL', '$e');
    }
  }

  // 4. Restart — very last; poll status until the server recovers.
  await _capture('tautulli', 'status__pre_restart', 'status');
  try {
    await pkg.tautulli.restart();
    _pkgLog('tautulli.restart', 'OK', 'restart accepted');
  } on TautulliException catch (e) {
    _pkgLog('tautulli.restart', 'FAIL', '$e');
    return;
  }
  stdout.writeln('waiting for server to come back...');
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 5));
    try {
      final status = await _rawData('status');
      if ('${status?['result']}' == 'success') {
        _pkgLog('restart recovery', 'OK', 'back after ~${(i + 1) * 5}s');
        await _capture('tautulli', 'status__post_restart', 'status');
        return;
      }
    } on Exception {
      // still down — keep polling
    }
  }
  _pkgLog('restart recovery', 'FAIL', 'server did not return within 150s');
}
