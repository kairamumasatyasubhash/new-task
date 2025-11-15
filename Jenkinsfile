pipeline {
  agent any

  environment {
    PROJECT_ID = "mitochondria-476610"
    REGION     = "us-central1"
    REPO       = "demo-task"
    IMAGE_NAME = "subhash-app"
    TAG        = "latest"
  }

  stages {
    stage('Checkout PHP Code') {
      steps {
        echo "Pulling code from GitHub..."
        git(url: 'https://github.com/kairamumasatyasubhash/new-task.git', branch: 'main')
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "Building Docker image for PHP..."
        sh '''
          set -e
          cd project/application
          docker build -t ${IMAGE_NAME}:${TAG} .
        '''
      }
    }

    stage('Tag Docker Image for GAR') {
      steps {
        echo "Tagging image for Artifact Registry..."
        sh '''
          set -e
          docker tag ${IMAGE_NAME}:${TAG} ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${TAG}
        '''
      }
    }

    stage('Auth & Push Image to GAR') {
      steps {
        echo "Activating service account and configuring Docker credential helper..."
        // Assumes you added the SA key to Jenkins Credentials as "Secret file" with id 'gcp-sa-key'
        withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'SA_KEY')]) {
          sh '''
            set -e
            # show which user runs this (for debugging)
            id

            # activate service account for the Jenkins process
            gcloud auth activate-service-account --key-file="$SA_KEY" --project=${PROJECT_ID}

            # sanity checks (won't show token, only existence)
            gcloud auth list
            gcloud config get-value project

            # ensure artifactregistry API is enabled
            gcloud services enable artifactregistry.googleapis.com --project=${PROJECT_ID} || true

            # configure docker credential helper for the registry (important)
            gcloud auth configure-docker ${REGION}-docker.pkg.dev -q

            # optional direct docker login fallback (uncomment to debug)
            # docker login -u oauth2accesstoken -p "$(gcloud auth print-access-token)" ${REGION}-docker.pkg.dev

            # finally push
            docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${TAG}
          '''
        }
      }
    }

    stage('Deploy Infrastructure using Terraform') {
      steps {
        echo "Deploying MIG + ALB using Terraform..."
        sh '''
          set -e
          cd project/terraform
          terraform init
          terraform apply -auto-approve
        '''
      }
    }
  }

  post {
    success { echo "CI/CD Pipeline Completed Successfully!" }
    failure { echo "Pipeline Failed! Check logs." }
  }
}
