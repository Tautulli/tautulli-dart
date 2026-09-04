# MAINTAINING.md — tracking Tautulli and shipping the result

This document owns the path from "upstream changed" to "released". It does not repeat what these
already cover:

| For | Read |
|---|---|
| Architecture, adding a command, model conventions, pitfalls | `CLAUDE.md` |
| Running a fixture capture sweep | `test/CAPTURING.md` |
| What a fixture may contain, sanitization, auditing | `test/fixtures/README.md` |

**STOP** below means: stop, report what you found, do not proceed on a best guess. Version tags in
example commands are the values current when this file was last updated; substitute the real ones.

## 1. Non-negotiables

1. Pin every upstream fetch to a **release tag** (`vX.Y.Z`), never `master`, `nightly` or `beta`. All
   three branches can point at the same commit, and `plexpy/version.py` cannot tell them apart.
   A requested beta pins a nightly SHA instead, never the branch name (§8).
2. Evidence precedence: `test/fixtures/` (real captured behavior) > server source at the exact tag >
   wiki. The wiki has known errors; it never outranks a fixture.
3. Nightly is a heads-up, never an implementation target. Shape changes have shipped and been reverted
   within one release — `get_plex_log` nested rows under `data.data`, un-nested them in v2.18.0, and
   re-nested them in v2.18.1. The one exception is a requested beta (§8).
4. No fixture, no model change. Never author or hand-edit a fixture to match code.
5. Never state a behavior in dartdoc, `README.md` or `CHANGELOG.md` that you have not traced yourself to
   source at a pinned tag, or to a fixture. A subagent's summary is not a trace.
6. Never `git commit`, `git push`, `git tag` or `dart pub publish` unprompted; each is a separate
   approval. Stage, propose a message, wait. One commit at a time.
   Pushing a `vX.Y.Z` tag **is** the publish (§7.4), so propose it as "push the tag, which publishes
   X.Y.Z to pub.dev", never as a bare tag push.
7. Never cite an internal review doc (`CODE_REVIEW.md`, `LIVE_TEST_RESULTS.md`,
   `API_REFERENCE_INCONSISTENCIES.md`) in code, comments or commits — state the constraint directly.
   They and the other files in `.gitignore`'s development-notes block are local notes a fresh clone
   does not have.

## 2. Detect

```bash
gh api repos/Tautulli/Tautulli/releases/latest --jq .tag_name
```

Compare against README's `Last audited against` line. Read that release's notes:

```bash
gh release view vX.Y.Z -R Tautulli/Tautulli --json body --jq .body | grep -A8 '^\* API:'
```

**The notes' `* API:` section is incomplete.** `get_synced_items` and `get_metadata`'s `sync_id` were
both removed in v2.18.0 and appear in no entry. Treat it as a hint; §3 is the detector.

For early warning only, list the handler files nightly has touched since the audited tag. A hit is the
heads-up, nothing more (rule 3):

```bash
gh api repos/Tautulli/Tautulli/compare/v2.18.1...nightly --jq '.files[].filename' | grep -E 'webserve|api2'
```

## 3. Diff the real surface

```bash
python3 tool/api_surface.py v2.18.1 <new-tag>
```

Left operand is the audited tag; `v2.17.2 v2.18.1` is the diff that produced 3.2.0 (two removals). The
tool reads `@addtoapi` in `plexpy/webserve.py` plus the public `API2` methods in `plexpy/api2.py`. At
v2.18.1 it emits 123 commands, byte-identical to what a live server reports — verify that for free, with
no server, against two fixtures that are themselves live captures (both print 123):

```bash
python3 -c "import json;print(len(json.load(open('test/fixtures/api/docs.json'))['response']['data']))"
python3 -c "import json;m=json.load(open('test/fixtures/errors/unknown_command.json'))['response']['message'];print(len(m.split('Possible commands are:')[1].split()))"
```

**A name diff is not enough.** Between v2.17.2 and v2.18.1 it is 2 lines while `webserve.py` changed a
few hundred. Parameter and response-shape changes are invisible to it, so diff the handler files:

```bash
for t in v2.18.1 <new-tag>; do for f in webserve.py api2.py; do
  curl -sSL "https://raw.githubusercontent.com/Tautulli/Tautulli/$t/plexpy/$f" -o "/tmp/$t-$f"; done; done
diff -u /tmp/v2.18.1-webserve.py /tmp/<new-tag>-webserve.py; diff -u /tmp/v2.18.1-api2.py /tmp/<new-tag>-api2.py
```

Not `gh api …/compare`: it drops the patch for large diffs and reports the file as `changes=0` —
across v2.17.2…v2.18.1 it showed `webserve.py` as unchanged.

**Never grep `def <command>` to find a handler.** At v2.18.1, 18 of its 123 commands are registered
under a name that differs from their function, and for `get_stream_data` and `pms_image_proxy` an
unrelated function with the bare command name also exists — a grep silently reads the wrong one. Use:

```bash
python3 tool/api_surface.py v2.18.1 --map
```

## 4. Triage — what a hit means

Nothing in this table authorizes a code change. A confirmed wire change authorizes a *capture*.

| Signal | What it proves | Required confirmation |
|---|---|---|
| Command removed | Real. The only self-sufficient signal. | `comm -23 <(python3 tool/api_surface.py <tag> 2>/dev/null \| sort) <(grep -rhoE "'[a-z_0-9]+'" lib/src/services \| tr -d "'" \| sort -u)` — the class must include digits (`top_10`). Expected output is only `import_config` and `import_database`, the deliberate `UnimplementedError` stubs. |
| Command added | In scope — the package covers the full surface except the multipart `import_*` uploads. | Needs a capture, so no server → **STOP**. Added fields and parameters are optional or nullable and never raise the minimum server version. |
| Parameter changed in the signature | Real but partial — many parameters arrive via `**kwargs` and never appear in a signature. | Also diff the docstring; then read the handler body. |
| Parameter changed only in the docstring | Could be real, or a years-late doc correction. | Read the handler, not the wiki. |
| Response field named in a docstring | **Assume false until traced.** A docstring typo fix looks identical to a wire change. | Count the literal in *code*, not docstrings, in the `--map` handler and in the module it delegates to (`datafactory.py`, `pmsconnect.py`, …). Equal non-zero counts at both tags mean documentation changed; 0 at both means the row is built dynamically — **STOP**. |

If a change cannot be confirmed from source at a tag **or** from a capture — **STOP**.

## 5. Capture and implement

Run `test/CAPTURING.md` end to end — always the full sweep, never `--only`: a partial run creates a third
alias namespace and an audit that never saw the untouched files. Its phase order is mandatory. No
disposable server → **STOP** (rule 4). Only the deltas over `CLAUDE.md`'s "Adding a New Command" belong
here:

- Before the sweep, `tautulli_commit` from `get_tautulli_info` must start with
  `gh api repos/Tautulli/Tautulli/commits/vX.Y.Z --jq '.sha[:7]'`, the SHA provenance lines record;
  otherwise the server is on a branch — **STOP**. A §8 beta capture replaces this check with §8's.
- Keep the staging tree until **after** `sanitize.dart --check`. It rebuilds its needle list from
  `$TAUTULLI_STAGING_DIR` on every run: a deleted directory crashes it (exit 255) and an empty one prints
  `audit clean` (exit 0) having searched only the env-var literals and its own email/private-IP
  regexes. Neither is an audit. Pair it with independent regex sweeps — emails, IPv4/IPv6, URL hosts,
  home paths, high-entropy strings — because a keyed audit cannot find what its collector never knew about.
- A regenerated corpus needs a **shape diff**, not a value diff (a recapture renumbers every alias):
  `tool/fixture_shape_diff.sh` prints a `SHAPE:` line per fixture whose key set changed against `HEAD`,
  and every line needs a model decision. Keep an older-batch fixture only when the new capture is thinner
  with identical keys; list it under "Two capture batches" in `test/fixtures/README.md`.
- A removed parameter edits the params map; a removed command deletes the method, its model and its
  fixture, and earns a `### Breaking` bullet. Removals are deletions, not deprecations.
- Send a parameter exactly as the handler compares it. Tautulli tests `not (all_servers == 'false')`, so
  the usual `1`/`0` encoding silently reads as true.
- When a release shipped a shape and reverted it, accept both. Two shapes live in inline test
  responses instead of fixtures, because no capture can hold them: `get_plex_log`'s v2.18.0 bare
  list (`test/services/log_service_test.dart`) and `search`'s bare-list reply when the PMS query
  fails (`test/services/media_service_test.dart`), which the v2.18.1 capture without `limit` no
  longer reproduces. They are the documented rule-4 exceptions.
- Reconcile tests to fixtures, never the reverse.

## 6. Verification gates

```bash
dart pub get && dart format --output=none --set-exit-if-changed . && dart analyze && dart test && dart pub publish --dry-run
```

CI (`.github/workflows/ci.yml`, on push and PR to `main`) runs the pubspec minimum SDK and `stable` —
raise both together; `format` and `publish --dry-run` run on `stable` only. Read the dry-run's file
tree, not only its exit code: a new repo-root file ships unless listed in `.pubignore`, and
`example/main.dart` and `README.md` always ship — placeholder hosts and keys only.
`publish.yml`'s `test` job is a byte copy of `ci.yml`'s, because a tag push does not run `ci.yml`; a
matrix change lands in both files.

What green does **not** prove:

- `dart test` proves only that tests match fixtures — `CLAUDE.md` "Adding a New Command" step 5 is how
  green once hid 22 permanently-null model fields.
- At 3.2.0, 94 of 149 fixtures were read by no test. Adding a fixture adds no coverage by itself:

```bash
comm -23 <(find test/fixtures -name '*.json' | sed 's|^test/fixtures/||' | sort) <(grep -rhoE "'[A-Za-z0-9_/.-]+\.json'" test --include='*.dart' | tr -d "'" | sort -u)
```

## 7. Release

**Version.** Patch: no signature, model-field or requirement change. Minor: everything else, including
upstream removals and a raised server floor, each a `### Breaking` bullet — never a major for an
upstream-driven change (3.1.0 and 3.2.0 both shipped removals as minors). Major is reserved for a
package-initiated redesign.

**Server floor.** `Requires` moves only when the package starts sending what an older server rejects or
stops sending what it needs, and earns a `### Breaking` bullet; it normally sits below the audited tag.
`Last audited` (README, `pubspec.yaml`, this file's tag examples) moves after a §3 source diff.
"Verified end-to-end", the provenance lines and `api_surface.py`'s "Validated at" (`CLAUDE.md`,
`test/fixtures/README.md`, `tool/api_surface.py`) move only after a §5 capture at a release tag; a §8
beta capture moves the provenance line alone.

**Prereleases.** Only when asked; §8 is the whole path.

1. Bump `pubspec.yaml` and rename the top `## <next>-wip` heading to the bare `## <version>` in the same
   commit. `dart pub publish --dry-run` exits 65 when `CHANGELOG.md` does not contain the pubspec version
   string anywhere — a substring check, so `-wip` satisfies it mid-cycle; the bare heading is §9's rule.
2. Every hit below is a place to decide whether the audited version, tag SHA or capture date moves;
   `test/` assertions are fixture-bound and reconcile through `dart test` instead:

```bash
git ls-files | grep -E '\.(md|ya?ml|py)$' | xargs grep -nE 'v?2\.18\.1|6d410e2|2026-09-03' | grep -v '^CHANGELOG.md'
```

   `grep -n 'tautulli: \^' README.md` moves on every package release.
3. Before a `### Breaking` release, check the raw calls in Tautulli Remote — `dart analyze` covers the
   typed surface, but `client.execute('<cmd>', …)` carries command strings and parameter keys the
   compiler cannot flag: `grep -rnE "\.execute\(\s*'[a-z_0-9]+'" ../Tautulli-Remote/lib`.
4. Push, then wait for **both** matrix legs:
   `gh run watch $(gh run list --workflow=ci.yml --commit $(git rev-parse HEAD) --json databaseId --jq '.[0].databaseId') --exit-status`.
   Then tag lightweight `vX.Y.Z` on that commit and push the tag, each its own approval. **The tag push
   is the publish** (rule 6): `.github/workflows/publish.yml` reruns the matrix on the tag and, only when
   both legs are green, calls `dart-lang/setup-dart`'s reusable publish workflow, authenticated by a
   GitHub-signed OIDC token, so no secret exists anywhere. pub.dev accepts the upload only from a tag
   push on `Tautulli/tautulli-dart` named exactly `v` + the pubspec `version`. Watch the run
   (`--workflow=publish.yml` in the command above), then confirm on pub.dev, the release index,
   which must now end with the new version: `curl -s https://pub.dev/api/packages/tautulli | jq -r '.versions[].version'`.
   A red `test` leg skips `publish`. The reusable workflow runs its own `dart pub publish --dry-run`
   before `dart pub publish -f`, so a red publish job is either a pub warning or a pub.dev refusal:
   read which step failed. Check pub.dev before any retry: re-run a transient failure from the
   Actions UI (same commit, same ref), but a fix that needs a commit needs the tag moved
   (`git tag -d vX.Y.Z && git push origin :refs/tags/vX.Y.Z`, re-tag, push), and once the version is
   on pub.dev the fix is the next version (item 6). If the workflow itself is broken,
   `dart pub publish` by hand after green `ci.yml` legs, then tag and push; the tag's run fails at
   the publish step (the version exists) and uploads nothing.
5. No `-beta` heading survives into a release entry; merge it into the final version's section.
6. Bugs never retract a published version; the fix ships as the next version (3.0.x stands). Retract,
   within pub.dev's 7-day window, only when the tarball itself is the problem: a leaked secret or real
   host in `example/` or `README.md`, or a version that cannot resolve.

**Automated publishing (maintainer only).** Enabled 2026-09-02. The package belongs to the
`tautulli.com` publisher, so changing it needs a publisher admin. On
`pub.dev/packages/tautulli/admin` → **Automated publishing**: repository `Tautulli/tautulli-dart`,
tag pattern `v{{version}}`. Under GitHub Actions only **Enable publishing from push events** is
checked; workflow_dispatch and "Require GitHub Actions environment" stay off. **Enable manual
publishing** stays checked, because step 4's fallback depends on it. GitHub needs no secret and no
environment; the tagged commit must contain `publish.yml`. If tag publishing is ever disabled there,
or for a prerelease tag until the first beta proves it, expect the tag's run to fail at the publish
step and upload nothing: step 4's fallback applies.

## 8. Nightly and betas

Only `tautulli_commit` identifies a nightly server: nightly's `version.py` still says
`PLEXPY_BRANCH = "master"` and the release version, and the v2.18.1 corpus server reported
`tautulli_branch: nightly` at the release SHA.

**Scan** when §2's heads-up fires: run §3 at the nightly head, with the SHA in place of `<new-tag>`.
A hit is recorded nowhere: no code, no bullet, no `-wip` heading (rule 3).

```bash
sha=$(gh api repos/Tautulli/Tautulli/commits/nightly --jq '.sha[:7]'); python3 tool/api_surface.py v2.18.1 $sha
```

**Decide.** A beta starts with a request naming the consumer, the upstream commit it cannot wait
for, and a disposable server on `tautulli/tautulli:nightly`. Docker Hub publishes only that moving
tag, so the pin is whatever the server reports, never a SHA chosen up front. Either missing →
**STOP**.

**Capture.** §5 in full, with this in place of its pre-check:

```bash
pin=$(curl -s "$TAUTULLI_BASE_URL/api/v2?apikey=$TAUTULLI_API_KEY&cmd=get_tautulli_info" | jq -r '.response.data.tautulli_commit[:7]')
gh api repos/Tautulli/Tautulli/compare/<wanted-commit>...$pin --jq .status   # ahead or identical, else STOP
```

Record `$pin` when first read; every later phase must read the same value back (a re-pulled `nightly`
image is a different server) or **STOP** and restart the sweep. Run §3 with `$pin` in place of
`<new-tag>`; the tool and the raw-file URLs both take a 7-char SHA. The pin appears in the changelog
preamble, in the provenance line ("captured <date> from a live **Tautulli nightly** server, commit
`<pin>`; replaced by a release-tag corpus before <version>") and inside `test/fixtures/`;
`git grep -n <pin>` finds nothing else. README `Requires`/`Last audited`, `pubspec.yaml`, `CLAUDE.md`
and "Validated at" keep their release values: they describe the stable line, and pub.dev shows the
stable README for a prerelease.

**Before the final version**, re-capture at the release tag (§5's own pre-check) and shape-diff
against the beta corpus. A shape only the beta corpus held has no fixture afterwards: rule 4 removes
its model code and its bullet, and the final entry names the drop under `### Behavior notes`. A
shape any release tag shipped stays, reverted or not (§5, `get_plex_log`). The inverse holds for a
command the beta deleted: if the release tag still has it, the re-capture returns its fixture
(`fixture_shape_diff.sh` reports it as new), rule 4 restores the method and model, the beta's
`### Breaking` bullet is dropped in the merge, and the final entry names the return under
`### Behavior notes`. An abandoned beta line gets the same treatment at whatever stable ships next.
After the release commit, `git grep -n <pin>` hits only fixtures listed under "Two capture batches"
in `test/fixtures/README.md`.

**Version.** `X.Y.Z-beta.N`, N from 1, never reset, never another word. Each beta is §7.1 with
`X.Y.Z-beta.N` as the version: `pubspec.yaml` bumped and `## X.Y.Z-wip` renamed to `## X.Y.Z-beta.N`
in one commit, because the dry-run's substring check needs that literal. The preamble carries the pin
and "stay on <stable> for release servers". A later beta keeps the pin or re-captures at a new one,
never edits it. `## X.Y.Z-wip` reopens on top between betas; the release commit merges every `-beta.N`
section into `## X.Y.Z` (§7.5). Ship by §7.4 with tag `vX.Y.Z-beta.N` (`publish.yml`'s second glob).
A consumer pins the exact version in its own `pubspec.yaml`, `tautulli: 3.3.0-beta.1`, bumped per
beta; that file is the only record of who runs a beta. pub gives `^3.2.0` the latest stable while one
satisfies it, and `^3.3.0-beta.1` flips to `3.3.0` the moment it exists.

## 9. Changelog style

**Structure.** One `# Changelog`. Versions newest-first as bare `## <version>` — no dates, no links, no
`[Unreleased]`. Released versions plus at most one `## <next>-wip` heading at the top, opened by the
first bullet-worthy change after a release; `pubspec.yaml` stays at the released version until the
release commit renames the heading (§7.1). Subheads in this order: `### Breaking`, `### Fixed`,
`### Added`, `### Behavior notes`. Optional prose preamble above the first subhead; an audited release
names the server floor and the audited tag there. Which version number moves is §7, not a bullet.

**Punctuation.** Every bullet and preamble sentence ends in a period; a bullet's internal sentences are
punctuated normally. This prints nothing when the file conforms:

```bash
awk 'prev ~ /^(- |  )/ && $0 !~ /^  / && prev !~ /\.$/ {print NR-1": "prev} {prev=$0} END {if (prev ~ /^(- |  )/ && prev !~ /\.$/) print NR": "prev}' CHANGELOG.md
```

**Layout.** Wrap to fill ~100 columns, hard max 105, continuations indented exactly 2 spaces.

**Voice.** Third person; no we/our/us. Past-tense verb-first for package changes ("Removed
`getSyncedItems` …"); subject-first present tense for statements of current behavior ("`getSettings`
returns the raw sectioned JSON map"). Second-person imperative only for consumer warnings. Backtick
every identifier, server key, literal and server expression. No PR, issue or commit links.

**Phrasing** (`CHANGELOG.md` only; this file keeps its own style). The corpus these entries imitate has
none of the tells below: Tautulli's changelog has 0 spaced em dashes in 3,088 lines, `package:http` 0 in
291. Wikipedia's "Signs of AI writing" says "AI-generated em dashes are usually surrounded by spaces,
contrary to common typographic guidelines"; Google's style guide says of the em dash "Don't put a space
before or after it." The rule rests on that norm, not on detection — Wikipedia already marks the sign as
fading — so do not relax it when the detection argument does.
- No em dash and no semicolon in a bullet. Use a colon before a predicate or a list, `so` for a
  consequence, or a second sentence: "Removed `x` — Plex retired Sync." → "Removed `x`. Plex retired Sync."
- Before/after is `instead of`, not "now": "It is now sent as a literal string." → "sent as
  `'true'`/`'false'` instead of `1`/`0`." "no longer" only for a real version change, never in adjacent bullets.
- Keep a hedge or intensifier that carries a fact (`typically`, `most often`, `silently`). Wikipedia lists
  "hedging qualifiers and intensifiers" among markers of human writing; every rewrite that cut them lost the fact.
- Length follows content: "`pushToken` on `registerDevice`." is finished, and a server quirk gets its
  mechanism. The tell is a repeated template (three "Previously …" tails in a row), not a word.
- Blocklist, run on the newest entry; prints nothing when clean (a `;` inside a code span also trips it):

```bash
awk '/^## /{n++} n==1' CHANGELOG.md | grep -niE ' — |;|\bpreviously\b|\b(delve|seamless|leverag|comprehensive|crucial|pivotal|streamlin|enhanc|ensur|showcas|underscor|highlight|notably|additionally)|not (just|only) [^.]*\bbut\b|while (preserv|ensur|maintain)ing|serves as'
```

**The bar for a bullet:** it carries a verifiable server fact — a version, a handler predicate
(`not (all_servers == 'false')`), a response shape, or a concrete misbehavior (passwords masked as four
spaces). A verb plus a list of renamed identifiers is the failure mode.

**Earns a bullet:** anything observable from outside the package — parameters, removed methods, model
fields, return types, exceptions, nullability, consumer gotchas, and server-version, Dart SDK and
`http` requirements (a raised floor is `### Breaking`; `environment.sdk` and the CI matrix's pinned
leg move in one commit). **Does not:** formatting, CI, test-only changes, fixture regeneration, capture
tooling, dartdoc fixes.

**Scope.** These rules govern new entries. An older entry gets punctuation, blocklist and structure
conformance only, never a reworded mechanism or an added fact: the server it was verified against is out
of range and cannot be re-captured (rule 5).

## 10. Commit style

- Imperative, sentence-capitalized, **no trailing period** (the convention changed on 2026-08-11; follow
  the newer form). No Conventional Commits prefix. Aim for ≤72 characters; join multiple lanes with "and".
- Body optional and often absent. When present: blank line, wrap ~72, third person, present tense.
- A body names the **mechanism**, not the category: "the server tests `not (all_servers == 'false')`, so
  the usual 1/0 encoding always read as true. It is now sent as a literal string."
- Reasoning, ordering constraints and migration detail live here, never in the changelog.
- Close with the `Co-Authored-By:` trailer.

## 11. Stop-and-verify checkpoints

1. Claiming a version behavior — did you read source at the **tag** (or the §8 pin), not a branch?
2. Claiming a response shape — is there a **fixture**, or only a wiki/docstring line?
3. Reading a handler — did you resolve the command through `--map` rather than grepping `def`?
4. A test went green — does a test actually **read** the fixture you added?
5. After sanitizing — did independent sweeps run, with the staging tree still present and non-empty?
6. Before committing, pushing, tagging or publishing — proposed, and waiting for approval?
7. Any unresolved uncertainty — **STOP** and report it rather than picking the likely answer.
8. A beta pin — read from the capture server's `tautulli_commit`, present in the changelog preamble,
   the provenance line and `test/fixtures/`, and nowhere else?
9. The first release after a beta — does `git grep -n <pin>` hit only fixtures listed under "Two
   capture batches", and is every model change that arrived in a beta backed by a release-tag fixture
   or reversed with a bullet?
