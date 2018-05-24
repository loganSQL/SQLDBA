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

## Client API : [SqlClient Connection Strings](<https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax#sqlclient-connection-strings>)

The TrustServerCertificate keyword is valid only when connecting to a SQL Server instance with a valid certificate. When TrustServerCertificate is set to true, the transport layer will use SSL to encrypt the channel and bypass walking the certificate chain to validate trust.

If  is set to true and encryption is turned on, the encryption level specified on the server will be used even if Encrypt is set to false in the connection string. The connection will fail otherwise. (SQL Server Network Protocol  forced Encryption is ON)

To enable encryption when a certificate has not been provisioned on the server, the Force Protocol Encryption and the Trust Server Certificate options must be set in SQL Server Configuration Manager. In this case, encryption will use a self-signed server certificate without validation if no verifiable certificate has been provisioned on the server.

Application settings cannot reduce the level of security configured in SQL Server, but can optionally strengthen it. An application can request encryption by setting the TrustServerCertificate and Encrypt keywords to true, guaranteeing that encryption takes place even when a server certificate has not been provisioned and Force Protocol Encryption has not been configured for the client. However, if TrustServerCertificate is not enabled in the client configuration, a provisioned server certificate is still required.

# Verifying if a connection to SQL Server is Encrypted
If you do not have a network parser such as netmon and want to verify if the connection from the client to the SQL server is encrypted, the following query can be utilised:

    SELECT session_id, encrypt_option, auth_scheme
    FROM sys.dm_exec_connections 
    WHERE session_id = @@SPID

-- Note: remove the WHERE clause to see all connections.
SELECT session_id, encrypt_option, auth_scheme, *
FROM sys.dm_exec_connections 

# Test 1: Server Forced Encryption Off
Although the server doesn't enforce the connection encryption, clients can still initiate the encrypted SQL connections (TrustServerCertificate=True, Encrypt connection=On). The transport layer will use SSL to encrypt the channel. The encryption is using self-signed server certification without validation because no verifiable certificate has been provisioned on the sql server. But by default, the client connections is not encrypted.

* Set SQL Server Network Protocol  forced Encryption is OFF
* Reboot SQL Service if needed

### Using SSMS to test encrypted connection
    1. Connect Database Engine, Click Options>>>
    2. Check "Encrypt connection"
    3. Check "Trust server certificate"
    4. Connect
    5. sql query to make sure connection is encrypted
    
          SELECT session_id, encrypt_option, auth_scheme
          FROM sys.dm_exec_connections 
          WHERE session_id = @@SPID
        
### Using SQLCMD to test encrypted connection
    1. sqlcmd -S YourSQLInstance -Uuser1 -N -C
      Notes: 
          -N Encrypt connection.
          -C Trust server certificate.
    2 sql query to make sure connection is encrypted
    
          SELECT session_id, encrypt_option, auth_scheme
          FROM sys.dm_exec_connections 
          WHERE session_id = @@SPID
          
# Test 2: Server Forced Encryption ON

* Set SQL Server Network Protocol  forced Encryption is ON
* Choose the right certificate (if not, the self-signed cert will be used)
* Reboot SQL Service if needed

### Using SSMS to test encrypted connection
    1. Connect Database Engine 
    4. Connect as normal (make sure clear the "Encrypt connection" / "Trust server certificate" options)
    5. sql query to make sure connection is encrypted by default
    
          SELECT session_id, encrypt_option, auth_scheme
          FROM sys.dm_exec_connections 
          WHERE session_id = @@SPID
        
### sing SQLCMD to test encrypted connection
    1. sqlcmd -S TORPFNSQL14 -Uuser1
    2 sql query to make sure connection is encrypted
    
          SELECT session_id, encrypt_option, auth_scheme
          FROM sys.dm_exec_connections 
          WHERE session_id = @@SPID
          
## References
* [Microsoft Docs: Encrypting Connections to SQL Server](<https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms189067(v=sql.105)>)
* [Microsoft Docs: Enable Encrypted Connections to the Database Engine](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/enable-encrypted-connections-to-the-database-engine?view=sql-server-2017)
* [MSDN: SqlConnection.ConnectionString Property](<https://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.connectionstring(v=vs.110).aspx>)
* [Microsoft Docs: Connection String Syntax](<https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax>)
* [How to set and use encrypted SQL Server connections](<https://www.sqlshack.com/how-to-set-and-use-encrypted-sql-server-connections/>)* 