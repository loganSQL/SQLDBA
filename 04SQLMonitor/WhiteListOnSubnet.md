# White List on Subnet
## White List Schema
```
USE [master]
GO

IF OBJECT_ID('dbo.[wl_subnet]') IS NOT NULL
  DROP TABLE [dbo].[wl_subnet];
GO

CREATE TABLE [dbo].[wl_subnet](
[wl_id] [int] IDENTITY(1,1) NOT NULL primary key,
[wl_network] [nvarchar](18) NOT NULL,
[wl_rdt] [datetime] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[wl_subnet] ADD  CONSTRAINT [DF_wl_subnet_wl_rdt]  DEFAULT (getdate()) FOR [wl_rdt]
GO

GRANT SELECT ON dbo.[wl_subnet] TO PUBLIC;
go

USE model
go

IF OBJECT_ID('wl_violation') IS NOT NULL
  DROP TABLE [dbo].[wl_violation];
GO

CREATE TABLE [dbo].[wl_violation](
[wl_v_id] [int] IDENTITY(1,1) NOT NULL primary key,
[wl_v_rdt] [datetime] NOT NULL,
[LoginName] VARCHAR(255) NOT NULL,
    [HostName] VARCHAR(255) NULL,
    [HostIpAddress] VARCHAR(50) NULL,
[AppName] VARCHAR(128) NULL,
[Pass] BIT NULL,


) ON [PRIMARY]
GO

ALTER TABLE [dbo].[wl_violation] ADD  CONSTRAINT [DF_wl_v_rdt]  DEFAULT (getdate()) FOR [wl_v_rdt]
GO
grant insert on [dbo].[wl_violation] to public
go

USE tempdb
go

IF OBJECT_ID('wl_violation') IS NOT NULL
  DROP TABLE [dbo].[wl_violation];
GO

CREATE TABLE [dbo].[wl_violation](
[wl_v_id] [int] IDENTITY(1,1) NOT NULL primary key,
[wl_v_rdt] [datetime] NOT NULL,
[LoginName] VARCHAR(255) NOT NULL,
    [HostName] VARCHAR(255) NULL,
    [HostIpAddress] VARCHAR(50) NULL,
[AppName] VARCHAR(128) NULL,
[Pass] BIT NULL,


) ON [PRIMARY]
GO

ALTER TABLE [dbo].[wl_violation] ADD  CONSTRAINT [DF_wl_v_rdt]  DEFAULT (getdate()) FOR [wl_v_rdt]
GO

grant insert on [dbo].[wl_violation] to public
```

```
-- some subnets on the white list for testing
-- 
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.101.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.102.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.102.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.103.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.104.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('192.16.105.0/24')

--
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.101.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.102.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.102.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.103.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.104.0/24')
insert into [dbo].[wl_subnet]([wl_network]) values ('10.16.105.0/24')

```
## Logon Trigger
```
CREATE TRIGGER WLSTrigger
ON ALL SERVER FOR LOGON
AS
BEGIN
  DECLARE 
     @LoginName VARCHAR(255) = ORIGINAL_LOGIN()
    ,@HostName VARCHAR(255) = HOST_NAME()
    ,@HostIpAddress VARCHAR(50) = CONVERT(VARCHAR(50),CONNECTIONPROPERTY('client_net_address'))
    ,@AppName nvarchar(128)
    ,@sid varbinary(85)=SUSER_SID()
    ,@Msg VARCHAR(255);
    
  --set @HostIpAddress='172.16.121.40'

  -- Only check those sql login (excluding sa and system created)
  if exists(SELECT name FROM sys.server_principals WHERE sid=@sid and TYPE = 'S' and name<>'sa' and name not like '%##%')
  begin
    -- HostIpAddress is not in the whitelist
    IF ([master].[dbo].[fnIsIPinWhiteList](@HostIpAddress)) = 0
    begin

    /*
      -- just keep an violation record into tempdb
      insert into tempdb.[dbo].[wl_violation]([LoginName],[HostName],[HostIpAddress],[AppName],[Pass])
      values (@LoginName,@HostName,@HostIpAddress,@AppName,0)
   */
      -- or directly kick out the connection
      rollback
    end
  end
END;
GO
```

## Some commands for Logon Trigger
```
use master
go

select * from sys.server_triggers
go


disable trigger WLSTrigger on ALL SERVER
go

drop trigger WLSTrigger on ALL SERVER
go
```

## T-SQL functions
[Reference: Datatype for storing ip address in SQL Server](https://stackoverflow.com/questions/1385552/datatype-for-storing-ip-address-in-sql-server)
To determine if an ip address is in a subnet
1) convert the network address, subnet mask and test address to binary.

2) Check if (Network Address & Subnet Mask) = (Test Address & Subnet mask)
(& represents bitwise AND)
If this comparison is true the test address is within the subnet

The key to understanding this is to realise that IP addresses (and subnet masks) are just 32 bit numbers.
A bitwise and between 2 32 bit numbers creates a new 32 bit number with a 1 in the position where there was a 1 in both of the 2 numbers being compared, and a 0 otherwise.

EG: 1010 & 1100 = 1000 because the first digit is 1 in both numbers (yielding a 1 in the result for the first digit), but the 2nd 3rd and 4th digits are not (so give 0 in the result for the 2nd 3rd and 4th digits).

SQL Server cannot do a bitwise and between 2 binary numbers unfortunately, but it works fine between decimal representations (ie when converted to BIGINT datatype).



### fnIsIPinWhiteList

```
-- To test an ip in WhiteList
-- For Example
--    select  dbo.fnIsIPinWhiteList('192.168.0.1')
--    select  dbo.fnIsIPinWhiteList('192.16.103.12')

/*
SELECT dbo.fnIsIpaddressInSubnetShorthand('192.168.2.0/24','192.168.3.91')
*/

create function dbo.fnIsIPinWhiteList 
 (
    @testAddress NVARCHAR(15) -- 'eg: '192.168.0.1'
)
RETURNS BIT AS
BEGIN
 --DECLARE @testAddress NVARCHAR(15)
 -- set @testAddress = '172.16.125.12'
  if exists ( select [wl_network] from [wl_subnet] where  [dbo].[fnIsIpaddressInSubnetShortHand](wl_network,@testAddress) =1 ) return 1
  return 0
END
```
### fnIsIpaddressInSubnetShortHand
```
-- To test an ip in a subnet
-- For Example
--    SELECT dbo.fnIsIpaddressInSubnetShorthan ('192.168.2.0/24','192.168.3.91')

CREATE FUNCTION dbo.fnIsIpaddressInSubnetShortHand
(
    @network NVARCHAR(18), -- 'eg: '192.168.0.0/24'
    @testAddress NVARCHAR(15) -- 'eg: '192.168.0.1'
)
RETURNS BIT AS
BEGIN
    DECLARE @networkAddress NVARCHAR(15)
    DECLARE @subnetBits TINYINT

    SELECT @networkAddress = LEFT(@network, CHARINDEX('/', @network) - 1)
    SELECT @subnetBits = CAST(SUBSTRING(@network, LEN(@networkAddress) + 2, 2) AS TINYINT)

    RETURN CASE WHEN (dbo.fnIPtoBigInt(@networkAddress) & dbo.fnSubnetBitstoBigInt(@subnetBits)) 
        = (dbo.fnIPtoBigInt(@testAddress) & dbo.fnSubnetBitstoBigInt(@subnetBits)) 
    THEN 1 ELSE 0 END
END
```

### fnSubnetBitstoBigInt
```
/*
To make this a bit easier for you you'll probably want a function that can convert '/24' to a BigInt too.
'/24' is a shorthand way of writing 255.255.255.0 - ie a 32bit number with the first 24bits set to 1 (and the remaining 8 bits set to 0)
*/

CREATE FUNCTION dbo.fnSubnetBitstoBigInt
(
    @SubnetBits TINYINT -- max = 32
)
RETURNS BIGINT
AS
BEGIN

 DECLARE @multiplier AS BIGINT = 2147483648
 DECLARE @ipAsBigInt AS BIGINT = 0
 DECLARE @bitIndex TINYINT = 1
 WHILE @bitIndex <= @SubnetBits
 BEGIN
    SELECT @ipAsBigInt = @ipAsBigInt + @multiplier
    SELECT @multiplier = @multiplier / 2
    SELECT @bitIndex = @bitIndex + 1
 END

 RETURN @ipAsBigInt

END

GO
```

### fnIsIpaddressInSubnet
```
-- a function to test if an address is in a subnet
--
CREATE FUNCTION dbo.fnIsIpaddressInSubnet
(
    @networkAddress NVARCHAR(15), -- 'eg: '192.168.0.0'
    @subnetMask NVARCHAR(15), -- 'eg: '255.255.255.0' for '/24'
    @testAddress NVARCHAR(15) -- 'eg: '192.168.0.1'
)
RETURNS BIT AS
BEGIN
    RETURN CASE WHEN (dbo.fnIPtoBigInt(@networkAddress) & dbo.fnIPtoBigInt(@subnetMask)) 
        = (dbo.fnIPtoBigInt(@testAddress) & dbo.fnIPtoBigInt(@subnetMask)) 
    THEN 1 ELSE 0 END
END
```

### fnIPtoBigInt
```
-- a function that converts your IP addresses to BIGINT datatype firstly
--
CREATE FUNCTION dbo.fnIPtoBigInt
(
    @Ipaddress NVARCHAR(15) -- should be in the form '123.123.123.123'
)
RETURNS BIGINT
AS
BEGIN
 DECLARE @part1 AS NVARCHAR(3) 
 DECLARE @part2 AS NVARCHAR(3) 
 DECLARE @part3 AS NVARCHAR(3)
 DECLARE @part4 AS NVARCHAR(3)

 SELECT @part1 = LEFT(@Ipaddress, CHARINDEX('.',@Ipaddress) - 1)
 SELECT @Ipaddress = SUBSTRING(@Ipaddress, LEN(@part1) + 2, 15)
 SELECT @part2 = LEFT(@Ipaddress, CHARINDEX('.',@Ipaddress) - 1)
 SELECT @Ipaddress = SUBSTRING(@Ipaddress, LEN(@part2) + 2, 15)
 SELECT @part3 = LEFT(@Ipaddress, CHARINDEX('.',@Ipaddress) - 1)
 SELECT @part4 = SUBSTRING(@Ipaddress, LEN(@part3) + 2, 15)

 DECLARE @ipAsBigInt AS BIGINT
 SELECT @ipAsBigInt =
    (16777216 * (CAST(@part1 AS BIGINT)))
    + (65536 * (CAST(@part2 AS BIGINT)))
    + (256 * (CAST(@part3 AS BIGINT)))
    + (CAST(@part4 AS BIGINT))

 RETURN @ipAsBigInt

END

GO
```

