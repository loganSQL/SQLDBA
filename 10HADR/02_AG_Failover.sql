/*
1. Check Status
*/

WITH AGStatus AS(
SELECT
name as AGname,
replica_server_name,
CASE WHEN  (primary_replica  = replica_server_name) THEN  1
ELSE  '' END AS IsPrimaryServer,
secondary_role_allow_connections_desc AS ReadableSecondary,
[availability_mode]  AS [Synchronous],
failover_mode_desc
FROM master.sys.availability_groups Groups
INNER JOIN master.sys.availability_replicas Replicas ON Groups.group_id = Replicas.group_id
INNER JOIN master.sys.dm_hadr_availability_group_states States ON Groups.group_id = States.group_id
)
Select
[AGname],
[Replica_server_name],
[IsPrimaryServer],
[Synchronous],
[ReadableSecondary],
[Failover_mode_desc]
FROM AGStatus
--WHERE
--IsPrimaryServer = 1
--AND Synchronous = 1
ORDER BY
AGname ASC,
IsPrimaryServer DESC;

select g.name, s.database_name, r.replica_server_name, s.is_failover_ready, r.availability_mode,r.availability_mode_desc FROM sys.dm_hadr_database_replica_cluster_states s,sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id and s.replica_id = r.replica_id 

/*
2. Sync or Async: AVAILABILITY_MODE change
*/
-- generate script for all AG to SYNCHRONOUS_COMMIT
select 'ALTER AVAILABILITY GROUP ['+g.name+']
MODIFY REPLICA ON N'''+r.replica_server_name+''' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id


-- generate script for all AG to ASYNCHRONOUS_COMMIT
select 'ALTER AVAILABILITY GROUP ['+g.name+']
MODIFY REPLICA ON N'''+r.replica_server_name+''' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id

/*
3. Failover (On Secondary)
*/
---*****************************
--- SECONDARY
--******************************

/*
3.1. Normal planned failover
*/
-- generate failover script ON SECONDARY (planned)
--ALTER AVAILABILITY GROUP 'youragnamehere' FAILOVER
--GO

select distinct 'ALTER AVAILABILITY GROUP ['+g.name+'] FAILOVER'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id

/*
3.2. Unplanned force failover
*/
-- generate ALLOW DATA_LOSS at the worst case ON SECONDARY (unplanned)
--ALTER AVAILABILITY GROUP 'youragnamehere' FORCE_FAILOVER_ALLOW_DATA_LOSS
--GO

select distinct 'ALTER AVAILABILITY GROUP ['+g.name+'] FORCE_FAILOVER_ALLOW_DATA_LOSS'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id

/*
3.3. Resume from Suspended
*/
-- generate SET HADR RESUME on Secondary just in-case (unplanned)
--ALTER DATABASE 'yourdatabasenamehere' SET HADR RESUME
--GO
select distinct 'ALTER AVAILABILITY GROUP ['+g.name+'] SET HADR RESUME'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id

-- if the database still in restoring (Hard break)

/*
3.4. Last resort: just restore with recovery
*/
ALTER DATABASE 'yourdatabasenamehere' SET OFFLINE WITH ROLLBACK IMMEDIATE
ALTER DATABASE 'yourdatabasenamehere' SET ONLINE
RESTORE DATABASE 'yourdatabasenamehere' WITH RECOVERY

/*
4. Login Sync or enable login
*/
select 'drop login ['+name+']' from syslogins where loginname not like '##%' and loginname not like 'NT%' and loginname <>'logansql\mssqlsvc'  and loginname<>'sa'


-- Get-DbaAvailabilityGroup -SqlInstance FNSQL10\MLQSQL | Sync-DbaAvailabilityGroup -ExcludeType SpConfigure, CustomErrors, Credentials, DatabaseMail, LinkedServers, SystemTriggers, DatabaseOwner, AgentCategory, AgentOperator, AgentAlert, AgentProxy, AgentSchedule, AgentJob
-- Powershell
-- Sync-DbaAvailabilityGroup -Primary FNSQL10\MLQSQL -Secondary MIDPFNSQL10\MLQSQL -ExcludeType SpConfigure, CustomErrors, Credentials, DatabaseMail, LinkedServers, SystemTriggers, DatabaseOwner, AgentCategory, AgentOperator, AgentAlert, AgentProxy, AgentSchedule, AgentJob
