pipeline {
    agent any
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
        stage('Genereate ssh key') {
            steps {
                script {
                    sh '''
                        ssh-keygen -t rsa -b 4096 -f "$WORKSPACE/testBicepKey" -N 'yoyo'
                    '''
                }
            }
        }

        stage('Deploy Bicep Files') {
            steps {
                script {
                    def config = readYaml file: 'variables.yml'
                    sh '''
                        az deployment group create --resource-group "${config.rgName}" --template-file aks-cluster.bicep --parameters vnetSubnetId="${config.subnetId}" dnsPrefix="${config.dnsPrefix}" linuxAdminUsername="${config.usrName}" sshRSAPublicKey="$(cat testBicepKey.pub)" aksLocation="${config.location}"
                    '''
                }
            }
        }
        stage('cleanup') {
            steps {
                cleanWs()
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
