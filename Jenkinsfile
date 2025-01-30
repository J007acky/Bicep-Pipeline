pipeline {
    agent any

    environment {
        
    }

    stages {
        stage('Login to Azure') {
            steps {
                script {
                    withCredentials([azureServicePrincipal(credentialsId:'AZURE_CRED',subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',clientIdVariable: 'AZURE_CLIENT_ID',clientSecretVariable: 'AZURE_CLIENT_SECRET',tenantIdVariable: 'AZURE_TENANT_ID')]) {
                        sh '''
                            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                        '''
                    }
                }
            }
        }

        stage('Deploy Bicep Files') {
            steps {
                script {
                    sh '''
                        az deployment group create --resource-group <your-resource-group> --template-file <path-to-your-bicep-file>
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'az logout'
            }
        }
    }
}