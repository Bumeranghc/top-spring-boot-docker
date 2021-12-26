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
                    dockerImage.run('-p 1234:8080 -h demo --name demo')	
					httpStatus = sh(script: "curl -s -w '%{http_code}' localhost:1234 -o /dev/null", returnStdout: true)
					if (httpStatus != "200" && httpStatus != "201" ) {
						echo "Service error with status code = ${httpStatus} when calling ${ppcUrl}"
						error("notify error")
					} else {
						echo "Service OK with status: ${httpStatus}"
					}
					sh "docker rmi demo"					
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
