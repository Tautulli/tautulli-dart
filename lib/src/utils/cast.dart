import '../exceptions.dart';

/// Coercion helpers for raw Tautulli API values.
///
/// The Tautulli API frequently returns integers as strings and booleans as
/// numbers. All `fromJson` coercions go through static methods here rather than
/// ad-hoc inline logic in model constructors.
class Cast {
  Cast._();

  static const _falsyStrings = {'', '0', 'false', 'no', 'off', 'n', 'f'};

  /// `0`, `""`, `"0"`, `"false"`, `"no"`, `"off"` (case-insensitive) → `false`;
  /// any other truthy value → `true`.
  static bool? castToBool(dynamic value) {
    return switch (value) {
      final num v => v != 0,
      final String v => !_falsyStrings.contains(v.toLowerCase()),
      final bool v => v,
      _ => null,
    };
  }

  /// Coerces [double], [int], [String], or [bool] to [int].
  static int? castToInt(dynamic value) {
    return switch (value) {
      final int v => v,
      final double v => v.floor(),
      final String v => int.tryParse(v),
      final bool v => v ? 1 : 0,
      _ => null,
    };
  }

  /// Coerces [double], [int], [String], or [bool] to [String].
  static String? castToString(dynamic value) {
    return switch (value) {
      final String v => v,
      final int v => v.toString(),
      final double v => v.toString(),
      final bool v => v ? '1' : '0',
      _ => null,
    };
  }

  /// Coerces [double], [int], [String], or [bool] to [double].
  static double? castToDouble(dynamic value) {
    return switch (value) {
      final double v => v,
      final int v => v.toDouble(),
      final String v => double.tryParse(v),
      final bool v => v ? 1.0 : 0.0,
      _ => null,
    };
  }

  /// Coerces to [num].
  static num? castToNum(dynamic value) {
    return switch (value) {
      final num v => v,
      final String v => num.tryParse(v),
      final bool v => v ? 1 : 0,
      _ => null,
    };
  }

  /// Maps each element through [castToInt], substituting `0` for values that
  /// fail to coerce so positions stay aligned (e.g. with graph categories).
  static List<int> castToIntList(List<dynamic> data) =>
      data.map((e) => castToInt(e) ?? 0).toList();

  /// Converts a Unix epoch-seconds value to a UTC [DateTime].
  ///
  /// Returns a UTC-flagged [DateTime]; call `.toLocal()` for display. Returns
  /// `null` when [value] does not coerce to an integer.
  static DateTime? dateTimeFromEpochSeconds(dynamic value) {
    final seconds = castToInt(value);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Returns [data] as a `Map<String, dynamic>`.
  ///
  /// Yields an empty map when [data] is `null`, but throws a
  /// [TautulliBadResponseException] (naming [context]) when [data] is present
  /// but not an object — surfacing an unexpected response shape as a typed
  /// error rather than a raw `TypeError`.
  static Map<String, dynamic> dataMap(Object? data, [String? context]) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    throw TautulliBadResponseException(
      message:
          "${context ?? 'response'}: expected a JSON object, "
          'got ${data.runtimeType}',
    );
  }

  /// Returns [data] as a `List`.
  ///
  /// Yields an empty list when [data] is `null`, but throws a
  /// [TautulliBadResponseException] (naming [context]) when [data] is present
  /// but not a list.
  static List<dynamic> dataList(Object? data, [String? context]) {
    if (data == null) return [];
    if (data is List) return data;
    throw TautulliBadResponseException(
      message:
          "${context ?? 'response'}: expected a JSON array, "
          'got ${data.runtimeType}',
    );
  }
}
