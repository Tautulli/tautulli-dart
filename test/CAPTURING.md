# Capturing real API responses (fixture regeneration)

Every file under `test/fixtures/` is a **real, sanitized Tautulli API response** captured from a live
server by the tooling in [`tool/live_capture/`](../tool/live_capture/). This document is the full,
reproducible process. It contains no server addresses or credentials — those are supplied via
environment variables at run time and never written into the repository.

## Prerequisites

1. **A disposable Tautulli test server.** The mutation and destructive phases create/edit/delete
   notifiers, newsletters, exports, devices, users, libraries, history rows, logs, and caches, and end
   with a `restart`. Never point this tooling at a production instance.
2. **A connected Plex Media Server** (never modified — all Plex-facing commands are read-only) with at
   least one movie library, one TV library, and some watch history across ≥ 2 users.
3. **Credentials**: the API key (Tautulli → Settings → Web Interface) and a device token (from a
   `register_device` call — the campaign registers its own throwaway device too).
4. Optional but recommended: `api_sql = 1` in the server's `config.ini` (set while Tautulli is stopped).
   Enables the `sql` command's success path, used as a storage oracle for the `edit_user`/`edit_library`
   integer-storage checks and for schema inspection.
5. Logged into the web UI at least once (populates the login log for `get_user_logins` /
   `logout_user_session`).

## Environment

```sh
export TAUTULLI_BASE_URL='http://<server>:<port>'   # no trailing slash
export TAUTULLI_API_KEY='<api key>'
export TAUTULLI_DEVICE_TOKEN='<device token>'
export TAUTULLI_STAGING_DIR='/tmp/tautulli-captures' # OUTSIDE the repo — raw captures are unsanitized
```

## Phases (run in this order)

```sh
dart run tool/live_capture/capture.dart --phase auth         # 6-state auth matrix
dart run tool/live_capture/capture.dart --phase reads        # ~110 read commands + variants
dart run tool/live_capture/verify.dart                       # package-path read sweep (~70 checks)
dart run tool/live_capture/capture.dart --phase stream       # needs an active throwaway stream; terminates it
dart run tool/live_capture/capture.dart --phase mutations    # reversible lifecycles (create→verify→cleanup)
dart run tool/live_capture/capture.dart --phase destructive  # deletes/purges; ends with restart
```

Notes:

- `capture.dart` performs **raw HTTP GETs** (ground truth) and writes them to the staging dir;
  mutation *verbs* go **through `TautulliClient`** so the package itself is exercised end-to-end.
  `verify.dart` runs every read method through the package and prints OK/FAIL per method.
- `--only <substring>` filters entries (reads) or lifecycles (mutations) for re-runs.
- Placeholders like `{sectionId}`/`{ratingKey}` in `manifest.dart` are resolved automatically from
  server discovery at startup; entries with unresolvable placeholders are skipped and logged.
- The stream phase exits with instructions if no session is active — start a throwaway playback,
  re-run, and it will capture the session shapes and then `terminate_session` it.
- Raw curl equivalent of any entry:
  `curl "$TAUTULLI_BASE_URL/api/v2?apikey=$TAUTULLI_API_KEY&cmd=<cmd>&<params>"`.
- A run log (`_log/run.jsonl` in the staging dir) records status/size/latency per call, plus every
  package-path outcome.

## Sanitizing → fixtures

```sh
dart run tool/live_capture/sanitize.dart          # staging → test/fixtures/ (deterministic)
dart run tool/live_capture/sanitize.dart --check  # audit: scans fixtures for any leaked value; exit 1 on hit
cp test/fixtures/tautulli/backup_config.json test/fixtures/success_response.json  # generic-success alias
```

The sanitizer collects sensitive values by key across all captures, assigns **stable placeholders**
(the same input always maps to the same alias, so identities stay consistent across files), and
rewrites every file. What is replaced and kept is documented in
[`test/fixtures/README.md`](fixtures/README.md). The value→placeholder map is written to
`<staging>/_log/sanitize_map.json` — it contains the real values and must **never** be committed.

Always re-run `--check` after sanitizing, and treat any hit as a stop-the-line bug in the sanitizer
(fix the rule, re-run; do not hand-edit the fixture output).

## After regeneration

1. `dart test` — expectation values in the service tests are tied to fixture content; reconcile any
   assertion that changed (the fixtures are the source of truth, never the tests).
2. `dart analyze` and `dart format --output=none --set-exit-if-changed .` must stay clean
   (`tool/` is analyzed too).
3. Update the provenance line (server version, capture date) in `test/fixtures/README.md`.
4. If the server version changed, cross-check the API surface first: shallow-clone Tautulli at the
   server's exact commit (`get_tautulli_info` → `tautulli_commit`), extract the `@addtoapi` command
   set from `plexpy/webserve.py` + the public methods of `API2` in `plexpy/api2.py`, and diff against
   the previous version's set.

## Known blockers (server-side)

- `download_database` / `download_plex_log` intermittently return **HTTP 500** ("returned more bytes
  than the declared Content-Length") when the file grows while being served — retry in a quiet moment.
- `search` without `limit` always returns `data: []` on current PMS versions (the server sends an
  empty `&limit=` that the PMS rejects).
- `get_export_fields` 500s unless `sub_media_type` is sent (empty string is accepted).
- A reverse-proxy `401` + HTML "Authorization Required" page cannot be captured from bare Tautulli
  (auth failures are 400 JSON) — the client-test coverage for that path uses synthetic responses.
