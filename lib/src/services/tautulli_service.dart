import 'dart:typed_data';

import '../executor.dart';
import '../models/tautulli/tautulli_settings.dart';

/// Commands: get_tautulli_info, get_date_formats, get_settings, status,
/// update_check, update, restart, backup_config, backup_db,
/// download_config, download_database, import_config, import_database,
/// sql, delete_cache, delete_image_cache, delete_temp_sessions,
/// logout_user_session
class TautulliService {
  final TautulliExecutor _client;
  TautulliService(TautulliExecutor client) : _client = client;

  /// Returns Tautulli's current settings.
  ///
  /// Optionally pass [key] to retrieve a single setting value.
  /// All raw settings are available via [TautulliSettings.rawData].
  Future<TautulliSettings> getSettings({String? key}) async {
    final params = <String, dynamic>{};
    if (key != null) params['key'] = key;
    final response = await _client.execute('get_settings', params: params);
    return TautulliSettings.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Returns Tautulli version, branch, and installation metadata.
  Future<Map<String, dynamic>> getTautulliInfo() async {
    final response = await _client.execute('get_tautulli_info');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the date and time format strings configured in Tautulli.
  Future<Map<String, dynamic>> getDateFormats() async {
    final response = await _client.execute('get_date_formats');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the current operational status of Tautulli.
  ///
  /// Pass [check] to test a specific subsystem (e.g. `'database'`).
  Future<Map<String, dynamic>> status({String? check}) async {
    final params = <String, dynamic>{};
    if (check != null) params['check'] = check;
    final response = await _client.execute('status', params: params);
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Checks for available Tautulli updates.
  Future<Map<String, dynamic>> updateCheck() async {
    final response = await _client.execute('update_check');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Executes a raw SQL [query] against the Tautulli database.
  ///
  /// Use with caution — no safety checks are applied.
  Future<List<Map<String, dynamic>>> sql({required String query}) async {
    final response = await _client.execute('sql', params: {'query': query});
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Downloads the Tautulli configuration file as raw bytes.
  Future<Uint8List> downloadConfig() async {
    return _client.executeDownload('download_config');
  }

  /// Downloads the Tautulli SQLite database file as raw bytes.
  Future<Uint8List> downloadDatabase() async {
    return _client.executeDownload('download_database');
  }

  /// Triggers a Tautulli update from the configured branch.
  Future<void> update() async {
    await _client.execute('update');
  }

  /// Restarts the Tautulli service.
  Future<void> restart() async {
    await _client.execute('restart');
  }

  /// Creates a backup of the Tautulli configuration file.
  Future<void> backupConfig() async {
    await _client.execute('backup_config');
  }

  /// Creates a backup of the Tautulli database.
  Future<void> backupDb() async {
    await _client.execute('backup_db');
  }

  /// Clears the Tautulli application cache.
  Future<void> deleteCache() async {
    await _client.execute('delete_cache');
  }

  /// Clears the Tautulli image proxy cache.
  Future<void> deleteImageCache() async {
    await _client.execute('delete_image_cache');
  }

  /// Deletes stale temporary session records from the database.
  Future<void> deleteTempSessions() async {
    await _client.execute('delete_temp_sessions');
  }

  /// Invalidates the login sessions with the given [rowIds].
  ///
  /// [rowIds] are login-log row IDs (see `UserService.getUserLogins`); pass at
  /// least one.
  Future<void> logoutUserSession({required List<int> rowIds}) async {
    await _client.execute('logout_user_session', params: {'row_ids': rowIds});
  }

  // ignore: avoid_returning_null_for_void
  Future<void> importConfig() => Future.error(
    UnimplementedError(
      'importConfig requires multipart POST — not yet implemented',
    ),
  );

  // ignore: avoid_returning_null_for_void
  Future<void> importDatabase() => Future.error(
    UnimplementedError(
      'importDatabase requires multipart POST — not yet implemented',
    ),
  );
}
