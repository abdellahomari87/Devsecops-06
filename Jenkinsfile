def registry = 'https://trialavw1yt.jfrog.io'
def imageName = 'trialavw1yt.jfrog.io/mmmm-omari87-docker-local/sample_app'
def version   = '2.1.2-SNAPSHOT'
pipeline {
    agent {
        node {
            label 'maven-build'
        }
    }
environment {
    PATH = "/opt/apache-maven-3.9.4/bin:$PATH"
}
    stages {
        stage("build") {
            steps {
                echo "----------- build completed ----------"
                withCredentials([usernamePassword(credentialsId: 'jfrog_cred', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
                    sh '''#!/bin/bash
                        echo "JFrog username: $JFROG_USER"
                        mvn clean deploy -Dmaven.test.skip=true -s /home/ubuntu/.m2/settings.xml
                    '''
                }
            }        
        }
        stage("test"){
            steps{
                echo "----------- unit test started ----------"
                sh 'mvn -e -X test'
                 echo "----------- unit test Complted ----------"
            }
        }

        stage('SonarCloud analysis') {
        environment {
          SONAR_TOKEN = credentials('sonarcloud-token')
        }
            steps{
            withSonarQubeEnv('SonarCloud') { // If you have configured more than one global server connection, you can specify its name
              sh """
                mvn clean verify sonar:sonar \
                -Dsonar.login=$SONAR_TOKEN \
                -Dmaven.test.skip=true
              """
            }
            }
        }
        stage("Quality Gate"){
            steps {
                script {
                timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
            def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
            if (qg.status != 'OK') {
            error "Pipeline aborted due to quality gate failure: ${qg.status}"
            }
        }
        }
            }
        }
         stage("Jar Publish") {
             steps {
                 script {
                 echo '<--------------- Jar Publish Started --------------->'
            
                 // Copier le bon artefact SNAPSHOT dans le dossier staging
                 sh 'mkdir -p jarstaging && cp target/*.jar jarstaging/ && cp target/*.pom jarstaging/ || true'
                 def server = Artifactory.newServer url:registry+"/artifactory", credentialsId:"jfrog_cred"
                 def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}"
                 def uploadSpec = """{
                   "files": [
                     {
                       "pattern": "jarstaging/*.jar",
                       "target": "mmmmm-libs-snapshot-local/io/github/abdellahomari87/demo-workshop/${version}/",
                       "flat": true,
                       "props" : "${properties}"
                      }
                    ]
                 }"""

                def buildInfo = server.upload(uploadSpec)
                buildInfo.env.collect()
                server.publishBuildInfo(buildInfo)

                echo '<--------------- Jar Publish Ended --------------->'
                }
        }   
    }

    stage(" Docker Build ") {
      steps {
        script {
           echo '<--------------- Docker Build Started --------------->'
           app = docker.build(imageName+":"+version)
           echo '<--------------- Docker Build Ends --------------->'
        }
      }
    }

            stage (" Docker Publish "){
        steps {
            script {
               echo '<--------------- Docker Publish Started --------------->'  
                docker.withRegistry(registry, 'jfrog_cred'){
                    app.push()
                }    
               echo '<--------------- Docker Publish Ended --------------->'  
            }
        }
    }

    // stage (" Deploy "){
    //     steps {
    //         script {
    //            sh './deploy.sh'  
    //         }
    //     }
    // }

stage(" Deploy ") {
       steps {
         script {
            echo '<--------------- Helm Deploy Started --------------->'
            sh 'helm install sample-app sample-app-1.0.1'
            echo '<--------------- Helm deploy Ends --------------->'
         }
       }
}  
}
}


