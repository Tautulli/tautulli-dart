# Fixtures — real, sanitized Tautulli API responses

**Provenance:** captured 2026-07-04 from a live **Tautulli v2.17.2** server (Docker, nightly commit
`5a39bac6`, PMS 1.43.3) during the post-fix live verification campaign. Every file is a complete,
unmodified server response run through the deterministic sanitizer in
[`tool/live_capture/sanitize.dart`](../../tool/live_capture/sanitize.dart) — see
[`test/CAPTURING.md`](../CAPTURING.md) for the full reproducible process.

## Rules

1. **Never hand-edit a fixture.** If a shape looks wrong, that is the server's real behavior — fix the
   model, not the evidence. Regeneration requires re-running the capture sweep against a live server.
2. **Never invent keys or trim responses.** Fixtures are full envelopes
   (`{"response": {"result": …, "data": …}}`), exactly as served.
3. **Naming:** `<cmd>.json` is the canonical response; `<cmd>__<variant>.json` are parameter variants,
   error shapes (`get_home_stats__before_400`, `auth/auth__bad_key`), or mutation states
   (`get_exports_table__after`, `get_history__predelete`). `<name>.meta.json` records
   status/content-type/size for binary download endpoints instead of file bytes.
4. `success_response.json` is a byte-copy of `tautulli/backup_config.json` (a real capture) used by
   tests that only need "any success envelope"; refresh the copy when regenerating.
5. **Version-bound:** these reflect v2.17.2. When a new Tautulli release changes the API surface,
   re-capture affected commands and update the provenance line above.
6. **Variant semantics worth knowing** (timing-sensitive captures):
   - `activity/get_activity__terminating.json` — taken ~4 s after `terminate_session`; the session is
     still listed (draining, `session_id` cleared) because termination is asynchronous. The settled
     zero-session state is the canonical `activity/get_activity.json`.
   - `user/get_users__after_delete_user.json` — a deleted user is filtered out of `get_users` entirely;
     the deletion shows as the row's absence (52 → 51 users vs `get_users.json`).
   - There is deliberately no "after logout" capture: `logout_user_session` NULLs a column that
     `get_user_logins` doesn't expose, so the table is unchanged by design.

## Sanitization guarantees

Replaced with stable placeholders (same input → same alias everywhere):

- API key / device token literals; any value under a credential-looking key
  (`*password*`, `*token*`, `*api_key*`, `*secret*`, `*hook*`, …) → `REDACTED`
- Server host and name → `192.0.2.10` / `TestServer`; operator hostnames in URLs → `hostN.example.com`
- All IPv4s: private → `192.0.2.x`, public → `203.0.113.x` (except campaign inputs like `8.8.8.8`);
  dash-encoded `*.plex.direct` hosts and their cert hashes
- Usernames / friendly names → `alice`, `bob`, … then `userN`; emails → `<alias>@example.com`
- Non-generic (personal) library names → `Library N`
- Machine ids / PMS identifiers / plex.tv avatar hashes → fixed hex placeholders
- File-system paths (settings dirs → `/config/redacted`; media file paths → `/media/<basename>`)
- Geo-lookup results → fixed fake coordinates (Springfield, IL)

Deliberately kept (documented, not sensitive): media titles, rating keys and other numeric ids,
timestamps, transient session ids, Plex/public-service URLs (plex.tv, imgur, …), and Tautulli's own
docs examples (`castleblack.com`).

Audit any time with `dart run tool/live_capture/sanitize.dart --check` (requires the original
env vars; scans this tree for every collected sensitive value and non-doc private IPs).
