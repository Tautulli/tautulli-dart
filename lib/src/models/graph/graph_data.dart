import '../../types/graph_series_type.dart';
import '../../utils/cast.dart';

/// Graph data returned by play/stream-count graph endpoints.
///
/// Contains the x-axis [categories] (labels) and one or more [series]
/// of data points.
class GraphData {
  /// X-axis labels for the graph (dates, days of week, platforms, etc.).
  final List<String> categories;

  /// The data series, one per stream type or dimension.
  final List<GraphSeries> series;

  const GraphData({required this.categories, required this.series});

  /// Parses [GraphData] from a Tautulli API JSON map.
  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      categories: (json['categories'] as List? ?? []).map((e) => e.toString()).toList(),
      series: (json['series'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GraphSeries.fromJson)
          .toList(),
    );
  }
}

/// A single data series within a [GraphData] response.
class GraphSeries {
  /// The type/label of this series (e.g. direct play, transcode, TV).
  final GraphSeriesType seriesType;

  /// The numeric data points, aligned with [GraphData.categories].
  final List<int> data;

  const GraphSeries({required this.seriesType, required this.data});

  /// Parses a [GraphSeries] from a Tautulli API JSON map.
  factory GraphSeries.fromJson(Map<String, dynamic> json) {
    return GraphSeries(
      seriesType: GraphSeriesType.fromString(Cast.castToString(json['name'])),
      data: Cast.castToIntList(json['data'] as List? ?? []),
    );
  }
}
