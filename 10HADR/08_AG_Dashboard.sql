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