import '../../utils/cast.dart';

/// A single entry from the Tautulli or Plex log.
///
/// Tautulli logs (`get_logs`) arrive as JSON objects — use [fromJson]. Plex
/// logs (`get_plex_log`) arrive as positional `[timestamp, level, message]`
/// arrays — use [fromPlexLogList].
class LogEntry {
  /// Formatted timestamp string for this log entry.
  final String? timestamp;

  /// Severity level (e.g. `'INFO'`, `'WARNING'`, `'ERROR'`).
  final String? level;

  /// Thread or module name that produced this entry (Tautulli logs only).
  final String? thread;

  /// The log message text.
  final String? message;

  const LogEntry({this.timestamp, this.level, this.thread, this.message});

  /// Parses a [LogEntry] from a Tautulli `get_logs` JSON map.
  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    timestamp: Cast.castToString(json['time']),
    level: Cast.castToString(json['loglevel']),
    thread: Cast.castToString(json['thread']),
    message: Cast.castToString(json['msg']),
  );

  /// Parses a [LogEntry] from a Plex `get_plex_log` positional row
  /// `[timestamp, level, message]`.
  static LogEntry fromPlexLogList(List<dynamic> list) => LogEntry(
    timestamp: list.isNotEmpty ? Cast.castToString(list[0]) : null,
    level: list.length > 1 ? Cast.castToString(list[1]) : null,
    message: list.length > 2 ? Cast.castToString(list[2]) : null,
  );
}
