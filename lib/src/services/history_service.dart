import '../executor.dart';
import '../models/history/history_entry.dart';
import '../models/history/home_stat_group.dart';
import '../models/paged_result.dart';
import '../types/play_metric_type.dart';
import '../types/stat_id_type.dart';
import '../utils/cast.dart';

/// Commands: get_history, get_home_stats, delete_history, regroup_history
class HistoryService {
  final TautulliExecutor _client;
  HistoryService(TautulliExecutor client) : _client = client;

  /// Returns a paginated list of Tautulli watch history entries.
  ///
  /// All parameters are optional filters. Use [start]/[length] for pagination,
  /// [before]/[after] for date range filtering, and [search] for text search.
  Future<PagedResult<HistoryEntry>> getHistory({
    bool? grouping,
    bool? includeActivity,
    String? user,
    int? userId,
    int? ratingKey,
    int? parentRatingKey,
    int? grandparentRatingKey,
    DateTime? startDate,
    DateTime? before,
    DateTime? after,
    int? sectionId,
    String? mediaType,
    String? transcodeDecision,
    String? guid,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (grouping != null) params['grouping'] = grouping;
    if (includeActivity != null) params['include_activity'] = includeActivity;
    if (user != null) params['user'] = user;
    if (userId != null) params['user_id'] = userId;
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (parentRatingKey != null) params['parent_rating_key'] = parentRatingKey;
    if (grandparentRatingKey != null) {
      params['grandparent_rating_key'] = grandparentRatingKey;
    }
    if (startDate != null) params['start_date'] = _formatDate(startDate);
    if (before != null) params['before'] = _formatDate(before);
    if (after != null) params['after'] = _formatDate(after);
    if (sectionId != null) params['section_id'] = sectionId;
    if (mediaType != null) params['media_type'] = mediaType;
    if (transcodeDecision != null) {
      params['transcode_decision'] = transcodeDecision;
    }
    if (guid != null) params['guid'] = guid;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_history', params: params);
    final data = Cast.dataMap(response['data'], 'get_history');
    final entries = Cast.dataList(
      data['data'],
      'get_history',
    ).whereType<Map<String, dynamic>>().map(HistoryEntry.fromJson).toList();
    return PagedResult(
      data: entries,
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns home statistics groups (top movies, top users, recently watched, etc.).
  ///
  /// Filter with [statId] to retrieve a single stat group, or leave null for all.
  Future<List<HomeStatGroup>> getHomeStats({
    bool? grouping,
    int? timeRange,
    PlayMetricType? statsType,
    int? statsStart,
    int? statsCount,
    StatIdType? statId,
    int? sectionId,
    int? userId,
    DateTime? before,
    DateTime? after,
  }) async {
    final params = <String, dynamic>{};
    if (grouping != null) params['grouping'] = grouping;
    if (timeRange != null) params['time_range'] = timeRange;
    if (statsType != null) params['stats_type'] = statsType.value;
    if (statsStart != null) params['stats_start'] = statsStart;
    if (statsCount != null) params['stats_count'] = statsCount;
    if (statId != null) params['stat_id'] = statId.value;
    if (sectionId != null) params['section_id'] = sectionId;
    if (userId != null) params['user_id'] = userId;
    if (before != null) params['before'] = _formatDate(before);
    if (after != null) params['after'] = _formatDate(after);

    final response = await _client.execute('get_home_stats', params: params);
    final data = response['data'];
    // A single-stat query ([statId]) returns the bare stat-group object
    // rather than the list of groups.
    if (data is Map<String, dynamic>) return [HomeStatGroup.fromJson(data)];
    return Cast.dataList(
      data,
      'get_home_stats',
    ).whereType<Map<String, dynamic>>().map(HomeStatGroup.fromJson).toList();
  }

  /// Permanently deletes the history entries with the given [rowIds].
  ///
  /// [rowIds] are history row IDs (see [HistoryEntry.rowId]); pass at least one.
  Future<void> deleteHistory({required List<int> rowIds}) async {
    await _client.execute('delete_history', params: {'row_ids': rowIds});
  }

  /// Regroups watch history entries that may have been split incorrectly.
  Future<void> regroupHistory() async {
    await _client.execute('regroup_history');
  }

  static String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
