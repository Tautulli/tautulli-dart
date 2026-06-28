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

    test('parses sessions list', () async {
      makeClient('activity/get_activity.json');
      final data = await client.activity.getActivity();
      expect(data.sessions, hasLength(1));
      expect(data.sessions.first.title, 'The Matrix');
      expect(data.sessions.first.fullTitle, 'The Matrix');
      expect(data.sessions.first.mediaType, MediaType.movie);
      expect(data.sessions.first.state, PlaybackState.playing);
    });

    test('parses actors, addedAt, allowGuest, art from session', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.actors, contains('Keanu Reeves'));
      expect(s.addedAt, '1461572396');
      expect(s.allowGuest, true);
      expect(s.art, '/library/metadata/1001/art/1000000');
    });

    test('parses source video quality fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.videoBitDepth, 8);
      expect(s.videoCodecLevel, '4.1');
      expect(s.videoProfile, 'high');
      expect(s.videoResolution, '1080');
      expect(s.videoScanType, 'progressive');
    });

    test('parses stream video quality fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.streamVideoHeight, 1080);
      expect(s.streamVideoWidth, 1920);
      expect(s.streamVideoBitDepth, 8);
      expect(s.streamVideoFramerate, '23.976');
    });

    test('parses stream audio fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.audioBitrate, 256);
      expect(s.audioChannels, 2);
      expect(s.streamAudioBitrate, 256);
      expect(s.streamAudioLanguageCode, 'eng');
    });

    test('parses stream subtitle fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.streamSubtitleForced, false);
    });

    test('parses transcode detail fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.transcodeContainer, isNull);
      expect(s.transcodeHwFullPipeline, false);
      expect(s.transcodeHwRequested, false);
    });

    test('parses session metadata fields', () async {
      makeClient('activity/get_activity.json');
      final s = (await client.activity.getActivity()).sessions.first;
      expect(s.sectionId, 1);
      expect(s.ipAddressPublic, '1.2.3.4');
      expect(s.machineId, 'abc-machine-id');
      expect(s.streamAspectRatio, '2.4');
      expect(s.streamDuration, const Duration(milliseconds: 4488000));
    });

    test('parses bandwidth fields', () async {
      makeClient('activity/get_activity.json');
      final data = await client.activity.getActivity();
      expect(data.lanBandwidth, 8000);
      expect(data.wanBandwidth, 0);
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
  });
}
