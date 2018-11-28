# Mail Request Automation
## Overview
***
I receive an email daily with some attached scripts to be executed routinely at different times.
The manual process is :
* save the attachment
* execute the script at the specific time
* email the result back to requester
***

## Submission
When receiving a request, I forward to another email address for submission.

The submission email is configured to:

* save all the scripts to local directory (C:\request)
* move submission email to a folder on exchange (for audit purpose)


### [Automatically Download Outlook Attachments To Folder With VBA And Rule](<https://www.extendoffice.com/documents/outlook/3747-outlook-auto-download-save-attachments-to-folder.html>)
1. Press Alt + F11 keys to open the Microsoft Visual Basic for Applications window.

2. Click Insert > Module, and then paste below VBA script into the new opening Module window
```
Public Sub SaveAttachmentsToDisk(MItem As Outlook.MailItem)
Dim oAttachment As Outlook.Attachment
Dim sSaveFolder As String
sSaveFolder = "C:\Request\"
For Each oAttachment In MItem.Attachments
oAttachment.SaveAsFile sSaveFolder & oAttachment.DisplayName
Next
End Sub
```
3. Save the VBA Script and close the Microsoft Visual Basic for Applications window.
4. Go to the Mail view, and click Home > Rules > Manage Rules & Alerts. 
5. In the opening Rules and Alerts dialog box, please click the New Rule button on the E-mail Rules tab
6. Now in the Rules Wizard dialog box, please click to select the Apply rule on messages I receive option, and click the Next button.
7. In the Rules Wizard (which condition(s) do you want to check?) dialog box, please uncheck any option, and click the Next button. And then click the Yes button in the popping up Microsoft Outlook dialog box. 
8. Now in the Rules Wizard (what do you want to do with the message?) dialog box, please: (1) Check the run a script option; (2) Click the text of a script to open the Select Script dialog box, select the script we added in Step 2 and click the OK button; (3) Click the Next button.
9. In the Rules Wizard (Are there any exceptions?) dialog box, please click the Next button directly.
10. Now in the last Rules Wizard dialog box, please name the rule in the Step 1 box, check options as you need in the Step 2 section, and click the Finish button.
11. Close the Rules and Alerts dialog box.
 

## Check In / Schedule

Create a Task in Task Schedule on the client machine with submission email, and to copy the submitted scripts from local directory (C:\Request) to server directory (\\myserver\e$\Request\Daily)
```
$servername = 'myserver'
$dbname = 'tempdb'
$source = "C:\Request"
$destination = "\\"+$servername+"\e$\request\Daily"


if (!(Test-Path -Path "$source\*"))
{
    # empty
    '{0} is empty' -f $source
    exit 0
}

if (Test-Path -Path "$destination\*")
{
    # Not empty
    '{0} is not empty' -f $destination
    exit 0
}


mv $source\* $destination

$checkInLog="\\"+$servername+"\e$\request\CheckInLog\"
$date = (Get-Date).ToString("yyyy-MM-dd")
$CheckInLogText=$checkInLog+'\'+$date+'.txt'
$date+' Scripts have been checked in to the following directory'>$CheckInLogText
dir $destination >> $CheckInLogText
"" >> $CheckInLogText
"The following are the schedule:" >> $CheckInLogText
"1. Customer_Trigger will run at 5PM" >> $CheckInLogText
"2. Customer_Patch will run at 8PM" >> $CheckInLogText
"3. Customer_Restore will run at 10PM" >> $CheckInLogText
"" >> $CheckInLogText
"You will be notified by email">> $CheckInLogText

$OutputText="e:\request\CheckInLog\"+$date+'.txt'

$maillist = 'Devteam@mycompany.com;sqldba@mycompany.com'

# send email
$sendmailsql="exec msdb..sendOutputEmail '{0}','{1}','{2}'" -f 'CheckIn/Schedule Process',$OutputText, $maillist
sqlcmd -E -S $servername -d $dbname -Q $sendmailsql
```

## Script Runner
```
[CmdletBinding()]

# .\scriptrunner.ps1 -servername SERVERNAME -dbname DBNAME -requestpath REQUESTPATH -scriptprefix myscriptprefix 
# Example
# .\scriptrunner.ps1 -servername myserver -dbname mydb -requestpath 'E:\Request' -scriptprefix Customer_Trigger
Param (
  [string]$servername,
  [string]$dbname,
  [string]$requestpath,
  [string]$scriptprefix
)

if (!$servername -or !$dbname -or !$requestpath -or !$scriptprefix )
{
'.\scriptrunner.ps1 -servername SERVERNAME -dbname DBNAME -requestpath REQUESTPATH -scriptprefix scriptprefix'  
 exit
}

$date = (Get-Date).ToString("yyyy-MM-dd")

$ScriptDir = $requestpath + '\Daily'
$scriptDir
Set-Location $ScriptDir


$scriptprefix=$scriptprefix+'*'
$Step=Get-Item $scriptprefix
if (!$Step)
{
 Write-output 'No file exists'
 exit
}

$StepFullName=$Step.FullName
$StepName=$Step.Name
$StepBaseName=$Step.BaseName
$InputScript=$StepFullName

$OutputDir = $requestpath + '\History\'+$date
if(!(Test-Path -Path $OutputDir )){
    New-Item -ItemType directory -Path $OutputDir
}
$OutputText=$OutputDir+'\'+$StepBaseName+'.txt'

$StepFullName
$OutputText

# execute the script
sqlcmd -E -S $servername -d $dbname -i $StepFullName -e -o $OutputText
Move-Item -Path $StepFullName -Destination $OutputDir

$maillist = 'devteam@mycompany.com;sqldba@mycompany.com'

# send email
$sendmailsql="exec msdb..sendOutputEmail '{0}','{1}','{2}'" -f $scriptprefix,$OutputText,$maillist
sqlcmd -E -S $servername -d $dbname -Q $sendmailsql
```

## sendOutputEmail

The store procedure to send an email with a output file
```
USE [msdb]
GO

CREATE procedure [dbo].[sendOutputEmail] 
(@job_name varchar(255), @outfile varchar(1024), @emails varchar(1024))
as
select @job_name= @job_name+' Daily Run At '+  CONVERT(VARCHAR(24), GETDATE(), 113)
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'sqladmin',
@recipients = @emails,
@body = 'The result has been attached.',
@file_attachments = @outfile,
@subject =   @job_name ;
GO
```
