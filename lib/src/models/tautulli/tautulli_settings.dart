import '../../utils/cast.dart';

/// Parsed view of `get_settings`.
///
/// [dateFormat] and [timeFormat] are surfaced as typed convenience fields
/// (both from the `General` section). Every other setting is available through
/// [rawData], which holds the complete response — a map of config section name
/// to that section's settings:
///
/// ```dart
/// final settings = await client.tautulli.getSettings();
/// final verifySsl = settings.rawData['Advanced']?['verify_ssl_cert'];
/// final pmsName = settings.rawData['PMS']?['pms_name'];
/// ```
///
/// Section names match Tautulli's config (`General`, `Advanced`, `PMS`, the
/// notifier sections, etc.). When a single section is requested via
/// `getSettings(key: 'General')`, [rawData] holds that section's keys directly.
class TautulliSettings {
  /// Date format string configured in Tautulli (e.g. `'YYYY-MM-DD'`).
  final String? dateFormat;

  /// Time format string configured in Tautulli (e.g. `'HH:mm'`).
  final String? timeFormat;

  /// The complete `get_settings` response: a map of config section name to that
  /// section's settings (or, when a single section was requested, its keys).
  final Map<String, dynamic> rawData;

  const TautulliSettings({
    this.dateFormat,
    this.timeFormat,
    required this.rawData,
  });

  /// Parses [TautulliSettings] from a Tautulli API JSON map.
  ///
  /// `get_settings` returns config sections (`{"General": {...}, ...}`), so
  /// [dateFormat] and [timeFormat] are read from the `General` section. When a
  /// single section was requested via `key`, the response is that section's
  /// keys directly, so this falls back to reading them from the root.
  factory TautulliSettings.fromJson(Map<String, dynamic> json) {
    final general = json['General'];
    final source = general is Map<String, dynamic> ? general : json;
    return TautulliSettings(
      dateFormat: Cast.castToString(source['date_format']),
      timeFormat: Cast.castToString(source['time_format']),
      rawData: json,
    );
  }
}
