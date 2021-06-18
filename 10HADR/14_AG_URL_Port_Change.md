# AG Hadr_endpoint
```
SELECT @@Servername as Server,type_desc, port , *FROM sys.tcp_endpoints;  
GO  

ALTER ENDPOINT Hadr_endpoint   
STATE = STARTED   
AS TCP (LISTENER_PORT = 6022)  
FOR database_mirroring (ROLE = ALL);  
GO  

```