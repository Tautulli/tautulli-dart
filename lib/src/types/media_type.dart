/// The type of a Plex media item.
enum MediaType {
  /// Music album.
  album('album'),

  /// Music artist.
  artist('artist'),

  /// Short-form video clip.
  clip('clip'),

  /// Plex collection.
  collection('collection'),

  /// TV episode.
  episode('episode'),

  /// Movie.
  movie('movie'),

  /// Other video content that does not fit standard categories.
  otherVideo('other_video'),

  /// Photo.
  photo('photo'),

  /// Photo album.
  photoAlbum('photo_album'),

  /// Plex playlist.
  playlist('playlist'),

  /// TV season.
  season('season'),

  /// TV show.
  show('show'),

  /// Music track.
  track('track'),

  /// Unrecognized media type.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const MediaType(this.value);

  /// Parses a raw API [v] string to a [MediaType].
  ///
  /// Returns [unknown] if [v] is null or does not match any known value.
  static MediaType fromString(String? v) {
    if (v == null) return MediaType.unknown;
    return MediaType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => MediaType.unknown,
    );
  }
}
