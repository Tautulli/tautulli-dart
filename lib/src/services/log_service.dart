import 'dart:typed_data';

import '../executor.dart';
import '../models/log/log_entry.dart';
import '../utils/cast.dart';

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
    return Cast.dataList(
      response['data'],
      'get_logs',
    ).whereType<Map<String, dynamic>>().map(LogEntry.fromJson).toList();
  }

  /// Returns Plex Media Server log entries.
  ///
  /// [window] limits the number of tail lines returned. [logfile] selects the
  /// Plex log file by name (e.g. `'Plex Media Server'`, `'Plex Media Scanner'`).
  Future<List<LogEntry>> getPlexLog({int? window, String? logfile}) async {
    final params = <String, dynamic>{};
    if (window != null) params['window'] = window;
    if (logfile != null) params['logfile'] = logfile;

    final response = await _client.execute('get_plex_log', params: params);
    // Rows are [timestamp, level, message]. Servers up to v2.17.2 nest them
    // under `data.data`; newer servers return the bare list as `data`.
    final data = response['data'];
    final rows = data is Map<String, dynamic> ? data['data'] : data;
    if (rows is! List) return [];
    return rows.whereType<List>().map(LogEntry.fromPlexLogList).toList();
  }

  /// Downloads the Tautulli log file as raw bytes.
  ///
  /// [logfile] selects a specific log file by name.
  Future<Uint8List> downloadLog({String? logfile}) async {
    return _client.executeDownload(
      'download_log',
      params: {'logfile': ?logfile},
    );
  }

  /// Downloads the Plex Media Server log file as raw bytes.
  ///
  /// [logfile] selects a specific Plex log file by name (e.g.
  /// `'Plex Media Server'`, `'Plex Media Scanner'`).
  Future<Uint8List> downloadPlexLog({String? logfile}) async {
    return _client.executeDownload(
      'download_plex_log',
      params: {'logfile': ?logfile},
    );
  }

  /// Deletes all entries from the Tautulli login log.
  Future<void> deleteLoginLog() async {
    await _client.execute('delete_login_log');
  }
}
