using 'aks-cluster.bicep'

var configFile = loadYamlContent('config.yml')

// Location where the AKS cluster will be created
param aksLocation = configFile.location

// Subnet ID where cluster Nodes will be deployed
// param vnetSubnetId = '/subscriptions/82103d68-e454-42a4-acbf-1b71e64bca29/resourceGroups/Azure-For-Students-westus-dev-resource-rg/providers/Microsoft.Network/virtualNetworks/Azure-For-Students-westus-dev-resource-vnet/subnets/Azure-For-Students-westus-dev-resource-vnet-private-subnet'

// Resource Group name prefix
param rgNamePrefix = '${configFile.subscription}-${configFile.location}-${configFile.environment}'

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

param serviceCidr = '30.1.0.0/18'

param dnsServiceIP = '30.1.2.10'
