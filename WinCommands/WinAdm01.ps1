<#
    Useful links : https://docs.microsoft.com/en-us/sysinternals/
#>

<########################################################
    How many users are logged on/connected to a server?
########################################################>
#   Sometimes we may need to know how many users are logged on to a (file) server, like maybe when there is a performance degradation.
#   At the server's console itself, with native commands only:


	NET SESSION | FIND /C "\\"
#   Remotely, with the help of SysInternals' PSTools:

	PSEXEC \\servername NET SESSION | FIND /C "\\"
#   By replacing FIND /C "\\" by FIND "\\" (removing the /C switch) you'll get a list of logged on users instead of just the number of users.

<###################################################
    Who is logged on to a computer?
###################################################>

	PSLOGGEDON -L \\remotecomputer
#   or:
	PSEXEC \\remotecomputer NET CONFIG WORKSTATION | FIND /I " name "
#   or:
	PSEXEC \\remotecomputer NET NAME

<###################################################
    What is the full name for this login name?
###################################################>

	NET USER loginname /DOMAIN | FIND /I " name "

<###################################################
    Members of a global group
###################################################>

	NET GROUP groupname /DOMAIN

<###################################################
    Is account locked?
###################################################>

	NET USER loginname /DOMAIN | FIND /I "Account active"

<###################################################
    List all domain in the network
###################################################>

    NET VIEW /DOMAIN

<###################################################
    List all computers in LAN
###################################################>

    NET VIEW

<###################################################
    List all local administrators
###################################################>

    NET LOCALGROUP Administrators

<###################################################
    List windows updates installed
###################################################>

    DISM /Online /Get-Packages
# or
    WMIC QFE List