/*
	Script to create a database for SQL Monitor schema (Tables, Views, SPs, etc)
*/


/*

	Create a database for SQL Monitor schema
*/
USE [master]
GO

/****** Object:  Database [DBA]    Script Date: 2017-10-05 2:24:04 PM ******/

if not exists (select name from sys.sysdatabases where name='DBA')
	CREATE DATABASE [DBA] ON  PRIMARY 
	( NAME = N'DBA', FILENAME = N'D:\Databases\DBA.mdf' , SIZE = 52224KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
	 LOG ON 
	( NAME = N'DBA_log', FILENAME = N'D:\Databases\DBA_log.ldf' , SIZE = 92864KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO


USE [DBA]
GO
/****** Object:  Table [dbo].[DW Running Query]    Script Date: 09/14/2017 12:03:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW Running Query](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User Name] [nvarchar](100) NULL,
	[Date and Time] [datetime2](7) NULL,
	[Running ID Batch] [int] NULL,
	[blocked] [int] NULL,
	[Database name] [nchar](100) NULL,
	[open trans] [int] NULL,
	[status] [nchar](30) NULL,
	[hostname] [nchar](100) NULL,
	[cmd] [nchar](100) NULL,
	[cpu] [int] NULL,
	[physica IO] [bigint] NULL,
	[CheckMemory Total Memory MB] [decimal](18, 0) NULL,
	[CheckMemory Perc Memory Free] [decimal](18, 0) NULL,
	[TOP 100 SQL Statement] [nvarchar](max) NULL,
	[TOP 100 Last execution time] [datetime] NULL,
	[TOP 100 Average IO] [bigint] NULL,
	[TOP 100 Average CPU Time (sec)] [bigint] NULL,
	[TOP 100 Average Elapsed Time (sec)] [bigint] NULL,
	[TOP 100 Execution Count] [bigint] NULL,
	[TOP 50 SQL Statement] [nvarchar](max) NULL,
	[TOP 50 Execution Count] [bigint] NULL,
	[TOP 50 Total Logical Reads] [bigint] NULL,
	[TOP 50 Last Logical Reads] [bigint] NULL,
	[TOP 50 Total Logical Writes] [bigint] NULL,
	[TOP 50 Last Logical Writes] [bigint] NULL,
	[TOP 50 Total Worker Time] [bigint] NULL,
	[TOP 50 Last Worker Time] [bigint] NULL,
	[TOP 50 Total Elapsed Time in S] [bigint] NULL,
	[TOP 50 Last Elapsed Time in S] [bigint] NULL,
	[TOP 50 Last Execution Time] [datetime] NULL,
 CONSTRAINT [PK_DW SQL Monitor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DW Running Counter]    Script Date: 09/14/2017 12:03:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DW Running Counter](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[User Name] [nvarchar](100) NULL,
	[Date and Time] [datetime2](7) NULL,
	[Running ID Batch] [int] NULL,
	[Locks Object Name] [nvarchar](50) NULL,
	[Locks Counter Name] [nvarchar](100) NULL,
	[Locks CNTR Value] [bigint] NULL,
	[Locks CNTR Type] [bigint] NULL,
	[Latches Object Name] [nvarchar](50) NULL,
	[Latches Counter Name] [nvarchar](100) NULL,
	[Latches CNTR Value] [bigint] NULL,
	[Latches CNTR Type] [bigint] NULL,
	[Memory Manager Object Name] [nvarchar](50) NULL,
	[Memory Manager Counter Name] [nvarchar](100) NULL,
	[Memory Manager CNTR Value] [bigint] NULL,
	[Memory Manager CNTR Type] [bigint] NULL,
	[SQL Statistics Object Name] [nvarchar](50) NULL,
	[SQL Statistics Counter Name] [nvarchar](100) NULL,
	[SQL Statistics CNTR Value] [bigint] NULL,
	[SQL Statistics CNTR Type] [bigint] NULL,
	[Transactions Object Name] [nvarchar](50) NULL,
	[Transactions Counter Name] [nvarchar](100) NULL,
	[Transactions CNTR Value] [bigint] NULL,
	[Transactions CNTR Type] [bigint] NULL,
	[Wait Statistics Object Name] [nvarchar](50) NULL,
	[Wait Statistics Counter Name] [nvarchar](100) NULL,
	[Wait Statistics CNTR Value] [bigint] NULL,
	[Wait Statistics CNTR Type] [bigint] NULL,
	[Workload Group Stats Object Name] [nvarchar](50) NULL,
	[Workload Group Stats Counter Name] [nvarchar](100) NULL,
	[Workload Group Stats CNTR Value] [bigint] NULL,
	[Workload Group Stats CNTR Type] [bigint] NULL,
	[Resource Pool Stats Object Name] [nvarchar](50) NULL,
	[Resource Pool Stats Counter Name] [nvarchar](100) NULL,
	[Resource Pool Stats CNTR Value] [bigint] NULL,
	[Resource Pool Stats CNTR Type] [bigint] NULL,
	[Buffer Manager Object Name] [nvarchar](50) NULL,
	[Buffer Manager Counter Name] [nvarchar](100) NULL,
	[Buffer Manager CNTR Value] [bigint] NULL,
	[Buffer Manager CNTR Type] [bigint] NULL,
	[General Statistics Object Name] [nvarchar](50) NULL,
	[General Statistics Counter Name] [nvarchar](100) NULL,
	[General Statistics CNTR Value] [bigint] NULL,
	[General Statistics CNTR Type] [bigint] NULL,
	[Access Methods Object Name] [nvarchar](50) NULL,
	[Access Methods Counter Name] [nvarchar](100) NULL,
	[Access Methods CNTR Value] [bigint] NULL,
	[Access Methods CNTR Type] [bigint] NULL,
 CONSTRAINT [PK_DW Running Counter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[Check_Memory]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Check_Memory]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE
     @CheckMemoryTotalMemoryMB decimal,  
     @CheckMemoryPercMemoryFree decimal
     
     DECLARE Check_Memory CURSOR FOR
SELECT available_physical_memory_kb/1024 as "Total Memory MB",
       available_physical_memory_kb/(total_physical_memory_kb*1.0)*100 AS "% Memory Free"
FROM sys.dm_os_sys_memory
OPEN Check_Memory
FETCH NEXT FROM Check_Memory
INTO @CheckMemoryTotalMemoryMB,@CheckMemoryPercMemoryFree

    INSERT INTO [SQLMonitor].[dbo].[DW Running Query]
    ([User Name]
    ,[Date and Time]
    ,[Running ID Batch]
    ,[CheckMemory Perc Memory Free]
    ,[CheckMemory Total Memory MB])
    VALUES(USER,
			SYSDATETIME(),
			1,
			@CheckMemoryTotalMemoryMB,
			@CheckMemoryPercMemoryFree)    

CLOSE Check_Memory
DEALLOCATE Check_Memory;
     
END
GO
/****** Object:  StoredProcedure [dbo].[Active_Process]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Active_Process]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   

	DECLARE
	  @blocked int,
	  @dname nchar(100),
	  @open_tran int,
	  @status nchar(30),
	  @hostname nchar(100),
	  @cmd nchar(100),
	  @cpu int,
	  @physicalIO bigint
	  DECLARE Active_Process CURSOR FOR
SELECT  blocked, d.name, open_tran, [status], hostname,
cmd, cpu,physical_io
FROM sys.sysprocesses p
INNER JOIN sys.databases d 
 on p.dbid=d.database_id 

OPEN Active_Process


FETCH NEXT FROM Active_Process
INTO @blocked,@dname,@open_tran,@status,@hostname,@cmd,@cpu,@physicalIO

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Query]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[blocked]
           ,[Database name]
           ,[open trans]
           ,[status]
           ,[hostname]
           ,[cmd]
           ,[cpu]
           ,[physica IO])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@blocked,
            @dname,
            @open_tran,
            @status,
            @hostname,
            @cmd,
            @cpu,
            @physicalIO)
                 
    FETCH NEXT FROM Active_Process
    INTO @blocked,@dname,@open_tran,@status,@hostname,@cmd,@cpu,@physicalIO
  END
CLOSE Active_Process;
DEALLOCATE Active_Process;
	  
	  END
GO
/****** Object:  View [dbo].[V_SQLMonitorQueryTOP50_EXPENSIVE]    Script Date: 09/14/2017 12:03:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_SQLMonitorQueryTOP50_EXPENSIVE]
AS
SELECT     ID, [User Name], [Date and Time], [Running ID Batch], blocked, [Database name], [open trans], status, hostname, cmd, cpu, [physica IO], 
                      [CheckMemory Total Memory MB], [CheckMemory Perc Memory Free], [TOP 100 SQL Statement], [TOP 100 Last execution time], [TOP 100 Average IO], 
                      [TOP 100 Average CPU Time (sec)], [TOP 100 Average Elapsed Time (sec)], [TOP 100 Execution Count], [TOP 50 SQL Statement], [TOP 50 Execution Count], 
                      [TOP 50 Total Logical Reads], [TOP 50 Last Logical Reads], [TOP 50 Total Logical Writes], [TOP 50 Last Logical Writes], [TOP 50 Total Worker Time], 
                      [TOP 50 Last Worker Time], [TOP 50 Total Elapsed Time in S], [TOP 50 Last Elapsed Time in S], [TOP 50 Last Execution Time], CONVERT(varchar, [Date and Time], 
                      105) AS [Running Date]
FROM         dbo.[DW Running Query]
WHERE     ([TOP 50 SQL Statement] <> N'') AND ([Date and Time] BETWEEN CONVERT(DATETIME, '2015-10-08 10:00:00', 102) AND CONVERT(DATETIME, '2015-10-08 12:00:00', 
                      102))
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[33] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DW Running Query"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 33
         Width = 284
         Width = 1500
         Width = 1500
         Width = 3015
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3570
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 945
         GroupBy = 1350
         Filter = 4830
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryTOP50_EXPENSIVE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryTOP50_EXPENSIVE'
GO
/****** Object:  View [dbo].[V_SQLMonitorQueryTOP100_POOR]    Script Date: 09/14/2017 12:03:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_SQLMonitorQueryTOP100_POOR]
AS
SELECT     ID, [User Name], [Date and Time], [Running ID Batch], blocked, [Database name], [open trans], status, hostname, cmd, cpu, [physica IO], 
                      [CheckMemory Total Memory MB], [CheckMemory Perc Memory Free], [TOP 100 SQL Statement], [TOP 100 Last execution time], [TOP 100 Average IO], 
                      [TOP 100 Average CPU Time (sec)], [TOP 100 Average Elapsed Time (sec)], [TOP 100 Execution Count], [TOP 50 SQL Statement], [TOP 50 Execution Count], 
                      [TOP 50 Total Logical Reads], [TOP 50 Last Logical Reads], [TOP 50 Total Logical Writes], [TOP 50 Last Logical Writes], [TOP 50 Total Worker Time], 
                      [TOP 50 Last Worker Time], [TOP 50 Total Elapsed Time in S], [TOP 50 Last Elapsed Time in S], [TOP 50 Last Execution Time], CONVERT(varchar, [Date and Time], 
                      105) AS [Running Date]
FROM         dbo.[DW Running Query]
WHERE     ([TOP 100 SQL Statement] <> N'')
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[38] 2[7] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DW Running Query"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 34
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 4170
         Width = 1500
         Width = 2910
         Width = 3030
         Width = 2310
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3780
         Alias = 1665
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 3780
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryTOP100_POOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryTOP100_POOR'
GO
/****** Object:  View [dbo].[V_SQLMonitorQueryCPUBenchMark]    Script Date: 09/14/2017 12:03:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_SQLMonitorQueryCPUBenchMark]
AS
SELECT     ID, [User Name], [Date and Time], [Running ID Batch], blocked, [Database name], [open trans], status, hostname, cmd, cpu, [physica IO], 
                      [CheckMemory Total Memory MB], [CheckMemory Perc Memory Free], [TOP 100 SQL Statement], [TOP 100 Last execution time], [TOP 100 Average IO], 
                      [TOP 100 Average CPU Time (sec)], [TOP 100 Average Elapsed Time (sec)], [TOP 100 Execution Count], [TOP 50 SQL Statement], [TOP 50 Execution Count], 
                      [TOP 50 Total Logical Reads], [TOP 50 Last Logical Reads], [TOP 50 Total Logical Writes], [TOP 50 Last Logical Writes], [TOP 50 Total Worker Time], 
                      [TOP 50 Last Worker Time], [TOP 50 Total Elapsed Time in S], [TOP 50 Last Elapsed Time in S], [TOP 50 Last Execution Time], CONVERT(varchar, [Date and Time], 
                      105) AS [Running Date]
FROM         dbo.[DW Running Query]
WHERE     (cpu > 0) AND (hostname <> N'')
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DW Running Query"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryCPUBenchMark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorQueryCPUBenchMark'
GO
/****** Object:  View [dbo].[V_SQLMonitorIndicators]    Script Date: 09/14/2017 12:03:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_SQLMonitorIndicators]
AS
SELECT     dbo.[DW Running Counter].*, CONVERT(varchar, [Date and Time], 105) AS [Running Date]
FROM         dbo.[DW Running Counter]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DW Running Counter"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 207
               Right = 295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 49
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2190
         Width = 1815
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2625
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorIndicators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorIndicators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_SQLMonitorIndicators'
GO
/****** Object:  StoredProcedure [dbo].[TOP_50]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery4.sql|7|0|C:\Users\sedpnav\AppData\Local\Temp\2\~vs649D.sql
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TOP_50]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 	DECLARE
  @top50sqlstatement nvarchar(max),
  @top50executioncount bigint,
  @top50totallogicalreads bigint,
  @top50lastlogicalreads bigint,
  @top50totallogicalwrites bigint,
  @top50lastlogicalwrites bigint,
  @top50totalworkertime bigint,
  @top50lastworkertime bigint,
  @top50totalelapsedtimeins bigint,
  @top50lastelapsedtimeins bigint,
  @top50lastexecutiontime datetime
  DECLARE TOP50 CURSOR FOR
SELECT TOP 50 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1) as 'SQL Statement',
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC -- CPU time
 
OPEN TOP50
FETCH NEXT FROM TOP50
INTO @top50sqlstatement ,
  @top50executioncount ,
  @top50totallogicalreads ,
  @top50lastlogicalreads ,
  @top50totallogicalwrites ,
  @top50lastlogicalwrites ,
  @top50totalworkertime ,
  @top50lastworkertime ,
  @top50totalelapsedtimeins ,
  @top50lastelapsedtimeins ,
  @top50lastexecutiontime 
  WHILE @@FETCH_STATUS = 0
   BEGIN
   INSERT INTO [SQLMonitor].[dbo].[DW Running Query]
    ([User Name]
	   ,[Date and Time]
	   ,[Running ID Batch]
	   ,[TOP 50 SQL Statement]
	   ,[TOP 50 Execution Count]
	   ,[TOP 50 Total Logical Reads]
	   ,[TOP 50 Last Logical Reads]
	   ,[TOP 50 Total Logical Writes]
	   ,[TOP 50 Last Logical Writes]
	   ,[TOP 50 Total Worker Time]
	   ,[TOP 50 Last Worker Time]
	   ,[TOP 50 Total Elapsed Time in S]
	   ,[TOP 50 Last Elapsed Time in S]
	   ,[TOP 50 Last Execution Time])
	   VALUES(USER,
	      SYSDATETIME(),
		  1,
		  @top50sqlstatement ,
		  @top50executioncount ,
		  @top50totallogicalreads ,
		  @top50lastlogicalreads ,
		  @top50totallogicalwrites ,
		  @top50lastlogicalwrites ,
		  @top50totalworkertime ,
		  @top50lastworkertime ,
		  @top50totalelapsedtimeins ,
		  @top50lastelapsedtimeins ,
		  @top50lastexecutiontime)
		  
		FETCH NEXT FROM TOP50
		INTO @top50sqlstatement ,
		  @top50executioncount ,
		  @top50totallogicalreads ,
		  @top50lastlogicalreads ,
		  @top50totallogicalwrites ,
		  @top50lastlogicalwrites ,
		  @top50totalworkertime ,
		  @top50lastworkertime ,
		  @top50totalelapsedtimeins ,
		  @top50lastelapsedtimeins ,
		  @top50lastexecutiontime 
END
CLOSE TOP50
DEALLOCATE TOP50
    
END
GO
/****** Object:  StoredProcedure [dbo].[TOP_100]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TOP_100]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE
	  @top100sqlstatement nvarchar(max),
	  @top100lastexecutiontime datetime,
	  @top100avarageIO bigint,
	  @top100avarageCPUTimesec bigint,
	  @top100avarageelapsedtimesec bigint,
	  @top100executioncount bigint


    DECLARE TOP100 CURSOR FOR
SELECT top 100 text as "SQL Statement",
   last_execution_time as "Last Execution Time",
   (total_logical_reads+total_physical_reads+total_logical_writes)/execution_count as [Average IO],
   (total_worker_time/execution_count)/1000000.0 as [Average CPU Time (sec)],
   (total_elapsed_time/execution_count)/1000000.0 as [Average Elapsed Time (sec)],
   execution_count as "Execution Count"
   --qp.query_plan as "Query Plan"
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
order by total_elapsed_time/execution_count desc

OPEN TOP100
FETCH NEXT FROM TOP100
INTO @top100sqlstatement,@top100lastexecutiontime,@top100avarageIO,
     @top100avarageCPUTimesec,@top100avarageelapsedtimesec,@top100executioncount
 WHILE @@FETCH_STATUS = 0
   BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Query]
    ([User Name]
    ,[Date and Time]
    ,[Running ID Batch]
    ,[TOP 100 SQL Statement]
    ,[TOP 100 Last execution time]
    ,[TOP 100 Average IO]
    ,[TOP 100 Average CPU Time (sec)]
    ,[TOP 100 Average Elapsed Time (sec)]
    ,[TOP 100 Execution Count])
    VALUES
		(USER,
			SYSDATETIME(),
			1,
			@top100sqlstatement,
			@top100lastexecutiontime,
			@top100avarageIO,
			@top100avarageCPUTimesec,
			@top100avarageelapsedtimesec,
			@top100executioncount)
 
	FETCH NEXT FROM TOP100
	INTO @top100sqlstatement,@top100lastexecutiontime,@top100avarageIO,
		 @top100avarageCPUTimesec,@top100avarageelapsedtimesec,@top100executioncount
	 END
CLOSE TOP100
DEALLOCATE TOP100;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Workload_Group_Stats]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Workload_Group_Stats]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Workload Group Stats%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Workload Group Stats Object Name]
           ,[Workload Group Stats Counter Name]
		   ,[Workload Group Stats CNTR Value]
		   ,[Workload Group Stats CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Wait_Statistics]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Wait_Statistics]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Wait Statistics%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Wait Statistics Object Name]
           ,[Wait Statistics Counter Name]
		   ,[Wait Statistics CNTR Value]
		   ,[Wait Statistics CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Transactions]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Transactions]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Server_Transactions%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Transactions Object Name]
           ,[Transactions Counter Name]
		   ,[Transactions CNTR Value]
		   ,[Transactions CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_SQL_Statistics]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_SQL_Statistics]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%SQL Statistics%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[SQL Statistics Object Name]
           ,[SQL Statistics Counter Name]
		   ,[SQL Statistics CNTR Value]
		   ,[SQL Statistics CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Resource_Pool_Stats]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Resource_Pool_Stats]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Resource Pool Stats%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Resource Pool Stats Object Name]
           ,[Resource Pool Stats Counter Name]
		   ,[Resource Pool Stats CNTR Value]
		   ,[Resource Pool Stats CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Memory_Manager]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Memory_Manager]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Memory Manager%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Memory Manager Object Name]
           ,[Memory Manager Counter Name]
		   ,[Memory Manager CNTR Value]
		   ,[Memory Manager CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Locks]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Locks]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Locks%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Locks Object Name]
           ,[Locks Counter Name]
		   ,[Locks CNTR Value]
		   ,[Locks CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Latches]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Latches]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Latches%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Latches Object Name]
           ,[Latches Counter Name]
		   ,[Latches CNTR Value]
		   ,[Latches CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_General_Statistics]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_General_Statistics]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%General Statistics%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[General Statistics Object Name]
           ,[General Statistics Counter Name]
		   ,[General Statistics CNTR Value]
		   ,[General Statistics CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Buffer_Manager]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Buffer_Manager]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Buffer Manager%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Buffer Manager Object Name]
           ,[Buffer Manager Counter Name]
		   ,[Buffer Manager CNTR Value]
		   ,[Buffer Manager CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLServer_Access_Methods]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SQLServer_Access_Methods]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE
     @object_name nchar,
	 @counter_name nchar,
	 @cntr_value bigint,
	 @cntr_type int	

	 DECLARE MyCursor CURSOR FOR
		SELECT [object_name], counter_name,cntr_value,cntr_type
		FROM sys.dm_os_performance_counters
		WHERE cntr_value > 0 and
		[object_name] like '%Access Methods%'
OPEN MyCursor
FETCH NEXT FROM MyCursor
INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 	

WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO [SQLMonitor].[dbo].[DW Running Counter]
           ([User Name]
           ,[Date and Time]
           ,[Running ID Batch]
           ,[Access Methods Object Name]
           ,[Access Methods Counter Name]
		   ,[Access Methods CNTR Value]
		   ,[Access Methods CNTR Type])
     VALUES(USER,
			SYSDATETIME(),
			1,
			@object_name ,
			@counter_name ,
			@cntr_value ,
			@cntr_type )
                 
    FETCH NEXT FROM MyCursor
    INTO @object_name ,
	 @counter_name ,
	 @cntr_value ,
	 @cntr_type 
  END
CLOSE MyCursor;
DEALLOCATE MyCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[SQLMonitorFULL_QueryMonitor]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SQLMonitorFULL_QueryMonitor]
AS
BEGIN
	-- Monitor Active Process - Monitring SQL Server Perofmance Indicators
	exec Active_Process

	-- Monitor Active Process - Monitring SQL Server Memory 
	exec Check_Memory


	-- Monitor Active Queries (More expensives)
	exec TOP_100

	-- Monitor Active Queries (More expensives resources)
	exec TOP_50

END
GO
/****** Object:  StoredProcedure [dbo].[SQLMonitorFULL_Indicators]    Script Date: 09/14/2017 12:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SQLMonitorFULL_Indicators] 	
AS
BEGIN
	exec SQLServer_Memory_Manager

	exec SQLServer_SQL_Statistics

	exec SQLServer_Access_Methods

	exec SQLServer_Buffer_Manager

	exec SQLServer_General_Statistics

	exec SQLServer_Latches

	exec SQLServer_Locks

	exec SQLServer_Wait_Statistics

	exec SQLServer_Workload_Group_Stats

END
GO
