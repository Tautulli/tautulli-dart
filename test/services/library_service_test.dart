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
      expect(result.data, hasLength(14));
      expect(result.data.first.sectionName, 'TV Shows');
      expect(result.data.first.sectionType, SectionType.show);
      expect(result.data.first.plays, 46957);
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
      expect(item.bitrate, 22942);
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
      expect(result.first.title, 'Timber');
      expect(result.first.mediaType, MediaType.episode);
      // This capture's rows are episodes and one movie (no season row); row
      // 0 (Timber) has an empty genres list and no directors. Row 2, another
      // episode, still exercises the non-empty string-list parsing path for
      // directors.
      expect(result.first.genres, isEmpty);
      expect(result[2].directors, contains('Geeta Patel'));
      // Plex sends milliseconds: 2369088 is row 1's duration.
      expect(result[1].duration, const Duration(milliseconds: 2369088));
      expect(result[1].contentRating, 'TV-MA');
      expect(result[1].collections, isEmpty);
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
      expect(result, hasLength(14));
      expect(result.first.sectionName, 'Documentaries');
      expect(result.first.sectionType, 'movie');
    });
  });

  group('LibraryService.editLibrary()', () {
    test('sends provided fields with bools as 1/0', () async {
      makeClient('success_response.json');
      await client.libraries.editLibrary(
        sectionId: 3,
        customThumb: '',
        customArt: '',
        keepHistory: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'edit_library');
      expect(q['section_id'], '3');
      expect(q['custom_thumb'], '');
      expect(q['custom_art'], '');
      expect(q['keep_history'], '1');
    });

    test('omits unset fields (partial update)', () async {
      makeClient('success_response.json');
      await client.libraries.editLibrary(sectionId: 3, keepHistory: false);
      final q = lastRequestUri.queryParameters;
      expect(q['keep_history'], '0');
      expect(q.containsKey('custom_thumb'), isFalse);
      expect(q.containsKey('custom_art'), isFalse);
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
      expect(lastRequestUri.queryParameters['cmd'], 'get_playlists_table');
      expect(lastRequestUri.queryParameters['user_id'], '5');
    });
  });

  group('LibraryService.getCollectionsTable()', () {
    test('sends correct cmd and parses paged result', () async {
      makeClient('library/get_collections_table.json');
      final result = await client.libraries.getCollectionsTable();
      expect(lastRequestUri.queryParameters['cmd'], 'get_collections_table');
      // This capture's server has no collections configured for Tautulli to
      // track: the fixture's data array is genuinely empty (recordsTotal
      // and recordsFiltered are both 0), not a partial capture.
      expect(result.recordsTotal, 0);
      expect(result.recordsFiltered, 0);
      expect(result.data, isEmpty);
    });
  });

  group('LibraryService.deleteRecentlyAdded()', () {
    test('sends correct cmd', () async {
      makeClient('success_response.json');
      await client.libraries.deleteRecentlyAdded();
      expect(lastRequestUri.queryParameters['cmd'], 'delete_recently_added');
    });
  });

  group('LibraryService.refreshLibrariesList()', () {
    test('sends correct cmd', () async {
      makeClient('library/refresh_libraries_list.json');
      await client.libraries.refreshLibrariesList();
      expect(lastRequestUri.queryParameters['cmd'], 'refresh_libraries_list');
    });
  });

  group('LibraryService.undeleteLibrary()', () {
    test('sends section_id and section_name', () async {
      makeClient('success_response.json');
      await client.libraries.undeleteLibrary(
        sectionId: 3,
        sectionName: 'Movies',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'undelete_library');
      expect(q['section_id'], '3');
      expect(q['section_name'], 'Movies');
    });
  });

  group('LibraryService.deleteMediaInfoCache()', () {
    test('sends section_id', () async {
      makeClient('success_response.json');
      await client.libraries.deleteMediaInfoCache(sectionId: 3);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'delete_media_info_cache');
      expect(q['section_id'], '3');
    });
  });
}
