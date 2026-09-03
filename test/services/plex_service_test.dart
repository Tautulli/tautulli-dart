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

  group('PlexService.getServerInfo()', () {
    test('sends correct cmd', () async {
      makeClient('plex/get_server_info.json');
      await client.plex.getServerInfo();
      expect(lastRequestUri.queryParameters['cmd'], 'get_server_info');
    });

    test('parses server info', () async {
      makeClient('plex/get_server_info.json');
      final info = await client.plex.getServerInfo();
      expect(info.pmsName, 'TestServer');
      expect(info.pmsIdentifier, 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee10');
      expect(info.pmsPlexpass, isTrue);
      expect(info.pmsPort, 32400);
      expect(info.pmsVersion, '1.43.4.10903-e5521bd8c');
    });

    test('throws TautulliInvalidApiKeyException for bad key', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'bad',
        ),
        httpClient: MockClient(
          (_) async => fixtureResponse('auth/auth__bad_key.json'),
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
      expect(
        result['machine_identifier'],
        'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee10',
      );
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
      expect(id, 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee10');
    });
  });

  group('PlexService.getServerList()', () {
    test('sends all_servers as a literal true/false string', () async {
      makeClient('plex/get_server_list.json');
      await client.plex.getServerList(allServers: true);
      var q = lastRequestUri.queryParameters;
      // The server tests `not (all_servers == 'false')`, so '1'/'0' would
      // both read as true — the literal string is required.
      expect(q['all_servers'], 'true');
      expect(q.containsKey('include_cloud'), isFalse);

      makeClient('plex/get_server_list.json');
      await client.plex.getServerList(allServers: false);
      q = lastRequestUri.queryParameters;
      expect(q['all_servers'], 'false');
    });
  });
}
