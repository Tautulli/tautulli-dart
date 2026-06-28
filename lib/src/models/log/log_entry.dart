import '../../utils/cast.dart';

/// A single entry from the Tautulli or Plex log.
///
/// Log responses can arrive as JSON objects (via `get_logs`) or positional
/// arrays (from some endpoints). Use [fromJson] or [fromList] accordingly.
class LogEntry {
  /// Row ID (only populated when parsed from a positional list via [fromList]).
  final int? rowId;

  /// Formatted timestamp string for this log entry.
  final String? timestamp;

  /// Severity level (e.g. `'INFO'`, `'WARNING'`, `'ERROR'`).
  final String? level;

  /// Thread or module name that produced this entry.
  final String? thread;

  /// The log message text.
  final String? message;

  const LogEntry({
    this.rowId,
    this.timestamp,
    this.level,
    this.thread,
    this.message,
  });

  /// Parses a [LogEntry] from a Tautulli API JSON map.
  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    timestamp: Cast.castToString(json['time']),
    level: Cast.castToString(json['loglevel']),
    thread: Cast.castToString(json['thread']),
    message: Cast.castToString(json['msg']),
  );

  /// Parses a [LogEntry] from a positional list `[rowId, timestamp, level, thread, message]`.
  static LogEntry fromList(List<dynamic> list) => LogEntry(
    rowId: list.isNotEmpty ? Cast.castToInt(list[0]) : null,
    timestamp: list.length > 1 ? Cast.castToString(list[1]) : null,
    level: list.length > 2 ? Cast.castToString(list[2]) : null,
    thread: list.length > 3 ? Cast.castToString(list[3]) : null,
    message: list.length > 4 ? Cast.castToString(list[4]) : null,
  );
}
