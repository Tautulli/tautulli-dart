import 'dart:io';

import '../exceptions.dart';
import '../utils/redact.dart';

/// Maps a network-layer [Exception] to a [TautulliException].
///
/// Native (`dart:io`) implementation: refines socket and TLS failures into
/// specific exception types. Loaded via conditional import on platforms where
/// `dart:io` is available.
TautulliException mapNetworkException(Exception e) {
  if (e is SocketException) {
    return TautulliConnectionException(message: e.message);
  }
  if (e is HandshakeException) {
    final text = e.toString();
    if (text.contains('CERTIFICATE_VERIFY_FAILED')) {
      // Best-effort: distinguish an expired certificate from other verification
      // failures. The exact substring is BoringSSL/platform-dependent, so fall
      // back to the generic verification exception when it is absent.
      final lower = text.toLowerCase();
      if (lower.contains('cert_has_expired') ||
          lower.contains('certificate has expired')) {
        return TautulliCertExpiredException(message: text);
      }
      return TautulliCertVerificationException(message: text);
    }
    return TautulliConnectionException(message: e.message);
  }
  return TautulliConnectionException(message: redactApiKey(e.toString()));
}
