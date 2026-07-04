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

    test('parses date and time format from the General section', () async {
      makeClient('tautulli/get_settings.json');
      final settings = await client.tautulli.getSettings();
      expect(settings.dateFormat, 'YYYY-MM-DD');
      expect(settings.timeFormat, 'hh:mm a');
    });

    test('provides rawData escape hatch with full sectioned map', () async {
      makeClient('tautulli/get_settings.json');
      final settings = await client.tautulli.getSettings();
      final pms = settings.rawData['PMS'] as Map<String, dynamic>;
      expect(pms['pms_name'], 'TestServer');
    });

    test('falls back to root keys for a single-section response', () async {
      makeClient('tautulli/get_settings__key_general.json');
      final settings = await client.tautulli.getSettings(key: 'General');
      expect(lastRequestUri.queryParameters['key'], 'General');
      expect(settings.dateFormat, 'YYYY-MM-DD');
      expect(settings.timeFormat, 'hh:mm a');
    });
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
      expect(result['tautulli_version'], 'v2.17.2');
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
      makeClient('success_response.json');
      await client.tautulli.logoutUserSession(rowIds: [2, 3]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'logout_user_session');
      expect(q['row_ids'], '2,3');
      expect(q.containsKey('row_id'), isFalse);
    });
  });
}
