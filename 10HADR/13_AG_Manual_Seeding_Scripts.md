# AG Manual Seeding Scripts
## vw_backup_history

```
CREATE view [dbo].[vw_backup_history]
as
SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
/*
CAST (backupset.backup_size/(1024*1024) AS decimal (10,4)) AS backup_MB, 
CAST (compressed_backup_size/(1024*1024) AS decimal (10,4))  AS compressed_MB ,
*/
CAST (backupset.backup_size/(1024*1024) AS decimal (16,4)) AS backup_MB, 
CAST (compressed_backup_size/(1024*1024) AS decimal (16,4))  AS compressed_MB ,
CAST (compressed_backup_size / backup_size AS decimal (6,4)) as ratio, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
GO
```
## Generate Copy Backup Scripts
```
use msdb
go

-- copy current date daily Full backup
select 'copy '+physical_device_name+' \\MyReplica\f$\DBBackup\temp' from [dbo].[vw_backup_history] 
where backup_start_date>='2021-06-16 20:00:00.000' and backup_type='Database'
and database_name not in ('master','msdb','model','MDW','ReportServerTempDB')
order by database_name

-- For BigDB
-- robocopy "G:\DBBackup\myBigDB" "\\MyReplica\f$\DBBackup" MyBigDB_backup_2021_05_15_200003_4095767.bak /MT:16 /MIR /LOG:RoboCopy_MyReplica_MyBigDB.log

-- copy all log backup after full backup (exlude BigDB)
select 'copy '+physical_device_name+' \\MyReplica\f$\DBBackup\temp\Log' from [dbo].[vw_backup_history] 
where backup_type='Log' and backup_start_date>='2021-06-16 20:00:00.000'
and database_name not in ('master','msdb','model','MDW','ReportServerTempDB')
order by database_name
```
all scripts to be execute on cmd under administrator
## Generate Restore Backup Scripts
```
use msdb

-- restore daily full backup commands
select 'RESTORE DATABASE ['+database_name+'] FROM  DISK = N'+'''F:\DBBackup\temp\'+backupset_name+'.bak'' WITH REPLACE, FILE = 1, NORECOVERY, NOUNLOAD, STATS = 5' 
from [dbo].[vw_backup_history] 
where backup_start_date>='2021-06-16 20:00:00.000' and backup_type='Database'
and database_name not in ('master','msdb','model','MDW','ReportServerTempDB')
order by database_name

-- restore hourly log backup command (All database)
select 'RESTORE LOG ['+database_name+'] FROM  DISK = N'+'''f:\DBBackup\Temp\Log\'+backupset_name+'.trn'' WITH NORECOVERY' from [dbo].[vw_backup_history] 
--where backup_type='Log' and backup_start_date>='2021-05-15 20:00:04.000' 
--where backup_type='Log' and backup_start_date>='2021-06-14 21:00:00.000' --'2021-05-15 20:00:04.000' 
--and database_name not in ('master','msdb','model','DBA', 'mdw','ReportServerTempDB')
where backup_type='Log' and backup_start_date>='2021-06-16 20:00:00.000' --'2021-05-15 20:00:04.000' 
and database_name not in ('master','msdb','model','MDW','ReportServerTempDB')
order by database_name,backupset_name
```