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

  /// Type identifier for the newsletter agent (e.g. `'email'`).
  final String? newsletterType;

  /// User-configured display name of the newsletter.
  final String? friendlyName;

  /// Subject line of the newsletter that was sent.
  final String? subject;

  /// Whether the newsletter was delivered successfully.
  final bool? success;

  const NewsletterLogEntry({
    this.id,
    this.timestamp,
    this.newsletterId,
    this.newsletterType,
    this.friendlyName,
    this.subject,
    this.success,
  });

  /// Parses a [NewsletterLogEntry] from a Tautulli API JSON map.
  factory NewsletterLogEntry.fromJson(Map<String, dynamic> json) =>
      NewsletterLogEntry(
        id: Cast.castToInt(json['id']),
        timestamp: Cast.castToInt(json['timestamp']),
        newsletterId: Cast.castToInt(json['newsletter_id']),
        newsletterType: Cast.castToString(json['newsletter_type']),
        friendlyName: Cast.castToString(json['friendly_name']),
        subject: Cast.castToString(json['subject']),
        success: Cast.castToBool(json['success']),
      );
}
