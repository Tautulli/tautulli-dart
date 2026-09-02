#!/usr/bin/env bash
# Print a SHAPE: line for every fixture under test/fixtures whose JSON key
# structure differs from the committed version. Values are ignored on purpose:
# a recapture renumbers every sanitizer alias, so a value diff is noise and only
# a key-set change needs a model decision. See MAINTAINING.md §5.
#
#   tool/fixture_shape_diff.sh          # working tree against HEAD
#   tool/fixture_shape_diff.sh <ref>    # working tree against another ref
#
# Prints nothing when every changed fixture kept its keys. New and deleted
# fixtures are always reported, since both need a decision.
set -u
ref="${1:-HEAD}"

keys='import json, sys
def k(o, p=""):
    if isinstance(o, dict):
        for x, v in o.items():
            k(v, p + "/" + x)
    elif isinstance(o, list) and o:
        k(o[0], p + "[]")
    else:
        print(p)
k(json.load(sys.stdin))'

cd "$(git rev-parse --show-toplevel)" || exit 1

{
  git diff --name-only "$ref" -- test/fixtures
  git ls-files --others --exclude-standard test/fixtures
} | grep '\.json$' | sort -u | while read -r f; do
  if [ ! -f "$f" ]; then
    echo "SHAPE: $f (deleted)"
  elif ! git cat-file -e "$ref:$f" 2>/dev/null; then
    echo "SHAPE: $f (new)"
  elif ! diff <(git show "$ref:$f" | python3 -c "$keys" | sort -u) \
              <(python3 -c "$keys" < "$f" | sort -u) >/dev/null; then
    echo "SHAPE: $f"
  fi
done
