import 'dart:typed_data';

/// Interface implemented by [TautulliClient] and consumed by all service classes.
///
/// Decouples services from the concrete client, enabling service-level unit
/// testing with mock implementations.
abstract class TautulliExecutor {
  /// Executes a Tautulli API command and returns the parsed JSON response object.
  ///
  /// [cmd] is the Tautulli API command name (e.g. `'get_activity'`).
  /// [params] are optional query parameters forwarded with the request.
  /// [timeout] overrides the connection's default timeout for this call.
  Future<Map<String, dynamic>> execute(
    String cmd, {
    Map<String, dynamic> params,
    Duration? timeout,
  });

  /// Executes a Tautulli API command and returns the raw response bytes.
  ///
  /// Used for binary-download endpoints such as `download_log` and
  /// `download_config` where the response body is a file rather than JSON.
  /// [timeout] overrides the connection's default timeout (useful for large
  /// downloads). By default a non-binary (JSON/HTML) response at HTTP 200 is
  /// treated as an error; set [allowNonBinary] for endpoints that legitimately
  /// return text (e.g. `docs_md`).
  Future<Uint8List> executeDownload(
    String cmd, {
    Map<String, dynamic> params,
    Duration? timeout,
    bool allowNonBinary,
  });
}
