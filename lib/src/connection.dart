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

  /// Timeout applied to binary download commands (`download_database`,
  /// `download_log`, etc.). Large transfers can exceed [timeout], so set a
  /// longer value here. Falls back to [timeout] when null.
  final Duration? downloadTimeout;

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
    this.downloadTimeout,
    this.useDeviceToken = false,
  });

  /// Returns a copy of this connection with the given fields replaced.
  ///
  /// Because omitted arguments fall back to the current value, [copyWith]
  /// **cannot clear** the nullable [path] or [downloadTimeout] — construct a
  /// fresh [TautulliConnection] to set those back to `null`.
  TautulliConnection copyWith({
    String? protocol,
    String? domain,
    String? path,
    String? apiKey,
    Map<String, String>? headers,
    Duration? timeout,
    Duration? downloadTimeout,
    bool? useDeviceToken,
  }) {
    return TautulliConnection(
      protocol: protocol ?? this.protocol,
      domain: domain ?? this.domain,
      path: path ?? this.path,
      apiKey: apiKey ?? this.apiKey,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      downloadTimeout: downloadTimeout ?? this.downloadTimeout,
      useDeviceToken: useDeviceToken ?? this.useDeviceToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TautulliConnection &&
        other.protocol == protocol &&
        other.domain == domain &&
        other.path == path &&
        other.apiKey == apiKey &&
        other.timeout == timeout &&
        other.downloadTimeout == downloadTimeout &&
        other.useDeviceToken == useDeviceToken &&
        _headersEqual(other.headers, headers);
  }

  @override
  int get hashCode => Object.hash(
    protocol,
    domain,
    path,
    apiKey,
    timeout,
    downloadTimeout,
    useDeviceToken,
    _headersHash(headers),
  );

  /// Redacts the [apiKey] and any header values (which may carry reverse-proxy
  /// credentials), exposing only the header count.
  @override
  String toString() =>
      'TautulliConnection(protocol: $protocol, domain: $domain, '
      'path: $path, apiKey: <redacted>, headers: ${headers.length} entries, '
      'timeout: $timeout, downloadTimeout: $downloadTimeout, '
      'useDeviceToken: $useDeviceToken)';
}

/// Order-independent equality for two `<String, String>` header maps.
bool _headersEqual(Map<String, String> a, Map<String, String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

/// Order-independent hash for a `<String, String>` header map, consistent with
/// [_headersEqual].
int _headersHash(Map<String, String> headers) {
  var hash = 0;
  for (final entry in headers.entries) {
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}
