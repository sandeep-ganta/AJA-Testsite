
-- User01 Migration file no . 3


-- -- [[[TypePractice]]]

--INSERT INTO dbo.[TypePractice]
--SELECT * FROM User_01.dbo.[TypePractice]


-- -- [[[[UserCitations]]]]

--INSERT INTO dbo.[UserCitations]
--SELECT * FROM User_01.dbo.[UserCitations]


-- -- [[[[[UserCitationsSubtopicIDZeroBackup]]]]]

--INSERT INTO dbo.[UserCitationsSubtopicIDZeroBackup]
--SELECT * FROM User_01.dbo.[UserCitationsSubtopicIDZeroBackup]


-- -- [[[[[[UserComment]]]]]]

--INSERT INTO dbo.[UserComment]
--SELECT * FROM User_01.dbo.[UserComment]


-- -- [[[[[[[UserHasSponsorFolder]]]]]]]

--INSERT INTO dbo.[UserHasSponsorFolder]
--SELECT * FROM User_01.dbo.[UserHasSponsorFolder]



-- -- [UserHasSponsorTopic]

--INSERT INTO dbo.[UserHasSponsorTopic]
--SELECT * FROM User_01.dbo.[UserHasSponsorTopic]


-- -- [[UserPreferences]]
 
--SET IDENTITY_INSERT dbo.[UserPreferences] ON
--INSERT INTO dbo.[UserPreferences] ([ID]
--      ,[UserID]
--      ,[OrgFolderID]
--      ,[OrgFolderName]
--      ,[FunFolderID]
--      ,[FunFolderName]
--      ,[MedlineID]
--      ,[SearchString]
--      ,[DateAdded])
--SELECT [ID]
--      ,[UserID]
--      ,[OrgFolderID]
--      ,[OrgFolderName]
--      ,[FunFolderID]
--      ,[FunFolderName]
--      ,[MedlineID]
--      ,[SearchString]
--      ,[DateAdded] FROM User_01.dbo.[UserPreferences]
--SET IDENTITY_INSERT dbo.[UserPreferences] OFF



---- -- [[UserSpecialties]]

--INSERT INTO dbo.[UserSpecialties]
--SELECT * FROM User_01.dbo.[UserSpecialties]


-- -- [[.Survey]]
--SET IDENTITY_INSERT dbo.Survey ON
--INSERT INTO dbo.Survey ([ID]
--      ,[Name])
--SELECT [ID]
--      ,[Name] FROM User_01.dbo.Survey
--SET IDENTITY_INSERT dbo.Survey OFF




-- -- [[.Question]]
--SET IDENTITY_INSERT dbo.Question ON
--INSERT INTO dbo.Question ([ID]
--      ,[Sequence]
--      ,[Body]
--      ,[SurveyID])
--SELECT [ID]
--      ,[Sequence]
--      ,[Body]
--      ,[SurveyID] FROM User_01.dbo.Question
--SET IDENTITY_INSERT dbo.Question OFF


-- -- [[[Answer]]]

--SET IDENTITY_INSERT dbo.[Answer] ON
--INSERT INTO dbo.[Answer] ([ID]
--      ,[Sequence]
--      ,[QuestionID]
--      ,[Body])
--SELECT [ID]
--      ,[Sequence]
--      ,[QuestionID]
--      ,[Body] FROM User_01.dbo.[Answer]
--SET IDENTITY_INSERT dbo.[Answer] OFF


---- -- [[GenesArticles]]

--INSERT INTO dbo.GenesArticles
--SELECT * FROM GeneDB_Production.dbo.GenesArticles


---- -- [[ArticlesAuthors]]

--INSERT INTO dbo.[ArticlesAuthors]
--SELECT * FROM GeneDB_Production.dbo.[ArticlesAuthors]


---- -- [[[CitationRate]]]

--INSERT INTO dbo.[CitationRate]
--SELECT * FROM User_01.dbo.[CitationRate]

---- -- [[[[CommentAuthorReferences]]]]

--INSERT INTO dbo.[CommentAuthorReferences]
--SELECT * FROM User_01.dbo.[CommentAuthorReferences]

---- -- [[[[[doc]]]]]
--SET IDENTITY_INSERT dbo.[doc] ON
--INSERT INTO dbo.[doc] (id
--      ,[source]
--      ,[nm]
--      ,[last_updated_dt]
--      ,[auto_upd]
--      ,[clicks_count])
--SELECT id
--      ,[source]
--      ,[nm]
--      ,[last_updated_dt]
--      ,[auto_upd]
--      ,[clicks_count] FROM User_01.dbo.[doc]
--SET IDENTITY_INSERT dbo.[doc] OFF




---- -- [doc_in_subtopic]
--SET IDENTITY_INSERT dbo.[doc_in_subtopic] ON
--INSERT INTO dbo.[doc_in_subtopic] ([id]
--      ,[subtopic_id]
--      ,[doc_id])
--SELECT [id]
--      ,[subtopic_id]
--      ,[doc_id] FROM User_01.dbo.[doc_in_subtopic]
--SET IDENTITY_INSERT dbo.[doc_in_subtopic] OFF


---- -- [[doc_sched_opt]]

--INSERT INTO dbo.[doc_sched_opt]
--SELECT * FROM User_01.dbo.[doc_sched_opt]

---- -- [[[EditorialCommentsGenes]]]

--INSERT INTO dbo.[EditorialCommentsGenes]
--SELECT * FROM GeneDB_Production.dbo.[EditorialCommentsGenes]


---- -- [[[[EditorialCommentsTests]]]]

--INSERT INTO dbo.[EditorialCommentsTests]
--SELECT * FROM GeneDB_Production.dbo.[EditorialCommentsTests]


---- -- [GenesLinks]

--INSERT INTO dbo.[GenesLinks]
--SELECT * FROM GeneDB_Production.dbo.[GenesLinks]


---- -- [[OutOfRangeSeminal]]

--INSERT INTO dbo.[OutOfRangeSeminal]
--SELECT * FROM User_01.dbo.[OutOfRangeSeminal]



---- -- [[[OutOfRangeUser]]]

--INSERT INTO dbo.[OutOfRangeUser]
--SELECT * FROM User_01.dbo.[OutOfRangeUser]


---- -- [[[[PageTracking]]]]

--SET IDENTITY_INSERT dbo.[PageTracking] ON
--INSERT INTO dbo.[PageTracking] ([Id]
--      ,[UserId]
--      ,[URL]
--      ,[Arguments]
--      ,[DateStamp])
--SELECT [Id]
--      ,[UserId]
--      ,[URL]
--      ,[Arguments]
--      ,[DateStamp] FROM User_01.dbo.[PageTracking]
--SET IDENTITY_INSERT dbo.[PageTracking] OFF


---- -- [[[[[Results]]]]]


--INSERT INTO dbo.[Results] 
--SELECT * FROM User_01.dbo.[Results]


---- -- [SubTopicEditorRefs]


--INSERT INTO dbo.[SubTopicEditorRefs] 
--SELECT * FROM User_01.dbo.[SubTopicEditorRefs]

---- -- [[SubTopicReferences]]


--INSERT INTO dbo.[SubTopicReferences] 
--SELECT * FROM User_01.dbo.[SubTopicReferences]



---- -- [[[TestsGenes]]]

--INSERT INTO dbo.[TestsGenes] 
--SELECT * FROM GeneDB_Production.dbo.[TestsGenes]


---- -- [[[[TestsLinks]]]]

--INSERT INTO dbo.[TestsLinks] 
--SELECT * FROM GeneDB_Production.dbo.[TestsLinks]


---- -- [[[[[ThreadsGenes]]]]]

--INSERT INTO dbo.[ThreadsGenes] 
--SELECT * FROM GeneDB_Production.dbo.[ThreadsGenes]


---- -- [[[[[[ThreadsTests]]]]]]

--INSERT INTO dbo.[ThreadsTests] 
--SELECT * FROM GeneDB_Production.dbo.[ThreadsTests]



---- -- [[[[[[[UserCitationSurvey]]]]]]]

--INSERT INTO dbo.[UserCitationSurvey] 
--SELECT * FROM User_01.dbo.[UserCitationSurvey]


---- -- [[[[[[[[UserCommentGenes]]]]]]]]

--INSERT INTO dbo.[UserCommentGenes] 
--SELECT * FROM GeneDB_Production.dbo.[UserCommentGenes]

---- -- [UserCommentTests]

--INSERT INTO dbo.[UserCommentTests] 
--SELECT * FROM GeneDB_Production.dbo.[UserCommentTests]

----[CustomMailHeaders]

--INSERT INTO dbo.CustomMailHeader
--SELECT * FROM CogentAdmin.dbo.CustomMailHeader