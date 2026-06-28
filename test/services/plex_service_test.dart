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
        httpClient: MockClient((_) async => http.Response(fixture('error_invalid_apikey.json'), 200)),
      );
      expect(() => client.plex.getServerInfo(), throwsA(isA<TautulliInvalidApiKeyException>()));
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
}
