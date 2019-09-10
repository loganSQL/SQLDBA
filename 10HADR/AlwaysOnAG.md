#1. Windows Failover Cluster Feature Installation

* Server Manager
* Add roles and features
* Select Features
* Select the Failover Clustering checkbox
* Add Features 
* Next

#2. Windows Failover Clustering Configuration

##2.1. Failover Cluster Validation

* Server Manager => Failover Cluster Manager => Validate Configuration => Validate a Configuration Wizard dialog box
* Select Servers or a Cluster dialog box => add server hostnames => Next
* Testing Options => n Run all tests (recommended) => Next
* Confirmation => Next
* Summary => Finished

The Failover Cluster Validation Wizard is expected to return several Warning messages, especially if you will not be using shared storage. 
There is no need to use shared storage to create the Windows Server Failover Cluster that we will use for our Availability Group. 
Just be aware of these Warning messages as we will configure a file share witness for our cluster quorum configuration. 
However, if you see any Error messages, you need to fix those first prior to creating the Windows Server Failover Cluster.

##2.2. Create a cluster: Failover Cluster Configuration (Access Point for Administering) the Cluster

* Access Point for Administering the Cluster dialog box => Enter virtual server name and virtual IP address
* Confirmation => Next
* Summary => verify the configuration successfully

##2.3. To configure the cluster quorum configuration to use a file share

* right-click on the cluster name, select More Actions and click Configure Cluster Quorum Settings
* In the Select Quorum Configuration page, select the Add or change the quorum witness option. Click Next
* In the Select Quorum Witness page, select the Configure a file share witness (recommended for special configuration) option. Click Next	
* In the Configure File Share Witness page, type path of the file share that you want to use in the File Share Path: text box. Click Next
* In the Confirmation page, click Next.
* In the Summary page, click Finish.

#3. Enable SQL Server AlwaysOn Availability Groups Feature
Repeat the following on primary and all the replicas
* Open SQL Server Configuration Manager. 
* Double-click the SQLServer (MSSQLSERVER) service to open the Properties dialog box
* select the AlwaysOn High Availability tab
* Check the Enable AlwaysOn Availability Groups check box
* Restart the SQL Server service.

#4. Create file share for backup and replicas
This is like setup log shipping before.
* Create a file share on one of the servers
* Give read/write access to all your service accounts.

#5. Create SQL Server AlwaysOn Availability Groups
In SSMS go to Management, right click Availability Groups and click New Availability Group Wizard,
* Specify Name for AG
* Select Databases
* Specify Replicas: connect to another server (instance)
* Replica Mode : Automatic Failover, High Performance, or High Safety.
•	Automatic Failover: This replica will use synchronous-commit availability mode and support both automatic failover and manual failover.
•	High Performance: This replica will use asynchronous-commit availability mode and support only forced failover (with possible data loss).
•	High Safety: This replica will use synchronous-commit availability mode and support only manual failover.
* Connection Mode in Secondary :  Disallow connections, Allow only read-intent connections, or Allow all connections.
•	Disallow connections: This availability replica will not allow any connections.
•	Allow only read-intent connections: This availability replica will only allow read-intent connections.
•	Allow all connections: This availability replica will allow all connections for read access, including connections running with older clients. For this example, I'll choose Automatic Failover and Disallow connections to my secondary role and click Next.

#6. Specify Availability Group Listener
take defaults and choose Next.

#7. Select Data Synchronization
	Perform initial data synchronization (need a shared location – fileshare)

#8. Validation & Summary & Script & Finish
* Configures endpoints 
* Create Availability Group 
* Create Availability Group Listener
* Join secondary replica to the Availability Group 
* Create a full backup of DB1 
* Restore DB1 to secondary server 
* Backup log of DB1 
* Restore DB1 log to secondary server 
* Join DB1 to Availability Group on secondary server 
* Create a full backup of DB2 
* Restore DB2 to secondary server 
* Backup log of DB2 
* Restore DB2 log to secondary server 
* Join DB2 to Availability Group on secondary server

#9. View the Availability Group in SSMS
In SSMS, drill down to Management => Availability Groups. 
* Availability Replicas
* Availability Databases
* Availability Group Listeners.
In the dashboard will help you determine if your databases are Synchronized and Healthy.
