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

echo "${NEXUS_PASSWORD}" | docker login "${NEXUS_DOCKER_REGISTRY}" -u "${NEXUS_USER}" --password-stdin >/dev/null
hosted_tag="${NEXUS_DOCKER_REGISTRY}/${NEXUS_DOCKER_HOSTED_REPO}/smoke:${SMOKE_VERSION}"
docker build -t "$hosted_tag" "$work" >/dev/null
docker push "$hosted_tag" >/dev/null
docker pull "$hosted_tag" >/dev/null

echo "nexus docker passed"
