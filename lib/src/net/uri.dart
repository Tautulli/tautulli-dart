import '../connection.dart';
import '../exceptions.dart';

/// Builds the `/api/v2` request URI for [connection] with the given [query].
///
/// Normalizes the optional path prefix (stripping stray leading/trailing
/// slashes) and rejects a [TautulliConnection.domain] that mistakenly includes
/// a scheme. Shared by `TautulliClient` and `ImageService`.
Uri buildTautulliUri(TautulliConnection connection, Map<String, String> query) {
  if (connection.domain.contains('://')) {
    throw TautulliProtocolException(
      message:
          "domain must not include a scheme (got '${connection.domain}'); "
          'set the protocol field instead',
    );
  }

  final cleanPath = (connection.path ?? '').replaceAll(RegExp(r'^/+|/+$'), '');
  final path = cleanPath.isEmpty ? '/api/v2' : '/$cleanPath/api/v2';

  switch (connection.protocol.toLowerCase()) {
    case 'http':
      return Uri.http(connection.domain, path, query);
    case 'https':
      return Uri.https(connection.domain, path, query);
    default:
      throw TautulliProtocolException(
        message: 'Unsupported protocol: ${connection.protocol}',
      );
  }
}
