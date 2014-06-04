/*
Run this script on:

        10.200.0.24.AJA    -  This database will be modified

to synchronize it with:

        10.200.0.24.AJA_local

You are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 12/10/2013 3:05:56 PM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Creating index [IX_IIS_LogAnalysis] on [dbo].[IIS_LogAnalysis]'
GO
CREATE CLUSTERED INDEX [IX_IIS_LogAnalysis] ON [dbo].[IIS_LogAnalysis] ([HitDate], [URL])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_SearchSummary] on [dbo].[SearchSummary]'
GO
CREATE UNIQUE CLUSTERED INDEX [IX_SearchSummary] ON [dbo].[SearchSummary] ([UserDB], [UserID], [SearchName])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [FK_GeneAliases_Genes] on [dbo].[GeneAliases]'
GO
CREATE NONCLUSTERED INDEX [FK_GeneAliases_Genes] ON [dbo].[GeneAliases] ([GeneID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [idxLegacySubTopicID] on [dbo].[SubTopics]'
GO
CREATE NONCLUSTERED INDEX [idxLegacySubTopicID] ON [dbo].[SubTopics] ([LegacyID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [idxLegacyTopicID] on [dbo].[Topics]'
GO
CREATE NONCLUSTERED INDEX [idxLegacyTopicID] ON [dbo].[Topics] ([LegacyID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_SearchView] on [dbo].[SearchView]'
GO
CREATE NONCLUSTERED INDEX [IX_SearchView] ON [dbo].[SearchView] ([UserID], [SearchID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_UserCitations] on [dbo].[UserCitations]'
GO
CREATE CLUSTERED INDEX [IX_UserCitations] ON [dbo].[UserCitations] ([UserID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
