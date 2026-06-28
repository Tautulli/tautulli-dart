import '../executor.dart';
import '../models/library/library_entry.dart';
import '../models/library/library_media_item.dart';
import '../models/library/library_name.dart';
import '../models/library/library_table_entry.dart';
import '../models/library/library_user_stat.dart';
import '../models/library/library_watch_time_stat.dart';
import '../models/library/recently_added_item.dart';
import '../models/paged_result.dart';
import '../types/media_type.dart';
import '../types/section_type.dart';
import '../utils/cast.dart';

/// Commands: get_libraries, get_library, get_library_names,
/// get_library_media_info, get_libraries_table, get_collections_table,
/// get_library_user_stats, get_library_watch_time_stats,
/// get_recently_added, delete_recently_added, refresh_libraries_list,
/// edit_library, delete_library, delete_all_library_history,
/// undelete_library, get_playlists_table, delete_media_info_cache
class LibraryService {
  final TautulliExecutor _client;
  LibraryService(TautulliExecutor client) : _client = client;

  /// Returns a paginated table of all Plex libraries tracked by Tautulli.
  Future<PagedResult<LibraryTableEntry>> getLibrariesTable({
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

    final response = await _client.execute('get_libraries_table', params: params);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final entries = (data['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryTableEntry.fromJson)
        .toList();
    return PagedResult(
      data: entries,
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns a paginated list of media items in a library section.
  ///
  /// [sectionId] is required. Optionally narrow to a sub-item with [ratingKey].
  /// Pass `refresh: true` to force Tautulli to refresh file metadata from disk.
  Future<PagedResult<LibraryMediaItem>> getLibraryMediaInfo({
    required int sectionId,
    int? ratingKey,
    SectionType? sectionType,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
    bool? refresh,
  }) async {
    final params = <String, dynamic>{'section_id': sectionId};
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (sectionType != null) params['section_type'] = sectionType.value;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;
    if (refresh != null) params['refresh'] = refresh;

    final response = await _client.execute('get_library_media_info', params: params);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final items = (data['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryMediaItem.fromJson)
        .toList();
    return PagedResult(
      data: items,
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns per-user watch statistics for a library section.
  Future<List<LibraryUserStat>> getLibraryUserStats({
    required int sectionId,
    bool? grouping,
  }) async {
    final params = <String, dynamic>{'section_id': sectionId};
    if (grouping != null) params['grouping'] = grouping;

    final response = await _client.execute('get_library_user_stats', params: params);
    final data = response['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(LibraryUserStat.fromJson).toList();
  }

  /// Returns watch time statistics for a library section over configurable time periods.
  Future<List<LibraryWatchTimeStat>> getLibraryWatchTimeStats({
    required int sectionId,
    bool? grouping,
    String? queryDays,
  }) async {
    final params = <String, dynamic>{'section_id': sectionId};
    if (grouping != null) params['grouping'] = grouping;
    if (queryDays != null) params['query_days'] = queryDays;

    final response = await _client.execute('get_library_watch_time_stats', params: params);
    final data = response['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(LibraryWatchTimeStat.fromJson).toList();
  }

  /// Returns the [count] most recently added items, optionally filtered by section or type.
  Future<List<RecentlyAddedItem>> getRecentlyAdded({
    required int count,
    int? start,
    MediaType? mediaType,
    int? sectionId,
  }) async {
    final params = <String, dynamic>{'count': count};
    if (start != null) params['start'] = start;
    if (mediaType != null) params['media_type'] = mediaType.value;
    if (sectionId != null) params['section_id'] = sectionId;

    final response = await _client.execute('get_recently_added', params: params);
    final data = response['data'];
    if (data is! Map<String, dynamic>) return [];
    final list = data['recently_added'] as List? ?? [];
    return list.whereType<Map<String, dynamic>>().map(RecentlyAddedItem.fromJson).toList();
  }

  /// Returns summary information for all Plex library sections.
  Future<List<LibraryEntry>> getLibraries() async {
    final response = await _client.execute('get_libraries');
    return (response['data'] as List? ?? []).whereType<Map<String, dynamic>>().map(LibraryEntry.fromJson).toList();
  }

  /// Returns summary information for a single library section by [sectionId].
  ///
  /// Pass `includeLastAccessed: true` to include the last-accessed timestamp.
  Future<LibraryEntry> getLibrary({required int sectionId, bool? includeLastAccessed}) async {
    final params = <String, dynamic>{'section_id': sectionId};
    if (includeLastAccessed != null) params['include_last_accessed'] = includeLastAccessed;
    final response = await _client.execute('get_library', params: params);
    return LibraryEntry.fromJson(response['data'] as Map<String, dynamic>? ?? {});
  }

  /// Returns a lightweight list of library section IDs, names, and types.
  Future<List<LibraryName>> getLibraryNames() async {
    final response = await _client.execute('get_library_names');
    return (response['data'] as List? ?? []).whereType<Map<String, dynamic>>().map(LibraryName.fromJson).toList();
  }

  /// Returns a paginated table of Plex collections.
  Future<PagedResult<Map<String, dynamic>>> getCollectionsTable({
    int? sectionId,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (sectionId != null) params['section_id'] = sectionId;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_collections_table', params: params);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return PagedResult(
      data: (data['data'] as List? ?? []).whereType<Map<String, dynamic>>().toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns a paginated table of Plex playlists.
  Future<PagedResult<Map<String, dynamic>>> getPlaylistsTable({
    int? sectionId,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (sectionId != null) params['section_id'] = sectionId;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_playlists_table', params: params);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return PagedResult(
      data: (data['data'] as List? ?? []).whereType<Map<String, dynamic>>().toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Deletes Tautulli's recently-added cache.
  Future<void> deleteRecentlyAdded() async {
    await _client.execute('delete_recently_added');
  }

  /// Forces Tautulli to refresh its library list from Plex.
  Future<void> refreshLibrariesList() async {
    await _client.execute('refresh_libraries_list');
  }

  /// Updates Tautulli settings for the library identified by [sectionId].
  Future<void> editLibrary({
    required int sectionId,
    String? customThumb,
    String? customArt,
    int? keepHistory,
  }) async {
    final params = <String, dynamic>{'section_id': sectionId};
    if (customThumb != null) params['custom_thumb'] = customThumb;
    if (customArt != null) params['custom_art'] = customArt;
    if (keepHistory != null) params['keep_history'] = keepHistory;
    await _client.execute('edit_library', params: params);
  }

  /// Marks a library section as deleted in Tautulli's database.
  Future<void> deleteLibrary({required int sectionId, required String sectionName}) async {
    await _client.execute('delete_library', params: {'section_id': sectionId, 'section_name': sectionName});
  }

  /// Deletes all watch history for the library identified by [sectionId].
  Future<void> deleteAllLibraryHistory({
    required int sectionId,
    required String sectionName,
    String? rowIds,
  }) async {
    final params = <String, dynamic>{'section_id': sectionId, 'section_name': sectionName};
    if (rowIds != null) params['row_ids'] = rowIds;
    await _client.execute('delete_all_library_history', params: params);
  }

  /// Restores a previously deleted library section.
  Future<void> undeleteLibrary({required int sectionId, required String sectionName}) async {
    await _client.execute('undelete_library', params: {'section_id': sectionId, 'section_name': sectionName});
  }

  /// Clears Tautulli's cached media info for the given library section.
  Future<void> deleteMediaInfoCache({required int sectionId}) async {
    await _client.execute('delete_media_info_cache', params: {'section_id': sectionId});
  }
}
