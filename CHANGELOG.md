# Changelog

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
- Minimum supported Tautulli server: v2.10.5
- Last verified against Tautulli: v2.17.0
