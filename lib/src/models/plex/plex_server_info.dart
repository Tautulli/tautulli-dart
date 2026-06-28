import '../../utils/cast.dart';

/// Information about the connected Plex Media Server.
///
/// Returned by `get_server_info`. All fields use the `pms_` prefix as they
/// come directly from Tautulli's stored Plex server settings.
class PlexServerInfo {
  /// Plex server machine identifier (UUID).
  final String? pmsIdentifier;

  /// IP address of the Plex Media Server.
  final String? pmsIp;

  /// Whether the Plex server is accessed remotely (not on LAN).
  final bool? pmsIsRemote;

  /// Friendly name of the Plex Media Server.
  final String? pmsName;

  /// Platform the Plex server runs on (e.g. `'Linux'`, `'Windows'`).
  final String? pmsPlatform;

  /// Whether the Plex account has an active Plex Pass subscription.
  final bool? pmsPlexpass;

  /// Port number the Plex server listens on.
  final int? pmsPort;

  /// Whether SSL/TLS is enabled for connections to the Plex server.
  final bool? pmsSsl;

  /// Base URL used to connect to the Plex server.
  final String? pmsUrl;

  /// Whether the Plex server URL was set manually rather than auto-detected.
  final bool? pmsUrlManual;

  /// Plex Media Server version string.
  final String? pmsVersion;

  const PlexServerInfo({
    this.pmsIdentifier,
    this.pmsIp,
    this.pmsIsRemote,
    this.pmsName,
    this.pmsPlatform,
    this.pmsPlexpass,
    this.pmsPort,
    this.pmsSsl,
    this.pmsUrl,
    this.pmsUrlManual,
    this.pmsVersion,
  });

  /// Parses [PlexServerInfo] from a Tautulli API JSON map.
  factory PlexServerInfo.fromJson(Map<String, dynamic> json) {
    return PlexServerInfo(
      pmsIdentifier: Cast.castToString(json['pms_identifier']),
      pmsIp: Cast.castToString(json['pms_ip']),
      pmsIsRemote: Cast.castToBool(json['pms_is_remote']),
      pmsName: Cast.castToString(json['pms_name']),
      pmsPlatform: Cast.castToString(json['pms_platform']),
      pmsPlexpass: Cast.castToBool(json['pms_plexpass']),
      pmsPort: Cast.castToInt(json['pms_port']),
      pmsSsl: Cast.castToBool(json['pms_ssl']),
      pmsUrl: Cast.castToString(json['pms_url']),
      pmsUrlManual: Cast.castToBool(json['pms_url_manual']),
      pmsVersion: Cast.castToString(json['pms_version']),
    );
  }
}
