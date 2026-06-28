import '../../utils/cast.dart';

/// Configuration for a single Tautulli notifier.
///
/// Returned by `get_notifiers` and `get_notifier_config`.
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

  /// Whether this notifier is enabled.
  final bool? active;

  const NotifierConfig({
    this.notifierId,
    this.agentId,
    this.agentName,
    this.agentLabel,
    this.friendlyName,
    this.active,
  });

  /// Parses a [NotifierConfig] from a Tautulli API JSON map.
  factory NotifierConfig.fromJson(Map<String, dynamic> json) => NotifierConfig(
        notifierId: Cast.castToInt(json['id']),
        agentId: Cast.castToInt(json['agent_id']),
        agentName: Cast.castToString(json['agent_name']),
        agentLabel: Cast.castToString(json['agent_label']),
        friendlyName: Cast.castToString(json['friendly_name']),
        active: Cast.castToBool(json['active']),
      );
}
