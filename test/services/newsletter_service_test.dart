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
      expect(result.recordsTotal, 1429);
      final entry = result.data.first;
      expect(entry.id, 69369);
      expect(entry.newsletterId, 1);
      expect(entry.agentId, 0);
      expect(entry.agentName, 'recently_added');
      expect(entry.notifyAction, 'on_cron');
      expect(entry.subjectText, 'Recently Added to TestServer! (2026-09-03)');
      expect(entry.bodyText, contains('newsletter/6ffc1fb7'));
      expect(entry.startDate, '2026-08-27');
      expect(entry.endDate, '2026-09-03');
      expect(entry.uuid, '6ffc1fb7');
      expect(entry.success, isTrue);
    });
  });

  group('NewsletterService.addNewsletterConfig()', () {
    test('sends agent_id and returns the new newsletter_id', () async {
      makeClient('newsletter/add_newsletter_config.json');
      final id = await client.newsletters.addNewsletterConfig(agentId: 0);
      expect(lastRequestUri.queryParameters['cmd'], 'add_newsletter_config');
      expect(lastRequestUri.queryParameters['agent_id'], '0');
      expect(id, 6);
    });
  });

  group('NewsletterService.getNewsletterConfig()', () {
    test('sends newsletter_id and parses the config', () async {
      makeClient('newsletter/get_newsletter_config__new.json');
      final result = await client.newsletters.getNewsletterConfig(
        newsletterId: 5,
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_newsletter_config');
      expect(lastRequestUri.queryParameters['newsletter_id'], '5');
      expect(result.newsletterId, 5);
      expect(result.agentId, 0);
      expect(result.agentName, 'recently_added');
      expect(result.agentLabel, 'Recently Added');
      expect(result.friendlyName, '');
      expect(result.active, false);
    });
  });

  group('NewsletterService.setNewsletterConfig()', () {
    test('sends newsletter_id and extraParams with correct encoding', () async {
      makeClient('success_response.json');
      await client.newsletters.setNewsletterConfig(
        newsletterId: 5,
        extraParams: {
          'friendly_name': 'My Newsletter',
          'active': true,
          'incl_libraries': [1, 2, 3],
        },
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'set_newsletter_config');
      expect(q['newsletter_id'], '5');
      expect(q['friendly_name'], 'My Newsletter');
      expect(q['active'], '1');
      expect(q['incl_libraries'], '1,2,3');
    });
  });

  group('NewsletterService.deleteNewsletter()', () {
    test('sends newsletter_id', () async {
      makeClient('success_response.json');
      await client.newsletters.deleteNewsletter(newsletterId: 5);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_newsletter');
      expect(q['newsletter_id'], '5');
    });
  });

  group('NewsletterService.deleteNewsletterLog()', () {
    test('sends the cmd with no extra params', () async {
      makeClient('success_response.json');
      await client.newsletters.deleteNewsletterLog();
      expect(lastRequestUri.queryParameters['cmd'], 'delete_newsletter_log');
    });
  });

  group('NewsletterService.notifyNewsletter()', () {
    test('sends newsletter_id, subject, body, and message', () async {
      makeClient('success_response.json');
      await client.newsletters.notifyNewsletter(
        newsletterId: 5,
        subject: 'Test Subject',
        body: 'Test Body',
        message: 'Test Message',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'notify_newsletter');
      expect(q['newsletter_id'], '5');
      expect(q['subject'], 'Test Subject');
      expect(q['body'], 'Test Body');
      expect(q['message'], 'Test Message');
    });
  });

  group('NewsletterService.deleteHostedImages()', () {
    test('sends rating_key, service, and delete_all', () async {
      makeClient('success_response.json');
      await client.newsletters.deleteHostedImages(
        ratingKey: 4017,
        service: 'imgur',
        deleteAll: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_hosted_images');
      expect(q['rating_key'], '4017');
      expect(q['service'], 'imgur');
      expect(q['delete_all'], '1');
    });
  });
}
