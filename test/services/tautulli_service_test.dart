import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tautulli/tautulli.dart';

import '../helpers/fixture_reader.dart';

void main() {
  late TautulliClient client;
  late Uri lastRequestUri;

  void makeClient(String fixtureFile) {
    client = TautulliClient(
      connection: const TautulliConnection(
        protocol: 'http',
        domain: 'tautulli.local',
        apiKey: 'abc123',
      ),
      httpClient: MockClient((request) async {
        lastRequestUri = request.url;
        return fixtureResponse(fixtureFile);
      }),
    );
  }

  group('TautulliService.getSettings()', () {
    test('sends correct cmd', () async {
      makeClient('tautulli/get_settings.json');
      await client.tautulli.getSettings();
      expect(lastRequestUri.queryParameters['cmd'], 'get_settings');
    });

    test('returns the raw sectioned settings map', () async {
      makeClient('tautulli/get_settings.json');
      final settings = await client.tautulli.getSettings();
      final general = settings['General'] as Map<String, dynamic>;
      final pms = settings['PMS'] as Map<String, dynamic>;
      expect(general['date_format'], 'YYYY-MM-DD');
      expect(general['time_format'], 'hh:mm a');
      expect(pms['pms_name'], 'TestServer');
    });

    test(
      'returns a single section at the top level when key is given',
      () async {
        makeClient('tautulli/get_settings__key_general.json');
        final settings = await client.tautulli.getSettings(key: 'General');
        expect(lastRequestUri.queryParameters['key'], 'General');
        expect(settings['date_format'], 'YYYY-MM-DD');
        expect(settings['time_format'], 'hh:mm a');
      },
    );
  });

  group('TautulliService.deleteImageCache()', () {
    test('sends correct cmd', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response(
            jsonEncode({
              'response': {'result': 'success', 'message': null, 'data': null},
            }),
            200,
          );
        }),
      );
      await client.tautulli.deleteImageCache();
      expect(lastRequestUri.queryParameters['cmd'], 'delete_image_cache');
    });
  });

  group('TautulliService.getTautulliInfo()', () {
    test('sends correct cmd', () async {
      makeClient('tautulli/get_tautulli_info.json');
      final result = await client.tautulli.getTautulliInfo();
      expect(lastRequestUri.queryParameters['cmd'], 'get_tautulli_info');
      expect(result['tautulli_version'], 'v2.18.2');
      expect(result['tautulli_platform'], 'Linux');
    });
  });

  group('TautulliService.getDateFormats()', () {
    test('sends correct cmd', () async {
      makeClient('tautulli/get_date_formats.json');
      final result = await client.tautulli.getDateFormats();
      expect(lastRequestUri.queryParameters['cmd'], 'get_date_formats');
      expect(result['date_format'], 'YYYY-MM-DD');
    });
  });

  group('TautulliService.logoutUserSession()', () {
    test('sends row_ids (plural) as a comma-separated list', () async {
      makeClient('tautulli/logout_user_session.json');
      await client.tautulli.logoutUserSession(rowIds: [2, 3]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'logout_user_session');
      expect(q['row_ids'], '2,3');
      expect(q.containsKey('row_id'), isFalse);
    });
  });

  group('TautulliService.status()', () {
    test('sends correct cmd', () async {
      makeClient('tautulli/status.json');
      final result = await client.tautulli.status();
      expect(lastRequestUri.queryParameters['cmd'], 'status');
      expect(result, isEmpty);
    });

    test('sends check param and parses result', () async {
      makeClient('tautulli/status__check_database.json');
      final result = await client.tautulli.status(check: 'database');
      expect(lastRequestUri.queryParameters['check'], 'database');
      expect(result['integrity_check'], 'ok');
    });
  });

  group('TautulliService.updateCheck()', () {
    test('sends correct cmd and parses result', () async {
      makeClient('tautulli/update_check.json');
      final result = await client.tautulli.updateCheck();
      expect(lastRequestUri.queryParameters['cmd'], 'update_check');
      expect(result['update'], isTrue);
      expect(
        result['current_version'],
        '5a39bac6f524a23ab79cef8b08f8126f5134a99e',
      );
      expect(result['commits_behind'], 3);
    });
  });

  group('TautulliService.sql()', () {
    test('sends query param and parses rows', () async {
      makeClient('tautulli/sql__select1.json');
      final result = await client.tautulli.sql(query: 'SELECT 1 AS one');
      expect(lastRequestUri.queryParameters['cmd'], 'sql');
      expect(lastRequestUri.queryParameters['query'], 'SELECT 1 AS one');
      expect(result, [
        {'one': 1},
      ]);
    });

    test('parses multi-column rows from a different query shape', () async {
      makeClient('tautulli/sql__user_flags_after_edit.json');
      final result = await client.tautulli.sql(
        query:
            'SELECT friendly_name, keep_history, allow_guest FROM users '
            'WHERE user_id = 1',
      );
      expect(result.single['friendly_name'], 'dart-edit-check');
      expect(result.single['keep_history'], 1);
    });
  });

  group('TautulliService.downloadConfig()', () {
    test('sends cmd and returns bytes', () async {
      final meta =
          json.decode(fixture('tautulli/download_config.meta.json'))
              as Map<String, dynamic>;
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response.bytes(
            [1, 2, 3],
            meta['status'] as int,
            headers: {'content-type': meta['content_type'] as String},
          );
        }),
      );
      final result = await client.tautulli.downloadConfig();
      expect(lastRequestUri.queryParameters['cmd'], 'download_config');
      expect(result, [1, 2, 3]);
    });
  });

  group('TautulliService.downloadDatabase()', () {
    test('sends cmd and returns bytes', () async {
      final meta =
          json.decode(fixture('tautulli/download_database.meta.json'))
              as Map<String, dynamic>;
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response.bytes(
            [1, 2, 3],
            meta['status'] as int,
            headers: {'content-type': meta['content_type'] as String},
          );
        }),
      );
      final result = await client.tautulli.downloadDatabase();
      expect(lastRequestUri.queryParameters['cmd'], 'download_database');
      expect(result, [1, 2, 3]);
    });
  });

  group('TautulliService.update()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.update();
      expect(lastRequestUri.queryParameters['cmd'], 'update');
    });
  });

  group('TautulliService.restart()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.restart();
      expect(lastRequestUri.queryParameters['cmd'], 'restart');
    });
  });

  group('TautulliService.backupConfig()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.backupConfig();
      expect(lastRequestUri.queryParameters['cmd'], 'backup_config');
    });
  });

  group('TautulliService.backupDb()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.backupDb();
      expect(lastRequestUri.queryParameters['cmd'], 'backup_db');
    });
  });

  group('TautulliService.deleteCache()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.deleteCache();
      expect(lastRequestUri.queryParameters['cmd'], 'delete_cache');
    });
  });

  group('TautulliService.deleteTempSessions()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.tautulli.deleteTempSessions();
      expect(lastRequestUri.queryParameters['cmd'], 'delete_temp_sessions');
    });
  });

  group('TautulliService.importConfig()', () {
    test('throws UnimplementedError', () async {
      makeClient('success_response.json');
      expect(
        () => client.tautulli.importConfig(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('TautulliService.importDatabase()', () {
    test('throws UnimplementedError', () async {
      makeClient('success_response.json');
      expect(
        () => client.tautulli.importDatabase(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
