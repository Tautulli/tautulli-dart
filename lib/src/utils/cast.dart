/// Coercion helpers for raw Tautulli API values.
///
/// The Tautulli API frequently returns integers as strings and booleans as
/// numbers. All [fromJson] coercions go through static methods here rather than
/// ad-hoc inline logic in model constructors.
class Cast {
  Cast._();

  /// `0`, `""`, `"0"`, `"false"`, `"False"` → `false`; any other truthy value → `true`.
  static bool? castToBool(dynamic value) {
    return switch (value) {
      final num v => v != 0,
      final String v => v != '' && v != '0' && v.toLowerCase() != 'false',
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

  /// Maps each element through [castToInt], dropping nulls.
  static List<int> castToIntList(List<dynamic> data) =>
      data.map(castToInt).whereType<int>().toList();
}
