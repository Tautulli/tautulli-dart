/// The watched completion status of a history entry.
///
/// Derived from the fractional `watched_status` value in the API response.
enum WatchedStatus {
  /// Less than 25% watched.
  empty,

  /// At least 25% but less than 50% watched.
  quarter,

  /// At least 50% but less than 75% watched.
  half,

  /// At least 75% but less than 100% watched.
  threeQuarter,

  /// Fully watched (100%).
  full,
}
