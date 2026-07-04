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

  group('LibraryService.getLibrariesTable()', () {
    test('sends correct cmd', () async {
      makeClient('library/get_libraries_table.json');
      await client.libraries.getLibrariesTable();
      expect(lastRequestUri.queryParameters['cmd'], 'get_libraries_table');
    });

    test('parses paged result', () async {
      makeClient('library/get_libraries_table.json');
      final result = await client.libraries.getLibrariesTable();
      expect(result.recordsTotal, 27);
      expect(result.data, hasLength(15));
      expect(result.data.first.sectionName, 'TV Shows');
      expect(result.data.first.sectionType, SectionType.show);
      expect(result.data.first.plays, 52777);
    });
  });

  group('LibraryService.getLibraryMediaInfo()', () {
    test('sends correct cmd and required param', () async {
      makeClient('library/get_library_media_info.json');
      await client.libraries.getLibraryMediaInfo(sectionId: 1);
      expect(lastRequestUri.queryParameters['cmd'], 'get_library_media_info');
      expect(lastRequestUri.queryParameters['section_id'], '1');
    });

    test('parses paged result', () async {
      makeClient('library/get_library_media_info.json');
      final result = await client.libraries.getLibraryMediaInfo(sectionId: 1);
      expect(result.recordsTotal, 4);
      expect(result.data.first.title, 'Rogue One: A Star Wars Story');
      expect(result.data.first.playCount, isNull);
    });

    test('parses media info fields', () async {
      makeClient('library/get_library_media_info.json');
      final item = (await client.libraries.getLibraryMediaInfo(
        sectionId: 1,
      )).data.first;
      expect(item.bitrate, 22964);
      expect(item.container, 'mkv');
      expect(item.videoCodec, 'hevc');
      expect(item.videoResolution, '4k');
      expect(item.audioCodec, 'truehd');
      expect(item.audioChannels, 8);
      expect(item.fileSize, 23049233562);
    });
  });

  group('LibraryService.getLibraryUserStats()', () {
    test('sends correct cmd', () async {
      makeClient('library/get_library_user_stats.json');
      await client.libraries.getLibraryUserStats(sectionId: 1);
      expect(lastRequestUri.queryParameters['cmd'], 'get_library_user_stats');
      expect(lastRequestUri.queryParameters['section_id'], '1');
    });

    test('parses user stat list', () async {
      makeClient('library/get_library_user_stats.json');
      final result = await client.libraries.getLibraryUserStats(sectionId: 1);
      expect(result, hasLength(1));
      expect(result.first.friendlyName, 'user25');
      expect(result.first.totalPlays, 4);
    });
  });

  group('LibraryService.getLibraryWatchTimeStats()', () {
    test('sends correct cmd', () async {
      makeClient('library/get_library_watch_time_stats.json');
      await client.libraries.getLibraryWatchTimeStats(sectionId: 1);
      expect(
        lastRequestUri.queryParameters['cmd'],
        'get_library_watch_time_stats',
      );
    });

    test('parses watch time stat list', () async {
      makeClient('library/get_library_watch_time_stats.json');
      final result = await client.libraries.getLibraryWatchTimeStats(
        sectionId: 1,
      );
      expect(result, hasLength(4));
      expect(result.first.queryDays, 1);
      expect(result.last.queryDays, 0);
    });

    test('sends query_days param', () async {
      makeClient('library/get_library_watch_time_stats.json');
      await client.libraries.getLibraryWatchTimeStats(
        sectionId: 1,
        queryDays: '1,7,30',
      );
      expect(lastRequestUri.queryParameters['query_days'], '1,7,30');
    });
  });

  group('LibraryService.getRecentlyAdded()', () {
    test('sends correct cmd and count param', () async {
      makeClient('library/get_recently_added.json');
      await client.libraries.getRecentlyAdded(count: 10);
      expect(lastRequestUri.queryParameters['cmd'], 'get_recently_added');
      expect(lastRequestUri.queryParameters['count'], '10');
    });

    test('parses recently added list', () async {
      makeClient('library/get_recently_added.json');
      final result = await client.libraries.getRecentlyAdded(count: 10);
      expect(result, hasLength(5));
      expect(result.first.title, 'FROM');
      expect(result.first.mediaType, MediaType.show);
      expect(result.first.genres, contains('Mystery'));
    });
  });

  group('LibraryService.getLibraries()', () {
    test('sends correct cmd and parses list', () async {
      makeClient('library/get_libraries.json');
      final result = await client.libraries.getLibraries();
      expect(lastRequestUri.queryParameters['cmd'], 'get_libraries');
      expect(result, hasLength(15));
      expect(result.first.sectionName, '4K Movies');
      // API returns numeric fields as strings; Cast.castToInt coerces them
      expect(result.first.sectionId, 24);
      expect(result.first.count, 4);
      expect(result.first.childCount, isNull);
      expect(result.first.isActive, true);
      expect(result.first.art, isNotNull);
      expect(result.first.thumb, isNotNull);
    });
  });

  group('LibraryService.getLibrary()', () {
    test('sends correct cmd with section_id', () async {
      makeClient('library/get_library.json');
      final result = await client.libraries.getLibrary(sectionId: 24);
      expect(lastRequestUri.queryParameters['cmd'], 'get_library');
      expect(lastRequestUri.queryParameters['section_id'], '24');
      expect(result.sectionName, '4K Movies');
    });

    test('parses extended fields from API reference', () async {
      makeClient('library/get_library.json');
      final result = await client.libraries.getLibrary(sectionId: 24);
      expect(result.count, 4);
      expect(result.rowId, 20);
      expect(result.doNotify, true);
      expect(result.doNotifyCreated, true);
      expect(result.keepHistory, true);
      expect(result.isActive, true);
      expect(result.deletedSection, false);
      expect(result.libraryArt, '');
      expect(result.libraryThumb, 'interfaces/default/images/cover.png');
      expect(result.serverId, isNotNull);
    });

    test('sends include_last_accessed param', () async {
      makeClient('library/get_library.json');
      await client.libraries.getLibrary(
        sectionId: 1,
        includeLastAccessed: true,
      );
      expect(lastRequestUri.queryParameters['include_last_accessed'], '1');
    });
  });

  group('LibraryService.getLibraryNames()', () {
    test('sends correct cmd and parses names', () async {
      makeClient('library/get_library_names.json');
      final result = await client.libraries.getLibraryNames();
      expect(lastRequestUri.queryParameters['cmd'], 'get_library_names');
      expect(result, hasLength(15));
      expect(result.first.sectionName, 'Documentaries');
      expect(result.first.sectionType, 'movie');
    });
  });

  group('LibraryService.editLibrary()', () {
    test('sends all fields with bools as 1/0', () async {
      makeClient('success_response.json');
      await client.libraries.editLibrary(
        sectionId: 3,
        customThumb: '',
        customArt: '',
        keepHistory: true,
        doNotify: false,
        doNotifyCreated: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'edit_library');
      expect(q['section_id'], '3');
      expect(q['custom_thumb'], '');
      expect(q['custom_art'], '');
      expect(q['keep_history'], '1');
      expect(q['do_notify'], '0');
      expect(q['do_notify_created'], '1');
    });
  });

  group('LibraryService.deleteLibrary()', () {
    test('sends server_id and section_id (not section_name)', () async {
      makeClient('success_response.json');
      await client.libraries.deleteLibrary(serverId: 'srv-abc', sectionId: 3);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_library');
      expect(q['server_id'], 'srv-abc');
      expect(q['section_id'], '3');
      expect(q.containsKey('section_name'), isFalse);
    });
  });

  group('LibraryService.deleteAllLibraryHistory()', () {
    test('sends server_id, section_id and optional row_ids', () async {
      makeClient('success_response.json');
      await client.libraries.deleteAllLibraryHistory(
        serverId: 'srv-abc',
        sectionId: 3,
        rowIds: [5, 6],
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_all_library_history');
      expect(q['server_id'], 'srv-abc');
      expect(q['section_id'], '3');
      expect(q['row_ids'], '5,6');
      expect(q.containsKey('section_name'), isFalse);
    });
  });

  group('LibraryService.getPlaylistsTable() userId', () {
    test('sends user_id', () async {
      makeClient('library/get_playlists_table.json');
      await client.libraries.getPlaylistsTable(userId: 5);
      expect(lastRequestUri.queryParameters['user_id'], '5');
    });
  });
}
