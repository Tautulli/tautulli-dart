/// The Y-axis metric used in Tautulli graph endpoints.
enum PlayMetricType {
  /// Count of plays.
  plays('plays'),

  /// Total playback duration in seconds.
  time('duration'),

  /// Unrecognized metric type.
  unknown('unknown');

  /// The raw string value sent as the `y_axis` query parameter.
  final String value;
  const PlayMetricType(this.value);

  /// Parses a raw API [v] string to a [PlayMetricType].
  ///
  /// Returns [unknown] if [v] is null or does not match any known value.
  static PlayMetricType fromString(String? v) {
    if (v == null) return PlayMetricType.unknown;
    return PlayMetricType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => PlayMetricType.unknown,
    );
  }
}
