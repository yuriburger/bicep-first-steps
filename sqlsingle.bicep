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
@description('The SQL Server administrator login')
param administratorLogin string

@description('The SQL Server administrator login password.')
@secure()
param administratorLoginPassword string

// vars
var location = resourceGroup().location
var databaseCollation = 'SQL_Latin1_General_CP1_CI_AS'
var serverName = 'sql-${webAppName}-${env}-westeu-001'

// resources
resource sqlServer 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${sqlServer.name}/sqldb-${webAppName}-${env}-westeu-001'
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    collation: databaseCollation
  }
}

// outputs
output sqlServerId string = sqlServer.id
