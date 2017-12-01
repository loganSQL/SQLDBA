#
#  Powershell steps for installation of WSL
#

<#
#	What is Windows Subsystem for Linux (WSL)?
#	The Windows Subsystem for Linux (WSL) is a new Windows 10 feature that enables you 
#	to run native Linux command-line tools directly on Windows, 
#	alongside your traditional Windows desktop and modern store apps.
#>

#####################################################################################
#
#	INSTALLATION and SETUP
#
#	Refer to https://msdn.microsoft.com/en-us/commandline/wsl/install-on-server
#####################################################################################
#
#	0. Pre-requisites
#
#	Refer to : https://msdn.microsoft.com/en-us/commandline/wsl/troubleshooting#check-your-build-number
#

PowerShell

# 0.1. Check your build number
#		Setting>system>about  (Windows build 16215, Systme Type: 64-bit OS, x64-based processor)
systeminfo | Select-String "^OS Name","^OS Version"

# if not 16215 above, update it
#  https://www.microsoft.com/en-ca/software-download/windows10

#	0.2.Make sure WSL is enabled
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# if not, enable WSL
#  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

#
#	1. Install a Linux distribution
#

#  cmd as sys admin
#  1.1 Download

Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1604 -OutFile ~/Ubuntu.zip -UseBasicParsing

#  1.2. Unzip the file
Expand-Archive ~/Ubuntu.zip c:\logan\Ubuntu

<#
PS C:\Windows\system32> ls C:\logan\Ubuntu\

ubu
    Directory: C:\logan\Ubuntu


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----       2017-11-29   1:35 PM                AppxMetadata
d-----       2017-11-29   1:35 PM                Assets
d-----       2017-11-29   1:35 PM                images
-a----       2017-07-11   6:10 PM         190434 AppxBlockMap.xml
-a----       2017-07-11   6:10 PM           2475 AppxManifest.xml
-a----       2017-07-11   6:11 PM          10554 AppxSignature.p7x
-a----       2017-07-11   6:10 PM      201254783 install.tar.gz
-a----       2017-07-11   6:10 PM           4840 resources.pri
-a----       2017-07-11   6:10 PM         222208 ubuntu.exe
-a----       2017-07-11   6:10 PM            809 [Content_Types].xml
#>

# 1.3. Run the installer
## first time install
ubuntu.exe 

#or subsequently use
bash

#or Factory reset
ubuntu clean

# 1.4. Create a UNIX user
logan 

# 1.5. Run distro update / upgrade
sudo apt-get update
sudo apt-get upgrade

<#
Frequently Asked Questions
https://msdn.microsoft.com/en-us/commandline/wsl/faq

WSL
This is primarily a tool for developers -- especially web developers and 
those who work on or with open source projects. 
This allows those who want/need to use Bash, common Linux tools (sed, awk, etc.) 
and many Linux-first tools (Ruby, Python, etc.) to use their toolchain on Windows.
#>

# check current Linux distro
lsb_release -a

# find your local drives mounted (C:)
ll /mnt/c
cd /mnt/c

ls /mnt/c/logan
ls /mnt/c/Users/logan.chen/Documents/

<#




	To Unistall WSL
lxrun /uninstall /full
sc stop lxssmanager
rmdir /S "\\?\%LOCALAPPDATA%\lxss"
#>
