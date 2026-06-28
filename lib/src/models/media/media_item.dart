import '../../types/media_type.dart';
import '../../utils/cast.dart';
import 'media_info.dart';

/// Metadata for a single Plex item returned by `get_metadata` or
/// `get_children_metadata`.
class MediaItem {
  /// Cast members for this item.
  final List<String>? actors;

  /// Date and time this item was added to the Plex library.
  final DateTime? addedAt;

  /// Audience rating score (e.g. from Rotten Tomatoes).
  final double? audienceRating;

  /// Plex collection names this item belongs to.
  final List<String>? collections;

  /// Content rating (e.g. `'PG-13'`, `'TV-MA'`).
  final String? contentRating;

  /// Directors credited for this item.
  final List<String>? directors;

  /// Total duration of this item.
  final Duration? duration;

  /// Full hierarchical title (e.g. `'Show - S01E01 - Episode'`).
  final String? fullTitle;

  /// Genres associated with this item.
  final List<String>? genres;

  /// Rating key of the grandparent item (series for episodes).
  final int? grandparentRatingKey;

  /// Thumbnail URL path for the grandparent item.
  final String? grandparentThumb;

  /// Title of the grandparent item (series name for episodes).
  final String? grandparentTitle;

  /// Plex library labels applied to this item.
  final List<String>? labels;

  /// Timestamp when this item was last viewed.
  final DateTime? lastViewedAt;

  /// Name of the Plex library section this item belongs to.
  final String? libraryName;

  /// Whether this is a live TV item.
  final bool? live;

  /// Episode or track index within its parent.
  final int? mediaIndex;

  /// Technical encoding details for this item (first version only).
  final MediaInfo? mediaInfo;

  /// Media type of this item.
  final MediaType? mediaType;

  /// Original title before localization (if different from [title]).
  final String? originalTitle;

  /// Original air/release date of this item.
  final DateTime? originallyAvailableAt;

  /// Season or album index within its grandparent.
  final int? parentMediaIndex;

  /// Rating key of the parent item (season for episodes).
  final int? parentRatingKey;

  /// Thumbnail URL path for the parent item.
  final String? parentThumb;

  /// Title of the parent item (season title for episodes).
  final String? parentTitle;

  /// Release year of the parent item.
  final int? parentYear;

  /// Critic rating score.
  final double? rating;

  /// Plex rating key identifying this item.
  final int? ratingKey;

  /// Library section ID this item belongs to.
  final int? sectionId;

  /// Sort title used for alphabetical ordering.
  final String? sortTitle;

  /// Production studio name.
  final String? studio;

  /// Plot summary or description.
  final String? summary;

  /// Marketing tagline for this item.
  final String? tagline;

  /// Thumbnail URL path (poster for movies/shows, cover for albums).
  final String? thumb;

  /// Display title for this item.
  final String? title;

  /// Timestamp when this item's metadata was last updated in Plex.
  final DateTime? updatedAt;

  /// User's personal rating score.
  final double? userRating;

  /// Writers credited for this item.
  final List<String>? writers;

  /// Release year of this item.
  final int? year;

  const MediaItem({
    this.actors,
    this.addedAt,
    this.audienceRating,
    this.collections,
    this.contentRating,
    this.directors,
    this.duration,
    this.fullTitle,
    this.genres,
    this.grandparentRatingKey,
    this.grandparentThumb,
    this.grandparentTitle,
    this.labels,
    this.lastViewedAt,
    this.libraryName,
    this.live,
    this.mediaIndex,
    this.mediaInfo,
    this.mediaType,
    this.originalTitle,
    this.originallyAvailableAt,
    this.parentMediaIndex,
    this.parentRatingKey,
    this.parentThumb,
    this.parentTitle,
    this.parentYear,
    this.rating,
    this.ratingKey,
    this.sectionId,
    this.sortTitle,
    this.studio,
    this.summary,
    this.tagline,
    this.thumb,
    this.title,
    this.updatedAt,
    this.userRating,
    this.writers,
    this.year,
  });

  /// Parses a [MediaItem] from a Tautulli API JSON map.
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      actors: _stringListFromList(json['actors'] as List?),
      addedAt: _dateTimeFromStringEpochSeconds(json['added_at']),
      audienceRating: Cast.castToDouble(json['audience_rating']),
      collections: _stringListFromList(json['collections'] as List?),
      contentRating: Cast.castToString(json['content_rating']),
      directors: _stringListFromList(json['directors'] as List?),
      duration: _durationFromMillisString(json['duration']),
      fullTitle: Cast.castToString(json['full_title']),
      genres: _stringListFromList(json['genres'] as List?),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      grandparentThumb: Cast.castToString(json['grandparent_thumb']),
      grandparentTitle: Cast.castToString(json['grandparent_title']),
      labels: _stringListFromList(json['labels'] as List?),
      lastViewedAt: _dateTimeFromStringEpochSeconds(json['last_viewed_at']),
      libraryName: Cast.castToString(json['library_name']),
      live: Cast.castToBool(json['live']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaInfo: _mediaInfoFromList(json['media_info'] as List?),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      originalTitle: Cast.castToString(json['original_title']),
      originallyAvailableAt: _dateTimeFromString(
        Cast.castToString(json['originally_available_at']),
      ),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      parentThumb: Cast.castToString(json['parent_thumb']),
      parentTitle: Cast.castToString(json['parent_title']),
      parentYear: Cast.castToInt(json['parent_year']),
      rating: Cast.castToDouble(json['rating']),
      ratingKey: Cast.castToInt(json['rating_key']),
      sectionId: Cast.castToInt(json['section_id']),
      sortTitle: Cast.castToString(json['sort_title']),
      studio: Cast.castToString(json['studio']),
      summary: Cast.castToString(json['summary']),
      tagline: Cast.castToString(json['tagline']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      updatedAt: _dateTimeFromStringEpochSeconds(json['updated_at']),
      userRating: Cast.castToDouble(json['user_rating']),
      writers: _stringListFromList(json['writers'] as List?),
      year: Cast.castToInt(json['year']),
    );
  }

  static List<String>? _stringListFromList(List? list) {
    if (list == null || list.isEmpty) return null;
    return list.map((item) => item.toString()).toList();
  }

  static DateTime? _dateTimeFromString(String? date) {
    if (date == null) return null;
    return DateTime.tryParse(date);
  }

  static DateTime? _dateTimeFromStringEpochSeconds(dynamic value) {
    final s = Cast.castToString(value);
    if (s == null) return null;
    final seconds = int.tryParse(s);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static Duration? _durationFromMillisString(dynamic value) {
    final ms = Cast.castToInt(value);
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  static MediaInfo? _mediaInfoFromList(List? list) {
    if (list == null || list.isEmpty) return null;
    final first = list[0];
    if (first is! Map<String, dynamic>) return null;
    return MediaInfo.fromJson(first);
  }
}
