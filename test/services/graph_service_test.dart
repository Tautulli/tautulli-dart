import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tautulli/tautulli.dart';

import '../helpers/fixture_reader.dart';

void main() {
  late TautulliClient client;
  late Uri lastRequestUri;

  void makeClient(String fixtureFile) {
    client = TautulliClient(
      connection: const TautulliConnection(
        protocol: 'http',
        domain: 'tautulli.local',
        apiKey: 'abc123',
      ),
      httpClient: MockClient((request) async {
        lastRequestUri = request.url;
        return fixtureResponse(fixtureFile);
      }),
    );
  }

  group('GraphService.getPlaysByDate()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_date.json');
      await client.graphs.getPlaysByDate(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_date');
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_date.json');
      final data = await client.graphs.getPlaysByDate(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(30));
      expect(data.categories.first, '2026-08-05');
      expect(data.series, hasLength(4));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data, hasLength(30));
      expect(data.series.first.data.take(3), [35, 34, 42]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [2, 2, 2]);
    });
  });

  group('GraphService.getConcurrentStreamsByStreamType()', () {
    test('sends correct cmd', () async {
      makeClient('graph/get_concurrent_streams_by_stream_type.json');
      await client.graphs.getConcurrentStreamsByStreamType(timeRange: 14);
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_concurrent_streams_by_stream_type',
      );
      expect(lastRequestUri.queryParameters['time_range'], '14');
    });
  });

  group('GraphService.getPlaysByDayOfWeek()', () {
    test('sends correct cmd', () async {
      makeClient('graph/get_plays_by_dayofweek.json');
      await client.graphs.getPlaysByDayOfWeek(
        yAxis: PlayMetricType.time,
        timeRange: 30,
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_dayofweek');
      expect(lastRequestUri.queryParameters['y_axis'], 'duration');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_dayofweek.json');
      final data = await client.graphs.getPlaysByDayOfWeek(
        yAxis: PlayMetricType.time,
        timeRange: 30,
      );
      expect(data.categories, hasLength(7));
      expect(data.categories.first, 'Sunday');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data.take(3), [133, 123, 124]);
      expect(
        data.series.any((s) => s.seriesType == GraphSeriesType.total),
        isFalse,
      );
    });
  });

  group('GraphService.getPlaysByHourOfDay()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_hourofday.json');
      await client.graphs.getPlaysByHourOfDay(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_hourofday');
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_hourofday.json');
      final data = await client.graphs.getPlaysByHourOfDay(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(24));
      expect(data.categories.first, '00');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data.take(3), [21, 12, 4]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [4, 2, 1]);
    });
  });

  group('GraphService.getPlaysBySourceResolution()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_source_resolution.json');
      await client.graphs.getPlaysBySourceResolution(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_plays_by_source_resolution',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_source_resolution.json');
      final data = await client.graphs.getPlaysBySourceResolution(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(3));
      expect(data.categories, ['1080p', '720p', '480p']);
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.directPlay);
      expect(data.series.first.data, [655, 32, 1]);
      expect(data.series[2].seriesType, GraphSeriesType.transcode);
      expect(data.series[2].data, [258, 2, 0]);
    });
  });

  group('GraphService.getPlaysByStreamResolution()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_stream_resolution.json');
      await client.graphs.getPlaysByStreamResolution(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_plays_by_stream_resolution',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_stream_resolution.json');
      final data = await client.graphs.getPlaysByStreamResolution(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(4));
      expect(data.categories, ['1080p', '720p', 'SD', '480p']);
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.directPlay);
      expect(data.series.first.data, [655, 32, 0, 1]);
      expect(data.series[2].seriesType, GraphSeriesType.transcode);
      expect(data.series[2].data, [231, 1, 25, 3]);
    });
  });

  group('GraphService.getPlaysByStreamType()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_stream_type.json');
      await client.graphs.getPlaysByStreamType(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_stream_type');
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_stream_type.json');
      final data = await client.graphs.getPlaysByStreamType(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(30));
      expect(data.categories.first, '2026-08-05');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.directPlay);
      expect(data.series.first.data.take(3), [28, 31, 27]);
      expect(data.series[2].seriesType, GraphSeriesType.transcode);
      expect(data.series[2].data.take(3), [9, 5, 16]);
    });
  });

  group('GraphService.getPlaysByTop10Platforms()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_top_10_platforms.json');
      await client.graphs.getPlaysByTop10Platforms(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_plays_by_top_10_platforms',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_top_10_platforms.json');
      final data = await client.graphs.getPlaysByTop10Platforms(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(9));
      expect(data.categories.first, 'Android');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data.take(3), [551, 121, 74]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [14, 11, 12]);
    });
  });

  group('GraphService.getPlaysByTop10Users()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_by_top_10_users.json');
      await client.graphs.getPlaysByTop10Users(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_plays_by_top_10_users',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_top_10_users.json');
      final data = await client.graphs.getPlaysByTop10Users(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(10));
      expect(data.categories.first, 'user25');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data.take(3), [476, 101, 81]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [12, 12, 2]);
    });
  });

  group('GraphService.getPlaysByMonth()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_plays_per_month.json');
      await client.graphs.getPlaysByMonth(
        yAxis: PlayMetricType.plays,
        timeRange: 12,
        userIds: [1, 2],
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_per_month');
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '12');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_per_month.json');
      final data = await client.graphs.getPlaysByMonth(
        yAxis: PlayMetricType.plays,
        timeRange: 12,
      );
      expect(data.categories, hasLength(12));
      expect(data.categories.first, 'Oct 2025');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data.take(3), [1291, 1123, 1005]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [43, 63, 60]);
    });
  });

  group('GraphService.getStreamTypeByTop10Platforms()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_stream_type_by_top_10_platforms.json');
      await client.graphs.getStreamTypeByTop10Platforms(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_stream_type_by_top_10_platforms',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_stream_type_by_top_10_platforms.json');
      final data = await client.graphs.getStreamTypeByTop10Platforms(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(9));
      expect(data.categories.first, 'Android');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.directPlay);
      expect(data.series.first.data.take(3), [535, 2, 80]);
      expect(data.series[2].seriesType, GraphSeriesType.transcode);
      expect(data.series[2].data.take(3), [30, 129, 6]);
    });
  });

  group('GraphService.getStreamTypeByTop10Users()', () {
    test('sends correct cmd and y_axis param', () async {
      makeClient('graph/get_stream_type_by_top_10_users.json');
      await client.graphs.getStreamTypeByTop10Users(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
        userIds: [1, 2],
      );
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_stream_type_by_top_10_users',
      );
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
      expect(lastRequestUri.queryParameters['user_id'], '1,2');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_stream_type_by_top_10_users.json');
      final data = await client.graphs.getStreamTypeByTop10Users(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(10));
      expect(data.categories.first, 'user25');
      expect(data.series, hasLength(3));
      expect(data.series.first.seriesType, GraphSeriesType.directPlay);
      expect(data.series.first.data.take(3), [484, 5, 34]);
      expect(data.series[2].seriesType, GraphSeriesType.transcode);
      expect(data.series[2].data.take(3), [3, 108, 48]);
    });
  });
}
