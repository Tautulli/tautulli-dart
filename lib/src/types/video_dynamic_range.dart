/// The dynamic range of a video stream.
enum VideoDynamicRange {
  /// High Dynamic Range.
  hdr('HDR'),

  /// Standard Dynamic Range.
  sdr('SDR'),

  /// Unrecognized dynamic range value.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const VideoDynamicRange(this.value);

  /// Parses a raw API [v] string to a [VideoDynamicRange] (case-insensitive).
  ///
  /// Returns `null` if [v] is null, or [unknown] if the value is unrecognized.
  static VideoDynamicRange? fromString(String? v) {
    if (v == null) return null;
    return VideoDynamicRange.values.firstWhere(
      (e) => e.value == v.toUpperCase(),
      orElse: () => VideoDynamicRange.unknown,
    );
  }
}
