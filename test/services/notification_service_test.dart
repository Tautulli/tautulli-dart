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

  group('NotificationService.getNotifiers()', () {
    test('sends correct cmd and parses notifiers', () async {
      makeClient('notification/get_notifiers.json');
      final result = await client.notifications.getNotifiers();
      expect(lastRequestUri.queryParameters['cmd'], 'get_notifiers');
      expect(result, hasLength(10));
      expect(result.first.agentName, 'scripts');
      expect(result.first.notifierId, 3);
      expect(result.first.active, false);
    });
  });

  group('NotificationService.notify()', () {
    test('sends notifier_id, subject and body (no notify_action)', () async {
      makeClient('success_response.json');
      await client.notifications.notify(
        notifierId: 1,
        subject: 'Hello',
        body: 'Test body',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'notify');
      expect(q['notifier_id'], '1');
      expect(q['subject'], 'Hello');
      expect(q['body'], 'Test body');
      expect(q.containsKey('notify_action'), isFalse);
    });

    test('sends optional headers and script_args when provided', () async {
      makeClient('success_response.json');
      await client.notifications.notify(
        notifierId: 2,
        subject: 's',
        body: 'b',
        headers: '{"X-Test":"1"}',
        scriptArgs: '--flag',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['headers'], '{"X-Test":"1"}');
      expect(q['script_args'], '--flag');
    });
  });

  group('NotificationService.notifyRecentlyAdded()', () {
    test('sends rating_key and optional notifier_id', () async {
      makeClient('success_response.json');
      await client.notifications.notifyRecentlyAdded(
        ratingKey: 12345,
        notifierId: 3,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'notify_recently_added');
      expect(q['rating_key'], '12345');
      expect(q['notifier_id'], '3');
    });

    test('omits notifier_id when not provided', () async {
      makeClient('success_response.json');
      await client.notifications.notifyRecentlyAdded(ratingKey: 999);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'notify_recently_added');
      expect(q['rating_key'], '999');
      expect(q.containsKey('notifier_id'), isFalse);
    });
  });

  group('NotificationService.getNotifierParameters()', () {
    test('parses the parameter list (not a map)', () async {
      makeClient('notification/get_notifier_parameters.json');
      final result = await client.notifications.getNotifierParameters();
      expect(lastRequestUri.queryParameters['cmd'], 'get_notifier_parameters');
      expect(result, hasLength(304));
      expect(result.first.name, 'Tautulli Version');
      expect(result.first.type, 'str');
      expect(result.first.value, 'tautulli_version');
    });
  });

  group('NotificationService.getNotificationLog()', () {
    test('parses real row fields from the notification log', () async {
      makeClient('notification/get_notification_log.json');
      final result = await client.notifications.getNotificationLog();
      expect(lastRequestUri.queryParameters['cmd'], 'get_notification_log');
      expect(result.recordsTotal, 95840);
      final entry = result.data.first;
      expect(entry.id, 95839);
      expect(entry.notifierId, 12);
      expect(entry.agentId, 21);
      expect(entry.agentName, 'remoteapp');
      expect(entry.notifyAction, 'on_intup');
      expect(entry.subjectText, 'Tautulli (TestServer)');
      expect(entry.bodyText, 'The Plex Media Server is back up.');
      expect(entry.success, isFalse);
    });
  });
}
