// params
@minLength(2)
@description('Base name of the resource such as web app name and app service plan.')
param webAppName string

@allowed([
  'qa'
  'prod'
])
@description('Environment (QA/PROD) for the web app and app service plan.')
param env string

@description('The SQL Server administrator login')
param administratorLogin string

@description('The SQL Server administrator login password.')
@secure()
param administratorLoginPassword string

@minLength(2)
@description('Object ID of the user with the default admin Access Policy')
param adminObjectId string

// vars
var vNetId = vnet.outputs.vNetId
var appSvcSubnetId = vnet.outputs.appSvcSubnetId
var privateLinkSubnetId = vnet.outputs.privateLinkSubnetId
var webAppObjectId = web.outputs.webAppObjectId
var sqlServerId = sql.outputs.sqlServerId

// modules
module vnet './vnet.bicep' = {
  name: 'vnet'
  params: {
    webAppName: webAppName
    env: env
  }
}

module web './webapp.bicep' = {
  name: 'web'
  params: {
    webAppName: webAppName
    env: env
    appSvcSubnetId: appSvcSubnetId
  }
}

module sql './sqlsingle.bicep' = {
  name: 'sql'
  params: {
    webAppName: webAppName
    env: env
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

module endpoint './endpoint.bicep' = {
  name: 'endpoint'
  params: {
    webAppName: webAppName
    env: env
    privateLinkSubnetId: privateLinkSubnetId
    vNetId: vNetId
    sqlServerId: sqlServerId
  }
}

module kevyault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    webAppName: webAppName
    env: env
    webAppObjectId: webAppObjectId
    adminObjectId: adminObjectId
  }
}
