#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${NEXUS_USER:-}" || -z "${NEXUS_PASSWORD:-}" ]]; then
  echo "NEXUS_USER and NEXUS_PASSWORD are required"
  exit 1
fi

: "${NEXUS_BASE_URL:=https://nexus.erauner.dev}"
: "${SMOKE_RUN_ID:=local}"

: "${NEXUS_NPM_HOSTED_REPO:=npm-hosted}"
: "${NEXUS_NPM_PROXY_REPO:=npm-proxy}"
: "${NEXUS_PYPI_HOSTED_REPO:=pypi-hosted}"
: "${NEXUS_PYPI_PROXY_REPO:=pypi-proxy}"
: "${NEXUS_GO_PROXY_REPO:=go-proxy}"
: "${NEXUS_RAW_HOSTED_REPO:=raw-hosted}"
: "${NEXUS_DOCKER_HOSTED_REPO:=homelab}"

NEXUS_BASE="${NEXUS_BASE_URL%/}"
NEXUS_HOST="$(echo "${NEXUS_BASE}" | sed -E 's#^https?://([^/]+).*$#\1#')"
: "${NEXUS_DOCKER_REGISTRY:=docker.nexus.erauner.dev}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN_TS="$(date +%Y%m%d%H%M%S)"
SMOKE_ID="${SMOKE_RUN_ID}-${RUN_TS}"
SMOKE_VERSION="0.0.${RUN_TS}"

basic_auth_b64="$(printf '%s:%s' "${NEXUS_USER}" "${NEXUS_PASSWORD}" | base64 | tr -d '\n')"

echo "Nexus: ${NEXUS_BASE}"
echo "Smoke ID: ${SMOKE_ID}"
echo "Version: ${SMOKE_VERSION}"
