/// The current playback state of a Plex session.
enum PlaybackState {
  /// Media is buffering.
  buffering('buffering'),

  /// Session is in an error state.
  error('error'),

  /// Media is paused.
  paused('paused'),

  /// Media is actively playing.
  playing('playing'),

  /// Unrecognized playback state.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const PlaybackState(this.value);

  /// Parses a raw API [v] string to a [PlaybackState].
  ///
  /// Returns `null` if [v] is null, or [unknown] if the value is unrecognized.
  static PlaybackState? fromString(String? v) {
    if (v == null) return null;
    return PlaybackState.values.firstWhere(
      (e) => e.value == v,
      orElse: () => PlaybackState.unknown,
    );
  }
}
