USE [DWH_LAB2]
GO
/****** Object:  Schema [CONTENT]    Script Date: 01/12/2024 2:21:05 ******/
CREATE SCHEMA [CONTENT]
GO
/****** Object:  Schema [ML]    Script Date: 01/12/2024 2:21:05 ******/
CREATE SCHEMA [ML]
GO
/****** Object:  Table [CONTENT].[DimClarity]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTENT].[DimClarity](
	[clarityID] [int] IDENTITY(1,1) NOT NULL,
	[clarity] [nvarchar](15) NULL,
 CONSTRAINT [PK_DimClarity] PRIMARY KEY CLUSTERED 
(
	[clarityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CONTENT].[DimColor]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTENT].[DimColor](
	[colorID] [int] IDENTITY(1,1) NOT NULL,
	[color] [nvarchar](5) NULL,
 CONSTRAINT [PK_DimColor] PRIMARY KEY CLUSTERED 
(
	[colorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CONTENT].[DimCut]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTENT].[DimCut](
	[cutID] [int] IDENTITY(1,1) NOT NULL,
	[cut] [nvarchar](20) NULL,
 CONSTRAINT [PK_DimCut] PRIMARY KEY CLUSTERED 
(
	[cutID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CONTENT].[FactDiamonds]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CONTENT].[FactDiamonds](
	[cutID] [int] NOT NULL,
	[colorID] [int] NOT NULL,
	[clarityID] [int] NOT NULL,
	[carat] [float] NULL,
	[depth] [float] NULL,
	[table] [float] NULL,
	[price] [float] NULL,
	[x] [float] NULL,
	[y] [float] NULL,
	[z] [float] NULL,
	[person] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [CONTENT].[vw_FactDiamonds]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [CONTENT].[vw_FactDiamonds] 
AS 

	SELECT CU.[cut] 
	,CO.[color] 
	,CA.[clarity] 
	,D.[carat] 
	,D.[depth] 
	,D.[table] 
	,D.[price] 
	,D.[x] 
	,D.[y] 
	,D.[z] 
	,D.[person] 
	FROM [CONTENT].[FactDiamonds] D 
	INNER JOIN [CONTENT].[DimClarity] CA ON D.[clarityID] = CA.[clarityID] 
	  INNER JOIN [CONTENT].[DimColor] CO ON D.[colorID] = CO.[colorID] 
	  INNER JOIN [CONTENT].[DimCut] CU  ON D.[cutID] = CU.[cutID] 
GO
/****** Object:  Table [ML].[Entrenamiento]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ML].[Entrenamiento](
	[person] [int] NULL,
	[origen] [nvarchar](10) NULL,
	[glosa] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  View [ML].[vw_Data]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [ML].[vw_Data] 
AS 
 
SELECT [cut] 
      ,[color] 
      ,[clarity] 
      ,[carat] 
      ,[depth] 
      ,[table] 
      ,[x] 
      ,[y] 
      ,[z] 
      ,E.[person] 
  FROM [DWH_LAB2].[CONTENT].[vw_FactDiamonds] FD 
  INNER JOIN ML.Entrenamiento E ON FD.person = E.person 
 
  WHERE E.glosa = 'test 1' 
 AND origen = 'validation' 
GO
/****** Object:  Table [dbo].[DIM_AUDIT]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIM_AUDIT](
	[AuditKey] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](100) NULL,
	[PkgName] [nvarchar](50) NOT NULL,
	[PkgGUID] [uniqueidentifier] NULL,
	[ExecStartDT] [datetime] NOT NULL,
	[ExecStopDT] [datetime] NULL,
	[ExecutionInstanceGUID] [uniqueidentifier] NULL,
	[ExtractRowCnt] [bigint] NULL,
	[TableInitialRowCnt] [bigint] NULL,
	[TableFinalRowCnt] [bigint] NULL,
	[SuccessfulProcessingInd] [nchar](1) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PATH_FILE]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PATH_FILE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NEGOCIO] [nvarchar](50) NULL,
	[RUTA] [nvarchar](500) NULL,
	[TableName] [nvarchar](500) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [ML].[PICKLE]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ML].[PICKLE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FILE_NAME] [nvarchar](255) NOT NULL,
	[FILE_PICKLE] [varbinary](max) NOT NULL,
	[FECHA] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [ML].[Prediction]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ML].[Prediction](
	[person] [int] NOT NULL,
	[forecast] [float] NOT NULL,
	[model] [nvarchar](255) NOT NULL,
	[fecha] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIM_AUDIT] ADD  DEFAULT ('Unknown') FOR [TableName]
GO
ALTER TABLE [dbo].[DIM_AUDIT] ADD  DEFAULT ('Unknown') FOR [PkgName]
GO
ALTER TABLE [dbo].[DIM_AUDIT] ADD  DEFAULT (getdate()) FOR [ExecStartDT]
GO
ALTER TABLE [dbo].[DIM_AUDIT] ADD  DEFAULT ('N') FOR [SuccessfulProcessingInd]
GO
ALTER TABLE [ML].[PICKLE] ADD  CONSTRAINT [D_FechaSistema]  DEFAULT (getdate()) FOR [FECHA]
GO
ALTER TABLE [CONTENT].[FactDiamonds]  WITH CHECK ADD  CONSTRAINT [FK_DimClarity_clarityID] FOREIGN KEY([clarityID])
REFERENCES [CONTENT].[DimClarity] ([clarityID])
GO
ALTER TABLE [CONTENT].[FactDiamonds] CHECK CONSTRAINT [FK_DimClarity_clarityID]
GO
ALTER TABLE [CONTENT].[FactDiamonds]  WITH CHECK ADD  CONSTRAINT [FK_DimColor_colorID] FOREIGN KEY([colorID])
REFERENCES [CONTENT].[DimColor] ([colorID])
GO
ALTER TABLE [CONTENT].[FactDiamonds] CHECK CONSTRAINT [FK_DimColor_colorID]
GO
ALTER TABLE [CONTENT].[FactDiamonds]  WITH CHECK ADD  CONSTRAINT [FK_DimCut_cutID] FOREIGN KEY([cutID])
REFERENCES [CONTENT].[DimCut] ([cutID])
GO
ALTER TABLE [CONTENT].[FactDiamonds] CHECK CONSTRAINT [FK_DimCut_cutID]
GO
/****** Object:  StoredProcedure [CONTENT].[sp_DimClarity]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CONTENT].[sp_DimClarity] 
AS 
BEGIN 
    MERGE [CONTENT].[DimClarity] AS target 
    USING ( 
        SELECT DISTINCT [clarity]  
        FROM [STAGE_LAB2].[CONTENT].[StageDiamonds] 
    ) AS source ([clarity]) 
    ON target.[clarity] = source.[clarity] 
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT ([clarity]) 
        VALUES (source.[clarity]); 
END 
GO
/****** Object:  StoredProcedure [CONTENT].[sp_DimColor]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CONTENT].[sp_DimColor] 
AS 
BEGIN 
    MERGE [CONTENT].[DimColor] AS target 
    USING ( 
        SELECT DISTINCT [color]  
        FROM [STAGE_LAB2].[CONTENT].[StageDiamonds] 
    ) AS source ([color]) 
    ON target.[color] = source.[color] 
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT ([color]) 
        VALUES (source.[color]); 
END 
GO
/****** Object:  StoredProcedure [CONTENT].[sp_DimCut]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CONTENT].[sp_DimCut] 
AS 
BEGIN 
    MERGE [CONTENT].[DimCut] AS target 
    USING ( 
        SELECT DISTINCT [cut]  
        FROM [STAGE_LAB2].[CONTENT].[StageDiamonds] 
    ) AS source ([cut]) 
    ON target.[cut] = source.[cut] 
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT ([cut]) 
        VALUES (source.[cut]); 
END 
GO
/****** Object:  StoredProcedure [CONTENT].[sp_FactDiamonds]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [CONTENT].[sp_FactDiamonds] 
AS 
 
INSERT INTO [CONTENT].[FactDiamonds] 
           ([cutID] 
           ,[colorID] 
           ,[clarityID] 
           ,[carat] 
           ,[depth] 
           ,[table] 
           ,[price] 
           ,[x] 
           ,[y] 
           ,[z] 
     ,[person]) 
 
SELECT ISNULL([cutID], -1) AS [cutID] 
      ,ISNULL([colorID], -1) AS [colorID] 
      ,ISNULL([clarityID], -1) AS [clarityID] 
   ,[carat] 
      ,[depth] 
      ,[table] 
      ,[price] 
      ,[x] 
      ,[y] 
      ,[z] 
      ,[person] 
 
  FROM [STAGE_LAB2].[CONTENT].[StageDiamonds] D 
  LEFT JOIN [CONTENT].[DimClarity] CA ON D.[clarity] = CA.[clarity] 
  LEFT JOIN [CONTENT].[DimColor] CO ON D.[color] = CO.[color] 
  LEFT JOIN [CONTENT].[DimCut] CU  ON D.[cut] = CU.[cut]
GO
/****** Object:  StoredProcedure [ML].[sp_PredictionDiamonds]    Script Date: 01/12/2024 2:21:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ML].[sp_PredictionDiamonds] 
@file_name NVARCHAR(100), 
@table NVARCHAR(100) 
AS 
BEGIN 
DECLARE @json sql_variant 
DECLARE @execution_id bigint 
DECLARE @var1 smallint = 1 
SET @json = N'{"file_name": "' + @file_name + '", "table": "' + @table + '"}'; 
EXEC [SSISDB].[catalog].[create_execution]  
@package_name = N'Prediction.dtsx' 
, @execution_id = @execution_id OUTPUT 
, @folder_name = N'LABORATORIO2' 
, @project_name = N'Laboratorio2' 
, @use32bitruntime = False 
, @reference_id = Null 
, @runinscaleout = False 
EXEC [SSISDB].[catalog].[set_execution_parameter_value]  
@execution_id 
, @object_type = 30 
, @parameter_name = N'input' 
, @parameter_value = @json 
EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
@execution_id 
, @object_type = 50 
, @parameter_name = N'LOGGING_LEVEL' 
, @parameter_value = @var1 
EXEC [SSISDB].[catalog].[start_execution] @execution_id 
END 
GO
