#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/assets/universal" "$work/universal"
tar -czf "$work/universal-smoke-${SMOKE_VERSION}.tar.gz" -C "$work" universal

curl -fsS -u "${ARTI_USER}:${ARTI_PASSWORD}" -T "$work/universal-smoke-${SMOKE_VERSION}.tar.gz" \
  "${ARTI_BASE}/${ARTI_GENERIC_LOCAL_REPO}/universal-smoke/${SMOKE_VERSION}/universal-smoke-${SMOKE_VERSION}.tar.gz" >/dev/null
curl -fsS -u "${ARTI_USER}:${ARTI_PASSWORD}" \
  "${ARTI_BASE}/${ARTI_GENERIC_VIRTUAL_REPO}/universal-smoke/${SMOKE_VERSION}/universal-smoke-${SMOKE_VERSION}.tar.gz" >/dev/null

echo "artifactory generic passed"
