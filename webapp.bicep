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
@description('The Runtime stack of current web app.')
param linuxFxVersion string = 'DOTNETCORE|5.0'

param appSvcSubnetId string

// vars
var location = resourceGroup().location
var appServiceName = 'app-${webAppName}-${env}-westeu-001'
var appServicePlanName = 'plan-${webAppName}-${env}-westeu-001'

// resources
resource appPlan 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
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
  name: appServiceName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appsettings 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${site.name}/appsettings'
  properties: {
    WEBSITE_VNET_ROUTE_ALL: '1'
    WEBSITE_DNS_SERVER: '168.63.129.16'
  }
}

resource sitevnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  name: '${site.name}/virtualNetwork'
  properties: {
    subnetResourceId: appSvcSubnetId
  }
}

// outputs
output webAppObjectId string = site.identity.principalId
