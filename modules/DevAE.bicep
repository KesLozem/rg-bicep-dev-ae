param location string

//virtual network
param vnetName string
param vnetDDOSProtectionEnabled bool
param vnetSubnetName string = 'subnet-bicep-dev-ae'

//storage account
param storageAccountName string
var storageAccountSKU  = 'Standard_LRS'

//key vault
param keyVaultName string
var keyVaultSKU = 'standard'

//logs analytics workspace
param logAnalyticsName string
param logAnalyticsSKU string

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.150.0.0/16'
      ]
    }
    enableDdosProtection: vnetDDOSProtectionEnabled

    //subnet
    subnets: [
      {
        name: vnetSubnetName
        properties: {
          addressPrefix: '10.150.0.0/28'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
    ]
  }
}

resource vnetSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: vnetSubnetName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSKU
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false //MUST BE FALSE
    accessTier: 'Hot'
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          action: 'Allow'
          id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vnetSubnet.name)
        }
      ]
    }
  }
}


resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  location: location
  name: keyVaultName
  properties: {
    sku: {
      family: 'A'
      name: keyVaultSKU
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: subscription().tenantId
        tenantId: subscription().tenantId
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          storage: [
            'all'
          ]
          secrets: [
            'all'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Deny' // MUST BE DENY
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vnetSubnet.name)
        }
      ]
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSKU
    }
  }
}

output subnetID string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vnetSubnet.name)

