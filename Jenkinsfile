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
          # Remove any old 'smoke' container
          docker rm -f smoke || true

          # Start fresh on the host network
          docker run --rm -d --network host --name smoke $IMAGE:$TAG
          sleep 5

          # Hit the health endpoint
          curl --fail http://localhost:8000/ || (docker logs smoke && exit 1)

          # Stop (and auto-remove) the smoke container
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
