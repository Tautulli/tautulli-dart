import '../../utils/cast.dart';

/// Full profile data for a Tautulli user returned by `get_user` or `get_users`.
class UserData {
  /// Whether this user is allowed to access Plex as a guest.
  final bool? allowGuest;

  /// Whether this user has been deleted from Plex.
  final bool? deletedUser;

  /// User's email address.
  final String? email;

  /// Plex content filter applied to all libraries for this user.
  final String? filterAll;

  /// Plex content filter applied to movie libraries for this user.
  final String? filterMovies;

  /// Plex content filter applied to music libraries for this user.
  final String? filterMusic;

  /// Plex content filter applied to photo libraries for this user.
  final String? filterPhotos;

  /// Plex content filter applied to TV libraries for this user.
  final String? filterTv;

  /// User-configured display name shown in Tautulli.
  final String? friendlyName;

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

  /// Timestamp of the last time this user was seen playing something.
  final DateTime? lastSeen;

  /// Database row ID for this user record.
  final int? rowId;

  /// Section IDs of libraries shared with this user.
  final List<int>? sharedLibraries;

  /// URL path for the user's avatar thumbnail.
  final String? userThumb;

  /// Plex user ID.
  final int? userId;

  /// Plex account username.
  final String? username;

  const UserData({
    this.allowGuest,
    this.deletedUser,
    this.email,
    this.filterAll,
    this.filterMovies,
    this.filterMusic,
    this.filterPhotos,
    this.filterTv,
    this.friendlyName,
    this.isActive,
    this.isAdmin,
    this.isAllowSync,
    this.isHomeUser,
    this.isRestricted,
    this.keepHistory,
    this.lastSeen,
    this.rowId,
    this.sharedLibraries,
    this.userThumb,
    this.userId,
    this.username,
  });

  /// Parses [UserData] from a Tautulli API JSON map.
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      allowGuest: Cast.castToBool(json['allow_guest']),
      deletedUser: Cast.castToBool(json['deleted_user']),
      email: Cast.castToString(json['email']),
      filterAll: Cast.castToString(json['filter_all']),
      filterMovies: Cast.castToString(json['filter_movies']),
      filterMusic: Cast.castToString(json['filter_music']),
      filterPhotos: Cast.castToString(json['filter_photos']),
      filterTv: Cast.castToString(json['filter_tv']),
      friendlyName: Cast.castToString(json['friendly_name']),
      isActive: Cast.castToBool(json['is_active']),
      isAdmin: Cast.castToBool(json['is_admin']),
      isAllowSync: Cast.castToBool(json['is_allow_sync']),
      isHomeUser: Cast.castToBool(json['is_home_user']),
      isRestricted: Cast.castToBool(json['is_restricted']),
      keepHistory: Cast.castToBool(json['keep_history']),
      lastSeen: Cast.dateTimeFromEpochSeconds(json['last_seen']),
      rowId: Cast.castToInt(json['row_id']),
      sharedLibraries: _sharedLibrariesFromList(
        json['shared_libraries'] as List?,
      ),
      userThumb: Cast.castToString(json['user_thumb']),
      userId: Cast.castToInt(json['user_id']),
      username: Cast.castToString(json['username']),
    );
  }

  static List<int>? _sharedLibrariesFromList(List? libraries) {
    if (libraries == null || libraries.isEmpty) return null;
    return libraries.map((item) => int.parse(item.toString())).toList();
  }
}
