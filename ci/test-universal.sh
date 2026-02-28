#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

ver="1.0.${RUN_TS}"
file="u-${SMOKE_ID}.txt"
echo "universal smoke ${SMOKE_ID}" > "$work/$file"

api_post_form "/1/workspaces/${REPOFLOW_WORKSPACE}/repositories/universal-local/packages/single" \
  -F "packageFiles=@$work/$file" \
  -F "packageName=universal-smoke" \
  -F "packageVersion=${ver}" >/dev/null

curl -fsS -H "Authorization: Bearer ${REPOFLOW_PAT}" \
  "${REPOFLOW_API_URL}/universal/${REPOFLOW_WORKSPACE}/universal/universal-smoke/${ver}/${file}" >/dev/null

echo "universal smoke passed: ${file}"
