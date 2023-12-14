param location string = resourceGroup().location
param dnsZoneName string
param linkVnetId string
param name string
param subnetId string
param privateLinkServiceId string
param privateLinkServiceGroupIds array
param isPrivateNetworkEnabled bool
param privateIPAddress array
param memberNames array = []

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (isPrivateNetworkEnabled) {
  name: 'privatelink.${dnsZoneName}'
  location: 'global'
}

resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (isPrivateNetworkEnabled) {
  name: 'vnet-link-${name}'
  location: 'global'
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: linkVnetId
    }
  }
}

// https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/private-link/private-endpoint-overview.md
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-02-01' = if (isPrivateNetworkEnabled) {
  name: '${name}-endpoint'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: '${name}-nic'
    ipConfigurations: [for (pip, i) in privateIPAddress : {
      name: '${name}-ipconfig${i+1}'
      properties: {
        privateIPAddress: pip
        groupId: privateLinkServiceGroupIds[0]
        memberName: memberNames != [] ? memberNames[i] : privateLinkServiceGroupIds[0]
      }
    }]
    // [
    //   {
    //     name: name
    //     properties: {
    //       groupId: privateLinkServiceGroupIds[0]
    //       memberName: memberName != '' ? memberName : privateLinkServiceGroupIds[0]
    //       privateIPAddress: privateIPAddress
    //     }
    //   }
    // ]
    privateLinkServiceConnections: [
      {
        name: '${name}-connection}'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: privateLinkServiceGroupIds
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = if (isPrivateNetworkEnabled) {
  parent: privateEndpoint
  name: privateDnsZone.name
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'private-link-${name}'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output privateEndpointName string = privateEndpoint.name
