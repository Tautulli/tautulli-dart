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

  group('HistoryService.getHistory()', () {
    test('sends correct cmd', () async {
      makeClient('history/get_history.json');
      await client.history.getHistory();
      expect(lastRequestUri.queryParameters['cmd'], 'get_history');
    });

    test('parses paged result', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      expect(result.recordsTotal, 82489);
      expect(result.recordsFiltered, 64884);
      expect(result.data, hasLength(10));
      final first = result.data.first;
      expect(first.title, 'Episode 31');
      expect(first.fullTitle, 'Love Island - Episode 31');
      expect(first.mediaType, MediaType.episode);
      expect(first.rowId, 83192);
      expect(first.transcodeDecision, StreamDecision.directPlay);
      expect(first.location, Location.wan);
      expect(first.live, isFalse);
      expect(first.secure, isTrue);
    });

    test('parses watched_status thresholds', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      expect(result.data.first.watchedStatus, WatchedStatus.quarter);
      expect(result.data.last.watchedStatus, WatchedStatus.full);
    });

    test('parses dates from epoch seconds as UTC', () async {
      makeClient('history/get_history.json');
      final result = await client.history.getHistory();
      final date = result.data.first.date;
      expect(date, isA<DateTime>());
      expect(date!.isUtc, isTrue);
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
      expect(result, hasLength(11));
      final topMovies = result.firstWhere(
        (g) => g.statId == StatIdType.topMovies,
      );
      expect(topMovies.rows, isNotEmpty);
      expect(topMovies.rows.first.title, 'Marty Supreme');
      expect(topMovies.rows.first.totalPlays, 3);
    });

    test('parses a single-stat (bare object) response', () async {
      makeClient('history/get_home_stats__top_movies.json');
      final result = await client.history.getHomeStats(
        statId: StatIdType.topMovies,
      );
      expect(lastRequestUri.queryParameters['stat_id'], 'top_movies');
      expect(result, hasLength(1));
      expect(result.first.statId, StatIdType.topMovies);
      expect(result.first.rows, hasLength(10));
    });

    test('parses new metadata fields', () async {
      makeClient('history/get_home_stats__top_movies.json');
      final row = (await client.history.getHomeStats()).first.rows.first;
      expect(row.guid, 'plex://movie/669748dc85be974cd2ab194c');
      expect(row.contentRating, 'R');
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

  group('HistoryService.deleteHistory()', () {
    test('sends row_ids as a comma-separated list only', () async {
      makeClient('success_response.json');
      await client.history.deleteHistory(rowIds: [65, 110, 2]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_history');
      expect(q['row_ids'], '65,110,2');
      expect(q.containsKey('user_id'), isFalse);
      expect(q.containsKey('section_id'), isFalse);
      expect(q.containsKey('rating_key'), isFalse);
    });
  });
}
