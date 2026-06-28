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
        return http.Response(fixture(fixtureFile), 200);
      }),
    );
  }

  group('TautulliService.getSettings()', () {
    test('sends correct cmd', () async {
      makeClient('tautulli/get_settings.json');
      await client.tautulli.getSettings();
      expect(lastRequestUri.queryParameters['cmd'], 'get_settings');
    });

    test('parses date and time format', () async {
      makeClient('tautulli/get_settings.json');
      final settings = await client.tautulli.getSettings();
      expect(settings.dateFormat, 'YYYY-MM-DD');
      expect(settings.timeFormat, 'HH:mm');
    });

    test('provides rawData escape hatch', () async {
      makeClient('tautulli/get_settings.json');
      final settings = await client.tautulli.getSettings();
      expect(settings.rawData['cache_dir'], '/config/cache');
    });

    test('sends key param when specified', () async {
      makeClient('tautulli/get_settings.json');
      await client.tautulli.getSettings(key: 'date_format');
      expect(lastRequestUri.queryParameters['key'], 'date_format');
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
      expect(result['tautulli_version'], 'v2.13.4');
      expect(result['tautulli_python_version'], '3.11.0');
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
}
