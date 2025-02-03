@description('Name of the Virtual Machine')
param vmName string = 'testing-VM'

@description('Location of the Virtual Machine')
param vmLocation string = 'CentralUS'

@description('Name for the NIC')
param nicName string = '${vmName}-NIC'

@description('Name for the NSG')
param nsgName string = '${nicName}-NSG'

@description('Name for the public IP')
param ipName string = '${vmName}-IP'


@description('Subnet ID for the Virtual Machine')
param subnetId string = '/subscriptions/8c01f775-0496-43bc-a889-65565e670e05/resourceGroups/Implementation-Vnet/providers/Microsoft.Network/virtualNetworks/Spoke/subnets/default'

@description('Username for accessing VM')
@secure()
param vmUsername string

@description('Password for accessing VM')
@secure()
param vmPassword string


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: vmLocation
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          description: 'Allow SSH connection'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}


resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: ipName
  location: vmLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: '${nicName}-ipconfig'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}



resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: vmLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: '${vmName}-OS'
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'None'
        createOption: 'FromImage'
        osType: 'Linux'
        diskSizeGB: 30
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }

      ]
    }
  }
}
