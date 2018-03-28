USE DBA
go

if exists (select name from sysobjects where name ='fnGrowthRate_MB' and type ='FN')
	drop function fnGrowthRate_MB
go

-- USAGE:- to get the table growth rate per DAY / WEEK / MONTH / YEAR
-- select dbo.fnGrowthRate_MB('MYSERVER','MYDB','MYTABLE','DAY')
-- select dbo.fnGrowthRate_MB('MYSERVER','MYDB','MYTABLE','WEEK')
-- select dbo.fnGrowthRate_MB('MYSERVER','MYDB','MYTABLE','MONTH')
-- select dbo.fnGrowthRate_MB('MYSERVER','MYDB','MYTABLE','YEAR')

CREATE FUNCTION dbo.fnGrowthRate_MB
(
@InstanceName nvarchar(128),
@DatabaseName nvarchar(128),
@TableName nvarchar(128),
@RateType nvarchar(20)
)  
RETURNS float   
AS   
-- Returns the stock level for the product.  
BEGIN  

declare @startsize as numeric(27,6), @endsize as numeric(27,6), @starttime  as datetime, @endtime as datetime, @growthrate as float


select top 1 @startsize= reserved_mb , @starttime=CollectTime from [dbo].[disk_usages_size] 
where InstanceName=@InstanceName and DatabaseName=@Databasename and TableName = @TableName 
order by CollectTime

select top 1 @endsize= reserved_mb , @endtime=CollectTime from [dbo].[disk_usages_size] 
where InstanceName=@InstanceName and DatabaseName=@Databasename and TableName = @TableName 
order by CollectTime desc

--- growthrate =( @endsize - @startsize ) / DATEDIFF

IF UPPER(@RateType) ='DAY'
	SELECT @growthrate=( @endsize - @startsize ) / DATEDIFF(day, @starttime, @endtime)
ELSE
	IF UPPER(@RateType) ='WEEK'
		SELECT @growthrate=( @endsize - @startsize ) / DATEDIFF(week, @starttime, @endtime)
	ELSE
		IF UPPER(@RateType) ='MONTH'
			SELECT @growthrate=( @endsize - @startsize ) / DATEDIFF(month, @starttime, @endtime)
		ELSE
			IF UPPER(@RateType) ='YEAR'
				SELECT @growthrate=( @endsize - @startsize ) / DATEDIFF(month, @starttime, @endtime)
			ELSE
				SELECT @growthrate=NULL

RETURN round(@growthrate, 2,10)
END

