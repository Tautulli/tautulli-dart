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

  group('MediaService.getMetadata()', () {
    test('sends correct cmd and rating_key', () async {
      makeClient('media/get_metadata.json');
      await client.media.getMetadata(ratingKey: 1001);
      expect(lastRequestUri.queryParameters['cmd'], 'get_metadata');
      expect(lastRequestUri.queryParameters['rating_key'], '1001');
    });

    test('parses metadata fields', () async {
      makeClient('media/get_metadata.json');
      final item = await client.media.getMetadata(ratingKey: 1001);
      expect(item.title, 'The American President');
      expect(item.mediaType, MediaType.movie);
      expect(item.year, 1995);
      expect(item.rating, closeTo(9.0, 0.01));
    });

    test('parses nested media_info', () async {
      makeClient('media/get_metadata.json');
      final item = await client.media.getMetadata(ratingKey: 1001);
      expect(item.mediaInfo, isNotNull);
      expect(item.mediaInfo!.videoCodec, 'hevc');
      expect(item.mediaInfo!.audioChannels, 6);
    });

    test('parses string lists', () async {
      makeClient('media/get_metadata.json');
      final item = await client.media.getMetadata(ratingKey: 1001);
      expect(item.genres, contains('Comedy'));
      expect(item.actors, contains('Michael Douglas'));
    });
  });

  group('MediaService.getChildrenMetadata()', () {
    test('sends correct cmd', () async {
      makeClient('media/get_children_metadata.json');
      await client.media.getChildrenMetadata(
        ratingKey: 2000,
        mediaType: 'show',
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_children_metadata');
      expect(lastRequestUri.queryParameters['rating_key'], '2000');
      expect(lastRequestUri.queryParameters['media_type'], 'show');
    });

    test('parses children list', () async {
      makeClient('media/get_children_metadata.json');
      final items = await client.media.getChildrenMetadata(
        ratingKey: 2000,
        mediaType: 'show',
      );
      expect(items, hasLength(32));
      expect(items.first.title, 'Episode 1');
      expect(items.first.mediaType, MediaType.episode);
      expect(items.first.mediaIndex, 1);
    });
  });

  group('MediaService.getNewRatingKeys()', () {
    test('sends correct cmd with rating_key and media_type', () async {
      makeClient('media/get_new_rating_keys.json');
      final result = await client.media.getNewRatingKeys(
        ratingKey: 1001,
        mediaType: 'movie',
      );
      expect(lastRequestUri.queryParameters['cmd'], 'get_new_rating_keys');
      expect(lastRequestUri.queryParameters['rating_key'], '1001');
      expect(lastRequestUri.queryParameters['media_type'], 'movie');
      expect(result, isNotEmpty);
    });
  });

  group('MediaService.search()', () {
    test('sends correct cmd with query', () async {
      makeClient('media/search.json');
      final result = await client.media.search(query: 'inception');
      expect(lastRequestUri.queryParameters['cmd'], 'search');
      expect(lastRequestUri.queryParameters['query'], 'inception');
      expect(result, isNotEmpty);
    });
  });

  group('MediaService.search() PMS-failure shape', () {
    test('returns an empty map when the server sends a bare list', () async {
      // Captured live: omitting `limit` (or any upstream PMS search failure)
      // makes the server return `data: []` instead of the results object.
      makeClient('media/search__no_limit_empty_list.json');
      final result = await client.media.search(query: 'anything');
      expect(result, isEmpty);
    });
  });

  group('MediaService new params', () {
    test('getMetadata sends sync_id', () async {
      makeClient('media/get_metadata.json');
      await client.media.getMetadata(ratingKey: 1, syncId: 9);
      expect(lastRequestUri.queryParameters['sync_id'], '9');
    });

    test('deleteLookupInfo sends delete_all', () async {
      makeClient('success_response.json');
      await client.media.deleteLookupInfo(
        ratingKey: 1,
        service: 'themoviedb',
        deleteAll: true,
      );
      expect(lastRequestUri.queryParameters['delete_all'], '1');
    });
  });
}
