import '../../utils/cast.dart';

/// Server and version information returned by `register_device`.
///
/// Contains both Plex Media Server details and Tautulli installation metadata
/// for the server the device was registered with.
class RegisterDeviceResult {
  /// Plex server machine identifier (UUID).
  final String? pmsIdentifier;

  /// IP address of the Plex Media Server.
  final String? pmsIp;

  /// Whether the Plex server is accessed remotely.
  final bool? pmsIsRemote;

  /// Friendly name of the Plex Media Server.
  final String? pmsName;

  /// Platform the Plex server runs on.
  final String? pmsPlatform;

  /// Whether the Plex account has an active Plex Pass subscription.
  final bool? pmsPlexpass;

  /// Port number the Plex server listens on.
  final int? pmsPort;

  /// Whether SSL/TLS is enabled for connections to the Plex server.
  final bool? pmsSsl;

  /// Base URL used to connect to the Plex server.
  final String? pmsUrl;

  /// Whether the Plex URL was set manually.
  final bool? pmsUrlManual;

  /// Plex Media Server version string.
  final String? pmsVersion;

  /// Tautulli server ID string.
  final String? serverId;

  /// Tautulli installation type (e.g. `'docker'`, `'bare-metal'`).
  final String? tautulliInstallType;

  /// Git branch Tautulli is running from.
  final String? tautulliBranch;

  /// Git commit hash of the running Tautulli version.
  final String? tautulliCommit;

  /// OS platform Tautulli runs on.
  final String? tautulliPlatform;

  /// Device/hostname of the machine running Tautulli.
  final String? tautulliPlatformDeviceName;

  /// Linux distribution name (if applicable).
  final String? tautulliPlatformLinuxDistro;

  /// OS release string.
  final String? tautulliPlatformRelease;

  /// OS version string.
  final String? tautulliPlatformVersion;

  /// Python version Tautulli is running under.
  final String? tautulliPythonVersion;

  /// Tautulli application version string.
  final String? tautulliVersion;

  const RegisterDeviceResult({
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
    this.serverId,
    this.tautulliInstallType,
    this.tautulliBranch,
    this.tautulliCommit,
    this.tautulliPlatform,
    this.tautulliPlatformDeviceName,
    this.tautulliPlatformLinuxDistro,
    this.tautulliPlatformRelease,
    this.tautulliPlatformVersion,
    this.tautulliPythonVersion,
    this.tautulliVersion,
  });

  /// Parses a [RegisterDeviceResult] from a Tautulli API JSON map.
  factory RegisterDeviceResult.fromJson(Map<String, dynamic> json) {
    return RegisterDeviceResult(
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
      serverId: Cast.castToString(json['server_id']),
      tautulliInstallType: Cast.castToString(json['tautulli_install_type']),
      tautulliBranch: Cast.castToString(json['tautulli_branch']),
      tautulliCommit: Cast.castToString(json['tautulli_commit']),
      tautulliPlatform: Cast.castToString(json['tautulli_platform']),
      tautulliPlatformDeviceName: Cast.castToString(
        json['tautulli_platform_device_name'],
      ),
      tautulliPlatformLinuxDistro: Cast.castToString(
        json['tautulli_platform_linux_distro'],
      ),
      tautulliPlatformRelease: Cast.castToString(
        json['tautulli_platform_release'],
      ),
      tautulliPlatformVersion: Cast.castToString(
        json['tautulli_platform_version'],
      ),
      tautulliPythonVersion: Cast.castToString(json['tautulli_python_version']),
      tautulliVersion: Cast.castToString(json['tautulli_version']),
    );
  }
}
