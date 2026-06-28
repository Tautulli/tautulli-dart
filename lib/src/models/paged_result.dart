/// Wrapper for paginated Tautulli responses that include total record counts.
class PagedResult<T> {
  /// The items returned for the current page.
  final List<T> data;

  /// Total number of records in the dataset (before filtering).
  final int? recordsTotal;

  /// Total number of records after applying any active search/filter.
  final int? recordsFiltered;

  const PagedResult({
    required this.data,
    this.recordsTotal,
    this.recordsFiltered,
  });
}
