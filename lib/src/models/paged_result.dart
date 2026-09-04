/// Wrapper for paginated Tautulli responses that include total record counts.
class PagedResult<T> {
  /// The items returned for the current page.
  final List<T> data;

  /// Total number of records in the dataset (before filtering).
  final int? recordsTotal;

  /// Total number of records after applying any active search/filter.
  final int? recordsFiltered;

  /// Human-readable total watch time of the whole dataset, such as
  /// `'1643 days 10 hrs 26 mins'`. Sent by `get_history` only; `null` for
  /// every other paged command.
  final String? totalDuration;

  /// Human-readable watch time of the filtered rows, in the same format as
  /// [totalDuration]. Sent by `get_history` only.
  final String? filterDuration;

  const PagedResult({
    required this.data,
    this.recordsTotal,
    this.recordsFiltered,
    this.totalDuration,
    this.filterDuration,
  });
}
