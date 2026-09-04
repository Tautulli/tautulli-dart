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

  group('ExportService.getExportsTable()', () {
    test('sends correct cmd and parses entries', () async {
      makeClient('export/get_exports_table__after.json');
      final result = await client.exports.getExportsTable();
      expect(lastRequestUri.queryParameters['cmd'], 'get_exports_table');
      expect(result.data, hasLength(1));
      final entry = result.data.first;
      expect(entry.title, 'Library - 4K Movies - All [24]');
      expect(entry.filename, 'Library - 4K Movies - All [24].csv');
      expect(entry.complete, true);
      expect(entry.sectionId, 24);
      expect(entry.ratingKey, isNull);
      expect(entry.fileSize, 2607);
      expect(entry.thumbLevel, 0);
      expect(entry.exists, true);
      expect(result.recordsTotal, 1);
    });
  });

  group('ExportService.exportMetadata()', () {
    test('sends real params (levels), no phantom mediaType', () async {
      makeClient('export/export_metadata.json');
      final exportId = await client.exports.exportMetadata(
        ratingKey: 4017,
        fileFormat: 'json',
        thumbLevel: 1,
        artLevel: 2,
        exportType: 'all',
        individualFiles: true,
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'export_metadata');
      expect(q['rating_key'], '4017');
      expect(q['file_format'], 'json');
      expect(q['thumb_level'], '1');
      expect(q['art_level'], '2');
      expect(q['individual_files'], '1');
      expect(q.containsKey('media_type'), isFalse);
      expect(q.containsKey('include_images'), isFalse);
      expect(exportId, 2); // data.export_id in the capture
    });
  });

  group('ExportService new params', () {
    test('getExportsTable sends user_id', () async {
      makeClient('export/get_exports_table.json');
      await client.exports.getExportsTable(userId: 5);
      expect(lastRequestUri.queryParameters['user_id'], '5');
    });

    test('getExportFields sends media_type and sub_media_type', () async {
      makeClient('export/get_export_fields.json');
      await client.exports.getExportFields(
        mediaType: 'collection',
        subMediaType: 'movie',
      );
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'get_export_fields');
      expect(q['media_type'], 'collection');
      expect(q['sub_media_type'], 'movie');
    });

    test('deleteExport sends delete_all', () async {
      makeClient('success_response.json');
      await client.exports.deleteExport(exportId: 1, deleteAll: true);
      expect(lastRequestUri.queryParameters['delete_all'], '1');
    });
  });

  group('ExportService.downloadExport()', () {
    test('sends export_id and returns the raw bytes', () async {
      final meta =
          jsonDecode(fixture('export/download_export.meta.json'))
              as Map<String, dynamic>;
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
            meta['status'] as int,
            headers: {'content-type': meta['content_type'] as String},
          );
        }),
      );

      final bytes = await client.exports.downloadExport(exportId: 7);

      expect(bytes, [1, 2, 3]);
      final q = lastRequestUri.queryParameters;
      expect(q['cmd'], 'download_export');
      expect(q['export_id'], '7');
    });
  });
}
