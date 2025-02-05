targetScope = 'subscription'

@description('Resource group name')
param rgName string

@description('Location for resource group.')
param rgLocation string

@description('Resource group for VM')
param vmRGName string

@description('Location for VM resource group')
param sharedLocation string

resource resourceGroupAKS 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgName}-aks-rg'
  location: rgLocation 
}

resource resourceGroupVM 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${vmRGName}-vm-rg'
  location: sharedLocation
}

resource resourceGroupIdentity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${rgName}-identity-rg'
  location: rgLocation
}

output aksRG string = resourceGroupAKS.name
output vmRG string = resourceGroupVM.name
output identityRG string = resourceGroupIdentity.name
