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
          docker exec smoke python - << 'EOF'
import urllib.request, sys
try:
    sys.exit(0 if urllib.request.urlopen('http://localhost:8000').getcode()==200 else 1)
except:
    sys.exit(1)
EOF
          docker stop smoke || true
        """
      }
    }

    stage('Code Quality') {
      steps {
        echo "📊 Linting with Flake8 and Pylint..."
        sh """
          # Our WORKDIR in the image is /app/databytes, so DBweb/ is the app dir
          docker run --rm $IMAGE:$TAG flake8 DBweb
          docker run --rm $IMAGE:$TAG pylint --exit-zero DBweb
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
