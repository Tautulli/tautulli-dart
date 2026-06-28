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

  group('ApiService.docs()', () {
    test('sends correct cmd and returns map', () async {
      makeClient('api/docs.json');
      final result = await client.api.docs();
      expect(lastRequestUri.queryParameters['cmd'], 'docs');
      expect(result, isNotEmpty);
    });
  });

  group('ApiService.arnold()', () {
    test('sends correct cmd and returns string', () async {
      makeClient('api/arnold.json');
      final result = await client.api.arnold();
      expect(lastRequestUri.queryParameters['cmd'], 'arnold');
      expect(result, contains('crush'));
    });
  });
}
