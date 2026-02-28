#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

cat > "$work/.netrc" <<NETRC
machine ${host_no_scheme}
login token
password ${REPOFLOW_PAT}
NETRC
chmod 600 "$work/.netrc"

pushd "$work" >/dev/null
export NETRC="$work/.netrc"
export GOPROXY="${REPOFLOW_API_URL}/go/${REPOFLOW_WORKSPACE}/go"
export GOSUMDB=off
export GONOSUMDB='*'
export GOPRIVATE='*'
go mod init smoke.example >/dev/null
go get github.com/google/uuid@v1.6.0 >/dev/null
popd >/dev/null

echo "go smoke passed: github.com/google/uuid@v1.6.0"
