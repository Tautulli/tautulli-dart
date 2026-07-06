# Changelog

## 3.2.0-beta.1

Prerelease tracking the **Tautulli nightly branch** (verified live at nightly commit
`bd28214`, July 2026), which fixed the server-side API issues flagged during the 3.1.0
verification campaigns. Stay on 3.1.0 for stable Tautulli servers (v2.17.2 and earlier);
this line becomes stable 3.2.0 when those fixes ship in a Tautulli release.

- Added opt-in `X-Api-Key` header auth: set `apiKeyLocation: ApiKeyLocation.header` on the
  connection to keep the key out of URLs and access logs (servers newer than v2.17.2 only;
  the query parameter remains the default and works everywhere)
- `editUser`/`editLibrary` are now partial updates with optional parameters — on servers
  up to v2.17.2 omitted fields are still reset server-side, so send every field there
- Removed the `doNotify`/`doNotifyCreated` model fields and edit parameters (the setting
  was removed from the Tautulli API)
- Added `audioAtmos`/`streamAudioAtmos` to `ActivitySession` (null on older servers)

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
