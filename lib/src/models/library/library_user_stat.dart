import '../../utils/cast.dart';

/// Watch statistics for a single user within a library section.
///
/// Returned as part of the `get_library_user_stats` response.
class LibraryUserStat {
  /// User-configured display name.
  final String? friendlyName;

  /// Total number of plays by this user in the library.
  final int? totalPlays;

  /// Total watch time in seconds by this user in the library.
  final int? totalTime;

  /// Plex user ID.
  final int? userId;

  /// URL path for the user's avatar thumbnail.
  final String? userThumb;

  /// Plex username.
  final String? username;

  const LibraryUserStat({
    this.friendlyName,
    this.totalPlays,
    this.totalTime,
    this.userId,
    this.userThumb,
    this.username,
  });

  /// Parses a [LibraryUserStat] from a Tautulli API JSON map.
  factory LibraryUserStat.fromJson(Map<String, dynamic> json) {
    return LibraryUserStat(
      friendlyName: Cast.castToString(json['friendly_name']),
      totalPlays: Cast.castToInt(json['total_plays']),
      totalTime: Cast.castToInt(json['total_time']),
      userId: Cast.castToInt(json['user_id']),
      userThumb: Cast.castToString(json['user_thumb']),
      username: Cast.castToString(json['username']),
    );
  }
}
