pipeline {
	agent any

	triggers {
		pollSCM 'H/10 * * * *'
	}

	options {
		disableConcurrentBuilds()
		buildDiscarder(logRotator(numToKeepStr: '14'))
	}

	stages {
		stage("test: baseline (jdk8)") {
			agent {
				docker {
					image 'adoptopenjdk/openjdk8:latest'
					args '-v $HOME/.m2:/tmp/jenkins-home/.m2'
				}
			}
			options { timeout(time: 30, unit: 'MINUTES') }
			steps {
				sh 'cd test && chmod -R a+x run.sh && bash run.sh'
			}
		}
        stage ('Build') {
            steps {
                script {
                    checkout scm
					sh 'cd demo && ./mvnw -B -DskipTests clean package'
					dockerImage=docker.build("bumeranghc/springbootdemo" + ":$BUILD_NUMBER", "-f demo/Dockerfile ./demo")
                }
            }
        }
		stage ('REST test') {
            steps {
                script {
                    dockerImage.withRun('-p 1234:8080 -h demo --name demo')	{ container ->
						httpStatus = sh(script: 'sleep 5 && curl -s localhost:1234/actuator/health | grep -q "{\"status\":\"UP\"}"', returnStatus: true)  == 0
						echo "Exit status: ${httpStatus}"
						if (httpStatus == 0) {
							echo "Up and running"
						} else {
							echo "Down"
						}
					}					
                }
            }
        }
		stage ('Deploy') {
            steps {
                script {
                        docker.withRegistry('', 'DockerHubBumeranghc') {
                        dockerImage.push()
                    }
                }
            }
        }
        stage ('Clean') {
            steps {
                sh "docker rmi bumeranghc/springbootdemo:$BUILD_NUMBER"
            }
        }
	}

	post {
		changed {
			script {
				//slackSend(
				//		color: (currentBuild.currentResult == 'SUCCESS') ? 'good' : 'danger',
				//		channel: '#sagan-content',
				//		message: "${currentBuild.fullDisplayName} - `${currentBuild.currentResult}`\n${env.BUILD_URL}")
				//emailext(
				//		subject: "[${currentBuild.fullDisplayName}] ${currentBuild.currentResult}",
				//		mimeType: 'text/html',
				//		recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']],
				//		body: "<a href=\"${env.BUILD_URL}\">${currentBuild.fullDisplayName} is reported as ${currentBuild.currentResult}</a>")
				echo 'test2'
			}
		}
	}
}
