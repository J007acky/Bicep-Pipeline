using 'aks-cluster.bicep'

param aksLocation = 'CentralUS'
param dnsPrefix = 'rahul-net'
param sshRSAPublicKey = 'SSH_KEY'
param vnetSubnetId = '/subscriptions/8c01f775-0496-43bc-a889-65565e670e05/resourceGroups/Implementation-Vnet/providers/Microsoft.Network/virtualNetworks/Spoke/subnets/default'
param clusterName = 'JenkinsAKS'
param agentCount = 2
param agentVMSize = 'Standard_DS2_v2'
param linuxAdminUsername = 'rahul'
param aksManagedIdentityId = 'aks-managed-identity'
param kubeletManagedIdentityId = 'kubelet-managed-identity'
