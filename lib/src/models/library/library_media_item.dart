import '../../types/media_type.dart';
import '../../types/section_type.dart';
import '../../utils/cast.dart';

/// A single media item returned by `get_library_media_info`.
class LibraryMediaItem {
  /// Date and time the item was added to the Plex library.
  final DateTime? addedAt;

  /// Audio track bitrate in kbps.
  final int? audioBitrate;

  /// Number of audio channels.
  final int? audioChannels;

  /// Audio codec name (e.g. `'aac'`, `'dca'`).
  final String? audioCodec;

  /// Combined audio+video bitrate in kbps.
  final int? bitrate;

  /// Container format (e.g. `'mkv'`, `'mp4'`).
  final String? container;

  /// File size in bytes.
  final int? fileSize;

  /// Rating key of the grandparent item (series for episodes).
  final int? grandparentRatingKey;

  /// Date and time this item was last played.
  final DateTime? lastPlayed;

  /// Episode number or track index.
  final int? mediaIndex;

  /// Media type of this item.
  final MediaType? mediaType;

  /// Season or album index.
  final int? parentMediaIndex;

  /// Rating key of the parent item (season for episodes, album for tracks).
  final int? parentRatingKey;

  /// Number of times this item has been played.
  final int? playCount;

  /// Library section ID this item belongs to.
  final int? sectionId;

  /// Library section type.
  final SectionType? sectionType;

  /// Plex rating key identifying this item.
  final int? ratingKey;

  /// Sort title used for alphabetical ordering.
  final String? sortTitle;

  /// Thumbnail URL path.
  final String? thumb;

  /// Display title for this item.
  final String? title;

  /// Video codec name (e.g. `'h264'`, `'hevc'`).
  final String? videoCodec;

  /// Video frame rate string (e.g. `'24p'`, `'NTSC'`).
  final String? videoFramerate;

  /// Video resolution string (e.g. `'1080'`, `'4k'`).
  final String? videoResolution;

  /// Release year of this item.
  final int? year;

  const LibraryMediaItem({
    this.addedAt,
    this.audioBitrate,
    this.audioChannels,
    this.audioCodec,
    this.bitrate,
    this.container,
    this.fileSize,
    this.grandparentRatingKey,
    this.lastPlayed,
    this.mediaIndex,
    this.mediaType,
    this.parentMediaIndex,
    this.parentRatingKey,
    this.playCount,
    this.sectionId,
    this.sectionType,
    this.ratingKey,
    this.sortTitle,
    this.thumb,
    this.title,
    this.videoCodec,
    this.videoFramerate,
    this.videoResolution,
    this.year,
  });

  /// Parses a [LibraryMediaItem] from a Tautulli API JSON map.
  factory LibraryMediaItem.fromJson(Map<String, dynamic> json) {
    return LibraryMediaItem(
      addedAt: _dateTimeFromStringEpochSeconds(json['added_at']),
      audioBitrate: Cast.castToInt(json['audio_bitrate']),
      audioChannels: Cast.castToInt(json['audio_channels']),
      audioCodec: Cast.castToString(json['audio_codec']),
      bitrate: Cast.castToInt(json['bitrate']),
      container: Cast.castToString(json['container']),
      fileSize: Cast.castToInt(json['file_size']),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      lastPlayed: _dateTimeFromEpochSeconds(Cast.castToInt(json['last_played'])),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      playCount: Cast.castToInt(json['play_count']),
      sectionId: Cast.castToInt(json['section_id']),
      sectionType: SectionType.fromString(Cast.castToString(json['section_type'])),
      ratingKey: Cast.castToInt(json['rating_key']),
      sortTitle: Cast.castToString(json['sort_title']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      videoCodec: Cast.castToString(json['video_codec']),
      videoFramerate: Cast.castToString(json['video_framerate']),
      videoResolution: Cast.castToString(json['video_resolution']),
      year: Cast.castToInt(json['year']),
    );
  }

  static DateTime? _dateTimeFromStringEpochSeconds(dynamic value) {
    final seconds = Cast.castToInt(value);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static DateTime? _dateTimeFromEpochSeconds(int? seconds) {
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
