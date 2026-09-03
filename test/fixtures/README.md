# Fixtures — real, sanitized Tautulli API responses

**Provenance:** the corpus was captured 2026-09-03 from a live **Tautulli v2.18.1** server (release
tag `6d410e2`, Docker image `tautulli/tautulli:v2.18.1`), all phases included. Four files date from
the 2026-07-04 campaign against **v2.17.2** (nightly `5a39bac6`) and are kept because the newer
capture was thinner — see "Two capture batches" below. Every file is a complete, unmodified server response run
through the deterministic sanitizer in
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
5. **Version-bound:** these reflect v2.18.1. When a new Tautulli release changes the API surface,
   re-run the full capture sweep (never `--only`: aliases are deterministic only within one run, so a
   partial re-capture creates a third alias namespace) and update the provenance line above.
6. **Variant semantics worth knowing** (timing-sensitive captures):
   - `activity/get_activity.json` is the idle-server (zero sessions) case;
     `activity/get_activity__live.json` is the populated one. `terminate_session` is asynchronous —
     a terminated session lingers in `get_activity` for several seconds while it drains.
   - There is deliberately no "after logout" capture: `logout_user_session` NULLs a column that
     `get_user_logins` doesn't expose, so the table is unchanged by design.
   - Three mutation-state captures were dropped from the 2026-08-27 batch because they carried
     partially-sanitized operator email addresses; the 2026-09-03 sweep regenerated them with the
     corrected sanitizer.

## Two capture batches

Sanitizer aliases are deterministic **within one capture run**, not across runs: the alias assigned to a
user depends on the set of users present in that corpus. The v2.18.1 re-capture therefore renumbered
some aliases relative to the v2.17.2 files retained alongside it, so the same real user can appear under
different aliases in the two batches. Apart from `activity/get_activity.json` and
`library/get_library_user_stats.json` — two of the four retained files named below — every fixture a test
reads comes from the v2.18.1 batch. When comparing identities, compare within a batch.

A handful of v2.17.2 fixtures were deliberately kept rather than re-captured because the newer capture
was *thinner*, not different in shape — `library/get_library_user_stats.json`,
`user/get_user_logins.json` and `tautulli/update_check.json` lost rows only because earlier destructive
testing emptied those tables, and `activity/get_activity.json` is the idle-server (zero sessions) case
that a test depends on.

## Sanitization guarantees

Replaced with stable placeholders (same input → same alias everywhere **within a
capture batch** — see above):

- API key / device token literals; any value under a credential-looking key
  (`*password*`, `*token*`, `*api_key*`, `*secret*`, `*hook*`, …) → `REDACTED`
- Server host and name → `192.0.2.10` / `TestServer`; operator hostnames in URLs → `hostN.example.com`
- All IPv4s: private → `192.0.2.x`, public → `203.0.113.x` (except campaign inputs like `8.8.8.8`);
  dash-encoded `*.plex.direct` hosts and their cert hashes
- Usernames / friendly names → `alice`, `bob`, … then `userN`; emails → `<alias>@example.com`
- Non-generic (personal) library names → `Library N`
- Player and device names (`player`, `player_name`) → `Player N` (they carry serials and room names)
- Machine ids / PMS identifiers / plex.tv avatar hashes → fixed hex placeholders
- File-system paths (settings dirs → `/config/redacted`; media file paths → `/media/<basename>`)
- Geo-lookup results → fixed fake coordinates (Springfield, IL)

Deliberately kept (documented, not sensitive): media titles, rating keys and other numeric ids,
timestamps, transient session ids, Plex/public-service URLs (plex.tv, imgur, …), and Tautulli's own
docs examples (`castleblack.com`).

## Auditing

`dart run tool/live_capture/sanitize.dart --check` (requires the original env vars) scans this tree for
every collected sensitive value and non-doc private IPs. **That check alone is not sufficient**: it can
only look for values the collector already knows about, so anything the collector misses is invisible to
it. Pair it with independent sweeps that do not depend on the collector — bare regex passes for email
addresses, IPv4/IPv6 literals, URL hosts, home-directory paths, and high-entropy token-shaped strings.

Two rounds of exactly that, and a later review of the settings captures, found leaks the keyed
collector had missed, and the sanitizer was corrected for each:

- Emails were only collected under a key literally named `email`, so addresses embedded in other
  settings survived. Collection is now a regex sweep over whole bodies, and email replacement runs
  before username replacement (a username is often an address's local part, and rewriting it first
  corrupted the address while leaving the real domain).
- Identity keys were matched exactly, missing plex.tv's camelCase `clientIdentifier` and `pms_uuid`;
  they are now matched as substrings, above a 16-character floor that spares short non-identity ids.
- Notifier credentials under keys no pattern reached (`maxmind_license_key`, `pushover_keys`,
  `cloudinary_cloud_name`) are now named explicitly in the credential list. They cannot be caught by a
  generic `key` rule without also swallowing `rating_key`/`rating_keys`/`session_key`.
- Settings paths under keys with no `_dir`/`_path` suffix (`https_cert`, `https_key`, `geoip_db`,
  `scripts_on_*_script`) escaped the `/config/redacted` rule; they are now named explicitly.

The already-published captures for the identity and credential cases were re-redacted in place with the corrected
sanitizer's own conventions rather than re-captured, because the staging tree was gone by then. That is
the one sanctioned exception to "never hand-edit a fixture": it replaced secret *values* only, changing
no key, shape, or type. A few v2.17.2 mutation-state captures were deleted instead of repaired, since
no test referenced them.
