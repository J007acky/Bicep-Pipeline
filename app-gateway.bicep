@description('The location of the Managed Cluster resource.')
param gatewayLocation string = resourceGroup().location

@description('The SKU name for the Application Gateway.')
param skuName string = 'Standard_v2'

@description('This is the Resource Group where the Vnet is created')
param vNetRG string = 'Implementation-Vnet'

@description('This is the name of the Vnet where the App Gateway is created')
param vNetName string = 'Spoke'

@description('This is the name of the Subnet where the App Gateway is created')
param subnetName string = 'default'

@description('This is the IP Address of the Ingress Controller')
param ingressControllerIP string = '10.0.0.65'

@description('Name of the Application Gateway')
param appGatewayName string = 'bicep-app-gateway'

@description('This is the IP Address of the Ingress Controller')
param publicIPName string = '${appGatewayName}-public-ip'

@description('Frontend Port to expose on the Application Gateway')
param portNo int = 80

@description('Backend Port of the Ingress Controller')
param portNoBack int = 80



resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIPName
  location: gatewayLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: appGatewayName
  location: resourceGroup().location
  properties: {
    sku: {
      name: skuName
      capacity: 1
      tier: skuName
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIPConfig'
        properties: {
          subnet: {
            id: resourceId(vNetRG, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfigurations'
        properties: {
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPName)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-${portNo}'
        properties: {
          port: portNo
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bicep-backend-pool'
        properties: {
          backendAddresses: [
            {
              ipAddress: ingressControllerIP
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettingsCollection'
        properties: {
          port: portNoBack
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener-port-${portNo}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGatewayName,
              'frontendIPConfigurations'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port-${portNo}')
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'bicep-routing-rules'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGatewayName,
              'listener-port-${portNo}'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGatewayName,
              'bicep-backend-pool'
            )
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGatewayName,
              'backendHttpSettingsCollection'
            )
          }
        }
      }
    ]
  }
}
