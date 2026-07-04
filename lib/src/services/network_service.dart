import '../executor.dart';
import '../models/network/geo_ip_data.dart';
import '../utils/cast.dart';

/// Commands: get_geoip_lookup, get_whois_lookup
class NetworkService {
  final TautulliExecutor _client;
  NetworkService(TautulliExecutor client) : _client = client;

  /// Returns geographic location data for the given [ipAddress].
  Future<GeoIpData> getGeoIpLookup({required String ipAddress}) async {
    final response = await _client.execute(
      'get_geoip_lookup',
      params: {'ip_address': ipAddress},
    );
    return GeoIpData.fromJson(
      Cast.dataMap(response['data'], 'get_geoip_lookup'),
    );
  }

  /// Returns WHOIS registration data for the given [ipAddress] as a raw map.
  Future<Map<String, dynamic>> getWhoisLookup({
    required String ipAddress,
  }) async {
    final response = await _client.execute(
      'get_whois_lookup',
      params: {'ip_address': ipAddress},
    );
    return Cast.dataMap(response['data'], 'get_whois_lookup');
  }
}
