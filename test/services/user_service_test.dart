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
      expect(user.username, 'user80');
      expect(user.friendlyName, 'jack');
      expect(user.isActive, isTrue);
      expect(user.userId, 8883082);
    });

    test('parses shared_libraries list', () async {
      makeClient('user/get_user.json');
      final user = await client.users.getUser(userId: 7);
      expect(user.sharedLibraries, containsAll([6, 13, 31, 12]));
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
      expect(names, hasLength(50));
      expect(names.first.userId, 0);
      expect(names.first.friendlyName, 'user50');
      expect(names.last.friendlyName, 'mona');
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
      expect(stats, hasLength(3));
      expect(stats.first.platform, 'Android');
      expect(stats.first.totalPlays, 148);
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
      expect(result.data.first.username, 'user101');
      expect(result.data.first.plays, 160);
      expect(result.data.first.historyRowId, 86264);
      expect(result.data.first.duration, const Duration(seconds: 284654));
    });
  });

  group('UserService.getUsers()', () {
    test('sends correct cmd and parses list', () async {
      makeClient('user/get_users.json');
      final result = await client.users.getUsers();
      expect(lastRequestUri.queryParameters['cmd'], 'get_users');
      expect(result, hasLength(50));
      expect(result.first.userId, 0);
      expect(result.first.deletedUser, isNull); // not sent by get_users
      // get_users sends the avatar as thumb, not user_thumb.
      expect(
        result[1].userThumb,
        'https://plex.tv/users/0000000000000000/avatar?c=1788586179',
      );
    });
  });

  group('UserService.editUser()', () {
    test('sends provided fields with bools as 1/0', () async {
      makeClient('success_response.json');
      await client.users.editUser(
        userId: 7,
        friendlyName: 'Jon Snow',
        customThumb: '',
        keepHistory: true,
        allowGuest: false,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'edit_user');
      expect(q['user_id'], '7');
      expect(q['friendly_name'], 'Jon Snow');
      expect(q['custom_thumb'], '');
      expect(q['keep_history'], '1');
      expect(q['allow_guest'], '0');
    });

    test('omits unset fields (partial update)', () async {
      makeClient('success_response.json');
      await client.users.editUser(userId: 7, friendlyName: 'Jon Snow');
      final q = lastRequestUri.queryParameters;
      expect(q['friendly_name'], 'Jon Snow');
      expect(q.containsKey('custom_thumb'), isFalse);
      expect(q.containsKey('keep_history'), isFalse);
      expect(q.containsKey('allow_guest'), isFalse);
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

  group('UserService.deleteAllUserHistory()', () {
    test('sends user_id and comma-joined row_ids, no username', () async {
      makeClient('success_response.json');
      await client.users.deleteAllUserHistory(userId: 7, rowIds: [2, 3]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_all_user_history');
      expect(q['user_id'], '7');
      expect(q['row_ids'], '2,3');
      expect(q.containsKey('username'), isFalse);
    });
  });

  group('UserService.getUserIps()', () {
    test('sends correct cmd and user_id', () async {
      makeClient('user/get_user_ips.json');
      await client.users.getUserIps(userId: 2535039);
      expect(lastRequestUri.queryParameters['cmd'], 'get_user_ips');
      expect(lastRequestUri.queryParameters['user_id'], '2535039');
    });

    test('parses paged result', () async {
      makeClient('user/get_user_ips.json');
      final result = await client.users.getUserIps(userId: 2535039);
      expect(result.recordsTotal, 74065);
      expect(result.recordsFiltered, 3);
      expect(result.data, hasLength(3));
      expect(result.data.first['ip_address'], '203.0.113.35');
      expect(result.data.first['play_count'], 160);
    });
  });

  group('UserService.getUserLogins()', () {
    test('sends correct cmd', () async {
      makeClient('user/get_user_logins.json');
      await client.users.getUserLogins();
      expect(lastRequestUri.queryParameters['cmd'], 'get_user_logins');
    });

    test('parses paged result', () async {
      makeClient('user/get_user_logins.json');
      final result = await client.users.getUserLogins();
      expect(result.recordsTotal, 210);
      expect(result.recordsFiltered, 210);
      expect(result.data, hasLength(25));
      expect(result.data.first['ip_address'], '192.0.2.12');
      expect(result.data.first['friendly_name'], 'user24');
    });
  });

  group('UserService.undeleteUser()', () {
    test('sends user_id and username', () async {
      makeClient('success_response.json');
      await client.users.undeleteUser(userId: 7, username: 'liam');
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'undelete_user');
      expect(q['user_id'], '7');
      expect(q['username'], 'liam');
    });
  });

  group('UserService.refreshUsersList()', () {
    test('sends correct cmd', () async {
      makeClient('user/refresh_users_list.json');
      await client.users.refreshUsersList();
      expect(lastRequestUri.queryParameters['cmd'], 'refresh_users_list');
    });
  });
}
