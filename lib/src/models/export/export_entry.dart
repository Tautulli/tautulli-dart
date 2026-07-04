import '../../utils/cast.dart';

/// A single metadata export job entry returned by `get_exports_table`.
class ExportEntry {
  /// Unique identifier for the export job.
  final int? exportId;

  /// Unix epoch timestamp when the export was created.
  final int? timestamp;

  /// Library section ID the export was scoped to, if any.
  final int? sectionId;

  /// User ID the export was scoped to (for playlist exports), if any.
  final int? userId;

  /// Plex rating key of the exported item, if any.
  final int? ratingKey;

  /// Media type of the exported item (e.g. `'movie'`, `'show'`).
  final String? mediaType;

  /// Human-readable media type label (e.g. `'Movie'`).
  final String? mediaTypeTitle;

  /// Display title of the exported item.
  final String? title;

  /// Name of the exported file on disk.
  final String? filename;

  /// File format of the export (e.g. `'csv'`, `'json'`).
  final String? fileFormat;

  /// Level of metadata included in the export.
  final int? metadataLevel;

  /// Level of media info included in the export.
  final int? mediaInfoLevel;

  /// Level of poster/cover images included in the export.
  final int? thumbLevel;

  /// Level of background artwork included in the export.
  final int? artLevel;

  /// Level of logo images included in the export.
  final int? logoLevel;

  /// Level of square art included in the export.
  final int? squareArtLevel;

  /// Level of theme audio included in the export.
  final int? themeLevel;

  /// Comma-separated list of custom fields included in the export.
  final String? customFields;

  /// Whether each item was exported as an individual file.
  final bool? individualFiles;

  /// Size of the exported file in bytes.
  final int? fileSize;

  /// Whether the export job has finished.
  final bool? complete;

  /// Number of items that have been exported so far.
  final int? exportedItems;

  /// Total number of items included in the export.
  final int? totalItems;

  /// Whether the exported file still exists on disk.
  final bool? exists;

  const ExportEntry({
    this.exportId,
    this.timestamp,
    this.sectionId,
    this.userId,
    this.ratingKey,
    this.mediaType,
    this.mediaTypeTitle,
    this.title,
    this.filename,
    this.fileFormat,
    this.metadataLevel,
    this.mediaInfoLevel,
    this.thumbLevel,
    this.artLevel,
    this.logoLevel,
    this.squareArtLevel,
    this.themeLevel,
    this.customFields,
    this.individualFiles,
    this.fileSize,
    this.complete,
    this.exportedItems,
    this.totalItems,
    this.exists,
  });

  /// Parses an [ExportEntry] from a Tautulli API JSON map.
  factory ExportEntry.fromJson(Map<String, dynamic> json) => ExportEntry(
    exportId: Cast.castToInt(json['export_id']),
    timestamp: Cast.castToInt(json['timestamp']),
    sectionId: Cast.castToInt(json['section_id']),
    userId: Cast.castToInt(json['user_id']),
    ratingKey: Cast.castToInt(json['rating_key']),
    mediaType: Cast.castToString(json['media_type']),
    mediaTypeTitle: Cast.castToString(json['media_type_title']),
    title: Cast.castToString(json['title']),
    filename: Cast.castToString(json['filename']),
    fileFormat: Cast.castToString(json['file_format']),
    metadataLevel: Cast.castToInt(json['metadata_level']),
    mediaInfoLevel: Cast.castToInt(json['media_info_level']),
    thumbLevel: Cast.castToInt(json['thumb_level']),
    artLevel: Cast.castToInt(json['art_level']),
    logoLevel: Cast.castToInt(json['logo_level']),
    squareArtLevel: Cast.castToInt(json['squareArt_level']),
    themeLevel: Cast.castToInt(json['theme_level']),
    customFields: Cast.castToString(json['custom_fields']),
    individualFiles: Cast.castToBool(json['individual_files']),
    fileSize: Cast.castToInt(json['file_size']),
    complete: Cast.castToBool(json['complete']),
    exportedItems: Cast.castToInt(json['exported_items']),
    totalItems: Cast.castToInt(json['total_items']),
    exists: Cast.castToBool(json['exists']),
  );
}
