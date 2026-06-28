import '../executor.dart';
import '../models/activity/activity_data.dart';

/// Commands: get_activity, get_stream_data, terminate_session
class ActivityService {
  final TautulliExecutor _client;
  ActivityService(TautulliExecutor client) : _client = client;

  /// Returns current Plex activity, optionally filtered to a single session.
  ///
  /// Provide [sessionKey] or [sessionId] to retrieve a single session's data.
  Future<ActivityData> getActivity({int? sessionKey, String? sessionId}) async {
    final params = <String, dynamic>{};
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (sessionId != null) params['session_id'] = sessionId;

    final response = await _client.execute('get_activity', params: params);
    return ActivityData.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Returns raw stream data for a session as an untyped map.
  ///
  /// Identify the session with [sessionKey], [sessionId], or [userId].
  Future<Map<String, dynamic>> getStreamData({
    int? sessionKey,
    String? sessionId,
    int? userId,
  }) async {
    final params = <String, dynamic>{};
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (sessionId != null) params['session_id'] = sessionId;
    if (userId != null) params['user_id'] = userId;

    final response = await _client.execute('get_stream_data', params: params);
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Terminates an active Plex session.
  ///
  /// Identify the session with [sessionId] or [sessionKey]. An optional
  /// [message] is displayed to the user whose session is terminated.
  Future<void> terminateSession({
    String? sessionId,
    int? sessionKey,
    String? message,
  }) async {
    final params = <String, dynamic>{};
    if (sessionId != null) params['session_id'] = sessionId;
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (message != null) params['message'] = message;

    await _client.execute('terminate_session', params: params);
  }
}
