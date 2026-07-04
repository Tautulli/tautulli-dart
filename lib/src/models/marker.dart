import '../utils/cast.dart';

/// A chapter marker (e.g. intro or credits) within a media item.
///
/// Returned in the `markers` list by both `get_activity` (per session) and
/// `get_metadata`.
class Marker {
  /// Plex marker ID.
  final int? id;

  /// Marker type (e.g. `'intro'`, `'credits'`).
  final String? type;

  /// Offset from the start of the item where the marker begins.
  final Duration? startTimeOffset;

  /// Offset from the start of the item where the marker ends.
  final Duration? endTimeOffset;

  /// Whether this is the first marker of its type.
  final bool? isFirst;

  /// Whether this is the final marker of its type.
  final bool? isFinal;

  const Marker({
    this.id,
    this.type,
    this.startTimeOffset,
    this.endTimeOffset,
    this.isFirst,
    this.isFinal,
  });

  /// Parses a [Marker] from a Tautulli API JSON map.
  factory Marker.fromJson(Map<String, dynamic> json) => Marker(
    id: Cast.castToInt(json['id']),
    type: Cast.castToString(json['type']),
    startTimeOffset: _ms(json['start_time_offset']),
    endTimeOffset: _ms(json['end_time_offset']),
    isFirst: Cast.castToBool(json['first']),
    isFinal: Cast.castToBool(json['final']),
  );

  static Duration? _ms(dynamic value) {
    final ms = Cast.castToInt(value);
    return ms == null ? null : Duration(milliseconds: ms);
  }
}
