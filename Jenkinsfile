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

        stage('Maven-build'){
            agent {
                docker {
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                sh "${MVN} verify -DskipTests"
            }
        }

        stage('Get-latest-jars'){
            agent {
                docker {
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

        stage('Split-tests.txt'){
            agent {
                docker {
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                script {
                    // Read the original file
                    def originalFile = readFile('tests.txt')
                    def lines = originalFile.readLines()
                    echo "Read lines!"
                    // Calculate the number of lines per file
                    def linesPerFile = 100
                    echo "${linesPerFile}"
                    // Split the lines into four files
                    for (i = 0; i < 3; i++) {
                        def startIndex = i * linesPerFile
                        def endIndex = (i < 2) ? (startIndex + linesPerFile) : lines.size()
                        echo "PER FILE!"
                        
                        // Create a new file with the lines
                        def outputFile = "test${i + 1}r"
                        writeFile(file: outputFile, text: lines.subList(startIndex, endIndex).join('\n'))
                    }
                }
            }
        }

        stage('Get-jars'){
            agent {
                docker {
                    image 'maven:3.6.3-jdk-8'
                    args '--network jenkins_jenkins_network'
                }
            }

            steps {
                sh "curl -u admin:Al12341234 -O 'http://artifactory:8082/artifactory/libs-snapshot-local/com/lidar/telemetry/99-SNAPSHOT${JARTM}'"
                sh "curl -u admin:Al12341234 -O 'http://artifactory:8082/artifactory/libs-snapshot-local/com/lidar/analytics/99-SNAPSHOT${JARAN}'"
                sh "rm tests.txt"
                sh "ls -l"
                sh "ls target"
                stash includes: 'test*r', name: 'tests'
                stash includes: '*.jar', name: 'jars'
                stash includes: 'target/*.jar', name: 'simulator'
                // sh "java -cp .${JARAN}:.${JARTM}:target/simulator-99-SNAPSHOT.jar com.lidar.simulation.Simulator"
            }
        }

        stage('Test'){
            parallel {
                stage('Test1'){
                    agent {
                        docker {
                            image 'maven:3.6.3-jdk-8'
                            args '--network jenkins_jenkins_network'
                        }
                    }

                    steps {
                        unstash 'tests'
                        unstash 'jars'
                        unstash 'simulator'
                        sh "ls"
                        sh "mv test1r tests.txt"
                        sh "java -cp .${JARAN}:.${JARTM}:target/simulator-99-SNAPSHOT.jar com.lidar.simulation.Simulator"
                    }
                }

                stage('Test2'){
                    agent {
                        docker {
                            image 'maven:3.6.3-jdk-8'
                            args '--network jenkins_jenkins_network'
                        }
                    }

                    steps {
                        unstash 'tests'
                        unstash 'jars'
                        unstash 'simulator'
                        sh "ls"
                        sh "mv test2r tests.txt"
                        sh "java -cp .${JARAN}:.${JARTM}:target/simulator-99-SNAPSHOT.jar com.lidar.simulation.Simulator"
                    }
                }

                stage('Test3'){
                    agent {
                        docker {
                            image 'maven:3.6.3-jdk-8'
                            args '--network jenkins_jenkins_network'
                        }
                    }

                    steps {
                        unstash 'tests'
                        unstash 'jars'
                        unstash 'simulator'
                        sh "ls"
                        sh "mv test3r tests.txt"
                        sh "java -cp .${JARAN}:.${JARTM}:target/simulator-99-SNAPSHOT.jar com.lidar.simulation.Simulator"
                    }
                }
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

            post {
                always {
                    cleanWs()
                }
            }

        }

    }

    post {
        always {
            cleanWs()
        }
    }
}