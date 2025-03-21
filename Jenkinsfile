pipeline {
  triggers {
    cron(env.BRANCH_NAME == 'main' ? '@weekly' : '')
  }

  agent {
    label 'Linux && Buildah'
  }

  environment{
    IMAGE = "serviio"
    SERVIIO_VERSION="2.4"

    IMAGE_TAG = "${env.IMAGE}:${env.SERVIIO_VERSION}"
    IMAGE_LATEST = "${env.IMAGE}:latest"
    LOCAL_REGISTRY_IMAGE_TAG_NAME = "${env.REGISTRY_LOCAL}/${env.IMAGE_TAG}"
    LOCAL_REGISTRY_IMAGE_LATEST_NAME = "${env.REGISTRY_LOCAL}/${env.IMAGE_LATEST}"
  }

  stages {
    stage('Initialize') {
      parallel {
        stage('Advertising start of build') {
          steps{
            slackSend color: "#4675b1", message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} started :fire: (<${env.RUN_DISPLAY_URL}|Open>)"
          }
        }

        stage('Print environments variables') {
          steps {
            sh 'printenv | sort'
          }
        }

        stage('Print Buildah infos') {
          steps {
            sh '''
              buildah version
              buildah info
            '''
          }
        }
      }
    }

    stage('Building image') {
      steps {
        sh '''
          buildah build \
            --pull \
            --build-arg Serviio_Version=$SERVIIO_VERSION \
            -t $LOCAL_REGISTRY_IMAGE_TAG_NAME \
            .
          buildah tag $LOCAL_REGISTRY_IMAGE_TAG_NAME $LOCAL_REGISTRY_IMAGE_LATEST_NAME
        '''
      }
    }

    stage('Pushing images') {
      parallel{
        stage("Push Tagged image to local registry") {
          steps {
            sh 'buildah push $LOCAL_REGISTRY_IMAGE_TAG_NAME'
          }
        }

        stage("Push latest image to local registry") {
          steps {
            sh 'buildah push $LOCAL_REGISTRY_IMAGE_LATEST_NAME'
          }
        }
      }
    }
  }

  post {
    success {
      slackSend color: "#4675b1", message: "${env.JOB_NAME} successfully built :blue_heart: !"
    }

    failure {
      slackSend color: "danger", message: "${env.JOB_NAME} build failed :poop: !"
    }
    
    cleanup {
      cleanWs()
    }
  }
}
