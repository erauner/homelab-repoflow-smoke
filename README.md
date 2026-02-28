# homelab-repoflow-smoke

CI smoke repository for validating RepoFlow publish/pull workflows across package types.

## What it tests

- npm: publish to local repo and install from virtual repo
- PyPI: upload to local repo and install from virtual repo
- Go: pull via virtual Go proxy
- Helm: upload chart to local repo and pull from virtual repo
- Universal: upload file to local repo and download from virtual repo
- Docker (optional): push to local repo and pull from virtual repo

## Jenkins usage

Run the `Jenkinsfile` with:

- `REPOFLOW_BASE_URL` (default: `https://repoflow.erauner.dev`)
- `REPOFLOW_WORKSPACE` (default: `homelab`)
- `REPOFLOW_PAT` (required)
- `RUN_DOCKER` (default: false)

