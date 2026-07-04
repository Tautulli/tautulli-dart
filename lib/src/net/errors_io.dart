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
    if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
      return TautulliCertVerificationException(message: e.toString());
    }
    return TautulliConnectionException(message: e.message);
  }
  return TautulliConnectionException(message: redactApiKey(e.toString()));
}
