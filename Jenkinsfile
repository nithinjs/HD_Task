pipeline {
  agent any

  environment {
    IMAGE = "databytes-web"
    TAG   = "${env.GIT_COMMIT}"
  }

  stages {
    stage('Build') {
      steps {
        echo "🔨 Building Docker image..."
        sh "docker build -t $IMAGE:$TAG ."
      }
    }

    stage('Test') {
      steps {
        echo "✅ Running Django tests..."
        sh "docker run --rm $IMAGE:$TAG python manage.py test --verbosity=2"
      }
    }

    stage('Smoke Test') {
      steps {
        echo "🚦 Smoke-testing the container…"
        sh """
          docker rm -f smoke || true
          docker run --rm -d --name smoke $IMAGE:$TAG
          sleep 5
          # simple HTTP check inside the container
          docker exec smoke python - << 'EOF'
import urllib.request, sys
sys.exit(0 if urllib.request.urlopen('http://localhost:8000').getcode()==200 else 1)
EOF
          docker stop smoke || true
        """
      }
    }

    stage('Code Quality') {
      steps {
        echo "📊 Linting with Flake8 and Pylint (warnings only)…"
        sh """
          docker run --rm $IMAGE:$TAG flake8 --exit-zero DBweb
          docker run --rm $IMAGE:$TAG pylint --exit-zero DBweb
        """
      }
    }

    stage('Security Scan') {
    steps {
      echo '🛡️ Scanning image for vulnerabilities (Trivy)…'
      sh '''
        docker pull aquasec/trivy:latest

        # run Trivy in “report-only” mode:
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \\
          aquasec/trivy:latest image \\
            --severity HIGH,CRITICAL \\
            --ignore-unfixed       \\
            --exit-code 0          \\
            nithinjs/databytes-web:latest
      '''
    }
  }
  }

  post {
    always {
      echo "🚧 Pipeline finished with status: ${currentBuild.currentResult}"
    }
  }
}
