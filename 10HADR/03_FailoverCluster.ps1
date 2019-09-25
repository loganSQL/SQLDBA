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
