@description('Resource Group name prefix')
param rgNamePrefix string


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

@description('IP address range for the Kubernetes service address range.')
param serviceCidr string

@description('IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns).')
param dnsServiceIP string

var clusterName = '${rgNamePrefix}-resource-aks'

var vnetSubnetId = resourceId('${rgNamePrefix}-resource-rg', 'Microsoft.Network/virtualNetworks/subnets', '${rgNamePrefix}-resource-vnet', '${rgNamePrefix}-resource-vnet-private-subnet')

var aksManagedIdentityId = '${rgNamePrefix}-identity-aks-managed-identity'

var kubeletManagedIdentityId = '${rgNamePrefix}-identity-kubelet-managed-identity'

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup('${rgNamePrefix}-identity-rg')
  name: aksManagedIdentityId
}

resource kubeletManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup('${rgNamePrefix}-identity-rg')
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
        name: '${clusterName}-agentpool'
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
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
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
