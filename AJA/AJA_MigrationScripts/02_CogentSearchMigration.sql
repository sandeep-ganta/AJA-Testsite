--INSERT INTO dbo.IIS_LogAnalysis 
--SELECT * FROM CogentSearch.dbo.IIS_LogAnalysis

--INSERT INTO dbo.[IIS_LogDistinctHitDateIP] 
--SELECT * FROM CogentSearch.dbo.[IIS_LogDistinctHitDateIP]

--INSERT INTO dbo.IIS_LogDistinctHitDateIP2 
--SELECT * FROM CogentSearch.dbo.IIS_LogDistinctHitDateIP2


--INSERT INTO dbo.[IIS_LogStage] 
--SELECT * FROM CogentSearch.dbo.[IIS_LogStage]

--SET IDENTITY_INSERT [dbo].[LogSearch] ON
--INSERT INTO [dbo].[LogSearch]([LogSearchID]
--      ,[RunTime]
--      ,[SearchID]
--      ,[firstName]
--      ,[lastName]
--      ,[SearchName]
--      ,[NewCitations]
--      ,[email]) 
--SELECT [LogSearchID]
--      ,[RunTime]
--      ,[SearchID]
--      ,[firstName]
--      ,[lastName]
--      ,[SearchName]
--      ,[NewCitations]
--      ,[email] FROM CogentSearch.dbo.[LogSearch]
--SET IDENTITY_INSERT [dbo].[LogSearch] OFF

--INSERT INTO dbo.[NoiseWord] 
--SELECT * FROM CogentSearch.dbo.[NoiseWord]

--INSERT INTO dbo.[SearchControl] 
--SELECT * FROM CogentSearch.dbo.[SearchControl]

--INSERT INTO dbo.[SearchDetails] 
--SELECT * FROM CogentSearch.dbo.[SearchDetails]

--INSERT INTO dbo.[SearchResults] 
--SELECT * FROM CogentSearch.dbo.[SearchResults]


--SET IDENTITY_INSERT [dbo].[SearchSummary] ON
--INSERT INTO dbo.[SearchSummary] ([SearchID]
--      ,[UserID]
--      ,[SearchName]
--      ,[RunOriginal]
--      ,[FoundOriginal]
--      ,[RunLast]
--      ,[FoundLast]
--      ,[PublicationTypeMask]
--      ,[LanguageMask]
--      ,[SpeciesMask]
--      ,[GenderMask]
--      ,[SubjectAgeMask]
--      ,[DateStart]
--      ,[DateEnd]
--      ,[AbstractMask]
--      ,[PaperAge]
--      ,[SearchSort]
--      ,[FastFullText]
--      ,[ShelfLife]
--      ,[Description]
--      ,[LastAutorunHits]
--      ,[LimitToUserLibrary]
--      ,[LastAutorunDate]
--      ,[ResultsFolder1]
--      ,[ResultsFolder2]
--      ,[Autosearch]
--      ,[UserDB]
--      ,[KeepDelete])
--SELECT [SearchID]
--      ,[UserID]
--      ,[SearchName]
--      ,[RunOriginal]
--      ,[FoundOriginal]
--      ,[RunLast]
--      ,[FoundLast]
--      ,[PublicationTypeMask]
--      ,[LanguageMask]
--      ,[SpeciesMask]
--      ,[GenderMask]
--      ,[SubjectAgeMask]
--      ,[DateStart]
--      ,[DateEnd]
--      ,[AbstractMask]
--      ,[PaperAge]
--      ,[SearchSort]
--      ,[FastFullText]
--      ,[ShelfLife]
--      ,[Description]
--      ,[LastAutorunHits]
--      ,[LimitToUserLibrary]
--      ,[LastAutorunDate]
--      ,[ResultsFolder1]
--      ,[ResultsFolder2]
--      ,[Autosearch]
--      ,[UserDB]
--      ,[KeepDelete] FROM CogentSearch.dbo.[SearchSummary]
--SET IDENTITY_INSERT [dbo].[SearchSummary] OFF


--INSERT INTO dbo.[SearchView] 
--SELECT * FROM CogentSearch.dbo.[SearchView]

