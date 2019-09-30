/*
https://blogs.msdn.microsoft.com/alwaysonpro/2014/01/02/maintenance-plan-does-not-backup-database-or-log-of-database-defined-in-availability-group/
*/

/**********************************************
1. Check HADR_Backup_PreferredReplica Setting
**********************************************
When you create an availability group, the availability group's AUTOMATED_BACKUP_PREFERENCE is set. 
If not specifically configured, the default, through T-SQL or using the New Availability Group wizard, is 'SECONDARY.'

BY DEFAULT, HADR_Backup_Preferred_Replication is 0 for the primary, and it means the backup will be on the secondary
*/

--  master.dbo.fn_hadr_backup_is_preferred_replica(name)
select name,recovery_model, master.dbo.fn_hadr_backup_is_preferred_replica(name) HADR_Backup_PreferredReplica, is_encrypted, replica_id, group_database_id
from sys.databases

-- AG primary: what is automated_backup_preference_desc
select g.name,g.automated_backup_preference,g.automated_backup_preference_desc, r.replica_server_name, r.availability_mode_desc, r.endpoint_url, r.owner_sid
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id and replica_metadata_id is not null and owner_sid is not null-- primary

-- AG Secondary: what is automated_backup_preference_desc
select g.name,g.automated_backup_preference,g.automated_backup_preference_desc, r.replica_server_name, r.availability_mode_desc, r.endpoint_url, r.owner_sid
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id and replica_metadata_id is null and owner_sid is null -- secondary

/**********************************************
2. Change HADR_Backup_PreferredReplica Setting
**********************************************
generate the scripts to set backup on primary   
    SET( AUTOMATED_BACKUP_PREFERENCE = PRIMARY )
*/

select distinct 'ALTER AVAILABILITY GROUP ['+g.name+'] SET( AUTOMATED_BACKUP_PREFERENCE = PRIMARY );'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id

/**********************************************
3. Veryify backup occuring on Primary
**********************************************
    The following is what maintenance plan generates the full backup script for database 'TSQL2012'
*/
DECLARE @preferredReplica int

SET @preferredReplica = (SELECT [master].sys.fn_hadr_backup_is_preferred_replica('TSQL2012'))

IF (@preferredReplica = 1)
BEGIN
    BACKUP DATABASE [TSQL2012] TO  DISK = N'D:\DBBackup\LoganSQL\TSQL2012_backup_2019_09_30_094744_2022875.bak' WITH NOFORMAT, NOINIT,  NAME = N'TSQL2012_backup_2019_09_30_094744_2022875', SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10
END
GO

/************
4. CONCLUSION
*************
When you define a new maintenance plan, the '...Ignore Replica Priority for Backup' setting is off by default. 
Therefore, the maintenance plan WILL detect the availability group's AUTOMATED_BACKUP_PREFERENCE setting when deciding to backup a database or log if that database is defined in the group.

Given that an availability group's default AUTOMATED_BACKUP_PREFERENCE setting is 'SECONDARY' in a maintenance plan, 
there will  NOT backup databases defined in the availability group in Primary Replica by default.
*/

/*
Configure backups on secondary replicas of an Always On availability group
https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/configure-backup-on-availability-replicas-sql-server?view=sql-server-2017
*/

/*
Prefer Secondary
Specifies that backups should occur on a secondary replica except when the primary replica is the only replica online. In that case, the backup should occur on the primary replica. This is the default option.

Secondary only
Specifies that backups should never be performed on the primary replica. If the primary replica is the only replica online, the backup should not occur.

Primary
Specifies that the backups should always occur on the primary replica. This option is useful if you need backup features, such as creating differential backups, that are not supported when backup is run on a secondary replica.
*/

-- set to the default 
select distinct 'ALTER AVAILABILITY GROUP ['+g.name+'] SET( AUTOMATED_BACKUP_PREFERENCE = SECONDARY );'
FROM sys.availability_replicas r, master.sys.availability_groups g
where  r.group_id = g.group_id


-- snippet to backup while checking automated backup preference into account for a given availability group,
use master 
DECLARE @DBNAME varchar(200)
IF (NOT sys.fn_hadr_backup_is_preferred_replica(@DBNAME))  
BEGIN  
      Select 'This is not the preferred replica, exiting with success';  
      RETURN 0 - This is a normal, expected condition, so the script returns success  
END  
BACKUP DATABASE @DBNAME TO DISK=<disk>  
   WITH COPY_ONLY;