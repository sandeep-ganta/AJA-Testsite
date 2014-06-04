---- User01 migrartion file no. 2


---- [GeneAliases]

--INSERT INTO dbo.[GeneAliases]
--SELECT * FROM GeneDB_Production.dbo.[GeneAliases]


---- [[[GeneComments]]]

--INSERT INTO dbo.[GeneComments]
--SELECT * FROM GeneDB_Production.dbo.[GeneComments]


---- [[GeneCommentCombos]]

--INSERT INTO dbo.[GeneCommentCombos]
--SELECT * FROM GeneDB_Production.dbo.[GeneCommentCombos]


---- [[[[HiddenSubTopics]]]]

--INSERT INTO dbo.[HiddenSubTopics]
--SELECT * FROM User_01.dbo.[HiddenSubTopics]

---- [[[[[HiddenTopics]]]]]

--INSERT INTO dbo.[HiddenTopics]
--SELECT * FROM User_01.dbo.[HiddenTopics]


---- [[[[[[IncludedRecipients]]]]]]

--INSERT INTO dbo.[IncludedRecipients]
--SELECT * FROM User_01.dbo.[IncludedRecipients]

---- [[[[[[[LinkOutAttributes]]]]]]]

--INSERT INTO dbo.[LinkOutAttributes]
--SELECT * FROM User_01.dbo.[LinkOutAttributes]


---- [[[[[[[[LinkOutControl]]]]]]]]

--INSERT INTO dbo.[LinkOutControl]
--SELECT * FROM User_01.dbo.[LinkOutControl]



---- [[[[[[[[[LinkOutLinks]]]]]]]]]

--SET IDENTITY_INSERT dbo.[LinkOutLinks] ON
--INSERT INTO dbo.[LinkOutLinks] ([LinkID]
--      ,[PMID]
--      ,[RequestType]
--      ,[URL]
--      ,[LinkName]
--      ,[ProviderID]
--      ,[LastUpdate])
--SELECT [LinkID]
--      ,[PMID]
--      ,[RequestType]
--      ,[URL]
--      ,[LinkName]
--      ,[ProviderID]
--      ,[LastUpdate] FROM User_01.dbo.[LinkOutLinks]
--SET IDENTITY_INSERT dbo.[LinkOutLinks] OFF



---- [[[[[[[[[LinkOutProviders]]]]]]]]]

--INSERT INTO dbo.[LinkOutProviders]
--SELECT * FROM User_01.dbo.[LinkOutProviders]


---- [LinkOutQueries]

--SET IDENTITY_INSERT dbo.[LinkOutQueries] ON
--INSERT INTO dbo.[LinkOutQueries]([RequestID]
--      ,[PMID]
--      ,[RequestType]
--      ,[RequestDate]
--      ,[UserID]
--      ,[IsCacheHit]
--      ,[CanQuery]
--      ,[IsComplete])
--SELECT [RequestID]
--      ,[PMID]
--      ,[RequestType]
--      ,[RequestDate]
--      ,[UserID]
--      ,[IsCacheHit]
--      ,[CanQuery]
--      ,[IsComplete] FROM User_01.dbo.[LinkOutQueries]
--SET IDENTITY_INSERT dbo.[LinkOutQueries] OFF


---- [LinkOutSubjects]

--INSERT INTO dbo.[LinkOutSubjects]
--SELECT * FROM User_01.dbo.[LinkOutSubjects]


---- [[NonMedlineCitations]]

--update User_01.dbo.NonMedlineCitations set ExpireDate = NULL  where ExpireDate like '%(ExpireDate)'

--INSERT INTO dbo.[NonMedlineCitations] ([PMID]
--      ,[ArticleTitle]
--      ,[AuthorList]
--      ,[Abstract]
--      ,[CitationDate]
--      ,[DisplayDate]
--      ,[DisplayNotes]
--      ,[ExpireDate]
--      ,[KeepDelete]
--      ,[MedlinePgn]
--      ,[MedlineTA]
--      ,[Nickname]
--      ,[SearchID]
--      ,[Status]
--      ,[StatusDisplay])
--SELECT [PMID]
--      ,[ArticleTitle]
--      ,[AuthorList]
--      ,[Abstract]
--      ,[CitationDate]
--      ,[DisplayDate]
--      ,[DisplayNotes]
--      ,CONVERT(DATETIME,CONVERT(VARCHAR,[ExpireDate]))
--      ,[KeepDelete]
--      ,[MedlinePgn]
--      ,[MedlineTA]
--      ,[Nickname]
--      ,[SearchID]
--      ,[Status]
--      ,[StatusDisplay]
--       FROM User_01.dbo.[NonMedlineCitations]



---- [[preLep_SponsorFolder]]

--INSERT INTO dbo.[preLep_SponsorFolder]
--SELECT * FROM User_01.dbo.[preLep_SponsorFolder]


---- [[[SeminalCitations]]]

--INSERT INTO dbo.[SeminalCitations]
--SELECT * FROM User_01.dbo.[SeminalCitations]



---- [[[[SpecialtyBanner]]]]

--INSERT INTO dbo.[SpecialtyBanner]
--SELECT * FROM User_01.dbo.[SpecialtyBanner]

---- [[[[[SponsorCitation]]]]]

--INSERT INTO dbo.[SponsorCitation]
--SELECT * FROM User_01.dbo.[SponsorCitation]


---- [SponsorCitations]

--INSERT INTO dbo.[SponsorCitations]
--SELECT * FROM User_01.dbo.[SponsorCitations]

---- [[SponsorFolder]]

--INSERT INTO dbo.[SponsorFolder]
--SELECT * FROM User_01.dbo.[SponsorFolder]



---- [[[SponsorFolderBackup20051014]]]

--INSERT INTO dbo.[SponsorFolderBackup20051014]
--SELECT * FROM User_01.dbo.[SponsorFolderBackup20051014]



---- [[[[SponsorTopics]]]]

--INSERT INTO dbo.[SponsorTopics]
--SELECT * FROM User_01.dbo.[SponsorTopics]



---- [[[[[SubTopics]]]]]

--SET IDENTITY_INSERT dbo.[SubTopics] ON
--INSERT INTO dbo.[SubTopics] ([SubTopicID]
--      ,[TopicID]
--      ,[Type]
--      ,[UserID]
--      ,[SubTopicName]
--      ,[createtime]
--      ,[LegacyID]
--      ,[Priority])
--SELECT [SubTopicID]
--      ,[TopicID]
--      ,[Type]
--      ,[UserID]
--      ,[SubTopicName]
--      ,[createtime]
--      ,[LegacyID]
--      ,[Priority] FROM User_01.dbo.[SubTopics]
--SET IDENTITY_INSERT dbo.[SubTopics] OFF
      
      
      
--      -- [[[[[TempUserTable]]]]]

--INSERT INTO dbo.[TempUserTable]
--SELECT * FROM User_01.dbo.[TempUserTable]

 
--  -- [[TestComments]]

--INSERT INTO dbo.[TestComments]
--SELECT * FROM GeneDB_Production.dbo.[TestComments]
 
-- -- [TestCommentCombos]

--INSERT INTO dbo.[TestCommentCombos]
--SELECT * FROM GeneDB_Production.dbo.[TestCommentCombos]



-- -- [[[Topics]]]
--SET IDENTITY_INSERT dbo.[Topics] ON
--INSERT INTO dbo.[Topics] ([TopicID]
--      ,[SpecialtyID]
--      ,[Type]
--      ,[UserID]
--      ,[TopicName]
--      ,[createtime]
--      ,[LegacyID])
--SELECT [TopicID]
--      ,[SpecialtyID]
--      ,[Type]
--      ,[UserID]
--      ,[TopicName]
--      ,[createtime]
--      ,[LegacyID] FROM User_01.dbo.[Topics]
--SET IDENTITY_INSERT dbo.[Topics] OFF