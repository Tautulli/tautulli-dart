import '../executor.dart';
import '../models/tautulli/register_device_result.dart';

/// Commands: register_device, set_mobile_device_config, delete_mobile_device
class DeviceService {
  final TautulliExecutor _client;
  DeviceService(TautulliExecutor client) : _client = client;

  /// Updates the configuration for a registered mobile device.
  ///
  /// [mobileDeviceId] identifies the device; [friendlyName] overrides
  /// the display name shown in Tautulli's mobile devices list.
  Future<void> setMobileDeviceConfig({
    required int mobileDeviceId,
    String? friendlyName,
  }) async {
    final params = <String, dynamic>{'mobile_device_id': mobileDeviceId};
    if (friendlyName != null) params['friendly_name'] = friendlyName;
    await _client.execute('set_mobile_device_config', params: params);
  }

  /// Removes a mobile device registration from Tautulli.
  ///
  /// Identify the device by its Tautulli [mobileDeviceId] or by its Plex
  /// [deviceId]; provide one.
  Future<void> deleteMobileDevice({
    int? mobileDeviceId,
    String? deviceId,
  }) async {
    final params = <String, dynamic>{};
    if (mobileDeviceId != null) params['mobile_device_id'] = mobileDeviceId;
    if (deviceId != null) params['device_id'] = deviceId;
    await _client.execute('delete_mobile_device', params: params);
  }

  /// Registers a mobile device with Tautulli and returns server info.
  ///
  /// Only [deviceId] and [deviceName] are required. Returns a
  /// [RegisterDeviceResult] containing Plex Media Server details and Tautulli
  /// version information for the connected server.
  Future<RegisterDeviceResult> registerDevice({
    required String deviceId,
    required String deviceName,
    String? platform,
    String? version,
    String? friendlyName,
    String? onesignalId,
    String? minVersion,
  }) async {
    final params = <String, dynamic>{
      'device_id': deviceId,
      'device_name': deviceName,
    };
    if (platform != null) params['platform'] = platform;
    if (version != null) params['version'] = version;
    if (friendlyName != null) params['friendly_name'] = friendlyName;
    if (onesignalId != null) params['onesignal_id'] = onesignalId;
    if (minVersion != null) params['min_version'] = minVersion;

    final response = await _client.execute('register_device', params: params);
    return RegisterDeviceResult.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
