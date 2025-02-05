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
                    def config = readYaml file: 'config.yml'
                    sh """
                        az deployment sub create --location '${config.location}' --parameters 'resource-group.bicepparam' --name bicep-rg-deployment
                    """
                }
            }
        }
        stage('Deploy Virtual Machine') {
            steps {
                script {
                    def config = readYaml file: 'config.yml'
                    withCredentials([string(credentialsId: 'SSH_KEY_NODE', variable: 'SSH_KEY')]) {
                        sh """
                        az deployment group create \
                        --resource-group '${config.subscription}-${config.locationShared}-${config.environment}-vm-rg' \
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
                    def config = readYaml file: 'config.yml'
                    sh """
                        az deployment group create --resource-group '${config.subscription}-${config.location}-${config.environment}-identity-rg' \
                        --parameters managed-identity.bicepparam \
                        --name identity-deployment
                    """
                }
            }
        }

        stage('Deploy Bicep Files') {
            steps {
                script {
                    def config = readYaml file: 'config.yml'
                    withCredentials([string(credentialsId: 'SSH_KEY_NODE', variable: 'SSH_KEY')]) {
                        sh """
                        az deployment group create\
                         --resource-group '${config.subscription}-${config.location}-${config.environment}-aks-rg' \
                         --parameters 'aks-cluster.bicepparam'\
                         --parameters sshRSAPublicKey='${SSH_KEY}'
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
