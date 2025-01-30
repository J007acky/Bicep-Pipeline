targetScope = 'subscription'

@description('Resource group name')
param rgName string= 'bicep-ag-rg'

@description('Location for resource group.')
param rgLocation string= 'CentralUS'



resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: rgLocation 
}

