using 'resource-group.bicep'

var configFile = loadYamlContent('config.yml')

// Prefix for the resource group names
param rgName = '${configFile.subscription}-${configFile.location}-${configFile.environment}'

// Location for the resource group
param rgLocation = configFile.location

param vmRGName = '${configFile.subscription}-${configFile.locationShared}-${configFile.environment}'

param sharedLocation = configFile.locationShared
