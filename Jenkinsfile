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
          # clean up any old smoke container
          docker rm -f smoke || true

          # start your app (no port mapping needed for this approach)
          docker run --rm -d --name smoke $IMAGE:$TAG

          # give Gunicorn a moment to spin up
          sleep 5

          # use Python inside the container to hit localhost:8000
          docker exec smoke python - << 'EOF'
import urllib.request, sys
try:
    status = urllib.request.urlopen('http://localhost:8000').getcode()
    sys.exit(0 if status == 200 else 1)
except Exception:
    sys.exit(1)
EOF

          # tear it down
          docker stop smoke || true
        """
      }
    }

    stage('Code Quality') {
      steps {
        echo "📊 Linting with Flake8 and Pylint..."
        sh """
          docker run --rm $IMAGE:$TAG flake8 databytes/DBweb
          docker run --rm $IMAGE:$TAG pylint --exit-zero databytes/DBweb
        """
      }
    }
  }

  post {
    always {
      echo "🚧 Pipeline finished with status: ${currentBuild.currentResult}"
    }
  }
}
