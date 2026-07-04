sealed class TautulliException implements Exception {
  final String? message;
  const TautulliException({this.message});

  @override
  String toString() => '$runtimeType${message != null ? ': $message' : ''}';
}

/// Thrown when a network-level connection fails (SocketException, etc).
final class TautulliConnectionException extends TautulliException {
  const TautulliConnectionException({super.message});
}

/// Thrown when the server returns 401 or an 'Authorization Required' response.
/// Typically caused by missing HTTP basic auth headers on a reverse proxy.
final class TautulliAuthException extends TautulliException {
  const TautulliAuthException({super.message});
}

/// Thrown when Tautulli responds with 'Invalid apikey'.
final class TautulliInvalidApiKeyException extends TautulliException {
  const TautulliInvalidApiKeyException({super.message});
}

/// Thrown when the server returns a non-200, non-401 HTTP status.
final class TautulliServerException extends TautulliException {
  final int? statusCode;
  const TautulliServerException({this.statusCode, super.message});
}

/// Thrown when the response body is not valid JSON or lacks the expected structure.
final class TautulliBadResponseException extends TautulliException {
  const TautulliBadResponseException({super.message});
}

/// Thrown when the HTTP request exceeds [TautulliConnection.timeout].
final class TautulliTimeoutException extends TautulliException {
  const TautulliTimeoutException({super.message});
}

/// Thrown when the Tautulli server version is below the minimum required.
final class TautulliVersionException extends TautulliException {
  const TautulliVersionException({super.message});
}

/// Thrown when the server's TLS certificate has expired.
///
/// Raised by the native (`dart:io`) network-error mapper on a best-effort basis
/// when a TLS handshake fails specifically because the certificate is expired;
/// other verification failures surface as [TautulliCertVerificationException].
/// A caller's [http.Client] may also raise it directly (e.g. from a
/// `badCertificateCallback`).
final class TautulliCertExpiredException extends TautulliException {
  const TautulliCertExpiredException({super.message});
}

/// Thrown when TLS handshake fails with CERTIFICATE_VERIFY_FAILED.
final class TautulliCertVerificationException extends TautulliException {
  const TautulliCertVerificationException({super.message});
}

/// Thrown when the connection protocol is not 'http' or 'https'.
final class TautulliProtocolException extends TautulliException {
  const TautulliProtocolException({super.message});
}

/// Thrown when Tautulli fails to terminate a stream session.
final class TautulliTerminateStreamException extends TautulliException {
  const TautulliTerminateStreamException({super.message});
}
