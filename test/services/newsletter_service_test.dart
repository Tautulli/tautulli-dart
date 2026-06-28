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

  group('NewsletterService.getNewsletters()', () {
    test('sends correct cmd and parses newsletters', () async {
      makeClient('newsletter/get_newsletters.json');
      final result = await client.newsletters.getNewsletters();
      expect(lastRequestUri.queryParameters['cmd'], 'get_newsletters');
      expect(result, hasLength(1));
      expect(result.first.agentName, 'recently_added');
      expect(result.first.newsletterId, 1);
      expect(result.first.active, true);
    });
  });
}
