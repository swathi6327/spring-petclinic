pipeline {
    agent any

    environment {
        MAVEN_HOME = tool 'Maven 3'
        JAVA_HOME = tool 'JDK 17'
        PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
        IMAGE_TAG = "1.0.0-${new Date().format('yyyyMMddHHmmss')}"
    }

    stages {

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Version Build') {
            steps {
                script {
                    def timestamp = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    env.BUILD_TIMESTAMP = timestamp
                    sh "mv target/spring-petclinic-3.5.0-SNAPSHOT.jar target/petclinic-${IMAGE_TAG}.jar"
                }
            }
        }

        stage('Publish to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        curl -v -u $NEXUS_USER:$NEXUS_PASS \
                        --upload-file target/petclinic-${IMAGE_TAG}.jar \
                        http://65.0.75.191:30801/repository/maven-releases/com/spring/petclinic/1.0.0/petclinic-${IMAGE_TAG}.jar
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        curl -u $NEXUS_USER:$NEXUS_PASS -O http://65.0.75.191:30801/repository/maven-releases/com/spring/petclinic/1.0.0/petclinic-${IMAGE_TAG}.jar
                        mv petclinic-${IMAGE_TAG}.jar petclinic.jar
                    '''
                }

                sh '''
                    docker build -t 65.0.75.191:30002/petclinic:${IMAGE_TAG} .
                '''

                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login 65.0.75.191:30002 -u $DOCKER_USER --password-stdin
                        docker push 65.0.75.191:30002/petclinic:${IMAGE_TAG}
                    '''
                }
            }
        }
    }
}
