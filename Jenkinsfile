pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'SonarQube'       
        MAVEN_HOME = tool 'Maven 3'              
        NEXUS_REPO = 'maven-releases'            
        NEXUS_URL = 'http://3.110.120.48:30001' 
        NEXUS_CREDENTIALS_ID = 'nexus'    
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
                    sh "${MAVEN_HOME}/bin/mvn clean verify sonar:sonar -Dcheckstyle.skip=true"
                }
            }
        }

        stage('Build') {
            steps {
                sh "${MAVEN_HOME}/bin/mvn -B clean package -DskipTests -Dcheckstyle.skip=true"
            }
        }

        stage('Version Build') {
            steps {
                script {
                    // You can use timestamp or git commit hash
                    def version = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    env.BUILD_VERSION = "1.0.0-${version}"
                    
                    sh """
                        cp target/spring-petclinic-3.5.0-SNAPSHOT.jar target/petclinic-${BUILD_VERSION}.jar
                    """
                }
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
                withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        curl -v -u $NEXUS_USER:$NEXUS_PASS \
                        --upload-file target/petclinic-${BUILD_VERSION}.jar \
                        $NEXUS_URL/repository/maven-releases/com/spring/petclinic/1.0.0/petclinic-${BUILD_VERSION}.jar
                    '''
                }
            }
        }
    }
}
