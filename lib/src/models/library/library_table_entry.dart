import '../../types/media_type.dart';
import '../../types/section_type.dart';
import '../../utils/cast.dart';

/// A library row returned by `get_libraries_table`.
///
/// Combines library metadata with stats about the most recently played item.
class LibraryTableEntry {
  /// Number of child items (episodes/tracks) in this library.
  final int? childCount;

  /// Content rating of the most recently played item (e.g. `'PG-13'`).
  final String? contentRating;

  /// Number of top-level items in this library (movies, shows, or artists).
  final int? count;

  /// Whether Tautulli sends notifications for activity in this library.
  final bool? doNotify;

  /// Whether Tautulli sends notifications when new items are added.
  final bool? doNotifyCreated;

  /// Total watch duration for the most recently played item.
  final Duration? duration;

  /// Plex GUID of the most recently played item.
  final String? guid;

  /// History row ID for the most recent play in this library.
  final int? historyRow;

  /// Whether this library is currently active in Plex.
  final bool? isActive;

  /// Whether Tautulli records watch history for this library.
  final bool? keepHistory;

  /// Content labels applied to the most recently played item.
  final List<String>? labels;

  /// Timestamp of the last time this library was accessed.
  final DateTime? lastAccessed;

  /// Title of the most recently played item.
  final String? lastPlayed;

  /// Custom background art URL path set in Tautulli.
  final String? libraryArt;

  /// Custom thumbnail URL path set in Tautulli.
  final String? libraryThumb;

  /// Whether the most recently played item is live TV.
  final bool? live;

  /// Episode/track index of the most recently played item.
  final int? mediaIndex;

  /// Media type of the most recently played item.
  final MediaType? mediaType;

  /// Original release date of the most recently played item.
  final DateTime? originallyAvailableAt;

  /// Number of parent items (seasons/albums) in this library.
  final int? parentCount;

  /// Season/album index of the most recently played item.
  final int? parentMediaIndex;

  /// Parent title (season name) of the most recently played item.
  final String? parentTitle;

  /// Total play count for this library.
  final int? plays;

  /// Plex rating key for the most recently played item.
  final int? ratingKey;

  /// Database row ID for this library record.
  final int? rowId;

  /// Plex section ID identifying this library.
  final int? sectionId;

  /// Display name of this library section.
  final String? sectionName;

  /// Library section type.
  final SectionType? sectionType;

  /// Plex server machine identifier this library belongs to.
  final String? serverId;

  /// Thumbnail URL path for the most recently played item.
  final String? thumb;

  /// Release year of the most recently played item.
  final int? year;

  const LibraryTableEntry({
    this.childCount,
    this.contentRating,
    this.count,
    this.doNotify,
    this.doNotifyCreated,
    this.duration,
    this.guid,
    this.historyRow,
    this.isActive,
    this.keepHistory,
    this.labels,
    this.lastAccessed,
    this.lastPlayed,
    this.libraryArt,
    this.libraryThumb,
    this.live,
    this.mediaIndex,
    this.mediaType,
    this.originallyAvailableAt,
    this.parentCount,
    this.parentMediaIndex,
    this.parentTitle,
    this.plays,
    this.ratingKey,
    this.rowId,
    this.sectionId,
    this.sectionName,
    this.sectionType,
    this.serverId,
    this.thumb,
    this.year,
  });

  /// Parses a [LibraryTableEntry] from a Tautulli API JSON map.
  factory LibraryTableEntry.fromJson(Map<String, dynamic> json) {
    return LibraryTableEntry(
      childCount: Cast.castToInt(json['child_count']),
      contentRating: Cast.castToString(json['content_rating']),
      count: Cast.castToInt(json['count']),
      doNotify: Cast.castToBool(json['do_notify']),
      doNotifyCreated: Cast.castToBool(json['do_notify_created']),
      duration: _durationFromSeconds(Cast.castToInt(json['duration'])),
      guid: Cast.castToString(json['guid']),
      historyRow: Cast.castToInt(json['history_row']),
      isActive: Cast.castToBool(json['is_active']),
      keepHistory: Cast.castToBool(json['keep_history']),
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList(),
      lastAccessed: _dateTimeFromEpochSeconds(
        Cast.castToInt(json['last_accessed']),
      ),
      lastPlayed: Cast.castToString(json['last_played']),
      libraryArt: Cast.castToString(json['library_art']),
      libraryThumb: Cast.castToString(json['library_thumb']),
      live: Cast.castToBool(json['live']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      originallyAvailableAt: _dateTimeFromString(
        Cast.castToString(json['originally_available_at']),
      ),
      parentCount: Cast.castToInt(json['parent_count']),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentTitle: Cast.castToString(json['parent_title']),
      plays: Cast.castToInt(json['plays']),
      ratingKey: Cast.castToInt(json['rating_key']),
      rowId: Cast.castToInt(json['row_id']),
      sectionId: Cast.castToInt(json['section_id']),
      sectionName: Cast.castToString(json['section_name']),
      sectionType: SectionType.fromString(
        Cast.castToString(json['section_type']),
      ),
      serverId: Cast.castToString(json['server_id']),
      thumb: Cast.castToString(json['thumb']),
      year: Cast.castToInt(json['year']),
    );
  }

  static DateTime? _dateTimeFromEpochSeconds(int? seconds) {
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static DateTime? _dateTimeFromString(String? date) {
    if (date == null) return null;
    return DateTime.tryParse(date);
  }

  static Duration? _durationFromSeconds(int? seconds) {
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }
}
