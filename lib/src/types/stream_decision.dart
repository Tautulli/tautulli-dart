/// How a particular stream component (video, audio, container) is being handled.
enum StreamDecision {
  /// The stream is being copied without re-encoding.
  copy('copy'),

  /// The stream is being played directly without any server-side processing.
  directPlay('direct play'),

  /// The stream is being transcoded (re-encoded) by the server.
  transcode('transcode'),

  /// No stream decision applies (e.g. subtitle not in use).
  none(''),

  /// Unrecognized stream decision value.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const StreamDecision(this.value);

  /// Parses a raw API [v] string to a [StreamDecision].
  ///
  /// Returns `null` if [v] is null, or [unknown] if the value is unrecognized.
  static StreamDecision? fromString(String? v) {
    if (v == null) return null;
    return StreamDecision.values.firstWhere(
      (e) => e.value == v,
      orElse: () => StreamDecision.unknown,
    );
  }
}
