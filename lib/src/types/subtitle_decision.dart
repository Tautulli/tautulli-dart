/// How subtitle delivery is being handled for a stream.
enum SubtitleDecision {
  /// Subtitles are being burned into the video stream.
  burn('burn'),

  /// Subtitles are being copied to the output without re-encoding.
  copy('copy'),

  /// Subtitles are being transcoded.
  transcode('transcode'),

  /// Subtitles are not active or are being ignored.
  none(''),

  /// Unrecognized subtitle decision value.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const SubtitleDecision(this.value);

  /// Parses a raw API [v] string to a [SubtitleDecision].
  ///
  /// Returns `null` if [v] is null. Empty strings and `'ignore'` map to [none].
  /// Unrecognized values map to [unknown].
  static SubtitleDecision? fromString(String? v) {
    if (v == null) return null;
    if (v == '' || v == 'ignore') return SubtitleDecision.none;
    return SubtitleDecision.values.firstWhere(
      (e) => e.value == v,
      orElse: () => SubtitleDecision.unknown,
    );
  }
}
