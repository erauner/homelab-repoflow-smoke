#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "${REPO_ROOT}/charts/rf-helm-smoke" "$work/rf-helm-smoke"

sed -i.bak "s/^version: .*/version: ${SMOKE_VERSION}/" "$work/rf-helm-smoke/Chart.yaml"
sed -i.bak "s/^appVersion: .*/appVersion: \"${SMOKE_VERSION}\"/" "$work/rf-helm-smoke/Chart.yaml"
rm -f "$work/rf-helm-smoke/Chart.yaml.bak"

pushd "$work" >/dev/null
helm package rf-helm-smoke -d . >/dev/null
curl -fsS -u "${ARTI_USER}:${ARTI_PASSWORD}" -T "rf-helm-smoke-${SMOKE_VERSION}.tgz" \
  "${ARTI_BASE}/${ARTI_HELM_LOCAL_REPO}/rf-helm-smoke-${SMOKE_VERSION}.tgz" >/dev/null
helm repo add arti-smoke "${ARTI_BASE}/${ARTI_HELM_VIRTUAL_REPO}" \
  --username "${ARTI_USER}" --password "${ARTI_PASSWORD}" >/dev/null
helm repo update >/dev/null
helm pull arti-smoke/rf-helm-smoke --version "${SMOKE_VERSION}" >/dev/null
popd >/dev/null

echo "artifactory helm passed"
