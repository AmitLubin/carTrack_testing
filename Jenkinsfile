def JARTM=""
def JARAN=""

pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        MVN="mvn -s settings.xml"
    }

    stages {
        stage('Git-checkout'){
            steps {
                deleteDir()
                checkout scm
            }
        }

        stage('Maven-deploy'){
            agent {
                docker {
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                sh "${MVN} deploy -DskipTests"
            }
        }

        stage('Get-latest-jars'){
            agent {
                docker {
                    // image 'openjdk:8-jre-alpine3.9'
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                script {
                    def analytics = sh(script: "curl -u admin:Al12341234 -X GET 'http://artifactory:8082/artifactory/api/storage/libs-snapshot-local/com/lidar/analytics/99-SNAPSHOT/'", returnStdout: true)
                    def telemetry = sh(script: "curl -u admin:Al12341234 -X GET 'http://artifactory:8082/artifactory/api/storage/libs-snapshot-local/com/lidar/telemetry/99-SNAPSHOT/'", returnStdout: true)

                    def jsonSlurper = new groovy.json.JsonSlurper()
                    def parsedAnalytics = jsonSlurper.parseText(analytics)
                    def parsedTelemetry = jsonSlurper.parseText(telemetry)

                    // Extract the JAR file URI
                    def jarAnalytics = parsedAnalytics.children.find { it.uri.endsWith(".jar") }?.uri
                    def jarTelemetry = parsedTelemetry.children.find { it.uri.endsWith(".jar") }?.uri

                    echo "${jarAnalytics}"
                    echo "${jarTelemetry}"

                    JARAN = jarAnalytics
                    JARTM = jarTelemetry
                }
            }
        }

        stage('Test'){
            agent {
                docker {
                    // image 'openjdk:8-jre-alpine3.9'
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                sh "curl -u admin:Al12341234 -O 'http://artifactory:8082/artifactory/libs-snapshot-local/com/lidar/telemetry/99-SNAPSHOT${JARTM}'"
                sh "curl -u admin:Al12341234 -O 'http://artifactory:8082/artifactory/libs-snapshot-local/com/lidar/analytics/99-SNAPSHOT${JARAN}'"
                sh "ls -l"
                sh "ls target"
                sh "java -cp .${JARSAN}:.${JARTM}:target/simulator-99-SNAPSHOT.jar com.lidar.simulation.Simulator"
            }
        }


    }

    post {
        always {
            cleanWs()
        }
    }
}