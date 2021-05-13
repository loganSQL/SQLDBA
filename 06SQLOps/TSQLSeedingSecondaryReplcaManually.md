# AG Secondary Seeding Manually
### 1. Generate Backup Copying commands
```
-- copy current date daily Full backup
select 'copy '+physical_device_name+' \\myPrimaryHost\g$\DBBackup\Temp\Log' from [dbo].[vw_backup_history] where backup_start_date>='2021-05-11 22:09:41.000' and backup_type='Log' and database_name = 'myDB'

-- copy all last hour log backup
select 'copy '+physical_device_name+' \\mySecondaryHost\g$\DBBackup\Temp\Log' from [dbo].[vw_backup_history] where backup_type='Log' and backup_start_date>='2021-05-12 14:14:14.000' order by database_name
```
### 2. Generate Restore Backup command
```
-- restore daily full backup commands
select 'RESTORE DATABASE ['+database_name+'] FROM  DISK = N'+'''g:\DBBackup\Temp\'+backupset_name+'.bak'' WITH REPLACE,  RESTRICTED_USER,  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5' from [dbo].[vw_backup_history] where backup_type='Database' and backup_start_date>='2021-05-11 22:09:41.000' order by database_name

--select * from [dbo].[vw_backup_history] where backup_start_date>='2021-05-11 22:09:41.000' and backup_type='LOG' and backup_start_date>='2021-05-11 22:09:41.000' order by database_name  2021-05-12 14:14:14.000
-- restore last hour log

-- restore hourly log backup command
select 'RESTORE LOG ['+database_name+'] FROM  DISK = N'+'''g:\DBBackup\Temp\Log\'+backupset_name+'.trn'' WITH NORECOVERY' from [dbo].[vw_backup_history] where backup_type='Log' and backup_start_date>='2021-05-12 14:14:14.000' order by database_name

select 'RESTORE LOG ['+database_name+'] FROM  DISK = N'+'''g:\DBBackup\Temp\Log\'+backupset_name+'.trn'' WITH NORECOVERY' from [dbo].[vw_backup_history] where backup_type='Log' and backup_start_date>='2021-05-11 22:09:41.000' and database_name='myDB'
```
### When databases on Secondary Host Ready
```
-- Add Replica by using join only
```