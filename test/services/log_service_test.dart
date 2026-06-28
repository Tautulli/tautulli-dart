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

  group('LogService.getLogs()', () {
    test('sends correct cmd and parses object format', () async {
      makeClient('log/get_logs.json');
      final result = await client.logs.getLogs();
      expect(lastRequestUri.queryParameters['cmd'], 'get_logs');
      expect(result, hasLength(2));
      expect(result.first.level, 'INFO');
      expect(result.first.message, 'Tautulli started');
      expect(result.first.thread, 'MainThread');
      expect(result.first.timestamp, '2024-01-01 12:00:00');
    });

    test('sends order and regex params', () async {
      makeClient('log/get_logs.json');
      await client.logs.getLogs(order: 'asc', regex: 'error');
      expect(lastRequestUri.queryParameters['order'], 'asc');
      expect(lastRequestUri.queryParameters['regex'], 'error');
    });
  });
}
