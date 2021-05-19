@minLength(2)
@description('Base name of the resource such as web app name and app service plan.')
param webAppName string

@description('The Runtime stack of current web app.')
param linuxFxVersion string = 'DOTNET|5.0'

module webApp './webapp.bicep' = {
  name: 'webAp'
  params: {
    webAppName: webAppName
    linuxFxVersion: linuxFxVersion
  }
}
