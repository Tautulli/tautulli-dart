/// Dart client for the Tautulli API.
///
/// Create a [TautulliClient] with a [TautulliConnection] to start making
/// requests. Each service (e.g. [ActivityService], [HistoryService]) is
/// accessible as a property on the client.
library;

// Client
export 'src/client.dart';
export 'src/connection.dart';
export 'src/exceptions.dart';
export 'src/executor.dart';

// Services
export 'src/services/activity_service.dart';
export 'src/services/api_service.dart';
export 'src/services/device_service.dart';
export 'src/services/export_service.dart';
export 'src/services/graph_service.dart';
export 'src/services/history_service.dart';
export 'src/services/image_service.dart';
export 'src/services/library_service.dart';
export 'src/services/log_service.dart';
export 'src/services/media_service.dart';
export 'src/services/network_service.dart';
export 'src/services/newsletter_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/plex_service.dart';
export 'src/services/tautulli_service.dart';
export 'src/services/user_service.dart';

// Types
export 'src/types/api_key_location.dart';
export 'src/types/graph_series_type.dart';
export 'src/types/image_fallback.dart';
export 'src/types/location.dart';
export 'src/types/media_type.dart';
export 'src/types/play_metric_type.dart';
export 'src/types/playback_state.dart';
export 'src/types/section_type.dart';
export 'src/types/stat_id_type.dart';
export 'src/types/stream_decision.dart';
export 'src/types/subtitle_decision.dart';
export 'src/types/video_dynamic_range.dart';
export 'src/types/watched_status.dart';

// Models
export 'src/models/marker.dart';
export 'src/models/paged_result.dart';
export 'src/models/activity/activity_data.dart';
export 'src/models/export/export_entry.dart';
export 'src/models/graph/graph_data.dart';
export 'src/models/history/history_entry.dart';
export 'src/models/history/home_stat_group.dart';
export 'src/models/library/library_entry.dart';
export 'src/models/library/library_media_item.dart';
export 'src/models/library/library_name.dart';
export 'src/models/library/library_table_entry.dart';
export 'src/models/library/library_user_stat.dart';
export 'src/models/library/library_watch_time_stat.dart';
export 'src/models/library/recently_added_item.dart';
export 'src/models/log/log_entry.dart';
export 'src/models/media/media_info.dart';
export 'src/models/media/media_item.dart';
export 'src/models/network/geo_ip_data.dart';
export 'src/models/newsletter/newsletter_config.dart';
export 'src/models/newsletter/newsletter_log_entry.dart';
export 'src/models/notification/notification_log_entry.dart';
export 'src/models/notification/notifier_config.dart';
export 'src/models/notification/notifier_parameter.dart';
export 'src/models/plex/plex_server_info.dart';
export 'src/models/tautulli/register_device_result.dart';
export 'src/models/user/user_data.dart';
export 'src/models/user/user_name.dart';
export 'src/models/user/user_player_stat.dart';
export 'src/models/user/user_table_entry.dart';
export 'src/models/user/user_watch_time_stat.dart';
