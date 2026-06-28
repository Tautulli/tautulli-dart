import '../../utils/cast.dart';

/// Technical encoding details for a single version of a Plex media item.
///
/// A single [MediaItem] may have multiple versions; `media_info` in the API
/// response is a list, but this model represents the first entry only.
class MediaInfo {
  /// Video aspect ratio (e.g. `1.78` for 16:9).
  final double? aspectRatio;

  /// Audio channel layout string (e.g. `'5.1(side)'`).
  final String? audioChannelLayout;

  /// Number of audio channels.
  final int? audioChannels;

  /// Audio codec name (e.g. `'aac'`, `'dca'`).
  final String? audioCodec;

  /// Audio encoding profile (e.g. `'lc'` for AAC-LC).
  final String? audioProfile;

  /// Combined audio+video bitrate in kbps.
  final int? bitrate;

  /// Live TV channel call sign (e.g. `'NBC'`).
  final String? channelCallSign;

  /// Live TV channel identifier string.
  final String? channelIdentifier;

  /// Live TV channel thumbnail URL path.
  final String? channelThumb;

  /// Container format (e.g. `'mkv'`, `'mp4'`).
  final String? container;

  /// Video height in pixels.
  final int? height;

  /// Internal Plex media version ID.
  final int? id;

  /// Whether this is an optimized (transcoded) version stored in Plex.
  final bool? optimizedVersion;

  /// Video codec name (e.g. `'h264'`, `'hevc'`).
  final String? videoCodec;

  /// Video frame rate string (e.g. `'24p'`, `'NTSC'`).
  final String? videoFramerate;

  /// Full video resolution string including scan type (e.g. `'1080p'`).
  final String? videoFullResolution;

  /// Video encoding profile (e.g. `'high'`, `'main'`).
  final String? videoProfile;

  /// Video resolution string (e.g. `'1080'`, `'4k'`).
  final String? videoResolution;

  /// Video width in pixels.
  final int? width;

  const MediaInfo({
    this.aspectRatio,
    this.audioChannelLayout,
    this.audioChannels,
    this.audioCodec,
    this.audioProfile,
    this.bitrate,
    this.channelCallSign,
    this.channelIdentifier,
    this.channelThumb,
    this.container,
    this.height,
    this.id,
    this.optimizedVersion,
    this.videoCodec,
    this.videoFramerate,
    this.videoFullResolution,
    this.videoProfile,
    this.videoResolution,
    this.width,
  });

  /// Parses [MediaInfo] from a Tautulli API JSON map.
  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      aspectRatio: Cast.castToDouble(json['aspect_ratio']),
      audioChannelLayout: Cast.castToString(json['audio_channel_layout']),
      audioChannels: Cast.castToInt(json['audio_channels']),
      audioCodec: Cast.castToString(json['audio_codec']),
      audioProfile: Cast.castToString(json['audio_profile']),
      bitrate: Cast.castToInt(json['bitrate']),
      channelCallSign: Cast.castToString(json['channel_call_sign']),
      channelIdentifier: Cast.castToString(json['channel_identifier']),
      channelThumb: Cast.castToString(json['channel_thumb']),
      container: Cast.castToString(json['container']),
      height: Cast.castToInt(json['height']),
      id: Cast.castToInt(json['id']),
      optimizedVersion: Cast.castToBool(json['optimized_version']),
      videoCodec: Cast.castToString(json['video_codec']),
      videoFramerate: Cast.castToString(json['video_framerate']),
      videoFullResolution: Cast.castToString(json['video_full_resolution']),
      videoProfile: Cast.castToString(json['video_profile']),
      videoResolution: Cast.castToString(json['video_resolution']),
      width: Cast.castToInt(json['width']),
    );
  }
}
