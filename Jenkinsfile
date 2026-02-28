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
    booleanParam(name: 'RUN_NEXUS', defaultValue: false, description: 'Run mirrored publish/pull checks against Nexus')
    string(name: 'NEXUS_BASE_URL', defaultValue: 'https://nexus.erauner.dev', description: 'Nexus base URL')
    string(name: 'NEXUS_CREDENTIALS_ID', defaultValue: 'nexus-credentials', description: 'Jenkins username/password credential id for Nexus')
    string(name: 'NEXUS_NPM_HOSTED_REPO', defaultValue: 'npm-hosted', description: 'Nexus npm hosted repo name')
    string(name: 'NEXUS_NPM_PROXY_REPO', defaultValue: 'npm-proxy', description: 'Nexus npm proxy/group repo name')
    string(name: 'NEXUS_PYPI_HOSTED_REPO', defaultValue: 'pypi-hosted', description: 'Nexus PyPI hosted repo name')
    string(name: 'NEXUS_PYPI_PROXY_REPO', defaultValue: 'pypi-proxy', description: 'Nexus PyPI proxy/group repo name')
    string(name: 'NEXUS_GO_PROXY_REPO', defaultValue: 'go-proxy', description: 'Nexus Go proxy repo name')
    string(name: 'NEXUS_RAW_HOSTED_REPO', defaultValue: 'raw-hosted', description: 'Nexus raw hosted repo name')
    string(name: 'NEXUS_DOCKER_HOSTED_REPO', defaultValue: 'homelab', description: 'Nexus docker hosted repo path segment')
    string(name: 'NEXUS_DOCKER_REGISTRY', defaultValue: 'docker.nexus.erauner.dev', description: 'Nexus Docker registry host')
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
          if (params.RUN_NEXUS && !params.NEXUS_CREDENTIALS_ID?.trim()) {
            error('NEXUS_CREDENTIALS_ID is required when RUN_NEXUS=true')
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

    stage('nexus/npm') {
      when {
        expression { return params.RUN_NEXUS }
      }
      steps {
        container('node') {
          withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'export NEXUS_BASE_URL="$NEXUS_BASE_URL"; export NEXUS_NPM_HOSTED_REPO="$NEXUS_NPM_HOSTED_REPO"; export NEXUS_NPM_PROXY_REPO="$NEXUS_NPM_PROXY_REPO"; bash ci/nexus/test-npm.sh'
          }
        }
      }
    }

    stage('nexus/pypi') {
      when {
        expression { return params.RUN_NEXUS }
      }
      steps {
        container('python') {
          withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'export NEXUS_BASE_URL="$NEXUS_BASE_URL"; export NEXUS_PYPI_HOSTED_REPO="$NEXUS_PYPI_HOSTED_REPO"; export NEXUS_PYPI_PROXY_REPO="$NEXUS_PYPI_PROXY_REPO"; bash ci/nexus/test-pypi.sh'
          }
        }
      }
    }

    stage('nexus/go') {
      when {
        expression { return params.RUN_NEXUS }
      }
      steps {
        container('golang') {
          sh 'apt-get update >/dev/null && apt-get install -y git >/dev/null'
          withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'export NEXUS_BASE_URL="$NEXUS_BASE_URL"; export NEXUS_GO_PROXY_REPO="$NEXUS_GO_PROXY_REPO"; bash ci/nexus/test-go.sh'
          }
        }
      }
    }

    stage('nexus/universal') {
      when {
        expression { return params.RUN_NEXUS }
      }
      steps {
        container('helm') {
          sh 'apk add --no-cache bash curl tar gzip >/dev/null'
          withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'export NEXUS_BASE_URL="$NEXUS_BASE_URL"; export NEXUS_RAW_HOSTED_REPO="$NEXUS_RAW_HOSTED_REPO"; bash ci/nexus/test-universal.sh'
          }
        }
      }
    }

    stage('nexus/docker') {
      when {
        expression { return params.RUN_NEXUS && params.RUN_DOCKER }
      }
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'export NEXUS_BASE_URL="$NEXUS_BASE_URL"; export NEXUS_DOCKER_HOSTED_REPO="$NEXUS_DOCKER_HOSTED_REPO"; export NEXUS_DOCKER_REGISTRY="$NEXUS_DOCKER_REGISTRY"; bash ci/nexus/test-docker.sh'
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Registry smoke checks passed'
    }
    failure {
      script {
        homelab.notifyDiscord(status: 'FAILURE')
      }
    }
  }
}
