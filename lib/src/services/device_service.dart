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
  Future<void> setMobileDeviceConfig({required int mobileDeviceId, String? friendlyName}) async {
    final params = <String, dynamic>{'mobile_device_id': mobileDeviceId};
    if (friendlyName != null) params['friendly_name'] = friendlyName;
    await _client.execute('set_mobile_device_config', params: params);
  }

  /// Removes a mobile device registration from Tautulli.
  Future<void> deleteMobileDevice({required int mobileDeviceId}) async {
    await _client.execute('delete_mobile_device', params: {'mobile_device_id': mobileDeviceId});
  }

  /// Registers a mobile device with Tautulli and returns server info.
  ///
  /// Returns a [RegisterDeviceResult] containing Plex Media Server details
  /// and Tautulli version information for the connected server.
  Future<RegisterDeviceResult> registerDevice({
    required String deviceName,
    required String deviceId,
    required String onesignalId,
    required String platform,
    required String version,
    String? minVersion,
  }) async {
    final params = <String, dynamic>{
      'device_name': deviceName,
      'device_id': deviceId,
      'onesignal_id': onesignalId,
      'platform': platform,
      'version': version,
    };
    if (minVersion != null) params['min_version'] = minVersion;

    final response = await _client.execute('register_device', params: params);
    return RegisterDeviceResult.fromJson(response['data'] as Map<String, dynamic>? ?? {});
  }
}
