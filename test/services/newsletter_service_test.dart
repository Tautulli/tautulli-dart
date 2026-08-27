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

  group('NewsletterService.getNewsletters()', () {
    test('sends correct cmd and parses newsletters', () async {
      makeClient('newsletter/get_newsletters.json');
      final result = await client.newsletters.getNewsletters();
      expect(lastRequestUri.queryParameters['cmd'], 'get_newsletters');
      expect(result, hasLength(2));
      expect(result.first.agentName, 'recently_added');
      expect(result.first.newsletterId, 1);
      expect(result.first.active, true);
    });
  });

  group('NewsletterService.getNewsletterLog()', () {
    test('parses real row fields from the newsletter log', () async {
      makeClient('newsletter/get_newsletter_log.json');
      final result = await client.newsletters.getNewsletterLog();
      expect(lastRequestUri.queryParameters['cmd'], 'get_newsletter_log');
      expect(result.recordsTotal, 1262);
      final entry = result.data.first;
      expect(entry.id, 69202);
      expect(entry.newsletterId, 1);
      expect(entry.agentId, 0);
      expect(entry.agentName, 'recently_added');
      expect(entry.notifyAction, 'on_cron');
      expect(entry.subjectText, 'Recently Added to TestServer! (2026-08-27)');
      expect(entry.bodyText, contains('newsletter/8c1f424c'));
      expect(entry.startDate, '2026-08-20');
      expect(entry.endDate, '2026-08-27');
      expect(entry.uuid, '8c1f424c');
      expect(entry.success, isTrue);
    });
  });
}
