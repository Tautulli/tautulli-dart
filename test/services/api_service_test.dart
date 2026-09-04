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

  group('ApiService.docs()', () {
    test('sends correct cmd and returns map', () async {
      makeClient('api/docs.json');
      final result = await client.api.docs();
      expect(lastRequestUri.queryParameters['cmd'], 'docs');
      expect(result, isNotEmpty);
    });
  });

  group('ApiService.arnold()', () {
    test('sends correct cmd and returns string', () async {
      makeClient('api/arnold.json');
      final result = await client.api.arnold();
      expect(lastRequestUri.queryParameters['cmd'], 'arnold');
      expect(result, contains('See you at the party Richter!'));
    });
  });

  group('ApiService.docsMd()', () {
    test('decodes the raw (non-JSON) markdown body', () async {
      final meta =
          json.decode(fixture('api/docs_md.meta.json')) as Map<String, dynamic>;
      client = TautulliClient(
        connection: const TautulliConnection(
          protocol: 'http',
          domain: 'tautulli.local',
          apiKey: 'abc123',
        ),
        httpClient: MockClient((request) async {
          lastRequestUri = request.url;
          return http.Response.bytes(
            utf8.encode(meta['body_preview'] as String),
            meta['status'] as int,
            headers: {'content-type': meta['content_type'] as String},
          );
        }),
      );
      final result = await client.api.docsMd();
      expect(lastRequestUri.queryParameters['cmd'], 'docs_md');
      expect(result, startsWith('<pre>## General structure'));
    });
  });
}
