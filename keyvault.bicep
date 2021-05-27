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
@minLength(2)
@description('Object ID of the user with the default admin Access Policy')
param adminObjectId string

@minLength(2)
@description('Object ID of the web app Get Secret Access Policy')
param webAppObjectId string

// vars
var accessPolicies = [
  {
    tenantId: subscription().tenantId
    objectId: adminObjectId
    permissions: {
      keys: [
        'get'
        'list'
        'update'
        'create'
        'import'
        'delete'
        'recover'
        'backup'
        'restore'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
        'recover'
        'backup'
        'restore'
      ]
      certificates: [
        'get'
        'list'
        'update'
        'create'
        'import'
        'delete'
        'recover'
        'backup'
        'restore'
        'managecontacts'
        'manageissuers'
        'getissuers'
        'listissuers'
        'setissuers'
        'deleteissuers'
      ]
    }
  }
  {
    tenantId: subscription().tenantId
    objectId: webAppObjectId
    permissions: {
      keys: []
      secrets: [
        'get'
      ]
      certificates: []
    }
  }
]

var location = resourceGroup().location
var sku = 'standard'
var vaultName = 'kv-${webAppName}-${env}-westeu-001'

// resources
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    networkAcls: {
      ipRules: []
      virtualNetworkRules: []
    }
  }
}
