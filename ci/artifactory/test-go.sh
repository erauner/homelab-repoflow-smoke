#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/packages/go" "$work/pkg"

cat > "$work/.netrc" <<NETRC
machine ${ARTI_HOST}
login ${ARTI_USER}
password ${ARTI_PASSWORD}
NETRC
chmod 600 "$work/.netrc"

pushd "$work/pkg" >/dev/null
export NETRC="$work/.netrc"
export GOPROXY="${ARTI_BASE}/api/go/${ARTI_GO_VIRTUAL_REPO}"
export GOSUMDB=off
export GONOSUMDB='*'
export GOPRIVATE='*'
go mod download >/dev/null
go build -o "$work/go-smoke" ./cmd/smoke
"$work/go-smoke" >/dev/null
popd >/dev/null

echo "artifactory go passed"
