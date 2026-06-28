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
  Future<Map<String, dynamic>> execute(
    String cmd, {
    Map<String, dynamic> params,
  });

  /// Executes a Tautulli API command and returns the raw response bytes.
  ///
  /// Used for binary-download endpoints such as `download_log` and
  /// `download_config` where the response body is a file rather than JSON.
  Future<Uint8List> executeDownload(
    String cmd, {
    Map<String, dynamic> params,
  });
}
