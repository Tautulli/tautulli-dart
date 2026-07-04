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
      expect(user.username, 'user27');
      expect(user.friendlyName, 'user26');
      expect(user.isActive, isTrue);
      expect(user.userId, 65059356);
    });

    test('parses shared_libraries list', () async {
      makeClient('user/get_user.json');
      final user = await client.users.getUser(userId: 7);
      expect(user.sharedLibraries, containsAll([28, 30, 6, 13]));
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
      expect(names, hasLength(52));
      expect(names.first.userId, 0);
      expect(names.first.friendlyName, 'user52');
      expect(names.last.friendlyName, 'nina');
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
      expect(stats, hasLength(10));
      expect(stats.first.platform, 'Android');
      expect(stats.first.totalPlays, 13414);
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
      expect(result.recordsTotal, 64);
      expect(result.data, hasLength(25));
      expect(result.data.first.username, 'user105');
      expect(result.data.first.plays, 157);
      expect(result.data.first.historyRowId, 81224);
    });
  });

  group('UserService.getUsers()', () {
    test('sends correct cmd and parses list', () async {
      makeClient('user/get_users.json');
      final result = await client.users.getUsers();
      expect(lastRequestUri.queryParameters['cmd'], 'get_users');
      expect(result, hasLength(52));
      expect(result.first.userId, 0);
      expect(result.first.deletedUser, isNull); // not sent by get_users
    });

    test('sends grouping param', () async {
      makeClient('user/get_users.json');
      await client.users.getUsers(grouping: true);
      expect(lastRequestUri.queryParameters['grouping'], '1');
    });
  });

  group('UserService.editUser()', () {
    test('sends all fields with bools as 1/0', () async {
      makeClient('success_response.json');
      await client.users.editUser(
        userId: 7,
        friendlyName: 'Jon Snow',
        customThumb: '',
        keepHistory: true,
        allowGuest: false,
        doNotify: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'edit_user');
      expect(q['user_id'], '7');
      expect(q['friendly_name'], 'Jon Snow');
      expect(q['custom_thumb'], '');
      expect(q['keep_history'], '1');
      expect(q['allow_guest'], '0');
      expect(q['do_notify'], '1');
    });
  });

  group('UserService.deleteUser()', () {
    test('sends user_id (+ optional row_ids), not username', () async {
      makeClient('success_response.json');
      await client.users.deleteUser(userId: 7, rowIds: [2, 3]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_user');
      expect(q['user_id'], '7');
      expect(q['row_ids'], '2,3');
      expect(q.containsKey('username'), isFalse);
    });
  });
}
