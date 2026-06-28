/// Identifies a specific home-stats group returned by `get_home_stats`.
enum StatIdType {
  /// Most recently watched items.
  lastWatched('last_watched'),

  /// Peak concurrent stream count.
  mostConcurrent('most_concurrent'),

  /// Most popular movies.
  popularMovies('popular_movies'),

  /// Most popular music.
  popularMusic('popular_music'),

  /// Most popular TV shows.
  popularTv('popular_tv'),

  /// Most-played library sections.
  topLibraries('top_libraries'),

  /// Top movies by play count or duration.
  topMovies('top_movies'),

  /// Top music by play count or duration.
  topMusic('top_music'),

  /// Top client platforms by play count or duration.
  topPlatforms('top_platforms'),

  /// Top TV shows by play count or duration.
  topTv('top_tv'),

  /// Top users by play count or duration.
  topUsers('top_users'),

  /// Unrecognized stat ID.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API `stat_id` field.
  final String value;
  const StatIdType(this.value);

  /// Parses a raw API [v] string to a [StatIdType].
  ///
  /// Returns [unknown] if [v] is null or does not match any known value.
  static StatIdType fromString(String? v) {
    if (v == null) return StatIdType.unknown;
    return StatIdType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => StatIdType.unknown,
    );
  }
}
