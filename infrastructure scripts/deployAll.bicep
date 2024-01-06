param serverName string = 'adxanalytics-dbserver'
param databaseName string = 'aworks'
param location string = 'westeurope'
param adminLogin string = 'SqlAdmin'
param adminPassword string = 'ChangeYourAdminPassword1'
param dataFactoryName string = 'adxanalytics-adf'
param kustoClusterName string = 'adxanalyticskusto'
param kustoDatabaseName string = 'storeDB'
param kustoClusterUri string = 'https://${kustoClusterName}.westeurope.kusto.windows.net'
param kustoScriptName string = 'db-script'
param skuName string = 'Dev(No SLA)_Standard_D11_v2'
param skuCapacity int = 1
param eventHubNamespaceName string = 'adxanalytics-ehub-ns'
param eventHubImpressions string = 'impressions'
param eventHubClicks string = 'clicks'
param ehubConsumerGroup1 string = 'kustoConsumerGroup1'
param ehubConsumerGroup2 string = 'kustoConsumerGroup2'


resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: serverName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'Allow Azure Services'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: databaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    sampleName: 'AdventureWorksLT'
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    capacity: 1
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource eventHub1 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: eventHubImpressions
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource eventHub2 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: eventHubClicks
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}


resource kustoCluster 'Microsoft.Kusto/clusters@2022-02-01' = {
  name: kustoClusterName
  location: location
  sku: {
    name: skuName
    tier: 'basic'
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }

}

resource kustoDatabase 'Microsoft.Kusto/clusters/databases@2022-02-01' = {
  name: kustoDatabaseName
  parent: kustoCluster
  location: location
  kind: 'ReadWrite'
}

resource kustoScript 'Microsoft.Kusto/clusters/databases/scripts@2022-02-01' = {
  name: kustoScriptName
  parent: kustoDatabase
  properties: {
    scriptContent: loadTextContent('script.kql')
    continueOnErrors: false
  }
}

//  We need to authorize the kustoCluster to read the event hub by assigning the role
//  "Azure Event Hubs Data Receiver"
//  Role list:  https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var dataReceiverId = 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
var fullDataReceiverId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', dataReceiverId)

var eventHubRoleAssignmentNameImpressions = '${resourceGroup().id}${kustoClusterName}${dataReceiverId}${eventHubImpressions}'
var roleAssignmentNameImpressions = guid(eventHubRoleAssignmentNameImpressions, eventHubImpressions, dataReceiverId, kustoClusterName)

var eventHubRoleAssignmentNameClicks = '${resourceGroup().id}${kustoClusterName}${dataReceiverId}${eventHubClicks}'
var roleAssignmentNameClicks = guid(eventHubRoleAssignmentNameClicks, eventHubClicks, dataReceiverId, kustoClusterName)


resource clusterEventHubAuthorization1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentNameImpressions
  scope: eventHub1
  properties: {
    description: 'Give "Azure Event Hubs Data Receiver" to the kustoCluster'
    principalId: kustoCluster.identity.principalId
    //  Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    roleDefinitionId: fullDataReceiverId
  }
  dependsOn: [
    kustoCluster
    eventHub1
  ]
}

resource clusterEventHubAuthorization2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentNameClicks
  scope: eventHub2
  properties: {
    description: 'Give "Azure Event Hubs Data Receiver" to the kustoCluster'
    principalId: kustoCluster.identity.principalId
    //  Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    roleDefinitionId: fullDataReceiverId
  }
  dependsOn: [
    kustoCluster
    eventHub2
  ]
}
resource sqlServerLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'SqlServerLinkedService'
  parent: dataFactory
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'integrated security=False;data source=${serverName}.database.windows.net;initial catalog=${databaseName};user id=${adminLogin};Password=${adminPassword}'
    }
  }
  dependsOn: [
    sqlServer
    sqlDatabase
  ]
}

resource kustoClusterLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'KustoClusterLinkedService'
  parent: dataFactory
  properties: {
    type: 'AzureDataExplorer'
    typeProperties: {
      endpoint: kustoClusterUri
      database: kustoDatabaseName
    }
  }
  dependsOn: [
    kustoCluster
  ]
}


resource kustoConsumerGroup1 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  name: ehubConsumerGroup1
  parent: eventHub1
  properties: {}
}

resource kustoConsumerGroup2 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  name: ehubConsumerGroup2
  parent: eventHub2
  properties: {}
}

resource eventConnection 'Microsoft.Kusto/clusters/databases/dataConnections@2022-12-29' = {
  name: 'eventConnection'
  parent: kustoDatabase
  location: location
  dependsOn: [
    //  We need the table to be present in the database
    eventHub1
    kustoScript
  ]
  kind: 'EventHub'
  properties: {
    compression: 'None'
    consumerGroup: kustoConsumerGroup1.name
    dataFormat: 'JSON'
    eventHubResourceId: eventHub1.id
    eventSystemProperties: [
      'x-opt-enqueued-time'
    ]
    managedIdentityResourceId: kustoCluster.id
    mappingRuleName: 'impressions_jsonmapping'
    tableName: 'impressions'
  }
}

resource eventConnection2 'Microsoft.Kusto/clusters/databases/dataConnections@2022-12-29' = {
  name: 'eventConnection2'
  parent: kustoDatabase
  location: location
  dependsOn: [
    //  We need the table to be present in the database
    eventHub2
    kustoScript
  ]
  kind: 'EventHub'
  properties: {
    compression: 'None'
    consumerGroup: kustoConsumerGroup2.name
    dataFormat: 'JSON'
    eventHubResourceId: eventHub2.id
    eventSystemProperties: [
      'x-opt-enqueued-time'
    ]
    managedIdentityResourceId: kustoCluster.id
    mappingRuleName: 'clicks_jsonmapping'
    tableName: 'clicks'
  }
}

resource symbolicname 'Microsoft.Kusto/clusters/principalAssignments@2022-02-01' = {
  name: 'adf1'
  parent: kustoCluster
  dependsOn: [
    dataFactory
  ]
  properties: {
    principalId: dataFactory.identity.principalId
    principalType: 'App'
    role: 'AllDatabasesAdmin'
    tenantId: subscription().tenantId
  }
}