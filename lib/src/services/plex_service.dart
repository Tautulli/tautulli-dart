import '../executor.dart';
import '../models/plex/plex_server_info.dart';
import '../utils/cast.dart';

/// Commands: get_server_info, get_server_identity, get_server_friendly_name,
/// get_server_id, get_server_list, get_server_pref, get_servers_info,
/// get_pms_update, server_status
class PlexService {
  final TautulliExecutor _client;
  PlexService(TautulliExecutor client) : _client = client;

  /// Returns information about the connected Plex Media Server.
  Future<PlexServerInfo> getServerInfo() async {
    final response = await _client.execute('get_server_info');
    return PlexServerInfo.fromJson(
      Cast.dataMap(response['data'], 'get_server_info'),
    );
  }

  /// Returns identity information (machine identifier) for the connected Plex server.
  Future<Map<String, dynamic>> getServerIdentity() async {
    final response = await _client.execute('get_server_identity');
    return Cast.dataMap(response['data'], 'get_server_identity');
  }

  /// Returns the friendly name of the connected Plex Media Server.
  Future<String> getServerFriendlyName() async {
    final response = await _client.execute('get_server_friendly_name');
    return (response['data'] as String?) ?? '';
  }

  /// Returns the Plex server ID (machine identifier) for the given [hostname] and [port].
  Future<String> getServerId({
    required String hostname,
    required int port,
    bool? ssl,
  }) async {
    final params = <String, dynamic>{'hostname': hostname, 'port': port};
    if (ssl != null) params['ssl'] = ssl;
    final response = await _client.execute('get_server_id', params: params);
    // The server returns {"identifier": "..."}, not a bare string.
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data['identifier']?.toString() ?? '';
    }
    return (data as String?) ?? '';
  }

  /// Returns all Plex servers accessible to the account as a list of raw maps.
  ///
  /// [allServers] controls whether every published connection address is
  /// returned for each server (the default) or just one; it does not filter by
  /// account ownership.
  Future<List<Map<String, dynamic>>> getServerList({bool? allServers}) async {
    final params = <String, dynamic>{};
    // Sent as a literal 'true'/'false' string, not the usual 1/0: the server
    // tests `not (all_servers == 'false')`, so '0' would read as true.
    if (allServers != null) {
      params['all_servers'] = allServers ? 'true' : 'false';
    }
    final response = await _client.execute('get_server_list', params: params);
    return Cast.dataList(
      response['data'],
      'get_server_list',
    ).whereType<Map<String, dynamic>>().toList();
  }

  /// Returns the value of a single Plex server preference by its key [pref].
  Future<String> getServerPref({required String pref}) async {
    final response = await _client.execute(
      'get_server_pref',
      params: {'pref': pref},
    );
    return (response['data'] as String?) ?? '';
  }

  /// Returns detailed information about all servers as a list of raw maps.
  Future<List<Map<String, dynamic>>> getServersInfo() async {
    final response = await _client.execute('get_servers_info');
    return Cast.dataList(
      response['data'],
      'get_servers_info',
    ).whereType<Map<String, dynamic>>().toList();
  }

  /// Returns available Plex Media Server update information.
  Future<Map<String, dynamic>> getPmsUpdate() async {
    final response = await _client.execute('get_pms_update');
    return Cast.dataMap(response['data'], 'get_pms_update');
  }

  /// Returns whether Tautulli is connected to the Plex Media Server, as
  /// `{'connected': bool}`.
  Future<Map<String, dynamic>> serverStatus() async {
    final response = await _client.execute('server_status');
    return Cast.dataMap(response['data'], 'server_status');
  }
}
