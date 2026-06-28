import 'package:http/http.dart' as http;
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
        return http.Response(fixture(fixtureFile), 200);
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
      expect(data.categories, hasLength(3));
      expect(data.categories.first, '2024-01-01');
      expect(data.series, hasLength(4));
      expect(data.series.first.seriesType, GraphSeriesType.movies);
      expect(data.series.first.data, [2, 4, 1]);
      expect(data.series[1].seriesType, GraphSeriesType.tv);
      expect(data.series[1].data, [5, 3, 8]);
    });
  });

  group('GraphService.getConcurrentStreamsByStreamType()', () {
    test('sends correct cmd', () async {
      makeClient('graph/get_concurrent_streams.json');
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
