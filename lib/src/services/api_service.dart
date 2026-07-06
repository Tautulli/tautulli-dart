import 'dart:convert';

import '../executor.dart';
import '../utils/cast.dart';

/// Commands: docs, docs_md, arnold
class ApiService {
  final TautulliExecutor _client;
  ApiService(TautulliExecutor client) : _client = client;

  /// Returns the full Tautulli API documentation as a structured map.
  Future<Map<String, dynamic>> docs() async {
    final response = await _client.execute('docs');
    return Cast.dataMap(response['data'], 'docs');
  }

  /// Returns the Tautulli API documentation as Markdown text.
  ///
  /// `docs_md` returns a raw (non-JSON) body, so it is fetched as bytes with
  /// `allowNonBinary` set (its `text/html` body is expected, not an error).
  Future<String> docsMd() async {
    final bytes = await _client.executeDownload(
      'docs_md',
      allowNonBinary: true,
    );
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// Returns a random Arnold Schwarzenegger quote.
  Future<String> arnold() async {
    final response = await _client.execute('arnold');
    return (response['data'] as String?) ?? '';
  }
}
