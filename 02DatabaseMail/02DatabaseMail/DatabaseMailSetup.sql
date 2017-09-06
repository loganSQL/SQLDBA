/*
	Steps to configure and setup Database Mail on SQL Server
*/

USE [master]
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO
-- Create a New Mail Profile for Notifications
EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = 'sqladmin',
       @description = 'Mail Profile for SQL Admin Notification'
GO
-- Set the New Profile as the Default
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'sqladmin',
    @principal_name = 'public',
    @is_default = 1 ;
GO
-- Create an Account for the Notifications
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'sqladmin',
    @description = 'Email account for SQL Admin Notification',
    @email_address = 'logan.sql@yourdomain.com',  -- Change This
    @display_name = 'SQL Admin (Please Do Not Reply)',
    @mailserver_name = 'mailserver@yourdomain.com'  -- Change This
GO
-- Add the Account to the Profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'sqladmin',
    @account_name = 'sqladmin',
    @sequence_number = 1
GO