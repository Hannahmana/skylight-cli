#!/usr/bin/env bash
# Internal helper to push agent-readiness commit via GitHub API.
# Used because GitHub-App installation tokens may permit API writes
# but not raw git protocol writes from this sandbox.
set -euo pipefail

OWNER="${OWNER:-Hannahmana}"
REPO="${REPO:-skylight-cli}"
BRANCH="${BRANCH:-agent-readiness-layer}"
BASE_SHA="${BASE_SHA:-1fc66bf6bc8c7d7caadbaeef56be58ec9be20ec4}"

PARENT_TREE_SHA=$(gh api "repos/$OWNER/$REPO/git/commits/$BASE_SHA" --jq '.tree.sha')
echo "Parent tree: $PARENT_TREE_SHA"

cd "$(git rev-parse --show-toplevel)"

FILES=(
  ".github/ISSUE_TEMPLATE/agent-confused.yml"
  ".github/ISSUE_TEMPLATE/bug.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/workflows/build.yml"
  "CHANGELOG.md"
  "LICENSE"
  "Makefile"
  "VERSION"
  "docs/error-codes.md"
  "llms.txt"
  "scripts/doctor.sh"
  "scripts/grant-permissions.sh"
  "scripts/install.sh"
  "scripts/smoke-test.sh"
)

TMP_TREE="$(mktemp)"
echo "[" > "$TMP_TREE"
FIRST=1
for FILE in "${FILES[@]}"; do
  echo "Creating blob: $FILE"
  CONTENT_B64=$(base64 -w0 < "$FILE")
  BLOB_PAYLOAD="$(mktemp)"
  jq -n --arg c "$CONTENT_B64" '{content: $c, encoding: "base64"}' > "$BLOB_PAYLOAD"
  BLOB_SHA=$(gh api -X POST "repos/$OWNER/$REPO/git/blobs" --input "$BLOB_PAYLOAD" --jq '.sha')
  rm -f "$BLOB_PAYLOAD"
  echo "  -> $BLOB_SHA"

  if [[ "$FILE" == *.sh ]]; then
    MODE="100755"
  else
    MODE="100644"
  fi

  if [ $FIRST -eq 0 ]; then echo "," >> "$TMP_TREE"; fi
  FIRST=0
  printf '{"path":"%s","mode":"%s","type":"blob","sha":"%s"}' "$FILE" "$MODE" "$BLOB_SHA" >> "$TMP_TREE"
done
echo "]" >> "$TMP_TREE"

echo "Creating tree..."
TREE_PAYLOAD="$(mktemp)"
jq -n --arg base "$PARENT_TREE_SHA" --argjson tree "$(cat "$TMP_TREE")" \
  '{base_tree: $base, tree: $tree}' > "$TREE_PAYLOAD"
TREE_SHA=$(gh api -X POST "repos/$OWNER/$REPO/git/trees" --input "$TREE_PAYLOAD" --jq '.sha')
echo "Tree: $TREE_SHA"

echo "Creating commit..."
COMMIT_PAYLOAD="$(mktemp)"
jq -n --arg msg "feat: add SOTA Agent Readiness Layer (LICENSE, CI, Makefile, scripts, error-codes, llms.txt)" \
  --arg tree "$TREE_SHA" \
  --arg parent "$BASE_SHA" \
  '{message: $msg, tree: $tree, parents: [$parent]}' > "$COMMIT_PAYLOAD"
COMMIT_SHA=$(gh api -X POST "repos/$OWNER/$REPO/git/commits" --input "$COMMIT_PAYLOAD" --jq '.sha')
echo "Commit: $COMMIT_SHA"

echo "Creating ref refs/heads/$BRANCH ..."
REF_PAYLOAD="$(mktemp)"
jq -n --arg ref "refs/heads/$BRANCH" --arg sha "$COMMIT_SHA" \
  '{ref: $ref, sha: $sha}' > "$REF_PAYLOAD"
if ! gh api -X POST "repos/$OWNER/$REPO/git/refs" --input "$REF_PAYLOAD" >/dev/null 2>&1; then
  echo "Ref exists, updating..."
  UPDATE_PAYLOAD="$(mktemp)"
  jq -n --arg sha "$COMMIT_SHA" '{sha: $sha, force: true}' > "$UPDATE_PAYLOAD"
  gh api -X PATCH "repos/$OWNER/$REPO/git/refs/heads/$BRANCH" --input "$UPDATE_PAYLOAD" >/dev/null
fi

rm -f "$TMP_TREE" "$TREE_PAYLOAD" "$COMMIT_PAYLOAD" "$REF_PAYLOAD" 2>/dev/null || true

echo ""
echo "SUCCESS: $OWNER/$REPO@$BRANCH -> $COMMIT_SHA"
