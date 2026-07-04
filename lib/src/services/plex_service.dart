import '../executor.dart';
import '../models/plex/plex_server_info.dart';
import '../utils/cast.dart';

/// Commands: get_server_info, get_server_identity, get_server_friendly_name,
/// get_server_id, get_server_list, get_server_pref, get_servers_info,
/// get_pms_update, server_status, get_synced_items, delete_synced_item
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
  /// [includeCloud] includes Plex Cloud servers; [allServers] includes servers
  /// owned by other accounts. Both default to true server-side.
  Future<List<Map<String, dynamic>>> getServerList({
    bool? includeCloud,
    bool? allServers,
  }) async {
    final params = <String, dynamic>{};
    if (includeCloud != null) params['include_cloud'] = includeCloud;
    if (allServers != null) params['all_servers'] = allServers;
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

  /// Returns the current status of the Plex Media Server.
  ///
  /// Optionally filter to a specific session with [sessionKey] or [sessionId].
  Future<Map<String, dynamic>> serverStatus({
    int? sessionKey,
    String? sessionId,
  }) async {
    final params = <String, dynamic>{};
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (sessionId != null) params['session_id'] = sessionId;
    final response = await _client.execute('server_status', params: params);
    return Cast.dataMap(response['data'], 'server_status');
  }

  /// Returns synced items for a Plex client device.
  ///
  /// Note: Plex has retired the Sync feature, so modern servers return no
  /// synced items and this yields an empty list.
  Future<List<Map<String, dynamic>>> getSyncedItems({
    String? machineId,
    int? userId,
  }) async {
    final params = <String, dynamic>{};
    if (machineId != null) params['machine_id'] = machineId;
    if (userId != null) params['user_id'] = userId;
    final response = await _client.execute('get_synced_items', params: params);
    // Servers with no sync data return {} instead of a list.
    final data = response['data'];
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// Deletes the synced item [syncId] from the device identified by [clientId].
  Future<void> deleteSyncedItem({
    required String clientId,
    required int syncId,
  }) async {
    await _client.execute(
      'delete_synced_item',
      params: {'client_id': clientId, 'sync_id': syncId},
    );
  }
}
