import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../utils/redact.dart';

/// Maps a network-layer [Exception] to a [TautulliException].
///
/// Default (non-`dart:io`) implementation used on web/WASM, where TLS and
/// socket errors are not distinguishable — they surface as generic client
/// exceptions. See `errors_io.dart` for the native implementation that refines
/// certificate and socket failures.
TautulliException mapNetworkException(Exception e) {
  // Kept in sync with errors_io.dart: a redirect-limit / redirect-loop failure
  // surfaces as a ClientException whose message names the redirect. On web the
  // browser follows redirects itself, so this is best-effort.
  if (e is http.ClientException &&
      e.message.toLowerCase().contains('redirect')) {
    return TautulliRedirectException(message: redactApiKey(e.message));
  }
  return TautulliConnectionException(message: redactApiKey(e.toString()));
}

/// Extra headers for download requests.
///
/// Empty on web: browsers forbid setting the `Connection` header (the
/// user agent manages the connection itself).
const Map<String, String> downloadHeaders = {};
