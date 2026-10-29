pipeline {
  agent any
  environment {
    IMAGE = "registry.example.com/devsecops-demo:${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('SAST - Semgrep') {
      steps {
        sh 'docker run --rm -v "$PWD:/src" -w /src semgrep/semgrep semgrep scan --config p/ci --severity ERROR --error --json -o semgrep.json'
      }
    }

    stage('SCA - Trivy fs') {
      steps {
        sh 'docker run --rm -v "$PWD:/src" aquasec/trivy fs --scanners vuln,secret --severity CRITICAL,HIGH --ignore-unfixed --exit-code 1 /src'
      }
    }

    stage('IaC - Trivy config') {
      steps {
        sh 'docker run --rm -v "$PWD:/src" aquasec/trivy config --severity CRITICAL,HIGH --exit-code 1 /src/terraform'
      }
    }

    stage('Build') { steps { sh 'docker build -t $IMAGE .' } }

    stage('Container scan gate') {
      steps {
        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity CRITICAL,HIGH --ignore-unfixed --exit-code 1 $IMAGE'
      }
    }

    stage('SBOM - Syft') {
      steps {
        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/out" anchore/syft $IMAGE -o spdx-json=/out/sbom.spdx.json'
      }
    }

    stage('Push, sign, attest') {
      when { branch 'main' }
      steps {
        withCredentials([file(credentialsId: 'cosign-key', variable: 'COSIGN_KEY'),
                         string(credentialsId: 'cosign-password', variable: 'COSIGN_PASSWORD')]) {
          sh '''
            docker push $IMAGE
            REF=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE)
            cosign sign --yes --key $COSIGN_KEY $REF
            cosign attest --yes --key $COSIGN_KEY --type spdxjson --predicate sbom.spdx.json $REF
          '''
        }
      }
    }
  }
  post {
    always { archiveArtifacts artifacts: '*.json', allowEmptyArchive: true }
  }
}