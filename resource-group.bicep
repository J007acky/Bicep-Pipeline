targetScope = 'subscription'

@description('Resource group name')
param rgName string

@description('Location for resource group.')
param rgLocation string

resource resourceGroupAKS 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgName}-aks'
  location: rgLocation 
}

resource resourceGroupVM 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgName}-vm'
  location: rgLocation
}

resource resourceGroupIdentity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgName}-identity'
  location: rgLocation
}

output aksRG string = resourceGroupAKS.name
output vmRG string = resourceGroupVM.name
output identityRG string = resourceGroupIdentity.name
