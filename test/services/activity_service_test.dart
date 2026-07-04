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
      expect(data.sessions, hasLength(1));
      final s = data.sessions.first;
      expect(s.title, 'Project Hail Mary');
      expect(s.mediaType, MediaType.movie);
      expect(s.state, PlaybackState.playing);
      expect(s.sectionId, 12);
      expect(s.machineId, 'eeeeeeeeeeeeeeeeeeeeee01');
      expect(s.actors, contains('Ryan Gosling'));
      expect(data.lanBandwidth, 10278);
      expect(data.wanBandwidth, 0);
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
      expect(s.videoHeight, 1080);
      expect(s.bitrate, 9904);
      expect(s.fileSize, 11943659317);
      expect(s.streamVideoBitrate, 9263);
      expect(s.videoFramerate, '24p'); // label, not numeric
      expect(s.videoDoviPresent, isFalse);
    });

    test('parses extended metadata list and string fields', () async {
      makeClient('activity/get_activity__live.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.guids, contains('imdb://tt12042730'));
      expect(s.genres, contains('Science Fiction'));
      expect(s.directors, contains('Phil Lord'));
      expect(s.contentRating, 'PG-13');
      expect(s.studio, 'Lord Miller');
      expect(s.libraryName, 'Movies');
      expect(s.user, 'user70');
    });

    test('parses markers into typed Marker objects', () async {
      makeClient('activity/get_activity__live.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.markers, isNotNull);
      expect(s.markers, hasLength(2));
      final m = s.markers!.first;
      expect(m.id, 118638);
      expect(m.type, 'credits');
      expect(m.startTimeOffset, const Duration(milliseconds: 9055945));
      expect(m.isFinal, isFalse);
      expect(s.markers!.last.isFinal, isTrue);
    });

    test('wraps a single-session (bare object) response', () async {
      makeClient('activity/get_activity__by_session_key.json');
      final data = await client.activity.getActivity(sessionKey: 2);
      expect(data.sessions, hasLength(1));
      expect(data.sessions.first.sessionKey, 2);
      expect(data.sessions.first.title, 'Project Hail Mary');
      expect(data.sessions.first.state, PlaybackState.playing);
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
      expect(data['title'], 'Episode 31');
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
