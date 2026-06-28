import '../../types/media_type.dart';
import '../../types/stream_decision.dart';
import '../../utils/cast.dart';

/// A user row returned by `get_users_table`.
///
/// Combines user account information with stats about their most recently
/// played item.
class UserTableEntry {
  /// Whether this user is allowed to access Plex as a guest.
  final bool? allowGuest;

  /// Whether this user has been deleted from Plex.
  final bool? deletedUser;

  /// Whether Tautulli sends notifications for this user's activity.
  final bool? doNotify;

  /// Total watch duration for the most recently played item in seconds.
  final int? duration;

  /// User's email address.
  final String? email;

  /// User-configured display name shown in Tautulli.
  final String? friendlyName;

  /// Plex GUID of the most recently played item.
  final String? guid;

  /// History row ID for this user's most recent play.
  final int? historyRowId;

  /// IP address of the most recent session.
  final String? ipAddress;

  /// Whether this user is currently active in Plex.
  final bool? isActive;

  /// Whether this user has Plex admin privileges.
  final bool? isAdmin;

  /// Whether this user is allowed to sync content offline.
  final bool? isAllowSync;

  /// Whether this is a Plex Home user.
  final bool? isHomeUser;

  /// Whether content restrictions are applied to this user.
  final bool? isRestricted;

  /// Whether Tautulli records watch history for this user.
  final bool? keepHistory;

  /// Title of the most recently played item.
  final String? lastPlayed;

  /// Timestamp when this user was last seen playing something.
  final DateTime? lastSeen;

  /// Whether the most recently played item was live TV.
  final bool? live;

  /// Episode/track index of the most recently played item.
  final int? mediaIndex;

  /// Media type of the most recently played item.
  final MediaType? mediaType;

  /// Original air date of the most recently played item.
  final String? originallyAvailableAt;

  /// Season/album index of the most recently played item.
  final int? parentMediaIndex;

  /// Season/album title of the most recently played item.
  final String? parentTitle;

  /// Platform of the most recent session.
  final String? platform;

  /// Player name of the most recent session.
  final String? player;

  /// Total play count for this user.
  final int? plays;

  /// Plex rating key for the most recently played item.
  final int? ratingKey;

  /// Database row ID for this user record.
  final int? rowId;

  /// Section IDs of libraries shared with this user.
  final List<int>? sharedLibraries;

  /// Thumbnail URL path for the most recently played item.
  final String? thumb;

  /// Title of the most recently played item.
  final String? title;

  /// Transcode decision for the most recent session.
  final StreamDecision? transcodeDecision;

  /// Plex user ID.
  final int? userId;

  /// URL path for the user's avatar thumbnail.
  final String? userThumb;

  /// Plex account username.
  final String? username;

  /// Release year of the most recently played item.
  final int? year;

  const UserTableEntry({
    this.allowGuest,
    this.deletedUser,
    this.doNotify,
    this.duration,
    this.email,
    this.friendlyName,
    this.guid,
    this.historyRowId,
    this.ipAddress,
    this.isActive,
    this.isAdmin,
    this.isAllowSync,
    this.isHomeUser,
    this.isRestricted,
    this.keepHistory,
    this.lastPlayed,
    this.lastSeen,
    this.live,
    this.mediaIndex,
    this.mediaType,
    this.originallyAvailableAt,
    this.parentMediaIndex,
    this.parentTitle,
    this.platform,
    this.player,
    this.plays,
    this.ratingKey,
    this.rowId,
    this.sharedLibraries,
    this.thumb,
    this.title,
    this.transcodeDecision,
    this.userId,
    this.userThumb,
    this.username,
    this.year,
  });

  /// Parses a [UserTableEntry] from a Tautulli API JSON map.
  factory UserTableEntry.fromJson(Map<String, dynamic> json) {
    return UserTableEntry(
      allowGuest: Cast.castToBool(json['allow_guest']),
      deletedUser: Cast.castToBool(json['deleted_user']),
      doNotify: Cast.castToBool(json['do_notify']),
      duration: Cast.castToInt(json['duration']),
      email: Cast.castToString(json['email']),
      friendlyName: Cast.castToString(json['friendly_name']),
      guid: Cast.castToString(json['guid']),
      historyRowId: Cast.castToInt(json['history_row_id']),
      ipAddress: Cast.castToString(json['ip_address']),
      isActive: Cast.castToBool(json['is_active']),
      isAdmin: Cast.castToBool(json['is_admin']),
      isAllowSync: Cast.castToBool(json['is_allow_sync']),
      isHomeUser: Cast.castToBool(json['is_home_user']),
      isRestricted: Cast.castToBool(json['is_restricted']),
      keepHistory: Cast.castToBool(json['keep_history']),
      lastPlayed: Cast.castToString(json['last_played']),
      lastSeen: _dateTimeFromEpochSeconds(Cast.castToInt(json['last_seen'])),
      live: Cast.castToBool(json['live']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      originallyAvailableAt: Cast.castToString(json['originally_available_at']),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentTitle: Cast.castToString(json['parent_title']),
      platform: Cast.castToString(json['platform']),
      player: Cast.castToString(json['player']),
      plays: Cast.castToInt(json['plays']),
      ratingKey: Cast.castToInt(json['rating_key']),
      rowId: Cast.castToInt(json['row_id']),
      sharedLibraries: _sharedLibrariesFromList(json['shared_libraries'] as List?),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      transcodeDecision: StreamDecision.fromString(Cast.castToString(json['transcode_decision'])),
      userId: Cast.castToInt(json['user_id']),
      userThumb: Cast.castToString(json['user_thumb']),
      username: Cast.castToString(json['username']),
      year: Cast.castToInt(json['year']),
    );
  }

  static DateTime? _dateTimeFromEpochSeconds(int? seconds) {
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static List<int>? _sharedLibrariesFromList(List? libraries) {
    if (libraries == null || libraries.isEmpty) return null;
    return libraries.map((item) => int.parse(item.toString())).toList();
  }
}
