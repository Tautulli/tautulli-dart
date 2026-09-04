import '../../utils/cast.dart';

/// Configuration for a single Tautulli notifier.
///
/// Returned by `get_notifiers` and `get_notifier_config`, which fill
/// different fields: only `get_notifiers` sends [active], [lastTriggered] and
/// [lastSuccess], and only `get_notifier_config` sends [config],
/// [configOptions], [actions], [notifyText], [customConditions] and
/// [customConditionsLogic]. The others are `null`.
class NotifierConfig {
  /// Unique identifier for this notifier.
  final int? notifierId;

  /// Internal ID of the notifier agent type.
  final int? agentId;

  /// Machine-readable name of the notifier agent.
  final String? agentName;

  /// Human-readable label for the notifier agent type.
  final String? agentLabel;

  /// User-configured display name for this notifier.
  final String? friendlyName;

  /// Whether this notifier is enabled. `get_notifiers` only.
  final bool? active;

  /// When this notifier last fired, from the notification log.
  /// `get_notifiers` only; `null` when it never fired.
  final DateTime? lastTriggered;

  /// Whether the notification recorded in [lastTriggered] succeeded.
  /// `get_notifiers` only.
  final bool? lastSuccess;

  /// Agent-specific settings as the server stores them, keyed by setting
  /// name. `get_notifier_config` only.
  final Map<String, dynamic>? config;

  /// The agent's setting descriptors (`label`, `description`, `input_type`
  /// and so on), one map per setting. `get_notifier_config` only.
  final List<dynamic>? configOptions;

  /// Trigger flags keyed by action name (`on_play`, `on_stop`, ...), `1` when
  /// the action is enabled. `get_notifier_config` only.
  final Map<String, dynamic>? actions;

  /// Subject and body templates keyed by action name.
  /// `get_notifier_config` only.
  final Map<String, dynamic>? notifyText;

  /// Custom condition rows (`parameter`, `operator`, `value`, `type`).
  /// `get_notifier_config` only.
  final List<dynamic>? customConditions;

  /// The logic expression joining [customConditions], empty when unset.
  /// `get_notifier_config` only.
  final String? customConditionsLogic;

  const NotifierConfig({
    this.notifierId,
    this.agentId,
    this.agentName,
    this.agentLabel,
    this.friendlyName,
    this.active,
    this.lastTriggered,
    this.lastSuccess,
    this.config,
    this.configOptions,
    this.actions,
    this.notifyText,
    this.customConditions,
    this.customConditionsLogic,
  });

  /// Parses a [NotifierConfig] from a Tautulli API JSON map.
  factory NotifierConfig.fromJson(Map<String, dynamic> json) => NotifierConfig(
    notifierId: Cast.castToInt(json['id']),
    agentId: Cast.castToInt(json['agent_id']),
    agentName: Cast.castToString(json['agent_name']),
    agentLabel: Cast.castToString(json['agent_label']),
    friendlyName: Cast.castToString(json['friendly_name']),
    active: Cast.castToBool(json['active']),
    lastTriggered: Cast.dateTimeFromEpochSeconds(json['last_triggered']),
    lastSuccess: Cast.castToBool(json['last_success']),
    config: Cast.mapOrNull(json['config']),
    configOptions: Cast.listOrNull(json['config_options']),
    actions: Cast.mapOrNull(json['actions']),
    notifyText: Cast.mapOrNull(json['notify_text']),
    customConditions: Cast.listOrNull(json['custom_conditions']),
    customConditionsLogic: Cast.castToString(json['custom_conditions_logic']),
  );
}
