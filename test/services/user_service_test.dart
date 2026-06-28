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

  group('UserService.getUser()', () {
    test('sends correct cmd and user_id', () async {
      makeClient('user/get_user.json');
      await client.users.getUser(userId: 7);
      expect(lastRequestUri.queryParameters['cmd'], 'get_user');
      expect(lastRequestUri.queryParameters['user_id'], '7');
    });

    test('parses user data', () async {
      makeClient('user/get_user.json');
      final user = await client.users.getUser(userId: 7);
      expect(user.username, 'johndoe');
      expect(user.friendlyName, 'JohnDoe');
      expect(user.isActive, isTrue);
      expect(user.userId, 7);
    });

    test('parses shared_libraries list', () async {
      makeClient('user/get_user.json');
      final user = await client.users.getUser(userId: 7);
      expect(user.sharedLibraries, containsAll([1, 2, 3]));
    });
  });

  group('UserService.getUserNames()', () {
    test('sends correct cmd', () async {
      makeClient('user/get_user_names.json');
      await client.users.getUserNames();
      expect(lastRequestUri.queryParameters['cmd'], 'get_user_names');
    });

    test('parses user name list', () async {
      makeClient('user/get_user_names.json');
      final names = await client.users.getUserNames();
      expect(names, hasLength(2));
      expect(names.first.username, 'admin');
      expect(names.last.friendlyName, 'JohnDoe');
    });
  });

  group('UserService.getUserPlayerStats()', () {
    test('sends correct cmd and user_id', () async {
      makeClient('user/get_user_player_stats.json');
      await client.users.getUserPlayerStats(userId: 7);
      expect(lastRequestUri.queryParameters['cmd'], 'get_user_player_stats');
      expect(lastRequestUri.queryParameters['user_id'], '7');
    });

    test('parses player stats', () async {
      makeClient('user/get_user_player_stats.json');
      final stats = await client.users.getUserPlayerStats(userId: 7);
      expect(stats, hasLength(1));
      expect(stats.first.platform, 'Linux');
      expect(stats.first.totalPlays, 120);
    });
  });

  group('UserService.getUserWatchTimeStats()', () {
    test('sends correct cmd', () async {
      makeClient('user/get_user_watch_time_stats.json');
      await client.users.getUserWatchTimeStats(userId: 7);
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_user_watch_time_stats',
      );
    });

    test('parses watch time stats', () async {
      makeClient('user/get_user_watch_time_stats.json');
      final stats = await client.users.getUserWatchTimeStats(userId: 7);
      expect(stats, hasLength(4));
      expect(stats.first.queryDays, 1);
      expect(stats[2].totalPlays, 45);
      expect(stats.last.queryDays, 0);
    });

    test('sends query_days param', () async {
      makeClient('user/get_user_watch_time_stats.json');
      await client.users.getUserWatchTimeStats(userId: 7, queryDays: '1,7,30');
      expect(lastRequestUri.queryParameters['query_days'], '1,7,30');
    });
  });

  group('UserService.getUsersTable()', () {
    test('sends correct cmd', () async {
      makeClient('user/get_users_table.json');
      await client.users.getUsersTable();
      expect(lastRequestUri.queryParameters['cmd'], 'get_users_table');
    });

    test('parses paged result', () async {
      makeClient('user/get_users_table.json');
      final result = await client.users.getUsersTable();
      expect(result.recordsTotal, 5);
      expect(result.data, hasLength(1));
      expect(result.data.first.username, 'johndoe');
      expect(result.data.first.plays, 42);
    });

    test('parses admin and permission fields', () async {
      makeClient('user/get_users_table.json');
      final entry = (await client.users.getUsersTable()).data.first;
      expect(entry.isAdmin, false);
      expect(entry.isAllowSync, true);
      expect(entry.isHomeUser, true);
      expect(entry.isRestricted, false);
      expect(entry.deletedUser, false);
      expect(entry.sharedLibraries, [1, 2]);
    });
  });

  group('UserService.getUsers()', () {
    test('sends correct cmd and parses list', () async {
      makeClient('user/get_users.json');
      final result = await client.users.getUsers();
      expect(lastRequestUri.queryParameters['cmd'], 'get_users');
      expect(result, hasLength(1));
      expect(result.first.userId, 5);
      expect(result.first.deletedUser, false);
    });

    test('sends grouping param', () async {
      makeClient('user/get_users.json');
      await client.users.getUsers(grouping: true);
      expect(lastRequestUri.queryParameters['grouping'], 'true');
    });
  });
}
