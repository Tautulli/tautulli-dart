/// Network location of a Plex client relative to the Plex Media Server.
enum Location {
  /// Client is on the same local network as the server.
  lan('lan'),

  /// Client is connecting over the internet.
  wan('wan'),

  /// Client is on a cellular data connection.
  cellular('cellular'),

  /// Location could not be determined.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const Location(this.value);

  /// Parses a raw API [v] string to a [Location].
  ///
  /// Returns [unknown] if [v] is null or does not match any known value.
  static Location fromString(String? v) {
    if (v == null) return Location.unknown;
    return Location.values.firstWhere(
      (e) => e.value == v,
      orElse: () => Location.unknown,
    );
  }
}
