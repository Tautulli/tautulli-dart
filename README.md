# tautulli

[![pub package](https://img.shields.io/pub/v/tautulli.svg)](https://pub.dev/packages/tautulli)
[![CI](https://github.com/Tautulli/tautulli-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/Tautulli/tautulli-dart/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A Dart client for the [Tautulli](https://tautulli.com/) API.

## Installation

```sh
dart pub add tautulli
```

Or add manually to `pubspec.yaml`:

```yaml
dependencies:
  tautulli: ^3.0.0
```

## Quick Start

```dart
import 'package:tautulli/tautulli.dart';

void main() async {
  final client = TautulliClient(
    connection: const TautulliConnection(
      protocol: 'http',
      domain: '192.168.0.2:8181',
      apiKey: 'your_api_key',
    ),
  );

  try {
    final activity = await client.activity.getActivity();
    print('Streaming: ${activity.streamCount} sessions');

    final history = await client.history.getHistory(length: 10);
    for (final entry in history.data) {
      print('${entry.title} watched by ${entry.friendlyName}');
    }
  } on TautulliAuthException {
    print('Invalid API key or authorization required');
  } on TautulliConnectionException {
    print('Could not reach Tautulli server');
  } finally {
    client.close();
  }
}
```

## Services

All API commands are accessible through namespaced service properties on `TautulliClient`:

| Property | Description |
|---|---|
| `client.activity` | Current playback sessions |
| `client.devices` | Mobile device registration |
| `client.exports` | Export metadata and download exports |
| `client.graphs` | Time-series chart data |
| `client.history` | Watch history and home statistics |
| `client.images` | Image proxy URL construction |
| `client.libraries` | Library/section management and media info |
| `client.logs` | Tautulli and Plex log retrieval |
| `client.media` | Metadata, search, rating keys |
| `client.network` | GeoIP and WHOIS lookups |
| `client.newsletters` | Newsletter configuration and delivery |
| `client.notifications` | Notifier configuration and notification log |
| `client.users` | User management and statistics |
| `client.api` | API documentation endpoints |
| `client.plex` | Plex Media Server identity and status |
| `client.tautulli` | Tautulli settings, info, backups, and restart |

## Custom HTTP Client

Pass a custom `http.Client` for SSL certificate handling or testing:

```dart
import 'dart:io';
import 'package:http/io_client.dart';

// Self-signed certificate support
final httpClient = HttpClient()
  ..badCertificateCallback = (cert, host, port) => allowedHosts.contains(host);

final client = TautulliClient(
  connection: const TautulliConnection(
    protocol: 'http',
    domain: '192.168.0.2:8181',
    apiKey: 'your_api_key',
  ),
  httpClient: IOClient(httpClient),
);
```

## Exception Handling

All exceptions extend the sealed `TautulliException` class:

| Exception | Thrown when |
|---|---|
| `TautulliConnectionException` | Network unreachable or socket error |
| `TautulliAuthException` | HTTP 401 or "Authorization Required" response |
| `TautulliInvalidApiKeyException` | Tautulli returns "Invalid apikey" |
| `TautulliServerException` | Non-200, non-401 HTTP status |
| `TautulliBadResponseException` | Malformed JSON or unexpected response structure |
| `TautulliTimeoutException` | Request exceeds configured timeout |
| `TautulliVersionException` | Server version below minimum requirement |
| `TautulliCertExpiredException` | TLS certificate has expired |
| `TautulliCertVerificationException` | TLS certificate verification failed |
| `TautulliProtocolException` | Protocol is not `http` or `https` |
| `TautulliTerminateStreamException` | Stream termination command failed |

## Testing

Inject a `MockClient` from `package:http/testing.dart` to unit-test code that calls
Tautulli without making real network requests:

```dart
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:tautulli/tautulli.dart';

final mockClient = MockClient((request) async {
  return http.Response(
    '{"response":{"result":"success","data":{"stream_count":2,"sessions":[]}}}',
    200,
  );
});

final client = TautulliClient(
  connection: const TautulliConnection(
    protocol: 'http',
    domain: '192.168.0.2:8181',
    apiKey: 'your_api_key',
  ),
  httpClient: mockClient,
);
```

## API Reference

All commands are documented in the [Tautulli API Reference](https://github.com/Tautulli/Tautulli/wiki/Tautulli-API-Reference).

- Minimum supported Tautulli server: **v2.10.5**
- Last audited against: **v2.17.0**

## License

GPL-3.0-or-later
