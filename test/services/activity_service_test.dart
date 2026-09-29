import 'dart:convert';

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

  group('ActivityService.getActivity()', () {
    test('sends correct cmd', () async {
      makeClient('activity/get_activity.json');
      await client.activity.getActivity();
      expect(lastRequestUri.queryParameters['cmd'], 'get_activity');
    });

    test('parses an idle server (zero sessions)', () async {
      makeClient('activity/get_activity.json');
      final data = await client.activity.getActivity();
      expect(data.streamCount, 0);
      expect(data.sessions, isEmpty);
    });

    test('parses core session and identity fields', () async {
      makeClient('activity/get_activity__live.json');
      final data = await client.activity.getActivity();
      expect(data.sessions, hasLength(4));
      final s = data.sessions.first;
      expect(s.title, 'Black Widow');
      expect(s.mediaType, MediaType.movie);
      expect(s.state, PlaybackState.playing);
      expect(s.sectionId, 12);
      expect(s.machineId, 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee05');
      expect(s.actors, contains('Scarlett Johansson'));
      expect(data.lanBandwidth, 0);
      expect(data.wanBandwidth, 72519);
    });

    test('relayed replaces the old relay key', () async {
      makeClient('activity/get_activity__live.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.relayed, isFalse);
    });

    test('parses extended fields with numeric-string coercion', () async {
      makeClient('activity/get_activity__live.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.videoWidth, 1920);
      expect(s.videoHeight, 804);
      expect(s.bitrate, 11671);
      expect(s.fileSize, 11709994914);
      expect(s.streamVideoBitrate, 11671);
      expect(s.videoFramerate, '24p'); // label, not numeric
      expect(s.videoDoviPresent, isFalse);
      expect(s.audienceRating, 6.6);
      expect(s.rating, isNull); // sent as ''
    });

    test('parses extended metadata list and string fields', () async {
      makeClient('activity/get_activity__live.json');
      // Session 0 is a movie, which has no grandparent, so grandparentGuids
      // is always empty there; session 1 is an episode and still exercises
      // that parsing path.
      final s = (await client.activity.getActivity()).sessions[1];
      expect(s.guids, contains('tvdb://60'));
      expect(s.grandparentGuids, contains('tvdb://70327'));
      expect(s.genres, contains('Drama'));
      expect(s.directors, contains('James A. Contner'));
      expect(s.contentRating, 'TV-14');
      expect(s.studio, 'Mutant Enemy Productions');
      expect(s.libraryName, 'TV Shows');
      expect(s.user, 'user80');
    });

    test('parses markers into typed Marker objects', () async {
      makeClient('activity/get_activity__live.json');
      // Session 1 is the only one that carries two markers in this capture
      // (credits + intro), so it's the one that exercises a multi-marker
      // list; the others each have a single credits marker.
      final s = (await client.activity.getActivity()).sessions[1];
      expect(s.markers, isNotNull);
      expect(s.markers, hasLength(2));
      final m = s.markers!.first;
      expect(m.id, 118638);
      expect(m.type, 'credits');
      expect(m.startTimeOffset, const Duration(milliseconds: 2613206));
      expect(m.isFinal, isTrue);
      expect(s.markers!.last.isFinal, isNull); // intro marker sends no flag
    });

    test('wraps a single-session (bare object) response', () async {
      makeClient('activity/get_activity__by_session_key.json');
      final data = await client.activity.getActivity(sessionKey: 18);
      expect(data.sessions, hasLength(1));
      expect(data.sessions.first.sessionKey, 6);
      expect(data.sessions.first.title, 'Permanent Uncertainty');
      expect(data.sessions.first.state, PlaybackState.paused);
    });

    test('passes optional params', () async {
      makeClient('activity/get_activity.json');
      await client.activity.getActivity(sessionKey: 42, sessionId: 'abc');
      expect(lastRequestUri.queryParameters['session_key'], '42');
      expect(lastRequestUri.queryParameters['session_id'], 'abc');
    });

    test('throws TautulliAuthException on 401', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((_) async => http.Response('Unauthorized', 401)),
      );
      expect(
        () => client.activity.getActivity(),
        throwsA(isA<TautulliAuthException>()),
      );
    });
  });

  group('ActivityService.terminateSession()', () {
    test('sends correct cmd', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response(
            jsonEncode({
              'response': {'result': 'success', 'message': null, 'data': null},
            }),
            200,
          );
        }),
      );
      await client.activity.terminateSession(sessionKey: 42);
      expect(lastRequestUri.queryParameters['cmd'], 'terminate_session');
      expect(lastRequestUri.queryParameters['session_key'], '42');
    });
  });

  group('ActivityService.getStreamData()', () {
    test('sends correct cmd with session_key', () async {
      makeClient('activity/get_stream_data__row_id.json');
      final data = await client.activity.getStreamData(sessionKey: 42);
      expect(lastRequestUri.queryParameters['cmd'], 'get_stream_data');
      expect(lastRequestUri.queryParameters['session_key'], '42');
      expect(data['title'], 'The Harsh Light of Day');
    });

    test('sends row_id for a historical entry, no phantom params', () async {
      makeClient('activity/get_stream_data__row_id.json');
      await client.activity.getStreamData(rowId: 2597);
      final q = lastRequestUri.queryParameters;
      expect(q['row_id'], '2597');
      expect(q.containsKey('session_id'), isFalse);
      expect(q.containsKey('user_id'), isFalse);
    });
  });
}
