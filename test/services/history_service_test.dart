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

  group('HistoryService.getHistory()', () {
    test('sends correct cmd', () async {
      makeClient('history/get_history.json');
      await client.history.getHistory();
      expect(lastRequestUri.queryParameters['cmd'], 'get_history');
    });

    test('parses paged result', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      expect(result.recordsTotal, 250);
      expect(result.data, hasLength(1));
      expect(result.data.first.title, 'The Matrix');
      expect(result.data.first.mediaType, MediaType.movie);
    });

    test('parses watched_status to WatchedStatus.full', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      expect(result.data.first.watchedStatus, WatchedStatus.full);
    });

    test('parses dates from epoch seconds', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      expect(result.data.first.date, isA<DateTime>());
    });

    test('sends optional params', () async {
      makeClient('history/get_history.json');
      await client.history.getHistory(userId: 7, length: 25, start: 0);
      expect(lastRequestUri.queryParameters['user_id'], '7');
      expect(lastRequestUri.queryParameters['length'], '25');
    });

    test('formats DateTime params as y-MM-dd', () async {
      makeClient('history/get_history.json');
      await client.history.getHistory(after: DateTime(2024, 1, 5));
      expect(lastRequestUri.queryParameters['after'], '2024-01-05');
    });
  });

  group('HistoryService.getHomeStats()', () {
    test('sends correct cmd', () async {
      makeClient('history/get_home_stats.json');
      await client.history.getHomeStats();
      expect(lastRequestUri.queryParameters['cmd'], 'get_home_stats');
    });

    test('parses stat groups', () async {
      makeClient('history/get_home_stats.json');
      final result = await client.history.getHomeStats();
      expect(result, hasLength(1));
      expect(result.first.statId, StatIdType.topMovies);
      expect(result.first.rows, hasLength(1));
      expect(result.first.rows.first.title, 'The Matrix');
      expect(result.first.rows.first.totalPlays, 42);
    });

    test('parses new metadata fields', () async {
      makeClient('history/get_home_stats.json');
      final row = (await client.history.getHomeStats()).first.rows.first;
      expect(row.guid, 'plex://movie/5d776828880197001ec9671c');
      expect(row.contentRating, 'R');
      expect(row.rating, 8.7);
      expect(row.labels, contains('Action'));
      expect(row.live, false);
    });

    test('sends section_id and user_id params', () async {
      makeClient('history/get_home_stats.json');
      await client.history.getHomeStats(sectionId: 1, userId: 7);
      expect(lastRequestUri.queryParameters['section_id'], '1');
      expect(lastRequestUri.queryParameters['user_id'], '7');
    });

    test('sends before and after date params', () async {
      makeClient('history/get_home_stats.json');
      await client.history.getHomeStats(
        before: DateTime(2024, 1, 31),
        after: DateTime(2024, 1, 1),
      );
      expect(lastRequestUri.queryParameters['before'], '2024-01-31');
      expect(lastRequestUri.queryParameters['after'], '2024-01-01');
    });
  });
}
