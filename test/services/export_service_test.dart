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
      final entry = result.data.first;
      expect(entry.title, 'The Matrix');
      expect(entry.filename, 'Movie - The Matrix [4017].csv');
      expect(entry.complete, true);
      expect(entry.sectionId, 3);
      expect(entry.ratingKey, 4017);
      expect(entry.fileSize, 1195);
      expect(entry.thumbLevel, 0);
      expect(entry.exists, true);
      expect(result.recordsTotal, 1);
    });
  });
}
