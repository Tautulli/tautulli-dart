@TestOn('vm')
library;

import 'dart:io';

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
}
