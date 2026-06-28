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

  group('NetworkService.getGeoIpLookup()', () {
    test('sends correct cmd and ip_address', () async {
      makeClient('network/get_geoip_lookup.json');
      await client.network.getGeoIpLookup(ipAddress: '8.8.8.8');
      expect(lastRequestUri.queryParameters['cmd'], 'get_geoip_lookup');
      expect(lastRequestUri.queryParameters['ip_address'], '8.8.8.8');
    });

    test('parses geo data', () async {
      makeClient('network/get_geoip_lookup.json');
      final data = await client.network.getGeoIpLookup(ipAddress: '8.8.8.8');
      expect(data.country, 'Canada');
      expect(data.city, 'Toronto');
      expect(data.code, 'CA');
      expect(data.latitude, closeTo(43.65, 0.01));
      expect(data.accuracy, 10);
      expect(data.continent, 'NA');
    });

    test('throws TautulliAuthException on auth error', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'bad',
        ),
        httpClient: MockClient((_) async => http.Response('Unauthorized', 401)),
      );
      expect(
        () => client.network.getGeoIpLookup(ipAddress: '1.2.3.4'),
        throwsA(isA<TautulliAuthException>()),
      );
    });
  });

  group('NetworkService.getWhoisLookup()', () {
    test('sends correct cmd with ip_address', () async {
      makeClient('network/get_whois_lookup.json');
      final data = await client.network.getWhoisLookup(ipAddress: '8.8.8.8');
      expect(lastRequestUri.queryParameters['cmd'], 'get_whois_lookup');
      expect(lastRequestUri.queryParameters['ip_address'], '8.8.8.8');
      expect(data['country'], 'United States');
    });
  });
}
