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
        echo "🚦 Smoke-testing the container..."
        sh """
          docker run --rm -d -p 8000:8000 --name smoke $IMAGE:$TAG
          sleep 5
          curl --fail http://localhost:8000/ || (docker logs smoke && exit 1)
          docker stop smoke
        """
      }
    }

    stage('Code Quality') {
      steps {
        echo "📊 Linting with Flake8 and Pylint..."
        sh """
          # Flake8 will catch style issues:
          docker run --rm $IMAGE:$TAG flake8 databytes/DBweb

          # Pylint will report code smells and complexity:
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
