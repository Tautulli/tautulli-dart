import '../../types/media_type.dart';
import '../../utils/cast.dart';

/// A recently added item returned by `get_recently_added`.
class RecentlyAddedItem {
  /// Cast members for this item.
  final List<String>? actors;

  /// Date and time this item was added to the Plex library.
  final DateTime? addedAt;

  /// Background art URL path.
  final String? art;

  /// Audience rating score (e.g. from Rotten Tomatoes).
  final num? audienceRating;

  /// Image identifier for the audience rating source.
  final String? audienceRatingImage;

  /// Banner URL path (typically used for TV shows).
  final String? banner;

  /// Number of child items (episodes for a season, tracks for an album).
  final int? childCount;

  /// Directors credited for this item.
  final List<String>? directors;

  /// Total duration of this item.
  final Duration? duration;

  /// Full hierarchical title (e.g. `'Show - Season Title'`).
  final String? fullTitle;

  /// Genres associated with this item.
  final List<String>? genres;

  /// Rating key of the grandparent item (series for seasons).
  final int? grandparentRatingKey;

  /// Thumbnail URL path for the grandparent item.
  final String? grandparentThumb;

  /// Title of the grandparent item (series name for seasons).
  final String? grandparentTitle;

  /// Primary Plex GUID for this item.
  final String? guid;

  /// Additional GUIDs (e.g. from TMDB, TVDB) for this item.
  final List<String>? guids;

  /// Plex library labels applied to this item.
  final List<String>? labels;

  /// Timestamp when this item was last viewed.
  final DateTime? lastViewedAt;

  /// Name of the Plex library section this item belongs to.
  final String? libraryName;

  /// Episode or track index within its parent.
  final int? mediaIndex;

  /// Media type of this item.
  final MediaType? mediaType;

  /// Original title before localization.
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

  /// Critic rating score.
  final num? rating;

  /// Image identifier for the rating source.
  final String? ratingImage;

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

  /// User's personal rating score.
  final num? userRating;

  /// Timestamp when this item's metadata was last updated in Plex.
  final DateTime? updatedAt;

  /// Writers credited for this item.
  final List<String>? writers;

  /// Release year of this item.
  final int? year;

  const RecentlyAddedItem({
    this.actors,
    this.addedAt,
    this.art,
    this.audienceRating,
    this.audienceRatingImage,
    this.banner,
    this.childCount,
    this.directors,
    this.duration,
    this.fullTitle,
    this.genres,
    this.grandparentRatingKey,
    this.grandparentThumb,
    this.grandparentTitle,
    this.guid,
    this.guids,
    this.labels,
    this.lastViewedAt,
    this.libraryName,
    this.mediaIndex,
    this.mediaType,
    this.originalTitle,
    this.originallyAvailableAt,
    this.parentMediaIndex,
    this.parentRatingKey,
    this.parentThumb,
    this.parentTitle,
    this.rating,
    this.ratingImage,
    this.ratingKey,
    this.sectionId,
    this.sortTitle,
    this.studio,
    this.summary,
    this.tagline,
    this.thumb,
    this.title,
    this.userRating,
    this.updatedAt,
    this.writers,
    this.year,
  });

  /// Parses a [RecentlyAddedItem] from a Tautulli API JSON map.
  factory RecentlyAddedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyAddedItem(
      actors: _stringListFromList(json['actors'] as List?),
      addedAt: _dateTimeFromStringEpochSeconds(json['added_at']),
      art: Cast.castToString(json['art']),
      audienceRating: Cast.castToNum(json['audience_rating']),
      audienceRatingImage: Cast.castToString(json['audience_rating_image']),
      banner: Cast.castToString(json['banner']),
      childCount: Cast.castToInt(json['child_count']),
      directors: _stringListFromList(json['directors'] as List?),
      duration: _durationFromSecondsString(json['duration']),
      fullTitle: Cast.castToString(json['full_title']),
      genres: _stringListFromList(json['genres'] as List?),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      grandparentThumb: Cast.castToString(json['grandparent_thumb']),
      grandparentTitle: Cast.castToString(json['grandparent_title']),
      guid: Cast.castToString(json['guid']),
      guids: _stringListFromList(json['guids'] as List?),
      labels: _stringListFromList(json['labels'] as List?),
      lastViewedAt: _dateTimeFromStringEpochSeconds(json['last_viewed_at']),
      libraryName: Cast.castToString(json['library_name']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      originalTitle: Cast.castToString(json['original_title']),
      originallyAvailableAt: _dateTimeFromString(
        Cast.castToString(json['originally_available_at']),
      ),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      parentThumb: Cast.castToString(json['parent_thumb']),
      parentTitle: Cast.castToString(json['parent_title']),
      rating: Cast.castToNum(json['rating']),
      ratingImage: Cast.castToString(json['rating_image']),
      ratingKey: Cast.castToInt(json['rating_key']),
      sectionId: Cast.castToInt(json['section_id']),
      sortTitle: Cast.castToString(json['sort_title']),
      studio: Cast.castToString(json['studio']),
      summary: Cast.castToString(json['summary']),
      tagline: Cast.castToString(json['tagline']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      userRating: Cast.castToNum(json['user_rating']),
      updatedAt: _dateTimeFromStringEpochSeconds(json['updated_at']),
      writers: _stringListFromList(json['writers'] as List?),
      year: Cast.castToInt(json['year']),
    );
  }

  static List<String>? _stringListFromList(List? list) {
    if (list == null) return [];
    return list.map((item) => item.toString()).toList();
  }

  static DateTime? _dateTimeFromString(String? date) {
    if (date == null) return null;
    return DateTime.tryParse(date);
  }

  static DateTime? _dateTimeFromStringEpochSeconds(dynamic value) {
    final seconds = Cast.castToInt(value);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static Duration? _durationFromSecondsString(dynamic value) {
    final seconds = Cast.castToInt(value);
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }
}
