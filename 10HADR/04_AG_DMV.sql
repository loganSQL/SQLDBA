/*
https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/always-on-availability-groups-dynamic-management-views-functions?redirectedfrom=MSDN&view=sql-server-2017
*/

-- Cluster info
select * from sys.dm_hadr_cluster
select * from sys.dm_hadr_cluster_members
select * from sys.dm_hadr_cluster_networks

-- mapping
select * from sys.dm_hadr_instance_node_map
select * from sys.dm_hadr_name_id_map

-- listener / port
select * from sys.dm_tcp_listener_states

-- Cluster / AG state
select * from sys.dm_hadr_availability_group_states

-- Replica cluster nodes / states
select * from sys.dm_hadr_availability_replica_cluster_nodes
select * from sys.dm_hadr_availability_replica_states

-- Database Replica cluster nodes / states
-- group_database_id, atabase_name
select * from sys.dm_hadr_database_replica_cluster_states
select * from sys.dm_hadr_database_replica_states

-- Databases: REPLICATED or NOT?
select  sd.name, 
(
case 
 when
  hdrs.is_primary_replica IS NULL then  'NOT REPLICATED'
 else
    'REPLICATED'
 end
) as  AGType
 from sys.databases as sd
 left outer join sys.dm_hadr_database_replica_states  as hdrs on hdrs.database_id = sd.database_id

 -- Replicated or NOT, with AG name

select sd.name, 
(
case 
 when
  hdrs.is_primary_replica IS NULL then  'NOT REPLICATED'
 else
    'REPLICATED'
 end
) as  AGType,
COALESCE(grp.ag_name,'N/A') as AGName
 from sys.databases as sd
 left outer join sys.dm_hadr_database_replica_states  as hdrs on hdrs.database_id = sd.database_id
 left outer join sys.dm_hadr_name_id_map as grp on grp.ag_id = hdrs.group_id

-- Get for a each database a row with:
-- name, AGType, AGName
-- DBName: name of the database
-- AGType: NOT REPLICATED/PRIMARY/SECONDARY
-- AGName: N/A if NOT REPLICATED, otherwise name of the AG Group the database is part of
 
select DISTINCT 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ServerHost,
@@SERVICENAME as SQLService, 
@@SERVERNAME as SQLInstance, 
sd.name as DBName, 
(
case 
 when
  hdrs.is_primary_replica IS NULL then  'NOT REPLICATED'
 when exists ( select * from sys.dm_hadr_database_replica_states as irs where sd.database_id = irs.database_id and is_primary_replica = 1 ) then
	'PRIMARY'
 else
    'SECONDARY'
 end
) as  AGType,
COALESCE(grp.ag_name,'N/A') as AGName
 from sys.databases as sd
 left outer join sys.dm_hadr_database_replica_states  as hdrs on hdrs.database_id = sd.database_id
 left outer join sys.dm_hadr_name_id_map as grp on grp.ag_id = hdrs.group_id
 where sd.database_id>4