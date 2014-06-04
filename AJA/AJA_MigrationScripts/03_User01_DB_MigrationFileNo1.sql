-- User01 DB migration File No-- 1



---- [EditorialThreads]

--SET IDENTITY_INSERT dbo.[EditorialThreads] ON
--INSERT INTO dbo.[EditorialThreads] ([ThreadID]
--      ,[OriginalPubDate]
--      ,[ThreadName])
--SELECT [ThreadID]
--      ,[OriginalPubDate]
--      ,[ThreadName] FROM User_01.dbo.[EditorialThreads]
--SET IDENTITY_INSERT dbo.[EditorialThreads] OFF


---- [[ArticleSelections]]


--INSERT INTO dbo.[ArticleSelections] 
--SELECT * FROM User_01.dbo.[ArticleSelections]

---- [[[AtLargeEditors]]]


--INSERT INTO dbo.[AtLargeEditors] 
--SELECT * FROM User_01.dbo.[AtLargeEditors]


---- [[[[Banner]]]]


--INSERT INTO dbo.[Banner] 
--SELECT * FROM User_01.dbo.[Banner]


---- [[[[Campaigns]]]]

--SET IDENTITY_INSERT dbo.Campaigns ON
--INSERT INTO dbo.Campaigns ([CampaignID]
--      ,[Name]
--      ,[Owner]
--      ,[StartDate]
--      ,[EndDate])
--SELECT [CampaignID]
--      ,[Name]
--      ,[Owner]
--      ,[StartDate]
--      ,[EndDate] FROM User_01.dbo.Campaigns
--SET IDENTITY_INSERT dbo.Campaigns OFF



---- CampAuthorizations

--SET IDENTITY_INSERT dbo.CampAuthorizations ON
--INSERT INTO dbo.CampAuthorizations ([AuthID]
--      ,[CampaignID]
--      ,[AuthType])
--SELECT [AuthID]
--      ,[CampaignID]
--      ,[AuthType] FROM User_01.dbo.CampAuthorizations
--SET IDENTITY_INSERT dbo.CampAuthorizations OFF


---- [[[[CampCustomPages]]]]


--INSERT INTO dbo.CampCustomPages 
--SELECT * FROM User_01.dbo.CampCustomPages

---- [[[[[CampImportErrors]]]]]

--INSERT INTO dbo.[CampImportErrors] 
--SELECT * FROM User_01.dbo.[CampImportErrors]


---- [[[[[[CampImportFiles]]]]]]

--INSERT INTO dbo.[CampImportFiles] 
--SELECT * FROM User_01.dbo.[CampImportFiles]



---- [[[[[[[[CampProspects]]]]]]]]

--INSERT INTO dbo.[CampProspects] 
--SELECT * FROM User_01.dbo.[CampProspects]

---- [[[[[[[CampImportItem]]]]]]]

--INSERT INTO dbo.[CampImportItem] 
--SELECT * FROM User_01.dbo.[CampImportItem]

---- [[[[[[[CampImportItem]]]]]]]

--SET IDENTITY_INSERT dbo.[CampImportTemp] ON
--INSERT INTO dbo.[CampImportTemp] ([ItemID]
--      ,[MarID]
--      ,[UserName]
--      ,[Password]
--      ,[LastName]
--      ,[FirstName]
--      ,[Title]
--      ,[Country]
--      ,[PostalCode]
--      ,[Email]
--      ,[Specialty]
--      ,[Profession]
--      ,[PracticeEnvironment]) 
--SELECT [ItemID]
--      ,[MarID]
--      ,[UserName]
--      ,[Password]
--      ,[LastName]
--      ,[FirstName]
--      ,[Title]
--      ,[Country]
--      ,[PostalCode]
--      ,[Email]
--      ,[Specialty]
--      ,[Profession]
--      ,[PracticeEnvironment] FROM User_01.dbo.[CampImportTemp]
--SET IDENTITY_INSERT dbo.[CampImportTemp] OFF


---- [[Genes]]

--INSERT INTO dbo.[Genes] 
--SELECT * FROM GeneDB_Production.dbo.[Genes]

---- [CitationsGenes]

--INSERT INTO dbo.[CitationsGenes] 
--SELECT * FROM GeneDB_Production.dbo.[CitationsGenes]

---- [[[Tests]]]

--INSERT INTO dbo.[Tests]
--SELECT * FROM GeneDB_Production.dbo.[Tests]

---- [[[CitationsTests]]]

--INSERT INTO dbo.[CitationsTests]
--SELECT * FROM GeneDB_Production.dbo.[CitationsTests]


---- [ClickThru]

--INSERT INTO dbo.[ClickThru]
--SELECT * FROM User_01.dbo.[ClickThru]


---- [[CommentAuthors]]

--SET IDENTITY_INSERT dbo.[CommentAuthors] ON
--INSERT INTO dbo.[CommentAuthors] ([id]
--      ,[name]
--      ,[affiliations]
--      ,[email])
--SELECT [id]
--      ,[name]
--      ,[affiliations]
--      ,[email] FROM User_01.dbo.[CommentAuthors]
--SET IDENTITY_INSERT dbo.[CommentAuthors] OFF



---- [[CoreSponsorAds]]

--INSERT INTO dbo.[CoreSponsorAds]
--SELECT * FROM User_01.dbo.[CoreSponsorAds]

---- [[[Countries]]]

--INSERT INTO dbo.[Countries]
--SELECT * FROM User_01.dbo.[Countries]


---- [[[[Editions]]]]

--SET IDENTITY_INSERT dbo.[Editions] ON 
--INSERT INTO dbo.[Editions] ([EditionID]
--      ,[SpecialtyID]
--      ,[PubDate])
--SELECT [EditionID]
--      ,[SpecialtyID]
--      ,[PubDate] FROM User_01.dbo.[Editions]
--SET IDENTITY_INSERT dbo.[Editions] OFF

---- [EditorialComments]

--SET IDENTITY_INSERT dbo.[EditorialComments] ON
--INSERT INTO dbo.[EditorialComments]([CommentID]
--      ,[ThreadID]
--      ,[SortOrder]
--      ,[Comment])
--SELECT [CommentID]
--      ,[ThreadID]
--      ,[SortOrder]
--      ,[Comment] FROM User_01.dbo.[EditorialComments]
--SET IDENTITY_INSERT dbo.[EditorialComments] OFF


---- [[Specialties]]

--INSERT INTO dbo.Specialties
--SELECT * FROM User_01.dbo.Specialties


---- [[EditorsChoiceAuth]]
/*Commented by sandeep */
--INSERT INTO dbo.[EditorsChoiceAuth]
--SELECT * FROM User_01.dbo.[EditorsChoiceAuth]

---- [[[EditorTopics]]]

--INSERT INTO dbo.[EditorTopics]
--SELECT * FROM User_01.dbo.[EditorTopics]


---- [[[[RecipientLists]]]]

--SET IDENTITY_INSERT dbo.RecipientLists ON
--INSERT INTO dbo.RecipientLists ([ID]
--      ,[AdminID]
--      ,[Specialty]
--      ,[CreateDate]
--      ,[MailingDate]
--      ,[Type])
--SELECT [ID]
--      ,[AdminID]
--      ,[Specialty]
--      ,[CreateDate]
--      ,[MailingDate]
--      ,[Type] FROM User_01.dbo.RecipientLists
--SET IDENTITY_INSERT dbo.RecipientLists OFF


---- [[[[ExcludedRecipients]]]]

--INSERT INTO dbo.[ExcludedRecipients]
--SELECT * FROM User_01.dbo.[ExcludedRecipients]