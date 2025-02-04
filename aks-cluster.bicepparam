using 'aks-cluster.bicep'

// Location where the AKS cluster will be created
param aksLocation = 'WestUS'

// Name of the Managed Cluster resource
param clusterName = 'JenkinsAKS'

// Subnet ID where cluster Nodes will be deployed
param vnetSubnetId = '/subscriptions/82103d68-e454-42a4-acbf-1b71e64bca29/resourceGroups/Azure-For-Students-westus-dev-resource-rg/providers/Microsoft.Network/virtualNetworks/Azure-For-Students-westus-dev-resource-vnet/subnets/Azure-For-Students-westus-dev-resource-vnet-private-subnet'

// Resource Group name prefix
param rgNamePrefix = 'bicep-rg'

// DNS prefix for the AKS cluster
param dnsPrefix = 'rahul-net'

// SSH RSA public key string
param sshRSAPublicKey = 'SSH_KEY'

// Number of nodes for the cluster
param agentCount = 2

// Size of the Virtual Machine for agent nodes
param agentVMSize = 'Standard_DS2_v2'

// User name for the Linux Virtual Machines
param linuxAdminUsername = 'Rahul'

// Name for the user assigned identity for the AKS cluster
param aksManagedIdentityId = 'aks-managed-identity'

// Name for the user assigned identity for the kubelet
param kubeletManagedIdentityId = 'kubelet-managed-identity'
