pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'SonarQube'  // Configure this in Jenkins > Manage Jenkins > Global Tool Configuration
        MAVEN_HOME = tool 'Maven 3'     // Adjust name as per your Jenkins config
        NEXUS_REPO = 'maven-releases'   // Your Nexus repository name
        NEXUS_URL = 'http://nexus-service.nexus.svc.cluster.local:8081' // Internal K8s URL for Nexus
        NEXUS_CREDENTIALS_ID = 'nexus' // Credentials stored in Jenkins (username + password)
    }

    options {
        skipStagesAfterUnstable()
    }

    stages {
        stage('Checkout') {
            when {
                branch 'main'
            }
            steps {
                git url: 'https://github.com/yeshcrik/spring-petclinic.git', branch: 'main'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh "${MAVEN_HOME}/bin/mvn clean verify sonar:sonar"
                }
            }
        }

        stage('Build') {
            steps {
                sh "${MAVEN_HOME}/bin/mvn clean package -DskipTests"
            }
        }

        stage('Manual Approval') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "Approve deployment to Nexus?", ok: "Deploy"
                }
            }
        }

        stage('Publish to Nexus') {
            steps {
                script {
                    def jarFile = sh(script: "ls target/*.jar | head -1", returnStdout: true).trim()
                    withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh """
                        curl -v -u $NEXUS_USER:$NEXUS_PASS --upload-file ${jarFile} \
                        ${NEXUS_URL}/repository/${NEXUS_REPO}/com/spring/petclinic/1.0.0/petclinic-1.0.0.jar
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}

