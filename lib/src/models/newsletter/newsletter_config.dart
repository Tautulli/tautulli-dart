import '../../utils/cast.dart';

/// Configuration for a single Tautulli newsletter.
///
/// Returned by `get_newsletters` and `get_newsletter_config`.
class NewsletterConfig {
  /// Unique identifier for this newsletter.
  final int? newsletterId;

  /// Internal ID of the newsletter agent type.
  final int? agentId;

  /// Machine-readable name of the newsletter agent.
  final String? agentName;

  /// Human-readable label for the newsletter agent type.
  final String? agentLabel;

  /// User-configured display name for this newsletter.
  final String? friendlyName;

  /// Whether this newsletter is enabled.
  final bool? active;

  const NewsletterConfig({
    this.newsletterId,
    this.agentId,
    this.agentName,
    this.agentLabel,
    this.friendlyName,
    this.active,
  });

  /// Parses a [NewsletterConfig] from a Tautulli API JSON map.
  factory NewsletterConfig.fromJson(Map<String, dynamic> json) =>
      NewsletterConfig(
        newsletterId: Cast.castToInt(json['id']),
        agentId: Cast.castToInt(json['agent_id']),
        agentName: Cast.castToString(json['agent_name']),
        agentLabel: Cast.castToString(json['agent_label']),
        friendlyName: Cast.castToString(json['friendly_name']),
        active: Cast.castToBool(json['active']),
      );
}
