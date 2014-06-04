/* Start Deleting All Procedures and Functions*/
declare @procName varchar(500)
declare cur cursor
for
select [name] from sys.objects
where type in (N'P', N'PC')
open cur
fetch next from cur into @procName
while @@fetch_status = 0
begin
    exec('drop procedure [' + @procName+']')
    fetch next from cur into @procName
end
close cur
deallocate cur
GO
declare @procName varchar(500)
declare cur cursor
for
select [name] from sys.objects
where type in (N'FN', N'IF', N'TF', N'FS', N'FT')
open cur
fetch next from cur into @procName
while @@fetch_status = 0
begin
    exec('drop function [' + @procName+']')
    fetch next from cur into @procName
end
close cur
deallocate cur
GO

/* End Deleting All Procedures and Functions*/


/* Start User Defined Functions*/


GO
/****** Object:  UserDefinedFunction [dbo].[RemoveNonASCII]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RemoveNonASCII] 
(
	@nstring nvarchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN

	DECLARE @Result varchar(MAX)
	SET @Result = ''

	DECLARE @nchar nvarchar(1)
	DECLARE @position int

	SET @position = 1
	WHILE @position <= LEN(@nstring)
	BEGIN
		SET @nchar = SUBSTRING(@nstring, @position, 1)
		--Unicode & ASCII are the same from 1 to 255.
		--Only Unicode goes beyond 255
		--0 to 31 are non-printable characters
		IF UNICODE(@nchar) between 32 and 255
			SET @Result = @Result + @nchar
		SET @position = @position + 1
	END

	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetThreadPMIDList]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fnGetThreadPMIDList]
(
	@threadID int,
	@delimiter as char(1)
)
RETURNS varchar(1000) as
BEGIN

-- Pass in a thread id and a delimiter and get back a delimited
-- list of all the PMIDs which are part of the Thread

	DECLARE @pmid int
	DECLARE @ret varchar(1000)

	DECLARE csr CURSOR LOCAL FAST_FORWARD FOR
	SELECT PMID FROM ArticleSelections WHERE ThreadID=@threadID
	ORDER BY SortOrder

	OPEN csr

	FETCH NEXT FROM csr
	INTO @pmid

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @ret IS NULL
			SET @ret= CAST(@pmid as varchar(20))
		ELSE
			SET @ret= @ret + @delimiter + CAST(@pmid as varchar(20))


		FETCH NEXT FROM csr
		INTO @pmid
	END
		
			
	RETURN @ret
END
GO
/****** Object:  UserDefinedFunction [dbo].[lib_GetThreadTopics]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 
-- Retrieves the list of topics and sub-topics for a given thread
--	Copyright (c) 2006 Cogent Medicine
--
-- =============================================
create FUNCTION [dbo].[lib_GetThreadTopics] 
(
	@EditionID INT,
	@ThreadID INT
)
RETURNS NVARCHAR(1024)
AS
BEGIN
	DECLARE @TopicList NVARCHAR(1024), @ThisTopic NVARCHAR(50), @ThisSubTopic NVARCHAR(50)

	DECLARE TopicCursor CURSOR FOR
	SELECT t.TopicName, st.SubTopicName
	FROM Topics t
	JOIN SubTopics st ON st.TopicID = t.TopicID
	JOIN SubTopicReferences stref ON stref.SubTopicID = st.SubTopicID
	WHERE stref.EditionID = @EditionID
	AND stref.ThreadID = @ThreadID
	ORDER BY t.TopicName, st.SubTopicName

	OPEN TopicCursor

	FETCH NEXT FROM TopicCursor INTO @ThisTopic, @ThisSubTopic
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TopicList IS NULL
			SET @TopicList = @ThisTopic + '&nbsp;|&nbsp;' + @ThisSubTopic
		ELSE
			SET @TopicList = @TopicList + ', ' + @ThisTopic + '&nbsp;|&nbsp;' + @ThisSubTopic
			
		FETCH NEXT FROM TopicCursor INTO @ThisTopic, @ThisSubTopic
	END

	CLOSE TopicCursor
	DEALLOCATE TopicCursor

	RETURN @TopicList
END
GO
/****** Object:  UserDefinedFunction [dbo].[lib_GetThreadEditors]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 
-- Retrieves the list of editors for a given thread
--	Copyright (c) 2006 Cogent Medicine
--
-- =============================================
create FUNCTION [dbo].[lib_GetThreadEditors] 
(
	-- Add the parameters for the function here
	@EditionID INT,
	@ThreadID INT
)
RETURNS NVARCHAR(1024)
AS
BEGIN

	DECLARE @EdName NVARCHAR(50), @Final NVARCHAR(1024)

	DECLARE EdCursor CURSOR FOR
	SELECT ed.[Name]
	FROM SubTopicEditorRefs ster
	JOIN CommentAuthors ed ON ster.EditorID = ed.ID
	WHERE ster.EditionID = @EditionID
	AND ster.ThreadID = @ThreadID
	ORDER BY ster.Seniority

	OPEN EdCursor
	FETCH NEXT FROM	EdCursor INTO @EdName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @Final IS NULL
			Set @Final = @EdName
		ELSE
			Set @Final = @Final + ', ' + @EdName

		FETCH NEXT FROM	EdCursor INTO @EdName
	END
	CLOSE EdCursor
	DEALLOCATE EdCursor

	RETURN @Final

END
GO
/****** Object:  UserDefinedFunction [dbo].[lib_IsEditorComment]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
--
-- Determines whether a given comment was authored by
-- all of the editors, and noone but the editors
-- =============================================
CREATE FUNCTION [dbo].[lib_IsEditorComment] 
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
GO
/****** Object:  UserDefinedFunction [dbo].[lib_GetCommentAuthors]    Script Date: 10/22/2013 10:58:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
-- =============================================
CREATE FUNCTION [dbo].[lib_GetCommentAuthors] 
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
GO



/* End Start User Defined Functions*/



/* Start Stored Procedures*/


GO
/****** Object:  StoredProcedure [dbo].[lib_GetGeneLinksByGeneID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetGeneLinksByGeneID]
(
	@GeneID int,
	@num int = null
) as
begin

	declare @top_str varchar(100)

	if @num is null set @top_str = ''
	else			set @top_str = 'top '+ cast(@num as varchar)

	exec('select '+ @top_str +' ArticleID, ArticleTitle, Year,  (select top 1 AuthorName from ArticlesAuthors t1 where t1.ArticleID = t2.ArticleID) as AuthorList
			from GenesArticles t2		
				where GeneID = '+ @GeneID)

end
GO
/****** Object:  StoredProcedure [dbo].[adm_GetLibrarySubTopics]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Copyright (c) 2006 Cogent Medicine
-- =============================================
create PROCEDURE [dbo].[adm_GetLibrarySubTopics] 
	@TopicID int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT SubTopicID, SubTopicName
	FROM SubTopics
	WHERE Type =1 AND TopicID = @TopicID
	ORDER BY SubTopicName
END
GO
/****** Object:  StoredProcedure [dbo].[adm_GetEditionTopics]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Paul Keister
-- Copyright (c) 2006 Cogent Medicine
--
-- Gets list of topics for the slected edition
-- =============================================
create PROCEDURE [dbo].[adm_GetEditionTopics] 
	@EditionID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT t.TopicID, t.TopicName
	FROM Topics t
	JOIN Editions e ON t.SpecialtyID = e.SpecialtyID
	--JOIN EditorTopics et ON et.TopicID = t.TopicID
	WHERE e.EditionID = @EditionID
	--AND et.RetireDate IS NULL
	AND t.Type = 1
	ORDER BY t.TopicName
END
GO
/****** Object:  StoredProcedure [dbo].[adm_GetEditions]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[adm_GetEditions]
AS

SET NOCOUNT ON

SELECT e.*,s.SpecialtyName FROM Editions e
INNER JOIN Specialties s ON s.SpecialtyID=e.SpecialtyID
ORDER BY PubDate DESC
GO
/****** Object:  StoredProcedure [dbo].[adm_GetEditionDetails]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Copyright (c) 2007 Cogent Medicine
-- =============================================
Create PROCEDURE [dbo].[adm_GetEditionDetails] 
	@EditionID int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ed.SpecialtyID, sp.SpecialtyName, ed.PubDate 
	FROM Editions ed
	JOIN Specialties sp ON ed.SpecialtyID = sp.SpecialtyID
	WHERE ed.EditionID = @EditionID
END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchPMID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchFetchPMID]
  @UserID					int,
	@SearchName			varchar(100),
  @SearchID				int,
	@PMID						int
AS

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
  INSERT INTO SearchView (UserID, SearchID, ViewPMID) VALUES (@UserID, @SearchID, @PMID)
  SELECT	c.PMID,
					ISNULL(w.ArticleTitle,wn.ArticleTitle) AS 'ArticleTitle',
					AuthorList,
					MedlineTA,
					MedlinePgn,
					DisplayDate,
					DisplayNotes
    FROM iCitation c
		LEFT JOIN iWide w ON w.PMID = c.PMID
		LEFT JOIN iWideNew wn ON wn.PMID = c.PMID
		WHERE c.PMID = @PMID
GO
/****** Object:  StoredProcedure [dbo].[lib_RemoveSponsorTopic]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_RemoveSponsorTopic]
	@UserID INT, @TopicID INT
AS
BEGIN
	DECLARE @SponsorID INT
	SET @SponsorID = (SELECT SponsorID FROM SponsorTopics WHERE TopicID = @TopicID)

	DELETE FROM UserHasSponsorTopic
	WHERE TopicID = @TopicID AND UserID = @UserID

	DELETE FROM UserHasSponsorFolder
	WHERE UserID = @UserID AND SponsorFolderId = @SponsorID

END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetUserSubTopics]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetUserSubTopics]
	@UserID int,	
	@TopicID int
AS
BEGIN
	select st.SubTopicID,st.SubTopicName from
SubTopics st
join 
Topics t on st.TopicID=t.TopicID 
WHERE
		(st.type = 1 
			OR (st.type = 2 AND st.UserID = @UserID)
			OR (st.type = 3))
			and st.TopicID=@TopicID			
			AND (st.type <> 2 OR st.UserID = @UserID)
			AND st.SubTopicID NOT IN
			(SELECT SubTopicID FROM HiddenSubTopics WHERE UserID = @UserID)
			
			order by st.SubTopicName 
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetUnsubscribedSpecialties]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[lib_GetUnsubscribedSpecialties]
	@UserID Int
			
AS
BEGIN

	SELECT 	*
	FROM 		Specialties
	WHERE	( isInUse = 1 ) AND SpecialtyID NOT IN (
								SELECT 	SpecialtyID
								FROM 		UserSpecialties
								WHERE 	UserID = @UserID
					     		           )

	
END
GO
/****** Object:  StoredProcedure [dbo].[SearchQueryGet]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[SearchQueryGet]
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
				--	@SearchName								AS 'SearchName',
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
GO
/****** Object:  StoredProcedure [dbo].[lib_DeleteUserAutoQueries]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[lib_DeleteUserAutoQueries]
	@SpecialtyID int,
	@UserID int
	
AS
BEGIN

	-------- BEGIN: Clearing auto-query stuff associated with specialty being deleted --------

	-- Get list of SearchIDs for specified specialty
	DECLARE SearchIdCursor CURSOR FOR 
		SELECT DISTINCT SearchID
		FROM SearchSummary
		WHERE UserID = @UserID AND
	              ResultsFolder2 IN ( SELECT SubTopics.SubTopicID FROM SubTopics INNER JOIN Topics ON SubTopics.TopicID = Topics.TopicID WHERE SpecialtyID = @SpecialtyID ) 
	              
	
	-- This will get filled in as we walk through cursor.	
	DECLARE @SearchID int;	

	-- Open cursor and get first value from it.
	OPEN SearchIdCursor
	FETCH NEXT FROM SearchIdCursor INTO @SearchID
	
	-- For each search id, delete it from SearchSummary, SearchDetails, SearchResults 
 	WHILE @@FETCH_STATUS = 0 
	 	BEGIN

			-- Delete this SearchID from SearchSummary.
			DELETE
			FROM SearchSummary
			WHERE SearchID = @SearchID;
			
			-- Delete this SearchID from SearchDetails.
			DELETE
			FROM SearchDetails
			WHERE SearchID = @SearchID;

			-- Delete this SearchID from SearchResults.
			DELETE
			FROM SearchResults
			WHERE SearchID = @SearchID;
	
			-- Get next SearchID.
	 		FETCH NEXT FROM SearchIdCursor INTO @SearchID

	 	END
	
	-- Close and dump cursor.
	CLOSE SearchIdCursor
 	DEALLOCATE SearchIdCursor

	-------- END: Clearing auto-query stuff associated with specialty being deleted --------

END
GO
/****** Object:  StoredProcedure [dbo].[lib_DeleteSearchesFromSubTopic]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[lib_DeleteSearchesFromSubTopic]
	@SubTopicID Int,
	@UserID Int

AS
	DECLARE @SearchID INT
	
	--DECLARE SearchIDCursor CURSOR FOR
	--	SELECT SearchID
	--	FROM CogentSearch..SearchSummary
	--	WHERE ResultsFolder2 = @SubTopicID
	--		AND UserID = @UserID
	--		AND UserDB = dbo.lib_GetCurrentDbName()

	--OPEN SearchIDCursor
	--FETCH NEXT FROM SearchIDCursor INTO @SearchID
	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	--	DELETE FROM CogentSearch..SearchResults WHERE SearchID = @SearchID
	--	DELETE FROM CogentSearch..SearchDetails WHERE SearchID = @SearchID
	--	DELETE FROM CogentSearch..SearchSummary WHERE SearchID = @SearchID

	--	FETCH NEXT FROM SearchIDCursor INTO @SearchID
	--END

	--CLOSE SearchIDCursor
	--DEALLOCATE SearchIDCursor
	
	
	DELETE a
FROM SearchResults a,  
   SearchSummary b
WHERE a.SearchID = b.SearchID
AND b.ResultsFolder2 = @SubTopicID
                  AND b.UserID = @UserID
 
 
 
DELETE a
FROM SearchDetails a,  
   SearchSummary b
WHERE a.SearchID = b.SearchID
AND b.ResultsFolder2 = @SubTopicID
                  AND b.UserID = @UserID
 
 
DELETE b
FROM SearchSummary b
WHERE b.ResultsFolder2 = @SubTopicID
                  AND b.UserID = @UserID
GO
/****** Object:  StoredProcedure [dbo].[lib_CreateSponsorFolderSFE]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_CreateSponsorFolderSFE]
	@UserID INT,
	@UserSpecialty INT,
	@SponsorFolderID INT,
	@TopicFolderID INT OUT
AS
BEGIN
	DECLARE @SponsorTopicID INT

	/*
	If the user's primary specialty is qualified, the sponsor folder will be 
	placed in the primary specialty library.  Otherwise, the most relevant 
	specialty will be chosed according to a relevancy rangking set in the 
	qualification data.
	*/
	SET @SponsorTopicID = (SELECT st.TopicID
				FROM SponsorTopics st
				JOIN Topics t ON st.TopicID = t.TopicID
				WHERE t.SpecialtyID = @UserSpecialty
				AND st.SponsorID = @SponsorFolderID)

	If @SponsorTopicID IS NULL
	BEGIN
		-- Higher relevance numbers are selected first
		SET @SponsorTopicID = (SELECT TOP 1 st.TopicID
					FROM SponsorTopics st
					JOIN Topics t ON st.TopicID = t.TopicID
					JOIN UserSpecialties us ON t.SpecialtyID = us.SpecialtyID
					WHERE us.UserID = @UserID
					AND st.SponsorID = @SponsorFolderID
					ORDER BY st.Relevance DESC)

	END

	
	--Set topic folder ID to the topic that has been chosen
	SET @TopicFolderID = @SponsorTopicID

	INSERT INTO UserHasSponsorTopic(UserID, TopicID)
	VALUES(@UserID, @TopicFolderID)
END
GO
/****** Object:  StoredProcedure [dbo].[lib_CopyUserCitation_MyQueries]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_CopyUserCitation_MyQueries]
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
	
			
			
		INSERT INTO UserCitations(UserID, PMID, SubTopicID, IsAutoQueryCitation,Deleted,KeepDelete,SearchID,ExpireDate)
			VALUES               (@userid, @pmid, @SubTopicID, 0,0,@KeepDelete,@SearchID,@ExpireDate)
	END

	-- Finally, get a specialty reference for the destination
	-- folder
	SET @SpecialtyID = (SELECT t.SpecialtyID
		FROM Topics t
		JOIN SubTopics st ON st.TopicID = t.TopicID
		WHERE st.SubTopicID = @SubTopicID)
END
GO
/****** Object:  StoredProcedure [dbo].[lib_CopyUserCitation]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_CopyUserCitation]
	@pmid INT, 
	@SubTopicID INT, 
	@userid INT,
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
		INSERT INTO UserCitations(UserID, PMID, SubTopicID,[IsAutoQueryCitation], Deleted,KeepDelete,SearchID,[ExpireDate])
			VALUES(@userid, @pmid, @SubTopicID,0, 0,1,0,'')
	END

	-- Finally, get a specialty reference for the destination
	-- folder
	SET @SpecialtyID = (SELECT t.SpecialtyID
		FROM Topics t
		JOIN SubTopics st ON st.TopicID = t.TopicID
		WHERE st.SubTopicID = @SubTopicID)
END
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_LogError]
(
    @ErrorId UNIQUEIDENTIFIER,
    @Application NVARCHAR(60),
    @Host NVARCHAR(30),
    @Type NVARCHAR(100),
    @Source NVARCHAR(60),
    @Message NVARCHAR(500),
    @User NVARCHAR(50),
    @AllXml NTEXT,
    @StatusCode INT,
    @TimeUtc DATETIME
)
AS

    SET NOCOUNT ON

    INSERT
    INTO
        [ELMAH_Error]
        (
            [ErrorId],
            [Application],
            [Host],
            [Type],
            [Source],
            [Message],
            [User],
            [AllXml],
            [StatusCode],
            [TimeUtc]
        )
    VALUES
        (
            @ErrorId,
            @Application,
            @Host,
            @Type,
            @Source,
            @Message,
            @User,
            @AllXml,
            @StatusCode,
            @TimeUtc
        )
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorXml]
(
    @Application NVARCHAR(60),
    @ErrorId UNIQUEIDENTIFIER
)
AS

    SET NOCOUNT ON

    SELECT 
        [AllXml]
    FROM 
        [ELMAH_Error]
    WHERE
        [ErrorId] = @ErrorId
    AND
        [Application] = @Application
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorsXml]
(
    @Application NVARCHAR(60),
    @PageIndex INT = 0,
    @PageSize INT = 15,
    @TotalCount INT OUTPUT
)
AS 

    SET NOCOUNT ON

    DECLARE @FirstTimeUTC DATETIME
    DECLARE @FirstSequence INT
    DECLARE @StartRow INT
    DECLARE @StartRowIndex INT

    SELECT 
        @TotalCount = COUNT(1) 
    FROM 
        [ELMAH_Error]
    WHERE 
        [Application] = @Application

    -- Get the ID of the first error for the requested page

    SET @StartRowIndex = @PageIndex * @PageSize + 1

    IF @StartRowIndex <= @TotalCount
    BEGIN

        SET ROWCOUNT @StartRowIndex

        SELECT  
            @FirstTimeUTC = [TimeUtc],
            @FirstSequence = [Sequence]
        FROM 
            [ELMAH_Error]
        WHERE   
            [Application] = @Application
        ORDER BY 
            [TimeUtc] DESC, 
            [Sequence] DESC

    END
    ELSE
    BEGIN

        SET @PageSize = 0

    END

    -- Now set the row count to the requested page size and get
    -- all records below it for the pertaining application.

    SET ROWCOUNT @PageSize

    SELECT 
        errorId     = [ErrorId], 
        application = [Application],
        host        = [Host], 
        type        = [Type],
        source      = [Source],
        message     = [Message],
        [user]      = [User],
        statusCode  = [StatusCode], 
        time        = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'
    FROM 
        [ELMAH_Error] error
    WHERE
        [Application] = @Application
    AND
        [TimeUtc] <= @FirstTimeUTC
    AND 
        [Sequence] <= @FirstSequence
    ORDER BY
        [TimeUtc] DESC, 
        [Sequence] DESC
    FOR
        XML AUTO
GO
/****** Object:  StoredProcedure [dbo].[lib_GetDefaultSubTopic]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetDefaultSubTopic]
	@UserID INT,
	@TopicID INT,
	@SubTopicID INT OUTPUT
AS
BEGIN
	SET @SubTopicID = (SELECT TOP 1 SubTopicID
				FROM SubTopics
				WHERE TopicID = @TopicID
				AND ((Type = 1 OR Type = 3)
					OR (Type = 2 AND UserID = @UserID))
				AND SubTopicID NOT IN
					(SELECT SubTopicID 
					FROM HiddenSubTopics WHERE UserID = @UserID)
				ORDER BY [Priority] DESC, SubTopicName)
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetNonMedlineCitation]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[lib_GetNonMedlineCitation]
	@pmid Int
			
AS
BEGIN

	SELECT  *
	FROM  NonMedlineCitations
	WHERE  PMID = @pmid
	
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSponsorCitations]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[lib_GetSponsorCitations]
	@SubTopicID INT
AS
BEGIN
	SELECT pmid FROM SponsorCitations
	WHERE SubTopicID = @SubTopicID
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSponCitExtraInfo]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetSponCitExtraInfo]
	@UserID INT,
	@SubTopicID INT
AS
BEGIN
	SELECT cmt.userid, sc.pmid, 0 as status,
		NULL As SearchID, NULL As ExpireDate, NULL As keepdelete,
		cmt.nickname, cmt.comment, cmt.updatedate As commentupdatedate
	FROM SponsorCitations sc
	LEFT JOIN UserComment cmt
	ON cmt.pmid = sc.pmid
	WHERE SubTopicID = @SubTopicID
		AND ((UserID = @UserID) OR (UserID IS NULL))
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSeminalCitations]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[lib_GetSeminalCitations]
	@SubTopicID INT
AS
BEGIN
	SELECT pmid FROM SeminalCitations
	WHERE SubTopicID = @SubTopicID
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSemCitExtraInfo]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetSemCitExtraInfo]
	@UserID INT,
	@SubTopicID INT
AS
BEGIN
	SELECT cmt.userid, sc.pmid, 0 as status,
		NULL As SearchID, NULL As ExpireDate, NULL As keepdelete,
		cmt.nickname, cmt.comment, cmt.updatedate As commentupdatedate
	FROM SeminalCitations sc
	LEFT JOIN UserComment cmt
	ON cmt.pmid = sc.pmid
	WHERE SubTopicID = @SubTopicID
		AND ((UserID = @UserID) OR (UserID IS NULL))
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSearchCitationList]    Script Date: 10/22/2013 10:59:50 ******/
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
GO
/****** Object:  StoredProcedure [dbo].[lib_GetSavedCitationList]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetSavedCitationList]
	@UserID Integer,
	@SubTopicID Integer
AS
BEGIN
	SELECT ucit.pmid, ucit.IsAutoQueryCitation as status, ucom.nickname, ucom.comment, 
		ucom.updatedate as commentupdatedate,
		ucit.searchid, ucit.expiredate, ucit.keepdelete 
	FROM UserCitations ucit
	LEFT JOIN UserComment ucom ON (ucit.PMID = ucom.pmid) AND (ucom.userid = ucit.userid)
	WHERE ucit.Userid = @UserID
		AND ((ucit.IsAutoQueryCitation = 0) OR (ucit.expiredate >= GETDATE()))
		AND ucit.SubTopicID = @SubTopicID
		AND ucit.Deleted = 0
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCitations]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetEditorsChoiceCitations]
	@SubTopicID int
AS
BEGIN
	SELECT DISTINCT arts.PMID
	FROM ArticleSelections arts
	JOIN EditorialThreads th ON arts.ThreadID = th.ThreadID
	JOIN SubTopicReferences stRef ON stRef.ThreadID = th.ThreadID
	WHERE stRef.SubTopicID = @SubTopicID
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetFoldersEC20Citations]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetFoldersEC20Citations]	
	@SpecialtyID int
AS
BEGIN

	SELECT DISTINCT arts.PMID, t.TopicID As oid, st.SubTopicID AS fid
		FROM
		Editions ed
		JOIN SubTopicReferences stRef ON stRef.EditionID = ed.EditionID 
		JOIN EditorialThreads th ON stRef.ThreadID = th.ThreadID
		JOIN ArticleSelections arts ON arts.ThreadID = th.ThreadID
		JOIN SubTopics st ON stRef.SubTopicID = st.SubTopicID
		JOIN Topics t ON st.TopicID = t.TopicID
		WHERE t.SpecialtyID = @SpecialtyID
			AND YEAR(ed.PubDate) = YEAR(GETDATE())
			AND MONTH(ed.PubDate) = MONTH(GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetFoldersAndEC20Citations]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_GetFoldersAndEC20Citations]
	@UserID int,
	@SpecialtyID int
AS
BEGIN
	SELECT DISTINCT t.TopicID As OrgFolderID, t.TopicName As OrgFolderName,
		st.SubTopicID As FunFolderID, st.SubTopicName As FunFolderName,
		st.Type As FunType, t.Type As OrgType, 
		t.TopicID As OrgTemplate, st.SubTopicID As FunTemplate,
		t.SpecialtyID As Specialty,
		TopicOrder = CASE t.Type WHEN 3 THEN 2 ELSE 1 END,
		(SELECT COUNT(*) FROM doc_in_subtopic g
					WHERE g.subtopic_id = st.SubTopicID) as doccount
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
	ORDER BY TopicOrder, OrgFolderName,OrgFolderID, FunFolderName

	--SELECT DISTINCT arts.PMID, t.TopicID As oid, st.SubTopicID AS fid
	--	FROM
	--	Editions ed
	--	JOIN SubTopicReferences stRef ON stRef.EditionID = ed.EditionID 
	--	JOIN EditorialThreads th ON stRef.ThreadID = th.ThreadID
	--	JOIN ArticleSelections arts ON arts.ThreadID = th.ThreadID
	--	JOIN SubTopics st ON stRef.SubTopicID = st.SubTopicID
	--	JOIN Topics t ON st.TopicID = t.TopicID
	--	WHERE t.SpecialtyID = @SpecialtyID
	--		AND YEAR(ed.PubDate) = YEAR(GETDATE())
	--		AND MONTH(ed.PubDate) = MONTH(GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetFolderListSFE]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[lib_GetFolderListSFE]
		@UserID Int,
		@SpecialtyID Int
AS
BEGIN

SELECT DISTINCT 

      		t.TopicID AS OrgId, t.TopicName AS OrgName, st.SubTopicID AS FunId, st.SubTopicName AS FunName, t.Type AS OrgType, st.Type AS FunType, 
      		t.UserID, t.SpecialtyID as SpecialtyID,
		TopicOrder = CASE t.Type WHEN 3 THEN 2 ELSE 1 END,
		(SELECT COUNT(*) FROM doc_in_subtopic g
					WHERE g.subtopic_id = st.SubTopicID) as doccount

FROM      dbo.Topics t LEFT OUTER JOIN dbo.SubTopics st ON t.TopicID = st.TopicID

WHERE    	( (t.Type = 1)  AND (st.Type = 1) 
				AND (t.SpecialtyID = @SpecialtyID ) ) OR
         	( (t.Type = 2)  AND (t.UserID = @UserID)  AND (t.SpecialtyID = @SpecialtyID ) ) OR
	       	( (st.Type = 2) AND (st.UserID = @UserID) AND (t.SpecialtyID = @SpecialtyID ) ) OR
		( 
			(t.Type = 3) AND (st.Type = 3) AND (t.SpecialtyID = @SpecialtyID )
			AND (t.TopicID IN 
				(SELECT TopicID FROM UserHasSponsorTopic WHERE UserID = @UserID))
		)

ORDER BY TopicOrder, t.TopicName,t.TopicID, st.SubTopicName

END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceExtraInfo]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Copyright (c) 2007 Cogent Medicine
-- =============================================
CREATE PROCEDURE [dbo].[lib_GetEditorsChoiceExtraInfo] 
	@UserID int,
	@SubTopicID int
AS
BEGIN
	SELECT DISTINCT @UserID AS UserID, arts.pmid, 0 as status, 
		NULL As SearchID, NULL As ExpireDate, NULL As keepdelete,
		cmt.nickname, cmt.comment, cmt.updatedate As commentupdatedate		
	FROM ArticleSelections arts
	JOIN EditorialThreads th ON arts.ThreadID = th.ThreadID
	JOIN SubTopicReferences stRef ON stRef.ThreadID = th.ThreadID
	LEFT JOIN UserComment cmt
	ON ((cmt.pmid = arts.pmid) AND (cmt.UserID = @UserID))
	WHERE stRef.SubTopicID = @SubTopicID
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetRelatedEditions]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForThread]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[lib_GetGenesForThread]
(  
   @PMID int
)
as
begin
    
select t2.GeneID, t2.name
	from ArticleSelections al
	inner join ThreadsGenes t1 on al.ThreadID = t1.ThreadID
	inner join Genes t2 on t2.GeneID = t1.GeneID
	where al.PMID = @PMID
	order by t2.GeneID desc
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForTestByTestID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetGenesForTestByTestID]
(
	@TestID int
) as
begin

	select t1.GeneID, t1.Name from Genes t1 inner join TestsGenes t2 on t1.GeneID = t2.GeneID where t2.TestID = @TestID order by t1.Name

end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetECEditionThreads]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
-- =============================================
create PROCEDURE [dbo].[lib_GetECEditionThreads] 
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
/****** Object:  StoredProcedure [dbo].[lib_GetAbstractCommentsEC20]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
--  Copyright (c) 2005 Cogent Medicine, Inc.
--	Created by PJPM (www.pjpm.biz)
-- =============================================
CREATE PROCEDURE [dbo].[lib_GetAbstractCommentsEC20] 
	@PMID int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT aSel.ThreadID, ec.CommentID, th.OriginalPubDate, ec.Comment
	FROM ArticleSelections aSel
	JOIN EditorialThreads th ON aSel.ThreadID = th.ThreadID
	JOIN EditorialComments ec ON ec.ThreadID = th.ThreadID
	WHERE aSel.PMID = @PMID
	ORDER BY th.OriginalPubDate DESC
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForThread]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetTestsForThread]
(  
   @PMID int
)
as
begin
    
select t2.TestID, t2.Name
	from ArticleSelections al
	inner join ThreadsTests t1 on al.ThreadID = t1.ThreadID
	inner join Tests t2 on t2.TestID = t1.TestID
	where al.PMID = @PMID
	order by t2.TestID desc
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForGeneByGeneID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetTestsForGeneByGeneID]
(
   @GeneID int
) as
begin	
	if @GeneID = 0 	select TestID, Name from Tests
	else select t1.TestID, t1.Name from TestsGenes t2 inner join Tests t1 on t2.TestID = t1.TestID where t2.GeneID = @GeneID
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForCitation]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[lib_GetGenesForCitation]
(  
   @PMID int
)
as
begin
    
SELECT t2.GeneID, t2.name
	FROM CitationsGenes t1
	JOIN Genes t2 ON t1.GeneID = t2.GeneID
	WHERE t1.PMID = @PMID
	ORDER BY t2.GeneID DESC 
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForCitation]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetTestsForCitation]
(  
   @PMID int
)
as
begin
    
select t1.TestID, t1.Name
	from Tests t1
	inner join CitationsTests t2 ON t1.TestID = t2.TestID
	where t2.PMID = @PMID
end
GO
/****** Object:  StoredProcedure [dbo].[doc_in_subtopic_find]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[doc_in_subtopic_find] 
	@id int = null,
	@subtopic_id int = null, 
	@doc_id int = null
AS
BEGIN
select
   dis.id,
   dis.subtopic_id,
   t.TopicName as topic_nm,	
   st.SubTopicName as subtopic_nm,
   dis.doc_id,
   d.source as doc_source,
   d.nm as doc_nm,
   d.last_updated_dt as doc_last_updated_dt,
   d.clicks_count as doc_clicks_count
from
   doc_in_subtopic dis
   inner join doc d on d.id = dis.doc_id
   inner join SubTopics st on st.SubTopicID = dis.subtopic_id
   inner join Topics t on t.TopicID = st.TopicID
where
   (@id is null or dis.id = @id)
   and (@subtopic_id is null or dis.subtopic_id = @subtopic_id)
   and (@doc_id is null or dis.doc_id = @doc_id)
END
GO
/****** Object:  StoredProcedure [dbo].[adm_UnlinkGeneFromTest]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_UnlinkGeneFromTest]
(
	@TestID int,
	@GeneID int
) as
begin

	delete from TestsGenes where TestID = @TestID and GeneID = @GeneID

end
GO
/****** Object:  StoredProcedure [dbo].[adm_AttachGeneToTest]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_AttachGeneToTest]
(
	@TestID int,
	@GeneID int
) as
begin

	insert into TestsGenes (TestID, GeneID) values (@TestID, @GeneID)

end
GO
/****** Object:  StoredProcedure [dbo].[adm_GetECMailingByEdition]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteThread]    Script Date: 10/22/2013 10:59:50 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteTestByTestID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_DeleteTestByTestID]
(
   @TestID int
) as
begin	

 	begin tran tr1

		delete from ThreadsTests where TestID = @TestID
		delete from TestsGenes where TestID = @TestID
		delete from TestsLinks where TestID = @TestID
		delete from TestCommentCombos where TestID = @TestID
		delete from TestComments where TestID = @TestID
		delete from EditorialCommentsTests where TestID = @TestID
		delete from CitationsTests where TestID = @TestID
		delete from Tests where TestID = @TestID
	 ;

	 commit tran tr1;
--		select @@rowcount;
end
GO
/****** Object:  StoredProcedure [dbo].[adm_DeleteGene]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_DeleteGene]
(
   @GeneID int
) as
begin	

 	begin tran tr1

		delete from ThreadsGenes where GeneID = @GeneID
		delete from TestsGenes where GeneID = @GeneID
		delete from GenesLinks where GeneID = @GeneID
		delete from GeneCommentCombos where GeneID = @GeneID
		delete from GeneComments where GeneID = @GeneID
		delete from GeneAliases where GeneID = @GeneID
		delete from EditorialCommentsGenes where GeneID = @GeneID
		delete from CitationsGenes where GeneID = @GeneID
		delete from ArticlesAuthors where GeneID = @GeneID
		delete from GenesArticles where GeneID = @GeneID
		delete from Genes where GeneID = @GeneID
	 ;

	 commit tran tr1;
--		select @@rowcount;
end
GO
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorialComment]    Script Date: 10/22/2013 10:59:50 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorCommentFromTest]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_DeleteEditorCommentFromTest]
(
   @TestID int,
   @CommentID int		
) as
begin	
	delete from EditorialCommentsTests where TestID = @TestID and CommentID = @CommentID  
end
GO
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorCommentFromGene]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_DeleteEditorCommentFromGene]
(
   @GeneID int,
   @CommentID int		
) as
begin	
	delete from EditorialCommentsGenes where GeneID = @GeneID and CommentID = @CommentID  
end
GO
/****** Object:  StoredProcedure [dbo].[adm_AddEditorCommentToTest]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_AddEditorCommentToTest]
(
   @TestID int,
   @CommentID int		
) as
begin	
	insert into EditorialCommentsTests (TestID, CommentID) values (@TestID, @CommentID)  
end
GO
/****** Object:  StoredProcedure [dbo].[adm_AddEditorCommentToGene]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[adm_AddEditorCommentToGene]
(
   @GeneID int,
   @CommentID int		
) as
begin	

	insert into EditorialCommentsGenes (GeneID, CommentID) values (@GeneID, @CommentID)  

end
GO
/****** Object:  StoredProcedure [dbo].[adm_InsertEditorialComment]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
-- =============================================
create PROCEDURE [dbo].[adm_InsertEditorialComment]
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
GO
/****** Object:  StoredProcedure [dbo].[adm_GetThreads]    Script Date: 10/22/2013 10:59:50 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestEditorCommentsByTestID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetTestEditorCommentsByTestID]
(
   @TestID int
) as
begin	
	select t1.CommentID, t1.Comment, t1.ThreadID from EditorialComments t1 inner join EditorialCommentsTests t2 on t1.CommentID = t2.CommentID where TestID = @TestID
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForEditorComments]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetTestsForEditorComments]
(
   @PMID int
)
as
begin
    
select t1.TestID, t1.Name
	from ArticleSelections aSel
	join EditorialThreads th ON aSel.ThreadID = th.ThreadID
	join EditorialComments ec ON ec.ThreadID = th.ThreadID
	join EditorialCommentsTests t2 ON ec.CommentID = t2.CommentID
	join Tests t1 ON t1.TestID = t2.TestID
		
	WHERE aSel.PMID = @PMID
	ORDER BY th.OriginalPubDate DESC
   
end
GO
/****** Object:  StoredProcedure [dbo].[lib_AddEditorCommentToGene]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_AddEditorCommentToGene]
(
   @GeneID int,
   @CommentID int		
) as
begin	
	insert into EditorialCommentsGenes (GeneID, CommentID) values (@GeneID, @CommentID)  
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetECThreadAttributes]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
--	Copyright (c) 2006 Cogent Medicine
-- =============================================
create PROCEDURE [dbo].[lib_GetECThreadAttributes] 
	@EditionID INT,
	@ThreadID INT,
	@ThreadEditors NVARCHAR(1024) OUT,
	@ThreadTopics NVARCHAR(1024) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ThreadEditors = dbo.lib_GetThreadEditors(@EditionID, @ThreadID)

	SET @ThreadTopics = dbo.lib_GetThreadTopics(@EditionID, @ThreadID)
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetECEditorSort]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[lib_GetECEditorSort]
	@EditionID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT dbo.lib_GetThreadEditors(@EditionID, asel.ThreadID) As Editors, asel.ThreadID, asel.PMID
	FROM SubTopicReferences stref
	JOIN ArticleSelections asel ON asel.ThreadID = stref.ThreadID
	JOIN EditorialComments ec ON ec.ThreadID = asel.ThreadID
	WHERE stref.EditionID = @EditionID
	ORDER BY dbo.lib_GetThreadEditors(@EditionID, asel.ThreadID), asel.ThreadID, asel.PMID
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForEditorsChoice]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[lib_GetGenesForEditorsChoice]
(
   @CommentID int
) as

begin	
	select t1.GeneID, t1.Name 
		from EditorialCommentsGenes t2 inner join Genes t1 on t2.GeneID = t1.GeneID 
			where CommentID = @CommentID
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForEditorComments]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[lib_GetGenesForEditorComments]
(
   @PMID int
)
as
begin
    
SELECT ecg.CommentID, Genes.GeneID, Genes.name
	FROM ArticleSelections aSel
	JOIN EditorialThreads th ON aSel.ThreadID = th.ThreadID
	JOIN EditorialComments ec ON ec.ThreadID = th.ThreadID
	JOIN EditorialCommentsGenes ecg ON ec.CommentID = ecg.CommentID
	JOIN Genes ON ecg.GeneID = Genes.GeneID
	
	WHERE aSel.PMID = @PMID
	ORDER BY th.OriginalPubDate DESC
   
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCommentsForTestByTestID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetEditorsChoiceCommentsForTestByTestID]
(
   @TestID int
) as
begin 
	
select t1.CommentID, t1.Comment, t4.name as Author, month(t5.OriginalPubDate) as CommentMonth, year(t5.OriginalPubDate) as CommentDate
		from 
						EditorialComments t1 
			inner join	EditorialCommentsTests t2 on t1.CommentID=t2.CommentID 
			inner join	CommentAuthorReferences t3 on t1.CommentID=t3.CommentID 
			inner join	CommentAuthors t4 on t3.AuthorID=t4.id 
			inner join	EditorialThreads t5 on t1.ThreadID=t5.ThreadID 				
			where t2.TestID =  @TestID order by t5.OriginalPubDate desc
  
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCommentsForGeneByGeneID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetEditorsChoiceCommentsForGeneByGeneID]
(
   @GeneID int
) as
begin	
select t1.CommentID, t1.Comment, t4.name as Author, month(t5.OriginalPubDate) as CommentMonth, year(t5.OriginalPubDate) as CommentDate
		from 
						EditorialComments t1 
			inner join	EditorialCommentsGenes t2 on t1.CommentID=t2.CommentID 
			inner join	CommentAuthorReferences t3 on t1.CommentID=t3.CommentID 
			inner join	CommentAuthors t4 on t3.AuthorID=t4.id 
			inner join	EditorialThreads t5 on t1.ThreadID=t5.ThreadID 
				
			where t2.GeneID = @GeneID
end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGeneEditorCommentsByGeneID]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[lib_GetGeneEditorCommentsByGeneID]
(
   @GeneID int
) as
begin	

	select t1.CommentID, t1.Comment, t1.ThreadID from EditorialComments t1 
	inner join EditorialCommentsGenes t2 on t1.CommentID = t2.CommentID where GeneID = @GeneID

end
GO
/****** Object:  StoredProcedure [dbo].[lib_GetECThreadComments]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
-- Get all comments for a thread
-- =============================================
CREATE PROCEDURE [dbo].[lib_GetECThreadComments] 
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
GO
/****** Object:  StoredProcedure [dbo].[lib_GetCommentContext]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Copyright (c) 2007 Cogent Medicine
-- Created by PJPM (www.pjpm.biz)
-- =============================================
CREATE PROCEDURE [dbo].[lib_GetCommentContext] 
	@TopicID int,
	@ThreadID int,
	@PMID int,
	@CommentID int,
	@EditorIsAuthor int OUT,
	@MultipleEditors int OUT,
	@Editors nvarchar(1042) OUT,
	@Authors nvarchar(1042) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EditionID int

	-- Find the edition based on the topic
	-- In the event that this thread has been included more
	-- than once in this topic, take the earliest edition
	-- number
	-- Join to sub-topic editors to make sure there will
	-- be editors for the edition selected
	SET @EditionID = 
	(SELECT TOP 1 stRef.EditionID
		FROM SubTopicReferences stRef
		JOIN SubTopics st ON stRef.SubTopicID = st.SubTopicID
		JOIN SubTopicEditorRefs steRef 
			ON (steRef.EditionID = stRef.EditionID AND steRef.ThreadID = stRef.ThreadID)
		WHERE stRef.ThreadID = @ThreadID
		AND st.TopicID = @TopicID
		ORDER BY stRef.EditionID ASC)

	-- If no editor is found, we are outside of the home
	-- topic.  This can happen when a user saves a citation
	IF @EditionID IS NULL
	BEGIN
		SET @EditionID =
			(SELECT Top 1 stRef.EditionID
			FROM SubTopicReferences stRef
			JOIN Editions ed ON stRef.EditionID = ed.EditionID
			WHERE stRef.ThreadID = @ThreadID
			ORDER BY ed.PubDate ASC)
	END

	SET @Editors = dbo.lib_GetThreadEditors(@EditionID, @ThreadID)

	SET @Authors = dbo.lib_GetCommentAuthors(@CommentID)

	IF @Editors = @Authors SET @EditorIsAuthor = 1
	ELSE SET @EditorISAuthor = 0

	DECLARE @EditCount int
	SET @EditCount = (SELECT Count(*)
						FROM SubTopicEditorRefs
						WHERE EditionID = @EditionID
						AND ThreadID = @ThreadID)

	IF @EditCount > 1 SET @MultipleEditors = 1
	ELSE SET @MultipleEditors = 0

	-- Return a list of related citations

	-- First, find a valid topic/sub-topic context
	-- This may not be avaiable from the page that is displaying the citation
	DECLARE @RefSubTopic int, @RefTopic int
	DECLARE TopicReferenceCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT Top 1 st.TopicID, st.SubTopicID
		FROM SubTopics st 
		JOIN SubTopicReferences rst ON rst.SubTopicID = st.SubTopicID
		WHERE rst.ThreadID = @ThreadID

	OPEN TopicReferenceCursor

	FETCH NEXT FROM TopicReferenceCursor INTO @RefTopic, @RefSubTopic

	CLOSE TopicReferenceCursor
	DEALLOCATE  TopicReferenceCursor

	--Related citation list
	SELECT PMID, @RefTopic AS TopicID, @RefSubTopic As SubTopicID 
	FROM ArticleSelections
	WHERE ThreadID = @ThreadID
	AND PMID != @PMID
END
GO
/****** Object:  StoredProcedure [dbo].[adm_GetThreadComments]    Script Date: 10/22/2013 10:59:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
-- Copyright (c) 2006 Cogent Medicine
-- Get all comments for the thread content window
-- =============================================
Create PROCEDURE [dbo].[adm_GetThreadComments] 
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
GO

/* End Stored Procedures*/