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
param privateLinkSubnetId string
param sqlServerId string
param vNetId string

// vars
var location = resourceGroup().location
var privateEndpointName = 'pe-${webAppName}-${env}-westeu-001'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var privateEndpointDnsGroupName = '${privateEndpointName}/dnsgroup'

// resources
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateLinkSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${privateDnsZone.name}/${privateDnsZoneName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNetId
    }
  }
}

resource dnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: privateEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
