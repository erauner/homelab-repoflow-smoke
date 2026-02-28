#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

pkg="repoflow-npm-smoke-${SMOKE_ID}"
ver="1.0.${RUN_TS}"

export npm_config_cache="$work/.npm-cache"
mkdir -p "$npm_config_cache"

pushd "$work" >/dev/null
npm init -y >/dev/null
npm pkg set name="$pkg" version="$ver" >/dev/null
printf 'module.exports = {ok:true}\n' > index.js
cat > .npmrc <<NPMRC
registry=${REPOFLOW_API_URL}/npm/${REPOFLOW_WORKSPACE}/npm-local/
//${host_no_scheme}/api/npm/${REPOFLOW_WORKSPACE}/npm-local/:_authToken=${REPOFLOW_PAT}
NPMRC
npm publish --registry "${REPOFLOW_API_URL}/npm/${REPOFLOW_WORKSPACE}/npm-local/" >/dev/null

mkdir consume && cd consume
npm init -y >/dev/null
cat > .npmrc <<NPMRC
registry=${REPOFLOW_API_URL}/npm/${REPOFLOW_WORKSPACE}/npm/
//${host_no_scheme}/api/npm/${REPOFLOW_WORKSPACE}/npm/:_authToken=${REPOFLOW_PAT}
NPMRC
npm install "${pkg}@${ver}" --registry "${REPOFLOW_API_URL}/npm/${REPOFLOW_WORKSPACE}/npm/" >/dev/null
popd >/dev/null

echo "npm smoke passed: ${pkg}@${ver}"
