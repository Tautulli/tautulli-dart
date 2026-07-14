import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../utils/redact.dart';

/// Maps a network-layer [Exception] to a [TautulliException].
///
/// Native (`dart:io`) implementation: refines socket and TLS failures into
/// specific exception types. Loaded via conditional import on platforms where
/// `dart:io` is available.
TautulliException mapNetworkException(Exception e) {
  // Redirect-limit / redirect-loop failure. dart:io raises RedirectException
  // (an HttpException) when maxRedirects is exceeded; package:http's IOClient
  // rewraps it as a ClientException, carrying the message through verbatim.
  // Detect both so a followed reverse-proxy / access-gateway login redirect is
  // reported distinctly instead of being conflated with an offline connection
  // error. Kept in sync with the web mapper in errors_stub.dart.
  final redirectMessage = _redirectMessage(e);
  if (redirectMessage != null) {
    return TautulliRedirectException(message: redactApiKey(redirectMessage));
  }
  // A request the client refused to even send — most often a custom header
  // whose name or value is not valid HTTP. dart:io throws FormatException while
  // building the request (IOClient does not wrap it, since it is neither a
  // SocketException nor an HttpException), so it never reached the network:
  // report it as a request/config error, not a connection failure. Kept in
  // sync with errors_stub.dart.
  if (e is FormatException) {
    return TautulliRequestException(message: redactApiKey(e.toString()));
  }
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

/// Returns the failure message when [e] represents an exhausted or looping
/// redirect, otherwise null.
///
/// Handles both the raw dart:io [RedirectException] and the
/// [http.ClientException] that `package:http`'s `IOClient` rewraps it into
/// (`on HttpException` → `ClientException(error.message, error.uri)`), whose
/// message names the redirect (`Redirect limit exceeded`, `Redirect loop
/// detected`, …). A wrapped [SocketException] is also a [http.ClientException]
/// but its message never mentions a redirect, so it is left to fall through to
/// the socket branch.
String? _redirectMessage(Exception e) {
  if (e is RedirectException) return e.message;
  if (e is http.ClientException &&
      e.message.toLowerCase().contains('redirect')) {
    return e.message;
  }
  return null;
}

/// Extra headers for download requests.
///
/// Downloads close the connection instead of returning it to the keep-alive
/// pool: Tautulli serves live files (config, database, logs) whose size can
/// change between the Content-Length header and the body write, and the
/// surplus bytes would otherwise arrive on the pooled connection as an
/// unhandled "unsolicited response" HttpException.
const Map<String, String> downloadHeaders = {'connection': 'close'};
