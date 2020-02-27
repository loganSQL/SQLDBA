# 1. import the “FailoverCluster” module
Get-Module -ListAvailable

Import-Module FailoverClusters

Get-Command –Module FailoverClusters 
# or
Get-Command | findstr Cluster

# 2. Basic Information
Get-Cluster
Get-ClusterNode
Get-ClusterQuorum
Get-ClusterGroup
Get-ClusterResource
Get-ClusterNetwork
Get-ClusterNetworkInterface
Get-ClusterAccess
Get-ClusterResourceType

## 3. Detail
## (1) One cluster has many nodes
## (2) One cluster (one node at a time) support many cluster groups 
## (3) One cluster groups has many cluster resources
## (4) One Resource has many properties and parameters
get-clustergroup -Name 'Cluster Group'|Get-ClusterResource
get-clustergroup -Name 'DBA'|Get-ClusterResource
Get-ClusterResource -Name "DBA" | Format-List -Property *
Get-ClusterResource -Name "DBA" | Get-ClusterParameter
Get-ClusterResource "Cluster IP Address" | Get-ClusterParameter

# 4. CLuster Group
# no good for ResourceType "SQL Server Availability Group"
Get-ClusterGroup
Start-ClusterGroup “Cluster Group”
Move-ClusterGroup “GROUPNAME” –Node “NODENAME”


# 5. test/validate my cluster
Test-Cluster –Node Node1,Node2

# 6. Logs
Set-Location C:\temp

## generate ClusterLog to current directory
Get-ClusterLog -Destination .

## view it
notepad.exe logansqltestsql01.logansql.net_cluster.log

## create log in the past 5 min
Get-ClusterLog -TimeSpan 5

## ********************************************************************
## Configuring IP Addresses and Dependencies for Multi-Subnet Clusters
## ********************************************************************
## https://techcommunity.microsoft.com/t5/Failover-Clustering/Configuring-IP-Addresses-and-Dependencies-for-Multi-Subnet/ba-p/371698
##
## find the correct name of the CCR (Cluster Core Resources)
Get-ClusterGroup
## 
## add a new IP Address which is a type of cluster resource.
# Add-ClusterResource –Name NewIP –ResourceType “IP Address” –Group “Cluster Group”
## The following IP will be shown as Other Resources
Add-ClusterResource -Name "Cluster IP Address XXX.XX.XX.XX"  -ResourceType "IP Address" -Group "Cluster Group"
## right click to specify subnet mask and static IP address, and Apply
##
## configure dependency of CLUSTER Server Name
## right click CCR, Server Name
##   add the above ip into IP Adresses of the cluster
##   Dependencies => OR 
## Apply

##
## Testing Failover
Move-ClusterGroup “Cluster Group” –node LoganSQLTest02

## ********************************************************************
## DNS Registration with the Network Name Resource
## ********************************************************************
## https://techcommunity.microsoft.com/t5/Failover-Clustering/DNS-Registration-with-the-Network-Name-Resource/ba-p/371482
##
