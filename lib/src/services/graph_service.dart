import '../executor.dart';
import '../models/graph/graph_data.dart';
import '../types/play_metric_type.dart';

/// Commands: get_concurrent_streams_by_stream_type, get_plays_by_date,
/// get_plays_by_dayofweek, get_plays_by_hourofday, get_plays_by_source_resolution,
/// get_plays_by_stream_resolution, get_plays_by_stream_type,
/// get_plays_by_top_10_platforms, get_plays_by_top_10_users,
/// get_plays_per_month, get_stream_type_by_top_10_platforms,
/// get_stream_type_by_top_10_users
class GraphService {
  final TautulliExecutor _client;
  GraphService(TautulliExecutor client) : _client = client;

  /// Returns concurrent stream counts broken down by stream type over [timeRange] days.
  Future<GraphData> getConcurrentStreamsByStreamType({
    required int timeRange,
    int? userId,
  }) async {
    final params = <String, dynamic>{'time_range': timeRange};
    if (userId != null) params['user_id'] = userId;
    return _graphData('get_concurrent_streams_by_stream_type', params);
  }

  /// Returns play counts or durations grouped by calendar date over [timeRange] days.
  Future<GraphData> getPlaysByDate({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_date',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by day of the week over [timeRange] days.
  Future<GraphData> getPlaysByDayOfWeek({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_dayofweek',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by hour of the day over [timeRange] days.
  Future<GraphData> getPlaysByHourOfDay({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_hourofday',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by source video resolution over [timeRange] days.
  Future<GraphData> getPlaysBySourceResolution({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_source_resolution',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by stream video resolution over [timeRange] days.
  Future<GraphData> getPlaysByStreamResolution({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_stream_resolution',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by stream type (direct play, transcode, etc.) over [timeRange] days.
  Future<GraphData> getPlaysByStreamType({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_stream_type',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations for the top 10 client platforms over [timeRange] days.
  Future<GraphData> getPlaysByTop10Platforms({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_top_10_platforms',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations for the top 10 users over [timeRange] days.
  Future<GraphData> getPlaysByTop10Users({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_by_top_10_users',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns play counts or durations grouped by month over [timeRange] months.
  Future<GraphData> getPlaysByMonth({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_plays_per_month',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns stream type breakdown for the top 10 platforms over [timeRange] days.
  Future<GraphData> getStreamTypeByTop10Platforms({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_stream_type_by_top_10_platforms',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  /// Returns stream type breakdown for the top 10 users over [timeRange] days.
  Future<GraphData> getStreamTypeByTop10Users({
    required PlayMetricType yAxis,
    required int timeRange,
    int? userId,
    bool? grouping,
  }) => _graphMethodWithYAxis(
    'get_stream_type_by_top_10_users',
    yAxis,
    timeRange,
    userId,
    grouping,
  );

  Future<GraphData> _graphMethodWithYAxis(
    String cmd,
    PlayMetricType yAxis,
    int timeRange,
    int? userId,
    bool? grouping,
  ) {
    final params = <String, dynamic>{
      'y_axis': yAxis.value,
      'time_range': timeRange,
    };
    if (userId != null) params['user_id'] = userId;
    if (grouping != null) params['grouping'] = grouping;
    return _graphData(cmd, params);
  }

  Future<GraphData> _graphData(String cmd, Map<String, dynamic> params) async {
    final response = await _client.execute(cmd, params: params);
    return GraphData.fromJson(response['data'] as Map<String, dynamic>? ?? {});
  }
}
