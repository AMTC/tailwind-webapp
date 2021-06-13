param VotingApi_name string = 'votingapi-${uniqueString(resourceGroup().id)}'
param VotingWeb_name string = 'votingweb-${uniqueString(resourceGroup().id)}'
param Votingrediscache_name string = 'votingcache-${uniqueString(resourceGroup().id)}'
param VotingApiPlan_name string = 'votingapiplan-${uniqueString(resourceGroup().id)}'
param VotingWebPlan_name string = 'votingwebplan-${uniqueString(resourceGroup().id)}'
param FunctionVoteCounter_name string = 'functionvotecounter-${uniqueString(resourceGroup().id)}'
param servicebusvotingns_name string = 'votingsb-${uniqueString(resourceGroup().id)}'
param FunctionVoteCounterPlan_name string = 'functionvotercounterplan-${uniqueString(resourceGroup().id)}'
param databaseAccounts_votingcosmos_name string = 'votingcosmos-${uniqueString(resourceGroup().id)}'
param FunctionstorageAccount string = toLower('function${uniqueString(resourceGroup().id)}')
param ResourcestorageAccount string = toLower('rsr${uniqueString(resourceGroup().id)}')
param frontdoors_VotingFrontDoor_name string = 'VotingFrontDoor-${uniqueString(resourceGroup().id)}'

@secure()
param SqlConnectionString string = 'SQL_CONNECTION_STRING'

var location = resourceGroup().location

resource Votingrediscache_name_resource 'Microsoft.Cache/Redis@2017-10-01' = {
  name: Votingrediscache_name
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 3
    }
    enableNonSslPort: false
    redisConfiguration: {
      maxclients: '5000'
    }
  }
}

resource databaseAccounts_votingcosmos_name_resource 'Microsoft.DocumentDB/databaseAccounts@2015-04-08' = {
  name: databaseAccounts_votingcosmos_name
  location: location
  tags: {
    defaultExperience: 'Core (SQL)'
  }
  kind: 'GlobalDocumentDB'
  properties: {
    ipRangeFilter: ''
    enableAutomaticFailover: false
    enableMultipleWriteLocations: true
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    capabilities: []
  }
}

resource FunctionVoteCounter_name_resource 'microsoft.insights/components@2015-05-01' = {
  name: FunctionVoteCounter_name
  location: location
  tags: {
    applicationType: 'web'
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${FunctionVoteCounter_name}': 'Resource'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource VotingApi_name_resource 'microsoft.insights/components@2015-05-01' = {
  name: VotingApi_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource VotingWeb_name_resource 'microsoft.insights/components@2015-05-01' = {
  name: VotingWeb_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource servicebusvotingns_name_resource 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: servicebusvotingns_name
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    metricId: '${subscription().tenantId}:${servicebusvotingns_name}'
    serviceBusEndpoint: 'https://${servicebusvotingns_name}.servicebus.windows.net:443/'
    status: 'Active'
  }
}

resource ResourcestorageAccount_resource 'Microsoft.Storage/storageAccounts@2018-07-01' = {
  name: ResourcestorageAccount
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource FunctionstorageAccount_resource 'Microsoft.Storage/storageAccounts@2018-07-01' = {
  name: FunctionstorageAccount
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource FunctionVoteCounterPlan_name_resource 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: FunctionVoteCounterPlan_name
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    name: FunctionVoteCounterPlan_name
    perSiteScaling: false
    reserved: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource VotingApiPlan_name_resource 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: VotingApiPlan_name
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    name: VotingApiPlan_name
    perSiteScaling: false
    reserved: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource VotingWebPlan_name_resource 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: VotingWebPlan_name
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    name: VotingWebPlan_name
    perSiteScaling: false
    reserved: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource servicebusvotingns_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  parent: servicebusvotingns_name_resource
  name: 'RootManageSharedAccessKey'
  location: location
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource servicebusvotingns_name_queue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: servicebusvotingns_name_resource
  name: 'queue'
  location: location
  properties: {
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource servicebusvotingns_name_votingqueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: servicebusvotingns_name_resource
  name: 'votingqueue'
  location: location
  properties: {
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource Microsoft_Web_sites_FunctionVoteCounter_name 'Microsoft.Web/sites@2016-08-01' = {
  name: FunctionVoteCounter_name
  location: location
  tags: {
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${FunctionVoteCounterPlan_name}': 'empty'
  }
  kind: 'functionapp'
  identity: {
    principalId: null
    tenantId: null
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${FunctionVoteCounter_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${FunctionVoteCounter_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: FunctionVoteCounterPlan_name_resource.id
    reserved: false
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v4.7'
      phpVersion: '5.6'
      pythonVersion: ''
      nodeVersion: ''
      linuxFxVersion: ''
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: false
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: false
      publishingUsername: '$VotingWeb'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(FunctionVoteCounter_name_resource.id, '2014-04-01').InstrumentationKey
        }
        {
          name: 'SERVICEBUS_CONNECTION_STRING'
          value: listKeys(resourceId('Microsoft.ServiceBus/namespaces/AuthorizationRules', servicebusvotingns_name, 'RootManageSharedAccessKey'), '2015-08-01').primaryConnectionString
        }
        {
          name: 'sqldb_connection'
          value: SqlConnectionString
        }
      ]
    }
  }
  dependsOn: [
    servicebusvotingns_name_resource
    Votingrediscache_name_resource
  ]
}

resource Microsoft_Web_sites_VotingApi_name 'Microsoft.Web/sites@2016-08-01' = {
  name: VotingApi_name
  location: location
  tags: {
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${VotingApiPlan_name}': 'empty'
  }
  kind: 'app'
  identity: {
    principalId: null
    tenantId: null
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${VotingApi_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${VotingApi_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: VotingApiPlan_name_resource.id
    reserved: false
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v4.7'
      phpVersion: '5.6'
      pythonVersion: ''
      nodeVersion: ''
      linuxFxVersion: ''
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: false
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: false
      publishingUsername: '$VotingWeb'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(VotingApi_name_resource.id, '2014-04-01').InstrumentationKey
        }
        {
          name: 'ApplicationInsights:InstrumentationKey'
          value: reference(VotingApi_name_resource.id, '2014-04-01').InstrumentationKey
        }
        {
          name: 'ConnectionStrings:SqlDbConnection'
          value: SqlConnectionString
        }
      ]
    }
  }
  dependsOn: [
    servicebusvotingns_name_resource
    Votingrediscache_name_resource
  ]
}

resource Microsoft_Web_sites_VotingWeb_name 'Microsoft.Web/sites@2016-08-01' = {
  name: VotingWeb_name
  location: location
  tags: {
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${VotingWebPlan_name}': 'empty'
  }
  kind: 'app'
  identity: {
    principalId: null
    tenantId: null
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${VotingWeb_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${VotingWeb_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: VotingWebPlan_name_resource.id
    reserved: false
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v4.7'
      phpVersion: '5.6'
      pythonVersion: ''
      nodeVersion: ''
      linuxFxVersion: ''
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: false
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: false
      publishingUsername: '$VotingWeb'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(VotingWeb_name_resource.id, '2014-04-01').InstrumentationKey
        }
        {
          name: 'ConnectionStrings:sbConnectionString'
          value: listKeys(resourceId('Microsoft.ServiceBus/namespaces/AuthorizationRules', servicebusvotingns_name, 'RootManageSharedAccessKey'), '2015-08-01').primaryConnectionString
        }
        {
          name: 'ConnectionStrings:VotingDataAPIBaseUri'
          value: 'https://${VotingApi_name}.azurewebsites.net'
        }
        {
          name: 'ApplicationInsights:InstrumentationKey'
          value: reference(VotingWeb_name_resource.id, '2014-04-01').InstrumentationKey
        }
        {
          name: 'ConnectionStrings:RedisConnectionString'
          value: '${Votingrediscache_name}.redis.cache.windows.net:6380,abortConnect=false,ssl=true,password=${listKeys(Votingrediscache_name_resource.id, '2015-08-01').primaryKey}'
        }
        {
          name: 'ConnectionStrings:queueName'
          value: 'votingqueue'
        }
        {
          name: 'ConnectionStrings:CosmosUri'
          value: 'https://${databaseAccounts_votingcosmos_name}.documents.azure.com:443/'
        }
        {
          name: 'ConnectionStrings:CosmosKey'
          value: listKeys(resourceId('Microsoft.DocumentDB/databaseAccounts', databaseAccounts_votingcosmos_name), '2015-04-08').primaryMasterKey
        }
      ]
    }
  }
  dependsOn: [
    servicebusvotingns_name_resource
  ]
}

resource frontdoors_VotingFrontDoor_name_resource 'Microsoft.Network/frontdoors@2018-08-01' = {
  name: frontdoors_VotingFrontDoor_name
  location: 'Global'
  properties: {
    resourceState: 'Enabled'
    backendPools: [
      {
        id: '${frontdoors_VotingFrontDoor_name_resource.id}/BackendPools/${frontdoors_VotingFrontDoor_name}BackendPool'
        name: '${frontdoors_VotingFrontDoor_name}BackendPool'
        properties: {
          backends: [
            {
              address: '${VotingWeb_name}.azurewebsites.net'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
              backendHostHeader: '${VotingWeb_name}.azurewebsites.net'
              enabledState: 'Enabled'
            }
          ]
          healthProbeSettings: {
            id: '${frontdoors_VotingFrontDoor_name_resource.id}/healthProbeSettings/healthProbeSettings-1569015585276'
          }
          loadBalancingSettings: {
            id: '${frontdoors_VotingFrontDoor_name_resource.id}/loadBalancingSettings/loadBalancingSettings-1569015585276'
          }
          resourceState: 'Enabled'
        }
      }
    ]
    healthProbeSettings: [
      {
        id: '${frontdoors_VotingFrontDoor_name_resource.id}/HealthProbeSettings/healthProbeSettings-1569015585276'
        name: 'healthProbeSettings-1569015585276'
        properties: {
          intervalInSeconds: 30
          path: '/'
          protocol: 'Https'
          resourceState: 'Enabled'
        }
      }
    ]
    frontendEndpoints: [
      {
        id: '${frontdoors_VotingFrontDoor_name_resource.id}/FrontendEndpoints/${frontdoors_VotingFrontDoor_name}-azurefd-net'
        name: '${frontdoors_VotingFrontDoor_name}-azurefd-net'
        properties: {
          hostName: '${frontdoors_VotingFrontDoor_name}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
          resourceState: 'Enabled'
        }
      }
    ]
    loadBalancingSettings: [
      {
        id: '${frontdoors_VotingFrontDoor_name_resource.id}/LoadBalancingSettings/loadBalancingSettings-1569015585276'
        name: 'loadBalancingSettings-1569015585276'
        properties: {
          additionalLatencyMilliseconds: 0
          sampleSize: 4
          successfulSamplesRequired: 2
          resourceState: 'Enabled'
        }
      }
    ]
    routingRules: [
      {
        id: '${frontdoors_VotingFrontDoor_name_resource.id}/RoutingRules/Default'
        name: 'Default'
        properties: {
          frontendEndpoints: [
            {
              id: '${frontdoors_VotingFrontDoor_name_resource.id}/frontendEndpoints/${frontdoors_VotingFrontDoor_name}-azurefd-net'
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          forwardingProtocol: 'HttpsOnly'
          backendPool: {
            id: '${frontdoors_VotingFrontDoor_name_resource.id}/backendPools/${frontdoors_VotingFrontDoor_name}BackendPool'
          }
          enabledState: 'Enabled'
          resourceState: 'Enabled'
        }
      }
    ]
    enabledState: 'Enabled'
    friendlyName: frontdoors_VotingFrontDoor_name
  }
}