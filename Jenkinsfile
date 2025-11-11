pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/Mrpraviya/IMS_devops.git'
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
        sh 'npm test --prefix backend'
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
        sh 'docker-compose down && docker-compose up -d'
      }
    }
  }
}
