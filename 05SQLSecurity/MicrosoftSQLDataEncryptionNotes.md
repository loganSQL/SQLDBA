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

### SQL Server Data Encryption In Motion (Client Connections)
SQL Server can also use the Secure Sockets Layer (SSL) protocol to encrypt data transmitted over the network whether between SQL Server instances or between SQL Server and a client application. In this way, data can be protected throughout a session, making it possible to pass sensitive information over a network. Of course, SSL doesn’t protect data at rest, but when combined with TDE or cell-level encryption, data can be protected at every stage.

### SQL Server Key Management
An important component of any encryption strategy is key management. Without going into all the gritty details of SQL Server key hierarchies, master keys, and symmetric and asymmetric keys, let’s just say you need to ensure these keys (or certificates) are fully protected. One strategy is to use symmetric keys to encrypt data and asymmetric keys to protect the symmetric keys. You should also password-protect keys, and always back up the master keys and certificates. Also back up your database to maintain copies of your symmetric and asymmetric keys, and be sure those backups are secure.