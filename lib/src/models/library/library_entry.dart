import '../../utils/cast.dart';

/// Summary information for a single Plex library section tracked by Tautulli.
class LibraryEntry {
  /// Background art URL path for this library.
  final String? art;

  /// Number of child items in this library (e.g. episodes for a TV library).
  final int? childCount;

  /// Number of top-level items in this library (movies, shows, or artists).
  final int? count;

  /// Whether this library section has been deleted from Plex.
  final bool? deletedSection;

  /// Whether this library is currently active in Plex.
  final bool? isActive;

  /// Whether Tautulli records watch history for this library.
  final bool? keepHistory;

  /// Timestamp of the last time this library was accessed.
  final DateTime? lastAccessed;

  /// Custom background art URL path set in Tautulli.
  final String? libraryArt;

  /// Custom thumbnail URL path set in Tautulli.
  final String? libraryThumb;

  /// Number of parent items (seasons for TV, albums for music).
  final int? parentCount;

  /// Database row ID for this library record.
  final int? rowId;

  /// Plex section ID identifying this library.
  final int? sectionId;

  /// Display name of this library section.
  final String? sectionName;

  /// Library type string (e.g. `'movie'`, `'show'`, `'artist'`).
  final String? sectionType;

  /// Plex server machine identifier this library belongs to.
  final String? serverId;

  /// Thumbnail URL path for the library's poster image.
  final String? thumb;

  const LibraryEntry({
    this.art,
    this.childCount,
    this.count,
    this.deletedSection,
    this.isActive,
    this.keepHistory,
    this.lastAccessed,
    this.libraryArt,
    this.libraryThumb,
    this.parentCount,
    this.rowId,
    this.sectionId,
    this.sectionName,
    this.sectionType,
    this.serverId,
    this.thumb,
  });

  /// Parses a [LibraryEntry] from a Tautulli API JSON map.
  factory LibraryEntry.fromJson(Map<String, dynamic> json) => LibraryEntry(
    art: Cast.castToString(json['art']),
    childCount: Cast.castToInt(json['child_count']),
    count: Cast.castToInt(json['count']),
    deletedSection: Cast.castToBool(json['deleted_section']),
    isActive: Cast.castToBool(json['is_active']),
    keepHistory: Cast.castToBool(json['keep_history']),
    lastAccessed: Cast.dateTimeFromEpochSeconds(json['last_accessed']),
    libraryArt: Cast.castToString(json['library_art']),
    libraryThumb: Cast.castToString(json['library_thumb']),
    parentCount: Cast.castToInt(json['parent_count']),
    rowId: Cast.castToInt(json['row_id']),
    sectionId: Cast.castToInt(json['section_id']),
    sectionName: Cast.castToString(json['section_name']),
    sectionType: Cast.castToString(json['section_type']),
    serverId: Cast.castToString(json['server_id']),
    thumb: Cast.castToString(json['thumb']),
  );
}
