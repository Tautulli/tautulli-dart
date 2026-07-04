import '../executor.dart';
import '../models/media/media_item.dart';

/// Commands: get_metadata, get_children_metadata, get_new_rating_keys,
/// get_old_rating_keys, update_metadata_details, search,
/// get_item_user_stats, get_item_watch_time_stats, delete_lookup_info
class MediaService {
  final TautulliExecutor _client;
  MediaService(TautulliExecutor client) : _client = client;

  /// Returns metadata for a single Plex item identified by [ratingKey].
  ///
  /// Alternatively pass [syncId] to look up a synced item.
  Future<MediaItem> getMetadata({required int ratingKey, int? syncId}) async {
    final params = <String, dynamic>{'rating_key': ratingKey};
    if (syncId != null) params['sync_id'] = syncId;
    final response = await _client.execute('get_metadata', params: params);
    return MediaItem.fromJson(response['data'] as Map<String, dynamic>? ?? {});
  }

  /// Returns the children of a Plex item (e.g. episodes of a season).
  ///
  /// [mediaType] must match the type of the children (e.g. `'episode'`).
  Future<List<MediaItem>> getChildrenMetadata({
    required int ratingKey,
    required String mediaType,
  }) async {
    final response = await _client.execute(
      'get_children_metadata',
      params: {'rating_key': ratingKey, 'media_type': mediaType},
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final list = data['children_list'] as List? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MediaItem.fromJson)
        .toList();
  }

  /// Returns the new Plex rating key hierarchy for an item, used after library refreshes.
  Future<Map<String, dynamic>> getNewRatingKeys({
    required int ratingKey,
    required String mediaType,
  }) async {
    final response = await _client.execute(
      'get_new_rating_keys',
      params: {'rating_key': ratingKey, 'media_type': mediaType},
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the old Plex rating key hierarchy for an item, used for history migration.
  Future<Map<String, dynamic>> getOldRatingKeys({
    required int ratingKey,
    required String mediaType,
  }) async {
    final response = await _client.execute(
      'get_old_rating_keys',
      params: {'rating_key': ratingKey, 'media_type': mediaType},
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Searches Plex for items matching [query], with an optional result [limit].
  Future<Map<String, dynamic>> search({
    required String query,
    int? limit,
  }) async {
    final params = <String, dynamic>{'query': query};
    if (limit != null) params['limit'] = limit;
    final response = await _client.execute('search', params: params);
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns per-user watch statistics for the item identified by [ratingKey].
  Future<List<Map<String, dynamic>>> getItemUserStats({
    required int ratingKey,
    bool? grouping,
  }) async {
    final params = <String, dynamic>{'rating_key': ratingKey};
    if (grouping != null) params['grouping'] = grouping;
    final response = await _client.execute(
      'get_item_user_stats',
      params: params,
    );
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Returns watch time statistics for the item identified by [ratingKey] over time periods.
  Future<List<Map<String, dynamic>>> getItemWatchTimeStats({
    required int ratingKey,
    bool? grouping,
    String? queryDays,
  }) async {
    final params = <String, dynamic>{'rating_key': ratingKey};
    if (grouping != null) params['grouping'] = grouping;
    if (queryDays != null) params['query_days'] = queryDays;
    final response = await _client.execute(
      'get_item_watch_time_stats',
      params: params,
    );
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Updates Tautulli's stored metadata by replacing [oldRatingKey] with [newRatingKey].
  ///
  /// Used after Plex library operations that change rating keys.
  Future<void> updateMetadataDetails({
    required int oldRatingKey,
    required int newRatingKey,
    required String mediaType,
  }) async {
    await _client.execute(
      'update_metadata_details',
      params: {
        'old_rating_key': oldRatingKey,
        'new_rating_key': newRatingKey,
        'media_type': mediaType,
      },
    );
  }

  /// Deletes the external metadata lookup cache for [ratingKey] from the given [service].
  ///
  /// Set [deleteAll] to clear the lookup cache for all items instead.
  Future<void> deleteLookupInfo({
    required int ratingKey,
    required String service,
    bool? deleteAll,
  }) async {
    final params = <String, dynamic>{
      'rating_key': ratingKey,
      'service': service,
    };
    if (deleteAll != null) params['delete_all'] = deleteAll;
    await _client.execute('delete_lookup_info', params: params);
  }
}
