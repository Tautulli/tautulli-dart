# CLAUDE.md — tautulli

This package is a standalone typed Dart client for the Tautulli API v2. It has no Flutter dependency and is designed to be publishable to pub.dev.

## Commands

```bash
dart test        # Run all tests
dart analyze     # Lint and type check
```

## Architecture

```
lib/src/
├── client.dart          # TautulliClient — HTTP core, service accessors
├── connection.dart      # TautulliConnection — immutable config value object
├── executor.dart        # TautulliExecutor — interface all services depend on
├── exceptions.dart      # Sealed TautulliException hierarchy (11 subtypes)
├── services/            # 16 service classes, one per API domain
├── models/              # Hand-written fromJson models, organized by domain
├── types/               # Domain enums (MediaType, PlaybackState, etc.)
└── utils/cast.dart      # Type coercion helpers for API response quirks
```

Services depend on `TautulliExecutor`, not `TautulliClient` directly. This is the seam that makes `MockClient`-based testing work without any mocking library.

## Key Constraints

- **Pure Dart only** — no Flutter SDK, no `dio`, no `dartz`, no `get_it`
- Only production dependency is `http: ^1.6.0`
- Do not add dependencies that would break pub.dev publication
- **`useDeviceToken` defaults to `false`.** Set it to `true` on `TautulliConnection` when the `apiKey` is a device-scoped token obtained via `register_device`. This adds `app=true` to every request, which tells Tautulli to enforce device token auth rather than accepting a plain API key.

## Adding a New Command

1. Add a method to the relevant service in `lib/src/services/`
2. Build a `params` map including only non-null values: `if (x != null) params['key'] = x`
3. Call `_client.execute(cmd, params: params)` — or `_client.executeDownload()` for binary responses
4. Parse `response['data']` through the typed model
5. Add a fixture at `test/fixtures/<domain>/<cmd>.json` — **fixtures are full sanitized captures from a
   live server** (see `test/CAPTURING.md` for the capture tooling). **Never write a fixture to match the
   model code**: that once made the entire test suite pass while 22 model fields were permanently null
   and a dozen methods were broken against real servers.
6. Add a test verifying the `cmd` query param and basic model parsing

## Model Conventions

- All models use **hand-written `fromJson` constructors** — no `json_serializable` codegen, no `.g.dart` files
- All type coercions go through `Cast` in `lib/src/utils/cast.dart` (`castToBool`, `castToInt`, `castToString`, `castToDouble`)
- Paginated responses return `PagedResult<T>` (`List<T> data`, `int? recordsTotal`, `int? recordsFiltered`)
- Download commands (`download_export`, `download_log`, etc.) use `_client.executeDownload()` and return `Future<Uint8List>`

## ImageService

`ImageService.buildImageUrl()` is **synchronous** — it constructs a `Uri` from connection parameters with no HTTP call. It is initialized with `TautulliConnection` alone, not a `TautulliExecutor`.

## Testing Pattern

Tests use `MockClient` from `package:http/testing.dart` (ships with `http` — no separate mock package needed). Each test group:
- Constructs a `TautulliClient` with a `MockClient` that returns a fixture via `fixtureResponse()` (from `test/helpers/fixture_reader.dart` — UTF-8 bytes with the real `application/json;charset=UTF-8` content type)
- Captures the request URI via closure to assert query parameters
- Asserts the `cmd` query parameter and key model fields
- Tests at least one error case (401 → `TautulliAuthException`)

## Fixtures (ground truth)

`test/fixtures/` holds ~150 **full sanitized real responses** captured 2026-07-04 from a live Tautulli
v2.17.2 server (see `test/fixtures/README.md` for provenance/sanitization and `test/CAPTURING.md` for the
reproducible capture process using `tool/live_capture/`). They are the authoritative source for response
shapes — more reliable than the wiki, whose examples are sometimes stale or abbreviated:

- **Never hand-edit a fixture and never invent keys** — regenerate from a live server instead.
- Naming: `<domain>/<cmd>.json` (canonical), `<cmd>__<variant>.json` (param variants, error shapes,
  mutation states), `<name>.meta.json` (binary download metadata).
- Tests are reconciled to fixture content, never the other way around.

## API Reference

The primary reference for commands and parameters is the [Tautulli API Reference](https://github.com/Tautulli/Tautulli/wiki/Tautulli-API-Reference), **but the wiki contains known errors** — check `API_REFERENCE_INCONSISTENCIES.md` before trusting it on a disputed point. Precedence for resolving response-shape questions: `test/fixtures/` (real behavior) > Tautulli server source at the version tag (shallow-clone + AST-extract technique, see CODE_REVIEW.md appendix) > wiki. The package was last verified against **Tautulli v2.17.2 (nightly `5a39bac6`), including two live full-API test campaigns** (`LIVE_TEST_RESULTS.md`); the fix backlog is `CODE_REVIEW.md`.

## Exception Hierarchy

`sealed class TautulliException` with 11 `final class` subtypes — see `lib/src/exceptions.dart`.

## Recurring Pitfalls

**`response['data']`, not `response`** — Tautulli wraps all payloads as `{ "response": { "result": "success", "data": { ... } } }`. `execute()` returns the inner `response` object, so data is at `response['data']`.

**Mutations return `Future<void>`** — Commands that mutate state (`terminate_session`, `delete_*`, `edit_*`, etc.) return void. If Tautulli reports failure, `execute()` throws before returning; reaching the return means success.

**`execute()` already validates `result == "success"`** — do not re-check `result` inside service methods.
