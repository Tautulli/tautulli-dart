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
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_date');
      expect(lastRequestUri.queryParameters['y_axis'], 'plays');
      expect(lastRequestUri.queryParameters['time_range'], '30');
    });

    test('parses categories and series', () async {
      makeClient('graph/get_plays_by_date.json');
      final data = await client.graphs.getPlaysByDate(
        yAxis: PlayMetricType.plays,
        timeRange: 30,
      );
      expect(data.categories, hasLength(30));
      expect(data.categories.first, '2026-06-05');
      expect(data.series, hasLength(4));
      expect(data.series.first.seriesType, GraphSeriesType.tv);
      expect(data.series.first.data, hasLength(30));
      expect(data.series.first.data.take(3), [37, 33, 25]);
      expect(data.series[1].seriesType, GraphSeriesType.movies);
      expect(data.series[1].data.take(3), [3, 4, 2]);
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
      makeClient('graph/get_plays_by_date.json');
      await client.graphs.getPlaysByDayOfWeek(
        yAxis: PlayMetricType.time,
        timeRange: 30,
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_plays_by_dayofweek');
      expect(lastRequestUri.queryParameters['y_axis'], 'duration');
    });
  });
}
