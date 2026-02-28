@Library('homelab') _

pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    workload-type: ci-builds
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    resources:
      requests: { cpu: "100m", memory: "256Mi" }
      limits:   { cpu: "500m", memory: "512Mi" }
  - name: node
    image: node:20-bookworm
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "100m", memory: "256Mi" }
      limits:   { cpu: "500m", memory: "512Mi" }
  - name: python
    image: python:3.12-bookworm
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "100m", memory: "256Mi" }
      limits:   { cpu: "500m", memory: "512Mi" }
  - name: golang
    image: golang:1.22
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "200m", memory: "512Mi" }
      limits:   { cpu: "1000m", memory: "1Gi" }
  - name: helm
    image: alpine/helm:3.15.2
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "50m", memory: "128Mi" }
      limits:   { cpu: "250m", memory: "256Mi" }
  - name: curl
    image: curlimages/curl:8.10.1
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "50m", memory: "128Mi" }
      limits:   { cpu: "250m", memory: "256Mi" }
  - name: docker
    image: docker:27-cli
    command: ['sleep', '3600']
    resources:
      requests: { cpu: "100m", memory: "256Mi" }
      limits:   { cpu: "500m", memory: "512Mi" }
'''
    }
  }

  options {
    timeout(time: 30, unit: 'MINUTES')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    string(name: 'REPOFLOW_BASE_URL', defaultValue: 'https://repoflow.erauner.dev', description: 'RepoFlow base URL')
    string(name: 'REPOFLOW_WORKSPACE', defaultValue: 'homelab', description: 'RepoFlow workspace name')
    booleanParam(name: 'RUN_DOCKER', defaultValue: false, description: 'Enable Docker push/pull check (requires docker daemon access)')
    booleanParam(name: 'RUN_ARTIFACTORY', defaultValue: false, description: 'Run mirrored publish/pull checks against Artifactory')
    string(name: 'ARTIFACTORY_BASE_URL', defaultValue: 'https://artifactory.erauner.dev/artifactory', description: 'Artifactory base URL')
    string(name: 'ARTIFACTORY_CREDENTIALS_ID', defaultValue: 'nexus-credentials', description: 'Jenkins username/password credential id for Artifactory')
    string(name: 'ARTI_NPM_LOCAL_REPO', defaultValue: 'npm-local', description: 'Artifactory npm local repo key')
    string(name: 'ARTI_NPM_VIRTUAL_REPO', defaultValue: 'npm', description: 'Artifactory npm virtual repo key')
    string(name: 'ARTI_PYPI_LOCAL_REPO', defaultValue: 'pypi-local', description: 'Artifactory PyPI local repo key')
    string(name: 'ARTI_PYPI_VIRTUAL_REPO', defaultValue: 'pypi', description: 'Artifactory PyPI virtual repo key')
    string(name: 'ARTI_GO_VIRTUAL_REPO', defaultValue: 'go', description: 'Artifactory Go virtual repo key')
    string(name: 'ARTI_HELM_LOCAL_REPO', defaultValue: 'helm-local', description: 'Artifactory Helm local repo key')
    string(name: 'ARTI_HELM_VIRTUAL_REPO', defaultValue: 'helm', description: 'Artifactory Helm virtual repo key')
    string(name: 'ARTI_GENERIC_LOCAL_REPO', defaultValue: 'generic-local', description: 'Artifactory generic local repo key')
    string(name: 'ARTI_GENERIC_VIRTUAL_REPO', defaultValue: 'generic', description: 'Artifactory generic virtual repo key')
    string(name: 'ARTI_DOCKER_LOCAL_REPO', defaultValue: 'docker-local', description: 'Artifactory Docker local repo key')
    string(name: 'ARTI_DOCKER_VIRTUAL_REPO', defaultValue: 'docker', description: 'Artifactory Docker virtual repo key')
    string(name: 'ARTI_DOCKER_REGISTRY', defaultValue: '', description: 'Optional Docker registry host override for Artifactory')
  }

  environment {
    REPOFLOW_BASE_URL = "${params.REPOFLOW_BASE_URL}"
    REPOFLOW_WORKSPACE = "${params.REPOFLOW_WORKSPACE}"
    REPOFLOW_CREDENTIALS = credentials('repoflow-credentials')
    SMOKE_RUN_ID = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(8) ?: 'dev'}"
  }

  stages {
    stage('Validate Inputs') {
      steps {
        echo 'Using Jenkins credential: repoflow-credentials'
        script {
          if (params.RUN_ARTIFACTORY && !params.ARTIFACTORY_CREDENTIALS_ID?.trim()) {
            error('ARTIFACTORY_CREDENTIALS_ID is required when RUN_ARTIFACTORY=true')
          }
        }
      }
    }

    stage('npm') {
      steps {
        container('node') {
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-npm.sh'
        }
      }
    }

    stage('pypi') {
      steps {
        container('python') {
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-pypi.sh'
        }
      }
    }

    stage('go') {
      steps {
        container('golang') {
          sh 'apt-get update >/dev/null && apt-get install -y git >/dev/null'
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-go.sh'
        }
      }
    }

    stage('helm') {
      steps {
        container('helm') {
          sh 'apk add --no-cache bash curl tar gzip >/dev/null'
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-helm.sh'
        }
      }
    }

    stage('universal') {
      steps {
        container('helm') {
          sh 'apk add --no-cache bash curl tar gzip >/dev/null'
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-universal.sh'
        }
      }
    }

    stage('docker') {
      when {
        expression { return params.RUN_DOCKER }
      }
      steps {
        container('docker') {
          sh 'export REPOFLOW_PAT="$REPOFLOW_CREDENTIALS_PSW"; bash ci/test-docker.sh'
        }
      }
    }

    stage('artifactory/npm') {
      when {
        expression { return params.RUN_ARTIFACTORY }
      }
      steps {
        container('node') {
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_NPM_LOCAL_REPO="$ARTI_NPM_LOCAL_REPO"; export ARTI_NPM_VIRTUAL_REPO="$ARTI_NPM_VIRTUAL_REPO"; bash ci/artifactory/test-npm.sh'
          }
        }
      }
    }

    stage('artifactory/pypi') {
      when {
        expression { return params.RUN_ARTIFACTORY }
      }
      steps {
        container('python') {
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_PYPI_LOCAL_REPO="$ARTI_PYPI_LOCAL_REPO"; export ARTI_PYPI_VIRTUAL_REPO="$ARTI_PYPI_VIRTUAL_REPO"; bash ci/artifactory/test-pypi.sh'
          }
        }
      }
    }

    stage('artifactory/go') {
      when {
        expression { return params.RUN_ARTIFACTORY }
      }
      steps {
        container('golang') {
          sh 'apt-get update >/dev/null && apt-get install -y git >/dev/null'
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_GO_VIRTUAL_REPO="$ARTI_GO_VIRTUAL_REPO"; bash ci/artifactory/test-go.sh'
          }
        }
      }
    }

    stage('artifactory/helm') {
      when {
        expression { return params.RUN_ARTIFACTORY }
      }
      steps {
        container('helm') {
          sh 'apk add --no-cache bash curl tar gzip >/dev/null'
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_HELM_LOCAL_REPO="$ARTI_HELM_LOCAL_REPO"; export ARTI_HELM_VIRTUAL_REPO="$ARTI_HELM_VIRTUAL_REPO"; bash ci/artifactory/test-helm.sh'
          }
        }
      }
    }

    stage('artifactory/universal') {
      when {
        expression { return params.RUN_ARTIFACTORY }
      }
      steps {
        container('helm') {
          sh 'apk add --no-cache bash curl tar gzip >/dev/null'
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_GENERIC_LOCAL_REPO="$ARTI_GENERIC_LOCAL_REPO"; export ARTI_GENERIC_VIRTUAL_REPO="$ARTI_GENERIC_VIRTUAL_REPO"; bash ci/artifactory/test-universal.sh'
          }
        }
      }
    }

    stage('artifactory/docker') {
      when {
        expression { return params.RUN_ARTIFACTORY && params.RUN_DOCKER }
      }
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: params.ARTIFACTORY_CREDENTIALS_ID, usernameVariable: 'ARTI_USER', passwordVariable: 'ARTI_PASSWORD')]) {
            sh 'export ARTIFACTORY_BASE_URL="$ARTIFACTORY_BASE_URL"; export ARTI_DOCKER_LOCAL_REPO="$ARTI_DOCKER_LOCAL_REPO"; export ARTI_DOCKER_VIRTUAL_REPO="$ARTI_DOCKER_VIRTUAL_REPO"; export ARTI_DOCKER_REGISTRY="$ARTI_DOCKER_REGISTRY"; bash ci/artifactory/test-docker.sh'
          }
        }
      }
    }
  }

  post {
    success {
      echo 'RepoFlow smoke checks passed'
    }
    failure {
      script {
        homelab.notifyDiscord(status: 'FAILURE')
      }
    }
  }
}
