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

  group('LogService.getLogs()', () {
    test('sends correct cmd and parses object format', () async {
      makeClient('log/get_logs.json');
      final result = await client.logs.getLogs();
      expect(lastRequestUri.queryParameters['cmd'], 'get_logs');
      expect(result, hasLength(10));
      expect(result.first.level, 'WARNING');
      expect(
        result.first.message,
        'Tautulli Pmsconnect :: Failed to terminate session: '
        'Invalid session_key (999999) or session_id ().',
      );
      expect(result.first.thread, 'CP Server Thread-11');
      expect(result.first.timestamp, '2026-07-04 10:29:28 ');
    });

    test('sends order and regex params', () async {
      makeClient('log/get_logs.json');
      await client.logs.getLogs(order: 'asc', regex: 'error');
      expect(lastRequestUri.queryParameters['order'], 'asc');
      expect(lastRequestUri.queryParameters['regex'], 'error');
    });
  });

  group('LogService.getPlexLog()', () {
    test('sends window/logfile and parses nested positional rows', () async {
      makeClient('log/get_plex_log.json');
      final result = await client.logs.getPlexLog(
        window: 50,
        logfile: 'Plex Media Server',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'get_plex_log');
      expect(q['window'], '50');
      expect(q['logfile'], 'Plex Media Server');
      // Rows are [timestamp, level, message] nested under data.data.
      expect(result, hasLength(10));
      expect(result.first.timestamp, 'Jul 04, 2026 10:29:28.406');
      expect(result.first.level, 'ERROR');
      expect(result.first.message, contains('error reading output'));
      expect(result.first.thread, isNull);
    });
  });

  group('LogService download logfile param', () {
    test('downloadPlexLog sends logfile', () async {
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response.bytes(
            [1, 2, 3],
            200,
            headers: {'content-type': 'application/x-download'},
          );
        }),
      );
      await client.logs.downloadPlexLog(logfile: 'Plex Media Server');
      expect(lastRequestUri.queryParameters['logfile'], 'Plex Media Server');
    });
  });
}
