import '../../types/media_type.dart';
import '../../types/section_type.dart';
import '../../types/stat_id_type.dart';
import '../../utils/cast.dart';

/// A group of home statistics rows returned by `get_home_stats`.
///
/// Each group represents one stat category (e.g. top movies, top users).
class HomeStatGroup {
  /// The stat category this group represents.
  final StatIdType statId;

  /// The ranked items in this stat group.
  final List<HomeStat> rows;

  const HomeStatGroup({required this.statId, this.rows = const []});

  /// Parses a [HomeStatGroup] from a Tautulli API JSON map.
  factory HomeStatGroup.fromJson(Map<String, dynamic> json) {
    return HomeStatGroup(
      statId: StatIdType.fromString(Cast.castToString(json['stat_id'])),
      rows: (json['rows'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(HomeStat.fromJson)
          .toList(),
    );
  }
}

/// A single item within a [HomeStatGroup].
class HomeStat {
  /// Background art URL path for the item.
  final String? art;

  /// Content rating (e.g. `'PG-13'`, `'TV-MA'`).
  final String? contentRating;

  /// Number of plays contributing to this stat row.
  final int? count;

  /// User-configured display name for user-based stats.
  final String? friendlyName;

  /// Title of a child item (used for episode/track stats).
  final String? grandchildTitle;

  /// Rating key of the grandparent item (series, artist).
  final int? grandparentRatingKey;

  /// Thumbnail path for the grandparent item.
  final String? grandparentThumb;

  /// Title of the grandparent item (series or artist name).
  final String? grandparentTitle;

  /// Plex GUID for the item.
  final String? guid;

  /// Plex library labels applied to this item.
  final List<String>? labels;

  /// Timestamp of the last play event for this item.
  final DateTime? lastPlay;

  /// Timestamp of the last watch event for this item.
  final DateTime? lastWatch;

  /// Whether this is a live TV item.
  final bool? live;

  /// Episode or track index within its parent.
  final int? mediaIndex;

  /// Media type of this item.
  final MediaType? mediaType;

  /// Season or album index within its grandparent.
  final int? parentMediaIndex;

  /// Client platform identifier for platform-based stats.
  final String? platform;

  /// Human-readable platform name.
  final String? platformName;

  /// Critic rating for the item.
  final num? rating;

  /// Plex rating key identifying the item.
  final int? ratingKey;

  /// Database row ID.
  final int? rowId;

  /// Library section ID this item belongs to.
  final int? sectionId;

  /// Library section name this item belongs to.
  final String? sectionName;

  /// Library section type.
  final SectionType? sectionType;

  /// When the most recent session started.
  final DateTime? started;

  /// Thumbnail path for this item.
  final String? thumb;

  /// Display title for this item.
  final String? title;

  /// Total watch duration summed across all plays in this stat period.
  final Duration? totalDuration;

  /// Total play count for this item in the stat period.
  final int? totalPlays;

  /// Username for user-based stats.
  final String? user;

  /// Plex user ID for user-based stats.
  final int? userId;

  /// Number of distinct users who watched this item.
  final int? usersWatched;

  /// User's avatar thumbnail URL.
  final String? userThumb;

  /// Release year of the item.
  final int? year;

  const HomeStat({
    this.art,
    this.contentRating,
    this.count,
    this.friendlyName,
    this.grandchildTitle,
    this.grandparentRatingKey,
    this.grandparentThumb,
    this.grandparentTitle,
    this.guid,
    this.labels,
    this.lastPlay,
    this.lastWatch,
    this.live,
    this.mediaIndex,
    this.mediaType,
    this.parentMediaIndex,
    this.platform,
    this.platformName,
    this.rating,
    this.ratingKey,
    this.rowId,
    this.sectionId,
    this.sectionName,
    this.sectionType,
    this.started,
    this.thumb,
    this.title,
    this.totalDuration,
    this.totalPlays,
    this.user,
    this.userId,
    this.usersWatched,
    this.userThumb,
    this.year,
  });

  /// Parses a [HomeStat] from a Tautulli API JSON map.
  factory HomeStat.fromJson(Map<String, dynamic> json) {
    return HomeStat(
      art: Cast.castToString(json['art']),
      contentRating: Cast.castToString(json['content_rating']),
      count: Cast.castToInt(json['count']),
      friendlyName: Cast.castToString(json['friendly_name']),
      grandchildTitle: Cast.castToString(json['grandchild_title']),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      grandparentThumb: Cast.castToString(json['grandparent_thumb']),
      grandparentTitle: Cast.castToString(json['grandparent_title']),
      guid: Cast.castToString(json['guid']),
      labels: (json['labels'] as List?)?.whereType<String>().toList(),
      lastPlay: _dateTimeFromEpochSeconds(json['last_play']),
      lastWatch: _dateTimeFromEpochSeconds(json['last_watch']),
      live: Cast.castToBool(json['live']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      platform: Cast.castToString(json['platform']),
      platformName: Cast.castToString(json['platform_name']),
      rating: Cast.castToNum(json['rating']),
      ratingKey: Cast.castToInt(json['rating_key']),
      rowId: Cast.castToInt(json['row_id']),
      sectionId: Cast.castToInt(json['section_id']),
      sectionName: Cast.castToString(json['section_name']),
      sectionType: SectionType.fromString(
        Cast.castToString(json['section_type']),
      ),
      started: _dateTimeFromEpochSeconds(json['started']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      totalDuration: _durationFromSeconds(
        Cast.castToInt(json['total_duration']),
      ),
      totalPlays: Cast.castToInt(json['total_plays']),
      user: Cast.castToString(json['user']),
      userId: Cast.castToInt(json['user_id']),
      usersWatched: Cast.castToInt(json['users_watched']),
      userThumb: Cast.castToString(json['user_thumb']),
      year: Cast.castToInt(json['year']),
    );
  }

  static DateTime? _dateTimeFromEpochSeconds(dynamic value) {
    final seconds = Cast.castToInt(value);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static Duration? _durationFromSeconds(int? seconds) {
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }
}
