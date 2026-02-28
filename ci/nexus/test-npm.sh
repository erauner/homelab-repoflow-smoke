#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/packages/npm" "$work/pkg"

pushd "$work/pkg" >/dev/null
npm version "${SMOKE_VERSION}" --no-git-tag-version >/dev/null
cat > .npmrc <<NPMRC
registry=${NEXUS_BASE}/repository/${NEXUS_NPM_HOSTED_REPO}/
//${NEXUS_HOST}/repository/${NEXUS_NPM_HOSTED_REPO}/:_auth=${basic_auth_b64}
//${NEXUS_HOST}/repository/${NEXUS_NPM_HOSTED_REPO}/:always-auth=true
NPMRC
npm publish --registry "${NEXUS_BASE}/repository/${NEXUS_NPM_HOSTED_REPO}/" >/dev/null

mkdir -p "$work/consume"
cd "$work/consume"
npm init -y >/dev/null
cat > .npmrc <<NPMRC
registry=${NEXUS_BASE}/repository/${NEXUS_NPM_PROXY_REPO}/
//${NEXUS_HOST}/repository/${NEXUS_NPM_PROXY_REPO}/:_auth=${basic_auth_b64}
//${NEXUS_HOST}/repository/${NEXUS_NPM_PROXY_REPO}/:always-auth=true
NPMRC

installed=0
for attempt in {1..12}; do
  if npm install "repoflow-npm-smoke@${SMOKE_VERSION}" --registry "${NEXUS_BASE}/repository/${NEXUS_NPM_PROXY_REPO}/" >/dev/null 2>&1; then
    installed=1
    break
  fi
  echo "nexus npm proxy not ready yet (attempt ${attempt}/12), retrying in 5s..."
  sleep 5
done
if [[ "${installed}" -ne 1 ]]; then
  echo "failed to install repoflow-npm-smoke@${SMOKE_VERSION} from nexus proxy after retries"
  exit 1
fi
popd >/dev/null

echo "nexus npm passed"
