import '../../types/location.dart';
import '../../types/media_type.dart';
import '../../types/playback_state.dart';
import '../../types/stream_decision.dart';
import '../../types/subtitle_decision.dart';
import '../../utils/cast.dart';

/// Snapshot of current Plex activity returned by `get_activity`.
class ActivityData {
  /// Total number of active streams.
  final int? streamCount;

  /// Number of active direct-play streams.
  final int? streamCountDirectPlay;

  /// Number of active direct-stream (container-only transcode) streams.
  final int? streamCountDirectStream;

  /// Number of active full-transcode streams.
  final int? streamCountTranscode;

  /// Combined bandwidth of all active streams in kbps.
  final int? totalBandwidth;

  /// Bandwidth of all LAN streams in kbps.
  final int? lanBandwidth;

  /// Bandwidth of all WAN streams in kbps.
  final int? wanBandwidth;

  /// Currently active streaming sessions.
  final List<ActivitySession> sessions;

  const ActivityData({
    this.streamCount,
    this.streamCountDirectPlay,
    this.streamCountDirectStream,
    this.streamCountTranscode,
    this.totalBandwidth,
    this.lanBandwidth,
    this.wanBandwidth,
    this.sessions = const [],
  });

  /// Parses [ActivityData] from a Tautulli API JSON map.
  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      streamCount: Cast.castToInt(json['stream_count']),
      streamCountDirectPlay: Cast.castToInt(json['stream_count_direct_play']),
      streamCountDirectStream: Cast.castToInt(json['stream_count_direct_stream']),
      streamCountTranscode: Cast.castToInt(json['stream_count_transcode']),
      totalBandwidth: Cast.castToInt(json['total_bandwidth']),
      lanBandwidth: Cast.castToInt(json['lan_bandwidth']),
      wanBandwidth: Cast.castToInt(json['wan_bandwidth']),
      sessions: (json['sessions'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ActivitySession.fromJson)
          .toList(),
    );
  }
}

/// A single active Plex streaming session within an [ActivityData] snapshot.
class ActivitySession {
  // ---- Source audio ----

  /// Source audio channel layout string (e.g. `'5.1(side)'`).
  final String? audioChannelLayout;

  /// Source audio bitrate in kbps.
  final int? audioBitrate;

  /// Number of source audio channels.
  final int? audioChannels;

  /// Source audio codec name (e.g. `'aac'`, `'dca'`).
  final String? audioCodec;

  /// How the audio track is being delivered (direct play, transcode, etc.).
  final StreamDecision? audioDecision;

  /// Source audio language name.
  final String? audioLanguage;

  /// Source audio encoding profile.
  final String? audioProfile;

  /// Source audio sample rate in Hz.
  final int? audioSampleRate;

  // ---- Stream / container ----

  /// Total bandwidth used by this session in kbps.
  final int? bandwidth;

  /// Live TV channel call sign (e.g. `'NBC'`).
  final String? channelCallSign;

  /// Source container format (e.g. `'mkv'`, `'mp4'`).
  final String? container;

  /// How the container is being delivered.
  final StreamDecision? containerDecision;

  // ---- Duration / progress ----

  /// Total duration of the media item.
  final Duration? duration;

  /// Current playback progress as a percentage (0–100).
  final int? progressPercent;

  /// Current playback position in milliseconds.
  final int? viewOffset;

  // ---- User / device ----

  /// Whether the watching user is a guest account.
  final bool? allowGuest;

  /// User-configured display name for the watching user.
  final String? friendlyName;

  /// Local IP address of the Plex client.
  final String? ipAddress;

  /// Public IP address of the Plex client (if behind NAT).
  final String? ipAddressPublic;

  /// Machine identifier of the Plex client device.
  final String? machineId;

  /// Platform identifier (e.g. `'chrome'`, `'ios'`, `'android'`).
  final String? platform;

  /// Human-readable platform name.
  final String? platformName;

  /// Platform software version.
  final String? platformVersion;

  /// Name of the Plex player application.
  final String? player;

  /// Plex product name.
  final String? product;

  /// Plex client product version.
  final String? productVersion;

  /// Quality profile name selected for this session.
  final String? qualityProfile;

  /// Whether the stream is being relayed through Plex Relay.
  final bool? relay;

  /// Whether the connection to the Plex client is secured.
  final bool? secure;

  /// Unique session identifier string.
  final String? sessionId;

  /// Numeric session key identifying the active session.
  final int? sessionKey;

  // ---- Media identity ----

  /// Cast members for the playing item.
  final List<String>? actors;

  /// Epoch timestamp string when this item was added to Plex.
  final String? addedAt;

  /// Background art URL path for the playing item.
  final String? art;

  /// Full hierarchical title (e.g. `'Show - S01E01 - Episode'`).
  final String? fullTitle;

  /// Rating key of the grandparent item (series for episodes).
  final int? grandparentRatingKey;

  /// Thumbnail URL path for the grandparent item.
  final String? grandparentThumb;

  /// Title of the grandparent item (series name for episodes).
  final String? grandparentTitle;

  /// Whether this is a live TV session.
  final bool? live;

  /// Live TV stream UUID.
  final String? liveUuid;

  /// Whether the client is on the local network.
  final bool? local;

  /// Network location of this session.
  final Location? location;

  /// Episode or track index within its parent.
  final int? mediaIndex;

  /// Media type of the playing item.
  final MediaType? mediaType;

  /// Whether this is an optimized version stored in Plex.
  final bool? optimizedVersion;

  /// Profile name of the optimized version being played.
  final String? optimizedVersionProfile;

  /// Title of the optimized version being played.
  final String? optimizedVersionTitle;

  /// Original air/release date of the playing item.
  final DateTime? originallyAvailableAt;

  /// Original title before localization.
  final String? originalTitle;

  /// Season or album index within its grandparent.
  final int? parentMediaIndex;

  /// Rating key of the parent item (season for episodes).
  final int? parentRatingKey;

  /// Thumbnail URL path for the parent item.
  final String? parentThumb;

  /// Title of the parent item (season for episodes).
  final String? parentTitle;

  /// Plex rating key identifying the playing item.
  final int? ratingKey;

  /// Library section ID this item belongs to.
  final int? sectionId;

  /// Current playback state.
  final PlaybackState? state;

  /// Sub-type string for the playing item.
  final String? subType;

  /// Thumbnail URL path for the playing item.
  final String? thumb;

  /// Display title of the playing item.
  final String? title;

  /// Raw media type string from the API.
  final String? type;

  /// Plex user ID of the watching user.
  final int? userId;

  /// URL path for the user's avatar thumbnail.
  final String? userThumb;

  /// Source video width in pixels.
  final int? width;

  /// Source video height in pixels.
  final int? height;

  /// Release year of the playing item.
  final int? year;

  // ---- Stream info ----

  /// Aspect ratio of the streamed video.
  final String? streamAspectRatio;

  /// Total bitrate of the stream in kbps.
  final int? streamBitrate;

  /// Container format of the stream.
  final String? streamContainer;

  /// How the stream container is being delivered.
  final StreamDecision? streamContainerDecision;

  /// Duration of the stream (may differ from [duration] for partial streams).
  final Duration? streamDuration;

  // ---- Stream audio ----

  /// Streamed audio bitrate in kbps.
  final int? streamAudioBitrate;

  /// Streamed audio channel layout string.
  final String? streamAudioChannelLayout;

  /// Number of streamed audio channels.
  final int? streamAudioChannels;

  /// Streamed audio codec name.
  final String? streamAudioCodec;

  /// How the audio track is being delivered in the stream.
  final StreamDecision? streamAudioDecision;

  /// Streamed audio language name.
  final String? streamAudioLanguage;

  /// Streamed audio language ISO code.
  final String? streamAudioLanguageCode;

  /// Streamed audio encoding profile.
  final String? streamAudioProfile;

  /// Streamed audio sample rate in Hz.
  final int? streamAudioSampleRate;

  // ---- Stream subtitle ----

  /// Streamed subtitle codec name.
  final String? streamSubtitleCodec;

  /// Streamed subtitle container format.
  final String? streamSubtitleContainer;

  /// How the subtitle track is being delivered.
  final SubtitleDecision? streamSubtitleDecision;

  /// Whether the streamed subtitle track is forced.
  final bool? streamSubtitleForced;

  /// Streamed subtitle format.
  final String? streamSubtitleFormat;

  /// Streamed subtitle language name.
  final String? streamSubtitleLanguage;

  /// Streamed subtitle language ISO code.
  final String? streamSubtitleLanguageCode;

  /// Where the streamed subtitle track is located (e.g. `'embedded'`, `'external'`).
  final String? streamSubtitleLocation;

  // ---- Stream video ----

  /// Bit depth of the streamed video (e.g. 8, 10).
  final int? streamVideoBitDepth;

  /// Chroma subsampling of the streamed video (e.g. `'4:2:0'`).
  final String? streamVideoChromaSubsampling;

  /// Streamed video codec name.
  final String? streamVideoCodec;

  /// Streamed video codec level string.
  final String? streamVideoCodecLevel;

  /// Streamed video color primaries string.
  final String? streamVideoColorPrimaries;

  /// Streamed video color range (e.g. `'tv'`, `'pc'`).
  final String? streamVideoColorRange;

  /// Streamed video color space.
  final String? streamVideoColorSpace;

  /// Streamed video transfer characteristics.
  final String? streamVideoColorTrc;

  /// How the video track is being delivered.
  final StreamDecision? streamVideoDecision;

  /// Dynamic range of the streamed video (e.g. `'HDR'`, `'SDR'`).
  final String? streamVideoDynamicRange;

  /// Frame rate of the streamed video.
  final String? streamVideoFramerate;

  /// Full resolution string of the streamed video (e.g. `'1080p'`).
  final String? streamVideoFullResolution;

  /// Height in pixels of the streamed video.
  final int? streamVideoHeight;

  /// Language of the streamed video track.
  final String? streamVideoLanguage;

  /// Language ISO code of the streamed video track.
  final String? streamVideoLanguageCode;

  /// Number of reference frames in the streamed video.
  final int? streamVideoRefFrames;

  /// Resolution string of the streamed video (e.g. `'1080'`).
  final String? streamVideoResolution;

  /// Scan type of the streamed video (e.g. `'progressive'`).
  final String? streamVideoScanType;

  /// Width in pixels of the streamed video.
  final int? streamVideoWidth;

  // ---- Source subtitle ----

  /// Source subtitle codec name.
  final String? subtitleCodec;

  /// Source subtitle container format.
  final String? subtitleContainer;

  /// Whether the source subtitle track is forced.
  final bool? subtitleForced;

  /// Source subtitle format string.
  final String? subtitleFormat;

  /// Source subtitle language name.
  final String? subtitleLanguage;

  /// Source subtitle language ISO code.
  final String? subtitleLanguageCode;

  /// Where the source subtitle track is stored.
  final String? subtitleLocation;

  /// Whether subtitles are enabled for this session.
  final bool? subtitles;

  // ---- Source video ----

  /// Source video codec name (e.g. `'h264'`, `'hevc'`).
  final String? videoCodec;

  /// How the video track is being delivered.
  final StreamDecision? videoDecision;

  /// Bit depth of the source video.
  final int? videoBitDepth;

  /// Source video codec level string.
  final String? videoCodecLevel;

  /// Source video color primaries.
  final String? videoColorPrimaries;

  /// Source video color range.
  final String? videoColorRange;

  /// Source video color space.
  final String? videoColorSpace;

  /// Source video transfer characteristics.
  final String? videoColorTrc;

  /// Dynamic range of the source video.
  final String? videoDynamicRange;

  /// Source video frame rate string.
  final String? videoFrameRate;

  /// Full resolution string of the source video.
  final String? videoFullResolution;

  /// Source video language name.
  final String? videoLanguage;

  /// Source video language ISO code.
  final String? videoLanguageCode;

  /// Source video encoding profile.
  final String? videoProfile;

  /// Number of reference frames in the source video.
  final int? videoRefFrames;

  /// Resolution string of the source video.
  final String? videoResolution;

  /// Scan type of the source video.
  final String? videoScanType;

  // ---- Transcode ----

  /// Overall transcode decision for this session.
  final StreamDecision? transcodeDecision;

  /// Container format being used by the transcoder.
  final String? transcodeContainer;

  /// Output video height from the transcoder in pixels.
  final int? transcodeHeight;

  /// Whether hardware decoding is active.
  final bool? transcodeHwDecoding;

  /// Hardware decoder name being used.
  final String? transcodeHwDecode;

  /// Human-readable title of the hardware decoder.
  final String? transcodeHwDecodeTitle;

  /// Whether hardware encoding is active.
  final bool? transcodeHwEncoding;

  /// Whether the full transcode pipeline is hardware-accelerated.
  final bool? transcodeHwFullPipeline;

  /// Whether hardware transcoding was requested by the client.
  final bool? transcodeHwRequested;

  /// Internal key identifying the active transcode session.
  final String? transcodeKey;

  /// Maximum seek offset available in the transcoded stream in milliseconds.
  final int? transcodeMaxOffsetAvailable;

  /// Minimum seek offset available in the transcoded stream in milliseconds.
  final int? transcodeMinOffsetAvailable;

  /// Transcoding progress as a percentage (0–100).
  final int? transcodeProgress;

  /// Streaming protocol used by the transcoder (e.g. `'dash'`, `'hls'`).
  final String? transcodeProtocol;

  /// Transcode speed multiplier (e.g. `2.0` means transcoding at 2× real-time).
  final double? transcodeSpeed;

  /// Whether the transcoder is throttled to manage CPU load.
  final bool? transcodeThrottled;

  /// Output video width from the transcoder in pixels.
  final int? transcodeWidth;

  /// Whether bandwidth throttling is active for this session.
  final bool? throttled;

  const ActivitySession({
    this.audioChannelLayout,
    this.audioBitrate,
    this.audioChannels,
    this.audioCodec,
    this.audioDecision,
    this.audioLanguage,
    this.audioProfile,
    this.audioSampleRate,
    this.bandwidth,
    this.channelCallSign,
    this.container,
    this.containerDecision,
    this.duration,
    this.progressPercent,
    this.viewOffset,
    this.friendlyName,
    this.ipAddress,
    this.ipAddressPublic,
    this.machineId,
    this.platform,
    this.platformName,
    this.platformVersion,
    this.player,
    this.product,
    this.productVersion,
    this.qualityProfile,
    this.relay,
    this.secure,
    this.sessionId,
    this.sessionKey,
    this.actors,
    this.addedAt,
    this.allowGuest,
    this.art,
    this.fullTitle,
    this.grandparentRatingKey,
    this.grandparentThumb,
    this.grandparentTitle,
    this.live,
    this.liveUuid,
    this.local,
    this.location,
    this.mediaIndex,
    this.mediaType,
    this.optimizedVersion,
    this.optimizedVersionProfile,
    this.optimizedVersionTitle,
    this.originallyAvailableAt,
    this.originalTitle,
    this.parentMediaIndex,
    this.parentRatingKey,
    this.parentThumb,
    this.parentTitle,
    this.ratingKey,
    this.sectionId,
    this.state,
    this.subType,
    this.thumb,
    this.title,
    this.type,
    this.userId,
    this.userThumb,
    this.width,
    this.height,
    this.year,
    this.streamAspectRatio,
    this.streamBitrate,
    this.streamContainer,
    this.streamContainerDecision,
    this.streamDuration,
    this.streamAudioBitrate,
    this.streamAudioChannelLayout,
    this.streamAudioChannels,
    this.streamAudioCodec,
    this.streamAudioDecision,
    this.streamAudioLanguage,
    this.streamAudioLanguageCode,
    this.streamAudioProfile,
    this.streamAudioSampleRate,
    this.streamSubtitleCodec,
    this.streamSubtitleContainer,
    this.streamSubtitleDecision,
    this.streamSubtitleForced,
    this.streamSubtitleFormat,
    this.streamSubtitleLanguage,
    this.streamSubtitleLanguageCode,
    this.streamSubtitleLocation,
    this.streamVideoBitDepth,
    this.streamVideoChromaSubsampling,
    this.streamVideoCodec,
    this.streamVideoCodecLevel,
    this.streamVideoColorPrimaries,
    this.streamVideoColorRange,
    this.streamVideoColorSpace,
    this.streamVideoColorTrc,
    this.streamVideoDecision,
    this.streamVideoDynamicRange,
    this.streamVideoFramerate,
    this.streamVideoFullResolution,
    this.streamVideoHeight,
    this.streamVideoLanguage,
    this.streamVideoLanguageCode,
    this.streamVideoRefFrames,
    this.streamVideoResolution,
    this.streamVideoScanType,
    this.streamVideoWidth,
    this.subtitleCodec,
    this.subtitleContainer,
    this.subtitleForced,
    this.subtitleFormat,
    this.subtitleLanguage,
    this.subtitleLanguageCode,
    this.subtitleLocation,
    this.subtitles,
    this.videoCodec,
    this.videoDecision,
    this.videoBitDepth,
    this.videoCodecLevel,
    this.videoColorPrimaries,
    this.videoColorRange,
    this.videoColorSpace,
    this.videoColorTrc,
    this.videoDynamicRange,
    this.videoFrameRate,
    this.videoFullResolution,
    this.videoLanguage,
    this.videoLanguageCode,
    this.videoProfile,
    this.videoRefFrames,
    this.videoResolution,
    this.videoScanType,
    this.transcodeDecision,
    this.transcodeContainer,
    this.transcodeHeight,
    this.transcodeHwDecoding,
    this.transcodeHwDecode,
    this.transcodeHwDecodeTitle,
    this.transcodeHwEncoding,
    this.transcodeHwFullPipeline,
    this.transcodeHwRequested,
    this.transcodeKey,
    this.transcodeMaxOffsetAvailable,
    this.transcodeMinOffsetAvailable,
    this.transcodeProgress,
    this.transcodeProtocol,
    this.transcodeSpeed,
    this.transcodeThrottled,
    this.transcodeWidth,
    this.throttled,
  });

  /// Parses an [ActivitySession] from a Tautulli API JSON map.
  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      // Source audio
      audioChannelLayout: Cast.castToString(json['audio_channel_layout']),
      audioBitrate: Cast.castToInt(json['audio_bitrate']),
      audioChannels: Cast.castToInt(json['audio_channels']),
      audioCodec: Cast.castToString(json['audio_codec']),
      audioDecision: StreamDecision.fromString(Cast.castToString(json['audio_decision'])),
      audioLanguage: Cast.castToString(json['audio_language']),
      audioProfile: Cast.castToString(json['audio_profile']),
      audioSampleRate: Cast.castToInt(json['audio_sample_rate']),

      bandwidth: Cast.castToInt(json['bandwidth']),
      channelCallSign: Cast.castToString(json['channel_call_sign']),
      container: Cast.castToString(json['container']),
      containerDecision: StreamDecision.fromString(Cast.castToString(json['container_decision'])),

      // Duration / progress
      duration: _durationFromMillisString(json['duration']),
      progressPercent: Cast.castToInt(json['progress_percent']),
      viewOffset: Cast.castToInt(json['view_offset']),

      // User / device
      allowGuest: Cast.castToBool(json['allow_guest']),
      friendlyName: Cast.castToString(json['friendly_name']),
      ipAddress: Cast.castToString(json['ip_address']),
      ipAddressPublic: Cast.castToString(json['ip_address_public']),
      machineId: Cast.castToString(json['machine_id']),
      platform: Cast.castToString(json['platform']),
      platformName: Cast.castToString(json['platform_name']),
      platformVersion: Cast.castToString(json['platform_version']),
      player: Cast.castToString(json['player']),
      product: Cast.castToString(json['product']),
      productVersion: Cast.castToString(json['product_version']),
      qualityProfile: Cast.castToString(json['quality_profile']),
      relay: Cast.castToBool(json['relay']),
      secure: Cast.castToBool(json['secure']),
      sessionId: Cast.castToString(json['session_id']),
      sessionKey: Cast.castToInt(json['session_key']),

      // Media identity
      actors: (json['actors'] as List?)?.whereType<String>().toList(),
      addedAt: Cast.castToString(json['added_at']),
      art: Cast.castToString(json['art']),
      fullTitle: Cast.castToString(json['full_title']),
      grandparentRatingKey: Cast.castToInt(json['grandparent_rating_key']),
      grandparentThumb: Cast.castToString(json['grandparent_thumb']),
      grandparentTitle: Cast.castToString(json['grandparent_title']),
      live: Cast.castToBool(json['live']),
      liveUuid: Cast.castToString(json['live_uuid']),
      local: Cast.castToBool(json['local']),
      location: Location.fromString(Cast.castToString(json['location'])),
      mediaIndex: Cast.castToInt(json['media_index']),
      mediaType: MediaType.fromString(Cast.castToString(json['media_type'])),
      optimizedVersion: Cast.castToBool(json['optimized_version']),
      optimizedVersionProfile: Cast.castToString(json['optimized_version_profile']),
      optimizedVersionTitle: Cast.castToString(json['optimized_version_title']),
      originallyAvailableAt: _dateTimeFromString(json['originally_available_at']),
      originalTitle: Cast.castToString(json['original_title']),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      parentThumb: Cast.castToString(json['parent_thumb']),
      parentTitle: Cast.castToString(json['parent_title']),
      ratingKey: Cast.castToInt(json['rating_key']),
      sectionId: Cast.castToInt(json['section_id']),
      state: PlaybackState.fromString(Cast.castToString(json['state'])),
      subType: Cast.castToString(json['sub_type']),
      thumb: Cast.castToString(json['thumb']),
      title: Cast.castToString(json['title']),
      type: Cast.castToString(json['type']),
      userId: Cast.castToInt(json['user_id']),
      userThumb: Cast.castToString(json['user_thumb']),
      width: Cast.castToInt(json['width']),
      height: Cast.castToInt(json['height']),
      year: Cast.castToInt(json['year']),

      // Stream info
      streamAspectRatio: Cast.castToString(json['stream_aspect_ratio']),
      streamBitrate: Cast.castToInt(json['stream_bitrate']),
      streamContainer: Cast.castToString(json['stream_container']),
      streamContainerDecision: StreamDecision.fromString(Cast.castToString(json['stream_container_decision'])),
      streamDuration: _durationFromMillisString(json['stream_duration']),

      // Stream audio
      streamAudioBitrate: Cast.castToInt(json['stream_audio_bitrate']),
      streamAudioChannelLayout: Cast.castToString(json['stream_audio_channel_layout']),
      streamAudioChannels: Cast.castToInt(json['stream_audio_channels']),
      streamAudioCodec: Cast.castToString(json['stream_audio_codec']),
      streamAudioDecision: StreamDecision.fromString(Cast.castToString(json['stream_audio_decision'])),
      streamAudioLanguage: Cast.castToString(json['stream_audio_language']),
      streamAudioLanguageCode: Cast.castToString(json['stream_audio_language_code']),
      streamAudioProfile: Cast.castToString(json['stream_audio_profile']),
      streamAudioSampleRate: Cast.castToInt(json['stream_audio_sample_rate']),

      // Stream subtitle
      streamSubtitleCodec: Cast.castToString(json['stream_subtitle_codec']),
      streamSubtitleContainer: Cast.castToString(json['stream_subtitle_container']),
      streamSubtitleDecision: SubtitleDecision.fromString(Cast.castToString(json['stream_subtitle_decision'])),
      streamSubtitleForced: Cast.castToBool(json['stream_subtitle_forced']),
      streamSubtitleFormat: Cast.castToString(json['stream_subtitle_format']),
      streamSubtitleLanguage: Cast.castToString(json['stream_subtitle_language']),
      streamSubtitleLanguageCode: Cast.castToString(json['stream_subtitle_language_code']),
      streamSubtitleLocation: Cast.castToString(json['stream_subtitle_location']),

      // Stream video
      streamVideoBitDepth: Cast.castToInt(json['stream_video_bit_depth']),
      streamVideoChromaSubsampling: Cast.castToString(json['stream_video_chroma_subsampling']),
      streamVideoCodec: Cast.castToString(json['stream_video_codec']),
      streamVideoCodecLevel: Cast.castToString(json['stream_video_codec_level']),
      streamVideoColorPrimaries: Cast.castToString(json['stream_video_color_primaries']),
      streamVideoColorRange: Cast.castToString(json['stream_video_color_range']),
      streamVideoColorSpace: Cast.castToString(json['stream_video_color_space']),
      streamVideoColorTrc: Cast.castToString(json['stream_video_color_trc']),
      streamVideoDecision: StreamDecision.fromString(Cast.castToString(json['stream_video_decision'])),
      streamVideoDynamicRange: Cast.castToString(json['stream_video_dynamic_range']),
      streamVideoFramerate: Cast.castToString(json['stream_video_framerate']),
      streamVideoFullResolution: Cast.castToString(json['stream_video_full_resolution']),
      streamVideoHeight: Cast.castToInt(json['stream_video_height']),
      streamVideoLanguage: Cast.castToString(json['stream_video_language']),
      streamVideoLanguageCode: Cast.castToString(json['stream_video_language_code']),
      streamVideoRefFrames: Cast.castToInt(json['stream_video_ref_frames']),
      streamVideoResolution: Cast.castToString(json['stream_video_resolution']),
      streamVideoScanType: Cast.castToString(json['stream_video_scan_type']),
      streamVideoWidth: Cast.castToInt(json['stream_video_width']),

      // Source subtitle
      subtitleCodec: Cast.castToString(json['subtitle_codec']),
      subtitleContainer: Cast.castToString(json['subtitle_container']),
      subtitleForced: Cast.castToBool(json['subtitle_forced']),
      subtitleFormat: Cast.castToString(json['subtitle_format']),
      subtitleLanguage: Cast.castToString(json['subtitle_language']),
      subtitleLanguageCode: Cast.castToString(json['subtitle_language_code']),
      subtitleLocation: Cast.castToString(json['subtitle_location']),
      subtitles: Cast.castToBool(json['subtitles']),

      // Source video
      videoCodec: Cast.castToString(json['video_codec']),
      videoDecision: StreamDecision.fromString(Cast.castToString(json['video_decision'])),
      videoBitDepth: Cast.castToInt(json['video_bit_depth']),
      videoCodecLevel: Cast.castToString(json['video_codec_level']),
      videoColorPrimaries: Cast.castToString(json['video_color_primaries']),
      videoColorRange: Cast.castToString(json['video_color_range']),
      videoColorSpace: Cast.castToString(json['video_color_space']),
      videoColorTrc: Cast.castToString(json['video_color_trc']),
      videoDynamicRange: Cast.castToString(json['video_dynamic_range']),
      videoFrameRate: Cast.castToString(json['video_frame_rate']),
      videoFullResolution: Cast.castToString(json['video_full_resolution']),
      videoLanguage: Cast.castToString(json['video_language']),
      videoLanguageCode: Cast.castToString(json['video_language_code']),
      videoProfile: Cast.castToString(json['video_profile']),
      videoRefFrames: Cast.castToInt(json['video_ref_frames']),
      videoResolution: Cast.castToString(json['video_resolution']),
      videoScanType: Cast.castToString(json['video_scan_type']),

      // Transcode
      transcodeDecision: StreamDecision.fromString(Cast.castToString(json['transcode_decision'])),
      transcodeContainer: Cast.castToString(json['transcode_container']),
      transcodeHeight: Cast.castToInt(json['transcode_height']),
      transcodeHwDecoding: Cast.castToBool(json['transcode_hw_decoding']),
      transcodeHwDecode: Cast.castToString(json['transcode_hw_decode']),
      transcodeHwDecodeTitle: Cast.castToString(json['transcode_hw_decode_title']),
      transcodeHwEncoding: Cast.castToBool(json['transcode_hw_encoding']),
      transcodeHwFullPipeline: Cast.castToBool(json['transcode_hw_full_pipeline']),
      transcodeHwRequested: Cast.castToBool(json['transcode_hw_requested']),
      transcodeKey: Cast.castToString(json['transcode_key']),
      transcodeMaxOffsetAvailable: Cast.castToInt(json['transcode_max_offset_available']),
      transcodeMinOffsetAvailable: Cast.castToInt(json['transcode_min_offset_available']),
      transcodeProgress: Cast.castToInt(json['transcode_progress']),
      transcodeProtocol: Cast.castToString(json['transcode_protocol']),
      transcodeSpeed: Cast.castToDouble(json['transcode_speed']),
      transcodeThrottled: Cast.castToBool(json['transcode_throttled']),
      transcodeWidth: Cast.castToInt(json['transcode_width']),
      throttled: Cast.castToBool(json['throttled']),
    );
  }

  static DateTime? _dateTimeFromString(dynamic value) {
    final s = Cast.castToString(value);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static Duration? _durationFromMillisString(dynamic value) {
    final ms = Cast.castToInt(value);
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }
}
