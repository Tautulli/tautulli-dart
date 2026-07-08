/// The command matrix for the live-capture campaign.
///
/// Each [CaptureEntry] is one raw HTTP GET against a live Tautulli server,
/// captured to the staging directory as `<domain>/<name>.json`. Values wrapped
/// in `{braces}` are placeholders resolved at runtime from server discovery
/// (see `capture.dart`), so the manifest itself contains no server-specific
/// data. See `test/CAPTURING.md` for the full process.
library;

/// Which credential the request is sent with.
enum AuthMode {
  /// The plain API key (`TAUTULLI_API_KEY`).
  plain,

  /// The device token (`TAUTULLI_DEVICE_TOKEN`) with `app=true`.
  deviceToken,

  /// The plain API key with `app=true` (server must reject).
  plainWithApp,

  /// The device token without `app=true` (server must reject).
  tokenNoApp,

  /// A syntactically valid but wrong key (server must reject).
  badKey,

  /// No `apikey` parameter at all (server must reject).
  noKey,
}

/// One raw capture: a single command + parameter combination.
class CaptureEntry {
  /// Fixture subfolder (mirrors `test/fixtures/<domain>/`).
  final String domain;

  /// File stem: `<cmd>` for the canonical response, `<cmd>__<variant>` for
  /// parameter variants, error shapes, and mutation states.
  final String name;

  /// The Tautulli API `cmd` value.
  final String cmd;

  /// Query parameters. Values may contain `{placeholder}` tokens.
  final Map<String, String> params;

  final AuthMode auth;

  /// True for endpoints that return file bytes; the body is not JSON-parsed
  /// and only response metadata is recorded.
  final bool binary;

  const CaptureEntry(
    this.domain,
    this.name,
    this.cmd, {
    this.params = const {},
    this.auth = AuthMode.plain,
    this.binary = false,
  });
}

/// The six-state authentication matrix (success and failure states).
const authEntries = <CaptureEntry>[
  CaptureEntry('auth', 'auth__plain', 'get_server_friendly_name'),
  CaptureEntry(
    'auth',
    'auth__token_app',
    'get_server_friendly_name',
    auth: AuthMode.deviceToken,
  ),
  CaptureEntry(
    'auth',
    'auth__plain_with_app',
    'get_server_friendly_name',
    auth: AuthMode.plainWithApp,
  ),
  CaptureEntry(
    'auth',
    'auth__token_no_app',
    'get_server_friendly_name',
    auth: AuthMode.tokenNoApp,
  ),
  CaptureEntry(
    'auth',
    'auth__bad_key',
    'get_server_friendly_name',
    auth: AuthMode.badKey,
  ),
  CaptureEntry(
    'auth',
    'auth__no_key',
    'get_server_friendly_name',
    auth: AuthMode.noKey,
  ),
];

/// Read-only commands and parameter/error variants. Safe to run repeatedly.
const readEntries = <CaptureEntry>[
  // --- tautulli ---------------------------------------------------------
  CaptureEntry('tautulli', 'get_tautulli_info', 'get_tautulli_info'),
  CaptureEntry('tautulli', 'get_date_formats', 'get_date_formats'),
  CaptureEntry('tautulli', 'get_settings', 'get_settings'),
  CaptureEntry(
    'tautulli',
    'get_settings__key_general',
    'get_settings',
    params: {'key': 'General'},
  ),
  CaptureEntry('tautulli', 'status', 'status'),
  CaptureEntry(
    'tautulli',
    'status__check_database',
    'status',
    params: {'check': 'database'},
  ),
  CaptureEntry('tautulli', 'update_check', 'update_check'),
  CaptureEntry(
    'tautulli',
    'sql__select1',
    'sql',
    params: {'query': 'SELECT 1 AS one'},
  ),
  CaptureEntry('tautulli', 'download_config', 'download_config', binary: true),
  CaptureEntry(
    'tautulli',
    'download_database',
    'download_database',
    binary: true,
  ),

  // --- api ----------------------------------------------------------------
  CaptureEntry('api', 'docs', 'docs'),
  CaptureEntry('api', 'docs_md', 'docs_md', binary: true),
  CaptureEntry('api', 'arnold', 'arnold'),

  // --- plex ---------------------------------------------------------------
  CaptureEntry('plex', 'get_server_info', 'get_server_info'),
  CaptureEntry('plex', 'get_server_identity', 'get_server_identity'),
  CaptureEntry('plex', 'get_server_friendly_name', 'get_server_friendly_name'),
  CaptureEntry(
    'plex',
    'get_server_id',
    'get_server_id',
    params: {'hostname': '{pmsHost}', 'port': '{pmsPort}'},
  ),
  CaptureEntry('plex', 'get_server_list', 'get_server_list'),
  CaptureEntry(
    'plex',
    'get_server_pref',
    'get_server_pref',
    params: {'pref': 'FriendlyName'},
  ),
  CaptureEntry('plex', 'get_servers_info', 'get_servers_info'),
  CaptureEntry('plex', 'get_pms_update', 'get_pms_update'),
  CaptureEntry('plex', 'server_status', 'server_status'),

  // --- library ------------------------------------------------------------
  CaptureEntry('library', 'get_libraries', 'get_libraries'),
  CaptureEntry('library', 'get_library_names', 'get_library_names'),
  CaptureEntry(
    'library',
    'get_library',
    'get_library',
    params: {'section_id': '{sectionId}'},
  ),
  CaptureEntry(
    'library',
    'get_library__last_accessed',
    'get_library',
    params: {'section_id': '{sectionId}', 'include_last_accessed': '1'},
  ),
  CaptureEntry(
    'library',
    'get_library__invalid_section',
    'get_library',
    params: {'section_id': '999999'},
  ),
  CaptureEntry('library', 'get_libraries_table', 'get_libraries_table'),
  CaptureEntry(
    'library',
    'get_libraries_table__search',
    'get_libraries_table',
    params: {
      'search': '{sectionName}',
      'order_column': 'plays',
      'order_dir': 'asc',
    },
  ),
  CaptureEntry(
    'library',
    'get_library_media_info',
    'get_library_media_info',
    params: {'section_id': '{sectionId}', 'length': '5'},
  ),
  CaptureEntry(
    'library',
    'get_library_user_stats',
    'get_library_user_stats',
    params: {'section_id': '{sectionId}'},
  ),
  CaptureEntry(
    'library',
    'get_library_watch_time_stats',
    'get_library_watch_time_stats',
    params: {'section_id': '{sectionId}', 'query_days': '1,7,30,0'},
  ),
  CaptureEntry(
    'library',
    'get_collections_table',
    'get_collections_table',
    params: {'section_id': '{sectionId}'},
  ),
  CaptureEntry('library', 'get_playlists_table', 'get_playlists_table'),
  CaptureEntry(
    'library',
    'get_recently_added',
    'get_recently_added',
    params: {'count': '5'},
  ),
  CaptureEntry(
    'library',
    'get_recently_added__movie',
    'get_recently_added',
    params: {'count': '5', 'media_type': 'movie'},
  ),
  CaptureEntry(
    'library',
    'get_recently_added__section',
    'get_recently_added',
    params: {'count': '5', 'section_id': '{sectionId}'},
  ),

  // --- user -----------------------------------------------------------------
  CaptureEntry('user', 'get_users', 'get_users'),
  CaptureEntry('user', 'get_user_names', 'get_user_names'),
  CaptureEntry('user', 'get_user', 'get_user', params: {'user_id': '{userId}'}),
  CaptureEntry(
    'user',
    'get_user__invalid',
    'get_user',
    params: {'user_id': '999999999'},
  ),
  CaptureEntry('user', 'get_users_table', 'get_users_table'),
  CaptureEntry(
    'user',
    'get_users_table__search',
    'get_users_table',
    params: {'length': '2', 'order_column': 'plays', 'order_dir': 'desc'},
  ),
  CaptureEntry(
    'user',
    'get_user_ips',
    'get_user_ips',
    params: {'user_id': '{userId}'},
  ),
  CaptureEntry('user', 'get_user_logins', 'get_user_logins'),
  CaptureEntry(
    'user',
    'get_user_player_stats',
    'get_user_player_stats',
    params: {'user_id': '{userId}'},
  ),
  CaptureEntry(
    'user',
    'get_user_watch_time_stats',
    'get_user_watch_time_stats',
    params: {'user_id': '{userId}', 'query_days': '1,7,30,0'},
  ),

  // --- history ----------------------------------------------------------------
  CaptureEntry(
    'history',
    'get_history',
    'get_history',
    params: {'length': '10'},
  ),
  CaptureEntry(
    'history',
    'get_history__user_id',
    'get_history',
    params: {'user_id': '{userId}', 'length': '5'},
  ),
  CaptureEntry(
    'history',
    'get_history__grouping',
    'get_history',
    params: {'grouping': '1', 'length': '5'},
  ),
  CaptureEntry(
    'history',
    'get_history__media_type',
    'get_history',
    params: {'media_type': 'movie', 'length': '5'},
  ),
  CaptureEntry(
    'history',
    'get_history__rating_key',
    'get_history',
    params: {'rating_key': '{ratingKey}', 'length': '5'},
  ),
  CaptureEntry(
    'history',
    'get_history__search_order',
    'get_history',
    params: {
      'length': '5',
      'order_column': 'date',
      'order_dir': 'asc',
      'start': '1',
    },
  ),
  CaptureEntry('history', 'get_home_stats', 'get_home_stats'),
  CaptureEntry(
    'history',
    'get_home_stats__duration',
    'get_home_stats',
    params: {'stats_type': 'duration'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__top_movies',
    'get_home_stats',
    params: {'stat_id': 'top_movies'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__top_tv',
    'get_home_stats',
    params: {'stat_id': 'top_tv'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__top_users',
    'get_home_stats',
    params: {'stat_id': 'top_users'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__last_watched',
    'get_home_stats',
    params: {'stat_id': 'last_watched'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__most_concurrent',
    'get_home_stats',
    params: {'stat_id': 'most_concurrent'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__count3',
    'get_home_stats',
    params: {'stats_count': '3', 'stats_start': '1'},
  ),
  CaptureEntry(
    'history',
    'get_home_stats__before_400',
    'get_home_stats',
    params: {'before': '2030-01-01'},
  ),

  // --- graphs -------------------------------------------------------------
  CaptureEntry(
    'graph',
    'get_plays_by_date',
    'get_plays_by_date',
    params: {'time_range': '30'},
  ),
  CaptureEntry(
    'graph',
    'get_plays_by_date__duration',
    'get_plays_by_date',
    params: {'time_range': '30', 'y_axis': 'duration'},
  ),
  CaptureEntry(
    'graph',
    'get_plays_by_date__user',
    'get_plays_by_date',
    params: {'time_range': '30', 'user_id': '{userId}'},
  ),
  CaptureEntry('graph', 'get_plays_by_dayofweek', 'get_plays_by_dayofweek'),
  CaptureEntry('graph', 'get_plays_by_hourofday', 'get_plays_by_hourofday'),
  CaptureEntry(
    'graph',
    'get_plays_by_source_resolution',
    'get_plays_by_source_resolution',
  ),
  CaptureEntry(
    'graph',
    'get_plays_by_stream_resolution',
    'get_plays_by_stream_resolution',
  ),
  CaptureEntry('graph', 'get_plays_by_stream_type', 'get_plays_by_stream_type'),
  CaptureEntry(
    'graph',
    'get_plays_by_top_10_platforms',
    'get_plays_by_top_10_platforms',
  ),
  CaptureEntry(
    'graph',
    'get_plays_by_top_10_users',
    'get_plays_by_top_10_users',
  ),
  CaptureEntry('graph', 'get_plays_per_month', 'get_plays_per_month'),
  CaptureEntry(
    'graph',
    'get_stream_type_by_top_10_platforms',
    'get_stream_type_by_top_10_platforms',
  ),
  CaptureEntry(
    'graph',
    'get_stream_type_by_top_10_users',
    'get_stream_type_by_top_10_users',
  ),
  CaptureEntry(
    'graph',
    'get_concurrent_streams_by_stream_type',
    'get_concurrent_streams_by_stream_type',
  ),

  // --- media ----------------------------------------------------------------
  CaptureEntry(
    'media',
    'get_metadata',
    'get_metadata',
    params: {'rating_key': '{ratingKey}'},
  ),
  CaptureEntry(
    'media',
    'get_metadata__episode',
    'get_metadata',
    params: {'rating_key': '{episodeRatingKey}'},
  ),
  CaptureEntry(
    'media',
    'get_metadata__invalid',
    'get_metadata',
    params: {'rating_key': '999999999'},
  ),
  CaptureEntry(
    'media',
    'get_children_metadata__show',
    'get_children_metadata',
    params: {'rating_key': '{showRatingKey}', 'media_type': 'show'},
  ),
  CaptureEntry(
    'media',
    'get_children_metadata',
    'get_children_metadata',
    params: {'rating_key': '{seasonRatingKey}', 'media_type': 'season'},
  ),
  CaptureEntry(
    'media',
    'get_new_rating_keys',
    'get_new_rating_keys',
    params: {'rating_key': '{showRatingKey}', 'media_type': 'show'},
  ),
  CaptureEntry(
    'media',
    'get_old_rating_keys',
    'get_old_rating_keys',
    params: {'rating_key': '{showRatingKey}', 'media_type': 'show'},
  ),
  // Canonical search sends a limit: omitting it hits a server-side bug
  // (empty `&limit=` rejected by the PMS) that always yields empty results.
  CaptureEntry(
    'media',
    'search',
    'search',
    params: {'query': '{searchTerm}', 'limit': '25'},
  ),
  CaptureEntry(
    'media',
    'search__no_limit_empty_list',
    'search',
    params: {'query': '{searchTerm}'},
  ),
  CaptureEntry(
    'media',
    'get_item_user_stats',
    'get_item_user_stats',
    params: {'rating_key': '{ratingKey}'},
  ),
  CaptureEntry(
    'media',
    'get_item_watch_time_stats',
    'get_item_watch_time_stats',
    params: {'rating_key': '{ratingKey}', 'query_days': '1,7,30,0'},
  ),

  // --- activity (no active session required) -------------------------------
  CaptureEntry('activity', 'get_activity', 'get_activity'),
  CaptureEntry(
    'activity',
    'get_stream_data__row_id',
    'get_stream_data',
    params: {'row_id': '{historyRowId}'},
  ),
  CaptureEntry(
    'activity',
    'terminate_session__error',
    'terminate_session',
    params: {'session_key': '999999'},
  ),

  // --- logs -----------------------------------------------------------------
  CaptureEntry('log', 'get_logs', 'get_logs', params: {'end': '10'}),
  CaptureEntry(
    'log',
    'get_logs__search',
    'get_logs',
    params: {'search': 'Tautulli', 'end': '5', 'order': 'desc'},
  ),
  CaptureEntry('log', 'get_plex_log', 'get_plex_log', params: {'window': '10'}),
  CaptureEntry(
    'log',
    'get_plex_log__logfile',
    'get_plex_log',
    params: {'window': '5', 'logfile': 'Plex Media Server'},
  ),
  CaptureEntry('log', 'download_log', 'download_log', binary: true),
  CaptureEntry('log', 'download_plex_log', 'download_plex_log', binary: true),

  // --- network ----------------------------------------------------------------
  CaptureEntry(
    'network',
    'get_geoip_lookup',
    'get_geoip_lookup',
    params: {'ip_address': '8.8.8.8'},
  ),
  CaptureEntry(
    'network',
    'get_whois_lookup',
    'get_whois_lookup',
    params: {'ip_address': '8.8.8.8'},
  ),

  // --- notifications (reads) --------------------------------------------------
  CaptureEntry('notification', 'get_notifiers', 'get_notifiers'),
  CaptureEntry(
    'notification',
    'get_notifier_parameters',
    'get_notifier_parameters',
  ),
  CaptureEntry(
    'notification',
    'get_notification_log',
    'get_notification_log',
    params: {'length': '5'},
  ),

  // --- newsletters (reads) ---------------------------------------------------
  CaptureEntry('newsletter', 'get_newsletters', 'get_newsletters'),
  CaptureEntry(
    'newsletter',
    'get_newsletter_log',
    'get_newsletter_log',
    params: {'length': '5'},
  ),

  // --- exports (reads) ---------------------------------------------------------
  // get_export_fields 500s when sub_media_type is omitted (server bug), so
  // the canonical success captures send an explicit empty sub_media_type.
  CaptureEntry(
    'export',
    'get_export_fields',
    'get_export_fields',
    params: {'media_type': 'movie', 'sub_media_type': ''},
  ),
  CaptureEntry(
    'export',
    'get_export_fields__show',
    'get_export_fields',
    params: {'media_type': 'show', 'sub_media_type': ''},
  ),
  CaptureEntry(
    'export',
    'get_export_fields__movie_no_sub_500',
    'get_export_fields',
    params: {'media_type': 'movie'},
  ),
  CaptureEntry(
    'export',
    'get_export_fields__collection',
    'get_export_fields',
    params: {'media_type': 'collection', 'sub_media_type': 'movie'},
  ),
  CaptureEntry(
    'export',
    'get_export_fields__collection_no_sub_500',
    'get_export_fields',
    params: {'media_type': 'collection'},
  ),
  CaptureEntry('export', 'get_exports_table', 'get_exports_table'),

  // --- generic error shapes ---------------------------------------------------
  CaptureEntry('errors', 'unknown_command', 'this_command_does_not_exist'),
  CaptureEntry('errors', 'missing_required_param', 'get_metadata'),
];
