pipeline {
    agent any
    // stages {
    //     stage('Login to Azure') {
    //         steps {
    //             script {
    //                 withCredentials([azureServicePrincipal(credentialsId:'AZURE_CRED',subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',clientIdVariable: 'AZURE_CLIENT_ID',clientSecretVariable: 'AZURE_CLIENT_SECRET',tenantIdVariable: 'AZURE_TENANT_ID')]) {
    //                     sh '''
    //                         az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
    //                     '''
    //                 }
    //             }
    //         }
    //     }
    //     stage('Genereate ssh key') {
    //         steps {
    //             script {
    //                 sh '''
    //                     ssh-keygen -t rsa -b 4096 -f "$WORKSPACE/testBicepKey" -N 'yoyo'
    //                 '''
    //             }
    //         }
    //     }

    //     stage('Deploy Bicep Files') {
    //         steps {
    //             script {
    //                 sh '''
    //                     az deployment group create --resource-group Implementation-Vnet --template-file aks-cluster.bicep --parameters vnetSubnetId="/subscriptions/8c01f775-0496-43bc-a889-65565e670e05/resourceGroups/Implementation-Vnet/providers/Microsoft.Network/virtualNetworks/Spoke/subnets/default" dnsPrefix=rahul-net linuxAdminUsername=rahul sshRSAPublicKey="$(cat testBicepKey.pub)" aksLocation=CentralUS
    //                 '''
    //             }
    //         }
    //     }
    //     stage('cleanup') {
    //         steps {
    //             cleanWs()
    //         }
    //     }
    // }

    // post {
    //     always {
    //         script {
    //             sh 'az logout'
    //         }
    //     }
    // }
    stages {
        stage('test') {
            steps {
                def config = readYaml file: 'variables.yml'
                echo "Properties: ${config}"
            }
        }
    }
}