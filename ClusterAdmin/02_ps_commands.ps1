
# 1. import the “FailoverCluster” module
Get-Module -ListAvailable

Import-Module FailoverClusters

Get-Command –Module FailoverClusters 
# or
Get-Command | findstr Cluster

# 2. CLuster Group
Get-ClusterGroup

Start-ClusterGroup “Cluster Group”

Move-ClusterGroup “GROUPNAME” –Node “NODENAME”

# 3. Cluster Resource
Get-ClusterResource

# 4. get a list of all clustered groups from an node
Get-ClusterNode –Name “NODENAME” | Get-ClusterGroup

# 5. get a list of all clustered resources within a cluster group
Get-ClusterGroup "GROUPNAME" | Get-ClusterResource

# 6. get more parameters from a clustered disk (resource)
Get-ClusterResource "Cluster IP Address" | Get-ClusterParameter

# 7. test/validate my cluster
Test-Cluster –Node Node1,Node2