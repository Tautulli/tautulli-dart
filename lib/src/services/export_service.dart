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
  /// Filter by [sectionId] or [ratingKey] to limit results to a specific
  /// library or item. Use [start]/[length] for pagination.
  Future<PagedResult<ExportEntry>> getExportsTable({
    int? sectionId,
    int? ratingKey,
    String? orderColumn,
    String? orderDir,
    int? start,
    int? length,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (sectionId != null) params['section_id'] = sectionId;
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (search != null) params['search'] = search;

    final response = await _client.execute('get_exports_table', params: params);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return PagedResult(
      data: (data['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExportEntry.fromJson)
          .toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Returns the available export fields for the given [mediaType].
  Future<Map<String, dynamic>> getExportFields({
    required String mediaType,
  }) async {
    final response = await _client.execute(
      'get_export_fields',
      params: {'media_type': mediaType},
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Downloads a completed export file by its [exportId].
  Future<Uint8List> downloadExport({required int exportId}) async {
    return _client.executeDownload(
      'download_export',
      params: {'export_id': exportId},
    );
  }

  /// Queues a metadata export job for the item identified by [ratingKey].
  Future<void> exportMetadata({
    required int ratingKey,
    required String mediaType,
    int? directoryRatingKey,
    String? fileFormat,
    bool? removeSurplus,
    bool? includeImages,
  }) async {
    final params = <String, dynamic>{
      'rating_key': ratingKey,
      'media_type': mediaType,
    };
    if (directoryRatingKey != null) {
      params['directory_rating_key'] = directoryRatingKey;
    }
    if (fileFormat != null) params['file_format'] = fileFormat;
    if (removeSurplus != null) params['remove_surplus'] = removeSurplus;
    if (includeImages != null) params['include_images'] = includeImages;
    await _client.execute('export_metadata', params: params);
  }

  /// Deletes the export job identified by [exportId].
  Future<void> deleteExport({required int exportId}) async {
    await _client.execute('delete_export', params: {'export_id': exportId});
  }
}
