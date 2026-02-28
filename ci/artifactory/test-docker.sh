#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not available"
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/docker/." "$work/"

echo "${ARTI_PASSWORD}" | docker login "${ARTI_DOCKER_REGISTRY}" -u "${ARTI_USER}" --password-stdin >/dev/null
local_tag="${ARTI_DOCKER_REGISTRY}/${ARTI_DOCKER_LOCAL_REPO}/smoke:${SMOKE_VERSION}"
virt_tag="${ARTI_DOCKER_REGISTRY}/${ARTI_DOCKER_VIRTUAL_REPO}/smoke:${SMOKE_VERSION}"
docker build -t "$local_tag" "$work" >/dev/null
docker push "$local_tag" >/dev/null
docker pull "$virt_tag" >/dev/null

echo "artifactory docker passed"
