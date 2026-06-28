import 'dart:typed_data';

import '../executor.dart';
import '../models/log/log_entry.dart';

/// Commands: get_logs, get_plex_log, download_log, download_plex_log,
/// delete_login_log
class LogService {
  final TautulliExecutor _client;
  LogService(TautulliExecutor client) : _client = client;

  /// Returns Tautulli log entries, optionally filtered and paginated.
  ///
  /// Use [search] or [regex] to filter by content, and [start]/[end] for row offsets.
  /// Set [ms] to `true` to include milliseconds in timestamps.
  Future<List<LogEntry>> getLogs({
    String? sort,
    String? search,
    String? order,
    String? regex,
    int? start,
    int? end,
    bool? ms,
  }) async {
    final params = <String, dynamic>{};
    if (sort != null) params['sort'] = sort;
    if (search != null) params['search'] = search;
    if (order != null) params['order'] = order;
    if (regex != null) params['regex'] = regex;
    if (start != null) params['start'] = start;
    if (end != null) params['end'] = end;
    if (ms != null) params['ms'] = ms;

    final response = await _client.execute('get_logs', params: params);
    return _parseLogs(response['data']);
  }

  /// Returns Plex Media Server log entries, optionally filtered and paginated.
  Future<List<LogEntry>> getPlexLog({String? sort, String? search, int? start, int? end}) async {
    final params = <String, dynamic>{};
    if (sort != null) params['sort'] = sort;
    if (search != null) params['search'] = search;
    if (start != null) params['start'] = start;
    if (end != null) params['end'] = end;

    final response = await _client.execute('get_plex_log', params: params);
    return _parseLogs(response['data']);
  }

  /// Downloads the Tautulli log file as raw bytes.
  Future<Uint8List> downloadLog() async {
    return _client.executeDownload('download_log');
  }

  /// Downloads the Plex Media Server log file as raw bytes.
  Future<Uint8List> downloadPlexLog() async {
    return _client.executeDownload('download_plex_log');
  }

  /// Deletes all entries from the Tautulli login log.
  Future<void> deleteLoginLog() async {
    await _client.execute('delete_login_log');
  }

  List<LogEntry> _parseLogs(dynamic data) {
    if (data is! List) return [];
    return data.map((item) {
      if (item is Map<String, dynamic>) return LogEntry.fromJson(item);
      if (item is List) return LogEntry.fromList(item);
      return const LogEntry();
    }).toList();
  }
}
