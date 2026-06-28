import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tautulli/tautulli.dart';
import 'package:test/test.dart';

import 'helpers/fixture_reader.dart';

void main() {
  const connection = TautulliConnection(
    protocol: 'http',
    domain: 'localhost:8181',
    path: '/tautulli',
    apiKey: 'test_api_key',
    useDeviceToken: true,
  );

  group('TautulliClient.execute() — URI construction', () {
    test(
      'builds correct URL with protocol, domain, path, and required params',
      () async {
        late Uri captured;
        final client = TautulliClient(
          connection: connection,
          httpClient: MockClient((request) async {
            captured = request.url;
            return http.Response(fixture('success_response.json'), 200);
          }),
        );

        await client.execute('get_server_info');

        expect(captured.scheme, equals('http'));
        expect(captured.host, equals('localhost'));
        expect(captured.port, equals(8181));
        expect(captured.path, equals('/tautulli/api/v2'));
        expect(captured.queryParameters['cmd'], equals('get_server_info'));
        expect(captured.queryParameters['apikey'], equals('test_api_key'));
        expect(captured.queryParameters['app'], equals('true'));
      },
    );

    test('includes additional params as query string', () async {
      late Uri captured;
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient((request) async {
          captured = request.url;
          return http.Response(fixture('success_response.json'), 200);
        }),
      );

      await client.execute('get_history', params: {'length': 25, 'start': 0});

      expect(captured.queryParameters['length'], equals('25'));
      expect(captured.queryParameters['start'], equals('0'));
    });

    test('builds https URI when protocol is https', () async {
      late Uri captured;
      const httpsConnection = TautulliConnection(
        protocol: 'https',
        domain: 'myserver.example.com',
        apiKey: 'key',
      );
      final client = TautulliClient(
        connection: httpsConnection,
        httpClient: MockClient((request) async {
          captured = request.url;
          return http.Response(fixture('success_response.json'), 200);
        }),
      );

      await client.execute('get_server_info');

      expect(captured.scheme, equals('https'));
      expect(captured.host, equals('myserver.example.com'));
      expect(captured.path, equals('/api/v2'));
    });

    test('omits app param when useDeviceToken is false', () async {
      late Uri captured;
      const apiKeyConnection = TautulliConnection(
        protocol: 'http',
        domain: 'localhost:8181',
        apiKey: 'plain_api_key',
      );
      final client = TautulliClient(
        connection: apiKeyConnection,
        httpClient: MockClient((request) async {
          captured = request.url;
          return http.Response(fixture('success_response.json'), 200);
        }),
      );

      await client.execute('get_server_info');

      expect(captured.queryParameters.containsKey('app'), isFalse);
    });

    test('omits null params', () async {
      late Uri captured;
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient((request) async {
          captured = request.url;
          return http.Response(fixture('success_response.json'), 200);
        }),
      );

      await client.execute(
        'get_history',
        params: {'user_id': null, 'length': 25},
      );

      expect(captured.queryParameters.containsKey('user_id'), isFalse);
      expect(captured.queryParameters['length'], equals('25'));
    });
  });

  group('TautulliClient.execute() — success', () {
    test('returns the "response" object from the body', () async {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response(fixture('success_response.json'), 200),
        ),
      );

      final result = await client.execute('get_server_info');

      expect(result['result'], equals('success'));
      expect(result.containsKey('data'), isTrue);
    });
  });

  group('TautulliClient.execute() — protocol errors', () {
    test('throws TautulliProtocolException for unsupported protocol', () {
      const badConnection = TautulliConnection(
        protocol: 'ftp',
        domain: 'localhost',
        apiKey: 'key',
      );
      final client = TautulliClient(
        connection: badConnection,
        httpClient: MockClient((_) async => http.Response('', 200)),
      );

      expect(
        () => client.execute('test'),
        throwsA(isA<TautulliProtocolException>()),
      );
    });
  });

  group('TautulliClient.execute() — HTTP errors', () {
    test('throws TautulliAuthException for 401 response', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response('Authorization Required', 401),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(isA<TautulliAuthException>()),
      );
    });

    test(
      'throws TautulliAuthException when body contains "authorization required"',
      () {
        final client = TautulliClient(
          connection: connection,
          httpClient: MockClient(
            (_) async =>
                http.Response('<html>Authorization Required</html>', 200),
          ),
        );

        expect(
          () => client.execute('get_server_info'),
          throwsA(isA<TautulliAuthException>()),
        );
      },
    );

    test('throws TautulliServerException for non-200, non-401 status', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response(
            '{"response":{"result":"error","message":"oops"}}',
            500,
          ),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(
          isA<TautulliServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(500),
          ),
        ),
      );
    });

    test(
      'throws TautulliVersionException on version mismatch 400 response',
      () {
        final client = TautulliClient(
          connection: connection,
          httpClient: MockClient(
            (_) async =>
                http.Response(fixture('error_version_mismatch.json'), 400),
          ),
        );

        expect(
          () => client.execute('register_device'),
          throwsA(isA<TautulliVersionException>()),
        );
      },
    );

    test('throws TautulliTimeoutException on timeout', () {
      const timeoutConnection = TautulliConnection(
        protocol: 'http',
        domain: 'localhost',
        apiKey: 'key',
        timeout: Duration(milliseconds: 1),
      );
      final client = TautulliClient(
        connection: timeoutConnection,
        httpClient: MockClient(
          (_) => Future.delayed(
            const Duration(seconds: 5),
            () => http.Response('', 200),
          ),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(isA<TautulliTimeoutException>()),
      );
    });

    test('throws TautulliBadResponseException for non-JSON body', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response('<html>not json</html>', 200),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(isA<TautulliBadResponseException>()),
      );
    });
  });

  group('TautulliClient.execute() — Tautulli API errors', () {
    test('throws TautulliInvalidApiKeyException for invalid apikey', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response(fixture('error_invalid_apikey.json'), 200),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(isA<TautulliInvalidApiKeyException>()),
      );
    });

    test(
      'throws TautulliTerminateStreamException on terminate stream failure',
      () {
        final client = TautulliClient(
          connection: connection,
          httpClient: MockClient(
            (_) async =>
                http.Response(fixture('error_terminate_session.json'), 200),
          ),
        );

        expect(
          () => client.execute('terminate_session'),
          throwsA(isA<TautulliTerminateStreamException>()),
        );
      },
    );

    test('throws TautulliBadResponseException for generic error result', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient(
          (_) async => http.Response(
            '{"response":{"result":"error","message":"Something went wrong"}}',
            200,
          ),
        ),
      );

      expect(
        () => client.execute('get_server_info'),
        throwsA(isA<TautulliBadResponseException>()),
      );
    });
  });

  group('ImageService.buildImageUrl()', () {
    test('builds correct http URI with img param', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient((_) async => http.Response('', 200)),
      );

      final uri = client.images.buildImageUrl(
        img: '/library/metadata/123/thumb',
      );

      expect(uri.scheme, equals('http'));
      expect(uri.host, equals('localhost'));
      expect(uri.path, equals('/tautulli/api/v2'));
      expect(uri.queryParameters['cmd'], equals('pms_image_proxy'));
      expect(uri.queryParameters['apikey'], equals('test_api_key'));
      expect(uri.queryParameters['img'], equals('/library/metadata/123/thumb'));
    });

    test('builds URI with ratingKey when no img provided', () {
      final client = TautulliClient(
        connection: connection,
        httpClient: MockClient((_) async => http.Response('', 200)),
      );

      final uri = client.images.buildImageUrl(
        ratingKey: 456,
        width: 300,
        height: 450,
      );

      expect(uri.queryParameters['rating_key'], equals('456'));
      expect(uri.queryParameters['width'], equals('300'));
      expect(uri.queryParameters['height'], equals('450'));
    });
  });
}
