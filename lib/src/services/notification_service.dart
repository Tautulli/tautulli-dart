import '../executor.dart';
import '../models/notification/notification_log_entry.dart';
import '../models/notification/notifier_config.dart';
import '../models/paged_result.dart';
import '../utils/cast.dart';

/// Commands: get_notifiers, get_notifier_config, get_notifier_parameters,
/// add_notifier_config, set_notifier_config, delete_notifier,
/// get_notification_log, delete_notification_log, notify, notify_recently_added
class NotificationService {
  final TautulliExecutor _client;
  NotificationService(TautulliExecutor client) : _client = client;

  /// Returns all configured notifiers.
  ///
  /// Pass [notifyAction] to filter to notifiers configured for a specific action.
  Future<List<NotifierConfig>> getNotifiers({String? notifyAction}) async {
    final params = <String, dynamic>{};
    if (notifyAction != null) params['notify_action'] = notifyAction;
    final response = await _client.execute('get_notifiers', params: params);
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(NotifierConfig.fromJson)
        .toList();
  }

  /// Returns the full configuration for a single notifier.
  Future<NotifierConfig> getNotifierConfig({required int notifierId}) async {
    final response = await _client.execute(
      'get_notifier_config',
      params: {'notifier_id': notifierId},
    );
    return NotifierConfig.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Returns the available notification parameters and their descriptions.
  Future<Map<String, dynamic>> getNotifierParameters() async {
    final response = await _client.execute('get_notifier_parameters');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Returns a paginated list of notification log entries.
  Future<PagedResult<NotificationLogEntry>> getNotificationLog({
    String? notifier,
    String? notifyAction,
    String? search,
    int? start,
    int? length,
    String? orderColumn,
    String? orderDir,
  }) async {
    final params = <String, dynamic>{};
    if (notifier != null) params['notifier'] = notifier;
    if (notifyAction != null) params['notify_action'] = notifyAction;
    if (search != null) params['search'] = search;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;

    final response = await _client.execute(
      'get_notification_log',
      params: params,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return PagedResult(
      data: (data['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(NotificationLogEntry.fromJson)
          .toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Adds a new notifier configuration for the given [agentId].
  Future<void> addNotifierConfig({required int agentId}) async {
    await _client.execute('add_notifier_config', params: {'agent_id': agentId});
  }

  /// Updates the configuration for the notifier identified by [notifierId].
  ///
  /// Agent-specific settings can be passed via [extraParams].
  Future<void> setNotifierConfig({
    required int notifierId,
    required int agentId,
    Map<String, dynamic> extraParams = const {},
  }) async {
    final params = <String, dynamic>{
      'notifier_id': notifierId,
      'agent_id': agentId,
      ...extraParams,
    };
    await _client.execute('set_notifier_config', params: params);
  }

  /// Deletes the notifier identified by [notifierId].
  Future<void> deleteNotifier({required int notifierId}) async {
    await _client.execute(
      'delete_notifier',
      params: {'notifier_id': notifierId},
    );
  }

  /// Deletes all notification log entries.
  Future<void> deleteNotificationLog() async {
    await _client.execute('delete_notification_log');
  }

  /// Sends a test notification via the given notifier.
  ///
  /// [notifyAction] is a Tautulli action string (e.g. `'test'`).
  /// Optionally associate the notification with a [ratingKey] or [userId].
  Future<void> notify({
    required int notifierId,
    required String notifyAction,
    int? ratingKey,
    int? userId,
  }) async {
    final params = <String, dynamic>{
      'notifier_id': notifierId,
      'notify_action': notifyAction,
    };
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (userId != null) params['user_id'] = userId;
    await _client.execute('notify', params: params);
  }

  /// Sends a recently-added notification for the item identified by [ratingKey].
  ///
  /// If [notifierId] is omitted, all notifiers with recently-added enabled are used.
  Future<void> notifyRecentlyAdded({
    required int ratingKey,
    int? notifierId,
  }) async {
    final params = <String, dynamic>{'rating_key': ratingKey};
    if (notifierId != null) params['notifier_id'] = notifierId;
    await _client.execute('notify_recently_added', params: params);
  }
}
