import '../executor.dart';
import '../models/notification/notification_log_entry.dart';
import '../models/notification/notifier_config.dart';
import '../models/notification/notifier_parameter.dart';
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
    return Cast.dataList(
      response['data'],
      'get_notifiers',
    ).whereType<Map<String, dynamic>>().map(NotifierConfig.fromJson).toList();
  }

  /// Returns the full configuration for a single notifier.
  Future<NotifierConfig> getNotifierConfig({required int notifierId}) async {
    final response = await _client.execute(
      'get_notifier_config',
      params: {'notifier_id': notifierId},
    );
    return NotifierConfig.fromJson(
      Cast.dataMap(response['data'], 'get_notifier_config'),
    );
  }

  /// Returns the notification template parameters available for message text.
  Future<List<NotifierParameter>> getNotifierParameters() async {
    final response = await _client.execute('get_notifier_parameters');
    return Cast.dataList(response['data'], 'get_notifier_parameters')
        .whereType<Map<String, dynamic>>()
        .map(NotifierParameter.fromJson)
        .toList();
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
    final data = Cast.dataMap(response['data'], 'get_notification_log');
    return PagedResult(
      data: Cast.dataList(data['data'], 'get_notification_log')
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

  /// Sends a notification with the given [subject] and [body] via the notifier
  /// identified by [notifierId].
  ///
  /// [headers] supplies JSON headers for webhook notifiers; [scriptArgs]
  /// supplies arguments for script notifiers. Tautulli fixes the notify action
  /// to `api` for this command, so it is not a parameter.
  Future<void> notify({
    required int notifierId,
    required String subject,
    required String body,
    String? headers,
    String? scriptArgs,
  }) async {
    final params = <String, dynamic>{
      'notifier_id': notifierId,
      'subject': subject,
      'body': body,
    };
    if (headers != null) params['headers'] = headers;
    if (scriptArgs != null) params['script_args'] = scriptArgs;
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
