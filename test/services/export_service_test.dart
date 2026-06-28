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

  group('ExportService.getExportsTable()', () {
    test('sends correct cmd and parses entries', () async {
      makeClient('export/get_exports_table.json');
      final result = await client.exports.getExportsTable();
      expect(lastRequestUri.queryParameters['cmd'], 'get_exports_table');
      expect(result.data, hasLength(1));
      expect(result.data.first.title, 'Movies');
      expect(result.data.first.complete, true);
      expect(result.recordsTotal, 1);
    });
  });
}
