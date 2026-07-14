@TestOn('vm')
library;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tautulli/src/net/errors_io.dart';
import 'package:tautulli/tautulli.dart';
import 'package:test/test.dart';

void main() {
  group('mapNetworkException — TLS handshake failures', () {
    test('expired certificate maps to TautulliCertExpiredException', () {
      const e = HandshakeException(
        'CERTIFICATE_VERIFY_FAILED: certificate has expired',
      );
      expect(mapNetworkException(e), isA<TautulliCertExpiredException>());
    });

    test('CERT_HAS_EXPIRED marker maps to TautulliCertExpiredException', () {
      const e = HandshakeException(
        'CERTIFICATE_VERIFY_FAILED: CERT_HAS_EXPIRED',
      );
      expect(mapNetworkException(e), isA<TautulliCertExpiredException>());
    });

    test('other verify failures map to TautulliCertVerificationException', () {
      const e = HandshakeException(
        'CERTIFICATE_VERIFY_FAILED: self signed certificate',
      );
      expect(mapNetworkException(e), isA<TautulliCertVerificationException>());
    });

    test('a non-TLS handshake failure maps to a connection exception', () {
      const e = HandshakeException('connection reset');
      expect(mapNetworkException(e), isA<TautulliConnectionException>());
    });

    test('a SocketException maps to a connection exception', () {
      expect(
        mapNetworkException(const SocketException('no route to host')),
        isA<TautulliConnectionException>(),
      );
    });
  });

  group('mapNetworkException — redirect failures', () {
    test('a raw RedirectException maps to TautulliRedirectException', () {
      const e = RedirectException('Redirect limit exceeded', []);
      expect(mapNetworkException(e), isA<TautulliRedirectException>());
    });

    test('the IOClient-wrapped redirect ClientException maps to '
        'TautulliRedirectException', () {
      // package:http's IOClient rewraps dart:io RedirectException as a plain
      // ClientException carrying the message, so this is the type that actually
      // reaches the mapper at runtime.
      final e = http.ClientException('Redirect limit exceeded');
      expect(mapNetworkException(e), isA<TautulliRedirectException>());
    });

    test('a redirect failure carries the underlying message through', () {
      final e = http.ClientException('Redirect loop detected');
      final mapped = mapNetworkException(e);
      expect(mapped.message, 'Redirect loop detected');
    });

    test('TautulliRedirectException is still a TautulliConnectionException '
        'so callers that only handle connection failures keep working', () {
      const e = RedirectException('Redirect limit exceeded', []);
      expect(mapNetworkException(e), isA<TautulliConnectionException>());
    });

    test('a non-redirect ClientException stays a plain connection exception',
        () {
      final e = http.ClientException('Connection closed before full header');
      final mapped = mapNetworkException(e);
      expect(mapped, isA<TautulliConnectionException>());
      expect(mapped, isNot(isA<TautulliRedirectException>()));
    });

    test('a wrapped SocketException is not misread as a redirect', () {
      // _ClientSocketException is both a SocketException and a ClientException;
      // its message never mentions a redirect, so it must map to a plain
      // connection exception, not a redirect one.
      final e = http.ClientException('Connection refused (errno 111)');
      expect(mapNetworkException(e), isNot(isA<TautulliRedirectException>()));
    });
  });

  group('mapNetworkException — malformed request', () {
    test('a FormatException maps to TautulliRequestException', () {
      // dart:io throws this from HttpHeaders.set when a custom header name
      // contains an illegal character such as ':'. IOClient does not wrap it,
      // so it reaches the mapper as a raw FormatException.
      const e = FormatException(
        'Invalid HTTP header field name: "CF-Access-Client-Id:"',
      );
      expect(mapNetworkException(e), isA<TautulliRequestException>());
    });

    test('a FormatException is NOT reported as a connection failure', () {
      // The whole point: a request that never touched the network must not be
      // mislabeled as "no connectivity".
      const e = FormatException('Invalid HTTP header field name: "a b"');
      final mapped = mapNetworkException(e);
      expect(mapped, isA<TautulliRequestException>());
      expect(mapped, isNot(isA<TautulliConnectionException>()));
    });

    test('a request failure carries the underlying message through', () {
      const e = FormatException('Invalid HTTP header field name: "a:b"');
      final mapped = mapNetworkException(e);
      expect(mapped.message, contains('Invalid HTTP header field name'));
    });
  });
}
