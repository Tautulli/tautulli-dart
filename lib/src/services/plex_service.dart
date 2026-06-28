import '../executor.dart';
import '../models/plex/plex_server_info.dart';

/// Commands: get_server_info, get_server_identity, get_server_friendly_name,
/// get_server_id, get_server_list, get_server_pref, get_servers_info,
/// get_pms_update, server_status, get_synced_items, delete_synced_item
class PlexService {
  final TautulliExecutor _client;
  PlexService(TautulliExecutor client) : _client = client;

  /// Returns information about the connected Plex Media Server.
  Future<PlexServerInfo> getServerInfo() async {
    final response = await _client.execute('get_server_info');
    return PlexServerInfo.fromJson(response['data'] as Map<String, dynamic>? ?? {});
  }

  /// Returns identity information (machine identifier) for the connected Plex server.
  Future<Map<String, dynamic>> getServerIdentity() async {
    final response = await _client.execute('get_server_identity');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the friendly name of the connected Plex Media Server.
  Future<String> getServerFriendlyName() async {
    final response = await _client.execute('get_server_friendly_name');
    return (response['data'] as String?) ?? '';
  }

  /// Returns the Plex server ID (machine identifier) for the given [hostname] and [port].
  Future<String> getServerId({required String hostname, required int port, bool? ssl, bool? remote}) async {
    final params = <String, dynamic>{'hostname': hostname, 'port': port};
    if (ssl != null) params['ssl'] = ssl;
    if (remote != null) params['remote'] = remote;
    final response = await _client.execute('get_server_id', params: params);
    return (response['data'] as String?) ?? '';
  }

  /// Returns all Plex servers accessible to the account as a list of raw maps.
  Future<List<Map<String, dynamic>>> getServerList() async {
    final response = await _client.execute('get_server_list');
    return (response['data'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
  }

  /// Returns the value of a single Plex server preference by its key [pref].
  Future<String> getServerPref({required String pref}) async {
    final response = await _client.execute('get_server_pref', params: {'pref': pref});
    return (response['data'] as String?) ?? '';
  }

  /// Returns detailed information about all servers as a list of raw maps.
  Future<List<Map<String, dynamic>>> getServersInfo() async {
    final response = await _client.execute('get_servers_info');
    return (response['data'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
  }

  /// Returns available Plex Media Server update information.
  Future<Map<String, dynamic>> getPmsUpdate() async {
    final response = await _client.execute('get_pms_update');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns the current status of the Plex Media Server.
  ///
  /// Optionally filter to a specific session with [sessionKey] or [sessionId].
  Future<Map<String, dynamic>> serverStatus({int? sessionKey, String? sessionId}) async {
    final params = <String, dynamic>{};
    if (sessionKey != null) params['session_key'] = sessionKey;
    if (sessionId != null) params['session_id'] = sessionId;
    final response = await _client.execute('server_status', params: params);
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns synced items for a Plex client device.
  Future<List<Map<String, dynamic>>> getSyncedItems({String? machineId, int? userId}) async {
    final params = <String, dynamic>{};
    if (machineId != null) params['machine_id'] = machineId;
    if (userId != null) params['user_id'] = userId;
    final response = await _client.execute('get_synced_items', params: params);
    return (response['data'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
  }

  /// Deletes a synced item from Plex.
  Future<void> deleteSyncedItem({required String machineId, required int syncId}) async {
    await _client.execute('delete_synced_item', params: {'machine_id': machineId, 'sync_id': syncId});
  }
}
