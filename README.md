# homelab-registry-smoke

CI smoke repository for validating package publish/pull parity across RepoFlow and Nexus using real project directories that Jenkins builds.

## Repository layout

- `packages/npm`: Node package
- `packages/python`: Python package
- `packages/go`: Go module/app used for proxy fetch checks
- `charts/rf-helm-smoke`: Helm chart for RepoFlow checks
- `assets/universal`: Generic payload files
- `docker`: Docker context
- `ci/`: RepoFlow CI stage scripts
- `ci/nexus/`: Nexus parity CI stage scripts

## Jenkins parameters

RepoFlow:
- `REPOFLOW_BASE_URL` (default: `https://repoflow.erauner.dev`)
- `REPOFLOW_WORKSPACE` (default: `homelab`)

Shared:
- `RUN_DOCKER` (default: `false`)

Nexus parity:
- `RUN_NEXUS` (default: `false`)
- `NEXUS_BASE_URL` (default: `https://nexus.erauner.dev`)
- `NEXUS_CREDENTIALS_ID` (default: `nexus-credentials`)
- `NEXUS_NPM_HOSTED_REPO` / `NEXUS_NPM_PROXY_REPO`
- `NEXUS_PYPI_HOSTED_REPO` / `NEXUS_PYPI_PROXY_REPO`
- `NEXUS_GO_PROXY_REPO`
- `NEXUS_RAW_HOSTED_REPO`
- `NEXUS_DOCKER_HOSTED_REPO`
- `NEXUS_DOCKER_REGISTRY`

## Jenkins credentials

- RepoFlow: `repoflow-credentials` (`username=token`, `password=PAT`)
- Nexus: `nexus-credentials` (username/password)

## Notes

- Docker stages are optional because they require daemon access in the Jenkins agent runtime.
- Virtual/proxy repository reads include retry logic to avoid indexing/metadata propagation flakes.
- Use the multibranch job path `erauner/homelab-registry-smoke/main`.
