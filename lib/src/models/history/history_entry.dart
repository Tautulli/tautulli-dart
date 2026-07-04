import '../../types/location.dart';
import '../../types/media_type.dart';
import '../../types/playback_state.dart';
import '../../types/stream_decision.dart';
import '../../types/watched_status.dart';
import '../../utils/cast.dart';

/// A single watch history entry returned by `get_history`.
class HistoryEntry {
  /// The date of the watch event, as a UTC [DateTime] (call `.toLocal()` for
  /// display).
  final DateTime? date;

  /// Total duration of the media item.
  final Duration? duration;

  /// User-configured display name for the watching user.
  final String? friendlyName;

  /// Full hierarchical title (e.g. `'Show - S01E01 - Episode'`).
  final String? fullTitle;

  /// Rating key of the grandparent item (series for episodes).
  final int? grandparentRatingKey;

  /// Title of the grandparent item (series title for episodes).
  final String? grandparentTitle;

  /// Number of individual play events grouped into this entry.
  final int? groupCount;

  /// Row IDs of the individual history rows that make up this grouped entry.
  final List<int>? groupIds;

  /// Plex GUID for the item (e.g. `'plex://movie/...'`).
  final String? guid;

  /// Database row ID for this history entry.
  final int? id;

  /// IP address from which the session was initiated.
  final String? ipAddress;

  /// Whether this was a live TV session.
  final bool? live;

  /// Network location of the stream (LAN, WAN, or cellular).
  final Location? location;

  /// Machine identifier of the Plex client.
  final String? machineId;

  /// Episode or track index within its parent.
  final int? mediaIndex;

  /// Media type of the watched item.
  final MediaType? mediaType;

  /// Original air/release date of the item.
  final DateTime? originallyAvailableAt;

  /// Original title before localization (if different from [title]).
  final String? originalTitle;

  /// Season or album index within its grandparent.
  final int? parentMediaIndex;

  /// Rating key of the parent item (season for episodes).
  final int? parentRatingKey;

  /// Title of the parent item (season title for episodes).
  final String? parentTitle;

  /// Total time the session was paused.
  final Duration? pausedCounter;

  /// Percentage of the item that was watched (0–100).
  final int? percentComplete;

  /// Platform identifier of the Plex client (e.g. `'chrome'`, `'ios'`).
  final String? platform;

  /// Name of the Plex player application.
  final String? player;

  /// Product name of the Plex client application.
  final String? product;

  /// Plex rating key identifying the watched item.
  final int? ratingKey;

  /// Reference row ID used for grouping repeat plays of the same item.
  final int? referenceId;

  /// Whether the stream was relayed through Plex Relay.
  final bool? relayed;

  /// Database row ID for this history record.
  final int? rowId;

  /// Whether the connection to the Plex client was secured (HTTPS).
  final bool? secure;

  /// Plex session key for the active or historical session.
  final int? sessionKey;

  /// Timestamp when playback started.
  final DateTime? started;

  /// Final playback state when the session ended.
  final PlaybackState? state;

  /// Timestamp when playback stopped.
  final DateTime? stopped;

  /// Thumbnail URL path for the watched item.
  final String? thumb;

  /// Display title of the watched item.
  final String? title;

  /// Transcode decision for this session (direct play, transcode, etc.).
  final StreamDecision? transcodeDecision;

  /// Plex username of the watching user.
  final String? user;

  /// Plex user ID of the watching user.
  final int? userId;

  /// URL path for the user's avatar thumbnail.
  final String? userThumb;

  /// How much of the item was watched, as a [WatchedStatus] threshold.
  final WatchedStatus? watchedStatus;

  /// Release year of the watched item.
  final int? year;

  const HistoryEntry({
    this.date,
    this.duration,
    this.friendlyName,
    this.fullTitle,
    this.grandparentRatingKey,
    this.grandparentTitle,
    this.groupCount,
    this.groupIds,
    this.guid,
    this.id,
    this.ipAddress,
    this.live,
    this.location,
    this.machineId,
    this.mediaIndex,
    this.mediaType,
    this.originallyAvailableAt,
    this.originalTitle,
    this.parentMediaIndex,
    this.parentRatingKey,
    this.parentTitle,
    this.pausedCounter,
    this.percentComplete,
    this.platform,
    this.player,
    this.product,
    this.ratingKey,
    this.referenceId,
    this.relayed,
    this.rowId,
    this.secure,
    this.sessionKey,
    this.started,
    this.state,
    this.stopped,
    this.thumb,
    this.title,
    this.transcodeDecision,
    this.user,
    this.userId,
    this.userThumb,
    this.watchedStatus,
    this.year,
  });

  /// Parses a [HistoryEntry] from a Tautulli API JSON map.
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: Cast.dateTimeFromEpochSeconds(json['date']),
      duration: _durationFromSeconds(Cast.castToInt(json['duration'])),
      friendlyName: Cast.castToString(json['friendly_name']),
      fullTitle: Cast.castToString(json['full_title']),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      grandparentTitle: Cast.castToString(json['grandparent_title']),
      groupCount: Cast.castToInt(json['group_count']),
      groupIds: _groupIdsFromString(Cast.castToString(json['group_ids'])),
      guid: Cast.castToString(json['guid']),
      id: Cast.castToInt(json['id']),
      ipAddress: Cast.castToString(json['ip_address']),
      live: Cast.castToBool(json['live']),
      location: Location.fromString(Cast.castToString(json['location'])),
      machineId: Cast.castToString(json['machine_id']),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      originallyAvailableAt: _dateTimeFromString(
        Cast.castToString(json['originally_available_at']),
      ),
      originalTitle: Cast.castToString(json['original_title']),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      parentTitle: Cast.castToString(json['parent_title']),
      pausedCounter: _durationFromSeconds(
        Cast.castToInt(json['paused_counter']),
      ),
      percentComplete: Cast.castToInt(json['percent_complete']),
      platform: Cast.castToString(json['platform']),
      player: Cast.castToString(json['player']),
      product: Cast.castToString(json['product']),
      ratingKey: Cast.castToInt(json['rating_key']),
      referenceId: Cast.castToInt(json['reference_id']),
      relayed: Cast.castToBool(json['relayed']),
      rowId: Cast.castToInt(json['row_id']),
      secure: Cast.castToBool(json['secure']),
      sessionKey: Cast.castToInt(json['session_key']),
      started: Cast.dateTimeFromEpochSeconds(json['started']),
      state: PlaybackState.fromString(Cast.castToString(json['state'])),
      stopped: Cast.dateTimeFromEpochSeconds(json['stopped']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      transcodeDecision: StreamDecision.fromString(
        Cast.castToString(json['transcode_decision']),
      ),
      user: Cast.castToString(json['user']),
      userId: Cast.castToInt(json['user_id']),
      userThumb: Cast.castToString(json['user_thumb']),
      watchedStatus: _watchedStatusFromNum(
        Cast.castToNum(json['watched_status']),
      ),
      year: Cast.castToInt(json['year']),
    );
  }

  static DateTime? _dateTimeFromString(String? date) {
    if (date == null) return null;
    return DateTime.tryParse(date);
  }

  static Duration? _durationFromSeconds(int? seconds) {
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }

  static List<int>? _groupIdsFromString(String? groupIds) {
    if (groupIds == null) return null;
    return groupIds
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }

  static WatchedStatus? _watchedStatusFromNum(num? value) {
    if (value == null) return null;
    if (value < 0.25) return WatchedStatus.empty;
    if (value < 0.5) return WatchedStatus.quarter;
    if (value < 0.75) return WatchedStatus.half;
    if (value < 1) return WatchedStatus.threeQuarter;
    return WatchedStatus.full;
  }
}
