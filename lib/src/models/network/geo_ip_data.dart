import '../../utils/cast.dart';

/// Geographic location data for an IP address from `get_geoip_lookup`.
class GeoIpData {
  /// ISO 3166-1 alpha-2 country code (e.g. `'US'`, `'CA'`).
  final String? code;

  /// Country name (e.g. `'United States'`).
  final String? country;

  /// Region or state name.
  final String? region;

  /// City name.
  final String? city;

  /// Postal or ZIP code.
  final String? postalCode;

  /// IANA timezone string (e.g. `'America/New_York'`).
  final String? timezone;

  /// Geographic latitude.
  final num? latitude;

  /// Geographic longitude.
  final num? longitude;

  /// Always `null`: the server hardcodes it for GeoLite2 compatibility.
  final num? accuracy;

  /// Two-letter continent code (e.g. `'NA'`).
  final String? continent;

  const GeoIpData({
    this.code,
    this.country,
    this.region,
    this.city,
    this.postalCode,
    this.timezone,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.continent,
  });

  /// Parses [GeoIpData] from a Tautulli API JSON map.
  factory GeoIpData.fromJson(Map<String, dynamic> json) {
    return GeoIpData(
      code: Cast.castToString(json['code']),
      country: Cast.castToString(json['country']),
      region: Cast.castToString(json['region']),
      city: Cast.castToString(json['city']),
      postalCode: Cast.castToString(json['postal_code']),
      timezone: Cast.castToString(json['timezone']),
      latitude: Cast.castToNum(json['latitude']),
      longitude: Cast.castToNum(json['longitude']),
      accuracy: Cast.castToNum(json['accuracy']),
      continent: Cast.castToString(json['continent']),
    );
  }
}
