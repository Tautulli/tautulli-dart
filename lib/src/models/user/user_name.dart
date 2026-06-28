import '../../utils/cast.dart';

/// Lightweight identifier for a Tautulli user.
///
/// Returned by `get_user_names` for populating dropdowns or filters.
class UserName {
  /// Plex user ID.
  final int? userId;

  /// Plex account username.
  final String? username;

  /// User-configured display name shown in Tautulli.
  final String? friendlyName;

  const UserName({this.userId, this.username, this.friendlyName});

  /// Parses a [UserName] from a Tautulli API JSON map.
  factory UserName.fromJson(Map<String, dynamic> json) {
    return UserName(
      userId: Cast.castToInt(json['user_id']),
      username: Cast.castToString(json['username']),
      friendlyName: Cast.castToString(json['friendly_name']),
    );
  }
}
