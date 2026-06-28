import '../../utils/cast.dart';

/// Subset of get_settings fields used by Tautulli Remote.
///
/// The full Tautulli settings object has many more keys. Access the raw
/// response via [rawData] if you need additional fields.
class TautulliSettings {
  /// Date format string configured in Tautulli (e.g. `'YYYY-MM-DD'`).
  final String? dateFormat;

  /// Time format string configured in Tautulli (e.g. `'HH:mm'`).
  final String? timeFormat;

  /// The complete raw API data map, for accessing fields not surfaced above.
  final Map<String, dynamic> rawData;

  const TautulliSettings({
    this.dateFormat,
    this.timeFormat,
    required this.rawData,
  });

  /// Parses [TautulliSettings] from a Tautulli API JSON map.
  factory TautulliSettings.fromJson(Map<String, dynamic> json) {
    return TautulliSettings(
      dateFormat: Cast.castToString(json['date_format']),
      timeFormat: Cast.castToString(json['time_format']),
      rawData: json,
    );
  }
}
