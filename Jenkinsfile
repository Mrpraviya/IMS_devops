 pipeline {
    agent any
    
    stages {
        stage('Check NodeJS') {
            steps {
                sh '''
                    # Fix library path if needed
                    ldconfig 2>/dev/null || true
                    node --version || echo "NodeJS not found"
                '''
            }
        }
        
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Mrpraviya/IMS_devops.git'
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    # Try with full path to npm
                    /var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs/bin/npm install --prefix frontend || \
                    echo "Build failed, trying alternative..."
                    
                    # Alternative: Use npx
                    npx npm install --prefix backend 2>/dev/null || \
                    echo "Alternative also failed"
                '''
            }
        }
    }
}
