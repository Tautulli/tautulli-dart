import '../executor.dart';
import '../models/paged_result.dart';
import '../models/user/user_data.dart';
import '../models/user/user_name.dart';
import '../models/user/user_player_stat.dart';
import '../models/user/user_table_entry.dart';
import '../models/user/user_watch_time_stat.dart';
import '../utils/cast.dart';

/// Commands: get_user, get_user_names, get_users, get_users_table,
/// get_user_ips, get_user_logins, get_user_player_stats,
/// get_user_watch_time_stats, edit_user, delete_user, undelete_user,
/// delete_all_user_history, refresh_users_list
class UserService {
  final TautulliExecutor _client;
  UserService(TautulliExecutor client) : _client = client;

  /// Returns full profile data for the user identified by [userId].
  ///
  /// [includeLastSeen] defaults to `true` to include the last-seen timestamp.
  Future<UserData> getUser({required int userId, bool? includeLastSeen}) async {
    final params = <String, dynamic>{
      'user_id': userId,
      'include_last_seen': includeLastSeen ?? true,
    };
    final response = await _client.execute('get_user', params: params);
    return UserData.fromJson(Cast.dataMap(response['data'], 'get_user'));
  }

  /// Returns a lightweight list of all user IDs, usernames, and friendly names.
  Future<List<UserName>> getUserNames() async {
    final response = await _client.execute('get_user_names');
    return Cast.dataList(
      response['data'],
      'get_user_names',
    ).whereType<Map<String, dynamic>>().map(UserName.fromJson).toList();
  }

  /// Returns per-player-platform statistics for the user identified by [userId].
  Future<List<UserPlayerStat>> getUserPlayerStats({
    required int userId,
    bool? grouping,
  }) async {
    final params = <String, dynamic>{'user_id': userId};
    if (grouping != null) params['grouping'] = grouping;

    final response = await _client.execute(
      'get_user_player_stats',
      params: params,
    );
    return Cast.dataList(
      response['data'],
      'get_user_player_stats',
    ).whereType<Map<String, dynamic>>().map(UserPlayerStat.fromJson).toList();
  }

  /// Returns watch time statistics for the user identified by [userId] over time periods.
  Future<List<UserWatchTimeStat>> getUserWatchTimeStats({
    required int userId,
    bool? grouping,
    String? queryDays,
  }) async {
    final params = <String, dynamic>{'user_id': userId};
    if (grouping != null) params['grouping'] = grouping;
    if (queryDays != null) params['query_days'] = queryDays;

    final response = await _client.execute(
      'get_user_watch_time_stats',
      params: params,
    );
    return Cast.dataList(response['data'], 'get_user_watch_time_stats')
        .whereType<Map<String, dynamic>>()
        .map(UserWatchTimeStat.fromJson)
        .toList();
  }

  /// Returns profile data for all Tautulli users.
  Future<List<UserData>> getUsers({bool? grouping}) async {
    final params = <String, dynamic>{};
    if (grouping != null) params['grouping'] = grouping;
    final response = await _client.execute('get_users', params: params);
    return Cast.dataList(
      response['data'],
      'get_users',
    ).whereType<Map<String, dynamic>>().map(UserData.fromJson).toList();
  }

  /// Returns a paginated list of IP addresses used by the given user.
  Future<PagedResult<Map<String, dynamic>>> getUserIps({
    required int userId,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{'user_id': userId};
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_user_ips', params: params);
    final data = Cast.dataMap(response['data'], 'get_user_ips');
    return PagedResult(
      data: Cast.dataList(
        data['data'],
        'get_user_ips',
      ).whereType<Map<String, dynamic>>().toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns a paginated login history for users.
  Future<PagedResult<Map<String, dynamic>>> getUserLogins({
    int? userId,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (userId != null) params['user_id'] = userId;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_user_logins', params: params);
    final data = Cast.dataMap(response['data'], 'get_user_logins');
    return PagedResult(
      data: Cast.dataList(
        data['data'],
        'get_user_logins',
      ).whereType<Map<String, dynamic>>().toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Updates the Tautulli settings for the user identified by [userId].
  ///
  /// Omitted (null) settings are left unchanged — `edit_user` performs a
  /// partial update. Pass an empty [friendlyName] or [customThumb] to clear it
  /// (an empty friendly name reverts to the Plex username).
  ///
  /// **Warning — servers up to and including v2.17.2:** older `edit_user`
  /// handlers are a full overwrite that **resets every omitted field to its
  /// default** (`keep_history` → 0, `allow_guest` → 0, `friendly_name` → '').
  /// When targeting those servers, read the current values with [getUser]
  /// first and pass every setting back.
  Future<void> editUser({
    required int userId,
    String? friendlyName,
    String? customThumb,
    bool? keepHistory,
    bool? allowGuest,
  }) async {
    await _client.execute(
      'edit_user',
      params: {
        'user_id': userId,
        'friendly_name': ?friendlyName,
        'custom_thumb': ?customThumb,
        'keep_history': ?keepHistory,
        'allow_guest': ?allowGuest,
      },
    );
  }

  /// Marks the user identified by [userId] as deleted in Tautulli's database.
  ///
  /// Optionally limit the deletion to specific history [rowIds].
  Future<void> deleteUser({required int userId, List<int>? rowIds}) async {
    final params = <String, dynamic>{'user_id': userId};
    if (rowIds != null) params['row_ids'] = rowIds;
    await _client.execute('delete_user', params: params);
  }

  /// Restores a previously deleted user.
  Future<void> undeleteUser({
    required int userId,
    required String username,
  }) async {
    await _client.execute(
      'undelete_user',
      params: {'user_id': userId, 'username': username},
    );
  }

  /// Deletes all watch history entries for the given user.
  Future<void> deleteAllUserHistory({
    required int userId,
    required String username,
    String? rowIds,
  }) async {
    final params = <String, dynamic>{'user_id': userId, 'username': username};
    if (rowIds != null) params['row_ids'] = rowIds;
    await _client.execute('delete_all_user_history', params: params);
  }

  /// Forces Tautulli to refresh its user list from Plex.
  Future<void> refreshUsersList() async {
    await _client.execute('refresh_users_list');
  }

  /// Returns a paginated table of all users with their watch statistics.
  Future<PagedResult<UserTableEntry>> getUsersTable({
    bool? grouping,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (grouping != null) params['grouping'] = grouping;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_users_table', params: params);
    final data = Cast.dataMap(response['data'], 'get_users_table');
    final entries = Cast.dataList(
      data['data'],
      'get_users_table',
    ).whereType<Map<String, dynamic>>().map(UserTableEntry.fromJson).toList();
    return PagedResult(
      data: entries,
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }
}
