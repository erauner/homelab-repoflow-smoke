#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

ver="0.2.${RUN_TS}"
pushd "$work" >/dev/null
helm create rf-helm-smoke >/dev/null
sed -i "s/^version: .*/version: ${ver}/" rf-helm-smoke/Chart.yaml
helm package rf-helm-smoke -d . >/dev/null

api_post_form "/1/workspaces/${REPOFLOW_WORKSPACE}/repositories/helm-local/packages/single" \
  -F "packageFiles=@rf-helm-smoke-${ver}.tgz" >/dev/null

helm repo add rf-smoke "${REPOFLOW_API_URL}/helm/${REPOFLOW_WORKSPACE}/helm" \
  --username token --password "${REPOFLOW_PAT}" >/dev/null
helm repo update >/dev/null
helm pull rf-smoke/rf-helm-smoke --version "${ver}" >/dev/null
popd >/dev/null

echo "helm smoke passed: rf-helm-smoke ${ver}"
