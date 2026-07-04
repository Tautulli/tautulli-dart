import '../../utils/cast.dart';

/// Lightweight identifier for a Tautulli user.
///
/// Returned by `get_user_names` for populating dropdowns or filters.
class UserName {
  /// Plex user ID.
  final int? userId;

  /// User-configured display name shown in Tautulli.
  final String? friendlyName;

  const UserName({this.userId, this.friendlyName});

  /// Parses a [UserName] from a Tautulli API JSON map.
  factory UserName.fromJson(Map<String, dynamic> json) {
    return UserName(
      userId: Cast.castToInt(json['user_id']),
      friendlyName: Cast.castToString(json['friendly_name']),
    );
  }
}
