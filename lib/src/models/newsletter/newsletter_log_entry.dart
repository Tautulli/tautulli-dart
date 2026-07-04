import '../../utils/cast.dart';

/// A single entry from the Tautulli newsletter send log.
///
/// Returned by `get_newsletter_log`.
class NewsletterLogEntry {
  /// Unique row ID for this log entry.
  final int? id;

  /// Unix epoch timestamp when this newsletter was sent.
  final int? timestamp;

  /// ID of the newsletter that was sent.
  final int? newsletterId;

  /// ID of the newsletter agent type.
  final int? agentId;

  /// Name of the newsletter agent (e.g. `'recently_added'`).
  final String? agentName;

  /// The Tautulli action that triggered this newsletter (e.g. `'on_cron'`).
  final String? notifyAction;

  /// Subject line of the newsletter that was sent.
  final String? subjectText;

  /// Body text of the newsletter that was sent.
  final String? bodyText;

  /// Start of the date range covered by the newsletter (`'YYYY-MM-DD'`).
  final String? startDate;

  /// End of the date range covered by the newsletter (`'YYYY-MM-DD'`).
  final String? endDate;

  /// Unique identifier for the hosted copy of the newsletter.
  final String? uuid;

  /// Whether the newsletter was delivered successfully.
  final bool? success;

  const NewsletterLogEntry({
    this.id,
    this.timestamp,
    this.newsletterId,
    this.agentId,
    this.agentName,
    this.notifyAction,
    this.subjectText,
    this.bodyText,
    this.startDate,
    this.endDate,
    this.uuid,
    this.success,
  });

  /// Parses a [NewsletterLogEntry] from a Tautulli API JSON map.
  factory NewsletterLogEntry.fromJson(Map<String, dynamic> json) =>
      NewsletterLogEntry(
        id: Cast.castToInt(json['id']),
        timestamp: Cast.castToInt(json['timestamp']),
        newsletterId: Cast.castToInt(json['newsletter_id']),
        agentId: Cast.castToInt(json['agent_id']),
        agentName: Cast.castToString(json['agent_name']),
        notifyAction: Cast.castToString(json['notify_action']),
        subjectText: Cast.castToString(json['subject_text']),
        bodyText: Cast.castToString(json['body_text']),
        startDate: Cast.castToString(json['start_date']),
        endDate: Cast.castToString(json['end_date']),
        uuid: Cast.castToString(json['uuid']),
        success: Cast.castToBool(json['success']),
      );
}
