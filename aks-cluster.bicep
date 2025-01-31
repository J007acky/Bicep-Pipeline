@description('The name of the Managed Cluster resource.')
param clusterName string = 'JenkinsAKS'

@description('The location of the Managed Cluster resource.')
param aksLocation string

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(10) // Free tier supports up to 10 nodes
param agentCount int = 2

@description('The size of the Virtual Machine for agent nodes.')
param agentVMSize string = 'Standard_DS2_v2' // Adjust based on your requirements

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'rahul'

@description('Configure all linux machines with the SSH RSA public key string.')
param sshRSAPublicKey string

@description('The ID of the subnet within the VNet where the AKS cluster will be deployed.')
param vnetSubnetId string

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: aksLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/8c01f775-0496-43bc-a889-65565e670e05/resourceGroups/bicep-RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-managed-identity': {}
    }
  }
  properties: {
    identityProfile:{
      kubeletidentity:{
        clientId: '0d9b009c-8e25-472c-bd53-da54bd17fdc5'
        objectId: 'bd520115-087c-46c4-907b-b1471488b778'
        resourceId: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', 'kubelet-managed-identity')
      }
    }
    agentPoolProfiles: [
      {
        name: 'deadpool'
        count: agentCount
        vmSize: agentVMSize
        osType: 'Ubuntu'
        mode: 'System'
        vnetSubnetID: vnetSubnetId
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
      }
    ]
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      serviceCidr: '10.1.0.0/16'
      dnsServiceIP: '10.1.0.10'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true // Enable private cluster
    }
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    dnsPrefix: dnsPrefix
    ingressProfile: {
      webAppRouting: {enabled: true}}
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
