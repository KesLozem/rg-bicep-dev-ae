//az deployment sub create -f main.bicep --location 'australiasoutheast'
targetScope = 'subscription'

//params
param rgBicepDevAEName string = 'rg-bicep-dev-ae-lkosem'
param location string = 'australiasoutheast'

param vnetName string = 'vnet-bicep-dev-ae'
param vnetSubnetName string = 'subnet-bicep-dev-ae'
param vnetDDOSProtectionEnabled bool = false

param storageAccountName string = 'stbicepdevae'

param keyVaultName string = 'kv-bicep-dev-ae'

param logAnalyticsName string = 'log-bicep-dev-ae'
param logAnalyticsSKU string = 'PerGB2018'


//resource group
resource rgbicepdevae 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgBicepDevAEName
  location: location
}

module DevAE 'modules/DevAE.bicep' = {
  scope: rgbicepdevae
  name: 'DevAE'
  params: {
    location: location
    
    //virtual network params
    vnetName: vnetName
    vnetDDOSProtectionEnabled: vnetDDOSProtectionEnabled
    vnetSubnetName: vnetSubnetName

    //storage account params
    storageAccountName: storageAccountName

    //key vault
    keyVaultName: keyVaultName

    //log analytics workspace
    logAnalyticsName: logAnalyticsName
    logAnalyticsSKU: logAnalyticsSKU

  }
}


output subnetId string = DevAE.outputs.subnetID

