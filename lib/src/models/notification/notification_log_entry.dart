import '../../utils/cast.dart';

/// A single entry from the Tautulli notification log.
///
/// Returned by `get_notification_log`.
class NotificationLogEntry {
  /// Unique row ID for this log entry.
  final int? id;

  /// Unix epoch timestamp when this notification was sent.
  final int? timestamp;

  /// Session key of the stream that triggered this notification, if any.
  final int? sessionKey;

  /// Rating key of the item the notification was about, if any.
  final int? ratingKey;

  /// Plex user ID associated with the notification, if any.
  final int? userId;

  /// Plex username associated with the notification, if any.
  final String? user;

  /// ID of the notifier instance that sent this notification.
  final int? notifierId;

  /// ID of the notification agent type (e.g. `17` for the browser agent).
  final int? agentId;

  /// Name of the notification agent (e.g. `'browser'`, `'email'`).
  final String? agentName;

  /// The Tautulli action that triggered this notification (e.g. `'on_play'`).
  final String? notifyAction;

  /// Subject line of the notification that was sent.
  final String? subjectText;

  /// Body text of the notification that was sent.
  final String? bodyText;

  /// Whether the notification was delivered successfully.
  final bool? success;

  const NotificationLogEntry({
    this.id,
    this.timestamp,
    this.sessionKey,
    this.ratingKey,
    this.userId,
    this.user,
    this.notifierId,
    this.agentId,
    this.agentName,
    this.notifyAction,
    this.subjectText,
    this.bodyText,
    this.success,
  });

  /// Parses a [NotificationLogEntry] from a Tautulli API JSON map.
  factory NotificationLogEntry.fromJson(Map<String, dynamic> json) =>
      NotificationLogEntry(
        id: Cast.castToInt(json['id']),
        timestamp: Cast.castToInt(json['timestamp']),
        sessionKey: Cast.castToInt(json['session_key']),
        ratingKey: Cast.castToInt(json['rating_key']),
        userId: Cast.castToInt(json['user_id']),
        user: Cast.castToString(json['user']),
        notifierId: Cast.castToInt(json['notifier_id']),
        agentId: Cast.castToInt(json['agent_id']),
        agentName: Cast.castToString(json['agent_name']),
        notifyAction: Cast.castToString(json['notify_action']),
        subjectText: Cast.castToString(json['subject_text']),
        bodyText: Cast.castToString(json['body_text']),
        success: Cast.castToBool(json['success']),
      );
}
