#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ARTI_USER:-}" || -z "${ARTI_PASSWORD:-}" ]]; then
  echo "ARTI_USER and ARTI_PASSWORD are required"
  exit 1
fi

: "${ARTIFACTORY_BASE_URL:=https://artifactory.erauner.dev/artifactory}"
: "${SMOKE_RUN_ID:=local}"

: "${ARTI_NPM_LOCAL_REPO:=npm-local}"
: "${ARTI_NPM_VIRTUAL_REPO:=npm}"
: "${ARTI_PYPI_LOCAL_REPO:=pypi-local}"
: "${ARTI_PYPI_VIRTUAL_REPO:=pypi}"
: "${ARTI_GO_VIRTUAL_REPO:=go}"
: "${ARTI_HELM_LOCAL_REPO:=helm-local}"
: "${ARTI_HELM_VIRTUAL_REPO:=helm}"
: "${ARTI_GENERIC_LOCAL_REPO:=generic-local}"
: "${ARTI_GENERIC_VIRTUAL_REPO:=generic}"
: "${ARTI_DOCKER_LOCAL_REPO:=docker-local}"
: "${ARTI_DOCKER_VIRTUAL_REPO:=docker}"

ARTI_BASE="${ARTIFACTORY_BASE_URL%/}"
ARTI_HOST="$(echo "${ARTI_BASE}" | sed -E 's#^https?://([^/]+).*$#\1#')"
ARTI_BASE_PATH="$(echo "${ARTI_BASE}" | sed -E 's#^https?://[^/]+##')"
if [[ -z "${ARTI_BASE_PATH}" ]]; then
  ARTI_BASE_PATH=""
fi
: "${ARTI_DOCKER_REGISTRY:=${ARTI_HOST}}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN_TS="$(date +%Y%m%d%H%M%S)"
SMOKE_ID="${SMOKE_RUN_ID}-${RUN_TS}"
SMOKE_VERSION="0.0.${RUN_TS}"

basic_auth_b64="$(printf '%s:%s' "${ARTI_USER}" "${ARTI_PASSWORD}" | base64 | tr -d '\n')"

echo "Artifactory: ${ARTI_BASE}"
echo "Smoke ID: ${SMOKE_ID}"
echo "Version: ${SMOKE_VERSION}"
