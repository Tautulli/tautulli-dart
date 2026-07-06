/// Package-path verification sweep (read-only).
///
/// Calls every read-only service method against the live server through
/// `TautulliClient` and reports OK / typed-exception per method, with a short
/// parsed-value summary so results can be eyeballed against the raw captures
/// from `capture.dart`. Mutating methods are exercised by the lifecycle
/// phases in `capture.dart`, not here — this sweep is always safe to run.
///
/// Requires TAUTULLI_BASE_URL, TAUTULLI_API_KEY, TAUTULLI_DEVICE_TOKEN.
/// Usage: dart run tool/live_capture/verify.dart
library;

import 'dart:io';

import 'package:tautulli/tautulli.dart';

late final TautulliClient pkg;
late final TautulliClient pkgToken;
var _ok = 0;
var _fail = 0;

Future<void> main() async {
  String req(String name) {
    final v = Platform.environment[name];
    if (v == null || v.isEmpty) {
      stderr.writeln('missing required env var: $name');
      exit(78);
    }
    return v;
  }

  final base = Uri.parse(req('TAUTULLI_BASE_URL'));
  final domain = base.hasPort ? '${base.host}:${base.port}' : base.host;
  // Optional: TAUTULLI_API_KEY_LOCATION=header runs the whole sweep through
  // X-Api-Key header auth (requires a server newer than v2.17.2).
  final keyLocation =
      Platform.environment['TAUTULLI_API_KEY_LOCATION'] == 'header'
      ? ApiKeyLocation.header
      : ApiKeyLocation.query;
  stdout.writeln('API key location: ${keyLocation.name}');
  pkg = TautulliClient(
    connection: TautulliConnection(
      protocol: base.scheme,
      domain: domain,
      path: base.path.isEmpty ? null : base.path,
      apiKey: req('TAUTULLI_API_KEY'),
      apiKeyLocation: keyLocation,
    ),
  );
  pkgToken = TautulliClient(
    connection: TautulliConnection(
      protocol: base.scheme,
      domain: domain,
      path: base.path.isEmpty ? null : base.path,
      apiKey: req('TAUTULLI_DEVICE_TOKEN'),
      useDeviceToken: true,
      apiKeyLocation: keyLocation,
    ),
  );

  try {
    await _run();
  } finally {
    pkg.close();
    pkgToken.close();
    stdout.writeln('\n=== verify sweep: $_ok OK, $_fail FAIL ===');
    exit(_fail == 0 ? 0 : 1);
  }
}

Future<void> _check(
  String name,
  Future<String> Function() body, {
  bool expectThrow = false,
  Type? expectedException,
}) async {
  try {
    final summary = await body();
    if (expectThrow) {
      _fail++;
      stdout.writeln('FAIL $name — expected an exception, got: $summary');
    } else {
      _ok++;
      stdout.writeln('OK   $name — $summary');
    }
  } on TautulliException catch (e) {
    if (expectThrow &&
        (expectedException == null || e.runtimeType == expectedException)) {
      _ok++;
      stdout.writeln('OK   $name — threw ${e.runtimeType} as expected');
    } else {
      _fail++;
      stdout.writeln('FAIL $name — ${e.runtimeType}: ${e.message}');
    }
  }
}

Future<void> _run() async {
  // ---- discovery through the package itself -------------------------------
  final libraries = await pkg.libraries.getLibraries();
  final movieLib = libraries.firstWhere(
    (l) => l.sectionType == 'movie',
    orElse: () => libraries.first,
  );
  final sectionId = movieLib.sectionId!;
  final history = await pkg.history.getHistory(length: 30);
  final movieRow = history.data.firstWhere(
    (h) => h.mediaType?.name == 'movie',
    orElse: () => history.data.first,
  );
  final episodeRows = history.data.where((h) => h.mediaType?.name == 'episode');
  final ratingKey = movieRow.ratingKey!;
  final userId = movieRow.userId!;
  final rowId = movieRow.rowId!;

  // ---- tautulli ------------------------------------------------------------
  await _check('tautulli.getTautulliInfo', () async {
    final info = await pkg.tautulli.getTautulliInfo();
    return 'version=${info['tautulli_version']}';
  });
  await _check('tautulli.getSettings (sectioned)', () async {
    final s = await pkg.tautulli.getSettings();
    final sections = s.keys.take(4).join(',');
    final general = s['General'];
    if (general is! Map<String, dynamic>) {
      throw const TautulliBadResponseException(
        message: 'expected sectioned settings with a General section',
      );
    }
    return 'sections=[$sections,…] dateFormat=${general['date_format']}';
  });
  await _check('tautulli.getSettings(key: General)', () async {
    final s = await pkg.tautulli.getSettings(key: 'General');
    return 'keys=${s.length}';
  });
  await _check('tautulli.getDateFormats', () async {
    final f = await pkg.tautulli.getDateFormats();
    return '$f';
  });
  await _check('tautulli.status', () async {
    final s = await pkg.tautulli.status();
    return 'result=${s['result'] ?? s}';
  });
  await _check('tautulli.updateCheck', () async {
    final u = await pkg.tautulli.updateCheck();
    return 'update=${u['update']}';
  });
  await _check('tautulli.downloadConfig', () async {
    final bytes = await pkg.tautulli.downloadConfig();
    return '${bytes.length} bytes';
  });
  await _check('tautulli.downloadDatabase', () async {
    final bytes = await pkg.tautulli.downloadDatabase();
    return '${bytes.length} bytes';
  });

  // ---- api -----------------------------------------------------------------
  await _check('api.docs', () async {
    final d = await pkg.api.docs();
    return '${d.length} commands documented';
  });
  await _check('api.docsMd', () async {
    final md = await pkg.api.docsMd();
    return '${md.length} chars';
  });
  await _check('api.arnold', () async {
    final quote = await pkg.api.arnold();
    return quote.length > 40 ? '${quote.substring(0, 40)}…' : quote;
  });

  // ---- plex ----------------------------------------------------------------
  await _check('plex.getServerInfo', () async {
    final s = await pkg.plex.getServerInfo();
    return 'name=${s.pmsName} identifier-set=${s.pmsIdentifier != null}';
  });
  final serverInfo = await pkg.plex.getServerInfo();
  await _check('plex.getServerIdentity', () async {
    final i = await pkg.plex.getServerIdentity();
    return 'keys=${i.keys.join(",")}';
  });
  await _check('plex.getServerFriendlyName', () async {
    return await pkg.plex.getServerFriendlyName();
  });
  await _check('plex.getServerId (identifier extraction)', () async {
    final id = await pkg.plex.getServerId(
      hostname: serverInfo.pmsIp!,
      port: serverInfo.pmsPort!,
    );
    if (id.isEmpty) {
      throw const TautulliBadResponseException(message: 'empty identifier');
    }
    return 'identifier=${id.substring(0, 8)}…';
  });
  await _check('plex.getServerList', () async {
    final l = await pkg.plex.getServerList();
    return '${l.length} servers';
  });
  await _check('plex.getServerPref(FriendlyName)', () async {
    return await pkg.plex.getServerPref(pref: 'FriendlyName');
  });
  await _check('plex.getServersInfo', () async {
    final l = await pkg.plex.getServersInfo();
    return '${l.length} servers';
  });
  await _check('plex.getPmsUpdate', () async {
    final u = await pkg.plex.getPmsUpdate();
    return 'update_available=${u['update_available']}';
  });
  await _check('plex.serverStatus', () async {
    final s = await pkg.plex.serverStatus();
    return 'connected=${s['connected']}';
  });
  await _check('plex.getSyncedItems (retired feature)', () async {
    final l = await pkg.plex.getSyncedItems();
    return '${l.length} items (Plex Sync retired)';
  });

  // ---- libraries -----------------------------------------------------------
  await _check('libraries.getLibraries', () async {
    final l = await pkg.libraries.getLibraries();
    return '${l.length} sections';
  });
  await _check('libraries.getLibraryNames', () async {
    final l = await pkg.libraries.getLibraryNames();
    return '${l.length} names';
  });
  await _check('libraries.getLibrary', () async {
    final l = await pkg.libraries.getLibrary(sectionId: sectionId);
    return 'name=${l.sectionName} count=${l.count}';
  });
  await _check('libraries.getLibrariesTable', () async {
    final t = await pkg.libraries.getLibrariesTable();
    return '${t.data.length} rows (total=${t.recordsTotal})';
  });
  await _check('libraries.getLibraryMediaInfo', () async {
    final t = await pkg.libraries.getLibraryMediaInfo(
      sectionId: sectionId,
      length: 5,
    );
    return '${t.data.length} rows (total=${t.recordsTotal})';
  });
  await _check('libraries.getLibraryUserStats', () async {
    final l = await pkg.libraries.getLibraryUserStats(sectionId: sectionId);
    return '${l.length} user stats';
  });
  await _check('libraries.getLibraryWatchTimeStats', () async {
    final l = await pkg.libraries.getLibraryWatchTimeStats(
      sectionId: sectionId,
    );
    return '${l.length} periods';
  });
  await _check('libraries.getCollectionsTable', () async {
    final t = await pkg.libraries.getCollectionsTable(sectionId: sectionId);
    return '${t.data.length} rows';
  });
  await _check('libraries.getPlaylistsTable', () async {
    final t = await pkg.libraries.getPlaylistsTable();
    return '${t.data.length} rows';
  });
  await _check('libraries.getRecentlyAdded', () async {
    final l = await pkg.libraries.getRecentlyAdded(count: 5);
    return '${l.length} items';
  });

  // ---- users -----------------------------------------------------------------
  await _check('users.getUsers', () async {
    final u = await pkg.users.getUsers();
    return '${u.length} users';
  });
  await _check('users.getUserNames', () async {
    final u = await pkg.users.getUserNames();
    return '${u.length} names';
  });
  await _check('users.getUser', () async {
    final u = await pkg.users.getUser(userId: userId);
    return 'username-set=${u.username != null} isActive=${u.isActive}';
  });
  await _check('users.getUsersTable', () async {
    final t = await pkg.users.getUsersTable();
    return '${t.data.length} rows (total=${t.recordsTotal})';
  });
  await _check('users.getUserIps', () async {
    final t = await pkg.users.getUserIps(userId: userId);
    return '${t.data.length} rows';
  });
  await _check('users.getUserLogins', () async {
    final t = await pkg.users.getUserLogins();
    return '${t.data.length} rows';
  });
  await _check('users.getUserPlayerStats', () async {
    final l = await pkg.users.getUserPlayerStats(userId: userId);
    return '${l.length} players';
  });
  await _check('users.getUserWatchTimeStats', () async {
    final l = await pkg.users.getUserWatchTimeStats(userId: userId);
    return '${l.length} periods';
  });

  // ---- history ----------------------------------------------------------------
  await _check('history.getHistory', () async {
    final h = await pkg.history.getHistory(length: 10);
    final first = h.data.first;
    return '${h.data.length} rows; first: ${first.fullTitle} '
        'date.isUtc=${first.date?.isUtc}';
  });
  await _check('history.getHistory (filters)', () async {
    final h = await pkg.history.getHistory(
      userId: userId,
      mediaType: 'movie',
      grouping: true,
      length: 5,
    );
    return '${h.data.length} rows';
  });
  await _check('history.getHomeStats', () async {
    final s = await pkg.history.getHomeStats();
    return '${s.length} stat groups';
  });
  await _check('history.getHomeStats(statId: topMovies)', () async {
    final s = await pkg.history.getHomeStats(statId: StatIdType.topMovies);
    return 'rows=${s.firstOrNull?.rows.length}';
  });

  // ---- graphs -------------------------------------------------------------
  await _check('graphs.getPlaysByDate (+alignment)', () async {
    final g = await pkg.graphs.getPlaysByDate(
      yAxis: PlayMetricType.plays,
      timeRange: 30,
    );
    final aligned = g.series.every((s) => s.data.length == g.categories.length);
    if (!aligned) {
      throw const TautulliBadResponseException(
        message: 'series/categories misaligned',
      );
    }
    return '${g.categories.length} categories × ${g.series.length} series';
  });
  await _check('graphs.getPlaysByDate(yAxis: time/duration)', () async {
    final g = await pkg.graphs.getPlaysByDate(
      yAxis: PlayMetricType.time,
      timeRange: 30,
    );
    return '${g.series.length} series';
  });
  await _check('graphs.getConcurrentStreamsByStreamType', () async {
    final g = await pkg.graphs.getConcurrentStreamsByStreamType(timeRange: 30);
    return '${g.series.length} series';
  });
  await _check('graphs.getPlaysByMonth', () async {
    final g = await pkg.graphs.getPlaysByMonth(
      yAxis: PlayMetricType.plays,
      timeRange: 6,
    );
    return '${g.categories.length} months';
  });

  // ---- media -----------------------------------------------------------------
  await _check('media.getMetadata', () async {
    final m = await pkg.media.getMetadata(ratingKey: ratingKey);
    return 'title=${m.title} mediaInfo-set=${m.mediaInfo != null}';
  });
  if (episodeRows.isNotEmpty) {
    await _check('media.getChildrenMetadata(season)', () async {
      final children = await pkg.media.getChildrenMetadata(
        ratingKey: episodeRows.first.parentRatingKey!,
        mediaType: 'season',
      );
      return '${children.length} episodes';
    });
  }
  await _check('media.search', () async {
    final r = await pkg.media.search(query: movieRow.title ?? 'a', limit: 5);
    return 'result-keys=${r['results_count'] ?? r.keys.length}';
  });
  await _check('media.getItemUserStats', () async {
    final l = await pkg.media.getItemUserStats(ratingKey: ratingKey);
    return '${l.length} users';
  });
  await _check('media.getItemWatchTimeStats', () async {
    final l = await pkg.media.getItemWatchTimeStats(ratingKey: ratingKey);
    return '${l.length} periods';
  });

  // ---- activity (no live session required) -----------------------------------
  await _check('activity.getActivity', () async {
    final a = await pkg.activity.getActivity();
    return 'streamCount=${a.streamCount}';
  });
  await _check('activity.getStreamData(rowId:) (§ fix)', () async {
    final d = await pkg.activity.getStreamData(rowId: rowId);
    if (d.isEmpty) {
      throw const TautulliBadResponseException(message: 'empty stream data');
    }
    return '${d.length} keys, media_type=${d['media_type']}';
  });
  await _check(
    'activity.terminateSession (invalid → typed error)',
    () async {
      await pkg.activity.terminateSession(sessionKey: 999999);
      return 'no exception';
    },
    expectThrow: true,
    expectedException: TautulliTerminateStreamException,
  );

  // ---- logs ----------------------------------------------------------------
  await _check('logs.getLogs', () async {
    final l = await pkg.logs.getLogs(end: 10);
    return '${l.length} entries';
  });
  await _check('logs.getPlexLog (§ nested-rows fix)', () async {
    final l = await pkg.logs.getPlexLog(window: 10);
    if (l.isEmpty) {
      throw const TautulliBadResponseException(message: '0 rows parsed');
    }
    return '${l.length} rows; first level=${l.first.level}';
  });
  await _check('logs.downloadLog', () async {
    final bytes = await pkg.logs.downloadLog();
    return '${bytes.length} bytes';
  });
  await _check('logs.downloadPlexLog', () async {
    final bytes = await pkg.logs.downloadPlexLog();
    return '${bytes.length} bytes';
  });

  // ---- network ----------------------------------------------------------------
  await _check('network.getGeoIpLookup', () async {
    final g = await pkg.network.getGeoIpLookup(ipAddress: '8.8.8.8');
    return 'country=${g.country}';
  });
  await _check('network.getWhoisLookup', () async {
    final w = await pkg.network.getWhoisLookup(ipAddress: '8.8.8.8');
    return 'host=${w['host']}';
  });

  // ---- notifications / newsletters / exports (reads) -----------------------
  await _check('notifications.getNotifiers', () async {
    final n = await pkg.notifications.getNotifiers();
    return '${n.length} notifiers';
  });
  await _check('notifications.getNotifierParameters', () async {
    final p = await pkg.notifications.getNotifierParameters();
    return '${p.length} parameters';
  });
  await _check('notifications.getNotificationLog', () async {
    final t = await pkg.notifications.getNotificationLog(length: 5);
    return '${t.data.length} rows';
  });
  await _check('newsletters.getNewsletters', () async {
    final n = await pkg.newsletters.getNewsletters();
    return '${n.length} newsletters';
  });
  await _check('newsletters.getNewsletterLog', () async {
    final t = await pkg.newsletters.getNewsletterLog(length: 5);
    return '${t.data.length} rows';
  });
  await _check('exports.getExportFields', () async {
    final f = await pkg.exports.getExportFields(
      mediaType: 'movie',
      subMediaType: '',
    );
    return 'field-groups=${f.keys.length}';
  });
  await _check('exports.getExportsTable', () async {
    final t = await pkg.exports.getExportsTable();
    return '${t.data.length} rows';
  });

  // ---- device-token auth path ------------------------------------------------
  await _check('deviceToken client: getServerFriendlyName', () async {
    return await pkgToken.plex.getServerFriendlyName();
  });
  await _check(
    'wrong key → TautulliInvalidApiKeyException',
    () async {
      final bad = TautulliClient(
        connection: pkg.connection.copyWith(
          apiKey: '0123456789abcdef0123456789abcdef',
        ),
      );
      try {
        await bad.plex.getServerFriendlyName();
        return 'no exception';
      } finally {
        bad.close();
      }
    },
    expectThrow: true,
    expectedException: TautulliInvalidApiKeyException,
  );
}
