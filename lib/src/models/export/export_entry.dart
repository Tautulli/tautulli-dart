import '../../utils/cast.dart';

/// A single metadata export job entry returned by `get_exports_table`.
class ExportEntry {
  /// Unique identifier for the export job.
  final int? exportId;

  /// Unix epoch timestamp when the export was created.
  final int? timestamp;

  /// Display title of the exported item.
  final String? title;

  /// Name of the exported file on disk.
  final String? fileName;

  /// Media type of the exported item (e.g. `'movie'`, `'show'`).
  final String? mediaType;

  /// File format of the export (e.g. `'csv'`, `'json'`).
  final String? fileFormat;

  /// Number of records included in the export.
  final int? totalItems;

  /// Whether the export job has finished.
  final bool? complete;

  const ExportEntry({
    this.exportId,
    this.timestamp,
    this.title,
    this.fileName,
    this.mediaType,
    this.fileFormat,
    this.totalItems,
    this.complete,
  });

  /// Parses an [ExportEntry] from a Tautulli API JSON map.
  factory ExportEntry.fromJson(Map<String, dynamic> json) => ExportEntry(
    exportId: Cast.castToInt(json['export_id']),
    timestamp: Cast.castToInt(json['timestamp']),
    title: Cast.castToString(json['title']),
    fileName: Cast.castToString(json['file_name']),
    mediaType: Cast.castToString(json['media_type']),
    fileFormat: Cast.castToString(json['file_format']),
    totalItems: Cast.castToInt(json['total_items']),
    complete: Cast.castToBool(json['complete']),
  );
}
