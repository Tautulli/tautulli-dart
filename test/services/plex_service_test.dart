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

  group('PlexService.getServerInfo()', () {
    test('sends correct cmd', () async {
      makeClient('plex/get_server_info.json');
      await client.plex.getServerInfo();
      expect(lastRequestUri.queryParameters['cmd'], 'get_server_info');
    });

    test('parses server info', () async {
      makeClient('plex/get_server_info.json');
      final info = await client.plex.getServerInfo();
      expect(info.pmsName, 'My Plex Server');
      expect(info.pmsIdentifier, 'abc123def456');
      expect(info.pmsPlexpass, isTrue);
      expect(info.pmsPort, 32400);
      expect(info.pmsVersion, '1.32.5.7516');
    });

    test('throws TautulliInvalidApiKeyException for bad key', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'bad',
        ),
        httpClient: MockClient(
          (_) async => http.Response(fixture('error_invalid_apikey.json'), 200),
        ),
      );
      expect(
        () => client.plex.getServerInfo(),
        throwsA(isA<TautulliInvalidApiKeyException>()),
      );
    });
  });

  group('PlexService.getServerIdentity()', () {
    test('sends correct cmd', () async {
      makeClient('plex/get_server_identity.json');
      final result = await client.plex.getServerIdentity();
      expect(lastRequestUri.queryParameters['cmd'], 'get_server_identity');
      expect(result['machineIdentifier'], 'abc123xyz');
    });
  });

  group('PlexService.deleteSyncedItem()', () {
    test('sends client_id and sync_id (not machine_id)', () async {
      makeClient('success_response.json');
      await client.plex.deleteSyncedItem(clientId: 'device-abc', syncId: 42);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_synced_item');
      expect(q['client_id'], 'device-abc');
      expect(q['sync_id'], '42');
      expect(q.containsKey('machine_id'), isFalse);
    });
  });

  group('PlexService.getSyncedItems()', () {
    test('returns empty list when server sends {} (sync retired)', () async {
      makeClient('plex/get_synced_items.json');
      final result = await client.plex.getSyncedItems();
      expect(lastRequestUri.queryParameters['cmd'], 'get_synced_items');
      expect(result, isEmpty);
    });
  });

  group('PlexService.getServerId()', () {
    test('sends hostname/port/ssl (no phantom remote), parses id', () async {
      makeClient('plex/get_server_id.json');
      final id = await client.plex.getServerId(
        hostname: 'localhost',
        port: 32400,
        ssl: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'get_server_id');
      expect(q['hostname'], 'localhost');
      expect(q['port'], '32400');
      expect(q['ssl'], '1');
      expect(q.containsKey('remote'), isFalse);
      // The identifier is nested under data.identifier, not a bare string.
      expect(id, '3502fd8796ee5a72045f020a30cf6f10');
    });
  });
}
