import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:tautulli/tautulli.dart';
import 'package:test/test.dart';

/// An [http.Client] that records whether [close] was called.
class _RecordingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(const Stream.empty(), 200);
  }

  @override
  void close() => closed = true;
}

void main() {
  const connection = TautulliConnection(
    protocol: 'http',
    domain: 'localhost:8181',
    apiKey: 'k',
  );

  test('close() does not close an injected http.Client', () {
    final injected = _RecordingClient();
    final client = TautulliClient(connection: connection, httpClient: injected);

    client.close();

    expect(injected.closed, isFalse);
  });

  test('close() is safe to call when the client is owned', () {
    final client = TautulliClient(connection: connection);
    expect(client.close, returnsNormally);
  });
}
