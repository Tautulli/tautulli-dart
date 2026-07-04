import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'connection.dart';
import 'exceptions.dart';
import 'executor.dart';
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

  /// Creates a [TautulliClient] with the given [connection].
  ///
  /// An optional [httpClient] can be supplied for testing or to configure
  /// SSL/TLS behaviour (e.g. to allow self-signed certificates).
  TautulliClient({required this.connection, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

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
  }) async {
    final uri = _buildUri(cmd, params);
    final response = await _get(uri);
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
  }) async {
    final uri = _buildUri(cmd, params);
    final response = await _get(uri);

    if (response.statusCode == 401 ||
        response.body.toLowerCase().contains('authorization required')) {
      throw const TautulliAuthException();
    }

    if (response.statusCode != 200) {
      throw TautulliServerException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode}',
      );
    }

    return response.bodyBytes;
  }

  /// Closes the underlying HTTP client and releases resources.
  ///
  /// Call this when the client is no longer needed to free sockets.
  void close() => _httpClient.close();

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

    final pathPrefix = connection.path ?? '';
    switch (connection.protocol.toLowerCase()) {
      case 'http':
        return Uri.http(connection.domain, '$pathPrefix/api/v2', queryParams);
      case 'https':
        return Uri.https(connection.domain, '$pathPrefix/api/v2', queryParams);
      default:
        throw TautulliProtocolException(
          message: 'Unsupported protocol: ${connection.protocol}',
        );
    }
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _httpClient
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              ...connection.headers,
            },
          )
          .timeout(connection.timeout);
    } on TautulliException {
      rethrow;
    } on SocketException catch (e) {
      throw TautulliConnectionException(message: e.message);
    } on TimeoutException {
      throw const TautulliTimeoutException();
    } on HandshakeException catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        throw TautulliCertVerificationException(message: e.toString());
      }
      throw TautulliConnectionException(message: e.message);
    } catch (e) {
      throw TautulliConnectionException(message: e.toString());
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    // Detect reverse-proxy basic-auth rejections before JSON parsing.
    // Still attempt JSON decode so an "Invalid apikey" 401 is identified correctly.
    if (response.statusCode == 401 ||
        response.body.toLowerCase().contains('authorization required')) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final msg =
              (decoded['response'] as Map<String, dynamic>?)?['message']
                  as String?;
          if (msg == 'Invalid apikey') {
            throw const TautulliInvalidApiKeyException();
          }
        }
      } catch (e) {
        if (e is TautulliException) rethrow;
      }
      throw const TautulliAuthException();
    }

    // Parse body — if not JSON, fail fast
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
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
