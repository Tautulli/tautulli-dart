import '../../utils/cast.dart';

/// A single entry from the Tautulli notification log.
///
/// Returned by `get_notification_log`.
class NotificationLogEntry {
  /// Unique row ID for this log entry.
  final int? id;

  /// Unix epoch timestamp when this notification was sent.
  final int? timestamp;

  /// Type identifier for the notifier agent (e.g. `'email'`, `'pushover'`).
  final String? notifierType;

  /// User-configured display name of the notifier.
  final String? friendlyName;

  /// The Tautulli action that triggered this notification (e.g. `'on_play'`).
  final String? notifyAction;

  /// Subject line of the notification that was sent.
  final String? subject;

  /// Whether the notification was delivered successfully.
  final bool? success;

  const NotificationLogEntry({
    this.id,
    this.timestamp,
    this.notifierType,
    this.friendlyName,
    this.notifyAction,
    this.subject,
    this.success,
  });

  /// Parses a [NotificationLogEntry] from a Tautulli API JSON map.
  factory NotificationLogEntry.fromJson(Map<String, dynamic> json) => NotificationLogEntry(
        id: Cast.castToInt(json['id']),
        timestamp: Cast.castToInt(json['timestamp']),
        notifierType: Cast.castToString(json['notifier_type']),
        friendlyName: Cast.castToString(json['friendly_name']),
        notifyAction: Cast.castToString(json['notify_action']),
        subject: Cast.castToString(json['subject']),
        success: Cast.castToBool(json['success']),
      );
}
