# Mail Request Automation
## Overview
***
I received an email daily with some attached scripts to be executed routinely at different times.
The manual process is :
* save the attachment
* execute the script at the specific time
* email the result back to requester
***
I automated the manual process in the following steps:
1. Submission to an dedicated email account;
2. Check In and Schedule the downloaded scripts;
3. Execute Script one by one based on fixed schedule;

At the end of each step, an acknowledge email would be sent with the result.
***

## Submission
When receiving a request, I forward to another email address for submission.

The submission email is configured to:

* save all the scripts to local directory (C:\request)
* move submission email to a folder on exchange (for audit purpose)


### [Automatically Download Outlook Attachments To Folder With VBA And Rule](<https://www.extendoffice.com/documents/outlook/3747-outlook-auto-download-save-attachments-to-folder.html>)
To automatically download attachments, I configured Microsoft outlook client as the following:
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


When you create a macro and are running Outlook with the default security settings, you are not able to run the macro at all or you’ll always get prompted first, unless you either tamper with the default security settings or sign your own code with a digital certificate.

Since it is not very common to have your own digital certificate, you probably set your macro security to a lower level to be able to run your macro:

* check **Macro Settings** in **Trust Center**: **File -> Options -> Trust Center (Trust Center Settings) -> Macro Settings -> "Enable all macros" (Apply macro security settings to installed add-ins)**

[Signing your own macros with SelfCert.exe](<https://www.howto-outlook.com/howto/selfcert.htm>)
* Create a certificate (**SELFCERT.exe**)
  * C:\Program Files\Microsoft Office\Office14\SELFCERT.EXE
  * Your certificate's name: LoganTest
  (certificate created under the **MMC console --> Certificate snap in --> LocalComputer --> Personal section**)
* Sign your code (**VBA Editor**)
  * Back in the VBA Editor (ALT+F11) where you created the macro choose;
  * Tools-> Digital Signature…
      You’ll see that the current VBA project isn’t signed yet. Press the Choose… button and you’ll get a screen to select a certificate. Now you can choose the certificate you just created.
* Verify your macro security level (**Outlook**)
  * File-> Options-> Trust Center-> Trust Center Settings…-> Macro Settings-> option: *Notifications for digitally signed macros, all other macros disabled*

## Check In / Schedule

### Task Scheduler

I created a Task in Task Schedule on the client machine with submission email by using the following powershell script, to copy the submitted sql scripts from local directory (C:\Request) to server directory (e.g. \\\myserver\e$\Request\Daily)
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
### MainLoop.ps1
There is a problem to schedule above check-in script in Windows Task Schedule by repeating at every 5 minutes, because the task doesn't execute well after a while.

To resolve this unpredictability, the following Powershell Script will be used to replace the task schedule to run the CheckIn.ps1 in an endless loop.
```
$PSScriptRoot
$i = 1
while($true)
{
    Write-Host "$i => Watcher wake up at $(Get-Date)"
    & "$PSScriptRoot\CheckIn.ps1"
    start-sleep -seconds 300
    if($i -lt 9999)
    {   
        $i++
    }
    else
    {
        $i = 1
    }
}

write-host "Timed out"
```
## Script Runner
The following powershell script was called at different SQL Agent Job schedule by identified script name prefix:
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
'.\scriptrunner.ps1 -servername SERVERNAME -dbname DBNAME -requestpath REQUESTPATH -scriptprefix SCRIPTPREFIX'  
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
@profile_name = 'sqldba',
@recipients = @emails,
@body = 'The result has been attached.',
@file_attachments = @outfile,
@subject =   @job_name ;
GO
```
