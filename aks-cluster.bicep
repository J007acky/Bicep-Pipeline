@description('Resource Group name prefix')
param rgNamePrefix string

@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param aksLocation string

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(10)
param agentCount int

@description('The size of the Virtual Machine for agent nodes.')
param agentVMSize string

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string.')
param sshRSAPublicKey string

@description('The ID of the subnet within the VNet where the AKS cluster will be deployed.')
param vnetSubnetId string

@description('Id for the user assigned identity for the kubelet.')
param aksManagedIdentityId string

@description('Id for the user assigned identity for the kubelet.')
param kubeletManagedIdentityId string

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup('${rgNamePrefix}-identity')
  name: aksManagedIdentityId
}

resource kubeletManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup('${rgNamePrefix}-identity')
  name: kubeletManagedIdentityId
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: aksLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksManagedIdentity.id}':{}
    }
  }
  properties: {
    identityProfile:{
      kubeletidentity:{
        clientId: kubeletManagedIdentity.properties.clientId
        objectId: kubeletManagedIdentity.properties.principalId
        resourceId: kubeletManagedIdentity.id
      }
    }
    agentPoolProfiles: [
      {
        name: 'deadpool'
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
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
      serviceCidr: '30.1.0.0/18'
      dnsServiceIP: '30.1.2.10'
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
    // ingressProfile: {
    //   webAppRouting: {enabled: true}}
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
