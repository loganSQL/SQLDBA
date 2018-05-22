# Encrypting Connections to SQL Server Note

## Encrypting connections

There are two choices for encrypting data on the network
* Internet Protocol Security (IPSec)
* Secure Sockets Layer (SSL)


## Internet Protocol Security (IPSec)

Internet Protocol Security (IPSec) is implemented by the operating system. Both the client and server operating system must support IPSec. IPSec:

* Is configured by local security policy or through Group Policy.
* Supports authentication using Kerberos, certificates, or pre-shared key.
* Provides advanced protocol filtering to block traffic by protocol and port.

## Secure Sockets Layer (SSL)

Secure Sockets Layer (SSL) is implemented by SQL Server. It’s most commonly used to support Web clients, but it can also be used to support native SQL Server clients. The main two advantages to SSL over IPSec are:

* Minimal client configuration.
* Configuration on the server is straightforward.

## To configure SSL on the server

Obtaining and installing certificate is beyond the scope of this article, but you can obtain an SSL certificate from a third-party certificate authority e.g. VeriSign or you can install Windows Certificate services and supply own. (SQL Server can issue a self-signed certificate, but it isn’t meant for production use.)

* On the Start menu, click Run; then in the Open box type MMC, and click OK.
* In Microsoft Management Console (MMC), on the File menu, click Add/Remove Snap-in.
* In Add/Remove snap-in dialog box, click Add.
* In the Add Standalone Snap-in dialog box, click Certificates, then click Add.
* In the Certificates Snap-in dialog box, click Computer account, and then click Finish.
* In the Certificates MMC snap-in dialog box, expand Certificates, expand Personal, and then right-click Certificates; then point  All Tasks, Import. The Certificate Import Wizard appears.
* Click Next,  then  Browse and locate the certificate file; then click OK.
* Click Next; again click Next to accept the default store; and then click Finish.
* Click OK to close the success dialog.

After you have installed certificate on the server, you need to configure the server to accept encrypted connections. Here is how to do that:

* Launch SQL Server Configuration Manager.
* Expand SQL Server Network Configuration.
* Right-click Protocols For<instance_name> and choose Properties.
* Activate Certificate tab, select the certificate from the list, and then click OK.
* Activate Flags tab, If you want all clients to connect using encryption, change ForceEncryption to Yes. If you want to support encrypted and unencrypted connections, keep it set to No.
* Click OK.
* Restart the SQL Server service.

You also need to configure the client computer. To do so:

* If necessary, install the root certificate for the certificate authority that issued the certificate you installed on SQL Server.
* Launch SQL Server Configuration Manager.
* Select SQL Native Client Configuration.
* Right-click in the Console pane and choose Properties.
* Set Force protocol encryption to Yes.
* Click OK.

One drawback to the ForceEncryption option is that it encrypts all data. Encryption causes performance degradation, so performance can suffer during communications. This can be noticeable when very large amounts of data are involved.

## Encrypting a single connection

You can encrypt a single connection. For example, you might need to connect to a remote SQL Server to create login or user accounts. To do so:

* Open SQL Server Management Studio.
* Click Connect and choose Database Engine.
* Click Options.
* Check Encrypt connection.
* Click Connect.