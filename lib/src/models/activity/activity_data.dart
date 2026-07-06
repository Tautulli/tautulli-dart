import '../../types/location.dart';
import '../../types/media_type.dart';
import '../../types/playback_state.dart';
import '../../types/stream_decision.dart';
import '../../types/subtitle_decision.dart';
import '../../utils/cast.dart';
import '../marker.dart';

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
      streamCountDirectStream: Cast.castToInt(
        json['stream_count_direct_stream'],
      ),
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

  /// Whether the source audio is Dolby Atmos.
  ///
  /// Only sent by Tautulli servers newer than v2.17.2; null on older servers.
  final bool? audioAtmos;

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
  final bool? relayed;

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

  /// Whether the streamed audio is Dolby Atmos.
  ///
  /// Only sent by Tautulli servers newer than v2.17.2; null on older servers.
  final bool? streamAudioAtmos;

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

  // ---- Extended fields (full get_activity session coverage) ----

  /// Session field `aspect_ratio` from `get_activity`.
  final String? aspectRatio;

  /// Session field `audience_rating` from `get_activity`.
  final String? audienceRating;

  /// Session field `audience_rating_image` from `get_activity`.
  final String? audienceRatingImage;

  /// Session field `audio_bitrate_mode` from `get_activity`.
  final String? audioBitrateMode;

  /// Session field `audio_language_code` from `get_activity`.
  final String? audioLanguageCode;

  /// Session field `banner` from `get_activity`.
  final String? banner;

  /// Session field `begins_at` from `get_activity`.
  final int? beginsAt;

  /// Session field `bif_thumb` from `get_activity`.
  final String? bifThumb;

  /// Session field `bitrate` from `get_activity`.
  final int? bitrate;

  /// Session field `channel_id` from `get_activity`.
  final String? channelId;

  /// Session field `channel_identifier` from `get_activity`.
  final String? channelIdentifier;

  /// Session field `channel_stream` from `get_activity`.
  final int? channelStream;

  /// Session field `channel_thumb` from `get_activity`.
  final String? channelThumb;

  /// Session field `channel_title` from `get_activity`.
  final String? channelTitle;

  /// Session field `channel_vcn` from `get_activity`.
  final String? channelVcn;

  /// Session field `children_count` from `get_activity`.
  final int? childrenCount;

  /// Session field `collections` from `get_activity`.
  final List<String>? collections;

  /// Session field `content_rating` from `get_activity`.
  final String? contentRating;

  /// Session field `deleted_user` from `get_activity`.
  final bool? deletedUser;

  /// Session field `device` from `get_activity`.
  final String? device;

  /// Session field `directors` from `get_activity`.
  final List<String>? directors;

  /// Session field `edition_title` from `get_activity`.
  final String? editionTitle;

  /// Session field `email` from `get_activity`.
  final String? email;

  /// Session field `ends_at` from `get_activity`.
  final int? endsAt;

  /// Session field `file` from `get_activity`.
  final String? file;

  /// Session field `file_size` from `get_activity`.
  final int? fileSize;

  /// Session field `genres` from `get_activity`.
  final List<String>? genres;

  /// Session field `grandparent_guid` from `get_activity`.
  final String? grandparentGuid;

  /// Session field `grandparent_guids` from `get_activity`.
  final List<String>? grandparentGuids;

  /// Session field `grandparent_slug` from `get_activity`.
  final String? grandparentSlug;

  /// Session field `grandparent_year` from `get_activity`.
  final String? grandparentYear;

  /// Session field `guid` from `get_activity`.
  final String? guid;

  /// Session field `guids` from `get_activity`.
  final List<String>? guids;

  /// Session field `id` from `get_activity`.
  final String? id;

  /// Session field `indexes` from `get_activity`.
  final int? indexes;

  /// Session field `is_active` from `get_activity`.
  final bool? isActive;

  /// Session field `is_admin` from `get_activity`.
  final bool? isAdmin;

  /// Session field `is_allow_sync` from `get_activity`.
  final bool? isAllowSync;

  /// Session field `is_home_user` from `get_activity`.
  final bool? isHomeUser;

  /// Session field `is_restricted` from `get_activity`.
  final bool? isRestricted;

  /// Session field `keep_history` from `get_activity`.
  final bool? keepHistory;

  /// Session field `labels` from `get_activity`.
  final List<String>? labels;

  /// Session field `last_seen` from `get_activity`.
  final int? lastSeen;

  /// Session field `last_viewed_at` from `get_activity`.
  final int? lastViewedAt;

  /// Session field `library_name` from `get_activity`.
  final String? libraryName;

  /// Session field `markers` from `get_activity`.
  final List<Marker>? markers;

  /// Session field `parent_guid` from `get_activity`.
  final String? parentGuid;

  /// Session field `parent_guids` from `get_activity`.
  final List<String>? parentGuids;

  /// Session field `parent_slug` from `get_activity`.
  final String? parentSlug;

  /// Session field `parent_year` from `get_activity`.
  final String? parentYear;

  /// Session field `profile` from `get_activity`.
  final String? profile;

  /// Session field `protocol` from `get_activity`.
  final String? protocol;

  /// Session field `rating` from `get_activity`.
  final String? rating;

  /// Session field `rating_image` from `get_activity`.
  final String? ratingImage;

  /// Session field `row_id` from `get_activity`.
  final int? rowId;

  /// Session field `selected` from `get_activity`.
  final bool? selected;

  /// Session field `shared_libraries` from `get_activity`.
  final List<String>? sharedLibraries;

  /// Session field `slug` from `get_activity`.
  final String? slug;

  /// Session field `sort_title` from `get_activity`.
  final String? sortTitle;

  /// Session field `stream_audio_bitrate_mode` from `get_activity`.
  final String? streamAudioBitrateMode;

  /// Session field `stream_audio_channel_layout_` from `get_activity`.
  final String? streamAudioChannelLayoutFull;

  /// Session field `stream_subtitle_transient` from `get_activity`.
  final bool? streamSubtitleTransient;

  /// Session field `stream_video_bitrate` from `get_activity`.
  final int? streamVideoBitrate;

  /// Session field `stream_video_dovi_bl_present` from `get_activity`.
  final bool? streamVideoDoviBlPresent;

  /// Session field `stream_video_dovi_el_present` from `get_activity`.
  final bool? streamVideoDoviElPresent;

  /// Session field `stream_video_dovi_level` from `get_activity`.
  final int? streamVideoDoviLevel;

  /// Session field `stream_video_dovi_present` from `get_activity`.
  final bool? streamVideoDoviPresent;

  /// Session field `stream_video_dovi_profile` from `get_activity`.
  final int? streamVideoDoviProfile;

  /// Session field `stream_video_dovi_rpu_present` from `get_activity`.
  final bool? streamVideoDoviRpuPresent;

  /// Session field `stream_video_dovi_version` from `get_activity`.
  final int? streamVideoDoviVersion;

  /// Session field `studio` from `get_activity`.
  final String? studio;

  /// Session field `subtitle_decision` from `get_activity`.
  final String? subtitleDecision;

  /// Session field `summary` from `get_activity`.
  final String? summary;

  /// Session field `synced_version` from `get_activity`.
  final int? syncedVersion;

  /// Session field `synced_version_profile` from `get_activity`.
  final String? syncedVersionProfile;

  /// Session field `tagline` from `get_activity`.
  final String? tagline;

  /// Session field `transcode_audio_channels` from `get_activity`.
  final String? transcodeAudioChannels;

  /// Session field `transcode_audio_codec` from `get_activity`.
  final String? transcodeAudioCodec;

  /// Session field `transcode_hw_encode` from `get_activity`.
  final String? transcodeHwEncode;

  /// Session field `transcode_hw_encode_title` from `get_activity`.
  final String? transcodeHwEncodeTitle;

  /// Session field `transcode_video_codec` from `get_activity`.
  final String? transcodeVideoCodec;

  /// Session field `updated_at` from `get_activity`.
  final int? updatedAt;

  /// Session field `user` from `get_activity`.
  final String? user;

  /// Session field `user_rating` from `get_activity`.
  final String? userRating;

  /// Session field `username` from `get_activity`.
  final String? username;

  /// Session field `video_bitrate` from `get_activity`.
  final int? videoBitrate;

  /// Session field `video_chroma_subsampling` from `get_activity`.
  final String? videoChromaSubsampling;

  /// Session field `video_dovi_bl_present` from `get_activity`.
  final bool? videoDoviBlPresent;

  /// Session field `video_dovi_el_present` from `get_activity`.
  final bool? videoDoviElPresent;

  /// Session field `video_dovi_level` from `get_activity`.
  final int? videoDoviLevel;

  /// Session field `video_dovi_present` from `get_activity`.
  final bool? videoDoviPresent;

  /// Session field `video_dovi_profile` from `get_activity`.
  final int? videoDoviProfile;

  /// Session field `video_dovi_rpu_present` from `get_activity`.
  final bool? videoDoviRpuPresent;

  /// Session field `video_dovi_version` from `get_activity`.
  final int? videoDoviVersion;

  /// Session field `video_framerate` from `get_activity`.
  final String? videoFramerate;

  /// Session field `video_height` from `get_activity`.
  final int? videoHeight;

  /// Session field `video_width` from `get_activity`.
  final int? videoWidth;

  /// Session field `writers` from `get_activity`.
  final List<String>? writers;

  const ActivitySession({
    this.audioChannelLayout,
    this.audioBitrate,
    this.audioChannels,
    this.audioCodec,
    this.audioDecision,
    this.audioLanguage,
    this.audioAtmos,
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
    this.relayed,
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
    this.streamAudioAtmos,
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
    this.aspectRatio,
    this.audienceRating,
    this.audienceRatingImage,
    this.audioBitrateMode,
    this.audioLanguageCode,
    this.banner,
    this.beginsAt,
    this.bifThumb,
    this.bitrate,
    this.channelId,
    this.channelIdentifier,
    this.channelStream,
    this.channelThumb,
    this.channelTitle,
    this.channelVcn,
    this.childrenCount,
    this.collections,
    this.contentRating,
    this.deletedUser,
    this.device,
    this.directors,
    this.editionTitle,
    this.email,
    this.endsAt,
    this.file,
    this.fileSize,
    this.genres,
    this.grandparentGuid,
    this.grandparentGuids,
    this.grandparentSlug,
    this.grandparentYear,
    this.guid,
    this.guids,
    this.id,
    this.indexes,
    this.isActive,
    this.isAdmin,
    this.isAllowSync,
    this.isHomeUser,
    this.isRestricted,
    this.keepHistory,
    this.labels,
    this.lastSeen,
    this.lastViewedAt,
    this.libraryName,
    this.markers,
    this.parentGuid,
    this.parentGuids,
    this.parentSlug,
    this.parentYear,
    this.profile,
    this.protocol,
    this.rating,
    this.ratingImage,
    this.rowId,
    this.selected,
    this.sharedLibraries,
    this.slug,
    this.sortTitle,
    this.streamAudioBitrateMode,
    this.streamAudioChannelLayoutFull,
    this.streamSubtitleTransient,
    this.streamVideoBitrate,
    this.streamVideoDoviBlPresent,
    this.streamVideoDoviElPresent,
    this.streamVideoDoviLevel,
    this.streamVideoDoviPresent,
    this.streamVideoDoviProfile,
    this.streamVideoDoviRpuPresent,
    this.streamVideoDoviVersion,
    this.studio,
    this.subtitleDecision,
    this.summary,
    this.syncedVersion,
    this.syncedVersionProfile,
    this.tagline,
    this.transcodeAudioChannels,
    this.transcodeAudioCodec,
    this.transcodeHwEncode,
    this.transcodeHwEncodeTitle,
    this.transcodeVideoCodec,
    this.updatedAt,
    this.user,
    this.userRating,
    this.username,
    this.videoBitrate,
    this.videoChromaSubsampling,
    this.videoDoviBlPresent,
    this.videoDoviElPresent,
    this.videoDoviLevel,
    this.videoDoviPresent,
    this.videoDoviProfile,
    this.videoDoviRpuPresent,
    this.videoDoviVersion,
    this.videoFramerate,
    this.videoHeight,
    this.videoWidth,
    this.writers,
  });

  /// Parses an [ActivitySession] from a Tautulli API JSON map.
  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      // Source audio
      audioChannelLayout: Cast.castToString(json['audio_channel_layout']),
      audioBitrate: Cast.castToInt(json['audio_bitrate']),
      audioChannels: Cast.castToInt(json['audio_channels']),
      audioCodec: Cast.castToString(json['audio_codec']),
      audioDecision: StreamDecision.fromString(
        Cast.castToString(json['audio_decision']),
      ),
      audioLanguage: Cast.castToString(json['audio_language']),
      audioAtmos: Cast.castToBool(json['audio_atmos']),
      audioProfile: Cast.castToString(json['audio_profile']),
      audioSampleRate: Cast.castToInt(json['audio_sample_rate']),

      bandwidth: Cast.castToInt(json['bandwidth']),
      channelCallSign: Cast.castToString(json['channel_call_sign']),
      container: Cast.castToString(json['container']),
      containerDecision: StreamDecision.fromString(
        Cast.castToString(json['container_decision']),
      ),

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
      relayed: Cast.castToBool(json['relayed']),
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
      optimizedVersionProfile: Cast.castToString(
        json['optimized_version_profile'],
      ),
      optimizedVersionTitle: Cast.castToString(json['optimized_version_title']),
      originallyAvailableAt: _dateTimeFromString(
        json['originally_available_at'],
      ),
      originalTitle: Cast.castToString(json['original_title']),
      parentMediaIndex: Cast.castToInt(json['parent_media_index']),
      parentRatingKey: Cast.castToInt(json['parent_rating_key']),
      parentThumb: Cast.castToString(json['parent_thumb']),
      parentTitle: Cast.castToString(json['parent_title']),
      ratingKey: Cast.castToInt(json['rating_key']),
      sectionId: Cast.castToInt(json['section_id']),
      state: PlaybackState.fromString(Cast.castToString(json['state'])),
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
      streamContainerDecision: StreamDecision.fromString(
        Cast.castToString(json['stream_container_decision']),
      ),
      streamDuration: _durationFromMillisString(json['stream_duration']),

      // Stream audio
      streamAudioBitrate: Cast.castToInt(json['stream_audio_bitrate']),
      streamAudioChannelLayout: Cast.castToString(
        json['stream_audio_channel_layout'],
      ),
      streamAudioChannels: Cast.castToInt(json['stream_audio_channels']),
      streamAudioCodec: Cast.castToString(json['stream_audio_codec']),
      streamAudioDecision: StreamDecision.fromString(
        Cast.castToString(json['stream_audio_decision']),
      ),
      streamAudioLanguage: Cast.castToString(json['stream_audio_language']),
      streamAudioLanguageCode: Cast.castToString(
        json['stream_audio_language_code'],
      ),
      streamAudioAtmos: Cast.castToBool(json['stream_audio_atmos']),
      streamAudioProfile: Cast.castToString(json['stream_audio_profile']),
      streamAudioSampleRate: Cast.castToInt(json['stream_audio_sample_rate']),

      // Stream subtitle
      streamSubtitleCodec: Cast.castToString(json['stream_subtitle_codec']),
      streamSubtitleContainer: Cast.castToString(
        json['stream_subtitle_container'],
      ),
      streamSubtitleDecision: SubtitleDecision.fromString(
        Cast.castToString(json['stream_subtitle_decision']),
      ),
      streamSubtitleForced: Cast.castToBool(json['stream_subtitle_forced']),
      streamSubtitleFormat: Cast.castToString(json['stream_subtitle_format']),
      streamSubtitleLanguage: Cast.castToString(
        json['stream_subtitle_language'],
      ),
      streamSubtitleLanguageCode: Cast.castToString(
        json['stream_subtitle_language_code'],
      ),
      streamSubtitleLocation: Cast.castToString(
        json['stream_subtitle_location'],
      ),

      // Stream video
      streamVideoBitDepth: Cast.castToInt(json['stream_video_bit_depth']),
      streamVideoChromaSubsampling: Cast.castToString(
        json['stream_video_chroma_subsampling'],
      ),
      streamVideoCodec: Cast.castToString(json['stream_video_codec']),
      streamVideoCodecLevel: Cast.castToString(
        json['stream_video_codec_level'],
      ),
      streamVideoColorPrimaries: Cast.castToString(
        json['stream_video_color_primaries'],
      ),
      streamVideoColorRange: Cast.castToString(
        json['stream_video_color_range'],
      ),
      streamVideoColorSpace: Cast.castToString(
        json['stream_video_color_space'],
      ),
      streamVideoColorTrc: Cast.castToString(json['stream_video_color_trc']),
      streamVideoDecision: StreamDecision.fromString(
        Cast.castToString(json['stream_video_decision']),
      ),
      streamVideoDynamicRange: Cast.castToString(
        json['stream_video_dynamic_range'],
      ),
      streamVideoFramerate: Cast.castToString(json['stream_video_framerate']),
      streamVideoFullResolution: Cast.castToString(
        json['stream_video_full_resolution'],
      ),
      streamVideoHeight: Cast.castToInt(json['stream_video_height']),
      streamVideoLanguage: Cast.castToString(json['stream_video_language']),
      streamVideoLanguageCode: Cast.castToString(
        json['stream_video_language_code'],
      ),
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
      videoDecision: StreamDecision.fromString(
        Cast.castToString(json['video_decision']),
      ),
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
      transcodeDecision: StreamDecision.fromString(
        Cast.castToString(json['transcode_decision']),
      ),
      transcodeContainer: Cast.castToString(json['transcode_container']),
      transcodeHeight: Cast.castToInt(json['transcode_height']),
      transcodeHwDecoding: Cast.castToBool(json['transcode_hw_decoding']),
      transcodeHwDecode: Cast.castToString(json['transcode_hw_decode']),
      transcodeHwDecodeTitle: Cast.castToString(
        json['transcode_hw_decode_title'],
      ),
      transcodeHwEncoding: Cast.castToBool(json['transcode_hw_encoding']),
      transcodeHwFullPipeline: Cast.castToBool(
        json['transcode_hw_full_pipeline'],
      ),
      transcodeHwRequested: Cast.castToBool(json['transcode_hw_requested']),
      transcodeKey: Cast.castToString(json['transcode_key']),
      transcodeMaxOffsetAvailable: Cast.castToInt(
        json['transcode_max_offset_available'],
      ),
      transcodeMinOffsetAvailable: Cast.castToInt(
        json['transcode_min_offset_available'],
      ),
      transcodeProgress: Cast.castToInt(json['transcode_progress']),
      transcodeProtocol: Cast.castToString(json['transcode_protocol']),
      transcodeSpeed: Cast.castToDouble(json['transcode_speed']),
      transcodeThrottled: Cast.castToBool(json['transcode_throttled']),
      transcodeWidth: Cast.castToInt(json['transcode_width']),
      throttled: Cast.castToBool(json['throttled']),

      // Extended fields
      aspectRatio: Cast.castToString(json['aspect_ratio']),
      audienceRating: Cast.castToString(json['audience_rating']),
      audienceRatingImage: Cast.castToString(json['audience_rating_image']),
      audioBitrateMode: Cast.castToString(json['audio_bitrate_mode']),
      audioLanguageCode: Cast.castToString(json['audio_language_code']),
      banner: Cast.castToString(json['banner']),
      beginsAt: Cast.castToInt(json['begins_at']),
      bifThumb: Cast.castToString(json['bif_thumb']),
      bitrate: Cast.castToInt(json['bitrate']),
      channelId: Cast.castToString(json['channel_id']),
      channelIdentifier: Cast.castToString(json['channel_identifier']),
      channelStream: Cast.castToInt(json['channel_stream']),
      channelThumb: Cast.castToString(json['channel_thumb']),
      channelTitle: Cast.castToString(json['channel_title']),
      channelVcn: Cast.castToString(json['channel_vcn']),
      childrenCount: Cast.castToInt(json['children_count']),
      collections: (json['collections'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      contentRating: Cast.castToString(json['content_rating']),
      deletedUser: Cast.castToBool(json['deleted_user']),
      device: Cast.castToString(json['device']),
      directors: (json['directors'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      editionTitle: Cast.castToString(json['edition_title']),
      email: Cast.castToString(json['email']),
      endsAt: Cast.castToInt(json['ends_at']),
      file: Cast.castToString(json['file']),
      fileSize: Cast.castToInt(json['file_size']),
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      grandparentGuid: Cast.castToString(json['grandparent_guid']),
      grandparentGuids: (json['grandparent_guids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      grandparentSlug: Cast.castToString(json['grandparent_slug']),
      grandparentYear: Cast.castToString(json['grandparent_year']),
      guid: Cast.castToString(json['guid']),
      guids: (json['guids'] as List?)?.map((e) => e.toString()).toList(),
      id: Cast.castToString(json['id']),
      indexes: Cast.castToInt(json['indexes']),
      isActive: Cast.castToBool(json['is_active']),
      isAdmin: Cast.castToBool(json['is_admin']),
      isAllowSync: Cast.castToBool(json['is_allow_sync']),
      isHomeUser: Cast.castToBool(json['is_home_user']),
      isRestricted: Cast.castToBool(json['is_restricted']),
      keepHistory: Cast.castToBool(json['keep_history']),
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList(),
      lastSeen: Cast.castToInt(json['last_seen']),
      lastViewedAt: Cast.castToInt(json['last_viewed_at']),
      libraryName: Cast.castToString(json['library_name']),
      markers: _markersFromList(json['markers'] as List?),
      parentGuid: Cast.castToString(json['parent_guid']),
      parentGuids: (json['parent_guids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      parentSlug: Cast.castToString(json['parent_slug']),
      parentYear: Cast.castToString(json['parent_year']),
      profile: Cast.castToString(json['profile']),
      protocol: Cast.castToString(json['protocol']),
      rating: Cast.castToString(json['rating']),
      ratingImage: Cast.castToString(json['rating_image']),
      rowId: Cast.castToInt(json['row_id']),
      selected: Cast.castToBool(json['selected']),
      sharedLibraries: (json['shared_libraries'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      slug: Cast.castToString(json['slug']),
      sortTitle: Cast.castToString(json['sort_title']),
      streamAudioBitrateMode: Cast.castToString(
        json['stream_audio_bitrate_mode'],
      ),
      streamAudioChannelLayoutFull: Cast.castToString(
        json['stream_audio_channel_layout_'],
      ),
      streamSubtitleTransient: Cast.castToBool(
        json['stream_subtitle_transient'],
      ),
      streamVideoBitrate: Cast.castToInt(json['stream_video_bitrate']),
      streamVideoDoviBlPresent: Cast.castToBool(
        json['stream_video_dovi_bl_present'],
      ),
      streamVideoDoviElPresent: Cast.castToBool(
        json['stream_video_dovi_el_present'],
      ),
      streamVideoDoviLevel: Cast.castToInt(json['stream_video_dovi_level']),
      streamVideoDoviPresent: Cast.castToBool(
        json['stream_video_dovi_present'],
      ),
      streamVideoDoviProfile: Cast.castToInt(json['stream_video_dovi_profile']),
      streamVideoDoviRpuPresent: Cast.castToBool(
        json['stream_video_dovi_rpu_present'],
      ),
      streamVideoDoviVersion: Cast.castToInt(json['stream_video_dovi_version']),
      studio: Cast.castToString(json['studio']),
      subtitleDecision: Cast.castToString(json['subtitle_decision']),
      summary: Cast.castToString(json['summary']),
      syncedVersion: Cast.castToInt(json['synced_version']),
      syncedVersionProfile: Cast.castToString(json['synced_version_profile']),
      tagline: Cast.castToString(json['tagline']),
      transcodeAudioChannels: Cast.castToString(
        json['transcode_audio_channels'],
      ),
      transcodeAudioCodec: Cast.castToString(json['transcode_audio_codec']),
      transcodeHwEncode: Cast.castToString(json['transcode_hw_encode']),
      transcodeHwEncodeTitle: Cast.castToString(
        json['transcode_hw_encode_title'],
      ),
      transcodeVideoCodec: Cast.castToString(json['transcode_video_codec']),
      updatedAt: Cast.castToInt(json['updated_at']),
      user: Cast.castToString(json['user']),
      userRating: Cast.castToString(json['user_rating']),
      username: Cast.castToString(json['username']),
      videoBitrate: Cast.castToInt(json['video_bitrate']),
      videoChromaSubsampling: Cast.castToString(
        json['video_chroma_subsampling'],
      ),
      videoDoviBlPresent: Cast.castToBool(json['video_dovi_bl_present']),
      videoDoviElPresent: Cast.castToBool(json['video_dovi_el_present']),
      videoDoviLevel: Cast.castToInt(json['video_dovi_level']),
      videoDoviPresent: Cast.castToBool(json['video_dovi_present']),
      videoDoviProfile: Cast.castToInt(json['video_dovi_profile']),
      videoDoviRpuPresent: Cast.castToBool(json['video_dovi_rpu_present']),
      videoDoviVersion: Cast.castToInt(json['video_dovi_version']),
      videoFramerate: Cast.castToString(json['video_framerate']),
      videoHeight: Cast.castToInt(json['video_height']),
      videoWidth: Cast.castToInt(json['video_width']),
      writers: (json['writers'] as List?)?.map((e) => e.toString()).toList(),
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

  static List<Marker>? _markersFromList(List? markers) {
    if (markers == null) return null;
    return markers
        .whereType<Map<String, dynamic>>()
        .map(Marker.fromJson)
        .toList();
  }
}
