#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/assets/universal" "$work/universal"
tar -czf "$work/universal-smoke-${SMOKE_VERSION}.tar.gz" -C "$work" universal

curl -fsS -u "${NEXUS_USER}:${NEXUS_PASSWORD}" -T "$work/universal-smoke-${SMOKE_VERSION}.tar.gz" \
  "${NEXUS_BASE}/repository/${NEXUS_RAW_HOSTED_REPO}/universal-smoke/${SMOKE_VERSION}/universal-smoke-${SMOKE_VERSION}.tar.gz" >/dev/null
curl -fsS -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  "${NEXUS_BASE}/repository/${NEXUS_RAW_HOSTED_REPO}/universal-smoke/${SMOKE_VERSION}/universal-smoke-${SMOKE_VERSION}.tar.gz" >/dev/null

echo "nexus raw passed"
