import '../../utils/cast.dart';

/// Play statistics for a user on a specific player platform.
///
/// Returned as part of the `get_user_player_stats` response.
class UserPlayerStat {
  /// Platform identifier string (e.g. `'chrome'`, `'ios'`).
  final String? platform;

  /// Human-readable platform name.
  final String? platformName;

  /// Name of the specific player application.
  final String? playerName;

  /// Result rank ID for ordering within the stat list.
  final int? resultId;

  /// Total number of plays on this platform.
  final int? totalPlays;

  /// Total watch time in seconds on this platform.
  final int? totalTime;

  const UserPlayerStat({
    this.platform,
    this.platformName,
    this.playerName,
    this.resultId,
    this.totalPlays,
    this.totalTime,
  });

  /// Parses a [UserPlayerStat] from a Tautulli API JSON map.
  factory UserPlayerStat.fromJson(Map<String, dynamic> json) {
    return UserPlayerStat(
      platform: Cast.castToString(json['platform']),
      platformName: Cast.castToString(json['platform_name']),
      playerName: Cast.castToString(json['player_name']),
      resultId: Cast.castToInt(json['result_id']),
      totalPlays: Cast.castToInt(json['total_plays']),
      totalTime: Cast.castToInt(json['total_time']),
    );
  }
}
