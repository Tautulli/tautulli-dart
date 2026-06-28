/// Immutable connection configuration for a Tautulli server.
class TautulliConnection {
  /// HTTP scheme — `'http'` or `'https'`.
  final String protocol;

  /// Hostname or IP address, including port if non-standard (e.g. `'192.168.1.1:8181'`).
  final String domain;

  /// Optional URL path prefix (e.g. `'/tautulli'`) when Tautulli is hosted at a subpath.
  final String? path;

  /// Tautulli API key or device token used to authenticate requests.
  final String apiKey;

  /// Additional HTTP headers merged into every request (e.g. for reverse-proxy auth).
  final Map<String, String> headers;

  /// Per-request timeout applied to every HTTP call.
  final Duration timeout;

  /// When true, adds `app=true` to every request, which instructs Tautulli to
  /// require a Device Token instead of a plain API Key. Set this when the
  /// apiKey is a device-scoped token obtained via `register_device`.
  final bool useDeviceToken;

  const TautulliConnection({
    required this.protocol,
    required this.domain,
    this.path,
    required this.apiKey,
    this.headers = const {},
    this.timeout = const Duration(seconds: 30),
    this.useDeviceToken = false,
  });
}
