import '../executor.dart';

/// Commands: docs, docs_md, arnold
class ApiService {
  final TautulliExecutor _client;
  ApiService(TautulliExecutor client) : _client = client;

  /// Returns the full Tautulli API documentation as a structured map.
  Future<Map<String, dynamic>> docs() async {
    final response = await _client.execute('docs');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the Tautulli API documentation as Markdown text.
  Future<String> docsMd() async {
    final response = await _client.execute('docs_md');
    return (response['data'] as String?) ?? '';
  }

  /// Returns a random Arnold Schwarzenegger quote.
  Future<String> arnold() async {
    final response = await _client.execute('arnold');
    return (response['data'] as String?) ?? '';
  }
}
