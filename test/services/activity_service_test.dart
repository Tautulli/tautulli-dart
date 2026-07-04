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
        return http.Response(fixture(fixtureFile), 200);
      }),
    );
  }

  group('ActivityService.getActivity()', () {
    test('sends correct cmd', () async {
      makeClient('activity/get_activity.json');
      await client.activity.getActivity();
      expect(lastRequestUri.queryParameters['cmd'], 'get_activity');
    });

    test('parses core session and identity fields', () async {
      makeClient('activity/get_activity.json');
      final data = await client.activity.getActivity();
      expect(data.sessions, hasLength(1));
      final s = data.sessions.first;
      expect(s.title, 'The Murder of Rachel Nickell');
      expect(s.mediaType, MediaType.movie);
      expect(s.state, PlaybackState.playing);
      expect(s.sectionId, 3);
      expect(s.machineId, 'machine-id-02');
      expect(s.actors, contains('Rachel Nickell'));
      expect(data.lanBandwidth, 0);
      expect(data.wanBandwidth, 3568);
    });

    test('relayed replaces the old relay key', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.relayed, isFalse);
    });

    test('parses extended fields with numeric-string coercion', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.videoWidth, 1920);
      expect(s.videoHeight, 800);
      expect(s.bitrate, 2633);
      expect(s.fileSize, 1902855892);
      expect(s.streamVideoBitrate, 2249);
      expect(s.videoFramerate, 'PAL'); // label, not numeric
      expect(s.videoDoviPresent, isFalse);
    });

    test('parses extended metadata list and string fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.guids, contains('imdb://tt42192165'));
      expect(s.genres, contains('Documentary'));
      expect(s.directors, contains('Lucy Bowden'));
      expect(s.contentRating, 'TV-MA');
      expect(s.studio, 'Blast! Films');
      expect(s.libraryName, 'Movies');
      expect(s.user, 'TestAdmin');
    });

    test('parses markers into typed Marker objects', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.markers, isNotNull);
      final m = s.markers!.first;
      expect(m.id, 3826);
      expect(m.type, 'credits');
      expect(m.startTimeOffset, const Duration(milliseconds: 5552998));
      expect(m.isFinal, isTrue);
    });

    test('wraps a single-session (bare object) response', () async {
      makeClient('activity/get_activity_session.json');
      final data = await client.activity.getActivity(sessionKey: 27);
      expect(data.sessions, hasLength(1));
      expect(data.sessions.first.sessionKey, 27);
      expect(data.sessions.first.title, 'The Matrix');
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
      makeClient('activity/get_stream_data.json');
      final data = await client.activity.getStreamData(sessionKey: 42);
      expect(lastRequestUri.queryParameters['cmd'], 'get_stream_data');
      expect(lastRequestUri.queryParameters['session_key'], '42');
      expect(data['title'], 'Frozen');
    });

    test('sends row_id for a historical entry, no phantom params', () async {
      makeClient('activity/get_stream_data.json');
      await client.activity.getStreamData(rowId: 2597);
      final q = lastRequestUri.queryParameters;
      expect(q['row_id'], '2597');
      expect(q.containsKey('session_id'), isFalse);
      expect(q.containsKey('user_id'), isFalse);
    });
  });
}
