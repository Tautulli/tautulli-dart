/// The type of a Plex library section.
enum SectionType {
  /// Music library.
  artist('artist'),

  /// Movie library.
  movie('movie'),

  /// Photo library.
  photo('photo'),

  /// TV show library.
  show('show'),

  /// Unrecognized section type.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const SectionType(this.value);

  /// Parses a raw API [v] string to a [SectionType].
  ///
  /// Returns `null` if [v] is null, or [unknown] if the value is unrecognized.
  static SectionType? fromString(String? v) {
    if (v == null) return null;
    return SectionType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => SectionType.unknown,
    );
  }
}
