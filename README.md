# homelab-registry-smoke

CI smoke repository for validating package publish/pull parity across RepoFlow and Artifactory using real project directories that Jenkins builds.

## Repository layout

- `packages/npm`: Node package published to npm-local and installed from npm (virtual)
- `packages/python`: Python package built and uploaded to pypi-local, then installed from pypi (virtual)
- `packages/go`: Go module/app built with dependencies resolved through Go virtual proxy
- `charts/rf-helm-smoke`: Helm chart packaged and uploaded to helm-local, then pulled from helm (virtual)
- `assets/universal`: Files packaged and uploaded to universal-local, then downloaded from universal (virtual)
- `docker`: Docker context built and pushed to docker-local, then pulled from docker (virtual)
- `ci/`: RepoFlow CI stage scripts used by `Jenkinsfile`
- `ci/artifactory/`: Artifactory parity CI stage scripts used by `Jenkinsfile`

## Jenkins parameters

- `REPOFLOW_BASE_URL` (default: `https://repoflow.erauner.dev`)
- `REPOFLOW_WORKSPACE` (default: `homelab`)
- `RUN_DOCKER` (default: `false`)
- `RUN_ARTIFACTORY` (default: `false`)
- `ARTIFACTORY_BASE_URL` (default: `https://artifactory.erauner.dev/artifactory`)
- `ARTIFACTORY_CREDENTIALS_ID` (default: `nexus-credentials`)
- `ARTI_*_REPO` params for repo keys (npm/pypi/go/helm/generic/docker)

## Jenkins credential

- Credential ID: `repoflow-credentials`
- Type: `Username with password`
- Username: `token`
- Password: RepoFlow PAT

Artifactory credential:

- Credential ID: `nexus-credentials` (default) or set `ARTIFACTORY_CREDENTIALS_ID`
- Type: `Username with password`
- Username/password for your Artifactory instance

## Notes

- Docker stage is optional because it requires daemon access in the Jenkins agent runtime.
- Go stage currently uses `GOSUMDB=off` because RepoFlow Go sumdb proxy support is not enabled.
- Use the multibranch job path `erauner/homelab-registry-smoke/main`; `homelab-repoflow-smoke` is the old renamed repo/job.
