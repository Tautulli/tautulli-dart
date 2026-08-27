# Changelog

## 3.2.0

**Requires Tautulli v2.18.0 or newer.** Verified end-to-end against a live v2.18.1 server; the test
fixtures are full sanitized captures from that release.

### Breaking

- Requires Tautulli v2.18.0+; the workarounds for v2.17.2 and earlier are gone
- Removed parameters the server no longer accepts: `includeCloud` from `getServerList`, `agentId` from
  `setNotifierConfig` and `setNewsletterConfig`, `syncId` from `getMetadata`, and the
  `doNotify`/`doNotifyCreated` edit parameters
- Removed `getSyncedItems` and `deleteSyncedItem` — Plex retired the Sync feature and Tautulli removed
  the commands
- Removed the `doNotify`/`doNotifyCreated` model fields and `RegisterDeviceResult.pmsIsCloud`, all
  dropped from the API
- `getSettings` returns the raw sectioned JSON map (like `getDateFormats`); the `TautulliSettings` model
  is gone — use `getDateFormats` for the format strings

### Fixed

- `getServerList(allServers: false)` was silently ignored on every server version: Tautulli tests
  `not (all_servers == 'false')`, so the usual `1`/`0` encoding always read as true. It is now sent as a
  literal string
- `editUser` and `editLibrary` are partial updates with optional parameters, matching the server
- `getPlexLog` accepts both `get_plex_log` response shapes — the bare list that shipped in v2.18.0, and
  the object nesting rows under `data.data` used before and after it

### Added

- Opt-in `X-Api-Key` header auth: `apiKeyLocation: ApiKeyLocation.header` keeps the key out of URLs and
  access logs. The query parameter remains the default
- `TautulliRedirectException` (a subtype of `TautulliConnectionException`) for redirect-limit and
  redirect-loop failures — typically a reverse proxy or access gateway answering an unauthenticated
  request with a login redirect. Previously indistinguishable from an offline socket error
- `TautulliRequestException` for a request that cannot be built, most often a custom header whose name or
  value is not valid HTTP. Previously mislabeled as a connection failure
- `pushToken` on `registerDevice`, for the Tautulli Remote relay push transport
- `audioAtmos` and `streamAudioAtmos` on `ActivitySession`

### Behavior notes

- `getMetadata` throws `TautulliServerException` for an unknown `rating_key`, and `getPlexLog` throws
  when the log cannot be read — both now return error envelopes server-side
- `setNotifierConfig` and `setNewsletterConfig` are partial updates. Never write back a config map read
  from `getNotifierConfig` / `getNewsletterConfig`: the server masks passwords as four spaces, and
  storing that mask replaces the real password

## 3.1.0

Every API command was verified end-to-end against a live Tautulli v2.17.2 server. This release repairs calls, corrects method signatures, and rebuilds the test suite on full captured server responses.

- Fixed commands that previously failed or silently did nothing, including `notify`, `deleteHistory`,
  `logoutUserSession`, `getPlexLog`, `getHomeStats`, `getStreamData`, `docsMd`, `deleteLibrary`,
  image fallback URLs, and single-session `getActivity`
- Fixed `editUser`/`editLibrary` corrupting boolean settings; their fields are now required because the
  server overwrites every field on edit
- Fixed models reading keys the server never sends (22 always-null fields); all `DateTime` values are
  now UTC — call `.toLocal()` for display
- Fixed downloads crashing the app when Tautulli serves a file that is actively being written
- Breaking: signatures corrected across services (phantom parameters removed, missing ones added —
  notably `exportMetadata`, `registerDevice`, `notify`, `deleteHistory`); `Cast` is no longer exported;
  unexpected response shapes now throw `TautulliBadResponseException` instead of returning empty models
- Added web and WASM support (the package no longer requires `dart:io`)
- Added `TautulliConnection` equality and `copyWith`, per-call timeouts, a separate `downloadTimeout`,
  chapter markers, typed notifier parameters, and many missing optional command parameters
- `close()` no longer closes an injected `http.Client`

## 3.0.1

- Fix unresolved dartdoc reference in `Cast`
- Apply `dart format` to all source files
- Expand `pubspec.yaml` description to meet pub.dev guidelines

## 3.0.0

- Ownership of this package was transferred to the Tautulli team and v3.0.0 is a complete rewrite
- Full coverage of Tautulli API as documented at:
  https://github.com/Tautulli/Tautulli/wiki/Tautulli-API-Reference
