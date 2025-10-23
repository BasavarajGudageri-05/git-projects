pipeline{
    agent any
    environment{
        DOCKER_IMAGE='akashjyothi/django-ecommerce-app'
    }
    stages{
        stage('git-checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/Jyothijagadish/Django-class-final-notes-and-source-code.git'
                 }

           }
        stage('docker-build'){
            steps{
                sh 'docker build -t $DOCKER_IMAGE:1 -f ecommerce/Dockerfile .'
            }
        }
        stage('docker-push'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'Docker', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin'
                        sh 'docker push $DOCKER_IMAGE:1'
       }
    }
       
  }
}
       stage('deploy-to-kubernetes'){
            steps{
               withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubernetes', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
     sh '''
                    echo 'applying deployment file'
                    kubectl apply -f ecommerce/deployment.yml
                    echo 'applying service file'
                    kubectl apply -f ecommerce/svc.yml
                    '''
}
                }
            }
        }
}