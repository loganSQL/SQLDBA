/*
    Sometimes, when SSRS service was shutdown, those related report server jobs are still running on SQL Agent
    These will cause the failure of job status
*/

-- select those SSRS jobs
SELECT 
 job_id
,name
,enabled
,*
FROM msdb.dbo.sysjobs
where category_id=105
ORDER BY date_created

-- code snip for disable those jobs
EXEC msdb.dbo.sp_update_job @job_name='Your job name',@enabled = 0

-- generate sql scripts
select 'EXEC msdb.dbo.sp_update_job @job_name='''+name+''',@enabled = 0'
FROM msdb.dbo.sysjobs
where category_id=105

/*
EXEC msdb.dbo.sp_update_job @job_name='D8290FE0-3E6F-47AE-ADBF-2F32112FA7D0',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='B866B1B2-6853-440A-AD0D-0D5DA6B26108',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='C6C7AAE9-FD98-4788-B1F7-29918EEB310E',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='37B37C58-C1C4-45E9-8610-31D377827DDC',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='31DBE2E3-7F0C-47D4-BE79-C433B2484DAE',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='609F6CA9-28B9-4F98-80DD-149010421303',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='9F783701-B68C-4C5B-830D-ED46B8941F89',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='F4ED72B6-0AA3-4A3E-B138-281B3DADE1FE',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='743E68C3-BA52-47FE-8A01-63878B1BC76E',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='B0E7CE76-8D81-4E54-9BEF-83BF1F2BB535',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='650AC52C-8CD2-4B7A-8AF8-E7CA103D591B',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='1C43E0B6-57D3-45D7-9C1E-D5316B295089',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='DF5012E6-7C94-4F1E-AF59-4A415595CA68',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='5F98C072-BC57-4A85-AB5E-847D20173A41',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='2B19024E-2CAA-47AC-A963-F99F4059DABF',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='ECE72141-2F02-4EE0-B10C-96CD35A49529',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='9E3C5B8B-FE92-4091-AB9A-FB228292BB14',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='889A2886-49D0-4D8A-BC1F-B725205DD803',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='C7C5CA21-BCDF-4915-A7C4-49B5796DA1A1',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='1B072C32-18A7-46AC-AF5A-F1A9C16A7804',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='06CD1DF8-89BB-4ED0-8AB9-C75250B3279D',@enabled = 0
EXEC msdb.dbo.sp_update_job @job_name='9C98ED08-35D2-46E1-9E56-CD5DC395CFF0',@enabled = 0
*/
