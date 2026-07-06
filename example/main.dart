import 'package:tautulli/tautulli.dart';

Future<void> main() async {
  // Plain API key auth (default).
  // Find your API key in Tautulli → Settings → Web Interface → API Key.
  final client = TautulliClient(
    connection: const TautulliConnection(
      protocol: 'http',
      domain: '192.168.0.2:8181',
      apiKey: 'your_api_key_here',
    ),
  );

  // Device token auth — use this when the apiKey is a device-scoped token
  // obtained via client.devices.registerDevice(...).
  // final client = TautulliClient(
  //   connection: TautulliConnection(
  //     protocol: 'http',
  //     domain: '192.168.0.2:8181',
  //     apiKey: 'your_device_token_here',
  //     useDeviceToken: true,
  //   ),
  // );

  try {
    final formats = await client.tautulli.getDateFormats();
    print('Date format: ${formats['date_format']}');
    print('Time format: ${formats['time_format']}');

    final activity = await client.activity.getActivity();
    print('Active streams: ${activity.streamCount ?? 0}');
    for (final session in activity.sessions) {
      print('  ${session.friendlyName} — ${session.title}');
    }
  } on TautulliAuthException {
    print('Invalid API key or device token.');
  } on TautulliConnectionException catch (e) {
    print('Could not reach server: ${e.message}');
  } on TautulliTimeoutException {
    print('Request timed out.');
  } on TautulliException catch (e) {
    print('Tautulli error: $e');
  } finally {
    client.close();
  }
}
