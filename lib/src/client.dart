import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'connection.dart';
import 'exceptions.dart';
import 'executor.dart';
import 'net/errors_stub.dart' if (dart.library.io) 'net/errors_io.dart';
import 'net/uri.dart';
import 'services/activity_service.dart';
import 'services/api_service.dart';
import 'services/device_service.dart';
import 'services/export_service.dart';
import 'services/graph_service.dart';
import 'services/history_service.dart';
import 'services/image_service.dart';
import 'services/library_service.dart';
import 'services/log_service.dart';
import 'services/media_service.dart';
import 'services/network_service.dart';
import 'services/newsletter_service.dart';
import 'services/notification_service.dart';
import 'services/plex_service.dart';
import 'services/tautulli_service.dart';
import 'services/user_service.dart';

/// The main entry point for interacting with the Tautulli API.
///
/// Create an instance with a [TautulliConnection] and then call methods on the
/// service accessors (e.g. [activity], [history], [libraries]).
///
/// ```dart
/// final client = TautulliClient(
///   connection: TautulliConnection(
///     protocol: 'https',
///     domain: 'tautulli.example.com',
///     apiKey: 'your_api_key',
///   ),
/// );
/// final data = await client.activity.getActivity();
/// client.close();
/// ```
class TautulliClient implements TautulliExecutor {
  /// The connection configuration used for all API requests.
  final TautulliConnection connection;
  final http.Client _httpClient;

  /// Whether this client created [_httpClient] itself. Injected clients are the
  /// caller's to close, so [close] only closes the owned one.
  final bool _ownsClient;

  /// Creates a [TautulliClient] with the given [connection].
  ///
  /// An optional [httpClient] can be supplied for testing or to configure
  /// SSL/TLS behaviour (e.g. to allow self-signed certificates). An injected
  /// [httpClient] is **not** closed by [close] — the caller retains ownership
  /// and is responsible for closing it.
  TautulliClient({required this.connection, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _ownsClient = httpClient == null;

  /// Service for `get_activity`, `get_stream_data`, and `terminate_session`.
  late final ActivityService activity = ActivityService(this);

  /// Service for graph endpoints (`get_plays_by_date`, `get_plays_by_stream_type`, etc.).
  late final GraphService graphs = GraphService(this);

  /// Service for `get_history`, `get_home_stats`, and related history commands.
  late final HistoryService history = HistoryService(this);

  /// Service for library endpoints (`get_libraries`, `get_library_media_info`, etc.).
  late final LibraryService libraries = LibraryService(this);

  /// Service for `get_metadata`, `get_children_metadata`, `search`, and related commands.
  late final MediaService media = MediaService(this);

  /// Service for Plex Media Server info endpoints (`get_server_info`, `server_status`, etc.).
  late final PlexService plex = PlexService(this);

  /// Service for Tautulli management commands (`get_settings`, `restart`, `backup_config`, etc.).
  late final TautulliService tautulli = TautulliService(this);

  /// Service for user endpoints (`get_user`, `get_users`, `get_user_watch_time_stats`, etc.).
  late final UserService users = UserService(this);

  /// Service for notifier configuration and `notify`/`notify_recently_added` commands.
  late final NotificationService notifications = NotificationService(this);

  /// Service for newsletter configuration and `notify_newsletter` commands.
  late final NewsletterService newsletters = NewsletterService(this);

  /// Service for `get_exports_table`, `export_metadata`, and `download_export`.
  late final ExportService exports = ExportService(this);

  /// Service for `get_logs`, `get_plex_log`, and log download commands.
  late final LogService logs = LogService(this);

  /// Service for `get_geoip_lookup` and `get_whois_lookup`.
  late final NetworkService network = NetworkService(this);

  /// Service for `register_device`, `set_mobile_device_config`, and `delete_mobile_device`.
  late final DeviceService devices = DeviceService(this);

  /// Service for `docs`, `docs_md`, and `arnold`.
  late final ApiService api = ApiService(this);

  /// Synchronous URI builder for `pms_image_proxy` (no HTTP call).
  late final ImageService images = ImageService(connection);

  /// Executes a Tautulli API command and returns the parsed JSON response.
  ///
  /// Throws a [TautulliException] subclass on network or API errors.
  @override
  Future<Map<String, dynamic>> execute(
    String cmd, {
    Map<String, dynamic> params = const {},
    Duration? timeout,
  }) async {
    final uri = _buildUri(cmd, params);
    final response = await _get(uri, timeout: timeout);
    return _parseResponse(response);
  }

  /// Executes a Tautulli API command and returns the raw response bytes.
  ///
  /// Used for binary-download endpoints such as `download_log` and
  /// `download_config`. Throws a [TautulliException] subclass on errors.
  @override
  Future<Uint8List> executeDownload(
    String cmd, {
    Map<String, dynamic> params = const {},
    Duration? timeout,
    bool allowNonBinary = false,
  }) async {
    final uri = _buildUri(cmd, params);
    final response = await _get(
      uri,
      timeout: timeout ?? connection.downloadTimeout,
    );

    // A 401, or an HTML reverse-proxy auth page, is an auth failure. Do not
    // scan the file bytes for the phrase — a log file may legitimately contain
    // "authorization required".
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();
    if (response.statusCode == 401 ||
        (contentType.contains('text/html') &&
            response.body.toLowerCase().contains('authorization required'))) {
      throw const TautulliAuthException();
    }

    if (response.statusCode != 200) {
      throw TautulliServerException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode}',
      );
    }

    // A file download expects binary content; a JSON or HTML body at 200 is an
    // error page (e.g. "log file not found"), not a file. Endpoints that
    // legitimately return text (docs_md) opt out via [allowNonBinary].
    if (!allowNonBinary) {
      if (contentType.contains('application/json')) {
        _parseResponse(response); // throws the typed error for the envelope
        throw const TautulliBadResponseException(
          message: 'Expected a file but received a JSON response',
        );
      }
      if (contentType.contains('text/html')) {
        throw TautulliBadResponseException(message: response.body.trim());
      }
    }

    return response.bodyBytes;
  }

  /// Closes the underlying HTTP client and releases resources.
  ///
  /// Only closes the client if [TautulliClient] created it. When an
  /// `httpClient` was injected into the constructor, this is a no-op — that
  /// client belongs to the caller, who must close it.
  void close() {
    if (_ownsClient) _httpClient.close();
  }

  // ---------------------------------------------------------------------------

  Uri _buildUri(String cmd, Map<String, dynamic> params) {
    final queryParams = <String, String>{
      'cmd': cmd,
      'apikey': connection.apiKey,
      if (connection.useDeviceToken) 'app': 'true',
    };
    for (final entry in params.entries) {
      final value = entry.value;
      if (value == null) continue;
      // Tautulli documents boolean params as 0/1. Some handlers (edit_user,
      // edit_library) store the raw value verbatim, so 'true'/'false' strings
      // would corrupt config. List params (row_ids etc.) are comma-separated.
      queryParams[entry.key] = switch (value) {
        bool b => b ? '1' : '0',
        List list => list.join(','),
        _ => value.toString(),
      };
    }

    return buildTautulliUri(connection, queryParams);
  }

  Future<http.Response> _get(Uri uri, {Duration? timeout}) async {
    try {
      // No Content-Type header: these are bodyless GETs, so it is meaningless
      // and would turn every request into a non-simple CORS request on web.
      return await _httpClient
          .get(uri, headers: connection.headers)
          .timeout(timeout ?? connection.timeout);
    } on TautulliException {
      rethrow;
    } on TimeoutException {
      throw const TautulliTimeoutException();
    } on Exception catch (e) {
      // Platform mapper refines socket/TLS errors (native) or redacts (web).
      // Errors (e.g. TypeError, StateError) are left to propagate.
      throw mapNetworkException(e);
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    // Parse the body up front. A valid Tautulli response is a JSON object with
    // a "response" object; anything else may be a reverse-proxy auth page.
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    final envelope = decoded is Map<String, dynamic> ? decoded : null;
    final hasEnvelope = envelope?['response'] is Map<String, dynamic>;

    // Auth failure: a 401, or a non-Tautulli body that looks like a
    // reverse-proxy "Authorization Required" page. The substring is only
    // applied to bodies that are NOT a valid Tautulli envelope, so a log line
    // containing the phrase is not mistaken for an auth error.
    if (response.statusCode == 401 ||
        (!hasEnvelope &&
            response.body.toLowerCase().contains('authorization required'))) {
      final msg =
          (envelope?['response'] as Map<String, dynamic>?)?['message']
              as String?;
      if (msg == 'Invalid apikey') {
        throw const TautulliInvalidApiKeyException();
      }
      throw const TautulliAuthException();
    }

    // Not JSON at all — fail fast.
    if (decoded == null) {
      throw TautulliBadResponseException(
        message: 'Response is not valid JSON (HTTP ${response.statusCode})',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const TautulliBadResponseException(
        message: 'Expected JSON object at response root',
      );
    }
    final body = decoded;

    // Non-200 with valid JSON body
    if (response.statusCode != 200) {
      final message =
          (body['response'] as Map<String, dynamic>?)?['message'] as String?;

      final mapped = _mapErrorMessage(message);
      if (mapped != null) throw mapped;

      throw TautulliServerException(
        statusCode: response.statusCode,
        message: message ?? 'HTTP ${response.statusCode}',
      );
    }

    // Validate the Tautulli result field
    final apiResponse = body['response'];
    if (apiResponse is! Map<String, dynamic>) {
      throw const TautulliBadResponseException(
        message: 'Response missing "response" object',
      );
    }

    final result = apiResponse['result'] as String?;
    final message = apiResponse['message'] as String?;

    if (result != 'success') {
      final mapped = _mapErrorMessage(message);
      if (mapped != null) throw mapped;
      throw TautulliBadResponseException(message: message ?? 'result: $result');
    }

    return apiResponse;
  }

  static final _versionMismatch = RegExp(
    r'^Device registration failed: Tautulli version v\d+\.\d+\.\d+ does not meet the minimum requirement of v\d+\.\d+\.\d+\.',
  );

  /// Maps a Tautulli error message to a specific exception, or `null` when no
  /// known pattern matches. Applied to both non-200 responses and HTTP 200
  /// responses whose `result` is not `success`, so error classification does
  /// not depend on the status code.
  TautulliException? _mapErrorMessage(String? message) {
    if (message == null) return null;
    if (message == 'Invalid apikey') {
      return const TautulliInvalidApiKeyException();
    }
    if (_versionMismatch.hasMatch(message)) {
      return TautulliVersionException(message: message);
    }
    if (message.contains('Failed to terminate session')) {
      return TautulliTerminateStreamException(message: message);
    }
    return null;
  }
}
