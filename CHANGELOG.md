# Changelog

## 3.3.0-wip

### Breaking

- Changed `buildImageUrl`'s `background` parameter from `int?` to `String?`. The server expects a hex
  color string such as `'282828'`, and the integer went out through `toString()` as a decimal the
  server could not use.
- Made `friendlyName` required on `setMobileDeviceConfig`. The server writes the name
  unconditionally, so a request without it stored an empty name.
- Removed `sessionKey` and `sessionId` from `serverStatus`. The handler reads no arguments and
  answers with the global connection flag.
- Removed `grouping` from `getUsers`. The handler builds the user list without arguments.
- Removed `username` from `deleteAllUserHistory` and changed `rowIds` to `List<int>?`. The handler
  forwards only `user_id` and `row_ids`.
- Removed `ms` from `getLogs`. The handler never reads it.
- Changed `exportMetadata`, `addNotifierConfig` and `addNewsletterConfig` to return the new export,
  notifier and newsletter id as `Future<int>`. The server sends it as `export_id`, `notifier_id`
  and `newsletter_id` in `data`, and the delete and configure calls need it.
- Changed `UserTableEntry.duration` from `int?` seconds to `Duration?`, matching
  `LibraryTableEntry.duration` for the same column.
- Removed `VideoDynamicRange`. No model used it, and the server joins `Dolby Vision`, `HLG`, `HDR10`
  and `HDR` with `/`, which the two `String` fields on `ActivitySession` already carry.
- Changed `rating`, `audienceRating` and `userRating` to `num?` on `ActivitySession` and
  `MediaItem`, matching `RecentlyAddedItem` and `HomeStat`. An empty string parses to `null`.
- Removed `ActivitySession.type`. It held the `streamType` of the last stream-detail dict Tautulli
  merges into a session (`3` when a subtitle stream is selected, empty otherwise), never the media
  type.
- Renamed `userId` to `userIds` (`List<int>?`) on every `GraphService` method. Each graph handler
  passes `user_id` through a condition builder that expects a comma-separated list.

### Fixed

- Stopped sending `refresh=0` and `return_hash=0` from `buildImageUrl` when the flags are false. The
  handler reads `refresh` by bare truthiness, so the string `'0'` bypassed the image cache on every
  request, and the API layer returns raw image bytes only when `return_hash` is absent from the
  request, so `return_hash=0` sent the bytes through the JSON encoder.
- Parsed `RecentlyAddedItem.duration` as milliseconds. The server sends Plex durations in
  milliseconds, so the value came out a thousand times too long.
- Read `UserData.userThumb` from the `thumb` key when `user_thumb` is absent. `get_users` sends the
  avatar as `thumb` and only `get_user` uses `user_thumb`, so the field was always null from
  `getUsers()`.

### Added

- Added `clip` to `buildImageUrl`, matching the handler's parameter.
- Added `totalDuration` and `filterDuration` to `PagedResult`, the human-readable watch times
  `get_history` sends next to its record counts. Other paged commands leave them null.
- Added `lastTriggered` and `lastSuccess` to `NotifierConfig` from `get_notifiers`, and `config`,
  `configOptions`, `actions`, `notifyText`, `customConditions` and `customConditionsLogic` from
  `get_notifier_config`, which sends no `active`.
- Added `statTitle` and `statType` to `HomeStatGroup`, and `stopped`, `libraryThumb` and
  `libraryArt` to `HomeStat` for the `most_concurrent` and `top_libraries` rows that carry them.
- Added `contentRating` and `collections` to `RecentlyAddedItem`.
- Added `markers` to `MediaItem`, the chapter markers `get_metadata` returns.
- Added `referenceId` to `getHistory`, the grouped-play filter the handler already applies.

### Behavior notes

- `regroupHistory` returns as soon as the server has started the regrouping on a background thread.
  Success means accepted, not finished.
- `get_server_id` with `get_url` or `test_websocket` answers HTTP 500 through the API on v2.18.1.
  The branch calls `self.get_server_resources`, which only the web interface class defines, so the
  API object raises. `getServerId` offers neither option and exposes no `url` or `ws`.

## 3.2.0

**Requires Tautulli v2.18.0 or newer.** Verified end-to-end against a live v2.18.1 server. The test
fixtures are full sanitized captures from that release.

### Breaking

- Requires Tautulli v2.18.0 or newer. The workarounds for v2.17.2 and earlier servers are gone.
- Removed parameters the server no longer accepts: `includeCloud` from `getServerList`, `agentId`
  from `setNotifierConfig` and `setNewsletterConfig`, `syncId` from `getMetadata`, and the
  `doNotify`/`doNotifyCreated` edit parameters.
- Removed `getSyncedItems` and `deleteSyncedItem`. Plex retired the Sync feature and Tautulli
  dropped the commands.
- Removed the `doNotify`/`doNotifyCreated` model fields and `RegisterDeviceResult.pmsIsCloud`, all
  dropped from the API.
- `getSettings` returns the raw sectioned JSON map (like `getDateFormats`) and the
  `TautulliSettings` model is gone. Read the format strings from `getDateFormats`.

### Fixed

- `getServerList(allServers: false)` was silently ignored on every server version: Tautulli tests
  `not (all_servers == 'false')`, so the usual `1`/`0` encoding always read as true. `allServers` is
  sent as the literal `'true'` or `'false'` instead.
- `editUser` and `editLibrary` are partial updates: every parameter except `userId`/`sectionId`
  is optional, matching `edit_user` and `edit_library` on v2.18.0, which update only the fields
  provided.
- `getPlexLog` accepts both `get_plex_log` response shapes: the bare list that shipped in v2.18.0,
  and the object nesting rows under `data.data` used before and after it.

### Added

- Opt-in `X-Api-Key` header auth: `apiKeyLocation: ApiKeyLocation.header` keeps the key out of URLs
  and access logs. The query parameter remains the default.
- `TautulliRedirectException` (a subtype of `TautulliConnectionException`) for redirect-limit and
  redirect-loop failures, typically a reverse proxy or access gateway answering an unauthenticated
  request with a login redirect. Before this release they were indistinguishable from an offline
  socket error.
- `TautulliRequestException` for a request that cannot be built, most often a custom header whose
  name or value is not valid HTTP. Earlier releases reported it as a connection failure.
- `pushToken` on `registerDevice`, for the Tautulli Remote relay push transport.
- `audioAtmos` and `streamAudioAtmos` on `ActivitySession` (server keys `audio_atmos` and
  `stream_audio_atmos`).

### Behavior notes

- `getMetadata` throws `TautulliServerException` for an unknown `rating_key`, and `getPlexLog`
  throws when the log cannot be read. Both are server `error` envelopes on v2.18.0 and newer. On
  v2.17.2 an unknown `rating_key` returned `success` with an empty `data`.
- `setNotifierConfig` and `setNewsletterConfig` are partial updates. Never write back a config map
  read from `getNotifierConfig` or `getNewsletterConfig`: the server masks passwords as four spaces,
  and storing that mask replaces the real password.

## 3.1.0

Every API command was verified end-to-end against a live Tautulli v2.17.2 server. This release
repairs calls, corrects method signatures, and rebuilds the test suite on full captured server
responses.

### Breaking

- Signatures corrected across services: phantom parameters removed, missing ones added
  (`exportMetadata`, `registerDevice`, `notify`, `deleteHistory`). `Cast` is no longer exported.
  Unexpected response shapes throw `TautulliBadResponseException` instead of returning empty models.

### Fixed

- Commands that failed or silently did nothing, including `notify`, `deleteHistory`,
  `logoutUserSession`, `getPlexLog`, `getHomeStats`, `getStreamData`, `docsMd`, `deleteLibrary`,
  image fallback URLs, and single-session `getActivity`.
- `editUser`/`editLibrary` corrupted boolean settings. Their fields are now required because the
  server overwrites every field on edit.
- Models were reading keys the server never sends (22 always-null fields). All `DateTime` values are
  now UTC: call `.toLocal()` for display.
- Downloads crashed the app when Tautulli served a file that was actively being written.

### Added

- Web and WASM support (the package no longer requires `dart:io`).
- `TautulliConnection` equality and `copyWith`, per-call timeouts, a separate `downloadTimeout`,
  chapter markers, typed notifier parameters, and many missing optional command parameters.

### Behavior notes

- `close()` no longer closes an injected `http.Client`.

## 3.0.1

- Fix unresolved dartdoc reference in `Cast`.
- Apply `dart format` to all source files.
- Expand `pubspec.yaml` description to meet pub.dev guidelines.

## 3.0.0

- Ownership of this package was transferred to the Tautulli team and v3.0.0 is a complete rewrite.
- Full coverage of Tautulli API as documented at:
  https://github.com/Tautulli/Tautulli/wiki/Tautulli-API-Reference.
