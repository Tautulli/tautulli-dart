/// The type of a data series in a Tautulli graph response.
///
/// Maps the `name` field returned in each series object by graph endpoints.
enum GraphSeriesType {
  /// TV show plays.
  tv('tv'),

  /// Movie plays.
  movies('movies'),

  /// Music plays.
  music('music'),

  /// Live TV plays.
  live('live tv'),

  /// Direct play (no transcoding) streams.
  directPlay('direct play'),

  /// Direct stream (container remux only) streams.
  directStream('direct stream'),

  /// Transcoded streams.
  transcode('transcode'),

  /// Maximum concurrent streams.
  concurrent('max. concurrent streams'),

  /// Total count across all stream types.
  total('total'),

  /// Unrecognized series type.
  unknown('unknown');

  /// The raw string value as returned by the Tautulli API.
  final String value;
  const GraphSeriesType(this.value);

  /// Parses a raw API [v] string to a [GraphSeriesType].
  ///
  /// Returns [unknown] if [v] is null or does not match any known value.
  static GraphSeriesType fromString(String? v) {
    if (v == null) return GraphSeriesType.unknown;
    return GraphSeriesType.values.firstWhere(
      (e) => e.value == v.toLowerCase(),
      orElse: () => GraphSeriesType.unknown,
    );
  }
}
