import 'dart:typed_data';

import '../executor.dart';
import '../models/export/export_entry.dart';
import '../models/paged_result.dart';
import '../utils/cast.dart';

/// Commands: export_metadata, get_exports_table, get_export_fields,
/// download_export, delete_export
class ExportService {
  final TautulliExecutor _client;
  ExportService(TautulliExecutor client) : _client = client;

  /// Returns a paginated list of metadata export jobs.
  ///
  /// Filter by [sectionId], [userId], or [ratingKey] to limit results to a
  /// specific library, user, or item. Use [start]/[length] for pagination.
  Future<PagedResult<ExportEntry>> getExportsTable({
    int? sectionId,
    int? userId,
    int? ratingKey,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (sectionId != null) params['section_id'] = sectionId;
    if (userId != null) params['user_id'] = userId;
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_exports_table', params: params);
    final data = Cast.dataMap(response['data'], 'get_exports_table');
    return PagedResult(
      data: Cast.dataList(
        data['data'],
        'get_exports_table',
      ).whereType<Map<String, dynamic>>().map(ExportEntry.fromJson).toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns the available export fields for the given [mediaType].
  ///
  /// [subMediaType] narrows collection/playlist fields (e.g. `'movie'`, `'video'`).
  Future<Map<String, dynamic>> getExportFields({
    required String mediaType,
    String? subMediaType,
  }) async {
    final params = <String, dynamic>{'media_type': mediaType};
    if (subMediaType != null) params['sub_media_type'] = subMediaType;
    final response = await _client.execute('get_export_fields', params: params);
    return Cast.dataMap(response['data'], 'get_export_fields');
  }

  /// Downloads a completed export file by its [exportId].
  Future<Uint8List> downloadExport({required int exportId}) async {
    return _client.executeDownload(
      'download_export',
      params: {'export_id': exportId},
    );
  }

  /// Queues a metadata export job.
  ///
  /// Provide exactly one target: [sectionId] (a library), [userId] (a user's
  /// playlists), or [ratingKey] (a single item). [fileFormat] is `csv`
  /// (default), `json`, `xml`, or `m3u`. The `*Level` parameters control how
  /// much metadata / media info / imagery is exported (0 disables); pass
  /// [exportType] `'collection'` or `'playlist'` for library/user exports.
  Future<void> exportMetadata({
    int? sectionId,
    int? userId,
    int? ratingKey,
    String? fileFormat,
    int? metadataLevel,
    int? mediaInfoLevel,
    int? thumbLevel,
    int? artLevel,
    int? logoLevel,
    int? squareArtLevel,
    int? themeLevel,
    String? customFields,
    String? exportType,
    bool? individualFiles,
  }) async {
    final params = <String, dynamic>{};
    if (sectionId != null) params['section_id'] = sectionId;
    if (userId != null) params['user_id'] = userId;
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (fileFormat != null) params['file_format'] = fileFormat;
    if (metadataLevel != null) params['metadata_level'] = metadataLevel;
    if (mediaInfoLevel != null) params['media_info_level'] = mediaInfoLevel;
    if (thumbLevel != null) params['thumb_level'] = thumbLevel;
    if (artLevel != null) params['art_level'] = artLevel;
    if (logoLevel != null) params['logo_level'] = logoLevel;
    if (squareArtLevel != null) params['squareArt_level'] = squareArtLevel;
    if (themeLevel != null) params['theme_level'] = themeLevel;
    if (customFields != null) params['custom_fields'] = customFields;
    if (exportType != null) params['export_type'] = exportType;
    if (individualFiles != null) params['individual_files'] = individualFiles;
    await _client.execute('export_metadata', params: params);
  }

  /// Deletes the export job identified by [exportId].
  ///
  /// Set [deleteAll] to remove all export files instead.
  Future<void> deleteExport({required int exportId, bool? deleteAll}) async {
    final params = <String, dynamic>{'export_id': exportId};
    if (deleteAll != null) params['delete_all'] = deleteAll;
    await _client.execute('delete_export', params: params);
  }
}
