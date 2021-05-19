param location string = resourceGroup().location
param webAppName string
param linuxFxVersion string

var webAppPortalName = '${webAppName}-webapp'
var appServicePlanName = '${webAppName}-plan'

resource appPlan 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    name: appServicePlanName
    perSiteScaling: false
    reserved: true
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource site 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppPortalName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}
