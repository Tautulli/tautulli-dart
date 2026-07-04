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

  group('DeviceService.registerDevice()', () {
    test('sends correct cmd and required params', () async {
      makeClient('device/register_device.json');
      await client.devices.registerDevice(
        deviceName: 'TestPhone',
        deviceId: 'device-uuid-123',
        onesignalId: 'onesignal-id-abc',
        platform: 'android',
        version: '3.5.1',
      );
      expect(lastRequestUri.queryParameters['cmd'], 'register_device');
      expect(lastRequestUri.queryParameters['device_name'], 'TestPhone');
      expect(lastRequestUri.queryParameters['device_id'], 'device-uuid-123');
      expect(lastRequestUri.queryParameters['platform'], 'android');
    });

    test('parses register result', () async {
      makeClient('device/register_device.json');
      final result = await client.devices.registerDevice(
        deviceName: 'TestPhone',
        deviceId: 'device-uuid-123',
        onesignalId: 'onesignal-id-abc',
        platform: 'android',
        version: '3.5.1',
      );
      expect(result.pmsName, 'My Plex Server');
      expect(result.serverId, 'abc123def456');
      expect(result.tautulliVersion, 'v2.17.0');
      expect(result.pmsPlexpass, isTrue);
      expect(result.pmsIsCloud, isFalse);
    });

    test('includes minVersion when provided', () async {
      makeClient('device/register_device.json');
      await client.devices.registerDevice(
        deviceName: 'TestPhone',
        deviceId: 'id',
        onesignalId: 'oid',
        platform: 'ios',
        version: '3.5.1',
        minVersion: 'v2.10.5',
      );
      expect(lastRequestUri.queryParameters['min_version'], 'v2.10.5');
    });

    test('requires only deviceId/deviceName; sends friendlyName', () async {
      makeClient('device/register_device.json');
      await client.devices.registerDevice(
        deviceId: 'id',
        deviceName: 'TestPhone',
        friendlyName: 'My Phone',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['device_id'], 'id');
      expect(q['device_name'], 'TestPhone');
      expect(q['friendly_name'], 'My Phone');
      // optional now — not sent when omitted
      expect(q.containsKey('platform'), isFalse);
      expect(q.containsKey('onesignal_id'), isFalse);
    });
  });
}
