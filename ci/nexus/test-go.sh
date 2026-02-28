#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/packages/go" "$work/pkg"

cat > "$work/.netrc" <<NETRC
machine ${NEXUS_HOST}
login ${NEXUS_USER}
password ${NEXUS_PASSWORD}
NETRC
chmod 600 "$work/.netrc"

pushd "$work/pkg" >/dev/null
export NETRC="$work/.netrc"
export GOPROXY="${NEXUS_BASE}/repository/${NEXUS_GO_PROXY_REPO}/"
export GOSUMDB=off
export GONOSUMDB='*'
export GOPRIVATE='*'
go mod download >/dev/null
go build -o "$work/go-smoke" ./cmd/smoke
"$work/go-smoke" >/dev/null
popd >/dev/null

echo "nexus go proxy passed"
