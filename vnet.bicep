// params common
@minLength(3)
@description('Base name of the resource such as web app name and app service plan.')
param webAppName string

@allowed([
  'qa'
  'prod'
])
@description('Environment (QA/PROD) for the web app and app service plan.')
param env string

// params specific

// vars
var vnetName = 'vnet-${webAppName}-${env}-westeu-001'
var vnetAddressPrefix = '10.1.0.0/16'
var subnet1Name = 'AppSvcSubnet'
var subnet1Prefix = '10.1.2.0/24'

var subnet2Name = 'PrivateLinkSubnet'
var subnet2Prefix = '10.1.1.0/24'
var location = resourceGroup().location

// resources
resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${vnet.name}/${subnet1Name}'
  properties: {
    addressPrefix: subnet1Prefix
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: '${vnet.name}/${subnet2Name}'
  properties: {
    addressPrefix: subnet2Prefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

// outputs
output vNetId string = vnet.id
output appSvcSubnetId string = subnet1.id
output privateLinkSubnetId string = subnet2.id
