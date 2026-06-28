import '../../utils/cast.dart';

/// Lightweight identifier for a Plex library section.
///
/// Returned by `get_library_names` for populating dropdowns or filters.
class LibraryName {
  /// Plex section ID identifying this library.
  final int? sectionId;

  /// Display name of the library section.
  final String? sectionName;

  /// Library type string (e.g. `'movie'`, `'show'`, `'artist'`).
  final String? sectionType;

  const LibraryName({this.sectionId, this.sectionName, this.sectionType});

  /// Parses a [LibraryName] from a Tautulli API JSON map.
  factory LibraryName.fromJson(Map<String, dynamic> json) => LibraryName(
        sectionId: Cast.castToInt(json['section_id']),
        sectionName: Cast.castToString(json['section_name']),
        sectionType: Cast.castToString(json['section_type']),
      );
}
