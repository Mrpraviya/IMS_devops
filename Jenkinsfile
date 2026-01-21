 pipeline {
  agent {
    docker {
      image 'node:20-alpine'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/Mrpraviya/IMS_devops.git'
      }
    }

    stage('Build') {
      steps {
        sh 'npm install --prefix frontend'
        sh 'npm install --prefix backend'
      }
    }

    stage('Test') {
      steps {
        sh 'npm test --prefix backend || true'
      }
    }

    stage('Docker Build & Push') {
      steps {
        sh 'docker build -t sandeeptha/inventory-frontend ./frontend'
        sh 'docker build -t sandeeptha/inventory-backend ./backend'
        sh 'docker push sandeeptha/inventory-frontend'
        sh 'docker push sandeeptha/inventory-backend'
      }
    }

    stage('Deploy') {
      steps {
        sh 'docker-compose down || true'
        sh 'docker-compose up -d'
      }
    }
  }
}
