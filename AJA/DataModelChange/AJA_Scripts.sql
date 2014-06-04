/*copy data from one db table to another db table */

INSERT INTO aja.dbo.Countries
SELECT * FROM User_01.dbo.Countries

Insert into aja.dbo.Specialties
select * from User_01.dbo.Specialties

insert into aja.dbo.TypePractice
select * from User_01.dbo.TypePractice


ALTER TABLE dbo.AJA_tbl_Users  ADD CPswd nvarchar(150),Fname nvarchar(50),Lname nvarchar(50),Pincode int
GO

/*new column added in AJA_User table 7-09-2013 by Ravi*/

alter table [dbo].[AJA_tbl_Users] ADD IseditorEmaiSend bit,IsSavedAqemaisend bit,deleted_ind nvarchar(1),surveyValidated bit
Go

/*import data from user to AJA DB */
INSERT INTO aja.dbo.NonMedlineCitations
SELECT * FROM User_01.dbo.NonMedlineCitations

/*Change NonMedlineCitations table data type*/
alter table NonMedlineCitations alter column [AuthorList] nvarchar(max)
alter table NonMedlineCitations alter column [DisplayDate] nvarchar(250)
alter table NonMedlineCitations alter column [DisplayNotes] nvarchar(250)
alter table NonMedlineCitations alter column [ExpireDate]  nvarchar(250)
alter table NonMedlineCitations alter column [KeepDelete] nvarchar(50)
alter table NonMedlineCitations alter column [MedlinePgn] nvarchar(500)
alter table NonMedlineCitations alter column [MedlineTA] nvarchar(500)
alter table NonMedlineCitations alter column [Nickname] varchar(100)
alter table NonMedlineCitations alter column [SearchID] varchar(100)
alter table NonMedlineCitations alter column [Status] varchar(100)
alter table NonMedlineCitations alter column [StatusDisplay] varchar(100)

/* Scripts for vwRecentEditions sandeep.g*/ 

/****** Object:  View [dbo].[vwRecentEditions]    Script Date: 08/02/2013 16:02:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[vwRecentEditions] AS
SELECT TOP 10 EditionID
	, sp.SpecialtyName 
	+ REPLACE(REPLACE(' (' + CONVERT(nvarchar(10), PubDate, 101) + ')', '/0', '/'),'(0', '(')
	AS [Edition Name]
FROM Editions ed
JOIN Specialties sp ON ed.SpecialtyID = sp.SpecialtyID
ORDER BY PubDate DESC

GO

/*added stored procedure 'adm_InsertEditorialComment' */
 
/****** Object:  StoredProcedure [dbo].[adm_InsertEditorialComment]    Script Date: 08/02/2013 16:06:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[adm_InsertEditorialComment]
	@ThreadID INT, 
	@AuthorID INT,
	@SortOrder INT,
	@Comment NTEXT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CommentID INT;

	INSERT INTO EditorialComments
		(ThreadID, SortOrder, Comment)
	VALUES
		(@ThreadID, @SortOrder, @Comment)

	SET @CommentID = SCOPE_IDENTITY()

	INSERT INTO CommentAuthorReferences
		(AuthorID, CommentID)
	VALUES
		(@AuthorID, @CommentID)
END

/*added stored procedure [adm_GetThreadComments] sandeep.g*/
 
/****** Object:  StoredProcedure [dbo].[adm_GetThreadComments]    Script Date: 08/02/2013 16:07:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[adm_GetThreadComments] 
	@ThreadID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	ec.CommentID, 
			dbo.lib_GetCommentAuthors(CommentID) As Authors
	FROM
	EditorialComments ec
	WHERE ThreadID = @ThreadID
	ORDER BY ec.SortOrder

END

Go


/* Fot the build on 30-aug-2013 */

/*Scripts for Editors Choice by RaviM */
create PROCEDURE [dbo].[lib_GetECThreadComments] 
	@EditionID INT,
	@ThreadID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	ec.CommentID, 
			dbo.lib_IsEditorComment(@ThreadID, CommentID, @EditionID) As IsEditor, 
			dbo.lib_GetCommentAuthors(CommentID) As Authors,
			ec.Comment
	FROM
	EditorialComments ec
	WHERE ThreadID = @ThreadID
	--ORDER BY IsEditor DESC, ec.SortOrder
	ORDER BY ec.SortOrder
END
Go

create FUNCTION [dbo].[lib_IsEditorComment] 
(
	@ThreadID INT, 
	@CommentID INT, 
	@EditionID INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @RetVal BIT

	IF EXISTS
	(
		SELECT AuthorID FROM
		(
			SELECT car.AuthorID
			FROM CommentAuthorReferences car
			WHERE CommentID = @CommentID
			EXCEPT
			SELECT ster.EditorID As AuthorID
			FROM SubTopicEditorRefs ster
			WHERE EditionID = @EditionID
			  AND ThreadID = @ThreadID
		) AuthorsNotEditors
		UNION
		SELECT AuthorID FROM
		(
			SELECT ster.EditorID As AuthorID
			FROM SubTopicEditorRefs ster
			WHERE EditionID = @EditionID
			  AND ThreadID = @ThreadID
			EXCEPT
			SELECT car.AuthorID
			FROM CommentAuthorReferences car
			WHERE CommentID = @CommentID
		) EditorsNotAuthors
	)
	SET @RetVal = 0 
	ELSE SET @RetVal = 1

	RETURN @RetVal
END
go

-- =============================================
-- Author:		Ravi Kumar M
-- Copyright (c) 2013 ACR Journal Advisor
-- =============================================
create FUNCTION [dbo].[lib_GetCommentAuthors] 
(
	@CommentID INT
)
RETURNS NVARCHAR(1024)
AS
BEGIN
	DECLARE @AuthorList NVARCHAR(1024), @ThisAuthor NVARCHAR(50)

	DECLARE AuthorCursor CURSOR FOR
		SELECT ca.[Name]
		FROM CommentAuthorReferences car
		JOIN CommentAuthors ca ON car.AuthorID = ca.ID
		WHERE CommentID = @CommentID

	OPEN AuthorCursor

	FETCH NEXT FROM AuthorCursor INTO @ThisAuthor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AuthorList IS NULL
			SET @AuthorList = @ThisAuthor
		ELSE
			SET @AuthorList = @AuthorList + ', ' + @ThisAuthor

		FETCH NEXT FROM AuthorCursor INTO @ThisAuthor
	END

	CLOSE AuthorCursor
	DEALLOCATE AuthorCursor

	RETURN @AuthorList
END

Go

/*Scripts FOR Related Editions*/
create PROCEDURE [dbo].[lib_GetRelatedEditions]
	@PMID int
	,@EditionID int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT s.SpecialtyName, eds.PubDate, eds.EditionID, s.SpecialtyID, ths.ThreadID
	FROM ArticleSelections arts
	JOIN EditorialThreads ths ON arts.ThreadId = ths.ThreadID
	JOIN SubTopicReferences stref ON stref.ThreadID = ths.ThreadID
	JOIN Editions eds ON stref.EditionID = eds.EditionID
	JOIN Specialties s ON eds.SpecialtyID = s.SpecialtyID
	WHERE arts.PMID = @PMID
	AND eds.EditionID != @EditionID
	ORDER BY eds.PubDate, s.SpecialtyName
END


GO
-- =============================================
-- Author:		Ravi Kumar M
-- Copyright (c) 2013 ACR Journal Advisor
-- =============================================
Create PROCEDURE [dbo].[lib_GetECEditionThreads] 
	-- Add the parameters for the stored procedure here
	@EditionID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT thds.ThreadID, thds.OriginalPubDate,
	(
		SELECT Top 1 (t.TopicName + st.SubTopicName)
		FROM Topics t
		JOIN SubTopics st ON st.TopicID = t.TopicID
		JOIN SubTopicReferences strefs ON strefs.SubTopicID = st.SubTopicID
		WHERE strefs.ThreadID = thds.ThreadID
		-- ORDER BY Would be nice, but very expensive in terms of performance
	) AS TopicOrdering
	INTO #TheseThreads
	FROM
	(
		SELECT DISTINCT eth.ThreadID, eth.OriginalPubDate 
		FROM EditorialThreads eth
		JOIN SubTopicReferences strefs ON strefs.ThreadID = eth.ThreadID
		WHERE strefs.EditionID = @EditionID
	) thds

	SELECT ThreadID, OriginalPubDate FROM #TheseThreads
	ORDER BY TopicOrdering

	DROP TABLE #TheseThreads

END

GO
create proc [dbo].[lib_GetGenesForEditorsChoice]
(
   @CommentID int
) as

begin	
	select t1.GeneID, t1.Name 
		from EditorialCommentsGenes t2 inner join Genes t1 on t2.GeneID = t1.GeneID 
			where CommentID = @CommentID
end

 /*Scipts for GetMailingEdition */
 go
CREATE PROCEDURE [dbo].[adm_GetECMailingByEdition]
	@EditionID INT
AS
SELECT DISTINCT art.pmid
	, e.name As EdtiorName
	, CAST(ec.Comment AS nvarchar(2048)) As Comment
	, ed.PubDate As EditorDate
	, ths.ThreadID
	, t.TopicName As OrgFolderName
	, st.SubTopicName As FunFolderName
	FROM
	Editions ed
	JOIN SubTopicReferences stref ON stref.EditionID = ed.EditionID
	JOIN EditorialThreads ths on ths.ThreadID = stref.ThreadID 
	JOIN SubTopics st ON stref.SubTopicID = st.SubTopicID
	JOIN Topics t ON st.TopicID = t.TopicID
	JOIN ArticleSelections art ON art.ThreadID = ths.ThreadID
	JOIN EditorialComments ec ON ec.ThreadID = ths.ThreadID
	JOIN CommentAuthorReferences authref ON authref.CommentID = ec.CommentID
	JOIN CommentAuthors e ON authref.AuthorID = e.ID
	WHERE ed.EditionID = @EditionID
	ORDER BY t.TopicName, st.SubTopicName



GO


/*Scripts to Delete EditorialComments*/
GO

/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorialComment]    Script Date: 08/30/2013 17:08:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[adm_DeleteEditorialComment]
(
	@CommentID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM	CommentAuthorReferences
		WHERE CommentID = @CommentID;

	DELETE FROM EditorialComments
		WHERE CommentID = @CommentID;
END



GO

/*Scripts To delete Editorial Threads*/

GO

/****** Object:  StoredProcedure [dbo].[adm_DeleteThread]    Script Date: 08/30/2013 17:09:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[adm_DeleteThread]
(
	@ThreadID int
)
AS
BEGIN
	DELETE FROM ArticleSelections
	WHERE ThreadID=@ThreadID

	DELETE FROM CommentAuthorReferences
	WHERE CommentID IN
	(SELECT CommentID FROM EditorialComments
		WHERE ThreadID=@ThreadID)

	DELETE FROM EditorialComments
	WHERE ThreadID=@ThreadID

	DELETE FROM SubTopicEditorRefs
	WHERE ThreadID=@ThreadID

	DELETE FROM SubTopicReferences
	WHERE ThreadID=@ThreadID	

	DELETE FROM EditorialThreads
	WHERE ThreadID=@ThreadID
END
 
GO

/*Scripts To get Threads sandeep.g*/ 
GO

/****** Object:  StoredProcedure [dbo].[adm_GetThreads]    Script Date: 08/30/2013 17:12:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[adm_GetThreads]
	@EditionID INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT th.ThreadID, 
	dbo.fnGetThreadPMIDList(th.ThreadID,';') as ArticleSelections,
		dbo.lib_GetThreadEditors(@EditionID, th.ThreadID) As Editors
	FROM EditorialThreads th
	JOIN SubTopicReferences stref ON stref.ThreadID = th.ThreadID
	WHERE stref.EditionID = @EditionID 
	ORDER BY Editors
END 
GO

/*Changing Data Type of PinCode from Int to Nvarchar(50)  RaviM 09/04/2013 */

Go
ALTER TABLE dbo.AJA_tbl_Users
   ALTER COLUMN Pincode nvarchar(50)

   /* Alter ExpireDate from 'Nvarchar - DateTime Madhavi G 09/12/2013*/

    alter table [NonMedlineCitations] alter column [ExpireDate] datetime null
	go
   
   
   /*for corrupted data in userTitle --by RaviM on 09/17/2013*/
   update AJA_tbl_Users set UserTitle='Ph.D.' where UserTitle='PhD'
   Go

  
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryGet]    Script Date: 09/18/2013 By RaviM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
Create PROCEDURE [dbo].[SearchQueryGet]
  @UserID					int,
	@SearchName			varchar(100),
  @SearchID				int
											
AS
  DECLARE @RecCount				int
	DECLARE @Op1						char(3)
  DECLARE @Terms1					varchar(100)
	DECLARE @Tab1						varchar(35)
	DECLARE @Op2						char(3)
  DECLARE @Terms2					varchar(100)
	DECLARE @Tab2						varchar(35)
	DECLARE @Op3						char(3)
  DECLARE @Terms3					varchar(100)
	DECLARE @Tab3						varchar(35)
	DECLARE @Op4						char(3)
  DECLARE @Terms4					varchar(100)
	DECLARE @Tab4						varchar(35)
	DECLARE @Op5						char(3)
  DECLARE @Terms5					varchar(100)
	DECLARE @Tab5						varchar(35)
	DECLARE @Op6						char(3)
  DECLARE @Terms6					varchar(100)
	DECLARE @Tab6						varchar(35)
	DECLARE @PublicationTypeMask	smallint
	DECLARE @SubjectAgeMask	smallint
	DECLARE @LanguageMask		tinyint
	DECLARE @SpeciesMask		tinyint
	DECLARE @GenderMask			tinyint
  DECLARE @AbstractMask		tinyint
	DECLARE @PaperAge				tinyint
	DECLARE @DateStart			smallint
	DECLARE @DateEnd				smallint
  DECLARE @SearchSort			tinyint
  DECLARE @AutoSearch 		tinyint
  DECLARE @ShelfLife 			smallint
  DECLARE @Description		varchar(500)
  DECLARE @LastAutorunHits		int
  DECLARE @LastAutorunDate		smalldatetime
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1	int
  DECLARE @ResultsFolder2	int
  DECLARE @UserDB					varchar(50)
  DECLARE @KeepDelete			tinyint
	DECLARE @Seq						int
	DECLARE @Op							char(3)
	DECLARE @Terms					varchar(100)
	DECLARE @Tab						varchar(35)
  SET NOCOUNT ON
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM SearchSummary  
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  SELECT	@PublicationTypeMask	= PublicationTypeMask,
					@SubjectAgeMask				= SubjectAgeMask,
					@LanguageMask					= LanguageMask,
					@SpeciesMask					= SpeciesMask,
					@GenderMask						= GenderMask,
					@AbstractMask					= AbstractMask,
					@PaperAge							= PaperAge,
					@DateStart						= DATEPART(yyyy,DateStart),
					@DateEnd							= DATEPART(yyyy,DateEnd),
					@UserID								= UserID,
					@SearchSort						= SearchSort,
					@SearchName						= SearchName,
					@AutoSearch						= AutoSearch,
					@ShelfLife						= ShelfLife,
					@Description					= Description,
					@LastAutorunHits			= LastAutorunHits,
					@LastAutorunDate			= LastAutorunDate,
					@LimitToUserLibrary		= LimitToUserLibrary,
					@ResultsFolder1				= ResultsFolder1,
					@ResultsFolder2				= ResultsFolder2,
					@UserDB								= UserDB,
					@KeepDelete						= KeepDelete
	  FROM SearchSummary
		WHERE SearchID = @SearchID
  DECLARE cur CURSOR FOR
	  SELECT Seq, Op, Terms, Tab
		  FROM SearchDetails
			WHERE SearchID = @SearchID
			ORDER BY Seq
	OPEN cur
	FETCH NEXT FROM cur INTO @Seq, @Op, @Terms, @Tab
  WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Seq = 1 AND @Terms IS NOT NULL
				BEGIN
					SET @Op1		= @Op
					SET @Terms1 = @Terms
					SET @Tab1	  = @Tab
				END
			IF @Seq = 2 AND @Terms IS NOT NULL
				BEGIN
					SET @Op2		= @Op
					SET @Terms2 = @Terms
					SET @Tab2	  = @Tab
				END
			IF @Seq = 3 AND @Terms IS NOT NULL
				BEGIN
					SET @Op3		= @Op
					SET @Terms3 = @Terms
					SET @Tab3	  = @Tab
				END
			IF @Seq = 4 AND @Terms IS NOT NULL
				BEGIN
					SET @Op4		= @Op
					SET @Terms4 = @Terms
					SET @Tab4	  = @Tab
				END
			IF @Seq = 5 AND @Terms IS NOT NULL
				BEGIN
					SET @Op5		= @Op
					SET @Terms5 = @Terms
					SET @Tab5	  = @Tab
				END
			IF @Seq = 6 AND @Terms IS NOT NULL
				BEGIN
					SET @Op6		= @Op
					SET @Terms6 = @Terms
					SET @Tab6	  = @Tab
				END
			FETCH NEXT FROM cur INTO @Seq, @Op, @Terms, @Tab
		END
  CLOSE cur
	DEALLOCATE cur
  SELECT	@UserID                   AS 'UserID',
					@SearchName               AS 'SearchName',
					@SearchID                 AS 'SearchID',
					@Op1                      AS 'Op1',
					@Terms1                   AS 'Terms1',
					@Tab1                     AS 'Tab1',
					@Op2                      AS 'Op2',
					@Terms2                   AS 'Terms2',
					@Tab2                     AS 'Tab2',
					@Op3                      AS 'Op3',
					@Terms3                   AS 'Terms3',
					@Tab3                     AS 'Tab3',
					@Op4                      AS 'Op4',
					@Terms4                   AS 'Terms4',
					@Tab4                     AS 'Tab4',
					@Op5                      AS 'Op5',
					@Terms5                   AS 'Terms5',
					@Tab5                     AS 'Tab5',
					@Op6                      AS 'Op6',
					@Terms6                   AS 'Terms6',
					@Tab6                     AS 'Tab6',
					@PublicationTypeMask      AS 'PublicationTypeMask',
					@SubjectAgeMask           AS 'SubjectAgeMask',
					@LanguageMask             AS 'LanguageMask',
					@SpeciesMask              AS 'SpeciesMask',
					@GenderMask               AS 'GenderMask',
					@AbstractMask             AS 'AbstractMask',
					@PaperAge                 AS 'PaperAge',
					@DateStart                AS 'DateStart',
					@DateEnd                  AS 'DateEnd',
					@SearchSort               AS 'SearchSort',
					@AutoSearch								AS 'AutoSearch',
					@ShelfLife								AS 'ShelfLife',
					@Description							AS 'Description',
					@LimitToUserLibrary				AS 'LimitToUserLibrary',
					@LastAutorunHits					AS 'LastAutorunHits',
					@LastAutorunDate					AS 'LastAutorunDate',
					@ResultsFolder1						AS 'ResultsFolder1',
					@ResultsFolder2						AS 'ResultsFolder2',
					@UserDB										AS 'UserDB',
					@KeepDelete								AS 'KeepDelete'


/****** Added StoredProcedure [dbo].[lib_GetSearchCitationList]    Script Date: 09/26/2013 15:00:23 Madhavi******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[lib_GetSearchCitationList]
	@UserID INT, 
	@SearchID INT
AS
BEGIN
	SELECT ucit.pmid, 1 as status, ucom.nickname, ucom.comment, 
		ucom.updatedate as commentupdatedate,
		ucit.searchid, ucit.expiredate, ucit.keepdelete 
	FROM UserCitations ucit
	LEFT JOIN UserComment ucom ON (ucit.PMID = ucom.pmid) AND (ucom.userid = ucit.userid)
	WHERE ucit.Userid = @UserID
		AND ucit.IsAutoQueryCitation = 1
		AND ucit.SearchID = @SearchID
		AND ucit.Deleted = 0
END
Go

USE [AJA_Dev]
GO

/***Seacrh Queries **/
/****** Object:  Table [dbo].[debug_tblTrackSearchAdd]    Script Date: 09/30/2013 12:32:19 ******/
USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryAdd]    Script Date: 09/30/2013 12:09:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create PROCEDURE [dbo].[ap_SearchQueryAdd_AJA]
	@Op1						char(3),
  @Terms1					varchar(100),
	@Tab1						varchar(35),
	@Op2						char(3),
  @Terms2					varchar(100),
	@Tab2						varchar(35),
	@Op3						char(3),
  @Terms3					varchar(100),
	@Tab3						varchar(35),
	@Op4						char(3),
  @Terms4					varchar(100),
	@Tab4						varchar(35),
	@Op5						char(3),
  @Terms5					varchar(100),
	@Tab5						varchar(35),
	@Op6						char(3),
  @Terms6					varchar(100),
	@Tab6						varchar(35),
	@PublicationTypeMask	smallint,
	@SubjectAgeMask	smallint,
	@LanguageMask		tinyint,
	@SpeciesMask		tinyint,
	@GenderMask			tinyint,
  @AbstractMask		tinyint,
	@PaperAge				tinyint,
	@DateStart			smallint,
	@DateEnd				smallint,
  @SearchSort			tinyint,
  @UserID					int,
	@SearchName			varchar(100),
-- Start new
	@AutoSearch 		tinyint,  			-- 0) Ad Hoc 1) Scheduled
	@ShelfLife 			smallint,				-- days found citations stay in user folder
	@Description		varchar(255),		-- user-supplied description
	@LimitToUserLibrary	tinyint,		-- limit searching to user's citations only NOT IMPLEMENTED YET
	@ResultsFolder1	int,						-- Save found PMIDs in this folder - Set to 0 to skip
	@ResultsFolder2	int,						-- Also save found PMIDs in this folder - Set to 0 to skip
	@UserDB					varchar(50),		-- DB name for user folders
	@KeepDelete			tinyint,
-- End new
  @ReturnCode			int OUTPUT	-- >0: SearchID 
															-- -1: SearchName already exists
AS
  DECLARE @RecCount			int
  DECLARE @SearchID			int
  SET NOCOUNT ON
  IF @SearchName IS NULL
		SET @SearchName = 'Search created on ' + CONVERT(varchar(30),GETDATE(),100)
  IF LEN(@SearchName) = 0
		SET @SearchName = 'Search created on ' + CONVERT(varchar(30),GETDATE(),100)
  DECLARE @TrackID INT
  INSERT INTO debug_tblTrackSearchAdd(SearchName, UserID, UserDB)
	VALUES(@SearchName, @UserID, @UserDB)
  SET @TrackID = @@IDENTITY
  SELECT @RecCount = COUNT(*)
    FROM  AJA_Dev.dbo.SearchSummary
		WHERE UserID			= @UserID	AND
				  SearchName	= @SearchName	AND
				UserDb		= @UserDB
  IF @RecCount >= 1 
		BEGIN
			UPDATE debug_tblTrackSearchAdd
				SET RecCount = @RecCount
				WHERE AttemptID = @TrackID
			SET @ReturnCode = -1
			RETURN
		END
  INSERT INTO AJA_Dev.dbo.SearchSummary (
		PublicationTypeMask,
		SubjectAgeMask,
		LanguageMask,
		SpeciesMask,
		GenderMask,
	  AbstractMask,
		PaperAge,
		DateStart,
		DateEnd,
		SearchSort,
	  UserID,
		SearchName,
		AutoSearch,
		ShelfLife,
		[Description],
		LimitToUserLibrary,
		ResultsFolder1,
		ResultsFolder2,
		UserDB,
		KeepDelete
  )
  VALUES (
		@PublicationTypeMask,
		@SubjectAgeMask,
		@LanguageMask,
		@SpeciesMask,
		@GenderMask,
	  @AbstractMask,
		@PaperAge,
		CAST( CAST(@DateStart AS varchar(4)) + '-01-01' AS smalldatetime),
		CAST( CAST(@DateEnd AS varchar(4)) + '-12-31' AS smalldatetime),
		@SearchSort,
	  @UserID,
		@SearchName,
		@AutoSearch,
		@ShelfLife,
		@Description,
		@LimitToUserLibrary,
		@ResultsFolder1,
		@ResultsFolder2,
		@UserDB,
		@KeepDelete
  )
  SET @SearchID = @@IDENTITY
  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
    VALUES (@SearchID, 1, @Op1, @Terms1, @Tab1)
  IF LEN(@Terms2) > 0
	  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 2, @Op2, @Terms2, @Tab2)
  IF LEN(@Terms3) > 0
	  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 3, @Op3, @Terms3, @Tab3)
  IF LEN(@Terms4) > 0
	  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 4, @Op4, @Terms4, @Tab4)
  IF LEN(@Terms5) > 0
	  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 5, @Op5, @Terms5, @Tab5)
  IF LEN(@Terms6) > 0
	  INSERT INTO AJA_Dev.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 6, @Op6, @Terms6, @Tab6)
  SET @ReturnCode = @SearchID


 /****** Object:  StoredProcedure [dbo].[ap_SearchExecute_AJA]    Script Date: 09/30/2013 14:16:51 ******/
 go
create PROCEDURE [dbo].[ap_SearchExecute_AJA]
  @UserID							int ,
	@SearchName					varchar(100),
  @SearchID						int,
	@SearchMode					int , 						-- 0) interactive; 1) Autorun
	@ShelfLife					int,						-- only for autosearch. stamps UserDB_Stage.UserCitation.expiredate with @ThisAutorunDate + @ShelfLife
	@LimitToUserLibrary	int ,						-- only for autosearch. not implemented
	@ThisAutorunDateS		varchar(50),	-- only for autosearch.
	@ResultsFolder1			int,						-- only for autosearch.  Output to @UserDB.UserCitation.folderid if @ResultsFolder1 > 0
	@ResultsFolder2			int,						-- only for autosearch.  Output to @UserDB.UserCitation.folderid if @ResultsFolder2 > 0
	@UserDB							varchar(50),		-- only for autosearch.
	@KeepDelete					int,						-- only for autosearch.  Pass user to @UserDB.UserCitation
  @DoNoExecute				int,
  @SearchResultsCount	int	OUTPUT,
	@QueryDetails				varchar(2000)	OUTPUT,
	@ErrorDesc					varchar(2000)	OUTPUT									
AS

  DECLARE @RecCount				int
  DECLARE @QueryFinal		 	nvarchar(4000)
  DECLARE @RunQuery				int
  DECLARE @Found					int
	DECLARE @ThisAutorunDate		smalldatetime

	SET @ThisAutorunDate = CAST(@ThisAutorunDateS AS smalldatetime)

  SET NOCOUNT ON
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM AJA_Dev.dbo.SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  IF @DoNoExecute = 0
  	DELETE FROM AJA_Dev.dbo.SearchResults WHERE SearchID = @SearchID

	SET @RunQuery = 0
  EXEC ap_SearchBuildFullQuery  @SearchID,
																@SearchMode,
																@ShelfLife,
																@LimitToUserLibrary,
																@ThisAutorunDate,
																@ResultsFolder1,
																@ResultsFolder2,
																@UserDB,
																@KeepDelete,
																@QueryFinal	OUTPUT,		--Full query
																@RunQuery		OUTPUT,		--0: don't run query; 1: run query
																@ErrorDesc	OUTPUT,		--Show user why search terms are no good
																@QueryDetails	OUTPUT

	IF @RunQuery = 1 AND @DoNoExecute <> 1
		BEGIN
			EXEC sp_executesql @QueryFinal
		  SELECT @SearchResultsCount = FoundLast
				FROM AJA_Dev.dbo.SearchSummary
				WHERE SearchID = @SearchID
		END
	ELSE
		BEGIN
		  SET @SearchResultsCount = 0
		END
		select @SearchResultsCount SearchResultsCount,@QueryDetails QueryDetails , @ErrorDesc ErrorDesc


/* changed search summary start date,end date columns datatype - RaviM - 10/01/2013   */
go

ALTER TABLE dbo.SearchSummary
ALTER COLUMN DateStart DATETIME NULL


ALTER TABLE dbo.SearchSummary
ALTER COLUMN DateEnd DATETIME NULL

go

		USE [AJA_Dev]
GO
/****** Object:  StoredProcedure [dbo].[lib_CopyUserCitation]    Script Date: 10/01/2013 12:50:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[lib_CopyUserCitation_MyQueries]
	@pmid INT, 
	@SubTopicID INT, 
	@userid INT,
	@SearchID int,
	@ExpireDate smalldatetime,
	@KeepDelete bit,
	@SpecialtyID INT OUTPUT
AS
BEGIN	
	-- undelete the citation if it exists
	UPDATE UserCitations
		SET Deleted = 0
		WHERE UserID = @userid
		AND PMID = @pmid
		AND SubTopicID = @SubTopicID
	
	-- if not, insert it
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO UserCitations(UserID, PMID, SubTopicID, Deleted,SearchID,ExpireDate,KeepDelete,IsAutoQueryCitation)
			VALUES(@userid, @pmid, @SubTopicID, 0,@SearchID,@ExpireDate,@KeepDelete,0)
	END

	-- Finally, get a specialty reference for the destination
	-- folder
	SET @SpecialtyID = (SELECT t.SpecialtyID
		FROM Topics t
		JOIN SubTopics st ON st.TopicID = t.TopicID
		WHERE st.SubTopicID = @SubTopicID)
END
go

USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchRange_AJA]    Script Date: 10/01/2013 16:39:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ap_SearchFetchRange_AJA]
  @UserID					int,
	@SearchName			varchar(100),
  @SearchID				int,
	@RangeStart			int,
  @RangeEnd				int
AS
  SET NOCOUNT ON
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM AJA_Dev.dbo.SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  INSERT INTO AJA_Dev.dbo.SearchView (ViewPMID,ViewDate,UserID, SearchID,ViewCountSummary) VALUES (0,GETDATE(), @UserID, @SearchID, @RangeEnd - @RangeStart + 1)
  SELECT	r.PMID,
					r.List,
					ISNULL(w.ArticleTitle,wn.ArticleTitle) AS 'ArticleTitle',
					AuthorList,
					MedlineTA,
					MedlinePgn,
					DisplayDate,
					DisplayNotes
    FROM AJA_Dev.dbo.SearchResults r
		JOIN iCitation c ON c.PMID = r.PMID
		LEFT JOIN iWide w ON w.PMID = r.PMID
		LEFT JOIN iWideNew wn ON wn.PMID = r.PMID
		WHERE SearchID = @SearchID AND
					List		 >= @RangeStart	AND
					List 		<= @RangeEnd
		ORDER BY List
		
		go


		/* Changed AJAUser to AJA User  10/09/13  tfs-5621*/

		update AJA_tbl_Roles set RoleName='AJA User' where RoleID=2
		Go



		/* Created ap_search_get_AJA  & Alter [ap_SearchBuildFullQuery_AJA] for using AJA_dev  */ --- 11-10-2013
		USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildFullQuery_AJA]    Script Date: 10/11/2013 13:09:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ap_SearchBuildFullQuery_AJA]
	@SearchID				int,
	@SearchMode					int, 						-- 0) interactive; 1) Autorun
	@ShelfLife					int,						-- only for autosearch. 
																			-- stamps UserDB_Stage.UserCitation.expiredate with @ThisAutorunDate + @ShelfLife
	@LimitToUserLibrary	int,						-- only for autosearch. not implemented
	@ThisAutorunDate		smalldatetime,	-- only for autosearch.
	@ResultsFolder1			int,						-- only for autosearch.  @ResultsFolder1 must be > 0.  Output to @UserDB.UserCitation.subtopicid
	@ResultsFolder2			int,						-- only for autosearch.  Output to @UserDB.UserCitation.subtopicid if @ResultsFolder2 > 0
	@UserDB							varchar(50),		-- only for autosearch.
	@KeepDelete					tinyint,				-- only for autosearch.
	@QueryFinal			varchar(8000)		OUTPUT,		--Full query
	@RunQuery				int							OUTPUT,		--0: don't run query; 1: run query
	@ErrorDesc			varchar(200)		OUTPUT,		--Show user why search terms are no good
	@QueryDetails	  varchar(4000)		OUTPUT		--English description of query
AS
SET NOCOUNT ON
-- Locals ----------------------------------------------------------

	DECLARE @PublicationTypeMask	smallint		--From AJA_Dev.dbo.SearchSummary
	DECLARE @LanguageMask		tinyint						--From AJA_Dev.dbo.SearchSummary
	DECLARE @SpeciesMask		tinyint						--From AJA_Dev.dbo.SearchSummary
	DECLARE @GenderMask			tinyint						--From AJA_Dev.dbo.SearchSummary
	DECLARE @SubjectAgeMask	smallint					--From AJA_Dev.dbo.SearchSummary
	DECLARE @AbstractMask		smallint					--From AJA_Dev.dbo.SearchSummary
	DECLARE @DateStart			smalldatetime			--From AJA_Dev.dbo.SearchSummary
	DECLARE @DateEnd				smalldatetime			--From AJA_Dev.dbo.SearchSummary
  DECLARE @PaperAge				tinyint						--From AJA_Dev.dbo.SearchSummary
  DECLARE @SearchSort			tinyint						--From AJA_Dev.dbo.SearchSummary
  DECLARE @FastFullText		tinyint						--From AJA_Dev.dbo.SearchSummary
  DECLARE @UserID					int
	DECLARE @Terms					varchar(400)			--Search words entered by user in each terms set
	DECLARE @Seq						int								--Sequence number of terms set
	DECLARE @Op							char(3)						--Operation for terms set: Any, All, Not
	DECLARE @Tab						varchar(35)				--Table to be searched for terms set
	DECLARE @SSet						int								--Sequence number of terms set, used when reading search set
	DECLARE @TestOrder			int								--Order in which search words to be found within xRef table
																						-- 100-199: quoted phrase
																						-- 200: full string phrase
																						-- 201-299: two word phrase
																						-- 300-399 single word
	DECLARE @Field					varchar(35)				--Field to be searched
	DECLARE @TermA					varchar(100)			--Search term A
	DECLARE @TermB					varchar(100)			--Search term b
	DECLARE @Status					int								--Status of search: 0) term does not exist in xRef; 1) term exists
	DECLARE @FindA					int								--Key from xRef
	DECLARE @FindB					int								--Key from xRef (if second value needed)
	DECLARE @Extra					varchar(200)			--Used in ap_SearchBuildTokens to return additional results

	DECLARE @QueryOne				varchar(2000)			--Text for query for this search word/phrase
	DECLARE @QueryDetailsW	varchar(2000)			--Work table for @QueryDetailsW
	DECLARE @QueryDetailsB	varchar(2000)			--Work table for @QueryDetailsW
	
	DECLARE @QueryWhere 		nvarchar(4000)		
	DECLARE @OpLast					char(3)						
  DECLARE @iOpLast				int
  DECLARE @SSetLast				int

  DECLARE @QSeq						int 							
  DECLARE @iOp						int 							-- 1: Or; 2: And; 3: Not
  DECLARE @SQL						varchar(2000)			-- SQL statement
  DECLARE @Details				varchar(200)			-- English description

  DECLARE @Pos1						int								--position while parsing terms set
  DECLARE @Pos2						int								--position while parsing terms set
  DECLARE @TermsW					varchar(400)			--holder while parsing terms set

  DECLARE @WordThis				varchar(400)			--holder while parsing terms set
  DECLARE @WordLast				varchar(400)			--holder while parsing terms set
  DECLARE @WordPairCount	int 							--counter while parsing terms set
	DECLARE @WordEachCount	int 							--counter while parsing terms set
	DECLARE @cr							char(1)
	DECLARE @RecCount				int 							--working counter
	DECLARE @FullOld				int
	DECLARE @FullNew				int
	DECLARE @FullOldLimit		varchar(50)
  DECLARE @JoinLine				int
  DECLARE @BaseWhere			varchar(1000)
	DECLARE @tad						varchar(20) 

-- Misc. Initialization -------------------------------------------------
	SET @cr = CHAR(13) 
	SET @RunQuery				= 0
	SET @QueryOne				= ''
	SET @QueryFinal			= ''
	SET @QueryWhere			= ''
	SET @QueryDetails		= ''
	SET @QueryDetailsB	= ''
	SET @QueryDetailsW	= ''
  SET @BaseWhere			= ''
	SET @tad = CONVERT(varchar(20),@ThisAutorunDate,102)
	IF @UserDB IS NULL OR @UserDB = ''
		SET @UserDB = 'AJA_Dev'

	IF @ResultsFolder1 IS NULL
		SET @ResultsFolder1 = 0

-- Get search details ---------------------------------------------------
	SELECT	@PublicationTypeMask	= PublicationTypeMask,
					@LanguageMask					= LanguageMask,
					@SpeciesMask					= SpeciesMask,
					@GenderMask						= GenderMask,
					@SubjectAgeMask				= SubjectAgeMask,
					@AbstractMask					= AbstractMask,
					@DateStart						= DateStart,
					@DateEnd							= DateEnd,
					@PaperAge							= PaperAge,
					@SearchSort						= SearchSort,
					@FastFullText					= FastFullText,
					@UserID								= UserID
		FROM AJA_Dev.dbo.SearchSummary
		WHERE SearchID	= @SearchID

-- Quick error exit - Only a NOT line ---------------------------------------
  SELECT @RecCount = SUM(CASE WHEN Op = 'Not' THEN 1 ELSE 10 END)
		FROM AJA_Dev.dbo.SearchDetails
		WHERE SearchID	= @SearchID
  IF @RecCount = 1
	  BEGIN
			SET @ErrorDesc			= 'Invalid search - there must be at least one All or Any line'
			RETURN
		END

-- Determine by date range what full text files to use
	IF @DateStart <> '1960-01-01'
		BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Paper published between the years ' + 
													CAST(DATEPART(yyyy,@DateStart) AS varchar(10)) + ' and ' +
													CAST(DATEPART(yyyy,@DateEnd) AS varchar(10))
		END

	IF @SearchMode = 1
		BEGIN
			IF @PaperAge = 0
				SET @PaperAge = 3
			IF @PaperAge > 3
				SET @PaperAge = 3
		END

	IF @PaperAge > 0
		BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
		  SET @DateEnd = CONVERT(varchar(20),GETDATE(),101)

			IF @PaperAge = 1 
			 BEGIN
				SET @DateStart = DATEADD(d,-30,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 30 days'
			 END
			IF @PaperAge = 2
			 BEGIN
				SET @DateStart = DATEADD(d,-60,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 60 days'
			 END
			IF @PaperAge = 3 
			 BEGIN
				SET @DateStart = DATEADD(d,-90,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 90 days'
			 END
			IF @PaperAge = 4 
			 BEGIN
				SET @DateStart = DATEADD(d,-180,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 180 days'
			 END
			IF @PaperAge = 5 
			 BEGIN
				SET @DateStart = DATEADD(yy,-1,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last year'
			 END
			IF @PaperAge = 6 
			 BEGIN
				SET @DateStart = DATEADD(yy,-2,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 2 years'
			 END
			IF @PaperAge = 7 
			 BEGIN
				SET @DateStart = DATEADD(yy,-5,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 5 years'
			 END
			IF @PaperAge = 8 
			 BEGIN
				SET @DateStart = DATEADD(yy,-10,@DateEnd)
			  SET @QueryDetailsB = @QueryDetailsB + 'Paper published in the last 10 years'
			 END
		END
	SET @FullOld = 1
	SET @FullNew = 1
	SET @FullOldLimit = ''
  IF @DateStart >= '2001-01-01'
		SET @FullOld = 0
  IF @DateEnd < '2001-01-01'
		SET @FullNew = 0
	IF @FastFullText = 1
		SET @FullOldLimit = ',2000'
--Temp override
	SET @FullOld = 0

/*
print 'ap_SearchBuildFullQuery:  @DateStart: ' + isnull(cast(@DateStart as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @DateEnd: ' + isnull(cast(@DateEnd as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @PaperAge: ' + isnull(cast(@PaperAge as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @FullOld: ' + isnull(cast(@FullOld as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @FullNew: ' + isnull(cast(@FullNew as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @FullOldLimit: ' + isnull(cast(@FullOldLimit as varchar(40)),'')
print 'ap_SearchBuildFullQuery:  @QueryDetailsB: ' + isnull(@QueryDetailsB,'')


*/

	CREATE TABLE #s (
		Seq					int 					NOT NULL IDENTITY(1,1) PRIMARY KEY,
		SSet				int						NOT NULL,							-- term set sequence
		Op					char(3) 			NOT NULL,							-- from term set
		Tab					varchar(35) 	NOT NULL,							-- from term set
		Field				varchar(35)		NULL,									-- Field to search for.  ex: LastName, CollectiveName
		TestOrder		int						NOT NULL,							-- order to try finding term in xRef.  Unique within SSet
		Status			int 					NOT NULL DEFAULT(0),	-- -3: fail; this phrase included in a good phrase
																										-- -2: fail; this single word included in a good phrase
																										-- -1: fail; not found in search table
																										-- 0: not processed; 
																										-- 1: Include in fulltext;
																										-- 2: good
		FindA				int 					NULL,									-- key found in xRef
		FindB				int 					NULL,									-- some keys have two parts
		TermA				varchar(100)	NULL,									-- term to find in xRef
		TermB				varchar(100)	NULL,									-- some terms to find might have two parts
		QueryOne		varchar(2000)	NULL,									-- Query to find key in i* table,
		Extra				varchar(200)	NULL
	) 

-- Populate #s Search table  from #p ---------------------------------------
	DECLARE curA CURSOR FOR
		SELECT	Seq,
						Op,
						Terms,
						Tab
		FROM AJA_Dev.dbo.SearchDetails
		WHERE SearchID	= @SearchID
		ORDER BY Seq
	
	OPEN curA
	
	FETCH NEXT FROM curA INTO @Seq, @Op, @Terms, @Tab
	WHILE @@FETCH_STATUS = 0
		BEGIN

		-- Find quoted phrases first
		-- Transact-SQL is not designed for sophisticated string handling, but it can be done!
			SET @Terms = ' ' + @Terms + ' '
			SET @Terms = REPLACE(@Terms,' AND ',' ')
			SET @Terms = REPLACE(@Terms,' OR ',' ')
			SET @Terms = REPLACE(@Terms,' IN ',' ')
			SET @Terms = REPLACE(@Terms,'  ',' ')
			SET @Terms = REPLACE(@Terms,'  ',' ')
			SET @Terms = REPLACE(@Terms,'  ',' ')
			SET @Terms = SUBSTRING(@Terms, 2, LEN(@Terms) - 1)

			SET @Pos1 = CHARINDEX('"', @Terms)
			WHILE @Pos1 > 0
				BEGIN
					SET @Pos2 = CHARINDEX('"', @Terms, @Pos1 + 1)
					IF @Pos2 = 0
						BEGIN
							SET @RunQuery = -1
							SET @ErrorDesc = 'Trailing " missing'
							RETURN
						END
					SET @TermsW = SUBSTRING(@Terms, @Pos1 + 1, @Pos2 - @Pos1 - 1)
					INSERT INTO #s (Op, Tab, SSet, TestOrder, TermA, TermB) VALUES (@Op, @Tab, @Seq, 100, @TermsW, NULL)
					SET @Terms = RTRIM(LTRIM((SUBSTRING(@Terms, 1, @Pos1 - 1) + SUBSTRING(@Terms, @Pos2 + 2, 400))))
					SET @Pos1 = CHARINDEX('"', @Terms)
				END

			IF LEN(@Terms) > 0
			  SET @WordThis = ''
			  SET @WordLast = ''
				SET @WordEachCount = 1
				SET @WordPairCount = 1
				BEGIN
					SET @Terms = @Terms + ' '
					SET @Pos1 = CHARINDEX(' ', @Terms)
			-- see if there are 3+ terms in phrase
					SET @Pos2 = CHARINDEX(' ', RTRIM(@Terms), @Pos1 + 1)
					IF @Pos2 > 0
						INSERT INTO #s (Op, Tab, SSet, TestOrder, TermA, TermB) VALUES (@Op, @Tab, @Seq, 200, RTRIM(@Terms), NULL)
					WHILE @Pos1 > 0
						BEGIN
							SET @WordThis = LEFT(@Terms, @Pos1 - 1)
							IF LEN(@WordThis) > 0
								INSERT INTO #s (Op, Tab, SSet, TestOrder, TermA, TermB) VALUES (@Op, @Tab, @Seq, 300 + @WordEachCount, @WordThis, NULL)
							SET @WordEachCount = @WordEachCount + 1
							IF LEN(@WordLast) > 0 
								BEGIN
									INSERT INTO #s 
											(Op, Tab, SSet, TestOrder, TermA, TermB) 
										VALUES 
											(@Op, @Tab, @Seq, 200 + @WordPairCount, @WordLast + ' ' + @WordThis, NULL)
									SET @WordPairCount = @WordPairCount + 1
								END
							SET @WordLast = @WordThis
							SET @Terms = LTRIM((SUBSTRING(@Terms, @Pos1 + 1, 400)))
							SET @Pos1 = CHARINDEX(' ', @Terms)
						END
				END	

		  FETCH NEXT FROM curA INTO @Seq, @Op, @Terms, @Tab
		END
	
	CLOSE curA
	DEALLOCATE curA

  DELETE FROM #s WHERE Tab = 'Journal' AND TestOrder > 300
--  DELETE FROM #s WHERE @TermA IS NULL
/*
		SELECT	Seq,
						Op,
						Tab,
						SSet,
						TestOrder,
						Field,
						Status,
						TermA,
						TermB
			FROM #s
*/
-- Find lookup keys from Search words ----------------------------------------------------
	DECLARE curB CURSOR KEYSET FOR
		SELECT	Seq,
						Op,
						Tab,
						SSet,
						TestOrder,
						Field,
						Status,
						TermA,
						TermB
			FROM #s
			ORDER BY SSet,
							 TestOrder
	
	OPEN curB
	FETCH NEXT FROM curB INTO @Seq, @Op, @Tab, @SSet, @TestOrder, @Field, @Status, @TermA, @TermB
	SET @ErrorDesc = ''
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Extra = ''
		IF @Status = 0
	
			EXEC ap_SearchBuildTokens		@TermA,
																	@TermB,
																	@SSet,
																	@TestOrder,
																	@Tab				OUTPUT,
																	@Field			OUTPUT,
																	@Status			OUTPUT,
																	@FindA			OUTPUT,
																	@FindB			OUTPUT,
																	@ErrorDesc	OUTPUT,
																	@Extra			OUTPUT

		IF @Tab IN('Author','Journal','Substance Name','MeSH Term') AND @Status IN( -1,0) AND @TestOrder > 300
			BEGIN
				DROP TABLE #s
				SET @ErrorDesc			= '"' + @TermA + '" was not found as a ' + @Tab
				RETURN		
			END

-- Special processing for Authors
		IF @Tab = 'Author' AND @TestOrder = 201
			UPDATE #s
			  SET Status = -3
				WHERE SSet = @SSet AND 
						  TestOrder <> 201
/*
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: ------------------------------'
print 'ap_SearchBuildFullQuery: @TestOrder: ' + isnull(cast(@TestOrder as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @Tab: ' + isnull(cast(@Tab as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @TestOrder: ' + isnull(cast(@TestOrder as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @TermA: ' + isnull(cast(@TermA as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @Field: ' + isnull(cast(@Field as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @Status: ' + isnull(cast(@Status as varchar(40)),'')
print 'ap_SearchBuildFullQuery: ap_SearchBuildTokens: @FindA: ' + isnull(cast(@FindA as varchar(40)),'')
*/
		IF @ErrorDesc <> ''
			BEGIN
				SET @QueryFinal	= ''
				SET @RunQuery		= 0
				RETURN
			END

--		IF (@TestOrder BETWEEN 300 AND 399) AND (@Tab IN('MeSH Term','Title/Abstract/MeSH Term')) AND (@Status = -1)
--			SET @Status = 2

		IF @Status > 0
			BEGIN
				IF @TestOrder = 200
					BEGIN
					  UPDATE #s
						  SET Status = -2
							WHERE SSet = @SSet AND 
									  TestOrder BETWEEN 300 AND 399 -- each word
					  UPDATE #s
						  SET Status = -3
							WHERE SSet = @SSet AND 
									  TestOrder BETWEEN 201 AND 299 -- all two word phrases
					END

				IF @TestOrder BETWEEN 201 AND 299
					BEGIN
					  UPDATE #s
						  SET Status = -2
							WHERE SSet = @SSet AND 
									  TestOrder BETWEEN (@TestOrder + 100) AND (@TestOrder + 101)  --each word in phrase
					  UPDATE #s
						  SET Status = -3
							WHERE SSet			= @SSet AND 
										TestOrder = @TestOrder + 1  -- following two word phrase
					END
				UPDATE #s
				  SET Status		= @Status,
							Tab				= @Tab,
							Field			= @Field,
							FindA			= @FindA,
							FindB			= @FindB,
						  Extra			= @Extra
					WHERE Seq = @Seq
			END
	  FETCH NEXT FROM curB INTO @Seq, @Op, @Tab, @SSet, @TestOrder, @Field, @Status, @TermA, @TermB
	END

	CLOSE curB
	DEALLOCATE curb

	CREATE TABLE #q (
		QSeq				int 					NOT NULL IDENTITY(1,1) PRIMARY KEY,
		iOp					int 					NOT NULL,	-- 1: Or; 2: And; 3: Not
		SQL					varchar(2000)	NULL,			-- SQL statement
		Details			varchar(200)	NULL,			-- English description
	  SSet				int
	) 
--select * from #s
/*
		SELECT	status,Seq,
						Op,
						Tab,
						SSet,
						TestOrder,
						Field,
						Status,
						FindA,
						FindB,
						TermA,
						TermB,
					  Extra
			FROM #s
			WHERE (Status = 2) OR ((Tab = 'Title/Abstract/Mesh Term') AND (Status = 0) AND (TestOrder > 300 OR TestOrder = 100))
			ORDER BY CASE WHEN Op = 'Any' THEN 1 WHEN Op = 'All' THEN 2 ELSE 3 END,
							 SSet,
							 TestOrder
*/

	DECLARE curC CURSOR KEYSET FOR
		SELECT	Seq,
						Op,
						Tab,
						SSet,
						TestOrder,
						Field,
						Status,
						FindA,
						FindB,
						TermA,
						TermB,
					  Extra
			FROM #s
			WHERE (Status = 2) OR ((Tab = 'Title/Abstract/Mesh Term') AND (Status = 0) AND (TestOrder > 300 OR TestOrder = 100))
			ORDER BY CASE WHEN Op = 'Any' THEN 1 WHEN Op = 'All' THEN 2 ELSE 3 END,
							 SSet,
							 TestOrder


	OPEN curC

	FETCH NEXT FROM curC INTO @Seq, @Op, @Tab, @SSet, @TestOrder, @Field, @Status, @FindA, @FindB, @TermA, @TermB, @Extra
	SET @ErrorDesc = ''
	SET @OpLast = ''
	WHILE @@FETCH_STATUS = 0
		BEGIN

		  EXEC ap_SearchBuildEachQuery_AJA	@Op,
																		@Tab,
																		@Field,
																		@TermA,
																		@TermB,
																		@FindA,
																		@FindB,
																		@TestOrder,
																		@Extra,
																		@FullOld,
																		@FullNew,
																		@FullOldLimit,
																		@QueryOne				OUTPUT,
																		@QueryDetailsW	OUTPUT

--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @Op: ' + isnull(cast(@Op as varchar(40)),'')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @Tab: ' + isnull(cast(@Tab as varchar(40)),'')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @Field: ' + isnull(cast(@Field as varchar(40)),'')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @TermA: ' + isnull(cast(@TermA as varchar(40)),'')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @FindA: ' + isnull(cast(@FindA as varchar(40)),'')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @QueryOne: ' + isnull(@QueryOne,'null')
--print 'ap_SearchBuildFullQuery: ap_SearchBuildEachQuery: @QueryDetailsW: ' + isnull(@QueryDetailsW,'null')


			IF @Op = 'Any' AND @QueryOne <> ''
				INSERT INTO #q(iOP, SQL, Details, SSet) VALUES (1, @QueryOne, @QueryDetailsW, @SSet)

			IF @Op = 'All' AND @QueryOne <> ''
				INSERT INTO #q(iOP, SQL, Details, SSet) VALUES (2, @QueryOne, @QueryDetailsW, @SSet)

			IF @Op = 'Not' AND @QueryOne <> ''
				INSERT INTO #q(iOP, SQL, Details, SSet) VALUES (3, @QueryOne, @QueryDetailsW, @SSet)


				UPDATE #s
				  SET QueryOne	= @QueryOne
					WHERE Seq = @Seq

		  FETCH NEXT FROM curC INTO @Seq, @Op, @Tab, @SSet, @TestOrder, @Field, @Status, @FindA, @FindB, @TermA, @TermB, @Extra
		END
	CLOSE curC
	DEALLOCATE curC

-- Quick error exit - no matching terms ---------------------------------------
  SELECT @RecCount = COUNT(*)
		FROM #s
		WHERE QueryOne IS NOT NULL
  IF @RecCount = 0
	  BEGIN
			DROP TABLE #s
			DROP TABLE #q
			SET @ErrorDesc			= 'No matching terms found'
			RETURN
		END


-- Insure at least one Any
  SELECT @RecCount = COUNT(*)
	  FROM #q
	  WHERE iOP = 1
  IF @RecCount = 0
		BEGIN
		  SELECT @QSeq = MIN(QSeq)
			  FROM #q
			  WHERE iOP = 2
			UPDATE #q
				SET iOP = 1,
					  SSet = 0
				WHERE QSeq = @QSeq
		END


-- build WHERE clause ------------------------------------------------	
	IF LEN(@QueryWhere) = 0
		SET @QueryWhere = ' WHERE '
	ELSE
		SET @QueryWhere = @QueryWhere + ' AND '

	SET @QueryWhere = @QueryWhere + 
										'de>=' + 	CAST(DATEDIFF(d,'1960-01-01',@DateStart) AS varchar(10))	+  ' AND ' + 
										'de<=' + 	CAST(DATEDIFF(d,'1960-01-01',@DateEnd) AS varchar(10))

	IF @PublicationTypeMask > 0
	 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Publication Type: ' + 
				CASE
					WHEN @PublicationTypeMask = 1 THEN 'Clinical Trial'
					WHEN @PublicationTypeMask = 2 THEN 'Clinical Trial Phase I'
					WHEN @PublicationTypeMask = 4 THEN 'Clinical Trial Phase II'
					WHEN @PublicationTypeMask = 8 THEN 'Clinical Trial Phase II+'
					WHEN @PublicationTypeMask = 16 THEN 'Clinical Trial Phase III'
					WHEN @PublicationTypeMask = 32 THEN 'Clinical Trial Phase III+'
					WHEN @PublicationTypeMask = 64 THEN 'Clinical Trial Phase IV'
					WHEN @PublicationTypeMask = 128 THEN 'Editorial'
					WHEN @PublicationTypeMask = 256 THEN 'Letter'
					WHEN @PublicationTypeMask = 512 THEN 'Meta-Analysis'
					WHEN @PublicationTypeMask = 1024 THEN 'Multicenter Study'
					WHEN @PublicationTypeMask = 2048 THEN 'Practice Guideline'
					WHEN @PublicationTypeMask = 4096 THEN 'Randomized Controlled Trial'
					WHEN @PublicationTypeMask = 8192 THEN 'Review'
					ELSE '?'
				END

		SET @QueryWhere = @QueryWhere + ' AND fp&'		+ CAST(@PublicationTypeMask AS varchar(20)) + '>0'
	 END

	IF @SubjectAgeMask > 0
	 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Subject Ages: ' + 
				CASE
					WHEN @SubjectAgeMask = 3 THEN 'All Infant (birth - 23 months)'
					WHEN @SubjectAgeMask = 128 THEN 'All Child (0 - 18 years)'
					WHEN @SubjectAgeMask = 4096 THEN 'All Adult (19+ years)'
					WHEN @SubjectAgeMask = 1 THEN 'Newborn (birth - 1 month)'
					WHEN @SubjectAgeMask = 2 THEN 'Infant (1 - 23 months)'
					WHEN @SubjectAgeMask = 16 THEN 'Preschool Child (2 - 5 years)'
					WHEN @SubjectAgeMask = 32 THEN 'Child (6 - 12 years)'
					WHEN @SubjectAgeMask = 64 THEN 'Adolescent (13 - 18 years)'
					WHEN @SubjectAgeMask = 256 THEN 'Adult (19 - 44 years)'
					WHEN @SubjectAgeMask = 512 THEN 'Middle Aged (45 - 64 years)'
					WHEN @SubjectAgeMask = 1024 THEN 'Aged (65+ years)'
					WHEN @SubjectAgeMask = 2048 THEN '80 and over (80+ years)'
					ELSE '?'
				END
		SET @QueryWhere = @QueryWhere + ' AND fs&' + CAST(@SubjectAgeMask AS varchar(20)) + '>0'
	 END

	IF (@SpeciesMask + @GenderMask + @AbstractMask) > 0
	 BEGIN
		IF @SpeciesMask > 0
		 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Species: ' + 
				CASE
					WHEN @SpeciesMask = 1 THEN 'Human'
					WHEN @SpeciesMask = 2 THEN 'Animal'
					ELSE '?'
				END
		 END
		IF @GenderMask > 0
		 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Gender: ' + 
				CASE
					WHEN @GenderMask = 8 THEN 'Female'
					WHEN @GenderMask = 4 THEN 'Male'
					ELSE '?'
				END
		 END
		IF @AbstractMask > 0
		 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Only Show Citations with Abstracts'
		 END

		SET @QueryWhere = @QueryWhere + ' AND fo&' + CAST((@SpeciesMask | @GenderMask | @AbstractMask) AS varchar(20)) + '>0'
	 END

	IF @LanguageMask > 0
	 BEGIN
		  IF LEN(@QueryDetailsB) > 0
				SET @QueryDetailsB = @QueryDetailsB + '; '
			SET @QueryDetailsB = @QueryDetailsB + 'Language: ' + 
				CASE
					WHEN @LanguageMask = 1 THEN 'English'
					WHEN @LanguageMask = 2 THEN 'French'
					WHEN @LanguageMask = 4 THEN 'German'
					WHEN @LanguageMask = 8 THEN 'Italian'
					WHEN @LanguageMask = 16 THEN 'Japanese'
					WHEN @LanguageMask = 32 THEN 'Russian'
					WHEN @LanguageMask = 64 THEN 'Spanish'
					ELSE '?'
				END
		SET @QueryWhere = @QueryWhere + ' AND fl&' 	+ CAST(@LanguageMask AS varchar(20)) + '>0'
	 END

	IF @SearchMode = 1		SET @QueryWhere = @QueryWhere + ' AND du=' + 	CAST(DATEDIFF(d,'1960-01-01',@ThisAutorunDate) AS varchar(10))

/*
SELECT PMID INTO #base	FROM (SELECT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=4247 
UNION SELECT PMID FROM iWide WHERE CONTAINS(*,'DNA') ) a
SELECT b.PMID, dps,dpe,de,fp,fs,fo,fl,sa,st,sj
	INTO #pre2
	FROM #base b	INNER LOOP JOIN iCitationScreen c ON c.PMID=b.PMID   WHERE dpe>='01/01/1960' AND dps<='12/31/2002' AND fp&2>0 ORDER BY st*/

-- build final query ------------------------------------------------	

	DECLARE curQ CURSOR FOR
		SELECT	QSeq,
						iOP,
						SQL,
						Details,
						SSet
		FROM #q
		ORDER BY iOP, SSet, QSeq
	
	OPEN curQ

DECLARE @CloseAllWithJoin int
SET @CloseAllWithJoin = 0

SET @QueryFinal = 'SELECT a.PMID INTO #base FROM (' + @cr

SET @iOpLast = 0
SET @SSetLast = 0
SET @JoinLine = 0	FETCH NEXT FROM curQ INTO @QSeq, @iOP, @SQL, @Details, @SSet
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @JoinLine = @JoinLine  + 1
			IF @iOP = 1
				BEGIN
					IF @iOpLast = 0
						BEGIN
							SET @QueryFinal = @QueryFinal + @SQL
							SET @QueryDetails = '(' + @Details
						END
					IF @iOpLast > 0 AND @SSetLast = @SSet
						BEGIN
							SET @QueryFinal = @QueryFinal + '	UNION ' + @SQL 
							SET @QueryDetails = @QueryDetails + ' OR ' + @Details
						END
					IF @iOpLast > 0 AND @SSetLast <> @SSet
						BEGIN
							IF @SSetLast = 1
								BEGIN
									SET @QueryFinal = @QueryFinal + ') a' + @cr +
																		' JOIN (' + @SQL 
									SET @QueryDetails = @QueryDetails + ') AND (' + @Details
									SET @CloseAllWithJoin = 1
								END
							ELSE
								BEGIN
									SET @QueryFinal = @QueryFinal + ') K' + CAST(@JoinLine AS varchar(10)) + ' ON K' + CAST(@JoinLine AS varchar(10)) + '.pmid = a.pmid' + 
																		'	JOIN (' + @SQL + @cr
									SET @QueryDetails = @QueryDetails + ') AND (' + @Details
									SET @CloseAllWithJoin = 1
								END
						END
				END

			IF @iOP IN (2,3) AND @iOpLast = 1
				IF @CloseAllWithJoin = 0
					BEGIN
						SET @QueryFinal = @QueryFinal + ') a' + @cr
						SET @QueryDetails = @QueryDetails + ')'
					END
				ELSE
					BEGIN
						SET @QueryFinal = @QueryFinal + ') J' + CAST(@JoinLine AS varchar(10)) + ' ON J' + CAST(@JoinLine AS varchar(10)) + '.pmid = a.pmid' + @cr
						SET @QueryDetails = @QueryDetails
					END

			IF @iOP = 2
				BEGIN
					SET @QueryFinal = @QueryFinal + '	JOIN (' + @SQL + ') H' + CAST(@JoinLine AS varchar(10)) + ' ON H' + CAST(@JoinLine AS varchar(10)) + '.pmid = a.pmid' + @cr
					SET @QueryDetails = @QueryDetails + ' AND ' + @Details
				END

			IF @iOP = 3
				BEGIN
					SET @QueryFinal = @QueryFinal + 'LEFT JOIN (' + @SQL + ') n' + CAST(@JoinLine AS varchar(10)) + ' on n' + CAST(@JoinLine AS varchar(10)) + '.pmid = a.pmid ' + @cr
					IF LEN(@BaseWhere) > 0
						SET @BaseWhere = @BaseWhere + ' AND'
					SET @BaseWhere = @BaseWhere + ' n' + CAST(@JoinLine AS varchar(10)) + '.PMID IS NULL' + @cr
					SET @QueryDetails = @QueryDetails + '	NOT ' + @Details
				END

			SET @iOpLast = @iOP
		  SET @SSetLast = @SSet
			FETCH NEXT FROM curQ INTO @QSeq, @iOP, @SQL, @Details, @SSet
	
		END
	
	CLOSE curQ
	DEALLOCATE curQ

	IF @iOpLast = 1 
		IF @SSet <= 1
			BEGIN
				SET @QueryFinal = @QueryFinal + ') a' + @cr
				SET @QueryDetails = @QueryDetails + ')'
			END
		ELSE
			BEGIN
				SET @QueryFinal = @QueryFinal + ') M' + CAST(@JoinLine AS varchar(10)) + ' on M' + CAST(@JoinLine AS varchar(10)) + '.pmid = a.pmid' + @cr
				SET @QueryDetails = @QueryDetails + ')'
			END
	IF LEN(@BaseWhere) > 0
		SET @BaseWhere = 'WHERE' + @BaseWhere

SET @QueryFinal = @QueryFinal + @BaseWhere + @cr + 
'SELECT b.PMID,IDENTITY(int,1,1) AS List ' + @cr +
'	INTO #pre2' + @cr +
'	FROM #base b' + @cr +'	INNER LOOP JOIN iCitationScreen c ON c.PMID=b.PMID ' + @cr +CASE WHEN LEN(@QueryWhere) > 0 THEN
  @QueryWhere
ELSE
  ''
END +
CASE @SearchSort
	WHEN 1 THEN '	ORDER BY dps DESC' + @cr
	WHEN 2 THEN '	ORDER BY sa' + @cr
	WHEN 3 THEN '	ORDER BY st' + @cr
	WHEN 4 THEN '	ORDER BY sj' + @cr
	ELSE ''
END +
@cr +
CASE WHEN @SearchMode = 0 THEN'UPDATE AJA_Dev.dbo.SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr +'SELECT * INTO #pre3 FROM #pre2 WHERE LIST BETWEEN 1 AND 1000' + @cr +'DELETE FROM AJA_Dev.dbo.SearchResults WHERE SearchID =' + CAST(@SearchID as varchar(20)) + @cr +'INSERT INTO AJA_Dev.dbo.SearchResults (SearchID, PMID, List) SELECT ' + CAST(@SearchID as varchar(20)) + ', PMID, List FROM #pre3' + @cr
ELSE
'SELECT p.PMID,' + CAST(@ResultsFolder1 as varchar(10)) + ' AS ''f1'',' +  + CAST(@ResultsFolder2 as varchar(10)) + ' AS ''f2'', CAST(''' + @tad + ''' AS smalldatetime) AS ''c'', 1 AS ''s'',DATEADD(d,' + CAST(@ShelfLife AS varchar(10)) + ',''' + @tad + ''') AS ''e'',' + CAST(@KeepDelete AS varchar(2)) + ' AS ''k'' INTO #pre3 FROM #pre2 p ' + @cr +
--'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + ' ' + @cr +
--'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + @cr +
--'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f1,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr +
  CASE WHEN @ResultsFolder2 <> 0 THEN
		'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + ' ' + @cr +
		'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + @cr +
		'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f2,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr + 
	  'UPDATE AJA_Dev.dbo.SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr	ELSE
		''
	END 
END +
@cr +
'drop table #base' + @cr +
'drop table #pre2' + @cr +
'drop table #pre3' + @cr

--if @SearchMode <> 0
SET @RunQuery = 1
  IF LEN(@QueryDetailsB) > 1
	  SET @QueryDetails = @QueryDetails + ' LIMITS: ' + @QueryDetailsB
ExitPoint:
--print 'xxx'
--print @QueryFinal
/*
-- *****************************************************************
select Seq, Op, Terms, Tab FROM AJA_Dev.dbo.SearchDetails WHERE SearchID	= @SearchID ORDER by Seq
select * from #s order by sset, TestOrder
SELECT * FROM #q
print @QueryDetails
-- *****************************************************************
*/

	DROP TABLE #q
	DROP TABLE #s


--print @QueryFinal

USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryGet]    Script Date: 10/11/2013 13:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create PROCEDURE [dbo].[ap_SearchQueryGet_AJA]
  @UserID					int,
	@SearchName			varchar(100),
  @SearchID				int
											
AS
  DECLARE @RecCount				int
	DECLARE @Op1						char(3)
  DECLARE @Terms1					varchar(100)
	DECLARE @Tab1						varchar(35)
	DECLARE @Op2						char(3)
  DECLARE @Terms2					varchar(100)
	DECLARE @Tab2						varchar(35)
	DECLARE @Op3						char(3)
  DECLARE @Terms3					varchar(100)
	DECLARE @Tab3						varchar(35)
	DECLARE @Op4						char(3)
  DECLARE @Terms4					varchar(100)
	DECLARE @Tab4						varchar(35)
	DECLARE @Op5						char(3)
  DECLARE @Terms5					varchar(100)
	DECLARE @Tab5						varchar(35)
	DECLARE @Op6						char(3)
  DECLARE @Terms6					varchar(100)
	DECLARE @Tab6						varchar(35)
	DECLARE @PublicationTypeMask	smallint
	DECLARE @SubjectAgeMask	smallint
	DECLARE @LanguageMask		tinyint
	DECLARE @SpeciesMask		tinyint
	DECLARE @GenderMask			tinyint
  DECLARE @AbstractMask		tinyint
	DECLARE @PaperAge				tinyint
	DECLARE @DateStart			smallint
	DECLARE @DateEnd				smallint
  DECLARE @SearchSort			tinyint
  DECLARE @AutoSearch 		tinyint
  DECLARE @ShelfLife 			smallint
  DECLARE @Description		varchar(500)
  DECLARE @LastAutorunHits		int
  DECLARE @LastAutorunDate		smalldatetime
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1	int
  DECLARE @ResultsFolder2	int
  DECLARE @UserDB					varchar(50)
  DECLARE @KeepDelete			tinyint
	DECLARE @Seq						int
	DECLARE @Op							char(3)
	DECLARE @Terms					varchar(100)
	DECLARE @Tab						varchar(35)
  SET NOCOUNT ON
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM AJA_Dev.dbo.SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  SELECT	@PublicationTypeMask	= PublicationTypeMask,
					@SubjectAgeMask				= SubjectAgeMask,
					@LanguageMask					= LanguageMask,
					@SpeciesMask					= SpeciesMask,
					@GenderMask						= GenderMask,
					@AbstractMask					= AbstractMask,
					@PaperAge							= PaperAge,
					@DateStart						= DATEPART(yyyy,DateStart),
					@DateEnd							= DATEPART(yyyy,DateEnd),
					@UserID								= UserID,
					@SearchSort						= SearchSort,
					@SearchName						= SearchName,
					@AutoSearch						= AutoSearch,
					@ShelfLife						= ShelfLife,
					@Description					= Description,
					@LastAutorunHits			= LastAutorunHits,
					@LastAutorunDate			= LastAutorunDate,
					@LimitToUserLibrary		= LimitToUserLibrary,
					@ResultsFolder1				= ResultsFolder1,
					@ResultsFolder2				= ResultsFolder2,
					@UserDB								= UserDB,
					@KeepDelete						= KeepDelete
	  FROM AJA_Dev.dbo.SearchSummary
		WHERE SearchID = @SearchID
  DECLARE cur CURSOR FOR
	  SELECT Seq, Op, Terms, Tab
		  FROM AJA_Dev.dbo.SearchDetails
			WHERE SearchID = @SearchID
			ORDER BY Seq
	OPEN cur
	FETCH NEXT FROM cur INTO @Seq, @Op, @Terms, @Tab
  WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Seq = 1 AND @Terms IS NOT NULL
				BEGIN
					SET @Op1		= @Op
					SET @Terms1 = @Terms
					SET @Tab1	  = @Tab
				END
			IF @Seq = 2 AND @Terms IS NOT NULL
				BEGIN
					SET @Op2		= @Op
					SET @Terms2 = @Terms
					SET @Tab2	  = @Tab
				END
			IF @Seq = 3 AND @Terms IS NOT NULL
				BEGIN
					SET @Op3		= @Op
					SET @Terms3 = @Terms
					SET @Tab3	  = @Tab
				END
			IF @Seq = 4 AND @Terms IS NOT NULL
				BEGIN
					SET @Op4		= @Op
					SET @Terms4 = @Terms
					SET @Tab4	  = @Tab
				END
			IF @Seq = 5 AND @Terms IS NOT NULL
				BEGIN
					SET @Op5		= @Op
					SET @Terms5 = @Terms
					SET @Tab5	  = @Tab
				END
			IF @Seq = 6 AND @Terms IS NOT NULL
				BEGIN
					SET @Op6		= @Op
					SET @Terms6 = @Terms
					SET @Tab6	  = @Tab
				END
			FETCH NEXT FROM cur INTO @Seq, @Op, @Terms, @Tab
		END
  CLOSE cur
	DEALLOCATE cur
  SELECT	@UserID                   AS 'UserID',
					@SearchName               AS 'SearchName',
					@SearchID                 AS 'SearchID',
					@Op1                      AS 'Op1',
					@Terms1                   AS 'Terms1',
					@Tab1                     AS 'Tab1',
					@Op2                      AS 'Op2',
					@Terms2                   AS 'Terms2',
					@Tab2                     AS 'Tab2',
					@Op3                      AS 'Op3',
					@Terms3                   AS 'Terms3',
					@Tab3                     AS 'Tab3',
					@Op4                      AS 'Op4',
					@Terms4                   AS 'Terms4',
					@Tab4                     AS 'Tab4',
					@Op5                      AS 'Op5',
					@Terms5                   AS 'Terms5',
					@Tab5                     AS 'Tab5',
					@Op6                      AS 'Op6',
					@Terms6                   AS 'Terms6',
					@Tab6                     AS 'Tab6',
					@PublicationTypeMask      AS 'PublicationTypeMask',
					@SubjectAgeMask           AS 'SubjectAgeMask',
					@LanguageMask             AS 'LanguageMask',
					@SpeciesMask              AS 'SpeciesMask',
					@GenderMask               AS 'GenderMask',
					@AbstractMask             AS 'AbstractMask',
					@PaperAge                 AS 'PaperAge',
					@DateStart                AS 'DateStart',
					@DateEnd                  AS 'DateEnd',
					@SearchSort               AS 'SearchSort',
					@SearchName								AS 'SearchName',
					@AutoSearch								AS 'AutoSearch',
					@ShelfLife								AS 'ShelfLife',
					@Description							AS 'Description',
					@LimitToUserLibrary				AS 'LimitToUserLibrary',
					@LastAutorunHits					AS 'LastAutorunHits',
					@LastAutorunDate					AS 'LastAutorunDate',
					@ResultsFolder1						AS 'ResultsFolder1',
					@ResultsFolder2						AS 'ResultsFolder2',
					@UserDB										AS 'UserDB',
					@KeepDelete								AS 'KeepDelete'



/** get topics from spectlity for a user**/
/****** Object:  StoredProcedure [dbo].[lib_GetFoldersAndEC20Citations]    Script Date: 10/17/2013 15:48:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[lib_GetFoldersAndEC20Citations]
	@UserID int,
	@SpecialtyID int
AS
BEGIN
	SELECT DISTINCT t.TopicID As OrgFolderID, t.TopicName As OrgFolderName,
		st.SubTopicID As FunFolderID, st.SubTopicName As FunFolderName,
		st.Type As FunType, t.Type As OrgType, 
		t.TopicID As OrgTemplate, st.SubTopicID As FunTemplate,
		t.SpecialtyID As Specialty,
		TopicOrder = CASE t.Type WHEN 3 THEN 2 ELSE 1 END
	FROM Topics t
		JOIN SubTopics st ON st.TopicID = t.TopicID
		WHERE 
			(t.type = 1 
			OR (t.type = 2 AND t.UserID = @UserID)
			OR (t.type = 3 AND 
	t.TopicID IN (SELECT TopicID FROM UserHasSponsorTopic WHERE UserID = @UserID)))
		AND (st.type <> 2 OR st.UserID = @UserID) 
		AND t.SpecialtyID = @SpecialtyID
		AND t.TopicID NOT IN 
			(SELECT TopicID FROM HiddenTopics WHERE UserID = @UserID)
		AND st.SubTopicID NOT IN
			(SELECT SubTopicID FROM HiddenSubTopics WHERE UserID = @UserID)
	ORDER BY TopicOrder, OrgFolderName, FunFolderName
END

/**Alter Non Medline Citions table --> ArticleTitle for provinding search ***/
alter table dbo.NonMedlineCitations alter column ArticleTitle nvarchar(max)

/*Alter AJA_Table Users from nullable bit to not nullable -RaviM 10/23/2013*/
alter table dbo.AJA_tbl_Users alter column IseditorEmaiSend BIT NOT NULL









