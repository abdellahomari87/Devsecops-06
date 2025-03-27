def registry = 'https://trialavw1yt.jfrog.io'
def imageName = 'trialavw1yt.jfrog.io/omari87-docker-local/sample_app'
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
                echo "----------- build started ----------"
                withCredentials([usernamePassword(credentialsId: 'jfrog_cred', usernameVariable: 'abdellah.omari88@gmail.com', passwordVariable: 'cmVmdGtuOjAxOjE3NzQ2NDkwODU6VlNRMHdOVHlCVHVmcmtXQWF2anJOaWVoUXZV')]) {
                    sh 'mvn clean deploy -Dmaven.test.skip=true -Dusername=$JFROG_USER -Dpassword=$JFROG_PASS'
                }
                echo "----------- build completed ----------"
            }
        }
        stage("build"){
            steps {
                 echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                 echo "----------- build complted ----------"
            }
        }
        stage("test"){
            steps{
                echo "----------- unit test started ----------"
                sh 'mvn surefire-report:report'
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
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jfrog_cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "mmmmm-libs-snapshot-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
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


