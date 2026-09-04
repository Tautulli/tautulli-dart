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
      expect(item.title, 'Aladdin');
      expect(item.mediaType, MediaType.movie);
      expect(item.year, 1992);
      // The captured item has no critic rating (`rating` is `""`); the
      // audience score covers the double coercion.
      expect(item.rating, isNull);
      expect(item.audienceRating, closeTo(8.0, 0.01));
      expect(item.markers, hasLength(1));
      expect(item.markers!.single.type, 'credits');
      expect(
        item.markers!.single.startTimeOffset,
        const Duration(milliseconds: 5159884),
      );
    });

    test('parses nested media_info', () async {
      makeClient('media/get_metadata.json');
      final item = await client.media.getMetadata(ratingKey: 1001);
      expect(item.mediaInfo, isNotNull);
      expect(item.mediaInfo!.videoCodec, 'h264');
      expect(item.mediaInfo!.audioChannels, 6);
    });

    test('parses string lists', () async {
      makeClient('media/get_metadata.json');
      final item = await client.media.getMetadata(ratingKey: 1001);
      expect(item.genres, contains('Fantasy'));
      expect(item.actors, contains('Scott Weinger'));
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
      expect(items, hasLength(10));
      expect(items.first.title, 'The Big Bang');
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
      // When the upstream PMS search fails, the server returns `data: []`
      // instead of the results object. Inline rather than a fixture: the
      // reliable trigger (omitting `limit`) was fixed in v2.18.0, so this
      // shape is no longer reproducible against a supported server.
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient(
          (_) async => http.Response(
            '{"response":{"result":"success","message":null,"data":[]}}',
            200,
            headers: {'content-type': 'application/json;charset=UTF-8'},
          ),
        ),
      );
      final result = await client.media.search(query: 'anything');
      expect(result, isEmpty);
    });
  });

  group('MediaService new params', () {
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

  group('MediaService.getMetadata() error shape', () {
    test('an invalid rating_key surfaces as TautulliServerException', () async {
      // api2 sets HTTP 400 for a handler result of "error".
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient(
          (_) async => fixtureResponse(
            'media/get_metadata__invalid.json',
            statusCode: 400,
          ),
        ),
      );
      expect(
        () => client.media.getMetadata(ratingKey: 999999999),
        throwsA(isA<TautulliServerException>()),
      );
    });
  });

  group('MediaService.getOldRatingKeys()', () {
    test(
      'sends correct cmd, rating_key and media_type, parses hierarchy',
      () async {
        makeClient('media/get_old_rating_keys.json');
        final result = await client.media.getOldRatingKeys(
          ratingKey: 19197,
          mediaType: 'show',
        );
        expect(lastRequestUri.queryParameters['cmd'], 'get_old_rating_keys');
        expect(lastRequestUri.queryParameters['rating_key'], '19197');
        expect(lastRequestUri.queryParameters['media_type'], 'show');
        expect(result['0']['rating_key'], 19197);
        expect(result['0']['children']['1']['rating_key'], 19198);
      },
    );
  });

  group('MediaService.getItemUserStats()', () {
    test(
      'sends correct cmd, rating_key and grouping, parses user stats',
      () async {
        makeClient('media/get_item_user_stats.json');
        final result = await client.media.getItemUserStats(
          ratingKey: 1001,
          grouping: true,
        );
        expect(lastRequestUri.queryParameters['cmd'], 'get_item_user_stats');
        expect(lastRequestUri.queryParameters['rating_key'], '1001');
        expect(lastRequestUri.queryParameters['grouping'], '1');
        expect(result, hasLength(3));
        expect(result.first['friendly_name'], 'user35');
        expect(result.first['total_plays'], 3);
      },
    );
  });

  group('MediaService.getItemWatchTimeStats()', () {
    test(
      'sends correct cmd, rating_key, grouping and query_days, parses stats',
      () async {
        makeClient('media/get_item_watch_time_stats.json');
        final result = await client.media.getItemWatchTimeStats(
          ratingKey: 1001,
          grouping: false,
          queryDays: '1,7,30,0',
        );
        final q = lastRequestUri.queryParameters;
        expect(q['cmd'], 'get_item_watch_time_stats');
        expect(q['rating_key'], '1001');
        expect(q['grouping'], '0');
        expect(q['query_days'], '1,7,30,0');
        expect(result, hasLength(4));
        expect(result.first['query_days'], 1);
        expect(result.first['total_time'], 1437);
      },
    );
  });

  group('MediaService.updateMetadataDetails()', () {
    test('sends correct cmd and all rating_key/media_type params', () async {
      makeClient('success_response.json');
      await client.media.updateMetadataDetails(
        oldRatingKey: 100,
        newRatingKey: 200,
        mediaType: 'movie',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'update_metadata_details');
      expect(q['old_rating_key'], '100');
      expect(q['new_rating_key'], '200');
      expect(q['media_type'], 'movie');
    });
  });
}
