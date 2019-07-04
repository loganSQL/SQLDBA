<#
Remote Server Administration Tools for Windows 10
https://www.microsoft.com/en-ca/download/details.aspx?id=45520
#>

Import-Module ActiveDirectory

# Generate a CSV of all enabled users (email, first name, last name, and OU)
Get-ADUser -Properties * -Filter {Enabled -eq 'True'} | Select-Object @{Label = "Email";Expression = {$_.EmailAddress}}, @{Label = "First Name";Expression = {$_.GivenName}}, @{Label = "Last Name";Expression = {$_.Surname}}, @{Label = "Group";Expression = {($_.canonicalname -Split "/")[-2]}} | Export-Csv -Path users.csv -NoTypeInformation

# Generate a CSV of all enabled users who are a member of a particular security group
Get-ADUser -Properties * -Filter {Enabled -eq 'True'} | Where-Object {($_.memberof -like "*SQLDBA*")} | Select-Object @{Label = "Email";Expression = {$_.EmailAddress}}, @{Label = "First Name";Expression = {$_.GivenName}}, @{Label = "Last Name";Expression = {$_.Surname}}, @{Label = "Group";Expression = {($_.canonicalname -Split "/")[-2]}} | Export-Csv -Path users.csv -NoTypeInformation

# Generate a Security Group Mailing List
$grouptext = "SQLDBA"
# net group $grouptext /domain
$group=Get-ADUser -Properties * -Filter {Enabled -eq 'True'} | Where-Object {($_.memberof -like "*${grouptext}*")}
#$Members = Get-ADGroupMember -Recursive "SQLDBA"
$GroupMailList=""
foreach($Member in $group){
    $Member.mail
    $GroupMailList=$GroupMailList+$Member.mail+";"
}

$GroupMailList

# list of groups
$grouplist = ("SQLDBA","PBIUser")

foreach($grouptext in $grouplist){
    $group=Get-ADUser -Properties * -Filter {Enabled -eq 'True'} | Where-Object {($_.memberof -like "*${grouptext}*")}
    $GroupMailList=""
    foreach($Member in $group){
        $Member.mail
        $GroupMailList=$GroupMailList+$Member.mail+";"
    }
    $grouptext    
    $GroupMailList    
}

$GroupMailList

# Generate a CSV of all enabled users that are contained in a distribution group with a specific name
$Members = Get-ADGroupMember -Recursive "SQLDBA"
$Obj = @()
ForEach ($Member in $Members)
{
$User = Get-ADUser -Filter {Name -eq $Member.name -and Enabled -eq 'True'} -Properties *
$GroupObj = New-Object PSObject
$GroupObj | Add-Member -MemberType NoteProperty -Name "Email" -Value $User.EmailAddress
$GroupObj | Add-Member -MemberType NoteProperty -Name "First Name" -Value $User.GivenName
$GroupObj | Add-Member -MemberType NoteProperty -Name "Last Name" -Value $User.Surname
$GroupObj | Add-Member -MemberType NoteProperty -Name "Group" -Value (($User.canonicalname -Split "/")[-2])
$Obj += $GroupObj
}
$Obj | Export-Csv users.csv -NoTypeInformation

# Simple Way to send email to a group

$Recipients = Get-ADGroupMember $GroupName | Get-AdUser -Properties mail | Select-Object -ExpandProperty mail;
Send-MailMessage -SmtpServer $ServerName -To $Recipients [...]
<#
Module: Microsoft.PowerShell.Utility

Send-MailMessage -From 'User01 <user01@fabrikam.com>' `
-To 'User02 <user02@fabrikam.com>', 'User03 <user03@fabrikam.com>' `
-Subject 'Sending the Attachment' `
-Body "Forgot to send the attachment. Sending now." `
-Attachments .\data.csv `
-Priority High -DeliveryNotificationOption OnSuccess, OnFailure `
-SmtpServer 'smtp.fabrikam.com'

$params = @{ 
    'From' = 'logansql@exmaples.ca';
    'To' = 'logansql@exmaples.ca';
    'Subject' = 'Sending the Attachment'; 
    'Body' = 'Sending the Attachment'; 
    'SmtpServer' = 'SmtpServer.exmaples.ca'}
#>

$params = @{ 
    'From' = 'logansql@exmaples.ca';
    'To' = 'logansql@exmaples.ca';
    'Subject' = 'Sending the Attachment'; 
    'Body' = 'Sending the Attachment'; 
    'Attachments' =  '.\data.csv ';
    'SmtpServer' = 'SmtpServer.exmaples.ca'}

Send-MailMessage @params