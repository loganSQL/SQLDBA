---If you want to gather information about the current health of your Availability Group directly through DMVs instead of opening the Dashboard, you can run the following script to derive roughly the same information:

-- 1. Cluster
select cluster_name, quorum_state_desc
from sys.dm_hadr_cluster
GO
-- 2. Replicas
select 
ar.replica_server_name,
ars.role_desc,
ar.failover_mode_desc,
ars.synchronization_health_desc,
ars.operational_state_desc,
CASE ars.connected_state
WHEN 0 THEN 'Disconnected'
WHEN 1 THEN 'Connected'
ELSE ''
END as ConnectionState
from sys.dm_hadr_availability_replica_states ars
inner join sys.availability_replicas ar on ars.replica_id = ar.replica_id
and ars.group_id = ar.group_id
GO

-- 3. databases
select distinct rcs.database_name,
ar.replica_server_name,
drs.synchronization_state_desc,
drs.synchronization_health_desc,
CASE rcs.is_failover_ready
WHEN 0 THEN 'Data Loss'
WHEN 1 THEN 'No Data Loss'
ELSE ''
END as FailoverReady
from sys.dm_hadr_database_replica_states drs
inner join sys.availability_replicas ar on drs.replica_id = ar.replica_id
and drs.group_id = ar.group_id
inner join sys.dm_hadr_database_replica_cluster_states rcs on drs.replica_id = rcs.replica_id
order by replica_server_name


/*
Dynamic Management Views –

The second method you can use to observe the current state of your AlwaysOn Availability Groups is through querying dynamic management views (DMVs).  SQL provides several DMVs to monitor the state of your AlwaysOn Availability Group that will give you information about your AG cluster, networks, replicas, databases, and listeners.

sys.dm_hadr_cluster

sys.dm_hadr_cluster_members

sys.dm_hadr_cluster_networks

sys.availability_groups

sys.availability_groups_cluster

sys.dm_hadr_availability_group_states

sys.availability_replicas

sys.dm_hadr_availability_replica_cluster_nodes

sys.dm_hadr_availability_replica_cluster_states

sys.dm_hadr_availability_replica_states

sys.dm_hadr_auto_page_repair

sys.dm_hadr_database_replica_states

sys.dm_hadr_database_replica_cluster_states

sys.availability_group_listener_ip_addresses

sys.availability_group_listeners

sys.dm_tcp_listener_states

These DMVs are all explained here https://msdn.microsoft.com/en-us/library/ff878305%28SQL.110%29.aspx . You can query any of these DMVs to gather information about your AG such as configuration, health status, and the condition of your Availability Group.  Another great link for further explanation of these DMVs is here https://msdn.microsoft.com/en-us/library/ff877943.aspx?f=255&MSPPError=-2147217396 .

Just an FYI…AlwaysOn AG catalog views require View Any Definition permission on the server instance. AlwaysOn Availability Groups dynamic management views require View Server State permission on the server.
*/