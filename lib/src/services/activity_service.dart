import '../executor.dart';
import '../models/activity/activity_data.dart';
import '../utils/cast.dart';

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
    final data = Cast.dataMap(response['data'], 'get_activity');

    // A single-session query returns the bare session object as `data`
    // (no stream counts / sessions wrapper) rather than the full snapshot.
    if ((sessionKey != null || sessionId != null) &&
        !data.containsKey('sessions')) {
      if (data.isEmpty) return const ActivityData();
      return ActivityData(sessions: [ActivitySession.fromJson(data)]);
    }

    return ActivityData.fromJson(data);
  }

  /// Returns raw stream data for a session as an untyped map.
  ///
  /// Identify the stream with [sessionKey] for a current stream, or [rowId] for
  /// a historical entry. Provide exactly one.
  Future<Map<String, dynamic>> getStreamData({
    int? sessionKey,
    int? rowId,
  }) async {
    final params = <String, dynamic>{};
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (rowId != null) params['row_id'] = rowId;

    final response = await _client.execute('get_stream_data', params: params);
    return Cast.dataMap(response['data'], 'get_stream_data');
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
