
# https://docs.microsoft.com/en-us/azure/virtual-network/service-tags-overview
# Azure Public :         https://www.microsoft.com/download/details.aspx?id=56519 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519
# Azure US Government :  https://www.microsoft.com/download/details.aspx?id=57063 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57063
# Azure China :          https://www.microsoft.com/download/details.aspx?id=57062 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57062
# Azure Germany :        https://www.microsoft.com/download/details.aspx?id=57064 - https://www.microsoft.com/en-us/download/confirmation.aspx?id=57064



# public
(Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519').links | ? href -Like *.json | select href -uni
(Invoke-WebRequest -Uri 'https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_20211011.json').rawcontent

<# 
The IP address ranges in these files are in CIDR notation.

The following AzureCloud tags do not have regional names formatted according to the normal schema:

AzureCloud.centralfrance (FranceCentral)
AzureCloud.southfrance (FranceSouth)
AzureCloud.germanywc (GermanyWestCentral)
AzureCloud.germanyn (GermanyNorth)
AzureCloud.norwaye (NorwayEast)
AzureCloud.norwayw (NorwayWest)
AzureCloud.switzerlandn (SwitzerlandNorth)
AzureCloud.switzerlandw (SwitzerlandWest)
AzureCloud.usstagee (EastUSSTG)
AzureCloud.usstagec (SouthCentralUSSTG) 
#>