/// Fallback image type passed to the `pms_image_proxy` endpoint.
///
/// When the requested image is unavailable, Tautulli returns a placeholder
/// image matching the specified fallback type.
enum ImageFallback {
  /// Poster-style fallback (portrait artwork).
  poster('poster'),

  /// Cover-style fallback (square/album artwork).
  cover('cover'),

  /// Art/background fallback (landscape backdrop).
  art('art'),

  /// Poster fallback for live TV channels.
  posterLive('poster-live'),

  /// Art fallback for live TV channels.
  artLive('art-live'),

  /// Full-width art fallback for live TV channels.
  artLiveFull('art-live-full'),

  /// User avatar fallback.
  user('user');

  /// The raw string value sent as the `fallback` query parameter.
  final String value;
  const ImageFallback(this.value);
}
