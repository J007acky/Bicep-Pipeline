pipeline {
    agent any
    stages {
        stage('Login to Azure') {
            steps {
                script {
                    withCredentials([azureServicePrincipal(credentialsId:'AZ_CLI', subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID', clientIdVariable: 'AZURE_CLIENT_ID', clientSecretVariable: 'AZURE_CLIENT_SECRET', tenantIdVariable: 'AZURE_TENANT_ID')]) {
                        sh '''
                            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                        '''
                    }
                }
            }
        }
        // stage('Genereate ssh key') {
        //     steps {
        //         script {
        //             sh '''
        //                 ssh-keygen -t rsa -b 4096 -f "$WORKSPACE/testBicepKey" -N 'yoyo'
        //             '''
        //         }
        //     }
        // }
        stage('Deploy Resource Groups') {
            steps {
                script {
                    sh '''
                        az deployment sub create --location CentralUS --parameters 'resource-group.bicepparam' --name bicep-rg-deployment
                    '''
                }
            }
        }
        stage('Deploy Virtual Machine') {
            steps {
                script {
                    def config = readYaml file: 'variables.yml'
                    withCredentials([string(credentialsId: 'SSH_KEY_NODE', variable: 'SSH_KEY')]) {
                        sh """
                        az deployment group create \
                        --resource-group '${config.rgName}-vm' \
                        --parameters test-vm.bicepparam \
                        --parameters vmUsername=Rahul \
                        vmPassword='Rahul@123' \
                        sshKeyVM='${SSH_KEY}'

                    """
                    }
                }
            }
        }
        stage('Deploy Managed Identity') {
            steps {
                script {
                    def config = readYaml file: 'variables.yml'
                    sh """
                        az deployment group create --resource-group '${config.rgName}-identity' \
                        --template-file managed-identity.bicep \
                        --name identity-deployment
                    """
                }
            }
        }

        stage('Deploy Bicep Files') {
            steps {
                script {
                    def config = readYaml file: 'variables.yml'
                    withCredentials([string(credentialsId: 'SSH_KEY_NODE', variable: 'SSH_KEY')]) {
                        sh """
                        az deployment group create\
                         --resource-group '${config.rgName}-aks' \
                         --parameters 'aks-cluster.bicepparam'\
                         --parameters sshRSAPublicKey='${SSH_KEY}' \
                         rgNamePrefix='${config.rgName}'
                    """
                    }
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
