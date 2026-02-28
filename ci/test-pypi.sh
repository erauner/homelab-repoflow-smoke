#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

python -m pip install -q --upgrade pip build twine

pkg="repoflow_pypi_smoke_${SMOKE_ID//-/_}"
ver="0.0.${RUN_TS}"

mkdir -p "$work/$pkg/$pkg"
cat > "$work/$pkg/pyproject.toml" <<PY
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "${pkg}"
version = "${ver}"
description = "RepoFlow PyPI smoke"
requires-python = ">=3.8"
PY
printf '__all__=["ping"]\n' > "$work/$pkg/$pkg/__init__.py"
printf 'def ping():\n    return "pong"\n' > "$work/$pkg/$pkg/core.py"

pushd "$work/$pkg" >/dev/null
python -m build >/dev/null
python -m twine upload --non-interactive -u token -p "${REPOFLOW_PAT}" \
  --repository-url "${REPOFLOW_API_URL}/pypi/${REPOFLOW_WORKSPACE}/pypi-local/" dist/* >/dev/null
python -m venv .venv
source .venv/bin/activate
pip install "${pkg}==${ver}" --index-url "https://token:${REPOFLOW_PAT}@${host_no_scheme}/api/pypi/${REPOFLOW_WORKSPACE}/pypi/simple" >/dev/null
deactivate
popd >/dev/null

echo "pypi smoke passed: ${pkg}==${ver}"
