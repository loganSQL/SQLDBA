# Microsoft SQL Data Encryption Notes

Compiled By Logan

### Overview
An organization less diligent about security might assume that, because SQL Server is a backend system, the databases are inherently more secure than public-facing components and be satisfied that the data is ensconced in a protective layer. But SQL Server still relies on network access and is consequently exposed enough to warrant protection at all levels. Add to this the possibility that physical components such as backup drives can be lost or stolen (most likely the latter), and you can’t help but realize that no protection should be overlooked.

Encryption is one such protection. Although it cannot prevent malicious attempts to access or intercept data, no more than it can prevent a drive from being stolen, it offers another safeguard for protecting your data, especially that super-sensitive stuff such as credit card information and social security numbers. That way, if the data has been accessed for less than ethical reasons, it is at least protected from prying eyes.

SQL Server supports the ability to **encrypt data at rest** and **in motion**. 

### SQL Server Data Encryption At Rest
On the at-rest side, you have two options: **cell-level encryption and Transparent Data Encryption (TDE)**. 

Cell-level has been around for a while and lets you encrypt individual columns. SQL Server encrypts the data before storing it and can retain the encrypted state in memory.

Introduced in SQL Server 2008, TDE encrypts the entire database, including the log files. The data is encrypted when it is written to disk and decrypted when being read from disk. The entire process is transparent to the clients and requires no special coding. TDE is generally recommended for its performance benefits and ease of implementation. If you need a more granular approach or are working with SQL Server 2005 or earlier, then go with cell-level encryption.

### SQL Server Data Encryption In Motion (Sessions / Connections)
SQL Server can also use the Secure Sockets Layer (SSL) protocol to encrypt data transmitted over the network whether between SQL Server instances or between SQL Server and a client application. In this way, data can be protected throughout a session, making it possible to pass sensitive information over a network. Of course, SSL doesn’t protect data at rest, but when combined with TDE or cell-level encryption, data can be protected at every stage.

### SQL Server Key Management
An important component of any encryption strategy is key management. Without going into all the gritty details of SQL Server key hierarchies, master keys, and symmetric and asymmetric keys, let’s just say you need to ensure these keys (or certificates) are fully protected. One strategy is to use symmetric keys to encrypt data and asymmetric keys to protect the symmetric keys. You should also password-protect keys, and always back up the master keys and certificates. Also back up your database to maintain copies of your symmetric and asymmetric keys, and be sure those backups are secure.

## SQL Server Encryption References
[Microsoft Docs: SQL Server Encryption Hierarchy](https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms189586(v%3dsql.105))
[Microsoft Docs: Understanding Transparent Data Encryption (TDE)](<https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/bb934049(v%3dsql.105)>)


## Challenges to Microsoft SQL TDE
Simon McAuliffe wrote a piece about how to break TDE(
[The Anatomy and (In)Security of Microsoft SQL Server Transparent Data Encryption (TDE), or How to Break TDE](<https://simonmcauliffe.com/technology/tde/>)). The challenge is not restricted to Microsoft. It is the technology itself (<https://en.wikipedia.org/wiki/Transparent_Data_Encryption>). 

There is no magic on data encryption. The best security is coming from the thoughtful design.
* **Good Application Design:** Application (column level/row level) based encryption of data at rest is an alternative to TDE. It avoids some of the pitfalls, but requires support from application developers and may be expensive to retrofit to existing systems.

* **Good Administration Practice:** Great care should be taken with access to servers and with file permissions. An unprivileged user should be entirely prevented from accessing database files. A privileged user will be able to decrypt and read encrypted data in all cases, so don’t do well over it too much. The only thing you can practically do is keep the files away from unprivileged users, and try to prevent users from escalating by following other good security practices. Adding TDE on top of that won’t help a bean since an unprivileged user can’t get the data and a privileged user can read it despite TDE.

* **Independent Encryption System:** Backups should be encrypted with an independent encryption system integrated into the backup system.

* **Keep a Closely Eye On:** Your permissions and other access controls should be audited automatically and frequently so that if an accidental change is made it can be fixed before it is exploited.


