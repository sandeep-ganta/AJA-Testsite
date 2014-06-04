USE [Cogent3-PostMayWeekly]
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineBuildLookup-Instance]    Script Date: 11/22/2013 04:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[ap_LoadMedLineBuildLookup-Instance_MVC]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
	DECLARE @RecCount int




	INSERT INTO [Cogent3-PostMayWeekly].dbo.xCollectiveName(CollectiveName)
	SELECT DISTINCT CollectiveName
	FROM xCollectiveName 
	WHERE CollectiveName NOT IN
	   (SELECT CollectiveName
	   FROM xCollectiveName) AND
	CollectiveName IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCollectiveName', @RecCount, 0)		
	
	
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xChemicalName(ChemicalName)
	SELECT DISTINCT ChemicalName
	FROM xChemicalName
	WHERE ChemicalName NOT IN
	   (SELECT ChemicalName
	   FROM [Cogent3-PostMayWeekly].dbo.xChemicalName)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalName', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xChemicalRegistry(ChemicalRegistry)
	SELECT DISTINCT ChemicalRegistry
	FROM xChemicalRegistry
	WHERE ChemicalRegistry NOT IN
	   (SELECT ChemicalRegistry
	   FROM [Cogent3-PostMayWeekly].dbo.xChemicalRegistry)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalRegistry', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xCommentType(CommentType)
	SELECT DISTINCT CommentType
	FROM xCommentType
	WHERE CommentType NOT IN
	   (SELECT CommentType
	   FROM [Cogent3-PostMayWeekly].dbo.xCommentType)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCommentType', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xCountry(CountryName)
	SELECT DISTINCT CountryName
	FROM xCountry
	WHERE CountryName NOT IN
	   (SELECT CountryName
	   FROM [Cogent3-PostMayWeekly].dbo.xCountry)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCountry', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xDataBank(DataBankName)
	SELECT DISTINCT DataBankName
	FROM xDataBank
	WHERE DataBankName NOT IN
	   (SELECT DataBankName
	   FROM [Cogent3-PostMayWeekly].dbo.xDataBank)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xDataBank', @RecCount, 0)		

	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xGrantAcronym(Acronym)
	SELECT DISTINCT Acronym
	FROM xGrantAcronym
	WHERE Acronym NOT IN
	   (SELECT Acronym
	   FROM [Cogent3-PostMayWeekly].dbo.xGrantAcronym)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAcronym', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xGrantAgency(Agency)
	SELECT DISTINCT Agency
	FROM xGrantAgency
	WHERE Agency NOT IN
	   (SELECT Agency
	   FROM [Cogent3-PostMayWeekly].dbo.xGrantAgency)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAgency', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xGrantID(GrantID)
	SELECT DISTINCT GrantID
	FROM xGrantID
	WHERE GrantID NOT IN
	   (SELECT GrantID
	   FROM [Cogent3-PostMayWeekly].dbo.xGrantID)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantID', @RecCount, 0)		

	INSERT INTO [Cogent3-PostMayWeekly].dbo.xISSN(ISSN)
	SELECT DISTINCT ISSN
	FROM xISSN
	WHERE ISSN NOT IN
	   (SELECT ISSN
	   FROM [Cogent3-PostMayWeekly].dbo.xISSN) AND
		ISSN IS NOT NULL
	
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xKeyword(Keyword)
	SELECT DISTINCT Keyword
	FROM xKeyword
	WHERE Keyword NOT IN
	   (SELECT Keyword
	   FROM [Cogent3-PostMayWeekly].dbo.xKeyword)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xKeyword', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xLanguage(Lang)
	SELECT DISTINCT Lang
	FROM xLanguage
	WHERE Lang NOT IN
	   (SELECT Lang
	   FROM [Cogent3-PostMayWeekly].dbo.xLanguage)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xLanguage', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xLastName(LastName)
	SELECT DISTINCT LastName
	FROM xLastName
	WHERE LastName NOT IN
	   (SELECT LastName
	   FROM [Cogent3-PostMayWeekly].dbo.xLastName) AND LastName IS NOT NULL
	
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xMedlineTA(MedlineTA)
	SELECT DISTINCT MedlineTA
	FROM xMedlineTA
	WHERE MedlineTA NOT IN
	   (SELECT MedlineTA
	   FROM [Cogent3-PostMayWeekly].dbo.xMedlineTA)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xMedlineTA', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xPublicationType(PublicationType)
	SELECT DISTINCT PublicationType
	FROM xPublicationType
	WHERE PublicationType NOT IN
	   (SELECT PublicationType
	   FROM [Cogent3-PostMayWeekly].dbo.xPublicationType)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xPublicationType', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xSpaceFlightMission(SpaceFlightMission)
	SELECT DISTINCT SpaceFlightMission
	FROM xSpaceFlightMission
	WHERE SpaceFlightMission NOT IN
	   (SELECT SpaceFlightMission
	   FROM [Cogent3-PostMayWeekly].dbo.xSpaceFlightMission)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSpaceFlightMission', @RecCount, 0)		
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xOwner(Owner)
	SELECT DISTINCT Owner
	FROM xOwner
	WHERE Owner NOT IN
	   (SELECT Owner
	   FROM [Cogent3-PostMayWeekly].dbo.xOwner)

	
	
	INSERT INTO [Cogent3-PostMayWeekly].dbo.xSuffix(Suffix)
	SELECT DISTINCT Suffix
	FROM xSuffix
	WHERE Suffix NOT IN
	   (SELECT Suffix
	   FROM [Cogent3-PostMayWeekly].dbo.xSuffix)
	SET @RecCount = @@ROWCOUNT	
	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSuffix', @RecCount, 0)

	INSERT INTO [Cogent3-PostMayWeekly].dbo.xCitedMedium(CitedMedium)
	SELECT DISTINCT CitedMedium
	FROM xCitedMedium 
	WHERE CitedMedium NOT IN
	   (SELECT CitedMedium
	   FROM [Cogent3-PostMayWeekly].dbo.xCitedMedium)
	SET @RecCount = @@ROWCOUNT	
	
INSERT INTO [Cogent3-PostMayWeekly].dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCitedMedium2', @RecCount, 0)



		USE [Cogent3-PostMayWeekly]
GO
/****** Object:  StoredProcedure [dbo].[UpdateLookUpID]    Script Date: 11/22/2013 04:45:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[UpdateLookUpID_MVC]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    

--- IAuthor LastNameID ,SuffixID , CollectiveNameID----
UPDATE iAuthor 
SET LastNameID = XB.LastNameID FROM iAuthor ,XlastName x,[Cogent3-PostMayWeekly].dbo.XlastName xB
WHERE x.LastNameID = iAuthor.LastNameID and  x.LastName = xB.LastName

UPDATE iAuthor 
SET SuffixID = xs.SuffixID FROM iAuthor ,xSuffix x,[Cogent3-PostMayWeekly].dbo.xSuffix xs
WHERE x.SuffixID = iAuthor.SuffixID and  x.Suffix = xs.Suffix

UPDATE iAuthor 
SET CollectiveNameID = XB.CollectiveNameID from iAuthor ,xCollectiveName x,[Cogent3-PostMayWeekly].dbo.xCollectiveName xB
WHERE x.CollectiveNameID = iAuthor.CollectiveNameID and  x.CollectiveName = xB.CollectiveName

--- iArticle  MedLineTAID , ISSNID , PubModelID---
UPDATE iArticle 
SET MedLineTAID = XB.MedlineTAID from iArticle ,xMedlineTA x,[Cogent3-PostMayWeekly].dbo.xMedlineTA xB
WHERE x.MedlineTAID = iArticle.MedLineTAID and  x.MedlineTA = xB.MedlineTA

UPDATE iArticle 
SET ISSNID = XB.ISSNID from iArticle ,xISSN x,[Cogent3-PostMayWeekly].dbo.xISSN xB
WHERE x.ISSNID = iArticle.ISSNID and  x.ISSN= xB.ISSN

UPDATE iArticle 
SET PubModelID = XB.PubModelID from iArticle ,xPubModel x,[Cogent3-PostMayWeekly].dbo.xPubModel xB
WHERE x.PubModelID= iArticle.PubModelID and  x.PubModel = xB.PubModel

--- iAccession  DataBankID---
UPDATE iAccession 
SET DataBankID = XB.DataBankID from iAccession ,xDataBank x,[Cogent3-PostMayWeekly].dbo.xDataBank xB
WHERE x.DataBankID = iAccession.DataBankID and  x.DataBankName= xB.DataBankName

--- iChemical  ChemicalNameID ChemicalRegistryID ---
UPDATE iChemical 
SET ChemicalNameID = XB.ChemicalNameID from iChemical ,xChemicalName x,[Cogent3-PostMayWeekly].dbo.xChemicalName xB
WHERE x.ChemicalNameID = iChemical.ChemicalNameID and  x.ChemicalName= xB.ChemicalName

UPDATE iChemical 
SET ChemicalRegistryID = XB.ChemicalRegistryID from iChemical ,xChemicalRegistry x,[Cogent3-PostMayWeekly].dbo.xChemicalRegistry xB
WHERE x.ChemicalRegistryID = iChemical.ChemicalRegistryID and  x.ChemicalRegistry= xB.ChemicalRegistry

-- icitation xcitationstatus
UPDATE iCitation
SET StatusID = XB.StatusID FROM iCitation ,xCitationStatus x,[Cogent3-PostMayWeekly].dbo.xCitationStatus xB
WHERE x.StatusID = iCitation.StatusID and x.Status = xB.Status


UPDATE iCitation
SET OwnerID = XB.OwnerID FROM iCitation ,xOwner x,[Cogent3-PostMayWeekly].dbo.xOwner xB
WHERE x.OwnerID = iCitation.OwnerID and x.Owner = xB.Owner

-- ilanguage xlanguage
UPDATE iLanguage
SET LanguageID = XB.LanguageID FROM iLanguage ,xLanguage x,[Cogent3-PostMayWeekly].dbo.xLanguage xB
WHERE x.LanguageID = iLanguage.LanguageID and x.Lang = xB.Lang

-- ipublication xPublicationType
UPDATE iPublicationType
SET PublicationTypeID = XB.PublicationTypeID FROM iPublicationType ,xPublicationType x,[Cogent3-PostMayWeekly].dbo.xPublicationType xB
WHERE x.PublicationTypeID = iPublicationType.PublicationTypeID and x.PublicationType = xB.PublicationType

---- ikeyword xowner, xkeyword
UPDATE iKeyword
SET OwnerID = XB.OwnerID FROM iKeyword ,xOwner x,[Cogent3-PostMayWeekly].dbo.xOwner xB
WHERE x.OwnerID = iKeyword.OwnerID and x.Owner = xB.Owner

UPDATE iKeyword
SET KeywordID = XB.KeywordID FROM iKeyword ,xKeyword x,[Cogent3-PostMayWeekly].dbo.xKeyword xB
WHERE x.KeywordID = iKeyword.KeywordID and x.Keyword = xB.Keyword

--- ikeywordlist xowner
UPDATE iKeywordList
SET OwnerID = XB.OwnerID FROM iKeywordList ,xOwner x,[Cogent3-PostMayWeekly].dbo.xOwner xB
WHERE x.OwnerID = iKeywordList.OwnerID and x.Owner = xB.Owner

--icomment xcommentType
UPDATE iComment
SET CommentTypeID = XB.CommentTypeID FROM iComment ,xCommentType x,[Cogent3-PostMayWeekly].dbo.xCommentType xB
WHERE x.CommentTypeID = iComment.CommentTypeID and x.CommentType = xB.CommentType

-- iGrant xGrantID,xGrantAcronym,xGrantAgency
UPDATE iGrant
SET GrantIDID = XB.GrantIDID FROM iGrant ,xGrantID x,[Cogent3-PostMayWeekly].dbo.xGrantID xB
WHERE x.GrantIDID = iGrant.GrantIDID and x.GrantID = xB.GrantID

UPDATE iGrant
SET AcronymID = XB.AcronymID FROM iGrant ,xGrantAcronym x,[Cogent3-PostMayWeekly].dbo.xGrantAcronym xB
WHERE x.AcronymID = iGrant.AcronymID and x.Acronym = xB.Acronym


UPDATE iGrant
SET AgencyID = XB.AgencyID FROM iGrant ,xGrantAgency x,[Cogent3-PostMayWeekly].dbo.xGrantAgency xB
WHERE x.AgencyID = iGrant.AgencyID and x.Agency = xB.Agency

END



USE [Cogent3-PostMayWeekly]
GO
/****** Object:  StoredProcedure [dbo].[Merge_MedLineData]    Script Date: 11/22/2013 04:50:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Merge_MedLineData_MVC]
  @LogSet 			varchar(50)
	
AS
  SET NOCOUNT ON
	DECLARE @RecCount int
  DECLARE @RunType	char(1)
  DECLARE @DeleteCount int
  SET @RunType = 'i'
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Start BuildSearch ',0,0)		
--**************************************************************************
-- Remove existing citations that match records in the input file ----------------
--**************************************************************************
	SET @DeleteCount = 0 
	CREATE TABLE #e (
		PMID int 					NOT NULL PRIMARY KEY
	) 
		INSERT INTO #e
		SELECT c.PMID
		  FROM iCitation c with(nolock)

		SET @RecCount = @@ROWCOUNT	
		SET @DeleteCount = @RecCount
		INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Duplicate PMID ',0,@RecCount)	
			
		INSERT INTO #e
		SELECT distinct PMID
		  FROM DeleteCitation where PMID not in (select PMID from #e)
		  
		SET @RecCount = @@ROWCOUNT	
		SET @DeleteCount = @DeleteCount + @RecCount

  IF @DeleteCount > 0
		BEGIN
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iAccession i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAccession',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iArticle i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticle',0,@RecCount)
		
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iArticleDate i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticleDate',0,@RecCount)
		
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iWide i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWide',0,@RecCount)
		
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iWideNew i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWideNew',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iAuthor i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAuthor',0,@RecCount)
		
			
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iChemical i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iChemical',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iCitation i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitation',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iCitationMeSHHeading i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHHeading',0,@RecCount)
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iCitationMeSHQualifier i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHQualifier',0,@RecCount)		
	
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iCitationSubset i INNER JOIN #e e ON e.PMID = i.PMID
						
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationSubset',0,@RecCount)
			
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iCitationScreen i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationScreen',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iComment i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iComment',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iDataBank i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iDataBank',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iGrant i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iGrant',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iKeyword i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeyword',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iKeywordList i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeywordList',0,@RecCount)
		
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iLanguage i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iLanguage',0,@RecCount)
			
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iPublicationType i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iPublicationType',0,@RecCount)
			
			DELETE i FROM [Cogent3-PostMayWeekly].dbo.iOtherID i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iOtherID ',0,@RecCount)	
		END
		DROP TABLE #e
		
		INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation Compeleted ',0,@RecCount)		

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iArticle 
	SELECT  * FROM iArticle
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iArticle',@RecCount,0)		
		
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iArticleDate
	SELECT * FROM iArticleDate with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iArticleDate',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iAuthor 
	SELECT 	*	FROM iAuthor with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAuthor',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iDataBank 
	SELECT *	FROM iDataBank with(nolock)

	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iDataBank',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iAccession 
	SELECT * FROM iAccession with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAccession',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iChemical
	SELECT *	FROM iChemical with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iChemical',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iGrant 
	SELECT * FROM iGrant with(nolock)

	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iGrant',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iCitationSubset 
	SELECT *	FROM iCitationSubset with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationSubset',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iComment 
	SELECT *	FROM iComment with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iComment',@RecCount,0)		
	

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iKeywordList 
	SELECT	* FROM iKeywordList with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iKeywordList',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iKeyword 
	SELECT *	FROM iKeyword with(nolock)

	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iKeyword',@RecCount,0)		
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iPublicationType 
	SELECT *	FROM iPublicationType with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iPublicationType',@RecCount,0)		
	

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iOtherID 
	SELECT *	FROM iOtherID with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iOtherID',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iLanguage 
	SELECT	*	FROM iLanguage with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iLanguage',@RecCount,0)		

--**************************************************************************
	INSERT INTO [Cogent3-PostMayWeekly].dbo.iCitation 
	SELECT 	*	FROM iCitation with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitation',@RecCount,0)

--**************************************************************************
INSERT INTO [Cogent3-PostMayWeekly].dbo.iWide (
      PMID,
      ArticleTitle,
      AbstractText,
      CopyrightInformation,
      VernacularTitle,
      Affiliation
)
SELECT       PMID,
      ArticleTitle,
      AbstractText,
      CopyrightInformation,
      VernacularTitle,
      Affiliation
      from iWide with(nolock)

	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iWide',@RecCount,0)		
--**************************************************************************
INSERT INTO [Cogent3-PostMayWeekly].dbo.iWideNew 
(
      PMID,
      ArticleTitle,
      AbstractText,
      CopyrightInformation,
      VernacularTitle,
      Affiliation
)
SELECT PMID,
      ArticleTitle,
      AbstractText,
      CopyrightInformation,
      VernacularTitle,
      Affiliation from iWideNew with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iWideNew',@RecCount,0)		

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iCitationScreen 
		SELECT * FROM iCitationScreen with(nolock)
		
		SET @RecCount = @@ROWCOUNT	
		INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationScreen',@RecCount,0)		

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iCitationMeSHHeading 
	SELECT *	FROM iCitationMeSHHeading with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeading',@RecCount,0)		

	INSERT INTO [Cogent3-PostMayWeekly].dbo.iCitationMeSHQualifier 
		SELECT * FROM iCitationMeSHQualifier with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHQualifier',@RecCount,0)
