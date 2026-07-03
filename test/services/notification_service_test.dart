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

  group('NotificationService.getNotifiers()', () {
    test('sends correct cmd and parses notifiers', () async {
      makeClient('notification/get_notifiers.json');
      final result = await client.notifications.getNotifiers();
      expect(lastRequestUri.queryParameters['cmd'], 'get_notifiers');
      expect(result, hasLength(1));
      expect(result.first.agentName, 'email');
      expect(result.first.notifierId, 1);
      expect(result.first.active, true);
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
}
