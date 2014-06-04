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
/****** Object:  UserDefinedFunction [dbo].[fn_FormatBinary]    Script Date: 10/28/2013 15:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_FormatBinary] (
  @in	int,
	@places int
)
	RETURNS varchar(32)
AS
BEGIN
	DECLARE @i 			int
  DECLARE @mask		int
	DECLARE @out		varchar(32)
	SET @i = 0
  SET @out = ''
	WHILE @i <= (@places - 1)
		BEGIN
			SET @mask = POWER(2,@i)
			SET @i = @i + 1
			SET @out =  CASE WHEN @in & @mask > 0 THEN '1' ELSE '0' END + @out
			IF @i % 8 = 0 
				SET @out = ' ' + @out
		END
	RETURN @out
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SearchInsertOr]    Script Date: 10/28/2013 15:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SearchInsertOr] (
  @target	varchar(200)
)
	RETURNS varchar(200)
AS
BEGIN
	DECLARE @i 				int
	DECLARE @inQuote 	int
--	SET @i = CHARINDEX(' ', @target)
--	IF @i > 0
--			SET @target = '"' + @target + '"'
	SET @i = LEN(@target)
  SET @inQuote = 0
	WHILE @i > 1
		BEGIN
			IF SUBSTRING(@target,@i,1) = '"'
				SET @inQuote = CASE WHEN @inQuote = 0 THEN 1 ELSE 0 END
			IF @inQuote = 0
				IF SUBSTRING(@target,@i,1) = ' '
					SET @target = LEFT(@target,@i) + 'OR' + SUBSTRING(@target,@i,999)
			SET @i = @i - 1
		END
	RETURN @target
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SearchInsertAnd]    Script Date: 10/28/2013 15:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SearchInsertAnd] (
  @target	varchar(200)
)
	RETURNS varchar(200)
AS
BEGIN
	DECLARE @i 				int
	DECLARE @inQuote	int
/*
	SET @i = CHARINDEX(' ', @target)
	IF @i > 0
			SET @target = '"' + @target + '"'
*/
	SET @i = LEN(@target)
  SET @inQuote = 0
	WHILE @i > 1
		BEGIN
			IF SUBSTRING(@target,@i,1) = '"'
				SET @inQuote = CASE WHEN @inQuote = 0 THEN 1 ELSE 0 END
			IF @inQuote = 0
				IF SUBSTRING(@target,@i,1) = ' '
					SET @target = LEFT(@target,@i) + 'AND' + SUBSTRING(@target,@i,999)
			SET @i = @i - 1
		END
	RETURN @target
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_abstract_text]    Script Date: 10/28/2013 15:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_abstract_text]
(
    @pmid int
)
returns varchar(8000)
as
begin
    declare @varLabel   varchar(8000),
            @varText       varchar(8000),
            @varResult   varchar(8000),
			@varAbstractTextCount int,
			@index int	

	SELECT @varAbstractTextCount = COUNT(*) FROM wAbstractText WHERE PMID = @pmid

	if @varAbstractTextCount > 1
    begin
		set @varResult = ''
		DECLARE simpleCursor CURSOR
		LOCAL
		FAST_FORWARD
		FOR SELECT Label, AbstractText_Text  FROM wAbstractText WHERE PMID = @pmid

		OPEN simpleCursor
		set @index = 0

		WHILE @index < @varAbstractTextCount
		BEGIN			
			FETCH simpleCursor
				INTO @varLabel, @varText
			set @varResult = @varResult + @varLabel + ': ' + @varText + ' '
			set @index = @index + 1
		END
		CLOSE simpleCursor
		DEALLOCATE simpleCursor
	end
	else
	begin
		SELECT @varResult = AbstractText_Text FROM wAbstractText WHERE PMID = @pmid
	end

    return @varResult
end
GO


/* End User Defined Functions*/

/* Start Stored Procedures */

GO

/****** Object:  StoredProcedure [dbo].[ap_SAS_RunAll2]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SAS_RunAll2]
	@ThisAutorunDateS		varchar(50),
	@UserDB							varchar(50)
AS

--exec ap_SAS_RunAll2 '2007-01-30', 'UserDB_lep'
-- select * from UserDB_lep..users where userid = 1799
SET NOCOUNT ON

	DECLARE @SearchID						int
	DECLARE @SearchResultsCount	int
	DECLARE @QueryDetails				varchar(2000)
	DECLARE @ErrorDesc					varchar(2000)
	DECLARE @ShelfLife					smallint
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1			int
  DECLARE @ResultsFolder2			int
	DECLARE @ThisAutorunDate		smalldatetime
  DECLARE @KeepDelete					tinyint
	SET @ThisAutorunDate = CAST(@ThisAutorunDateS AS smalldatetime)
/*
	DECLARE curS CURSOR FOR
	  SELECT SearchID, ShelfLife, LimitToUserLibrary, ResultsFolder2, KeepDelete
		  FROM CogentSearch..SearchSummary
			WHERE AutoSearch	= 1		
--						AND UserDB			= @UserDB 
						AND UserDB			= 'UserDB_lep'
 AND userid = 1799 	
			ORDER BY UserID

	OPEN curS
	FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete

  WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ap_SearchExecute 0,
														'',
													  @SearchID,
														1,
														@ShelfLife, 
														@LimitToUserLibrary, 
														@ThisAutorunDate,
														@ResultsFolder1, 
														@ResultsFolder2,
														@UserDB,
														@KeepDelete,
														0,
													  @SearchResultsCount	OUTPUT,
														@QueryDetails				OUTPUT,
														@ErrorDesc					OUTPUT											
			UPDATE CogentSearch..SearchSummary
				SET LastAutorunDate = @ThisAutorunDate,
						LastAutorunHits	= @SearchResultsCount
				WHERE SearchID = @SearchID
print 'ap_SAS_RunAll2:  @ThisAutorunDate: ' + isnull(cast(@ThisAutorunDate as varchar(40)),'')
print 'ap_SAS_RunAll2:  @SearchResultsCount: ' + isnull(cast(@SearchResultsCount as varchar(40)),'')
			FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete
		END
  CLOSE curS
	DEALLOCATE curS
*/

--print cast(@ResultsFolder2 as varchar(10))
-- Mailing --------------------------------------------------------------
	DECLARE @MailOut				varchar(4000)
	DECLARE @email					nvarchar(50)
	DECLARE @emailLast			nvarchar(50)
	DECLARE @firstname			nvarchar(50)
	DECLARE @lastname				nvarchar(50)
	DECLARE @title					nvarchar(50)
	DECLARE @SpecialtyName	nvarchar(50)
	DECLARE @TopicName			nvarchar(50)
	DECLARE @SubTopicName		nvarchar(50)
	DECLARE @SearchName			varchar(500)
	DECLARE @NewCitations		int
	DECLARE @cr							varchar(20)
	DECLARE @SQL						nvarchar(1000)
  DECLARE @Conclusion			varchar(1000)
  DECLARE @len						int
-- Misc. Initialization -------------------------------------------------
	SET @cr = '\r\n' --CHAR(13) + CHAR(10)
  SET @Conclusion = @cr + 
'To view your saved queries and their new citations, or to ' + 
'change your notification preference, please log on to ' +
'http://www.cogentmedicine.com, and select My Queries from ' + 
'the navigation bar.  Please e-mail us at ' +
'cogent@cogentmedicine.com if you have any questions about ' +
'the Cogent Medicine system.' + @cr + @cr +
'Sincerely,' + @cr + @cr + 
'Brian Goldsmith MD' + @cr + 
'Moderator, Cogent Medicine' + @cr
	SET @emailLast = 'zzzz999919'
	SELECT 0 as SearchID, CAST('' AS varchar(100))		AS 'email',
				 CAST('' AS varchar(100))		AS 'firstname',
				 CAST('' AS varchar(100))		AS 'lastname',
				 CAST('' AS varchar(100))		AS 'searchname',
				 CAST('' AS varchar(100))		AS 'SpecialtyName',
				 CAST('' AS varchar(100))		AS 'TopicName',
				 CAST('' AS varchar(100))		AS 'SubTopicName',
				 CAST(0 AS int)		AS 'NewCitations'
		INTO #t 
	DELETE FROM #t		
	SET @SQL = 'INSERT INTO #t ' + 
--	SET @SQL = 
						 'SELECT s.searchid, u.email, firstname, lastname, searchname, SpecialtyName, TopicName, SubTopicName, LastAutorunHits	AS ''NewCitations'' ' +
						 ' FROM ' + @UserDB + '..Users u' + 
						 ' JOIN AJA..SearchSummary s ON s.UserID = u.UserID' + 
						 ' LEFT JOIN ' + @UserDB + '..SubTopics h3 ON h3.SubTopicID = s.ResultsFolder2' + 
						 ' LEFT JOIN ' + @UserDB + '..Topics h2 ON h2.TopicID = h3.TopicID' + 
						 ' LEFT JOIN ' + @UserDB + '..Specialties h1 ON h1.SpecialtyID = h2.SpecialtyID' + 
						 ' WHERE u.email IS NOT NULL		AND' + 
						 --' 			s.LastAutorunHits > 0			AND' + 
						 ' 			s.LastAutorunDate = ''' + CAST(@ThisAutorunDate AS varchar(20)) + '''		AND' + 
						 ' 			AutoSearch	= 1			AND' + 
						 ' 			s.UserDB = ''' + @UserDB + '''		AND' + 
						 ' u.userid = 1799 	AND ' + 
						 ' 			u.sasemail = 1'
	EXEC sp_executesql @SQL

  INSERT INTO AJA..LogSearch
		(SearchID, email, firstname, lastname, searchname, NewCitations)
select * from #t
  SELECT SearchID, email, firstname, lastname, searchname, NewCitations FROM #t
	DECLARE curM CURSOR FOR
		SELECT * FROM #t
			ORDER BY email
	OPEN curM
	FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
  WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @email = 'andrewxgoodman@gmail.com'
			IF @emailLast <> @email
				BEGIN
					IF @emailLast <> 'zzzz999919'
						BEGIN
							SET @MailOut = @MailOut + @Conclusion + '"'
							EXEC master..xp_cmdshell @MailOut
						END
					SET @MailOut = 'postie -host:192.168.36.33 -to:' + 
												 @email + 
												 ' -from:cogent@cogentmedicine.com ' + 
												 ' -s:"Cogent Medicine AutoQuery Update"' + 
												 ' -msg:"Dear ' + 
												 @firstname + ' ' + @lastname + ':' + @cr + @cr +
												 'Your AutoQuery status this week:' + @cr + @cr
					SET @emailLast = @email
				END
		  IF @SpecialtyName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SpecialtyName)
					SET @SpecialtyName = SUBSTRING(@SpecialtyName,1,20)
					IF LEN(@SpecialtyName) <> @len
					  BEGIN
					    SET @SpecialtyName = REVERSE(@SpecialtyName)
						  SET @len = CHARINDEX(' ',@SpecialtyName)
						  IF @Len = 0
								  SET @SpecialtyName = REVERSE(@SpecialtyName) + '...'
						  ELSE
									SET @SpecialtyName = REVERSE(SUBSTRING(@SpecialtyName,@len+1,99)) + '...'
						END
				END
		  IF @TopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@TopicName)
					SET @TopicName = SUBSTRING(@TopicName,1,20)
					IF LEN(@TopicName) <> @len
					  BEGIN
					    SET @TopicName = REVERSE(@TopicName)
						  SET @len = CHARINDEX(' ',@TopicName)
						  IF @Len = 0
								  SET @TopicName = REVERSE(@TopicName) + '...'
						  ELSE
									SET @TopicName = REVERSE(SUBSTRING(@TopicName,@len+1,99)) + '...'
						END
				END
		  IF @SubTopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SubTopicName)
					SET @SubTopicName = SUBSTRING(@SubTopicName,1,20)
					IF LEN(@SubTopicName) <> @len
					  BEGIN
					    SET @SubTopicName = REVERSE(@SubTopicName)
						  SET @len = CHARINDEX(' ',@SubTopicName)
						  IF @Len = 0
								  SET @SubTopicName = REVERSE(@SubTopicName) + '...'
						  ELSE
									SET @SubTopicName = REVERSE(SUBSTRING(@SubTopicName,@len+1,99)) + '...'
						END
				END
			SET @MailOut = @MailOut + 'Query Title: ' + @SearchName + @cr + 
										'Destination folder: ' + ISNULL(@SpecialtyName + '>','') + @TopicName + '>' + @SubTopicName + @cr +
										 CAST(@NewCitations AS varchar(10)) + ' citations' + @cr  + @cr
			FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
		END
  CLOSE curM

	DEALLOCATE curM
	DROP TABLE #t
	IF @emailLast <> 'zzzz999919'
	  BEGIN
			SET @MailOut = @MailOut + @Conclusion + '"'
			EXEC master..xp_cmdshell @MailOut
print @MailOut
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SAS_NightlyCitationPurge]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SAS_NightlyCitationPurge]
AS
UPDATE UserDB_live..UserCitation
	SET Status = 0
  WHERE KeepDelete = 1 AND
	Status = 1 AND
	ExpireDate <= GETDATE()
UPDATE UserDB_live..UserCitation
	SET Status = 2
  WHERE KeepDelete = 0 AND
	Status = 1 AND
	ExpireDate <= GETDATE()
UPDATE UserDB..UserCitation
	SET Status = 0
  WHERE KeepDelete = 1 AND
	Status = 1 AND
	ExpireDate <= GETDATE()
UPDATE UserDB..UserCitation
	SET Status = 2
  WHERE KeepDelete = 0 AND
	Status = 1 AND
	ExpireDate <= GETDATE()
GO
/****** Object:  StoredProcedure [dbo].[sp_MSforeachtable_mad]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  proc [dbo].[sp_MSforeachtable_mad]
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null,
   @command3 nvarchar(2000) = null, @whereand nvarchar(2000) = null,
	@precommand nvarchar(2000) = null, @postcommand nvarchar(2000) = null
as
	/* This proc returns one or more rows for each table (optionally, matching @where), with each table defaulting to its own result set */
	/* @precommand and @postcommand may be used to force a single result set via a temp table. */

	/* Preprocessor won't replace within quotes so have to use str(). */
	declare @mscat nvarchar(12)
	select @mscat = ltrim(str(convert(int, 0x0002)))

	if (@precommand is not null)
		exec(@precommand)

	/* Create the select */
   exec(N'declare hCForEachTable cursor global for select ''['' + REPLACE(schema_name(syso.schema_id), N'']'', N'']]'') + '']'' + ''.'' + ''['' + REPLACE(object_name(o.id), N'']'', N'']]'') + '']'' from dbo.sysobjects o join sys.all_objects syso on o.id = syso.object_id '
         + N' where o.name like ''w%'' and o.name not like ''wMeSH%'' and o.name not in (''wInvestigatorValid'',''Wjournal_Update_date'',''wPartialRetractionIn_CommentType'',''wPartialRetractionOf_CommentType'' ) or  o.name in (''wMeshHeading'',''wMeshHeadingList'') and OBJECTPROPERTY(o.id, N''IsUserTable'') = 1 ' + N' and o.category & ' + @mscat + N' = 0 '
         + @whereand)
	declare @retval int
	select @retval = @@error
	if (@retval = 0)
		exec @retval = sys.sp_MSforeach_worker @command1, @replacechar, @command2, @command3, 0

	if (@retval = 0 and @postcommand is not null)
		exec(@postcommand)

	return @retval
GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID_AJA_Dev_Detailed]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_DisplayPMID_AJA_Dev_Detailed]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate,ViewCountSummary, ViewPMID) SELECT @UserID, 0, GETDATE(),0, PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2 '

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
--  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
		  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp
GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID_AJA_Dev]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ap_DisplayPMID_AJA_Dev]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate,ViewCountSummary, ViewPMID) SELECT @UserID, 0, GETDATE(),0, PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2,ISNULL(w.unicodeFixed,wn.unicodeFixed) AS unicodeFixed '

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
	--	  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp



GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_DisplayPMID]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate, ViewPMID) SELECT @UserID, 0, GETDATE(), PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2,ISNULL(w.unicodeFixed,wn.unicodeFixed) AS unicodeFixed'

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
		  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryUpdate]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchQueryUpdate]
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
  @SearchID			  int,
-- Start new
	@AutoSearch 		tinyint,
	@ShelfLife 			smallint,
	@Description		varchar(500),
	@LimitToUserLibrary	tinyint,
	@ResultsFolder1	int,
	@ResultsFolder2	int,
	@UserDB					varchar(50),
	@KeepDelete			tinyint,
-- End new
  @ReturnCode			int OUTPUT  --  -1: duplicate UserID/SearchName
															--	-2: UserID/SearchName not found
															--  -3: SearchID not found
AS
  DECLARE @RecCount			int
  SET NOCOUNT ON
-- Find SearchID if only UserID/SearchName provided ---------------------------------------
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM AJA..SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName	AND
						UserDb		= @UserDB
		  IF @@ROWCOUNT = 0
				BEGIN
					SET @ReturnCode = -2
					RETURN
				END
		END
-- SearchID exists? ----------------------------------------------------
  SELECT @RecCount = COUNT(*)
    FROM AJA..SearchSummary
		WHERE SearchID		= @SearchID
  IF @RecCount = 0
		BEGIN
			SET @ReturnCode = -3
			RETURN
		END
-- Changing to a duplicate name? ------------------------------------------------
  IF @SearchName IS NULL
		SET @SearchName = 'Search created on ' + CONVERT(varchar(30),GETDATE(),100)
  IF LEN(@SearchName) = 0
		SET @SearchName = 'Search created on ' + CONVERT(varchar(30),GETDATE(),100)
  SELECT @RecCount = COUNT(*)
    FROM AJA..SearchSummary
		WHERE UserID			= @UserID	AND
				  SearchName	= @SearchName AND
				UserDb		= @UserDb AND
					SearchID		<> @SearchID
  IF @RecCount >= 1 
		BEGIN
			SET @ReturnCode = -1
			RETURN
		END
  UPDATE AJA..SearchSummary
		SET PublicationTypeMask	= @PublicationTypeMask,
				SubjectAgeMask			= @SubjectAgeMask,
				LanguageMask				= @LanguageMask,
				SpeciesMask					= @SpeciesMask,
				GenderMask					= @GenderMask,
				AbstractMask				= @AbstractMask,
				PaperAge						= @PaperAge,
				SearchSort					= @SearchSort,
				DateStart						= CAST( CAST(@DateStart AS varchar(4)) + '-01-01' AS smalldatetime),
				DateEnd							= CAST( CAST(@DateEnd AS varchar(4)) + '-12-31' AS smalldatetime),
				SearchName					= ISNULL(@SearchName,SearchName),
				AutoSearch					= ISNULL(@AutoSearch,AutoSearch),
				ShelfLife						= ISNULL(@ShelfLife,ShelfLife),
				Description					= ISNULL(@Description,Description),
				LimitToUserLibrary	= ISNULL(@LimitToUserLibrary,LimitToUserLibrary),
				ResultsFolder1			= ISNULL(@ResultsFolder1,ResultsFolder1),
				ResultsFolder2			= ISNULL(@ResultsFolder2,ResultsFolder2),
				UserDB							= ISNULL(@UserDB,UserDB),
				KeepDelete					= ISNULL(@KeepDelete,KeepDelete)
		WHERE SearchID = @SearchID
  DELETE 
	  FROM AJA..SearchDetails
    WHERE SearchID = @SearchID
  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
    VALUES (@SearchID, 1, @Op1, @Terms1, @Tab1)
  IF LEN(@Terms2) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 2, @Op2, @Terms2, @Tab2)
  IF LEN(@Terms3) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 3, @Op3, @Terms3, @Tab3)
  IF LEN(@Terms4) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 4, @Op4, @Terms4, @Tab4)
  IF LEN(@Terms5) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 5, @Op5, @Terms5, @Tab5)
  IF LEN(@Terms6) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 6, @Op6, @Terms6, @Tab6)
  SET @ReturnCode = @SearchID
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryDelete]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchQueryDelete]
  @UserID					int,
	@SearchName			varchar(100),
  @SearchID				int
											
AS
  DECLARE @RecCount				int
  SET NOCOUNT ON
  IF @SearchID = 0
		BEGIN
		  SELECT @SearchID = SearchID
		    FROM AJA..SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
		DELETE FROM AJA..SearchResults WHERE SearchID = @SearchID
		DELETE FROM AJA..SearchDetails WHERE SearchID = @SearchID
		DELETE FROM AJA..SearchSummary WHERE SearchID = @SearchID
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineSetSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineSetSearch]
	@Setting	varchar(50),
  @Value 	varchar(50)
AS
  SET NOCOUNT ON
  UPDATE AJA..SearchControl
	  SET Value = @Value
		WHERE Setting = @Setting
GO
/****** Object:  StoredProcedure [dbo].[Merge_MedLineData]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Merge_MedLineData]
  @LogSet 			varchar(50),
	@UpdateSource	int,
	@UpdateDate		smalldatetime
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
		SELECT PMID
		  FROM wDeleteCitation
		  
		SET @RecCount = @@ROWCOUNT	
		SET @DeleteCount = @DeleteCount + @RecCount

  IF @DeleteCount > 0
		BEGIN
			DELETE i FROM [Cogent3].dbo.iAccession i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAccession',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iArticle i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticle',0,@RecCount)
		
		
			DELETE i FROM [Cogent3].dbo.iArticleDate i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticleDate',0,@RecCount)
		
		
			DELETE i FROM [Cogent3].dbo.iWide i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWide',0,@RecCount)
		
		
			DELETE i FROM [Cogent3].dbo.iWideNew i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWideNew',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iAuthor i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAuthor',0,@RecCount)
		
			
			DELETE i FROM [Cogent3].dbo.iChemical i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iChemical',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iCitation i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitation',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iCitationMeSHHeading i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHHeading',0,@RecCount)
			DELETE i FROM [Cogent3].dbo.iCitationMeSHQualifier i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHQualifier',0,@RecCount)		
	
			DELETE i FROM [Cogent3].dbo.iCitationSubset i INNER JOIN #e e ON e.PMID = i.PMID
						
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationSubset',0,@RecCount)
			
			DELETE i FROM [Cogent3].dbo.iCitationScreen i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationScreen',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iComment i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iComment',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iDataBank i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iDataBank',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iGrant i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iGrant',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iKeyword i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeyword',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iKeywordList i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeywordList',0,@RecCount)
		
			DELETE i FROM [Cogent3].dbo.iLanguage i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iLanguage',0,@RecCount)
			
			DELETE i FROM [Cogent3].dbo.iPublicationType i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iPublicationType',0,@RecCount)
			
			DELETE i FROM [Cogent3].dbo.iOtherID i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
			VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iOtherID ',0,@RecCount)	
		END
		DROP TABLE #e
		
		INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation Compeleted ',0,@RecCount)		

	INSERT INTO [Cogent3].dbo.iArticle 
	SELECT  * FROM iArticle
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iArticle',@RecCount,0)		
		
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iArticleDate
	SELECT * FROM iArticleDate with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iArticleDate',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iAuthor 
	SELECT 	*	FROM iAuthor with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAuthor',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iDataBank 
	SELECT *	FROM iDataBank with(nolock)

	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iDataBank',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iAccession 
	SELECT * FROM iAccession with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAccession',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iChemical
	SELECT *	FROM iChemical with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iChemical',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iGrant 
	SELECT * FROM iGrant with(nolock)

	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iGrant',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iCitationSubset 
	SELECT *	FROM iCitationSubset with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationSubset',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iComment 
	SELECT *	FROM iComment with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iComment',@RecCount,0)		
	

	INSERT INTO [Cogent3].dbo.iKeywordList 
	SELECT	* FROM iKeywordList with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iKeywordList',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iKeyword 
	SELECT *	FROM iKeyword with(nolock)

	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iKeyword',@RecCount,0)		
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iPublicationType 
	SELECT *	FROM iPublicationType with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iPublicationType',@RecCount,0)		
	

	INSERT INTO [Cogent3].dbo.iOtherID 
	SELECT *	FROM iOtherID with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iOtherID',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO [Cogent3].dbo.iLanguage 
	SELECT	*	FROM iLanguage with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
	INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	VALUES (@LogSet,@RunType,GETDATE(),'iLanguage',@RecCount,0)		

--**************************************************************************
	INSERT INTO [Cogent3].dbo.iCitation 
	SELECT 	*	FROM iCitation with(nolock)
	
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitation',@RecCount,0)

--**************************************************************************
INSERT INTO [Cogent3].dbo.iWide (
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
INSERT INTO [Cogent3].dbo.iWideNew 
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
      Affiliation from iWide with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iWideNew',@RecCount,0)		

	INSERT INTO [Cogent3].dbo.iCitationScreen 
		SELECT * FROM iCitationScreen with(nolock)
		
		SET @RecCount = @@ROWCOUNT	
		INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationScreen',@RecCount,0)		

	INSERT INTO [Cogent3].dbo.iCitationMeSHHeading 
	SELECT *	FROM iCitationMeSHHeading with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeading',@RecCount,0)		

	INSERT INTO [Cogent3].dbo.iCitationMeSHQualifier 
		SELECT * FROM iCitationMeSHQualifier with(nolock)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHQualifier',@RecCount,0)
GO
/****** Object:  StoredProcedure [dbo].[Wjournal_Update_date]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Wjournal_Update_date]
as
UPDATE c
	SET DateCreatedYear = dc.Year,
		DateCreatedMonth = dc.Month,
		DateCreatedDay = dc.Day,
		DateCompletedYear = do.Year,
		DateCompletedMonth = do.Month,
		DateCompletedDay = do.Day,
		DateRevisedYear = dr.Year,
		DateRevisedMonth = dr.Month,
		DateRevisedDay = dr.Day
	FROM wMedlineCitation c
	LEFT OUTER JOIN wDateCreated dc on dc.PMID  = c.PMID
	LEFT OUTER JOIN wDateCompleted do on do.PMID  = c.PMID
	LEFT OUTER JOIN wDateRevised dr on dr.PMID  = c.PMID

UPDATE c
	SET Volume = i.Volume,
		Issue = i.Issue,
		Year= CASE WHEN p.Year < 1900 then 1900 else p.Year END,
		Month = p.Month,
		Day = case when p.Year<1900 and p.Month='feb' and p.Day=29 then 28 else p.Day END ,
		Season = p.Season,
		MedlineDate = p.MedlineDate,
		CitedMediumID = xc.CitedMediumID
	FROM wJournal c
	LEFT OUTER JOIN wJournalIssue i on i.PMID  = c.PMID
	LEFT OUTER JOIN wPubDate p on p.PMID  = c.PMID
	LEFT JOIN xCitedMedium xc ON xc.CitedMedium = i.CitedMedium
	--print 'wJournal'
UPDATE c
	SET Year= CASE WHEN Year < 1900 then 1900 else Year END
	FROM wJournal c
	--print 'wJournal Year'
	
UPDATE c
	SET StartPage = p.StartPage,
		EndPage = p.EndPage,
		MedlinePgn = p.MedlinePgn,
		GrantListComplete = g.CompleteYN,
		DataBankListComplete = d.CompleteYN,
		AuthorListComplete = a.CompleteYN
	FROM wArticle c
	LEFT OUTER JOIN wPagination p on p.PMID  = c.PMID
	LEFT OUTER JOIN wGrantList g on g.PMID  = c.PMID
	LEFT OUTER JOIN wDataBankList d on d.PMID  = c.PMID
	LEFT OUTER JOIN wAuthorList a on a.PMID  = c.PMID

 
UPDATE wJournal
 SET DatePublicationStart = CASE  WHEN [Month] IS NOT NULL THEN
                                                      CASE [Month]
                                                            WHEN 'Jan' THEN '01'
                                                            WHEN 'Feb' THEN '02'
                                                            WHEN 'Mar' THEN '03'
                                                            WHEN 'Apr' THEN '04'
                                                            WHEN 'May' THEN '05'

                                                            WHEN 'Jun' THEN '06'

                                                            WHEN 'Jul' THEN '07'

                                                            WHEN 'Aug' THEN '08'

                                                            WHEN 'Sep' THEN '09'

                                                            WHEN 'Oct' THEN '10'

                                                            WHEN 'Nov' THEN '11'

                                                            WHEN 'Dec' THEN '12'

                                                      END

                                                ELSE '01'

                                                END + '/'+ CASE WHEN [DAY]>0 THEN

                                                                              COnvert(VARCHAR,[DAY])

                                                                        ELSE '01'

                                                                        END+ '/'+ Convert(VARCHAR,[Year]),

      DatePublicationEnd = CASE  WHEN [Month] IS NOT NULL THEN

                                                      CASE [Month]

                                                            WHEN 'Jan' THEN '01'

                                                            WHEN 'Feb' THEN '02'

                                                            WHEN 'Mar' THEN '03'

                                                            WHEN 'Apr' THEN '04'

                                                            WHEN 'May' THEN '05'

                                                            WHEN 'Jun' THEN '06'

                                                            WHEN 'Jul' THEN '07'

                                                            WHEN 'Aug' THEN '08'

                                                            WHEN 'Sep' THEN '09'

                                                            WHEN 'Oct' THEN '10'

                                                            WHEN 'Nov' THEN '11'

                                                            WHEN 'Dec' THEN '12'

                                                      END + '/'+ CASE WHEN [DAY]>0

                                                                              THEN COnvert(VARCHAR,[DAY])

                                                                              ELSE '01'

                                                                              END

                                                ELSE '12/31'

                                                END + '/'+ Convert(VARCHAR,[Year])

WHERE  [MedlineDate] IS NULL

--28775        

 

                                 

UPDATE wJournal

  SET DatePublicationEnd = DATEADD(DAY, -1, DATEADD(MONTH, 1,DatePublicationEnd))     

from wJournal                        

WHERE  [MedlineDate] IS NULL

  AND [MONTH] IS NOT NULL

  AND [DAY] IS NULL    

--18663     

   

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/01/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =  DATEADD(DAY, -1, DATEADD(MONTH, 1,

  CASE SUBSTRING([MedlineDate],10,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/01/'+SUBSTRING([MedlineDate],1,4)))

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z]-[a-z][a-z][a-z]' --'2009 Apr-May'

 

------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

 

  WHEN 'Jan' THEN '01'

 

  WHEN 'Feb' THEN '02'

 

  WHEN 'Mar' THEN '03'

 

  WHEN 'Apr' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'Jun' THEN '06'

 

  WHEN 'Jul' THEN '07'

 

  WHEN 'Aug' THEN '08'

 

  WHEN 'Sep' THEN '09'

 

  WHEN 'Oct' THEN '10'

 

  WHEN 'Nov' THEN '11'

 

  WHEN 'Dec' THEN '12'

 

  END

 

  +'/01/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =  DATEADD(DAY, -1, DATEADD(MONTH, 1,

 

  CASE SUBSTRING([MedlineDate],15,3)

 

  WHEN 'Jan' THEN '01'

 

  WHEN 'Feb' THEN '02'

 

  WHEN 'Mar' THEN '03'

 

  WHEN 'Apr' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'Jun' THEN '06'

 

  WHEN 'Jul' THEN '07'

 

  WHEN 'Aug' THEN '08'

 

  WHEN 'Sep' THEN '09'

 

  WHEN 'Oct' THEN '10'

 

  WHEN 'Nov' THEN '11'

 

  WHEN 'Dec' THEN '12'

 

  END

 

  +'/01/'+SUBSTRING([MedlineDate],10,4)))

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z]-[0-9][0-9][0-9][0-9] [a-z][a-z][a-z]'  --'2001 Dec-2002 Jan'

 

-----------

 

UPDATE [wJournal]

 

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

 

  WHEN 'Jan' THEN '01'

 

  WHEN 'Feb' THEN '02'

 

  WHEN 'Mar' THEN '03'

 

  WHEN 'Apr' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'Jun' THEN '06'

 

  WHEN 'Jul' THEN '07'

 

  WHEN 'Aug' THEN '08'

 

  WHEN 'Sep' THEN '09'

 

  WHEN 'Oct' THEN '10'

 

  WHEN 'Nov' THEN '11'

 

  WHEN 'Dec' THEN '12'

 

  END

 

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =  CASE SUBSTRING([MedlineDate],6,3)

 

  WHEN 'Jan' THEN '01'

 

  WHEN 'Feb' THEN '02'

 

  WHEN 'Mar' THEN '03'

 

  WHEN 'Apr' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'Jun' THEN '06'

 

  WHEN 'Jul' THEN '07'

 

  WHEN 'Aug' THEN '08'

 

  WHEN 'Sep' THEN '09'

 

  WHEN 'Oct' THEN '10'

 

  WHEN 'Nov' THEN '11'

 

  WHEN 'Dec' THEN '12'

 

  END

 

  +'/'+RIGHT([MedlineDate],LEN([MedlineDate])-CHARINDEX('-',[MedlineDate]))+'/'+SUBSTRING([MedlineDate],1,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[0-9][0-9]'  --'2003 Oct 9-22'

 

------------------------------------------------------------------------------------------------

 

UPDATE [wJournal]

 

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,CHARINDEX('-',[MedlineDate])-6)

 

  WHEN 'January' THEN '01'

 

  WHEN 'February' THEN '02'

 

  WHEN 'March' THEN '03'

 

  WHEN 'April' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'June' THEN '06'

 

  WHEN 'July' THEN '07'

 

  WHEN 'August' THEN '08'

 

  WHEN 'September' THEN '09'

 

  WHEN 'October' THEN '10'

 

  WHEN 'November' THEN '11'

 

  WHEN 'December' THEN '12'

 

  END

 

  +'/01/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =  DATEADD(DAY, -1, DATEADD(MONTH, 1,

 

  CASE RIGHT([MedlineDate],LEN([MedlineDate])-CHARINDEX('-',[MedlineDate]))

 

  WHEN 'January' THEN '01'

 

  WHEN 'February' THEN '02'

 

  WHEN 'March' THEN '03'

 

  WHEN 'April' THEN '04'

 

  WHEN 'May' THEN '05'

 

  WHEN 'June' THEN '06'

 

  WHEN 'July' THEN '07'

 

  WHEN 'August' THEN '08'

 

  WHEN 'September' THEN '09'

 

  WHEN 'October' THEN '10'

 

  WHEN 'November' THEN '11'

 

  WHEN 'December' THEN '12'

 

  END

 

  +'/01/'+SUBSTRING([MedlineDate],1,4)))

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] [January][February][March][April][May][June][July][August][September][October][November][December] - [January][February][March][April][May][June][July][August][September][October][November][December]'

 

--1994 October-December

 

---------------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

  CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

 

   +'/'+RIGHT([MedlineDate],LEN([MedlineDate])-CHARINDEX('-',[MedlineDate]))+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]-[0-9][0-9]' --'2010 May 25-31'

 

  ---------------------------

 UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

  CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

 

   +'/'+RIGHT([MedlineDate],LEN([MedlineDate])-CHARINDEX('-',[MedlineDate]))+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[0-9]' --'2003 Dec 2-8'

 

-------------------------

 

UPDATE [wJournal]

SET DatePublicationStart =  '01'+

  +'/'+'01'+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

   '01'+

  +'/'+'01'+'/'+SUBSTRING([MedlineDate],6,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' --'2001-2002'

 

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],13,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],17,1)+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like  '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]-[a-z][a-z][a-z] [0-9]' --'2001 Jun 28-Jul 4'

 

 

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],13,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],16,2)+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[a-z][a-z][a-z] [0-9][0-9]' --'2001 Jun 4-Jul 28'

 

 

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],13,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],17,2)+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]-[a-z][a-z][a-z] [0-9][0-9]' --'2001 Jun 14-Jul 28'

 

  ---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],12,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],16,1)+'/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[a-z][a-z][a-z] [0-9]' --'2001 Jun 4-Jul 4'

 

 

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],18,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],22,1)+'/'+SUBSTRING([MedlineDate],13,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]-[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]' -- '2001 Dec 13-2002 Jan 2'

 

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],18,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],22,2)+'/'+SUBSTRING([MedlineDate],13,4)

WHERE MedlineDate is not null

and MedlineDate like  '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]-[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]' -- '2001 Dec 13-2002 Jan 12'

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],17,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],21,2)+'/'+SUBSTRING([MedlineDate],12,4)

WHERE MedlineDate is not null

and MedlineDate like  '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9][0-9]' -- '2001 Dec 3-2002 Jan 12'

---------------

UPDATE [wJournal]

SET DatePublicationStart = CASE SUBSTRING([MedlineDate],6,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+ SUBSTRING([MedlineDate],10,CHARINDEX('-',[MedlineDate])-10)+'/'+SUBSTRING([MedlineDate],1,4), 

 

DatePublicationEnd =

 CASE SUBSTRING([MedlineDate],17,3)

  WHEN 'Jan' THEN '01'

  WHEN 'Feb' THEN '02'

  WHEN 'Mar' THEN '03'

  WHEN 'Apr' THEN '04'

  WHEN 'May' THEN '05'

  WHEN 'Jun' THEN '06'

  WHEN 'Jul' THEN '07'

  WHEN 'Aug' THEN '08'

  WHEN 'Sep' THEN '09'

  WHEN 'Oct' THEN '10'

  WHEN 'Nov' THEN '11'

  WHEN 'Dec' THEN '12'

  END

  +'/'+SUBSTRING([MedlineDate],21,1)+'/'+SUBSTRING([MedlineDate],12,4)

WHERE MedlineDate is not null

and MedlineDate like  '[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]-[0-9][0-9][0-9][0-9] [a-z][a-z][a-z] [0-9]' -- '2001 Dec 3-2002 Jan 1'

 --------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '03/31/'+SUBSTRING([MedlineDate],11,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] Fall-[0-9][0-9][0-9][0-9] Winter' --'2001 Fall-2002 Winter'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '03/31/'+SUBSTRING([MedlineDate],11,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] Autumn - [0-9][0-9][0-9][0-9] Winter' --'2001 Fall-2002 Winter'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '01/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '03/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Winter' --'2001-2002 Winter'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] -[0-9][0-9][0-9][0-9] Autumn' --'2001-2002 Autumn'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] - [0-9][0-9][0-9][0-9] Fall' --'2001-2002 Fall'

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '04/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '06/30/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9] - [0-9][0-9][0-9][0-9] Spring' --'2001-2002 Spring'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '09/30/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Summer' --'2001-2002 Summer'

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Fall-Winter' --1983-1984 Fall-Winter

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Autumn-Winter' --1983-1984 Autumn-Winter

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '01/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '06/30/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Winter-Spring' --1983-1984 Winter-Spring

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '04/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '09/30/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Spring-Summer' --1983-1984 Spring-Summer

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Summer-Fall' --1983-1984 Summer-Fall

 

-----------------------------

UPDATE [wJournal]

 

SET DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],6,4)

 

WHERE MedlineDate is not null

 

and MedlineDate like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] Summer-Autumn' --1983-1984 Summer-Autumn

 

----------------------------------------------------------

 

UPDATE [wJournal]

SET DatePublicationStart = '01/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '06/30/'+SUBSTRING([MedlineDate],13,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Winter-[0-9][0-9][0-9][0-9] Spring' --'2001 Winter-2002 Spring'

-----------------

UPDATE [wJournal]

SET DatePublicationStart = '04/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '09/30/'+SUBSTRING([MedlineDate],13,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Spring-[0-9][0-9][0-9][0-9] Summer' --'2001 Spring-2002 Summer'

 

-----------------

UPDATE [wJournal]

SET DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],13,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Summer-[0-9][0-9][0-9][0-9] Fall' --'2001 Summer-2002 Fall'

 

 

-----------------

UPDATE [wJournal]

set DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '03/31/'+CONVERT(VARCHAR,CONVERT(INT,SUBSTRING([MedlineDate],1,4))+1)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Fall-Winter' --'2001 Fall-Winter'

 

-----------------

UPDATE [wJournal]

set  DatePublicationStart = '01/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '06/30/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Winter-Spring' --'2001 Winter-Spring'

 

-----------------

UPDATE [wJournal]

set DatePublicationStart = '04/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '09/30/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Spring-Summer' --'2001 Spring-Summer'

 

-----------------

UPDATE [wJournal]

set DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Summer-Fall' --'2001 Summer-Fall'

 

----------------------------------

UPDATE [wJournal]

set DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Summer-Autumn'---'2006 Summer-Autumn'

 

  -------------------------------

UPDATE [wJournal]

set DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

 

      DatePublicationEnd = '03/31/'+CONVERT(VARCHAR,CONVERT(INT,SUBSTRING([MedlineDate],1,4))+1)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Autumn-Winter' -- '2001 Autumn-Winter'

 

  ---------------------------

UPDATE [wJournal]

set  DatePublicationStart = '01/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '03/31/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Winter' --'2001 Winter

 

----------------------------------

UPDATE [wJournal]

set DatePublicationStart = '04/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '06/30/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Spring' --'2001 Spring

 

----------------------------------

UPDATE [wJournal]

set DatePublicationStart = '07/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '09/30/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Summer' --'2001 Summer

 

----------------------------------

UPDATE [wJournal]

set DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Fall' --'2001 Fall

 

----------------------------------------------------

 

UPDATE [wJournal]

set DatePublicationStart = '10/01/'+SUBSTRING([MedlineDate],1,4), 

      DatePublicationEnd = '12/31/'+SUBSTRING([MedlineDate],1,4)

WHERE MedlineDate is not null

and MedlineDate like '[0-9][0-9][0-9][0-9] Autumn' --'2001 Autumn

UPDATE [wJournal]

set DatePublicationStart ='1900-01-01 00:00:00' WHERE DatePublicationStart is  null

UPDATE [wJournal]

set DatePublicationEnd ='1900-01-01 00:00:00' WHERE DatePublicationEnd is  null

---------------------------

 

 -----------------------------End Wjournal Update date --------------------------

/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineBuildLookup]    Script Date: 04/03/2013 19:38:00 ******/
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryGet_AJA]    Script Date: 10/28/2013 15:49:46 ******/
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
		    FROM AJA.dbo.SearchSummary
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
	  FROM AJA.dbo.SearchSummary
		WHERE SearchID = @SearchID
  DECLARE cur CURSOR FOR
	  SELECT Seq, Op, Terms, Tab
		  FROM AJA.dbo.SearchDetails
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
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryGet]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchQueryGet]
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
		    FROM AJA.dbo.SearchSummary
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
	  FROM AJA.dbo.SearchSummary
		WHERE SearchID = @SearchID
  DECLARE cur CURSOR FOR
	  SELECT Seq, Op, Terms, Tab
		  FROM AJA.dbo.SearchDetails
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
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildEachQuery_AJA]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildEachQuery_AJA]
	@Op								char(3),
	@Tab							varchar(35),
	@Field						varchar(35),
  @TermA						varchar(100),
  @TermB						varchar(100),
	@FindA						int,
	@FindB						int,
	@TestOrder				int,
	@Extra						varchar(200),
	@FullOld					int,
	@FullNew					int,
	@FullOldLimit			varchar(50),
	@QuerySub					varchar(4000)	OUTPUT, -- set to '' if no valid query
	@QueryDetails	  	varchar(2000)	OUTPUT
AS
  DECLARE @RecCount				int
	DECLARE @cr							char(1)
	DECLARE @uDescriptorID	int
	DECLARE @TreeNumber			varchar(100)
	DECLARE @NoiseCount			int

-- Misc. Initialization -------------------------------------------------
  SET NOCOUNT ON
	SET @cr = CHAR(13) 
  SET @QuerySub = ''
  SET @QueryDetails = ''

  IF @Tab = 'Title/Abstract/MeSH Term'  OR @Tab = 'Title/Abstract' 
		SELECT @NoiseCount = COUNT(*) FROM AJA.dbo.NoiseWord WHERE Word = @TermA
	ELSE
		SET @NoiseCount = 0

--print 'bseq >' + @TermA + '< ' + @tab + ' ' + cast(@noisecount as varchar(10))

	IF @Tab = 'PMID'
		BEGIN
			SET @QuerySub = 'SELECT ' + CAST(@FindA AS varchar(20)) + ' AS PMID' + @cr
			SET @QueryDetails = '(PMID=' + CAST(@FindA AS varchar(20)) + ')'
		END

	IF @Tab = 'Author' AND @Field = 'LastName'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE LastNameID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(Author="' + @TermA + '")'
		END

	IF @Tab = 'Author' AND @Field = 'LastNameInitials'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE LastNameID=' + CAST(@FindA AS varchar(20))
			IF LEN(@Extra) = 1
				SET @QuerySub = @QuerySub + ' AND Initial1=''' + @Extra + '''' + @cr
			ELSE
				SET @QuerySub = @QuerySub + ' AND Initial1=''' + SUBSTRING(@Extra,1,1) + '''' + 
												' AND Initial2=''' + SUBSTRING(@Extra,2,1) + '''' + @cr
			SET @QueryDetails = '(Author="' + @TermA + '")'
		END

	IF @Tab = 'Author' AND @Field = 'CollectiveName'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE CollectiveNameID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(CollectiveName="' + @TermA + '")'
		END

	IF @Tab = 'Chemical' AND @Field = 'ChemicalNameID'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iChemical WHERE ChemicalNameID=' + CAST(@FindA AS varchar(20)) + @cr
			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			SET @QueryDetails = '(Chemical=' + @TermA + ')'
			RETURN
		END

	IF @Tab = 'Journal' AND @Field = 'ISSN'
		BEGIN
			SET @QuerySub = 'SELECT PMID FROM iArticle WHERE ISSNID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(ISSN=' + @TermA + ')'
		END

	IF @Tab = 'Journal' AND @Field = 'MedLineTA'
		BEGIN
			SET @QuerySub = 'SELECT PMID FROM iArticle WHERE MedLineTAID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(MedlineTA="' + @TermA + '")'
		END

	IF @Tab = 'MeSH Term' 
		BEGIN
					SET @QuerySub = 'SELECT DISTINCT DQSUIn FROM iMeSHTreeNumber WHERE DQSUIc = ''D'' '
					DECLARE curTa CURSOR FOR SELECT TreeNumber FROM iMeSHTreeNumber WHERE DQSUIc = 'D' AND DQSUIn = @FindA
					OPEN curTa
					FETCH NEXT FROM curTa INTO @TreeNumber
					DECLARE @TreeCount int
					SET @TreeCount = 0
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @TreeCount = 0
								SET @QuerySub = @QuerySub + ' AND ('
							ELSE
								SET @QuerySub = @QuerySub + ' OR '
							SET @TreeCount = @TreeCount + 1
							SET @QuerySub = @QuerySub + ' TreeNumber LIKE ''' + @TreeNumber + '%''' 
							SET @RecCount = 1
							FETCH NEXT FROM curTa INTO @TreeNumber
						END
					CLOSE curTa
					DEALLOCATE curTa
					IF @TreeCount > 0
						SET @QuerySub = @QuerySub + ')'

--	SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN ' +
--		'(SELECT DISTINCT TOP 500 DQSUIn FROM IMeSHTerm WHERE TermName LIKE ''%' + @TermA + '%'' and DQSUIc = ''d'' ORDER BY DQSUIn )' + @cr			
--				'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr			
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading with (nolock) WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr +
											' UNION SELECT DISTINCT PMID FROM iCitationMeSHHeading with (nolock) WHERE DescriptorUI IN (' + @QuerySub + ')'+ @cr			
				SET @QueryDetails = '(MeSH Terms=' + @Extra
			IF @FindB > 0
				BEGIN
					SET @QuerySub = @QuerySub + 'UNION SELECT DISTINCT PMID FROM iCitationMeSHQualifier with (nolock) WHERE QualifierUI=' + CAST(@FindB AS varchar(20)) + @cr			
					IF @FindA = 0
						SET @QueryDetails = '(MeSH Subheading=' + @Extra
					ELSE
						SET @QueryDetails = @QueryDetails  + ' OR MeSH Subheading=' + @Extra
				END
				SET @QueryDetails = @QueryDetails + ')'
		END

	IF @Tab = 'Title/Abstract/MeSH Term' 
		BEGIN

			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)

		  IF @FindA > 0
				BEGIN
					SET @QuerySub = 'SELECT DISTINCT DQSUIn FROM iMeSHTreeNumber with (nolock) WHERE DQSUIc = ''D'' '
					DECLARE curTb CURSOR FOR SELECT TreeNumber FROM iMeSHTreeNumber with (nolock) WHERE DQSUIc = 'D' AND DQSUIn = @FindA
					OPEN curTb
					FETCH NEXT FROM curTb INTO @TreeNumber
					WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @QuerySub = @QuerySub + ' AND TreeNumber LIKE ''' + @TreeNumber + '%''' 
							SET @RecCount = 1
							FETCH NEXT FROM curTb INTO @TreeNumber
						END
					CLOSE curTb
					DEALLOCATE curTb

--			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN ' +
--				'(SELECT DISTINCT TOP 500 DQSUIn FROM IMeSHTerm WHERE TermName LIKE ''%' + @TermA + '%'' and DQSUIc = ''d'' ORDER BY DQSUIn)' + @cr			
--						'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr			
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading with (nolock) WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr +
											' UNION SELECT DISTINCT PMID FROM iCitationMeSHHeading with (nolock) WHERE DescriptorUI IN (' + @QuerySub + ')'+ @cr
					SET @QueryDetails = '(MeSH Terms=' + @Extra
					IF @FindB > 0
						BEGIN
							SET @QuerySub = @QuerySub + 'UNION SELECT DISTINCT PMID FROM iCitationMeSHQualifier with (nolock) WHERE QualifierUI=' + CAST(@FindB AS varchar(20)) + @cr			
							IF @FindA = 0
								SET @QueryDetails = '(MeSH Subheading=' + @Extra
							ELSE
								SET @QueryDetails = @QueryDetails  + ' OR MeSH Subheading=' + @Extra
						END
					SET @QuerySub = @QuerySub + ' UNION '
					SET @QueryDetails = @QueryDetails  + ' OR'
				END
			ELSE
			  BEGIN
					SET @QuerySub = ''
					SET @QueryDetails = @QueryDetails  + '('
				END

			IF @FullNew = 1 AND @NoiseCount = 0
				SET @QuerySub = @QuerySub + 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,*,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,*,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF @NoiseCount = 0
				SET @QueryDetails = @QueryDetails  + ' Title/Abstract includes ' + @TermA 
			SET @QueryDetails = @QueryDetails  + ')'

		END

	IF @Tab = 'Title' 
		BEGIN

			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)

			IF @FullNew = 1 AND @NoiseCount = 0
			  SET @QuerySub = 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,ArticleTitle,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,ArticleTitle,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			IF @NoiseCount = 0
				SET @QueryDetails = 'Title includes ' + @TermA 
		END

	IF @Tab = 'Title/Abstract' 
		BEGIN
			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)


			IF @FullNew = 1 AND @NoiseCount = 0
			SET @QuerySub = 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,*,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,*,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			IF @NoiseCount = 0
				SET @QueryDetails = 'Title/Abstract includes ' + @TermA 
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildEachQuery]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildEachQuery]
	@Op								char(3),
	@Tab							varchar(35),
	@Field						varchar(35),
  @TermA						varchar(100),
  @TermB						varchar(100),
	@FindA						int,
	@FindB						int,
	@TestOrder				int,
	@Extra						varchar(200),
	@FullOld					int,
	@FullNew					int,
	@FullOldLimit			varchar(50),
	@QuerySub					varchar(4000)	OUTPUT, -- set to '' if no valid query
	@QueryDetails	  	varchar(2000)	OUTPUT
AS
  DECLARE @RecCount				int
	DECLARE @cr							char(1)
	DECLARE @uDescriptorID	int
	DECLARE @TreeNumber			varchar(100)
	DECLARE @NoiseCount			int

-- Misc. Initialization -------------------------------------------------
  SET NOCOUNT ON
	SET @cr = CHAR(13) 
  SET @QuerySub = ''
  SET @QueryDetails = ''

  IF @Tab = 'Title/Abstract/MeSH Term'  OR @Tab = 'Title/Abstract' 
		SELECT @NoiseCount = COUNT(*) FROM AJA..NoiseWord WHERE Word = @TermA
	ELSE
		SET @NoiseCount = 0

--print 'bseq >' + @TermA + '< ' + @tab + ' ' + cast(@noisecount as varchar(10))

	IF @Tab = 'PMID'
		BEGIN
			SET @QuerySub = 'SELECT ' + CAST(@FindA AS varchar(20)) + ' AS PMID' + @cr
			SET @QueryDetails = '(PMID=' + CAST(@FindA AS varchar(20)) + ')'
		END

	IF @Tab = 'Author' AND @Field = 'LastName'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE LastNameID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(Author="' + @TermA + '")'
		END

	IF @Tab = 'Author' AND @Field = 'LastNameInitials'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE LastNameID=' + CAST(@FindA AS varchar(20))
			IF LEN(@Extra) = 1
				SET @QuerySub = @QuerySub + ' AND Initial1=''' + @Extra + '''' + @cr
			ELSE
				SET @QuerySub = @QuerySub + ' AND Initial1=''' + SUBSTRING(@Extra,1,1) + '''' + 
												' AND Initial2=''' + SUBSTRING(@Extra,2,1) + '''' + @cr
			SET @QueryDetails = '(Author="' + @TermA + '")'
		END

	IF @Tab = 'Author' AND @Field = 'CollectiveName'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iAuthor WHERE CollectiveNameID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(CollectiveName="' + @TermA + '")'
		END

	IF @Tab = 'Chemical' AND @Field = 'ChemicalNameID'
		BEGIN
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iChemical WHERE ChemicalNameID=' + CAST(@FindA AS varchar(20)) + @cr
			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			SET @QueryDetails = '(Chemical=' + @TermA + ')'
			RETURN
		END

	IF @Tab = 'Journal' AND @Field = 'ISSN'
		BEGIN
			SET @QuerySub = 'SELECT PMID FROM iArticle WHERE ISSNID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(ISSN=' + @TermA + ')'
		END

	IF @Tab = 'Journal' AND @Field = 'MedLineTA'
		BEGIN
			SET @QuerySub = 'SELECT PMID FROM iArticle WHERE MedLineTAID=' + CAST(@FindA AS varchar(20)) + @cr
			SET @QueryDetails = '(MedlineTA="' + @TermA + '")'
		END

	IF @Tab = 'MeSH Term' 
		BEGIN
					SET @QuerySub = 'SELECT DISTINCT DQSUIn FROM iMeSHTreeNumber WHERE DQSUIc = ''D'' '
					DECLARE curTa CURSOR FOR SELECT TreeNumber FROM iMeSHTreeNumber WHERE DQSUIc = 'D' AND DQSUIn = @FindA
					OPEN curTa
					FETCH NEXT FROM curTa INTO @TreeNumber
					DECLARE @TreeCount int
					SET @TreeCount = 0
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @TreeCount = 0
								SET @QuerySub = @QuerySub + ' AND ('
							ELSE
								SET @QuerySub = @QuerySub + ' OR '
							SET @TreeCount = @TreeCount + 1
							SET @QuerySub = @QuerySub + ' TreeNumber LIKE ''' + @TreeNumber + '%''' 
							SET @RecCount = 1
							FETCH NEXT FROM curTa INTO @TreeNumber
						END
					CLOSE curTa
					DEALLOCATE curTa
					IF @TreeCount > 0
						SET @QuerySub = @QuerySub + ')'

--	SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN ' +
--		'(SELECT DISTINCT TOP 500 DQSUIn FROM IMeSHTerm WHERE TermName LIKE ''%' + @TermA + '%'' and DQSUIc = ''d'' ORDER BY DQSUIn )' + @cr			
--				'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr			
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr +
											' UNION SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN (' + @QuerySub + ')'+ @cr			
				SET @QueryDetails = '(MeSH Terms=' + @Extra
			IF @FindB > 0
				BEGIN
					SET @QuerySub = @QuerySub + 'UNION SELECT DISTINCT PMID FROM iCitationMeSHQualifier WHERE QualifierUI=' + CAST(@FindB AS varchar(20)) + @cr			
					IF @FindA = 0
						SET @QueryDetails = '(MeSH Subheading=' + @Extra
					ELSE
						SET @QueryDetails = @QueryDetails  + ' OR MeSH Subheading=' + @Extra
				END
				SET @QueryDetails = @QueryDetails + ')'
		END

	IF @Tab = 'Title/Abstract/MeSH Term' 
		BEGIN

			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)

		  IF @FindA > 0
				BEGIN
					SET @QuerySub = 'SELECT DISTINCT DQSUIn FROM iMeSHTreeNumber WHERE DQSUIc = ''D'' '
					DECLARE curTb CURSOR FOR SELECT TreeNumber FROM iMeSHTreeNumber WHERE DQSUIc = 'D' AND DQSUIn = @FindA
					OPEN curTb
					FETCH NEXT FROM curTb INTO @TreeNumber
					WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @QuerySub = @QuerySub + ' AND TreeNumber LIKE ''' + @TreeNumber + '%''' 
							SET @RecCount = 1
							FETCH NEXT FROM curTb INTO @TreeNumber
						END
					CLOSE curTb
					DEALLOCATE curTb

--			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN ' +
--				'(SELECT DISTINCT TOP 500 DQSUIn FROM IMeSHTerm WHERE TermName LIKE ''%' + @TermA + '%'' and DQSUIc = ''d'' ORDER BY DQSUIn)' + @cr			
--						'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr			
			SET @QuerySub = 'SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI=' + CAST(@FindA AS varchar(20)) + @cr +
											' UNION SELECT DISTINCT PMID FROM iCitationMeSHHeading WHERE DescriptorUI IN (' + @QuerySub + ')'+ @cr
					SET @QueryDetails = '(MeSH Terms=' + @Extra
					IF @FindB > 0
						BEGIN
							SET @QuerySub = @QuerySub + 'UNION SELECT DISTINCT PMID FROM iCitationMeSHQualifier WHERE QualifierUI=' + CAST(@FindB AS varchar(20)) + @cr			
							IF @FindA = 0
								SET @QueryDetails = '(MeSH Subheading=' + @Extra
							ELSE
								SET @QueryDetails = @QueryDetails  + ' OR MeSH Subheading=' + @Extra
						END
					SET @QuerySub = @QuerySub + ' UNION '
					SET @QueryDetails = @QueryDetails  + ' OR'
				END
			ELSE
			  BEGIN
					SET @QuerySub = ''
					SET @QueryDetails = @QueryDetails  + '('
				END

			IF @FullNew = 1 AND @NoiseCount = 0
				SET @QuerySub = @QuerySub + 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,*,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,*,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF @NoiseCount = 0
				SET @QueryDetails = @QueryDetails  + ' Title/Abstract includes ' + @TermA 
			SET @QueryDetails = @QueryDetails  + ')'

		END

	IF @Tab = 'Title' 
		BEGIN

			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)

			IF @FullNew = 1 AND @NoiseCount = 0
			  SET @QuerySub = 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,ArticleTitle,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,ArticleTitle,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			IF @NoiseCount = 0
				SET @QueryDetails = 'Title includes ' + @TermA 
		END

	IF @Tab = 'Title/Abstract' 
		BEGIN
			IF @TestOrder = 100
				BEGIN
					IF CHARINDEX(' ', @TermA) > 0
						SET @TermA = '"' + @TermA + '"'
				END
			ELSE
				IF @Op = 'All'
					SET @TermA = dbo.fn_SearchInsertAnd(@TermA)
				ELSE
					SET @TermA = dbo.fn_SearchInsertOr(@TermA)


			IF @FullNew = 1 AND @NoiseCount = 0
			SET @QuerySub = 'SELECT [Key] AS PMID FROM CONTAINSTABLE(iWideNew,*,''' + @TermA + ''')  ' + @cr

			IF @FullOld = 1 AND @FullNew = 1
				SET @QuerySub = @QuerySub + ' UNION '

			IF @FullOld = 1
				SET @QuerySub = @QuerySub + ' SELECT [Key] AS PMID FROM CONTAINSTABLE(iWide,*,''' + @TermA + '''' + @FullOldLimit + ') ' + @cr

			IF LEFT(@TermA,1) <> '"'
				SET @TermA = '"' + @TermA + '"'
			IF @NoiseCount = 0
				SET @QueryDetails = 'Title/Abstract includes ' + @TermA 
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryAdd_AJA]    Script Date: 10/28/2013 15:49:46 ******/
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
    FROM  AJA.dbo.SearchSummary
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
  INSERT INTO AJA.dbo.SearchSummary (
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
  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
    VALUES (@SearchID, 1, @Op1, @Terms1, @Tab1)
  IF LEN(@Terms2) > 0
	  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 2, @Op2, @Terms2, @Tab2)
  IF LEN(@Terms3) > 0
	  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 3, @Op3, @Terms3, @Tab3)
  IF LEN(@Terms4) > 0
	  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 4, @Op4, @Terms4, @Tab4)
  IF LEN(@Terms5) > 0
	  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 5, @Op5, @Terms5, @Tab5)
  IF LEN(@Terms6) > 0
	  INSERT INTO AJA.dbo.SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 6, @Op6, @Terms6, @Tab6)
  SET @ReturnCode = @SearchID
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchQueryAdd]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchQueryAdd]
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
    FROM AJA..SearchSummary
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
  INSERT INTO AJA..SearchSummary (
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
  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
    VALUES (@SearchID, 1, @Op1, @Terms1, @Tab1)
  IF LEN(@Terms2) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 2, @Op2, @Terms2, @Tab2)
  IF LEN(@Terms3) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 3, @Op3, @Terms3, @Tab3)
  IF LEN(@Terms4) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 4, @Op4, @Terms4, @Tab4)
  IF LEN(@Terms5) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 5, @Op5, @Terms5, @Tab5)
  IF LEN(@Terms6) > 0
	  INSERT INTO AJA..SearchDetails (SearchID, Seq, Op, Terms, Tab)
	    VALUES (@SearchID, 6, @Op6, @Terms6, @Tab6)
  SET @ReturnCode = @SearchID
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchLookupTokens]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchLookupTokens]
	@Tab				varchar(35),
	@SearchA 		varchar(100),
	@SearchB 		varchar(100),
	@Field			varchar(35)	OUTPUT,
	@Status 		int 				OUTPUT,
	@FindA			int 				OUTPUT,
	@FindB			int 				OUTPUT
AS
  DECLARE @RecCount		int
  SET NOCOUNT ON
	SET @Status		= -1
	SET @FindA		= 0
	SET @FindB		= 0
	IF @Tab = 'Author'
	  BEGIN
			SELECT @FindA = LastNameID
				FROM xLastName
				WHERE LastName = @SearchA	
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'LastName'
				  IF @SearchB IS NOT NULL
					  BEGIN
							SELECT @FindB = InitialsID
								FROM xInitials
								WHERE Initials = @SearchB
						  IF @FindB = 0
								BEGIN
									SET @Status = 0
									SET @FindA	= 0
								END
							ELSE
								SET @Field = 'LastNameInitials'
						END
				END
		  ELSE
				BEGIN
					SELECT @FindA = CollectiveNameID
						FROM xCollectiveName
						WHERE CollectiveName = @SearchA	
				  IF @FindA > 0
						BEGIN
						  SET @Status = 2
							SET @Field = 'CollectiveName'
						END
				END
		END --@Tab = 'iAuthor'
	IF @Tab = 'Journal'
	  BEGIN
			SELECT @FindA = ISSNID
				FROM xISSN
				WHERE ISSN = @SearchA	
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'ISSN'
				END
		  ELSE
				BEGIN
					SELECT @FindA = MedLineTAID
						FROM xMedLineTA
						WHERE MedLineTA = @SearchA	
					IF @FindA > 0
						BEGIN
						  SET @Status = 2
							SET @Field = 'MedLineTA'
						END
				END
		END --@Tab = 'iJournal'
	IF @Tab = 'MeSH Term'
	  BEGIN
			SELECT @FindA = ASCII(DQSUIc),
						 @FindB = DQSUIn
				FROM iMeSHTerm
				WHERE TermName = @SearchA	
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'MeSHTerm'
				END
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchRange_AJA]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchFetchRange_AJA]
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
		    FROM AJA.dbo.SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  INSERT INTO AJA.dbo.SearchView (ViewPMID,ViewDate,UserID, SearchID,ViewCountSummary) VALUES (0,GETDATE(), @UserID, @SearchID, @RangeEnd - @RangeStart + 1)
  SELECT	r.PMID,
					r.List,
					ISNULL(w.ArticleTitle,wn.ArticleTitle) AS 'ArticleTitle',
					AuthorList,
					MedlineTA,
					MedlinePgn,
					DisplayDate,
					DisplayNotes
    FROM AJA.dbo.SearchResults r
		JOIN iCitation c ON c.PMID = r.PMID
		LEFT JOIN iWide w ON w.PMID = r.PMID
		LEFT JOIN iWideNew wn ON wn.PMID = r.PMID
		WHERE SearchID = @SearchID AND
					List		 >= @RangeStart	AND
					List 		<= @RangeEnd
		ORDER BY List
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchRange]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchFetchRange]
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
		    FROM AJA..SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  INSERT INTO AJA..SearchView (UserID, SearchID,ViewCountSummary) VALUES (@UserID, @SearchID, @RangeEnd - @RangeStart + 1)
  SELECT	r.PMID,
					r.List,
					ISNULL(w.ArticleTitle,wn.ArticleTitle) AS 'ArticleTitle',
					AuthorList,
					MedlineTA,
					MedlinePgn,
					DisplayDate,
					DisplayNotes
    FROM AJA..SearchResults r
		JOIN iCitation c ON c.PMID = r.PMID
		LEFT JOIN iWide w ON w.PMID = r.PMID
		LEFT JOIN iWideNew wn ON wn.PMID = r.PMID
		WHERE SearchID = @SearchID		AND
					List		 >= @RangeStart	AND
					List 		<= @RangeEnd
		ORDER BY List
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchPMID]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
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
		    FROM AJA..SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  INSERT INTO AJA..SearchView (UserID, SearchID, ViewPMID) VALUES (@UserID, @SearchID, @PMID)
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
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineBuildLookup-Instance]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineBuildLookup-Instance]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
	DECLARE @RecCount int




	INSERT INTO xCollectiveName(CollectiveName)
	SELECT DISTINCT CollectiveName
	FROM cogentx.dbo.xCollectiveName 
	WHERE CollectiveName NOT IN
	   (SELECT CollectiveName
	   FROM xCollectiveName) AND
	CollectiveName IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCollectiveName', @RecCount, 0)		
	
	
	
	INSERT INTO xChemicalName(ChemicalName)
	SELECT DISTINCT ChemicalName
	FROM cogentx.dbo.xChemicalName
	WHERE ChemicalName NOT IN
	   (SELECT ChemicalName
	   FROM xChemicalName)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalName', @RecCount, 0)		
	
	INSERT INTO xChemicalRegistry(ChemicalRegistry)
	SELECT DISTINCT ChemicalRegistry
	FROM cogentx.dbo.xChemicalRegistry
	WHERE ChemicalRegistry NOT IN
	   (SELECT ChemicalRegistry
	   FROM xChemicalRegistry)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalRegistry', @RecCount, 0)		
	
	INSERT INTO xCommentType(CommentType)
	SELECT DISTINCT CommentType
	FROM cogentx.dbo.xCommentType
	WHERE CommentType NOT IN
	   (SELECT CommentType
	   FROM xCommentType)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCommentType', @RecCount, 0)		
	
	INSERT INTO xCountry(CountryName)
	SELECT DISTINCT CountryName
	FROM cogentx.dbo.xCountry
	WHERE CountryName NOT IN
	   (SELECT CountryName
	   FROM xCountry)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCountry', @RecCount, 0)		
	
	INSERT INTO xDataBank(DataBankName)
	SELECT DISTINCT DataBankName
	FROM cogentx.dbo.xDataBank
	WHERE DataBankName NOT IN
	   (SELECT DataBankName
	   FROM xDataBank)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xDataBank', @RecCount, 0)		

	
	INSERT INTO xGrantAcronym(Acronym)
	SELECT DISTINCT Acronym
	FROM cogentx.dbo.xGrantAcronym
	WHERE Acronym NOT IN
	   (SELECT Acronym
	   FROM xGrantAcronym)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAcronym', @RecCount, 0)		
	
	INSERT INTO xGrantAgency(Agency)
	SELECT DISTINCT Agency
	FROM cogentx.dbo.xGrantAgency
	WHERE Agency NOT IN
	   (SELECT Agency
	   FROM xGrantAgency)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAgency', @RecCount, 0)		
	
	INSERT INTO xGrantID(GrantID)
	SELECT DISTINCT GrantID
	FROM cogentx.dbo.xGrantID
	WHERE GrantID NOT IN
	   (SELECT GrantID
	   FROM xGrantID)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantID', @RecCount, 0)		

	INSERT INTO xISSN(ISSN)
	SELECT DISTINCT ISSN
	FROM cogentx.dbo.xISSN
	WHERE ISSN NOT IN
	   (SELECT ISSN
	   FROM xISSN) AND
		ISSN IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
		
	
	INSERT INTO xKeyword(Keyword)
	SELECT DISTINCT Keyword
	FROM cogentx.dbo.xKeyword
	WHERE Keyword NOT IN
	   (SELECT Keyword
	   FROM xKeyword)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xKeyword', @RecCount, 0)		
	
	INSERT INTO xLanguage(Lang)
	SELECT DISTINCT Lang
	FROM cogentx.dbo.xLanguage
	WHERE Lang NOT IN
	   (SELECT Lang
	   FROM xLanguage)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xLanguage', @RecCount, 0)		
	
	INSERT INTO xLastName(LastName)
	SELECT DISTINCT LastName
	FROM cogentx.dbo.xLastName
	WHERE LastName NOT IN
	   (SELECT LastName
	   FROM xLastName) AND LastName IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
		
	
	INSERT INTO xMedlineTA(MedlineTA)
	SELECT DISTINCT MedlineTA
	FROM cogentx.dbo.xMedlineTA
	WHERE MedlineTA NOT IN
	   (SELECT MedlineTA
	   FROM xMedlineTA)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xMedlineTA', @RecCount, 0)		
	
	INSERT INTO xPublicationType(PublicationType)
	SELECT DISTINCT PublicationType
	FROM cogentx.dbo.xPublicationType
	WHERE PublicationType NOT IN
	   (SELECT PublicationType
	   FROM xPublicationType)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xPublicationType', @RecCount, 0)		
	
	INSERT INTO xSpaceFlightMission(SpaceFlightMission)
	SELECT DISTINCT SpaceFlightMission
	FROM cogentx.dbo.xSpaceFlightMission
	WHERE SpaceFlightMission NOT IN
	   (SELECT SpaceFlightMission
	   FROM xSpaceFlightMission)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSpaceFlightMission', @RecCount, 0)		
	
	INSERT INTO xOwner(Owner)
	SELECT DISTINCT Owner
	FROM cogentx.dbo.xOwner
	WHERE Owner NOT IN
	   (SELECT Owner
	   FROM xOwner)

	
	
	INSERT INTO xSuffix(Suffix)
	SELECT DISTINCT Suffix
	FROM cogentx.dbo.xSuffix
	WHERE Suffix NOT IN
	   (SELECT Suffix
	   FROM xSuffix)
	SET @RecCount = @@ROWCOUNT	
	
	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSuffix', @RecCount, 0)

	INSERT INTO xCitedMedium(CitedMedium)
	SELECT DISTINCT CitedMedium
	FROM cogentx.dbo.xCitedMedium 
	WHERE CitedMedium NOT IN
	   (SELECT CitedMedium
	   FROM xCitedMedium)
	SET @RecCount = @@ROWCOUNT	
	
INSERT INTO cogentx.dbo.LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCitedMedium2', @RecCount, 0)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineBuildLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineBuildLookup]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
	DECLARE @RecCount int

UPDATE wAuthor SET LastName = LTRIM(RTRIM(LastName))

UPDATE wAuthor SET LastName = REPLACE(LastName,'|','')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','c')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','n')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','y')
UPDATE wAuthor SET LastName = REPLACE(LastName,'�','y')

UPDATE wAuthor SET LastName = REPLACE(LastName,'ö','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ü','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'á','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ä','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'é','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ó','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ç','c')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ý','y')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ń','n')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ú','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ñ','n')
UPDATE wAuthor SET LastName = REPLACE(LastName,'è','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'â','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ø','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'í','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ĭ','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ë','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ë','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ã','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ć','c')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ô','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'å','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ł','l')
UPDATE wAuthor SET LastName = REPLACE(LastName,'à','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ş','s')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ğ','g')
UPDATE wAuthor SET LastName = REPLACE(LastName,'î','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ò','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ś','s')
UPDATE wAuthor SET LastName = REPLACE(LastName,'Ł','l')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ù','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ê','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ă','a')
UPDATE wAuthor SET LastName = REPLACE(LastName,'õ','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'Ø','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ì','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ï','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ź','z')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ņ','n')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ŕ','r')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ĕ','e')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ů','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ĉ','c')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ĵ','j')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ŝ','s')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ÿ','y')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ŏ','o')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ţ','t')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ŭ','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'û','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ĩ','i')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ũ','u')
UPDATE wAuthor SET LastName = REPLACE(LastName,'ŷ','y')

--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ö','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ü','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'á','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ä','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'é','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ó','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ç','c')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ý','y')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ń','n')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ú','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ñ','n')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'è','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'â','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ø','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'í','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ĭ','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ë','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ë','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ã','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ć','c')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ô','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'å','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ł','l')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'à','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ş','s')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ğ','g')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'î','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ò','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ś','s')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'Ł','l')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ù','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ê','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ă','a')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'õ','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'Ø','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ì','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ï','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ź','z')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ņ','n')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ŕ','r')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ĕ','e')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ů','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ĉ','c')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ĵ','j')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ŝ','s')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ÿ','y')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ŏ','o')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ţ','t')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ŭ','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'û','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ĩ','i')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ũ','u')
--UPDATE wInvestigator SET LastName = REPLACE(LastName,'ŷ','y')

--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ö','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ü','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'á','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ä','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'é','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ó','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ç','c')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ý','y')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ń','n')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ú','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ñ','n')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'è','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'â','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ø','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'í','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ĭ','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ë','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ë','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ã','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ć','c')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ô','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'å','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ł','l')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'à','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ş','s')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ğ','g')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'î','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ò','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ś','s')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'Ł','l')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ù','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ê','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ă','a')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'õ','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'Ø','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ì','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ï','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ź','z')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ņ','n')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ŕ','r')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ĕ','e')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ů','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ĉ','c')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ĵ','j')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ŝ','s')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ÿ','y')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ŏ','o')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ţ','t')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ŭ','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'û','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ĩ','i')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ũ','u')
--UPDATE wPersonalNameSubject SET LastName = REPLACE(LastName,'ŷ','y')


	--INSERT INTO xArticleDate(DateType)
	--SELECT DISTINCT DateType
	--FROM wArticleDate
	--WHERE DateType NOT IN
	--   (SELECT DateType
	--   FROM xArticleDate) AND
	--DateType IS NOT NULL
	--SET @RecCount = @@ROWCOUNT	
  --INSERT INTO LogTables(LogSet,RunType,TableName,RecCount, RecCountPrior) 
	--	VALUES (@LogSet,'x','xArticleDate', @RecCount, 0)		
	
	UPDATE wAuthor
		SET CollectiveName =  substring(CollectiveName,1,448)
		WHERE LEN(CollectiveName) > 448


	INSERT INTO xCollectiveName(CollectiveName)
	SELECT DISTINCT CollectiveName
	FROM wAuthor
	WHERE CollectiveName NOT IN
	   (SELECT CollectiveName
	   FROM xCollectiveName) AND
	CollectiveName IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCollectiveName', @RecCount, 0)		
	
--	INSERT INTO xAffiliation(Affiliation)
--	SELECT DISTINCT Affiliation
--	FROM wInvestigator
--	WHERE Affiliation NOT IN
--	   (SELECT Affiliation
--	   FROM xAffiliation)
--	SET @RecCount = @@ROWCOUNT	
--INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior)  
--		VALUES (@LogSet,'x',GETDATE(),'xAffiliation', @RecCount, 0)		
	
	INSERT INTO xChemicalName(ChemicalName)
	SELECT DISTINCT NameOfSubstance
	FROM wChemical
	WHERE NameOfSubstance NOT IN
	   (SELECT ChemicalName
	   FROM xChemicalName)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalName', @RecCount, 0)		
	
	INSERT INTO xChemicalRegistry(ChemicalRegistry)
	SELECT DISTINCT RegistryNumber
	FROM wChemical
	WHERE RegistryNumber NOT IN
	   (SELECT ChemicalRegistry
	   FROM xChemicalRegistry)
	SET @RecCount = @@ROWCOUNT	
 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xChemicalRegistry', @RecCount, 0)		
	
	INSERT INTO xCommentType(CommentType)
	SELECT DISTINCT CommentType
	FROM wComment
	WHERE CommentType NOT IN
	   (SELECT CommentType
	   FROM xCommentType)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCommentType', @RecCount, 0)		
	
	INSERT INTO xCountry(CountryName)
	SELECT DISTINCT Country
	FROM wMedlineJournalInfo
	WHERE Country NOT IN
	   (SELECT CountryName
	   FROM xCountry)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCountry', @RecCount, 0)		
	
	INSERT INTO xDataBank(DataBankName)
	SELECT DISTINCT DataBankName
	FROM wDataBank
	WHERE DataBankName NOT IN
	   (SELECT DataBankName
	   FROM xDataBank)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xDataBank', @RecCount, 0)		
/*	
	INSERT INTO xForeName(ForeName)
	SELECT DISTINCT ForeName
	FROM wAuthor
	WHERE ForeName NOT IN
	   (SELECT ForeName
	   FROM xForeName)
	SET @RecCount = @@ROWCOUNT	

	INSERT INTO xForeName(ForeName)
	SELECT DISTINCT ForeName
	FROM wInvestigator
	WHERE ForeName NOT IN
	   (SELECT ForeName
	   FROM xForeName)
	SET @RecCount = @RecCount + @@ROWCOUNT	

	INSERT INTO xForeName(ForeName)
	SELECT DISTINCT ForeName
	FROM wPersonalNameSubject
	WHERE ForeName NOT IN
	   (SELECT ForeName
	   FROM xForeName)
	SET @RecCount = @RecCount + @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount, RecCountPrior) 
		VALUES (@LogSet,'x','xForeName', @RecCount, 0)		
*/	
	INSERT INTO xGrantAcronym(Acronym)
	SELECT DISTINCT Acronym
	FROM wGrant
	WHERE Acronym NOT IN
	   (SELECT Acronym
	   FROM xGrantAcronym)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAcronym', @RecCount, 0)		
	
	INSERT INTO xGrantAgency(Agency)
	SELECT DISTINCT Agency
	FROM wGrant
	WHERE Agency NOT IN
	   (SELECT Agency
	   FROM xGrantAgency)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantAgency', @RecCount, 0)		
	
	INSERT INTO xGrantID(GrantID)
	SELECT DISTINCT GrantID
	FROM wGrant
	WHERE GrantID NOT IN
	   (SELECT GrantID
	   FROM xGrantID)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xGrantID', @RecCount, 0)		
/*	
	INSERT INTO xInitials(Initials)
	SELECT DISTINCT Initials
	FROM wAuthor
	WHERE Initials NOT IN
	   (SELECT Initials
	   FROM xInitials)
	SET @RecCount = @@ROWCOUNT	
	
	INSERT INTO xInitials(Initials)
	SELECT DISTINCT Initials
	FROM wInvestigator
	WHERE Initials NOT IN
	   (SELECT Initials
	   FROM xInitials)
	SET @RecCount = @RecCount + @@ROWCOUNT	
	
	INSERT INTO xInitials(Initials)
	SELECT DISTINCT Initials
	FROM wPersonalNameSubject
	WHERE Initials NOT IN
	   (SELECT Initials
	   FROM xInitials)
	SET @RecCount = @RecCount + @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount, RecCountPrior) 
		VALUES (@LogSet,'x','xInitials', @RecCount, 0)		
	*/
	INSERT INTO xISSN(ISSN)
	SELECT DISTINCT ISSN
	FROM wJournal
	WHERE ISSN NOT IN
	   (SELECT ISSN
	   FROM xISSN) AND
		ISSN IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xISSN', @RecCount, 0)		
	
	INSERT INTO xKeyword(Keyword)
	SELECT DISTINCT Keyword_Text
	FROM wKeyword
	WHERE Keyword_Text NOT IN
	   (SELECT Keyword
	   FROM xKeyword)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xKeyword', @RecCount, 0)		
	
	INSERT INTO xLanguage(Lang)
	SELECT DISTINCT Language_Text
	FROM wLanguage
	WHERE Language_Text NOT IN
	   (SELECT Lang
	   FROM xLanguage)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xLanguage', @RecCount, 0)		
	
	INSERT INTO xLastName(LastName)
	SELECT DISTINCT LastName
	FROM wAuthor
	WHERE LastName NOT IN
	   (SELECT LastName
	   FROM xLastName) AND LastName IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
	
	--INSERT INTO xLastName(LastName)
	--SELECT DISTINCT LastName
	--FROM wInvestigator
	--WHERE LastName NOT IN
	--   (SELECT LastName
	--   FROM xLastName) AND LastName IS NOT NULL
	--SET @RecCount = @RecCount + @@ROWCOUNT	
	
--	INSERT INTO xLastName(LastName)
--	SELECT DISTINCT LastName
--	FROM wPersonalNameSubject
--	WHERE LastName NOT IN
--	   (SELECT LastName
--	   FROM xLastName) AND LastName IS NOT NULL
--	SET @RecCount = @RecCount + @@ROWCOUNT	
--INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
--		VALUES (@LogSet,'x',GETDATE(),'xLastName', @RecCount, 0)		
	
	INSERT INTO xMedlineTA(MedlineTA)
	SELECT DISTINCT MedlineTA
	FROM wMedlineJournalInfo
	WHERE MedlineTA NOT IN
	   (SELECT MedlineTA
	   FROM xMedlineTA)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xMedlineTA', @RecCount, 0)		
	
	INSERT INTO xPublicationType(PublicationType)
	SELECT DISTINCT PublicationType_Text
	FROM wPublicationType
	WHERE PublicationType_Text NOT IN
	   (SELECT PublicationType
	   FROM xPublicationType)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xPublicationType', @RecCount, 0)		
	
	INSERT INTO xSpaceFlightMission(SpaceFlightMission)
	SELECT DISTINCT SpaceFlightMission_Text
	FROM wSpaceFlightMission
	WHERE SpaceFlightMission_Text NOT IN
	   (SELECT SpaceFlightMission
	   FROM xSpaceFlightMission)
	SET @RecCount = @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSpaceFlightMission', @RecCount, 0)		
	
	INSERT INTO xOwner(Owner)
	SELECT DISTINCT Owner
	FROM dbo.wMedlineCitation
	WHERE Owner NOT IN
	   (SELECT Owner
	   FROM xOwner)

	--INSERT INTO xOwner(Owner)
	--SELECT DISTINCT Owner
	--FROM wGeneralNote
	--WHERE Owner NOT IN
	--   (SELECT Owner
	--   FROM xOwner)

	INSERT INTO xOwner(Owner)
	SELECT DISTINCT Owner
	FROM wKeywordList 
	WHERE Owner NOT IN
	   (SELECT Owner
	   FROM xOwner)

	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xOwner', @RecCount, 0)		
	
	INSERT INTO xSuffix(Suffix)
	SELECT DISTINCT Suffix
	FROM wAuthor
	WHERE Suffix NOT IN
	   (SELECT Suffix
	   FROM xSuffix)
	SET @RecCount = @@ROWCOUNT	
	
	--INSERT INTO xSuffix(Suffix)
	--SELECT DISTINCT Suffix
	--FROM wInvestigator
	--WHERE Suffix NOT IN
	--   (SELECT Suffix
	--   FROM xSuffix)
	--SET @RecCount = @RecCount + @@ROWCOUNT	
	
	--INSERT INTO xSuffix(Suffix)
	--SELECT DISTINCT Suffix
	--FROM wPersonalNameSubject
	--WHERE Suffix NOT IN
	--   (SELECT Suffix
	--   FROM xSuffix)
	--SET @RecCount = @RecCount + @@ROWCOUNT	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xSuffix', @RecCount, 0)

	INSERT INTO xCitedMedium(CitedMedium)
	SELECT DISTINCT CitedMedium
	FROM wJournalIssue
	WHERE CitedMedium NOT IN
	   (SELECT CitedMedium
	   FROM xCitedMedium)
	SET @RecCount = @@ROWCOUNT	
	
INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'x',GETDATE(),'xCitedMedium2', @RecCount, 0)
GO
/****** Object:  StoredProcedure [dbo].[ap_InsertIntoIWideNew]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_InsertIntoIWideNew]
  @LogSet 			varchar(50)
AS
BEGIN
  SET NOCOUNT ON
	DECLARE @RecCount int


INSERT INTO iWideNew (
	PMID,
	ArticleTitle,
	AbstractText,
	CopyrightInformation,
	VernacularTitle,
	Affiliation
)
select t.PMID,
            t.ArticleTitle,  
            AbText = (Case when t.AbstractText IS NULL THEN
						CASE WHEN t.wAbstractTextcount = 0 THEN
							 CASE	WHEN t.OtherAbstractcount = 0 THEN
										' '
									WHEN t.OtherAbstractcount=1 THEN																	
										(SELECT LIst.AbstractText from
										(SELECT Type + ':'+ AbstractText  AS [text()]
										   FROM wOtherAbstract t1
										  WHERE t1.PMID = t.PMID
										  FOR XML PATH('')) AS List(AbstractText))
                              
									END
								WHEN t.wAbstractTextcount = 1 THEN
									(SELECT AbstractText_Text  
									   FROM wAbstractText t2
									  WHERE t2.PMID = t.PMID and t2.Abstract_Id = t.Abstract_Id)
						
								ELSE 
									(SELECT LIst.AbstractText from
									(SELECT Label + ':'+ AbstractText_Text  AS [text()]
									   FROM wAbstractText t2
									  WHERE t2.PMID = t.PMID and t2.Abstract_Id = t.Abstract_Id
									  FOR XML PATH('')) AS List(AbstractText))
								END
						ELSE
							t.AbstractText
						END),                                                                                                                   
            t.CopyrightInformation,
            t.VernacularTitle,
            t.Affiliation
			FROM(

SELECT     a.PMID,
            a.ArticleTitle,  
            b.AbstractText,
            wAbstractTextcount = (SELECT COUNT(1) 
					      FROM wAbstractText t1
                              WHERE t1.PMID = a.PMID),
             OtherAbstractcount = (SELECT COUNT(1) 
					      FROM wOtherAbstract t2
                              WHERE t2.PMID = a.PMID), 
            b.CopyrightInformation,
            a.VernacularTitle,
            a.Affiliation,
            b.Abstract_Id
FROM wArticle a with(nolock)
LEFT JOIN wAbstract b with(nolock) on b.PMID = a.PMID
LEFT JOIN iCitation c with(nolock) on c.PMID = a.PMID                                               
WHERE c.DateCreated >= '2001-01-01') t


SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'i',GETDATE(),'iWideNew',@RecCount,0)	
END
GO
/****** Object:  StoredProcedure [dbo].[ap_InsertIntoIWide]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_InsertIntoIWide]
  @LogSet 			varchar(50)
AS
  BEGIN
  SET NOCOUNT ON
	DECLARE @RecCount int

INSERT INTO iWide (
	PMID,
	ArticleTitle,
	AbstractText,
	CopyrightInformation,
	VernacularTitle,
	Affiliation
)
select  t.PMID,
            t.ArticleTitle,  
            AbText = (Case when t.AbstractText IS NULL THEN
						CASE WHEN t.wAbstractTextcount = 0 THEN
							 CASE	WHEN t.OtherAbstractcount = 0 THEN
										' '
									WHEN t.OtherAbstractcount=1 THEN																	
										(SELECT LIst.AbstractText from
										(SELECT Type + ':'+ AbstractText  AS [text()]
										   FROM wOtherAbstract t1
										  WHERE t1.PMID = t.PMID
										  FOR XML PATH('')) AS List(AbstractText))
                              
									END
								WHEN t.wAbstractTextcount = 1 THEN
									(SELECT AbstractText_Text  
									   FROM wAbstractText t2
									  WHERE t2.PMID = t.PMID and t2.Abstract_Id = t.Abstract_Id)
						
								ELSE 
									(SELECT LIst.AbstractText from
									(SELECT Label + ':'+ AbstractText_Text  AS [text()]
									   FROM wAbstractText t2
									  WHERE t2.PMID = t.PMID and t2.Abstract_Id = t.Abstract_Id
									  FOR XML PATH('')) AS List(AbstractText))
								END
						ELSE
							t.AbstractText
						END),                                                                                                                   
            t.CopyrightInformation,
            t.VernacularTitle,
            t.Affiliation
			FROM(

SELECT      a.PMID,
            a.ArticleTitle,  
            b.AbstractText,
            wAbstractTextcount = (SELECT COUNT(1) 
					      FROM wAbstractText t1
                              WHERE t1.PMID = a.PMID),
             OtherAbstractcount = (SELECT COUNT(1) 
					      FROM wOtherAbstract t2
                              WHERE t2.PMID = a.PMID), 
            b.CopyrightInformation,
            a.VernacularTitle,
            a.Affiliation,
            b.Abstract_Id
FROM wArticle a with(nolock)
LEFT JOIN wAbstract b with(nolock) on b.PMID = a.PMID
LEFT JOIN iCitation c with(nolock) on c.PMID = a.PMID                                               
WHERE c.DateCreated < '2001-01-01') t

SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,'i',GETDATE(),'iWide',@RecCount,0)	
END
GO
/****** Object:  StoredProcedure [dbo].[ap_DeletePMIDInAllTables]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_DeletePMIDInAllTables]
  @LogSet 			varchar(50),
	@UpdateSource	int,
	@UpdateDate		smalldatetime
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
	  SELECT  [PMID]      
  FROM [Cogent3].[dbo].[DeleteCition] with (nolock)
  
--		  JOIN iArticle i ON i.PMID = w.PMID
	SET @RecCount = @@ROWCOUNT	
  SET @DeleteCount = @RecCount
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Duplicate PMID ',0,@RecCount)		
  INSERT INTO #e
	  SELECT PMID
		  FROM wDeleteCitation
	SET @RecCount = @@ROWCOUNT	
  SET @DeleteCount = @DeleteCount + @RecCount

  IF @DeleteCount > 0
		BEGIN
			DELETE iAccession FROM iAccession i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAccession',0,@RecCount)
		
			DELETE iArticle FROM iArticle i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticle',0,@RecCount)
		
		
			DELETE iArticleDate FROM iArticleDate i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticleDate',0,@RecCount)
		
		
			DELETE iWide FROM iWide i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWide',0,@RecCount)
		
		
			DELETE iWideNew FROM iWideNew i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWideNew',0,@RecCount)
		
			DELETE iAuthor FROM iAuthor i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAuthor',0,@RecCount)
		
			--DELETE iAuthor2 FROM iAuthor2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iChemical FROM iChemical i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iChemical',0,@RecCount)
		
			--DELETE iChemical2 FROM iChemical2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitation FROM iCitation i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitation',0,@RecCount)
		
			DELETE iCitationMeSHHeading FROM iCitationMeSHHeading i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHHeading',0,@RecCount)
		
			--DELETE iCitationMeSHHeading2 FROM iCitationMeSHHeading2 i INNER JOIN #e e ON e.PMID = i.PMID
			--DELETE iCitationMeSHHeadingAside FROM iCitationMeSHHeadingAside i INNER JOIN #e e ON e.PMID = i.PMID		
		
		
			--DELETE iCitationMeSHHeadingAside2 FROM iCitationMeSHHeadingAside2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitationMeSHQualifier FROM iCitationMeSHQualifier i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHQualifier',0,@RecCount)
		
		--	DELETE iCitationMeSHQualifier2 FROM iCitationMeSHQualifier2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitationSubset FROM iCitationSubset i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationSubset',0,@RecCount)
			
			DELETE iCitationScreen FROM iCitationScreen i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationScreen',0,@RecCount)
		
			DELETE iComment FROM iComment i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iComment',0,@RecCount)
		
			DELETE iDataBank FROM iDataBank i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iDataBank',0,@RecCount)
			DELETE iGrant FROM iGrant i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iGrant',0,@RecCount)
			--DELETE iGeneralNote FROM iGeneralNote i INNER JOIN #e e ON e.PMID = i.PMID			
			--DELETE iInvestigator FROM iInvestigator i INNER JOIN #e e ON e.PMID = i.PMID
		
			DELETE iKeyword FROM iKeyword i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeyword',0,@RecCount)
			DELETE iKeywordList FROM iKeywordList i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeywordList',0,@RecCount)
			DELETE iLanguage FROM iLanguage i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iLanguage',0,@RecCount)
			--DELETE iPersonalNameSubject FROM iPersonalNameSubject i INNER JOIN #e e ON e.PMID = i.PMID
			
			DELETE iPublicationType FROM iPublicationType i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iPublicationType',0,@RecCount)
			--DELETE iSpaceFlightMission FROM iSpaceFlightMission i INNER JOIN #e e ON e.PMID = i.PMID
			
		
			DELETE iOtherID FROM iOtherID i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iOtherID ',0,@RecCount)	
		END
	DROP TABLE #e
	  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation Compeleted ',0,@RecCount)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineReportWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineReportWork]
  @LogSet 	varchar(50)
AS
	DECLARE @RecCount 	int
  SET NOCOUNT ON
  SELECT * 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType	= 'w'
  SELECT @RecCount = SUM(RecCount) 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType = 'w'
  SELECT @RecCount AS 'Total MedLine Work Records'
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineReportSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineReportSearch]
  @LogSet 	varchar(50)
AS
	DECLARE @RecCount 	int
  SET NOCOUNT ON
  SELECT * 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType	= 'i'
  SELECT @RecCount = SUM(RecCount) 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType = 'i'
  SELECT @RecCount AS 'Total MedLine Search Records'
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineReportLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineReportLookup]
  @LogSet 	varchar(50)
AS
	DECLARE @RecCount 	int
  SET NOCOUNT ON
  SELECT * 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType	= 'x'
  SELECT @RecCount = SUM(RecCount) 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType = 'x'
  SELECT @RecCount AS 'Total MedLine Lookup Records'
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineLogWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[ap_LoadMedLineLogWork]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
return
	DECLARE @wAbstract 						int
	DECLARE @wAccession 					int
	DECLARE @wArticle 						int
	DECLARE @wAuthor 							int
	DECLARE @wChemical 						int
	DECLARE @wCitation 						int
	DECLARE @wCitationSubset 			int
	DECLARE @wComment							int
	DECLARE @wDataBank						int
	DECLARE @wDeleteCitation			int
	DECLARE @wGeneralNote					int
	DECLARE @wGrant								int
	DECLARE @wInvestigator				int
	DECLARE @wJournal							int
	DECLARE @wKeyword							int
	DECLARE @wKeywordList					int
	DECLARE @wLanguage						int
	DECLARE @wMedlineJournal			int
	DECLARE @wCitationMeSHHeading	int
	DECLARE @wCitationMeSHQualifier	int
	DECLARE @wOtherID 						int
	DECLARE @wPublicationType 		int
	DECLARE @wPersonalNameSubject int
	DECLARE @wSpaceFlightMission	int
	SELECT @wAbstract 						= COUNT(*) FROM wAbstract
	SELECT @wAccession 						= COUNT(*) FROM wAccession
	SELECT @wArticle 							= COUNT(*) FROM wArticle
	SELECT @wAuthor 							= COUNT(*) FROM wAuthor
	SELECT @wChemical 						= COUNT(*) FROM wChemical
	SELECT @wCitation 						= COUNT(*) FROM wCitation
	SELECT @wCitationSubset 			= COUNT(*) FROM wCitationSubset
	SELECT @wComment 							= COUNT(*) FROM wComment
	SELECT @wDataBank 						= COUNT(*) FROM wDataBank
	SELECT @wDeleteCitation 			= COUNT(*) FROM wDeleteCitation
	SELECT @wGeneralNote 					= COUNT(*) FROM wGeneralNote
	SELECT @wGrant 								= COUNT(*) FROM wGrant
	SELECT @wInvestigator 				= COUNT(*) FROM wInvestigator
	SELECT @wJournal 							= COUNT(*) FROM wJournal
	SELECT @wKeyword 							= COUNT(*) FROM wKeyword
	SELECT @wKeywordList 					= COUNT(*) FROM wKeywordList
	SELECT @wLanguage 						= COUNT(*) FROM wLanguage
	SELECT @wMedlineJournal 			= COUNT(*) FROM wMedlineJournal
	SELECT @wCitationMeSHHeading 	= COUNT(*) FROM wCitationMeSHHeading
	SELECT @wCitationMeSHQualifier= COUNT(*) FROM wCitationMeSHQualifier
	SELECT @wOtherID 							= COUNT(*) FROM wOtherID
	SELECT @wPersonalNameSubject	= COUNT(*) FROM wPersonalNameSubject
	SELECT @wPublicationType			= COUNT(*) FROM wPublicationType
	SELECT @wSpaceFlightMission		= COUNT(*) FROM wSpaceFlightMission
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wAbstract',@wAbstract)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wAccession',@wAccession)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wArticle',@wArticle)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wAuthor',@wAuthor)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wChemical',@wChemical)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wCitation',@wCitation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wCitationSubset',@wCitationSubset)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wComment',@wComment)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wDataBank',@wDataBank)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wDeleteCitation',@wDeleteCitation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wGeneralNote',@wGeneralNote)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wGrant',@wGrant)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wInvestigator',@wInvestigator)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wJournal',@wJournal)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wKeyword',@wKeyword)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wKeywordList',@wKeywordList)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wLanguage',@wLanguage)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMedlineJournal',@wMedlineJournal)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wCitationMeSHHeading',@wCitationMeSHHeading)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wCitationMeSHQualifier',@wCitationMeSHQualifier)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wOtherID',@wOtherID)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wPersonalNameSubject',@wPersonalNameSubject)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wPublicationType',@wPublicationType)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wSpaceFlightMission',@wSpaceFlightMission)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineLogSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[ap_LoadMedLineLogSearch]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
return
	DECLARE @iAbstract						int
	DECLARE @iAccession						int
	DECLARE @iArticle							int
	DECLARE @iAuthor							int
	DECLARE @iChemical						int
	DECLARE @iCitation						int
	DECLARE @iCitationSubset			int
	DECLARE @iComment							int
	DECLARE @iDataBank						int
	DECLARE @iDeleteCitation			int
	DECLARE @iGeneralNote					int
	DECLARE @iGrant								int
	DECLARE @iInvestigator				int
	DECLARE @iJournal							int
	DECLARE @iKeyword							int
	DECLARE @iKeywordList					int
	DECLARE @iLanguage						int
	DECLARE @iMedlineJournal			int
	DECLARE @iOtherID							int
	DECLARE @iPersonalNameSubject int
	DECLARE @iPublicationType			int
	DECLARE @iSpaceFlightMission	int
	SELECT @iAbstract 						= COUNT(*) FROM iAbstract
	SELECT @iAccession 						= COUNT(*) FROM iAccession
	SELECT @iArticle 							= COUNT(*) FROM iArticle
	SELECT @iAuthor 							= COUNT(*) FROM iAuthor
	SELECT @iChemical 						= COUNT(*) FROM iChemical
	SELECT @iCitation 						= COUNT(*) FROM iCitation
	SELECT @iCitationSubset 			= COUNT(*) FROM iCitationSubset
	SELECT @iComment 							= COUNT(*) FROM iComment
	SELECT @iDataBank 						= COUNT(*) FROM iDataBank
	SELECT @iDeleteCitation 			= COUNT(*) FROM iDeleteCitation
	SELECT @iGeneralNote 					= COUNT(*) FROM iGeneralNote
	SELECT @iGrant 								= COUNT(*) FROM iGrant
	SELECT @iInvestigator 				= COUNT(*) FROM iInvestigator
	SELECT @iJournal 							= COUNT(*) FROM iJournal
	SELECT @iKeyword 							= COUNT(*) FROM iKeyword
	SELECT @iKeywordList 					= COUNT(*) FROM iKeywordList
	SELECT @iLanguage 						= COUNT(*) FROM iLanguage
	SELECT @iMedlineJournal 			= COUNT(*) FROM iMedlineJournal
--		SELECT @iCitationMeSHHeading 					= COUNT(*) FROM iMeshHeading
--		SELECT @iCitationMeSHQualifier 				= COUNT(*) FROM iMeshQualifier
	SELECT @iOtherID 							= COUNT(*) FROM iOtherID
	SELECT @iPersonalNameSubject	= COUNT(*) FROM iPersonalNameSubject
	SELECT @iPublicationType			= COUNT(*) FROM iPublicationType
	SELECT @iSpaceFlightMission		= COUNT(*) FROM iSpaceFlightMission
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iAbstract',@iAbstract)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iAccession',@iAccession)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iArticle',@iArticle)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iAuthor',@iAuthor)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iChemical',@iChemical)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iCitation',@iCitation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iCitationSubset',@iCitationSubset)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iComment',@iComment)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iDataBank',@iDataBank)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iDeleteCitation',ISNULL(@iDeleteCitation,0))		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iGeneralNote',@iGeneralNote)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iGrant',@iGrant)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iInvestigator',@iInvestigator)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iJournal',@iJournal)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iKeyword',@iKeyword)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iKeywordList',@iKeywordList)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iLanguage',@iLanguage)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iMedlineJournal',@iMedlineJournal)		
--	  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iCitationMeSHHeading',ISNULL(@iCitationMeSHHeading,0))		
--	  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iCitationMeSHQualifier',ISNULL(@iCitationMeSHQualifier,0))		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iOtherID',@iOtherID)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iPersonalNameSubject',@iPersonalNameSubject)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iPublicationType',@iPublicationType)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'i','iSpaceFlightMission',@iSpaceFlightMission)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineLogLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[ap_LoadMedLineLogLookup]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
return
	DECLARE @xAffiliation					int
	DECLARE @xChemicalName				int
	DECLARE @xChemicalRegistry		int
	DECLARE @xCollectiveName			int
	DECLARE @xCommentType					int
	DECLARE @xCountry							int
	DECLARE @xDataBank						int
	DECLARE @xForeName						int
	DECLARE @xGrantAcronym				int
	DECLARE @xGrantAgency					int
	DECLARE @xGrantID							int
	DECLARE @xInitials						int
	DECLARE @xKeyword							int
	DECLARE @xLanguage						int
	DECLARE @xLastName						int
	DECLARE @xMedlineTA						int
	DECLARE @xPublicationType			int
	DECLARE @xSpaceFlightMission	int
	DECLARE @xSuffix							int
	SELECT @xAffiliation				= COUNT(*) FROM xAffiliation
	SELECT @xChemicalName				= COUNT(*) FROM xChemicalName
	SELECT @xChemicalRegistry		= COUNT(*) FROM xChemicalRegistry
	SELECT @xCollectiveName			= COUNT(*) FROM xCollectiveName
	SELECT @xCommentType				= COUNT(*) FROM xCommentType
	SELECT @xCountry						= COUNT(*) FROM xCountry
	SELECT @xDataBank						= COUNT(*) FROM xDataBank
	SELECT @xGrantAcronym				= COUNT(*) FROM xGrantAcronym
	SELECT @xGrantAgency				= COUNT(*) FROM xGrantAgency
	SELECT @xGrantID						= COUNT(*) FROM xGrantID
	SELECT @xInitials						= COUNT(*) FROM xInitials
	SELECT @xKeyword						= COUNT(*) FROM xKeyword
	SELECT @xLanguage						= COUNT(*) FROM xLanguage
	SELECT @xLastName						= COUNT(*) FROM xLastName
	SELECT @xMedlineTA					= COUNT(*) FROM xMedlineTA
	SELECT @xPublicationType		= COUNT(*) FROM xPublicationType
	SELECT @xSpaceFlightMission	= COUNT(*) FROM xSpaceFlightMission
	SELECT @xSuffix							= COUNT(*) FROM xSuffix
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Affiliation',@xAffiliation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','ChemicalName',@xChemicalName)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','ChemicalRegistry',@xChemicalRegistry)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','CollectiveName',@xCollectiveName)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','CommentType',@xCommentType)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Country',@xCountry)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','DataBank',@xDataBank)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','GrantAcronym',@xGrantAcronym)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','GrantAgency',@xGrantAgency)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','GrantID',@xGrantID)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Initials',@xInitials)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Keyword',@xKeyword)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Language',@xLanguage)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','LastName',@xLastName)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','MedlineTA',@xMedlineTA)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','PublicationType',@xPublicationType)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','SpaceFlightMission',@xSpaceFlightMission)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'x','Suffix',@xSuffix)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadReport]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadReport]
  @LogSet 	varchar(50),
  @RunType	char(1)
AS
	DECLARE @RecCount 		int
	DECLARE @RunTypeDesc	varchar(50)
  SET NOCOUNT ON
	SELECT @RunTypeDesc = RunTypeDesc
		FROM xRunType
		WHERE RunType = @RunType
  SELECT * 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType	= @RunType
		ORDER BY LogTime
  SELECT @RecCount = SUM(RecCount) 
		FROM LogTables 
		WHERE LogSet	= @LogSet AND 
					RunType = @RunType
  SELECT @RunTypeDesc AS 'RunType',
				 @RecCount 		AS 'RecCount'
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHTruncateWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHTruncateWork]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE wMeSHQualifier
	TRUNCATE TABLE wMeSHSupplemental
	
	TRUNCATE TABLE wMeSHDescriptor
	TRUNCATE TABLE wMeSHYear
	TRUNCATE TABLE wMeSHAllowableQualifier
	TRUNCATE TABLE wMeSHPreviousIndexing
	TRUNCATE TABLE wMeSHEntryCombination
	TRUNCATE TABLE wMeSHSeeRelated
	TRUNCATE TABLE wMeSHSemanticType
	TRUNCATE TABLE wMeSHTreeNumber
	TRUNCATE TABLE wMeSHRecordOriginators
	TRUNCATE TABLE wMeSHConcept
	TRUNCATE TABLE wMeSHPharmacologicalAction
	TRUNCATE TABLE wMeSHRelatedRegistryNumber
	TRUNCATE TABLE wMeSHConceptRelation
	TRUNCATE TABLE wMeSHTerm
	TRUNCATE TABLE wMeSHThesaurus
	TRUNCATE TABLE wMeSHTreeNodeAllowed
  TRUNCATE TABLE wMeSHHeadingMappedTo
  TRUNCATE TABLE wMeSHIndexingInformation
	TRUNCATE TABLE wMeSHSource
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHTruncateSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHTruncateSearch]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE iMeSHDescriptor
	TRUNCATE TABLE iMeSHConcept
	TRUNCATE TABLE iMeSHConceptRelation
	TRUNCATE TABLE iMeSHEntryCombination
	TRUNCATE TABLE iMeSHPharmacologicalAction
	TRUNCATE TABLE iMeSHPreviousIndexing
	TRUNCATE TABLE iMeSHRecordOriginators
	TRUNCATE TABLE iMeSHSeeRelated
	TRUNCATE TABLE iMeSHRelatedRegistry
	TRUNCATE TABLE iMeSHSemanticType
	TRUNCATE TABLE iMeSHTreeNumber
	TRUNCATE TABLE iMeSHTreeNodeAllowed
	TRUNCATE TABLE iMeSHYear
	TRUNCATE TABLE iMeSHTerm
	TRUNCATE TABLE iMeSHTermPermute
	TRUNCATE TABLE iMeSHThesaurus
	TRUNCATE TABLE iMeSHAllowableQualifier
	TRUNCATE TABLE iMeSHQualifier
	TRUNCATE TABLE iMeSHSupplemental
	TRUNCATE TABLE iMeSHHeadingMappedTo
	TRUNCATE TABLE iMeSHIndexingInformation
	TRUNCATE TABLE iMeSHSource
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHTruncateLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHTruncateLookup]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE xSemanticType
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHTreeImport]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHTreeImport]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE wMeSHTree
	BULK INSERT Cogent3..wMeSHTree FROM 'D:\ImportProcessing\mtrees2010.bin'
	WITH (
	   DATAFILETYPE = 'char',
	   FIELDTERMINATOR = ';',
	   ROWTERMINATOR = '\n'
	)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHReportWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHReportWork]
  @LogSet 	varchar(50)
AS
	DECLARE @RecCount 	int
  SET NOCOUNT ON
  SELECT * 
		FROM LogTables 
		WHERE LogSet = @LogSet AND 
					RunType = 'w'
  SELECT @RecCount = SUM(RecCount) 
		FROM LogTables 
		WHERE LogSet = @LogSet AND 
					RunType = 'w'
  SELECT @RecCount AS 'Total Work Records'
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHLogWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHLogWork]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
	DECLARE @wMeSHAllowableQualifier 		int
	DECLARE @wMeSHConcept 							int
	DECLARE @wMeSHConceptRelation 			int
	DECLARE @wMeSHDescriptor 						int
	DECLARE @wMeSHEntryCombination 			int
	DECLARE @wMeSHPharmacologicalAction int
	DECLARE @wMeSHPreviousIndexing 			int
	DECLARE @wMeSHRecordOriginators 		int
	DECLARE @wMeSHRelatedRegistryNumber	int
	DECLARE @wMeSHSeeRelated 						int
	DECLARE @wMeSHSemanticType 					int
	DECLARE @wMeSHTerm 									int
	DECLARE @wMeSHTreeNumber 						int
	DECLARE @wMeSHThesaurus 						int
	DECLARE @wMeSHYear							 		int
	DECLARE @wMeSHQualifier							int
	DECLARE @wMeSHTreeNodeAllowed				int
	DECLARE @wMeSHSupplemental					int
	DECLARE @wMeSHHeadingMappedTo				int
  DECLARE @wMeSHIndexingInformation		int
	DECLARE	@wMeSHSource								int
	SELECT @wMeSHAllowableQualifier 		= COUNT(*) FROM wMeSHAllowableQualifier
	SELECT @wMeSHConcept 								= COUNT(*) FROM wMeSHConcept
	SELECT @wMeSHConceptRelation 				= COUNT(*) FROM wMeSHConceptRelation
	SELECT @wMeSHDescriptor 						= COUNT(*) FROM wMeSHDescriptor
	SELECT @wMeSHEntryCombination 			= COUNT(*) FROM wMeSHEntryCombination
	SELECT @wMeSHPharmacologicalAction 	= COUNT(*) FROM wMeSHPharmacologicalAction
	SELECT @wMeSHPreviousIndexing 			= COUNT(*) FROM wMeSHPreviousIndexing
	SELECT @wMeSHRecordOriginators 			= COUNT(*) FROM wMeSHRecordOriginators
	SELECT @wMeSHRelatedRegistryNumber	= COUNT(*) FROM wMeSHRelatedRegistryNumber
	SELECT @wMeSHSeeRelated 						= COUNT(*) FROM wMeSHSeeRelated
	SELECT @wMeSHSemanticType 					= COUNT(*) FROM wMeSHSemanticType
	SELECT @wMeSHTerm 									= COUNT(*) FROM wMeSHTerm
	SELECT @wMeSHThesaurus 							= COUNT(*) FROM wMeSHThesaurus
	SELECT @wMeSHTreeNumber 						= COUNT(*) FROM wMeSHTreeNumber
	SELECT @wMeSHYear 									= COUNT(*) FROM wMeSHYear
	SELECT @wMeSHQualifier 							= COUNT(*) FROM wMeSHQualifier
	SELECT @wMeSHTreeNodeAllowed 				= COUNT(*) FROM wMeSHTreeNodeAllowed
	SELECT @wMeSHSupplemental						= COUNT(*) FROM wMeSHSupplemental
	SELECT @wMeSHHeadingMappedTo				= COUNT(*) FROM wMeSHHeadingMappedTo
	SELECT @wMeSHIndexingInformation		= COUNT(*) FROM wMeSHIndexingInformation
	SELECT @wMeSHSource									= COUNT(*) FROM wMeSHSource
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHAllowableQualifier',@wMeSHAllowableQualifier)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHConcept',@wMeSHConcept)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHConceptRelation',@wMeSHConceptRelation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHDescriptor',@wMeSHDescriptor)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHEntryCombination',@wMeSHEntryCombination)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHPharmacologicalAction',@wMeSHPharmacologicalAction)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHPreviousIndexing',@wMeSHPreviousIndexing)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHRecordOriginators',@wMeSHRecordOriginators)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHRelatedRegistryNumber',@wMeSHRelatedRegistryNumber)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHSeeRelated',@wMeSHSeeRelated)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHSemanticType',@wMeSHSemanticType)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHTerm',@wMeSHTerm)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHThesaurus',@wMeSHThesaurus)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHTreeNumber',@wMeSHTreeNumber)	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHYear',@wMeSHYear)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHQualifier',@wMeSHQualifier)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHTreeNodeAllowed',@wMeSHTreeNodeAllowed)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHSupplemental',@wMeSHSupplemental)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHHeadingMappedTo',@wMeSHHeadingMappedTo)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHIndexingInformation',@wMeSHIndexingInformation)		
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount) VALUES (@LogSet,'w','wMeSHSource',@wMeSHSource)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHBuildSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHBuildSearch]
  @LogSet 	varchar(50),
	@RunType	char(1)
AS
  SET NOCOUNT ON
	DECLARE @RecCount int
	DECLARE @RecCountPrior int

  DECLARE @DQSUIc	char(1)
  IF @RunType = 'l'	--supp
	  SET @DQSUIc = 'C'
  IF @RunType = 'k'  --qual
	  SET @DQSUIc = 'Q'
  IF @RunType = 'j'		--desc
	  SET @DQSUIc = 'D'
  DELETE FROM iMeSHQualifier WHERE QualifierUIc = @DQSUIc
  DELETE FROM iMeSHDescriptor WHERE DescriptorUIc = @DQSUIc
  DELETE FROM iMeSHConcept WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHConceptRelation WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHEntryCombination WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHRecordOriginators WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHTreeNumber WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHTreeNodeAllowed WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHPreviousIndexing WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHSeeRelated WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHAllowableQualifier WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHPharmacologicalAction WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHRelatedRegistry WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHSemanticType WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHTermPermute WHERE TermUIc IN (SELECT DISTINCT LEFT(TermUI,1) FROM wMeSHTerm WHERE IsPermutedTerm = 'Y')
  DELETE FROM iMeSHTerm WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHThesaurus WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHYear WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHSupplemental WHERE SupplementalUIc = @DQSUIc
  DELETE FROM iMeSHHeadingMappedTo WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHIndexingInformation WHERE DQSUIc = @DQSUIc
  DELETE FROM iMeSHSource WHERE DQSUIc = @DQSUIc

	IF @RunType = 'l'
	  BEGIN
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHSupplemental
			INSERT INTO iMeSHSupplemental (
				SupplementalUIc,
				SupplementalUIn,
				SupplementalName,
				DateCreated,
				DateRevised,
				Note,
				Frequency
			)
			SELECT 	
				LEFT(SupplementalRecordUI,1),
			  CAST(SUBSTRING(SupplementalRecordUI,2,8) AS int),
				SupplementalName,
				CASE WHEN DateCreatedMonth > 0		THEN CAST(DateCreatedMonth		as varchar(4)) + '/' + CAST(DateCreatedDay		as varchar(4)) + '/' + CAST(DateCreatedYear 	as varchar(4)) ELSE NULL END, 
				CASE WHEN DateRevisedMonth > 0 		THEN 	CAST(DateRevisedMonth		as varchar(4)) + '/' + CAST(DateRevisedDay		as varchar(4)) + '/' + CAST(DateRevisedYear		as varchar(4)) ELSE NULL END,
				Note,
				Frequency
			FROM wMeSHSupplemental w
			SET @RecCount = @@ROWCOUNT	
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHSupplemental',@RecCount,@RecCountPrior)		
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHHeadingMappedTo
			INSERT INTO iMeSHHeadingMappedTo (
				DQSUIc,
				DQSUIn,
				DescriptorUIc,
				DescriptorUIn,
				QualifierUIc,
				QualifierUIn
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				LEFT(DescriptorUI,1),
			  CAST(SUBSTRING(DescriptorUI,2,8) AS int),
				ISNULL(LEFT(QualifierUI,1),' '),
			  ISNULL(CAST(SUBSTRING(QualifierUI,2,8) AS int),0)
			FROM wMeSHHeadingMappedTo w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHHeadingMappedTo', @RecCount, @RecCountPrior)
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHIndexingInformation
			INSERT INTO iMeSHIndexingInformation (
				DQSUIc,
				DQSUIn,
				DescriptorUIc,
				DescriptorUIn,
				QualifierUIc,
				QualifierUIn
			)
			SELECT DISTINCT
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				LEFT(DescriptorUI,1),
			  CAST(SUBSTRING(DescriptorUI,2,8) AS int),
				ISNULL(LEFT(QualifierUI,1),' '),
			  ISNULL(CAST(SUBSTRING(QualifierUI,2,8) AS int),0)
			FROM wMeSHIndexingInformation w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHIndexingInformation', @RecCount, @RecCountPrior)
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHSource
			INSERT INTO iMeSHSource (
				DQSUIc,
				DQSUIn,
				Source
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				Source
			FROM wMeSHSource w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHSource', @RecCount, @RecCountPrior)
		END --@RunType = 'l' Supplemental
	IF @RunType = 'k'
	  BEGIN
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHQualifier
			INSERT INTO iMeSHQualifier (
				QualifierUIc,
				QualifierUIn,
				QualifierName,
				DateCreated,
				DateRevised,
				DateEstablished,
				Type,
				Annotation,
				HistoryNote,
				OnlineNote
			)
			SELECT 	
				LEFT(QualifierUI,1),
			  CAST(SUBSTRING(QualifierUI,2,8) AS int),
				QualifierName,
				CASE WHEN DateCreatedMonth > 0		THEN CAST(DateCreatedMonth		as varchar(4)) + '/' + CAST(DateCreatedDay		as varchar(4)) + '/' + CAST(DateCreatedYear 	as varchar(4)) ELSE NULL END, 
				CASE WHEN DateRevisedMonth > 0 		THEN 	CAST(DateRevisedMonth		as varchar(4)) + '/' + CAST(DateRevisedDay		as varchar(4)) + '/' + CAST(DateRevisedYear		as varchar(4)) ELSE NULL END,
				CASE WHEN DateEstablishedMonth > 0 		THEN 	CAST(DateEstablishedMonth		as varchar(4)) + '/' + CAST(DateEstablishedDay		as varchar(4)) + '/' + CAST(DateEstablishedYear		as varchar(4)) ELSE NULL END,
				Type,
				Annotation,
				HistoryNote,
				OnlineNote
			FROM wMeSHQualifier w
			SET @RecCount = @@ROWCOUNT	
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHQualifier',@RecCount,@RecCountPrior)		
		END  --@RunType = 'k' Qualifier
	IF @RunType = 'j'
	  BEGIN
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHDescriptor
			INSERT INTO iMeSHDescriptor (
				DescriptorUIc,
				DescriptorUIn,
				DescriptorName,
				DateCreated,
				DateCompleted,
				DateRevised,
				DateEstablished,
				Class,
				HistoryNote,
				OnlineNote,
				PublicMeSHNote,
				Annotation,
				ConsiderAlso,
				RunningHead
			)
			SELECT 	
				LEFT(DescriptorUI,1),
			  CAST(SUBSTRING(DescriptorUI,2,8) AS int),
				DescriptorName,
				CASE WHEN DateCreatedMonth > 0		THEN CAST(DateCreatedMonth		as varchar(4)) + '/' + CAST(DateCreatedDay		as varchar(4)) + '/' + CAST(DateCreatedYear 	as varchar(4)) ELSE NULL END, 
				CASE WHEN DateCompletedMonth > 0	THEN CAST(DateCompletedMonth	as varchar(4)) + '/' + CAST(DateCompletedDay	as varchar(4)) + '/' + CAST(DateCompletedYear as varchar(4)) ELSE NULL END,
				CASE WHEN DateRevisedMonth > 0 		THEN 	CAST(DateRevisedMonth		as varchar(4)) + '/' + CAST(DateRevisedDay		as varchar(4)) + '/' + CAST(DateRevisedYear		as varchar(4)) ELSE NULL END,
				CASE WHEN DateEstablishedMonth > 0 		THEN 	CAST(DateEstablishedMonth		as varchar(4)) + '/' + CAST(DateEstablishedDay		as varchar(4)) + '/' + CAST(DateEstablishedYear		as varchar(4)) ELSE NULL END,
				Class,
				HistoryNote,
				OnlineNote,
				PublicMeSHNote,
				Annotation,
				ConsiderAlso,
				RunningHead
			FROM wMeSHDescriptor w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHDescriptor', @RecCount, @RecCountPrior)		
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHEntryCombination
			INSERT INTO iMeSHEntryCombination (
				DQSUIc,
				DQSUIn,
				ECInQualifierUIc,
				ECInQualifierUIn,
				ECOutDescriptorUIc,
				ECOutDescriptorUIn
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				LEFT(ECInQualifierUI,1),
			  CAST(SUBSTRING(ECInQualifierUI,2,8) AS int),
				LEFT(ECOutDescriptorUI,1),
			  CAST(SUBSTRING(ECOutDescriptorUI,2,8) AS int)
			FROM wMeSHEntryCombination w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHEntryCombination', @RecCount, @RecCountPrior)
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHPreviousIndexing
			INSERT INTO iMeSHPreviousIndexing (
				DQSUIc,
				DQSUIn,
				PreviousIndexing
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				PreviousIndexing
			FROM wMeSHPreviousIndexing w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHPreviousIndexing',  @RecCount, @RecCountPrior)
		
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHSeeRelated
			INSERT INTO iMeSHSeeRelated (
				DQSUIc,
				DQSUIn,
				RelatedDQSUIc,
				RelatedDQSUIn
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				LEFT(RelatedDescriptorUI,1),
			  CAST(SUBSTRING(RelatedDescriptorUI,2,8) AS int)
			FROM wMeSHSeeRelated w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHSeeRelated',  @RecCount, @RecCountPrior)
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHAllowableQualifier
			INSERT INTO iMeSHAllowableQualifier	 (
				DQSUIc,
				DQSUIn,
				QualifierUIc,
				QualifierUIn,
			  Abbreviation
			)
			SELECT 	
				LEFT(DQSUI,1),
			  CAST(SUBSTRING(DQSUI,2,8) AS int),
				LEFT(QualifierUI,1),
			  CAST(SUBSTRING(QualifierUI,2,8) AS int),
				Abbreviation
			FROM wMeSHAllowableQualifier w
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iiMeSHAllowableQualifier',  @RecCount, @RecCountPrior)
		END   --@RunType = 'j' Descriptor
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHConcept
	INSERT INTO iMeSHConcept (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		ConceptName,
		PreferredConcept,
		ConceptUMLSUI,
		RegistryNumber,
		CASN1Name,
		ScopeNote
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		ConceptName,
		PreferredConcept,
		ConceptUMLSUI,
		RegistryNumber,
		CASN1Name,
		ScopeNote
	FROM wMeSHConcept w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHConcept', @RecCount, @RecCountPrior)		
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHConceptRelation
	INSERT INTO iMeSHConceptRelation (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		RelationName,
		Concept1UIc,
		Concept1UIn,
		Concept2UIc,
		Concept2UIn
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		RelationName,
		LEFT(Concept1UI,1),
	  CAST(SUBSTRING(Concept1UI,2,8) AS int),
		LEFT(Concept2UI,1),
	  CAST(SUBSTRING(Concept2UI,2,8) AS int)
	FROM wMeSHConceptRelation w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHConceptRelation',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHPharmacologicalAction
	INSERT INTO iMeSHPharmacologicalAction (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		PA_DQSUIc,
		PA_DQSUIn
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		LEFT(PharmacologicalActionDescriptorUI,1),
	  CAST(SUBSTRING(PharmacologicalActionDescriptorUI,2,8) AS int)
	FROM wMeSHPharmacologicalAction w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHPharmacologicalAction',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHRecordOriginators
	INSERT INTO iMeSHRecordOriginators (
		DQSUIc,
		DQSUIn,
		RecordOriginator,
		RecordMaintainer,
		RecordAuthorizer
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		RecordOriginator,
		RecordMaintainer,
		RecordAuthorizer
	FROM wMeSHRecordOriginators w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHRecordOriginators',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHRelatedRegistry
	INSERT INTO iMeSHRelatedRegistry (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		RelatedRegistryNumber
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		RelatedRegistryNumber
	FROM wMeSHRelatedRegistryNumber w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHRelatedRegistry',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHSemanticType
	INSERT INTO iMeSHSemanticType (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		SemanticTypeUIc,
		SemanticTypeUIn
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		LEFT(SemanticTypeUI,1),
	  CAST(SUBSTRING(SemanticTypeUI,2,8) AS int)
	FROM wMeSHSemanticType w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHSemanticType',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHTreeNumber
	INSERT INTO iMeSHTreeNumber (
		DQSUIc,
		DQSUIn,
		TreeNumber
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		TreeNumber
	FROM wMeSHTreeNumber w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHTreeNumber',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHTreeNodeAllowed
	INSERT INTO iMeSHTreeNodeAllowed (
		DQSUIc,
		DQSUIn,
		TreeNodeAllowed
	)
	SELECT 	DISTINCT
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		TreeNodeAllowed
	FROM wMeSHTreeNodeAllowed w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHTreeNodeAllowed',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHYear
	INSERT INTO iMeSHYear (
		DQSUIc,
		DQSUIn,
		Year
	)
	SELECT DISTINCT	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		Year
	FROM wMeSHYear w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHYear',  @RecCount, @RecCountPrior)
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHTerm
	INSERT INTO iMeSHTerm (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		TermUIc,
		TermUIn,
		TermName,
		TermDate,
		Abbreviation,
		SortVersion,
		EntryVersion,
		ConceptPreferredTerm,
		IsPermutedTerm,
		LexicalTag,
		PrintFlag,
		RecordPreferredTerm
	)
	SELECT 	DISTINCT
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		LEFT(TermUI,1),
	  CAST(SUBSTRING(TermUI,2,8) AS int),
	 	TermName,
		CASE WHEN fMonth > 0		THEN CAST(fMonth as varchar(4)) + '/' + CAST(fDay as varchar(4)) + '/' + CAST(fYear as varchar(4)) ELSE NULL END, 
		Abbreviation,
		SortVersion,
		EntryVersion,
		ConceptPreferredTerm,
		ISNULL(IsPermutedTerm,'N'),
		LexicalTag,
		PrintFlag,
		RecordPreferredTerm
	FROM wMeSHTerm w
	WHERE IsPermutedTerm = 'N' OR @RunType = 'l' OR @RunType = 'k'
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHTerm',  @RecCount, @RecCountPrior)
  IF @RunType <> 'k'
		BEGIN
			SELECT @RecCountPrior = COUNT(*) FROM iMeSHTermPermute
			INSERT INTO iMeSHTermPermute (
				TermUIc,
				TermUIn,
				TermName
			)
			SELECT 	DISTINCT
				LEFT(TermUI,1),
			  CAST(SUBSTRING(TermUI,2,8) AS int),
			 	TermName
			FROM wMeSHTerm w
			WHERE IsPermutedTerm = 'Y' 
			SET @RecCount = @@ROWCOUNT	
		
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
				VALUES (@LogSet,@RunType,'iMeSHTermPermute',  @RecCount, @RecCountPrior)
		END
	SELECT @RecCountPrior = COUNT(*) FROM iMeSHThesaurus
	INSERT INTO iMeSHThesaurus (
		DQSUIc,
		DQSUIn,
		ConceptUIc,
		ConceptUIn,
		TermUIc,
		TermUIn,
		ThesaurusID
	)
	SELECT 	
		LEFT(DQSUI,1),
	  CAST(SUBSTRING(DQSUI,2,8) AS int),
		LEFT(ConceptUI,1),
	  CAST(SUBSTRING(ConceptUI,2,8) AS int),
		LEFT(TermUI,1),
	  CAST(SUBSTRING(TermUI,2,8) AS int),
		ThesaurusID
	FROM wMeSHThesaurus w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,'iMeSHThesaurus',  @RecCount, @RecCountPrior)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMeSHBuildLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMeSHBuildLookup]
  @LogSet 	varchar(50)
AS
  SET NOCOUNT ON
	DECLARE @RecCount int
	DECLARE @RecCountPrior int
	SELECT @RecCountPrior = COUNT(*) FROM xSemanticType
	INSERT INTO xSemanticType (
		SemanticTypeUIc,	
		SemanticTypeUIn,	
		SemanticTypeName
	)
	SELECT DISTINCT 
		LEFT(SemanticTypeUI,1),
	  CAST(SUBSTRING(SemanticTypeUI,2,8) AS int),
		SemanticTypeName
	FROM wMeSHSemanticType
	WHERE CAST(SUBSTRING(SemanticTypeUI,2,8) AS int) NOT IN
	   (SELECT SemanticTypeUIn
			   FROM xSemanticType)
			SET @RecCount = @@ROWCOUNT	
		  INSERT INTO LogTables(LogSet,RunType,TableName,RecCount, RecCountPrior) 
				VALUES (@LogSet,'y','xSemanticType', @RecCount, @RecCountPrior)
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineTuneSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineTuneSearch]
AS
  SET NOCOUNT ON

exec sp_fulltext_table 'iWideNew', 'Update_index'

INSERT INTO iCitationMeSHHeading SELECT * FROM iCitationMeSHHeading2
CHECKPOINT 
-- Not used--
--INSERT INTO iCitationMeSHHeadingAside SELECT DISTINCT * FROM iCitationMeSHHeadingAside2
--CHECKPOINT 
--- End of Not used ---
INSERT INTO iAuthor SELECT * FROM iAuthor2
CHECKPOINT 
INSERT INTO iChemical SELECT * FROM iChemical2
CHECKPOINT 
INSERT INTO iCitationMeSHQualifier SELECT * FROM iCitationMeSHQualifier2
CHECKPOINT 

TRUNCATE TABLE iCitationMeSHHeading2
-- Not used--
--TRUNCATE TABLE iCitationMeSHHeadingAside2
--- End of Not used ---
TRUNCATE TABLE iAuthor2
TRUNCATE TABLE iChemical2
TRUNCATE TABLE iCitationMeSHQualifier2

dbcc dbreindex (iCitationMeSHHeading,'',90)
CHECKPOINT 

-- Not used--
--dbcc dbreindex (iCitationMeSHHeadingAside,'',90)
--CHECKPOINT 
--- End of Not used ---
dbcc dbreindex (iAuthor,'',90)
CHECKPOINT 
dbcc dbreindex (iChemical,'',90)
CHECKPOINT 
dbcc dbreindex (iCitationMeSHQualifier,'',90)
CHECKPOINT 
dbcc dbreindex (iCitationScreen,'',90)
CHECKPOINT 
dbcc dbreindex (igrant,'',90)
CHECKPOINT 
--dbcc dbreindex (iInvestigator,'',90)
--CHECKPOINT 
dbcc dbreindex (iKeyword,'',90)
CHECKPOINT 
--dbcc dbreindex (iPersonalNameSubject,'',90)
--CHECKPOINT 



SELECT PMID, IDENTITY(int,1,1) AS st
  INTO #st
  FROM(SELECT PMID, SUBSTRING(ArticleTitle,1,100) AS 'ArticleTitle' FROM iWide
				UNION
			 SELECT PMID, SUBSTRING(ArticleTitle,1,100) FROM iWideNew) a
  ORDER BY ArticleTitle
CHECKPOINT 

SELECT PMID, IDENTITY(int,1,1) AS sa
  INTO #sa
  FROM iCitation
  ORDER BY AuthorList, DateCreated DESC
CHECKPOINT 

SELECT PMID, IDENTITY(int,1,1) AS sj
  INTO #sj
  FROM iCitation
  ORDER BY MedlineTA, DateCreated DESC
CHECKPOINT 

UPDATE iCitationScreen
  SET sa = ISNULL(a.sa,99999999),
			st = ISNULL(t.st,99999999),
			sj = ISNULL(j.sj,99999999)
FROM iCitationScreen c
LEFT JOIN #sa a ON a.PMID = c.PMID
LEFT JOIN #st t ON t.PMID = c.PMID
LEFT JOIN #sj j ON j.PMID = c.PMID
CHECKPOINT 

DROP TABLE #sj
DROP TABLE #sa
DROP TABLE #st
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineTruncateWork]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ap_LoadMedLineTruncateWork]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE wAbstract
	TRUNCATE TABLE wAbstractText
	TRUNCATE TABLE wAccessionNumber
	TRUNCATE TABLE wAccessionNumberList
	TRUNCATE TABLE wArticle
	TRUNCATE TABLE wArticleDate
	TRUNCATE TABLE wAuthor
	TRUNCATE TABLE wAuthor2
	TRUNCATE TABLE wAuthorList
	TRUNCATE TABLE wChemical
	TRUNCATE TABLE wChemicalList
	TRUNCATE TABLE wMedlineCitation
	TRUNCATE TABLE wDateCreated
	TRUNCATE TABLE wDateCompleted
	TRUNCATE TABLE wDateRevised
	TRUNCATE TABLE wCitationSubset
	TRUNCATE TABLE wCommentList
	TRUNCATE TABLE wComment
	TRUNCATE TABLE wCommentCommentIn
	TRUNCATE TABLE wCommentCommentOn
	TRUNCATE TABLE wCommentErratumIn
	TRUNCATE TABLE wCommentErratumFor
	TRUNCATE TABLE wCommentRepublishedFrom
	TRUNCATE TABLE wCommentRepublishedIn
	TRUNCATE TABLE wCommentRetractionOf
	TRUNCATE TABLE wCommentRetractionIn
	TRUNCATE TABLE wCommentUpdateIn
	TRUNCATE TABLE wCommentUpdateOf
	TRUNCATE TABLE wCommentSummaryForPatientsIn
	TRUNCATE TABLE wCommentOriginalReportIn
	TRUNCATE TABLE wCommentReprintOf
	TRUNCATE TABLE wCommentReprintIn
	TRUNCATE TABLE wCommentsCorrections
	TRUNCATE TABLE wCommentsCorrectionsList
	TRUNCATE TABLE wDataBank
	TRUNCATE TABLE wDataBankList
	TRUNCATE TABLE wDeleteCitation
	TRUNCATE TABLE wGeneralNote
	TRUNCATE TABLE wGeneSymbol
	TRUNCATE TABLE wGrant
	TRUNCATE TABLE wGrantList
	TRUNCATE TABLE wInvestigator
	TRUNCATE TABLE wInvestigatorList
	TRUNCATE TABLE wISSN
	TRUNCATE TABLE wJournal
	TRUNCATE TABLE wJournalIssue
	TRUNCATE TABLE wMedlineJournalInfo
	TRUNCATE TABLE wKeyword
	TRUNCATE TABLE wKeywordList
	TRUNCATE TABLE wLanguage
	TRUNCATE TABLE wJournal
	TRUNCATE TABLE wMeshHeading
	TRUNCATE TABLE wMeshHeadingList
	TRUNCATE TABLE wQualifierName
	TRUNCATE TABLE wOtherID
	TRUNCATE TABLE wPagination
	TRUNCATE TABLE wPublicationType
	TRUNCATE TABLE wPublicationTypeList
	TRUNCATE TABLE wPubDate
	TRUNCATE TABLE wPersonalNameSubject
	TRUNCATE TABLE wPersonalNameSubjectList
	TRUNCATE TABLE wSpaceFlightMission
	TRUNCATE TABLE wCitationMeSHHeadingX
	TRUNCATE TABLE wPMID
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineTruncateSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[ap_LoadMedLineTruncateSearch]
AS
  SET NOCOUNT ON
--		TRUNCATE TABLE iAbstract
		TRUNCATE TABLE iAccession
		TRUNCATE TABLE iArticle
		TRUNCATE TABLE iArticleDate
		TRUNCATE TABLE iAuthor
		TRUNCATE TABLE iAuthor2
		TRUNCATE TABLE iChemical
		TRUNCATE TABLE iChemical2
		TRUNCATE TABLE iCitation
		TRUNCATE TABLE iCitationMeSHHeading
		TRUNCATE TABLE iCitationMeSHHeading2
		TRUNCATE TABLE iCitationMeSHHeadingAside
		TRUNCATE TABLE iCitationMeSHHeadingAside2
		TRUNCATE TABLE iCitationMeSHQualifier
		TRUNCATE TABLE iCitationMeSHQualifier2
		TRUNCATE TABLE iCitationMeSHHeadingAside
		TRUNCATE TABLE iCitationSubset
		TRUNCATE TABLE iCitationScreen
		TRUNCATE TABLE iComment
		TRUNCATE TABLE iDataBank
		TRUNCATE TABLE iGrant
		TRUNCATE TABLE iGeneralNote
		TRUNCATE TABLE iInvestigator
		TRUNCATE TABLE iKeyword
		TRUNCATE TABLE iKeywordList
		TRUNCATE TABLE iLanguage
		TRUNCATE TABLE iPersonalNameSubject
		TRUNCATE TABLE iPublicationType
		TRUNCATE TABLE iSpaceFlightMission
		TRUNCATE TABLE iOtherID
		TRUNCATE TABLE iWide
		TRUNCATE TABLE iWideNew
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineTruncateLookup]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineTruncateLookup]
AS
  SET NOCOUNT ON
	TRUNCATE TABLE xAffiliation
	TRUNCATE TABLE xChemicalName
	TRUNCATE TABLE xChemicalRegistry
	TRUNCATE TABLE xCollectiveName
	TRUNCATE TABLE xCommentType
	TRUNCATE TABLE xCountry
	TRUNCATE TABLE xDataBank
	TRUNCATE TABLE xForeName
	TRUNCATE TABLE xGrantAcronym
	TRUNCATE TABLE xGrantAgency
	TRUNCATE TABLE xGrantID
	TRUNCATE TABLE xInitials
	TRUNCATE TABLE xKeyword
	TRUNCATE TABLE xLastName
	TRUNCATE TABLE xMedlineTA
	TRUNCATE TABLE xPublicationType
	TRUNCATE TABLE xSpaceFlightMission
	TRUNCATE TABLE xSuffix
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildTokens]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildTokens]
	@SearchA 		varchar(100),
	@SearchB 		varchar(100),
	@SSet				int,
	@TestOrder	int,
	@Tab				varchar(35)		OUTPUT,
	@Field			varchar(35)		OUTPUT,
	@Status 		int 					OUTPUT,
	@FindA			int 					OUTPUT,
	@FindB			int 					OUTPUT,
	@ErrorDesc	varchar(200)	OUTPUT,
	@Extra			varchar(100)	OUTPUT
	
AS
  DECLARE @RecCount			int
  SET NOCOUNT ON
	SET @Status		= -1
	SET @FindA		= 0
	SET @FindB		= 0
	IF @Tab = 'PMID' OR (@Tab = 'All Fields' AND (ISNUMERIC(@SearchA) = 1))
	  BEGIN
			IF ISNUMERIC(@SearchA)= 0
				BEGIN
					SET @ErrorDesc = '"' + @SearchA + '" is not a number.'
					RETURN
				END
			SET @FindA = CAST(@SearchA AS int)
			SET @Status = 2
			SET @Tab = 'PMID'
			RETURN
		END
	IF @Tab = 'MeSH Term' OR @Tab = 'Title/Abstract/MeSH Term' OR @Tab = 'All Fields'
	  BEGIN
			SELECT @FindA = DQSUIn
				FROM iMeSHTerm with (nolock)
				WHERE TermName = @SearchA	AND
							DQSUIc = 'D'
			SET @FindA = ISNULL(@FindA ,0)
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SELECT @Extra = DescriptorName
						FROM iMeSHDescriptor with (nolock)
						WHERE DescriptorUIn = @FindA
				END
			SELECT @FindB = DQSUIn
				FROM iMeSHTerm
				WHERE TermName = @SearchA	AND
							DQSUIc = 'Q'
			SET @FindB = ISNULL(@FindB ,0)
			IF @FindB > 0 AND @FindA = 0
				BEGIN
				  SET @Status = 2
					SELECT @Extra = QualifierName
						FROM iMeSHQualifier
						WHERE QualifierUIn = @FindB
				END
			IF @FindB > 0 OR @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'MeSHTerm'
					IF @Tab = 'All Fields'
						SET @Tab = 'Title/Abstract/MeSH Term'
					RETURN
				END
		END
	IF @Tab = 'Author' OR @Tab = 'All Fields'
	  BEGIN
DECLARE @Initials varchar(2)
DECLARE @LastName varchar(500)
DECLARE @ReversedName varchar(500)
DECLARE @intPos	int
			SET @ReversedName = REVERSE(@SearchA)
			SET @intPos = CHARINDEX(' ',@ReversedName)
			IF @IntPos = 0 OR @IntPos > 3
				BEGIN	
					SET @Initials = ''
					SET @LastName = @SearchA
				END
			IF @IntPos > 0
				BEGIN	
					SET @Initials = REVERSE(LEFT(@ReversedName,@IntPos-1))
					SET @ReversedName = SUBSTRING(@ReversedName,@IntPos+1,500)
					SET @LastName = REVERSE(@ReversedName)
				END
/*
print @SearchA
print @ReversedName
print cast(@intPos as varchar(2))
print @LastName
print @Initials
*/
			SELECT @FindA = LastNameID
				FROM xLastName
				WHERE LastName = @LastName	
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Tab = 'Author'
					SET @Field = 'LastName'
				  IF @Initials <> ''
					  BEGIN
							SET @FindB = 1
							SET @Extra = @Initials
							SET @Field = 'LastNameInitials'
						END
					RETURN
				END
-- Check for CollectiveName
			SELECT @FindA = CollectiveNameID
				FROM xCollectiveName with (nolock)
				WHERE CollectiveName = @SearchA	
		  IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'CollectiveName'
					SET @Tab = 'Author'
					RETURN
				END
		END --@Tab = 'iAuthor'
	IF @Tab = 'Journal' OR @Tab = 'All Fields'
	  BEGIN
			SELECT @FindA = ISSNID
				FROM xISSN with (nolock)
				WHERE ISSN = @SearchA	
			IF @FindA > 0
				BEGIN
				  SET @Status = 2
					SET @Field = 'ISSN'
					SELECT @Tab = 'Journal'
					RETURN
				END
		  ELSE
				BEGIN
					SELECT @FindA = MedLineTAID
						FROM xMedLineTA with (nolock)
						WHERE MedLineTA = @SearchA	
					IF @FindA > 0
						BEGIN
						  SET @Status = 2
							SET @Field = 'MedLineTA'
							SELECT @Tab = 'Journal'
							RETURN
						END
				END
		END --@Tab = 'iJournal'
	IF @Tab = 'Substance Name' OR @Tab = 'All Fields'
	  BEGIN
			SELECT @FindA = DQSUIn
				FROM iMeSHTerm with (nolock)
				WHERE TermName = @SearchA	AND
							DQSUIc = 'D'
			SET @FindA = ISNULL(@FindA ,0)
			IF @FindA > 0
				BEGIN
					SET @Tab = 'MeSH Term'
				  SET @Status = 2
					SET @Field = 'MeSHTerm'
					SELECT @Extra = DescriptorName
						FROM iMeSHDescriptor with (nolock)
						WHERE DescriptorUIn = @FindA
					RETURN
				END
			SELECT @FindA = ChemicalNameID
				FROM xChemicalName with (nolock)
				WHERE ChemicalName = @SearchA
			SET @FindA = ISNULL(@FindA ,0)
			IF @FindA > 0
				BEGIN
					SET @Tab = 'Chemical'
				  SET @Status = 2
					SET @Field = 'ChemicalNameID'
					RETURN
				END
		END
	IF @Tab = 'Title'
	  BEGIN
		  SET @Status = 2
			RETURN
		END
-- catch-all: leave this as the last test
	IF @Tab = 'Title/Abstract'
	  BEGIN
		  SET @Status = 2
			SET @Tab = 'Title/Abstract'
			RETURN
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildFullQueryC]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildFullQueryC]
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
	@UpdateSourceFrom		smallint,				-- only for autosearch.
	@UpdateSourceTo			smallint,				-- only for autosearch.
	@QueryFinal			varchar(8000)		OUTPUT,		--Full query
	@RunQuery				int							OUTPUT,		--0: don't run query; 1: run query
	@ErrorDesc			varchar(200)		OUTPUT,		--Show user why search terms are no good
	@QueryDetails	  varchar(4000)		OUTPUT		--English description of query
AS
SET NOCOUNT ON
-- Locals ----------------------------------------------------------

	DECLARE @PublicationTypeMask	smallint		--From CogentSearch..SearchSummary
	DECLARE @LanguageMask		tinyint						--From CogentSearch..SearchSummary
	DECLARE @SpeciesMask		tinyint						--From CogentSearch..SearchSummary
	DECLARE @GenderMask			tinyint						--From CogentSearch..SearchSummary
	DECLARE @SubjectAgeMask	smallint					--From CogentSearch..SearchSummary
	DECLARE @AbstractMask		smallint					--From CogentSearch..SearchSummary
	DECLARE @DateStart			smalldatetime			--From CogentSearch..SearchSummary
	DECLARE @DateEnd				smalldatetime			--From CogentSearch..SearchSummary
  DECLARE @PaperAge				tinyint						--From CogentSearch..SearchSummary
  DECLARE @SearchSort			tinyint						--From CogentSearch..SearchSummary
  DECLARE @FastFullText		tinyint						--From CogentSearch..SearchSummary
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
		SET @UserDB = 'UserDB'

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
		FROM AJA..SearchSummary
		WHERE SearchID	= @SearchID
  --print @DateStart 
  -- print @DateEnd 
-- Quick error exit - Only a NOT line ---------------------------------------
  SELECT @RecCount = SUM(CASE WHEN Op = 'Not' THEN 1 ELSE 10 END)
		FROM AJA..SearchDetails
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
		---- For testing by Mad ---
			IF @PaperAge = 0
				SET @PaperAge = 3
			-- End --
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
print 'ap_SearchBuildFullQueryC:  @DateStart: ' + isnull(cast(@DateStart as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @DateEnd: ' + isnull(cast(@DateEnd as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @PaperAge: ' + isnull(cast(@PaperAge as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @FullOld: ' + isnull(cast(@FullOld as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @FullNew: ' + isnull(cast(@FullNew as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @FullOldLimit: ' + isnull(cast(@FullOldLimit as varchar(40)),'')
print 'ap_SearchBuildFullQueryC:  @QueryDetailsB: ' + isnull(@QueryDetailsB,'')


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
		FROM AJA..SearchDetails
		WHERE SearchID	= @SearchID
		ORDER BY Seq
	
	OPEN curA
	
	FETCH NEXT FROM curA INTO @Seq, @Op, @Terms, @Tab
	WHILE @@FETCH_STATUS = 0
		BEGIN

		-- Find quoted phrases first
		-- Transact-SQL is not designed for sophisticated string handling, but it can be done!
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

--  DELETE FROM #s WHERE @TermA IS NULL

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
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: ------------------------------'
print 'ap_SearchBuildFullQueryC: @TestOrder: ' + isnull(cast(@TestOrder as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @Tab: ' + isnull(cast(@Tab as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @TestOrder: ' + isnull(cast(@TestOrder as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @TermA: ' + isnull(cast(@TermA as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @Field: ' + isnull(cast(@Field as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @Status: ' + isnull(cast(@Status as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildTokens: @FindA: ' + isnull(cast(@FindA as varchar(40)),'')
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

		  EXEC ap_SearchBuildEachQuery	@Op,
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
/*
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @Op: ' + isnull(cast(@Op as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @Tab: ' + isnull(cast(@Tab as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @Field: ' + isnull(cast(@Field as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @TermA: ' + isnull(cast(@TermA as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @FindA: ' + isnull(cast(@FindA as varchar(40)),'')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @QueryOne: ' + isnull(@QueryOne,'null')
print 'ap_SearchBuildFullQueryC: ap_SearchBuildEachQuery: @QueryDetailsW: ' + isnull(@QueryDetailsW,'null')
*/


			IF @Op = 'Any'
				INSERT INTO #q(iOP, SQL, Details, SSet) VALUES (1, @QueryOne, @QueryDetailsW, @SSet)

			IF @Op = 'All'
				INSERT INTO #q(iOP, SQL, Details, SSet) VALUES (2, @QueryOne, @QueryDetailsW, @SSet)

			IF @Op = 'Not'
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
   --print @DateStart 
   --print @DateEnd 
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

	--IF @SearchMode = 1	--	SET @QueryWhere = @QueryWhere + ' AND du=' + 	CAST(DATEDIFF(d,'1960-01-01',@ThisAutorunDate) AS varchar(10))

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
		  IF @SQL <>'' and @SQL is not null
		    Begin
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
		  END
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
'	FROM #base b' + @cr +'	JOIN iCitationScreen c ON c.PMID=b.PMID ' + @cr +'	JOIN iCitation ic ON ic.PMID=b.PMID ' + @cr +CASE WHEN LEN(@QueryWhere) > 0 THEN
  @QueryWhere  + @cr + ' AND ic.UpdateSource >= ' + CAST(@UpdateSourceFrom as varchar(10)) + ' AND ic.UpdateSource <= ' + CAST(@UpdateSourceTo AS varchar(10))
ELSE
  ' WHERE ic.UpdateSource >= ' + CAST(@UpdateSourceFrom as varchar(10)) + ' AND ic.UpdateSource <= ' + CAST(@UpdateSourceTo AS varchar(10))
END +
 --'where ic.UpdateSource >= ' + CAST(@UpdateSourceFrom as varchar(10)) + ' AND ic.UpdateSource <= ' + CAST(@UpdateSourceTo AS varchar(10))+

CASE @SearchSort
	WHEN 1 THEN '	ORDER BY dps DESC' + @cr
	WHEN 2 THEN '	ORDER BY sa' + @cr
	WHEN 3 THEN '	ORDER BY st' + @cr
	WHEN 4 THEN '	ORDER BY sj' + @cr
	ELSE ''
END +
@cr +
CASE WHEN @SearchMode = 0 THEN'UPDATE AJA..SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr +'SELECT * INTO #pre3 FROM #pre2 WHERE LIST BETWEEN 1 AND 1000' + @cr +'DELETE FROM AJA..SearchResults WHERE SearchID =' + CAST(@SearchID as varchar(20)) + @cr +'INSERT INTO AJA..SearchResults (SearchID, PMID, List) SELECT ' + CAST(@SearchID as varchar(20)) + ', PMID, List FROM #pre3' + @cr
ELSE
'SELECT p.PMID,' + CAST(@ResultsFolder1 as varchar(10)) + ' AS ''f1'',' +  + CAST(@ResultsFolder2 as varchar(10)) + ' AS ''f2'', CAST(''' + @tad + ''' AS smalldatetime) AS ''c'', 1 AS ''s'',DATEADD(d,' + CAST(@ShelfLife AS varchar(10)) + ',''' + @tad + ''') AS ''e'',' + CAST(@KeepDelete AS varchar(2)) + ' AS ''k'' INTO #pre3 FROM #pre2 p ' + @cr +
--'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + ' ' + @cr +
--'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + @cr +
--'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f1,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr +
  CASE WHEN @ResultsFolder2 <> 0 THEN
		'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + ' ' + @cr +
		'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + ' AND UserID = ' + CAST(@UserID AS varchar(10)) + @cr +
		'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f2,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr + 
	  'UPDATE AJA..SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr	ELSE
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
print @QueryFinal
/*
-- *****************************************************************
select Seq, Op, Terms, Tab FROM CogentSearch..SearchDetails WHERE SearchID	= @SearchID ORDER by Seq
select * from #s order by sset, TestOrder
SELECT * FROM #q
print @QueryDetails
-- *****************************************************************
*/

	DROP TABLE #q
	DROP TABLE #s
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildFullQuery_AJA]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildFullQuery_AJA]
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
	DECLARE @Terms					nvarchar(max)			--Search words entered by user in each terms set
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
		SET @UserDB = 'AJA'

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
		FROM AJA.dbo.SearchSummary with (nolock)
		WHERE SearchID	= @SearchID

-- Quick error exit - Only a NOT line ---------------------------------------
  SELECT @RecCount = SUM(CASE WHEN Op = 'Not' THEN 1 ELSE 10 END)
		FROM AJA.dbo.SearchDetails with (nolock)
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
		TermA				varchar(max)	NULL,									-- term to find in xRef
		TermB				varchar(max)	NULL,									-- some terms to find might have two parts
		QueryOne		varchar(max)	NULL,									-- Query to find key in i* table,
		Extra				varchar(max)	NULL
	) 

-- Populate #s Search table  from #p ---------------------------------------
	DECLARE curA CURSOR FOR
		SELECT	Seq,
						Op,
						Terms,
						Tab
		FROM AJA.dbo.SearchDetails with (nolock)
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
			FROM #s with (nolock)
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
'	FROM #base b with (nolock)' + @cr +'	INNER LOOP JOIN iCitationScreen c with (nolock) ON c.PMID=b.PMID ' + @cr +CASE WHEN LEN(@QueryWhere) > 0 THEN
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
CASE WHEN @SearchMode = 0 THEN'UPDATE AJA.dbo.SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr +'SELECT * INTO #pre3 FROM #pre2 with (nolock) WHERE LIST BETWEEN 1 AND 1000' + @cr +'DELETE FROM AJA.dbo.SearchResults WHERE SearchID =' + CAST(@SearchID as varchar(20)) + @cr +'INSERT INTO AJA.dbo.SearchResults (SearchID, PMID, List) SELECT ' + CAST(@SearchID as varchar(20)) + ', PMID, List FROM #pre3' + @cr
ELSE
'SELECT p.PMID,' + CAST(@ResultsFolder1 as varchar(10)) + ' AS ''f1'',' +  + CAST(@ResultsFolder2 as varchar(10)) + ' AS ''f2'', CAST(''' + @tad + ''' AS smalldatetime) AS ''c'', 1 AS ''s'',DATEADD(d,' + CAST(@ShelfLife AS varchar(10)) + ',''' + @tad + ''') AS ''e'',' + CAST(@KeepDelete AS varchar(2)) + ' AS ''k'' INTO #pre3 FROM #pre2 p ' + @cr +
--'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + ' ' + @cr +
--'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + @cr +
--'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f1,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr +
  CASE WHEN @ResultsFolder2 <> 0 THEN
		'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + ' ' + @cr +
		'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + @cr +
		'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f2,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr + 
	  'UPDATE AJA.dbo.SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr	ELSE
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
select Seq, Op, Terms, Tab FROM AJA.dbo.SearchDetails WHERE SearchID	= @SearchID ORDER by Seq
select * from #s order by sset, TestOrder
SELECT * FROM #q
print @QueryDetails
-- *****************************************************************
*/

	DROP TABLE #q
	DROP TABLE #s


--print @QueryFinal
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchBuildFullQuery]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchBuildFullQuery]
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

	DECLARE @PublicationTypeMask	smallint		--From CogentSearch..SearchSummary
	DECLARE @LanguageMask		tinyint						--From CogentSearch..SearchSummary
	DECLARE @SpeciesMask		tinyint						--From CogentSearch..SearchSummary
	DECLARE @GenderMask			tinyint						--From CogentSearch..SearchSummary
	DECLARE @SubjectAgeMask	smallint					--From CogentSearch..SearchSummary
	DECLARE @AbstractMask		smallint					--From CogentSearch..SearchSummary
	DECLARE @DateStart			smalldatetime			--From CogentSearch..SearchSummary
	DECLARE @DateEnd				smalldatetime			--From CogentSearch..SearchSummary
  DECLARE @PaperAge				tinyint						--From CogentSearch..SearchSummary
  DECLARE @SearchSort			tinyint						--From CogentSearch..SearchSummary
  DECLARE @FastFullText		tinyint						--From CogentSearch..SearchSummary
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
		SET @UserDB = 'UserDB'

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
		FROM AJA..SearchSummary
		WHERE SearchID	= @SearchID

-- Quick error exit - Only a NOT line ---------------------------------------
  SELECT @RecCount = SUM(CASE WHEN Op = 'Not' THEN 1 ELSE 10 END)
		FROM AJA..SearchDetails
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
		FROM AJA..SearchDetails
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

		  EXEC ap_SearchBuildEachQuery	@Op,
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
CASE WHEN @SearchMode = 0 THEN'UPDATE AJA..SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr +'SELECT * INTO #pre3 FROM #pre2 WHERE LIST BETWEEN 1 AND 1000' + @cr +'DELETE FROM AJA..SearchResults WHERE SearchID =' + CAST(@SearchID as varchar(20)) + @cr +'INSERT INTO AJA..SearchResults (SearchID, PMID, List) SELECT ' + CAST(@SearchID as varchar(20)) + ', PMID, List FROM #pre3' + @cr
ELSE
'SELECT p.PMID,' + CAST(@ResultsFolder1 as varchar(10)) + ' AS ''f1'',' +  + CAST(@ResultsFolder2 as varchar(10)) + ' AS ''f2'', CAST(''' + @tad + ''' AS smalldatetime) AS ''c'', 1 AS ''s'',DATEADD(d,' + CAST(@ShelfLife AS varchar(10)) + ',''' + @tad + ''') AS ''e'',' + CAST(@KeepDelete AS varchar(2)) + ' AS ''k'' INTO #pre3 FROM #pre2 p ' + @cr +
--'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + ' ' + @cr +
--'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder1 as varchar(10)) + @cr +
--'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f1,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr +
  CASE WHEN @ResultsFolder2 <> 0 THEN
		'DELETE p FROM #pre3 p INNER JOIN ' + @UserDB + '..UserCitations u ON u.PMID = p.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + ' ' + @cr +
		'DELETE u FROM ' + @UserDB + '..UserCitations u INNER JOIN #pre3 p ON p.PMID = u.PMID WHERE u.subtopicid=' + CAST(@ResultsFolder2 as varchar(10)) + @cr +
		'INSERT INTO ' + @UserDB + '..UserCitations (pmid,subtopicid,IsAutoQueryCitation,expiredate,SearchID,KeepDelete,userID) SELECT PMID,f2,s,e,' + CAST(@SearchID AS varchar(10)) + ',k,' + CAST(@UserID AS varchar(10)) + ' from #pre3' + @cr + 
	  'UPDATE AJA..SearchSummary SET FoundLast = @@ROWCOUNT, RunLast = GETDATE() WHERE SearchID=' + CAST(@SearchID as varchar(20)) + @cr	ELSE
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
select Seq, Op, Terms, Tab FROM CogentSearch..SearchDetails WHERE SearchID	= @SearchID ORDER by Seq
select * from #s order by sset, TestOrder
SELECT * FROM #q
print @QueryDetails
-- *****************************************************************
*/

	DROP TABLE #q
	DROP TABLE #s


--print @QueryFinal
GO
/****** Object:  StoredProcedure [dbo].[ap_LoadMedLineBuildSearch]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_LoadMedLineBuildSearch]
  @LogSet 			varchar(50),
	@UpdateSource	int,
	@UpdateDate		smalldatetime
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
	  SELECT w.PMID
		  FROM wMedlineCitation w
--		  JOIN iArticle i ON i.PMID = w.PMID
	SET @RecCount = @@ROWCOUNT	
  SET @DeleteCount = @RecCount
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Duplicate PMID ',0,@RecCount)		
  INSERT INTO #e
	  SELECT PMID
		  FROM wDeleteCitation
	SET @RecCount = @@ROWCOUNT	
  SET @DeleteCount = @DeleteCount + @RecCount

  IF @DeleteCount > 0
		BEGIN
			DELETE iAccession FROM iAccession i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAccession',0,@RecCount)
		
			DELETE iArticle FROM iArticle i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticle',0,@RecCount)
		
		
			DELETE iArticleDate FROM iArticleDate i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iArticleDate',0,@RecCount)
		
		
			DELETE iWide FROM iWide i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWide',0,@RecCount)
		
		
			DELETE iWideNew FROM iWideNew i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iWideNew',0,@RecCount)
		
			DELETE iAuthor FROM iAuthor i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iAuthor',0,@RecCount)
		
			--DELETE iAuthor2 FROM iAuthor2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iChemical FROM iChemical i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iChemical',0,@RecCount)
		
			--DELETE iChemical2 FROM iChemical2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitation FROM iCitation i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitation',0,@RecCount)
		
			DELETE iCitationMeSHHeading FROM iCitationMeSHHeading i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHHeading',0,@RecCount)
		
			--DELETE iCitationMeSHHeading2 FROM iCitationMeSHHeading2 i INNER JOIN #e e ON e.PMID = i.PMID
			--DELETE iCitationMeSHHeadingAside FROM iCitationMeSHHeadingAside i INNER JOIN #e e ON e.PMID = i.PMID		
		
		
			--DELETE iCitationMeSHHeadingAside2 FROM iCitationMeSHHeadingAside2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitationMeSHQualifier FROM iCitationMeSHQualifier i INNER JOIN #e e ON e.PMID = i.PMID
			
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationMeSHQualifier',0,@RecCount)
		
		--	DELETE iCitationMeSHQualifier2 FROM iCitationMeSHQualifier2 i INNER JOIN #e e ON e.PMID = i.PMID
			DELETE iCitationSubset FROM iCitationSubset i INNER JOIN #e e ON e.PMID = i.PMID
			
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationSubset',0,@RecCount)
			
			DELETE iCitationScreen FROM iCitationScreen i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iCitationScreen',0,@RecCount)
		
			DELETE iComment FROM iComment i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iComment',0,@RecCount)
		
			DELETE iDataBank FROM iDataBank i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iDataBank',0,@RecCount)
			DELETE iGrant FROM iGrant i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iGrant',0,@RecCount)
			--DELETE iGeneralNote FROM iGeneralNote i INNER JOIN #e e ON e.PMID = i.PMID			
			--DELETE iInvestigator FROM iInvestigator i INNER JOIN #e e ON e.PMID = i.PMID
		
			DELETE iKeyword FROM iKeyword i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeyword',0,@RecCount)
			DELETE iKeywordList FROM iKeywordList i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iKeywordList',0,@RecCount)
			DELETE iLanguage FROM iLanguage i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iLanguage',0,@RecCount)
			--DELETE iPersonalNameSubject FROM iPersonalNameSubject i INNER JOIN #e e ON e.PMID = i.PMID
			
			DELETE iPublicationType FROM iPublicationType i INNER JOIN #e e ON e.PMID = i.PMID
			INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iPublicationType',0,@RecCount)
			--DELETE iSpaceFlightMission FROM iSpaceFlightMission i INNER JOIN #e e ON e.PMID = i.PMID
			
		
			DELETE iOtherID FROM iOtherID i INNER JOIN #e e ON e.PMID = i.PMID
			 INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation iOtherID ',0,@RecCount)	
		END
	DROP TABLE #e
	  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'Delete Citation Compeleted ',0,@RecCount)		
--**************************************************************************
-- Post-process work tables
--**************************************************************************
--INSERT INTO wComment
	--SELECT * FROM wCommentCommentIn UNION
	--SELECT * FROM wCommentCommentOn UNION
	--SELECT * FROM wCommentErratumIn UNION
	---SELECT * FROM wCommentErratumFor UNION
	--SELECT * FROM wCommentRepublishedFrom UNION
	--SELECT * FROM wCommentRepublishedIn UNION
	--SELECT * FROM wCommentRetractionOf UNION
	---SELECT * FROM wCommentRetractionIn UNION
	--SELECT * FROM wCommentUpdateIn UNION
	--SELECT * FROM wCommentUpdateOf UNION
	--SELECT * FROM wCommentSummaryForPatientsIn UNION
	--SELECT * FROM wCommentOriginalReportIn UNION
	--SELECT * FROM wCommentReprintOf UNION
	--SELECT * FROM wCommentReprintIn  
	


UPDATE c
	SET Seq = LoadSeq - MinSeq
	FROM wAuthor c
	JOIN (SELECT PMID, MIN(LoadSeq) MinSeq FROM wAuthor GROUP BY PMID) a ON a.PMID = c.PMID
	
	--print 'wAuthor'
	dbcc checkident (wAuthor, reseed, 1)
--------------------------Not used-----------------------------------

--ALTER TABLE wJournal ADD CONSTRAINT wJournalPK PRIMARY KEY (PMID)
--DECLARE @command varchar(200)
--SET @command = 'd:\ImportProcessing\DateFix ' + DB_NAME()
--EXEC master..xp_cmdshell @command, NO_OUTPUT
--ALTER TABLE wJournal DROP CONSTRAINT wJournalPK
	
---------------------------End Not used---------------------------------------------------------

  --53 rows
--**************************************************************************
	INSERT INTO iArticle (
--**************************************************************************
	PMID,
	MedlineDate,
	DatePublicationStart,
	DatePublicationEnd,
	DateEntrez,
	Year,
	MonthID,
	Day,
	Volume,
	Issue,
	StartPage,
	EndPage,
	MedLineTAID,
	MedlinePgn,
	AuthorListComplete,
	DataBankListComplete ,
	GrantListComplete ,
	ISSNID,
	ISOAbbreviation ,
	Coden,
	Title,
	Season,
	CountryID,
	MedLineCode,
	NLMUniqueID,
	PubModelID,
	CitedMediumID)
	SELECT
		a.PMID,
		LEFT(MedlineDate,50),
		DatePublicationStart,
		DatePublicationEnd,
		DateEntrez,
		Year,
		MonthID,
		Day,
		Volume,
		Issue,
		StartPage,
		EndPage,
		MedlineTAID = xme.MedlineTAID,
		LEFT(MedlinePgn,50),
		ISNULL(AuthorListComplete,0),
		ISNULL(DataBankListComplete,0),
		ISNULL(GrantListComplete,0),
		ISNULL(ISSNID,0),
		ISOAbbreviation,
		Coden,
		Title,
		Season,
		xc.CountryID,
		m.MedlineCode,
		m.NlmUniqueID,
		PubModelID,
		CitedMediumID
	FROM wArticle a
	JOIN wJournal j ON j.PMID = a.PMID
	LEFT JOIN xMonth xmo ON xmo.MonthAbv = j.Month
	LEFT JOIN xISSN xi ON xi.ISSN = j.ISSN
	LEFT JOIN wMedlineJournalInfo  m ON m.PMID = a.PMID
	LEFT JOIN xCountry xc ON xc.CountryName = m.Country
	LEFT JOIN xMedlineTA xme ON xme.MedlineTA = m.MedlineTA
	LEFT JOIN xPubModel xp ON xp.PubModel = a.PubModel
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iArticle',@RecCount,0)		
		
--**************************************************************************
-- clean up bad data
UPDATE wArticleDate SET Year = Year - 100 WHERE Year > 2012
UPDATE wArticleDate SET Year = Year - 100 WHERE Year > 2012
UPDATE wArticleDate SET Year = Year - 100 WHERE Year > 2012
--**************************************************************************
	INSERT INTO iArticleDate (
--**************************************************************************
		PMID,
		DateTypeID,
		ArticleDate
	)
	SELECT
		PMID,
		1,
		CAST(CAST(Year AS varchar(4)) + '/' + CAST(ISNULL(Month,1) AS varchar(2)) + '/' + CAST(ISNULL(Day,1) AS varchar(2)) AS smalldatetime)
		OtherID
	FROM wArticleDate w
	--LEFT JOIN xArticleDate xa ON xa.DateType = w.DateType
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iArticleDate',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iAuthor2 (
--**************************************************************************
		PMID,
		LastNameID,
		Initial1,
		Initial2,
		SuffixID,
		CollectiveNameID,
	  Seq,
		ValidYN
	)
	SELECT
		PMID,
		ISNULL(LastNameID,0),
		ISNULL(SUBSTRING(Initials,1,1),' '),
		ISNULL(SUBSTRING(Initials,2,1),' '),
		ISNULL(SuffixID,0),
		ISNULL(CollectiveNameID,0),
	  Seq,
		ValidYN
	FROM wAuthor w
	LEFT JOIN xLastName xl ON xl.LastName = w.LastName
	LEFT JOIN xSuffix 	xs ON xs.Suffix = w.Suffix
	LEFT JOIN xCollectiveName xc ON xc.CollectiveName = w.CollectiveName
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAuthor',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iDataBank (
--**************************************************************************
		PMID,
		DataBankID
	)
	SELECT
		PMID,
		DataBank_Id 
	FROM wDataBank w
	--LEFT JOIN xDataBank xd ON xd.DataBankName = w.DataBankName
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iDataBank',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iAccession (
--**************************************************************************
		PMID,
		DataBankID,
		AccessionNumber
	)
	SELECT DISTINCT
		PMID,
		DataBankID,
		AccessionNumber_Text
	FROM wAccessionNumber  w
	LEFT JOIN xDataBank xd ON xd.DataBankName = w.DataBankName
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iAccession',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iChemical2 (
--**************************************************************************
		PMID,
		ChemicalNameID,
		ChemicalRegistryID
	)
	SELECT DISTINCT
		PMID,
		ChemicalNameID,
		ChemicalRegistryID
	FROM wChemical w
	LEFT JOIN xChemicalName xn ON xn.ChemicalName = w.NameOfSubstance
	LEFT JOIN xChemicalRegistry xr ON xr.ChemicalRegistry = w.RegistryNumber
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iChemical',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iGrant (
--**************************************************************************
		PMID,
		GrantIDID,
		AcronymID,
		AgencyID,
		County

	)
	SELECT DISTINCT
		PMID,
		ISNULL(GrantIDID,0),
		MAX(ISNULL(AcronymID,0)),
		MAX(ISNULL(AgencyID,0)),
		Country
	FROM wGrant w
	LEFT JOIN xGrantID xg ON xg.GrantID = w.GrantID
	LEFT JOIN xGrantAcronym xa ON xa.Acronym = w.Acronym
	LEFT JOIN xGrantAgency xy ON xy.Agency = w.Agency
	WHERE GrantIDID IS NOT NULL
	GROUP BY PMID, GrantIDID, Country
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iGrant',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iCitationSubset (
--**************************************************************************
		PMID,
		CitationSubset
	)
	SELECT DISTINCT
		PMID,
		CitationSubset_Text
	FROM wCitationSubset
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationSubset',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iComment (
--**************************************************************************
		PMID,
		CommentTypeID,
		RefSource,
		cPMID,
		cMedlineID,
		Note
	)
	SELECT
		PMID,
		CommentTypeID,
		RefSource,
		cPMID,
		cMedlineID,
		Note
	FROM wComment w
	LEFT JOIN xCommentType xc ON xc.CommentType = w.CommentType 
	WHERE cPMID IS NOT NULL
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iComment',@RecCount,0)		
	
--*************************Not used***************************************
	--INSERT INTO iGeneralNote (

	--	PMID,
	--	OwnerID,
	--	GeneralNote
	--)
	--SELECT
	--	PMID,
	--	OwnerID,
	--	GeneralNote_Text
	--FROM wGeneralNote w
	--JOIN xOwner xo ON xo.Owner = w.Owner
	--WHERE OwnerID IS NOT NULL
	--SET @RecCount = @@ROWCOUNT	
 -- INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	--	VALUES (@LogSet,@RunType,GETDATE(),'iGeneralNote',@RecCount,0)		
	

	--INSERT INTO iInvestigator (

	--	PMID,
	--	LastNameID,
	--	SuffixID,
	--	AffiliationID,
	--  Initial1,
	--  Initial2,
	--ValidYN
	--)
	--SELECT
	--	PMID,
	--	ISNULL(LastNameID,0),
	--	ISNULL(SuffixID,0),
	--	ISNULL(AffiliationID,0),
	--	ISNULL(SUBSTRING(w.Initials,1,1),' '),
	--	ISNULL(SUBSTRING(w.Initials,2,1),' '),
	--ValidYN
	--FROM wInvestigator w
	--LEFT JOIN xLastName xl ON xl.LastName = w.LastName
	--LEFT JOIN xForeName xf ON xf.ForeName = w.ForeName
	--LEFT JOIN xSuffix 	xs ON xs.Suffix = w.Suffix
	--LEFT JOIN xAffiliation xa ON xa.Affiliation = w.Affiliation
	--SET @RecCount = @@ROWCOUNT	
 -- INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	--	VALUES (@LogSet,@RunType,GETDATE(),'iInvestigator',@RecCount,0)		
	

	--INSERT INTO iPersonalNameSubject (

	--	PMID,
	--	LastNameID,
	--	SuffixID,
	--  Initial1,
	--  Initial2
	--)
	--SELECT
	--	PMID,
	--	ISNULL(LastNameID,0),
	--	ISNULL(SuffixID,0),
	--	ISNULL(SUBSTRING(w.Initials,1,1),' '),
	--	ISNULL(SUBSTRING(w.Initials,2,1),' ')
	--FROM wPersonalNameSubject w
	--LEFT JOIN xLastName xl ON xl.LastName = w.LastName
	--LEFT JOIN xForeName xf ON xf.ForeName = w.ForeName
	--LEFT JOIN xSuffix 	xs ON xs.Suffix = w.Suffix
	--SET @RecCount = @@ROWCOUNT	
 -- INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	--	VALUES (@LogSet,@RunType,GETDATE(),'iPersonalNameSubject',@RecCount,0)		
	
--*******************End of Not used********************************************
	INSERT INTO iKeywordList (
--**************************************************************************
		PMID,
		OwnerID
	)
	SELECT
	  distinct
		PMID,
		OwnerID
	FROM wKeywordList w
	LEFT JOIN xOwner xo ON xo.Owner = w.Owner
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iKeywordList',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iKeyword (
--**************************************************************************
		PMID,
		OwnerID,
		KeywordID,
		MajorTopic
	)
	SELECT
	distinct
		PMID,
		OwnerID,
		KeywordID,
		MajorTopicYN
	FROM wKeyword w
	LEFT JOIN xOwner xo ON xo.Owner = w.Owner
	LEFT JOIN xKeyword xk ON xk.Keyword = w.Keyword_Text
	where OwnerID is not null
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iKeyword',@RecCount,0)		
--**************************************************************************
	INSERT INTO iPublicationType (
--**************************************************************************
		PMID,
		PublicationTypeID
	)
	SELECT distinct
		PMID,
		PublicationTypeID
	FROM wPublicationType w
	LEFT JOIN xPublicationType xp ON xp.PublicationType = w.PublicationType_Text
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iPublicationType',@RecCount,0)		
	
--*********************Not used*********************************
	--INSERT INTO iSpaceFlightMission (

	--	PMID,
	--	SpaceFlightMissionID
	--)
	--SELECT
	--  distinct
	--	PMID,
	--	SpaceFlightMissionID
	--FROM wSpaceFlightMission w
	--LEFT JOIN xSpaceFlightMission xs ON xs.SpaceFlightMission = w.SpaceFlightMission_Text
	--SET @RecCount = @@ROWCOUNT	
 -- INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
	--	VALUES (@LogSet,@RunType,GETDATE(),'iSpaceFlightMission',@RecCount,0)		
	
--********************End of not used*****************************************
	INSERT INTO iOtherID (
--**************************************************************************
		PMID,
		Source,
		OtherID
	)
	SELECT DISTINCT
		PMID,
		Source,
		OtherID_Text
	FROM wOtherID w
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iOtherID',@RecCount,0)		
	
--**************************************************************************
	INSERT INTO iLanguage (
--**************************************************************************
		PMID,
		LanguageID
	)
	SELECT DISTINCT
		PMID,
		LanguageID
	FROM wLanguage w
	LEFT JOIN xLanguage xl ON xl.Lang = w.Language_Text
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iLanguage',@RecCount,0)		
TRUNCATE TABLE wCitationMeSHHeadingX
--**********************************************************
	INSERT INTO wCitationMeSHHeadingX (
--**************************************************************************
		PMID,
		DescriptorUI,
		QualifierUI,
		MajorTopic
	)
	SELECT 
		w.PMID,
		DQSUIn,
		0,
		MAX(DN.MajorTopicYNB)
	FROM wMeshHeading w
	LEFT JOIN wDescriptorName DN ON W.MeshHeading_Id=DN.MeshHeading_Id 
	LEFT JOIN iMeSHTerm t ON t.TermName = DN.DescriptorName_Text where DQSUIn is not null
  GROUP BY w.PMID, DQSUIn order by DQSUIn
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeading.D',@RecCount,0)		
	INSERT INTO wCitationMeSHHeadingX (
		PMID,
		DescriptorUI,
		QualifierUI,
		MajorTopic
	)
	 SELECT
		w.PMID,
		DQSUIn,
		QualifierUIn,
		max(DN.MajorTopicYNB)
	FROM wQualifierName w
	LEFT JOIN iMeSHQualifier q ON q.QualifierName = w.QualifierName_Text
	LEFT JOIN wDescriptorName DN ON W.MeshHeading_Id=DN.MeshHeading_Id 
	LEFT JOIN iMeSHTerm t ON t.TermName = DN.DescriptorName_Text
	WHERE DQSUIn IS NOT NULL
	GROUP BY	w.PMID,
				DQSUIn,
				QualifierUIn
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeading.DQ',@RecCount,0)		
	
--**************************************************************************
-- Build wCitationScreen
--**************************************************************************
UPDATE xLanguage SET FlagValue = 0x0000 
UPDATE xLanguage SET FlagValue = 0x0001 WHERE Lang = 'eng'
UPDATE xLanguage SET FlagValue = 0x0002 WHERE Lang = 'fre'
UPDATE xLanguage SET FlagValue = 0x0004 WHERE Lang = 'ger'
UPDATE xLanguage SET FlagValue = 0x0008 WHERE Lang = 'ita'
UPDATE xLanguage SET FlagValue = 0x0010 WHERE Lang = 'jpn'
UPDATE xLanguage SET FlagValue = 0x0020 WHERE Lang = 'rus'
UPDATE xLanguage SET FlagValue = 0x0040 WHERE Lang = 'spa'
UPDATE xPublicationType SET FlagValue = 0x0000 
UPDATE xPublicationType SET FlagValue = 0x0001 WHERE PublicationType = 'Clinical Trial'
UPDATE xPublicationType SET FlagValue = 0x0002 WHERE PublicationType = 'Clinical Trial, Phase I'
UPDATE xPublicationType SET FlagValue = 0x0004 | FlagValue WHERE PublicationType = 'Clinical Trial, Phase II'
UPDATE xPublicationType SET FlagValue = 0x0008 | FlagValue  WHERE PublicationType IN ('Clinical Trial, Phase II','Clinical Trial, Phase III','Clinical Trial, Phase IV')
UPDATE xPublicationType SET FlagValue = 0x0010 | FlagValue WHERE PublicationType = 'Clinical Trial, Phase III'
UPDATE xPublicationType SET FlagValue = 0x0020 | FlagValue WHERE PublicationType IN ('Clinical Trial, Phase III','Clinical Trial, Phase IV')
UPDATE xPublicationType SET FlagValue = 0x0040 | FlagValue WHERE PublicationType = 'Clinical Trial, Phase IV'
UPDATE xPublicationType SET FlagValue = 0x0080 WHERE PublicationType = 'Editorial'
UPDATE xPublicationType SET FlagValue = 0x0100 WHERE PublicationType = 'Letter'
UPDATE xPublicationType SET FlagValue = 0x0200 WHERE PublicationType = 'Meta-Analysis'
UPDATE xPublicationType SET FlagValue = 0x0400 WHERE PublicationType = 'Multicenter Study'
UPDATE xPublicationType SET FlagValue = 0x0800 WHERE PublicationType = 'Practice Guideline'
UPDATE xPublicationType SET FlagValue = 0x1000 WHERE PublicationType = 'Randomized Controlled Trial'
UPDATE xPublicationType SET FlagValue = 0x2000 WHERE PublicationType = 'Review'
UPDATE xPublicationType SET FlagValue = 0x4000 WHERE PublicationType = ''
UPDATE xPublicationType SET FlagValue = 0x8000 WHERE PublicationType = ''
DELETE FROM wCitationScreen
INSERT INTO wCitationScreen (
		PMID, 
		fl,fo,fs,fp,
		de
)
SELECT 
		w.PMID, 
		0,0,0,0,
		CAST(w.DateCreatedMonth	as varchar(4)) + '/' + CAST(w.DateCreatedDay	as varchar(4)) + '/' + CAST(w.DateCreatedYear as varchar(4))
	FROM wMedlineCitation w 
--Human D6801
UPDATE wCitationScreen SET fo = fo | 0x01 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 6801) a ON a.pmid = i.pmid
--Animal D818
UPDATE wCitationScreen SET fo = fo | 0x02 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 818) a ON a.pmid = i.pmid
--Male D8297
UPDATE wCitationScreen SET fo = fo | 0x04 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE  DescriptorUI = 8297) a ON a.pmid = i.pmid
--Female D5260
UPDATE wCitationScreen SET fo = fo | 0x08 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 5260) a ON a.pmid = i.pmid
UPDATE wCitationScreen SET fo = fo | 0x10 FROM wCitationScreen i
  JOIN wAbstract a ON a.pmid = i.pmid
	--WHERE LEN(AbstractText) > 0
--Newborn (birth-1 month)				Newborns D7231; Infant, Newborn D7232; Birth D7743
UPDATE wCitationScreen SET fs = fs | 0x0001 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI IN(7231,7232,7743)) a ON a.pmid = i.pmid
--Infant (1-23 months)					Infant D7223
UPDATE wCitationScreen SET fs = fs | 0x0002 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 7223) a ON a.pmid = i.pmid
--All Infant (birth-23 months)  
UPDATE wCitationScreen SET fs = fs | 0x0004 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI IN(7231,7232,7743,7223)) a ON a.pmid = i.pmid
--Preschool Child (2-5 years)		Preschool D2675
UPDATE wCitationScreen SET fs = fs | 0x0010 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 2675) a ON a.pmid = i.pmid
--Child (6-12 years)					  Child D2648
UPDATE wCitationScreen SET fs = fs | 0x0020 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 2648) a ON a.pmid = i.pmid
--Adolescent (13-18 years)			Adolescents D293
UPDATE wCitationScreen SET fs = fs | 0x0040 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 293) a ON a.pmid = i.pmid
--All Child (0-18 years)				Child D2648
UPDATE wCitationScreen SET fs = fs | 0x0080 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI IN(7231,7232,7743,7223,2648,293,2648)) a ON a.pmid = i.pmid
--Adult (19-44 years)						Adult D328
UPDATE wCitationScreen SET fs = fs | 0x0100 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 328) a ON a.pmid = i.pmid
--Middle Aged (45-64 years)			Middle Aged D8875
UPDATE wCitationScreen SET fs = fs | 0x0200 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 8875) a ON a.pmid = i.pmid
--Aged (65+ years)							Aged D368
UPDATE wCitationScreen SET fs = fs | 0x0400 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 368) a ON a.pmid = i.pmid
--80 and over (80+ years)				Aged, 80 and over D369
UPDATE wCitationScreen SET fs = fs | 0x0800 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI = 369) a ON a.pmid = i.pmid
--All Adult (19+ years)
UPDATE wCitationScreen SET fs = fs | 0x1000 FROM wCitationScreen i
  JOIN (SELECT PMID FROM wCitationMeSHHeadingX WHERE DescriptorUI IN(328,8875,368,369)) a ON a.pmid = i.pmid
--select * from imeshterm where TermName LIKE '%Aged%' order by termname
UPDATE wCitationScreen SET fp = SumFlagValue FROM wCitationScreen i
  JOIN (SELECT PMID, SUM(FlagValue) AS SumFlagValue
			    FROM iPublicationType p
  					JOIN xPublicationType x ON x.PublicationTypeID = p.PublicationTypeID
					GROUP BY pmid) a  ON a.pmid = i.pmid
UPDATE wCitationScreen SET fl = SumFlagValue FROM wCitationScreen i
  JOIN (SELECT PMID, SUM(FlagValue) AS SumFlagValue
			    FROM iLanguage l
  					JOIN xLanguage x ON x.LanguageID = l.LanguageID
					GROUP BY pmid) a  ON a.pmid = i.pmid
--**************************************************************************
	TRUNCATE TABLE wAuthor2
	INSERT INTO wAuthor2 SELECT * FROM wAuthor
--**************************************************************************
	
--**************************************************************************
-- build #satj
--**************************************************************************
	SELECT w.pmid,
				 MedlineTA		= LEFT(xm.MedlineTA,100),
				 MedlinePgn,
				 AuthorList	= ISNULL(LEFT(al.AuthorList,100),'[No Authors Listed]'),
				 DisplayNotes = '' +
											CASE WHEN (cs.fl & 0x0001) =  1 THEN '' ELSE ISNULL(Language + '. ','') END +
											CASE WHEN (cs.fo & 0x10) = 0 THEN 'No abstract available. ' ELSE '' END,
				 DisplayDate = LEFT(CASE
												WHEN MedlineDate IS NOT NULL THEN MedlineDate ELSE
												CAST([Year] AS varchar(4)) + 
													CASE
														WHEN MonthID = 0 THEN '' ELSE
															CASE
																WHEN MonthID =  1 THEN ' Jan' 
																WHEN MonthID =  2 THEN ' Feb' 
																WHEN MonthID =  3 THEN ' Mar' 
																WHEN MonthID =  4 THEN ' Apr' 
																WHEN MonthID =  5 THEN ' May' 
																WHEN MonthID =  6 THEN ' Jun' 
																WHEN MonthID =  7 THEN ' Jul' 
																WHEN MonthID =  8 THEN ' Aug' 
																WHEN MonthID =  9 THEN ' Sep' 
																WHEN MonthID = 10 THEN ' Oct' 
																WHEN MonthID = 11 THEN ' Nov' 
																WHEN MonthID = 12 THEN ' Dec'
															END +
														  CASE WHEN [Day] > 0 THEN ' ' + CAST([DAY] AS varchar(2)) ELSE '' END
													END
											END +
											';' + 
											CASE WHEN Volume IS NULL THEN	'' ELSE Volume END + 
											CASE WHEN Issue IS NULL THEN '' ELSE '(' + Issue + ')' END
											,100)
		INTO #satj
		FROM wMedlineCitation w
    JOIN wCitationScreen cs ON cs.PMID = w.PMID 
		LEFT JOIN iArticle a ON a.PMID = w.PMID
		LEFT JOIN xMedlineTA xm ON xm.MedlineTAID = a.MedlineTAID		
		LEFT JOIN (SELECT wl.PMID,MIN(LanguageID) AS mLID
									FROM wLanguage wl
									JOIN xLanguage xl on xl.Lang = wl.Language_Text
									GROUP BY wl.PMID) l ON l.PMID = w.PMID
		LEFT JOIN xLanguage xl ON xl.LanguageID = l.mLID
		LEFT JOIN (SELECT
					PMID,
					Author1 + 
				  CASE WHEN Author2 = '' THEN '' ELSE ', ' + Author2 END +
				  CASE WHEN Author3 = '' THEN '' ELSE ', ' + Author3 END +
				  CASE WHEN Author4 = '' THEN '' ELSE ', ' + 'et al' END AS 'AuthorList'
					FROM(SELECT
								wa2.PMID,
								MAX(CASE WHEN Seq = sSeq + 0 THEN CASE WHEN CollectiveName IS NULL or CollectiveName=''  THEN 
												LastName + CASE WHEN Initials IS NULL or Initials=''  THEN '' ELSE ' ' + Initials END
											ELSE CollectiveName END ELSE '' END) AS 'Author1',
								MAX(CASE WHEN Seq = sSeq + 1 THEN CASE WHEN CollectiveName IS NULL or CollectiveName=''  THEN 
												LastName + CASE WHEN Initials IS NULL or Initials='' THEN '' ELSE ' ' + Initials END
											ELSE CollectiveName END ELSE '' END) AS 'Author2',
								MAX(CASE WHEN Seq = sSeq + 2 THEN CASE WHEN CollectiveName IS NULL or CollectiveName=''  THEN 
												LastName + CASE WHEN Initials IS NULL or Initials='' THEN '' ELSE ' ' + Initials END
											ELSE CollectiveName END ELSE '' END) AS 'Author3',
								MAX(CASE WHEN Seq = sSeq + 3 THEN CASE WHEN CollectiveName IS NULL or CollectiveName='' THEN 
												LastName + CASE WHEN Initials IS NULL or Initials='' THEN '' ELSE ' ' + Initials END
											ELSE CollectiveName END ELSE '' END) AS 'Author4'
							FROM wAuthor2 wa2
							  JOIN (SELECT	PMID, 
															COUNT(*) AS 'aCount', 
															MIN(Seq) AS 'sSeq' 
												FROM wAuthor2 
												GROUP BY PMID) ac ON ac.PMID = wa2.PMID
							  GROUP BY wa2.PMID ) a) al ON al.PMID = w.PMID


--**************************************************************************
	INSERT INTO iCitation (
--**************************************************************************
	  MedlinePgn,
		MedlineTA,
		AuthorList,
		DisplayNotes,
		DisplayDate,
		MedlineID,
		PMID,
		StatusID,
		OwnerID,
		DateCreated,
		DateCompleted,
		DateRevised,
		NumberOfReferences,
		UpdateSource,
		UpdateDate
	)
	SELECT 	
		LEFT(MedlinePgn,100),
		MedlineTA,
		AuthorList,
		DisplayNotes,
		DisplayDate,
		MedlineCitation_Id,
		w.PMID,
		StatusID,
		ISNULL(OwnerID,0),
		CASE WHEN DateCreatedMonth > 0		THEN CAST(DateCreatedMonth		as varchar(4)) + '/' + CAST(DateCreatedDay		as varchar(4)) + '/' + CAST(DateCreatedYear 	as varchar(4)) ELSE NULL END, 
		CASE WHEN DateCompletedMonth > 0	THEN CAST(DateCompletedMonth	as varchar(4)) + '/' + CAST(DateCompletedDay	as varchar(4)) + '/' + CAST(DateCompletedYear as varchar(4)) ELSE NULL END,
		CASE WHEN DateRevisedMonth > 0 		THEN 	CAST(DateRevisedMonth		as varchar(4)) + '/' + CAST(DateRevisedDay		as varchar(4)) + '/' + CAST(DateRevisedYear		as varchar(4)) ELSE NULL END,
		CASE WHEN NumberOfReferences > 30000 THEN 30000 ELSE ISNULL(NumberOfReferences,0) END,
		UpdateSource,
		UpdateDate
	FROM wMedlineCitation w
	JOIN xCitationStatus xc ON xc.Status = w.Status
	LEFT JOIN xOwner xo ON xo.Owner = w.Owner
	LEFT JOIN #satj s ON s.PMID = w.PMID
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitation',@RecCount,0)		
DROP TABLE #satj
--**************************************************************************
INSERT INTO iWide (
--**************************************************************************
	PMID,
	ArticleTitle,
	AbstractText,
	CopyrightInformation,
	VernacularTitle,
	Affiliation
)
SELECT
		a.PMID,
		a.ArticleTitle,
		dbo.fn_get_abstract_text(b.PMID),
		CopyrightInformation,
		VernacularTitle,
		Affiliation
FROM wArticle a
LEFT JOIN wAbstract b on b.PMID = a.PMID
LEFT JOIN iCitation c on c.PMID = a.PMID
WHERE DateCreated < '2001-01-01'
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iWide',@RecCount,0)		
--**************************************************************************
INSERT INTO iWideNew (
--**************************************************************************
	PMID,
	ArticleTitle,
	AbstractText,
	CopyrightInformation,
	VernacularTitle,
	Affiliation
)
SELECT
		a.PMID,
		a.ArticleTitle,
		dbo.fn_get_abstract_text(b.PMID),
		CopyrightInformation,
		VernacularTitle,
		Affiliation
FROM wArticle a
LEFT JOIN wAbstract b on b.PMID = a.PMID
LEFT JOIN iCitation c on c.PMID = a.PMID
WHERE DateCreated >= '2001-01-01'
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iWideNew',@RecCount,0)		
--**************************************************************************
	INSERT INTO iCitationScreen (
--**************************************************************************
			PMID,
			sj,st,sa,
			dps,
			dpe,
			de,
		  du,
			fp,
			fs,
			fo,
			fl)
		SELECT
			w.PMID,
			0,0,0,
			DATEDIFF(d,'1960-01-01',DatePublicationStart),
			DATEDIFF(d,'1960-01-01',DatePublicationEnd),
			DATEDIFF(d,'1960-01-01',DateCreated),
			DATEDIFF(d,'1960-01-01',UpdateDate),
			fp,
			fs,
			fo,
			fl
		FROM wCitationScreen w
	  JOIN iCitation c ON c.PMID = w.PMID
	  JOIN iArticle a ON a.PMID = w.PMID
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationScreen',@RecCount,0)		
--**************************************************************************
	INSERT INTO iCitationMeSHHeading2 (
--**************************************************************************
		DescriptorUI,
		QualifierUI,
		PMID
	)
SELECT
		DescriptorUI,
		QualifierUI,
		PMID
FROM wCitationMeSHHeadingX 
WHERE DescriptorUI NOT IN(6801,5260,8297,818,328,8875,4740,293,368,2648,2675,7223,7231)
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeading',@RecCount,0)		
--****************************Not used***************************************
--	INSERT INTO iCitationMeSHHeadingAside2 (
--		DescriptorUI,
--		QualifierUI,
--		PMID
--	)
--SELECT
--		DescriptorUI,
--		QualifierUI,
--		PMID
--FROM wCitationMeSHHeadingX
--WHERE DescriptorUI IN(6801,5260,8297,818,328,8875,4740,293,368,2648,2675,7223,7231)
--	SET @RecCount = @@ROWCOUNT	
--  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
--		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHHeadingAside',@RecCount,0)		
--***********************End of not used****************************************
	INSERT INTO iCitationMeSHQualifier2 (
--**************************************************************************
		QualifierUI,
		PMID
	)
SELECT DISTINCT
		QualifierUI,
		PMID
FROM wCitationMeSHHeadingX 
WHERE QualifierUI > 0
	SET @RecCount = @@ROWCOUNT	
  INSERT INTO LogTables(LogSet,RunType,LogTime,TableName,RecCount,RecCountPrior) 
		VALUES (@LogSet,@RunType,GETDATE(),'iCitationMeSHQualifier',@RecCount,0)
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchExecuteC]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SearchExecuteC]
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
	@UpdateSourceFrom		smallint,				-- only for autosearch.
	@UpdateSourceTo			smallint,				-- only for autosearch.
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
		    FROM AJA..SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  IF @DoNoExecute = 0
  	DELETE FROM AJA..SearchResults WHERE SearchID = @SearchID

	SET @RunQuery = 0
  EXEC ap_SearchBuildFullQueryC  @SearchID,
																@SearchMode,
																@ShelfLife,
																@LimitToUserLibrary,
																@ThisAutorunDate,
																@ResultsFolder1,
																@ResultsFolder2,
																@UserDB,
																@KeepDelete,
																@UpdateSourceFrom,
																@UpdateSourceTo,
																@QueryFinal	OUTPUT,		--Full query
																@RunQuery		OUTPUT,		--0: don't run query; 1: run query
																@ErrorDesc	OUTPUT,		--Show user why search terms are no good
																@QueryDetails	OUTPUT

	IF @RunQuery = 1 AND @DoNoExecute <> 1
		BEGIN
			EXEC sp_executesql @QueryFinal
		  SELECT @SearchResultsCount = FoundLast
				FROM AJA..SearchSummary
				WHERE SearchID = @SearchID
		END
	ELSE
		BEGIN
		  SET @SearchResultsCount = 0
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchExecute_AJA]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchExecute_AJA]
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
		    FROM AJA.dbo.SearchSummary with (nolock)
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  IF @DoNoExecute = 0
  	DELETE FROM AJA.dbo.SearchResults WHERE SearchID = @SearchID

	SET @RunQuery = 0
  EXEC ap_SearchBuildFullQuery_AjA  @SearchID,
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
				FROM AJA.dbo.SearchSummary with (nolock)
				WHERE SearchID = @SearchID
		END
	ELSE
		BEGIN
		  SET @SearchResultsCount = 0
		END
		select @SearchResultsCount SearchResultsCount,@QueryDetails QueryDetails , @ErrorDesc ErrorDesc
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchExecute]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SearchExecute]
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
		    FROM AJA.dbo.SearchSummary
				WHERE UserID			= @UserID	AND
						  SearchName	= @SearchName
		  IF @@ROWCOUNT = 0
				RETURN
		END
  IF @DoNoExecute = 0
  	DELETE FROM AJA.dbo.SearchResults WHERE SearchID = @SearchID

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
				FROM AJA..SearchSummary
				WHERE SearchID = @SearchID
		END
	ELSE
		BEGIN
		  SET @SearchResultsCount = 0
		END
		select @SearchResultsCount SearchResultsCount,@QueryDetails QueryDetails , @ErrorDesc ErrorDesc
GO
/****** Object:  StoredProcedure [dbo].[ap_SAS_RunAll]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SAS_RunAll]
	@ThisAutorunDateS		varchar(50),
	@UserDB							varchar(50)
AS
	DECLARE @SearchID						int
	DECLARE @SearchResultsCount	int
	DECLARE @QueryDetails				varchar(2000)
	DECLARE @ErrorDesc					varchar(2000)
	DECLARE @ShelfLife					smallint
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1			int
  DECLARE @ResultsFolder2			int
	DECLARE @ThisAutorunDate		smalldatetime
  DECLARE @KeepDelete					tinyint


	SET @ThisAutorunDate = CAST(@ThisAutorunDateS AS smalldatetime)
	DECLARE curS CURSOR FOR
	  SELECT SearchID, ShelfLife, LimitToUserLibrary, ResultsFolder1, ResultsFolder2, KeepDelete
		  FROM AJA..SearchSummary
			WHERE AutoSearch	= 1		AND
						UserDB			= @UserDB 
 --AND userid = 1799 	
			ORDER BY UserID
	OPEN curS
	FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder1, @ResultsFolder2, @KeepDelete
  WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC ap_SearchExecute 0,
														'',
													  @SearchID,
														1,
														@ShelfLife, 
														@LimitToUserLibrary, 
														@ThisAutorunDate,
														@ResultsFolder1, 
														@ResultsFolder2,
														@UserDB,
														@KeepDelete,
														0,
													  @SearchResultsCount	OUTPUT,
														@QueryDetails				OUTPUT,
														@ErrorDesc					OUTPUT											
			UPDATE AJA..SearchSummary
				SET LastAutorunDate = @ThisAutorunDate,
						LastAutorunHits	= @SearchResultsCount
				WHERE SearchID = @SearchID

--print 'ap_SAS_RunAll:  @ThisAutorunDate: ' + isnull(cast(@ThisAutorunDate as varchar(40)),'')
--print 'ap_SAS_RunAll:  @SearchResultsCount: ' + isnull(cast(@SearchResultsCount as varchar(40)),'')

			FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder1, @ResultsFolder2, @KeepDelete
		END
  CLOSE curS
	DEALLOCATE curS


-- Mailing --------------------------------------------------------------
	DECLARE @MailOut			varchar(4000)
	DECLARE @email				nvarchar(50)
	DECLARE @emailLast		nvarchar(50)
	DECLARE @firstname		nvarchar(50)
	DECLARE @lastname			nvarchar(50)
	DECLARE @title				nvarchar(50)
	DECLARE @FolderName1	nvarchar(50)
	DECLARE @FolderName2	nvarchar(50)
	DECLARE @FolderName2p	nvarchar(50)
  DECLARE @SpecialtyName varchar(50)
	DECLARE @SearchName	 varchar(500)
	DECLARE @NewCitations	int
	DECLARE @cr						varchar(20)
	DECLARE @SQL					nvarchar(1000)
  DECLARE @Conclusion		varchar(1000)
  DECLARE @len					int


-- Misc. Initialization -------------------------------------------------
	SET @cr = '\r\n' --CHAR(13) + CHAR(10)
  SET @Conclusion = @cr + 
'To view your saved queries and their new citations, or to ' + 
'change your notification preference, please log on to ' +
'http://www.cogentmedicine.com, and select My Queries from ' + 
'the navigation bar.  Please e-mail us at ' +
'support@cogentmedicine.com if you have any questions about ' +
'the Cogent Medicine system.' + @cr + @cr +
'Sincerely,' + @cr + @cr + 
'Brian Goldsmith MD' + @cr + 
'Moderator, Cogent Medicine' + @cr

	SET @emailLast = 'zzzz999919'

	SELECT 0 as SearchID, CAST('' AS varchar(100))		AS 'email',
				 CAST('' AS varchar(100))		AS 'firstname',
				 CAST('' AS varchar(100))		AS 'lastname',
				 CAST('' AS varchar(100))		AS 'searchname',
				 CAST('' AS varchar(100))		AS 'FolderName1',
				 CAST('' AS varchar(100))		AS 'FolderName2',
				 CAST('' AS varchar(100))		AS 'FolderName2p',
				 CAST('' AS varchar(100))		AS 'SpecialtyName',
				 CAST(0 AS int)		AS 'NewCitations'
		INTO #t 
	DELETE FROM #t		

	SET @SQL = 'INSERT INTO #t ' + 
						 'SELECT s.searchid, u.email, firstname, lastname, searchname, f1.name AS ''FolderName1'', f2.name AS ''FolderName2'', f2p.name AS ''FolderName2p'', SpecialtyName, LastAutorunHits	AS ''NewCitations'' ' +
						 ' FROM ' + @UserDB + '..Users u' + 
						 ' JOIN AJA..SearchSummary s ON s.UserID = u.UserID' + 
						 ' JOIN ' + @UserDB + '..UserFolder f1 ON f1.id = s.ResultsFolder1' + 
						 ' LEFT JOIN ' + @UserDB + '..UserFolder f2 ON f2.id = s.ResultsFolder2' + 
						 ' LEFT JOIN ' + @UserDB + '..UserFolder f2p ON f2p.id = f2.parent' + 
						 ' LEFT JOIN ' + @UserDB + '..Specialties sp ON sp.SpecialtyID = f2p.specialty' + 
						 ' WHERE u.email IS NOT NULL		AND' + 
						 ' 			s.LastAutorunHits > 0			AND' + 
						 ' 			s.LastAutorunDate = ''' + CAST(@ThisAutorunDate AS varchar(20)) + '''		AND' + 
						 ' 			AutoSearch	= 1			AND' + 
						 ' 			s.UserDB = ''' + @UserDB + '''		AND' + 
						 ' 			u.sasemail = 1'

	EXEC sp_executesql @SQL

  INSERT INTO AJA..LogSearch
		(SearchID, email, firstname, lastname, searchname, NewCitations)
  SELECT SearchID, email, firstname, lastname, searchname, NewCitations FROM #t

	DECLARE curM CURSOR FOR
		SELECT * FROM #t
			ORDER BY email
	OPEN curM
	FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @FolderName1, @FolderName2, @FolderName2p, @SpecialtyName, @NewCitations
  WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @emailLast <> @email
				BEGIN
					IF @emailLast <> 'zzzz999919'
						BEGIN
							SET @MailOut = @MailOut + @Conclusion + '"'
							EXEC master..xp_cmdshell @MailOut

						END
					SET @MailOut = 'postie -host:192.168.36.33 -to:' + 
												 @email + 
												 ' -from:support@cogentmedicine.com ' + 
												 ' -s:"Cogent Medicine AutoQuery Update"' + 
												 ' -msg:"Dear ' + 
												 @firstname + ' ' + @lastname + ':' + @cr + @cr +
												 'Your AutoQuery status this week:' + @cr + @cr
					SET @emailLast = @email
				END

/*
			SET @len = LEN(@FolderName1)
			SET @FolderName1 = SUBSTRING(@FolderName1,1,20)
			IF LEN(@FolderName1) <> @len
			  BEGIN
			    SET @FolderName1 = REVERSE(@FolderName1)
				  SET @len = CHARINDEX(' ',@FolderName1)
				  IF @Len = 0
						  SET @FolderName1 = REVERSE(@FolderName1) + '...'
				  ELSE
							SET @FolderName1 = REVERSE(SUBSTRING(@FolderName1,@len+1,99)) + '...'
				END
*/
		  IF @FolderName2 IS NOT NULL
			  BEGIN
					SET @len = LEN(@FolderName2)
					SET @FolderName2 = SUBSTRING(@FolderName2,1,20)
					IF LEN(@FolderName2) <> @len
					  BEGIN
					    SET @FolderName2 = REVERSE(@FolderName2)
						  SET @len = CHARINDEX(' ',@FolderName2)
						  IF @Len = 0
								  SET @FolderName2 = REVERSE(@FolderName2) + '...'
						  ELSE
									SET @FolderName2 = REVERSE(SUBSTRING(@FolderName2,@len+1,99)) + '...'
						END
				END

		  IF @FolderName2p IS NOT NULL
			  BEGIN
					SET @len = LEN(@FolderName2p)
					SET @FolderName2p = SUBSTRING(@FolderName2p,1,20)
					IF LEN(@FolderName2p) <> @len
					  BEGIN
					    SET @FolderName2p = REVERSE(@FolderName2p)
						  SET @len = CHARINDEX(' ',@FolderName2p)
						  IF @Len = 0
								  SET @FolderName2p = REVERSE(@FolderName2p) + '...'
						  ELSE
									SET @FolderName2p = REVERSE(SUBSTRING(@FolderName2p,@len+1,99)) + '...'
						END
				END

			SET @MailOut = @MailOut + 'Query Title: ' + @SearchName + @cr + 
										 CASE 
											 WHEN @FolderName2 IS NULL THEN
												 'Destination folder: ' + @FolderName1 + @cr
											 ELSE
												 'Destination folder: ' + ISNULL(@SpecialtyName + '>','') + @FolderName2p + '>' + @FolderName2 + @cr
--												@FolderName1 + ', ' + @FolderName2 + ' folders: '
										 END  + CAST(@NewCitations AS varchar(10)) + ' citations' + @cr  + @cr
			FETCH NEXT FROM curM INTO  @SearchID, @email, @firstname, @lastname, @SearchName, @FolderName1, @FolderName2, @FolderName2p, @SpecialtyName, @NewCitations
		END
  CLOSE curM
	DEALLOCATE curM
	DROP TABLE #t

	IF @emailLast <> 'zzzz999919'
	  BEGIN
			SET @MailOut = @MailOut + @Conclusion + '"'
			EXEC master..xp_cmdshell @MailOut
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SAS_RunAllC]    Script Date: 10/28/2013 15:49:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ap_SAS_RunAllC]
	@ThisAutorunDateS		varchar(50),
	@UserDB							varchar(50),
	@profile_name varchar(50),
	@UpdateSourceFrom		smallint,				
	@UpdateSourceTo			smallint
AS
	DECLARE @SearchID						int
	DECLARE @SearchResultsCount	int
	DECLARE @QueryDetails				varchar(2000)
	DECLARE @ErrorDesc					varchar(2000)
	DECLARE @ShelfLife					smallint
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1			int
  DECLARE @ResultsFolder2			int
	DECLARE @ThisAutorunDate		smalldatetime
  DECLARE @KeepDelete					tinyint

	SET @ThisAutorunDate = CAST(@ThisAutorunDateS AS smalldatetime)
	DECLARE curS CURSOR FOR
	  SELECT SearchID, ShelfLife, LimitToUserLibrary, ResultsFolder2, KeepDelete
		  FROM AJA..SearchSummary
			WHERE AutoSearch	= 1		
					AND UserDB			= @UserDB 
--AND userid = 13788 	--andrew
-- AND userid = 2576  --pual
			ORDER BY UserID
	OPEN curS
	FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete
  WHILE @@FETCH_STATUS = 0
		BEGIN
print 'executing ' + cast(@SearchID as varchar(10))
			EXEC ap_SearchExecuteC 0,
														'',
													  @SearchID,
														1,
														@ShelfLife, 
														@LimitToUserLibrary, 
														@ThisAutorunDate,
														@ResultsFolder1, 
														@ResultsFolder2,
														@UserDB,
														@KeepDelete,
														@UpdateSourceFrom,
														@UpdateSourceTo,
														0,
													  @SearchResultsCount	OUTPUT,
														@QueryDetails				OUTPUT,
														@ErrorDesc					OUTPUT											
			UPDATE AJA..SearchSummary
				SET LastAutorunDate = @ThisAutorunDate,
						LastAutorunHits	= @SearchResultsCount
				WHERE SearchID = @SearchID

--print 'ap_SAS_RunAllC2:  @ThisAutorunDate: ' + isnull(cast(@ThisAutorunDate as varchar(40)),'')
--print 'ap_SAS_RunAllC2:  @SearchResultsCount: ' + isnull(cast(@SearchResultsCount as varchar(40)),'')

			FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete
		END
  CLOSE curS
	DEALLOCATE curS

--print cast(@ResultsFolder2 as varchar(10))
-- Mailing --------------------------------------------------------------
	DECLARE @MailOut				varchar(4000)
	DECLARE @email					nvarchar(50)
	DECLARE @emailLast			nvarchar(50)
	DECLARE @firstname			nvarchar(50)
	DECLARE @lastname				nvarchar(50)
	DECLARE @title					nvarchar(50)
	DECLARE @SpecialtyName	nvarchar(50)
	DECLARE @TopicName			nvarchar(50)
	DECLARE @SubTopicName		nvarchar(50)
	DECLARE @SearchName			varchar(500)
	DECLARE @NewCitations		int
	DECLARE @cr							varchar(20)
	DECLARE @SQL						nvarchar(1000)
  DECLARE @Conclusion			varchar(1000)
  DECLARE @len						int
  
  Declare @mailRecipients varchar(max)
  Declare @subject varchar(50)
  Declare @body varchar(max)
-- Misc. Initialization -------------------------------------------------
--set @profile_name='AutoQuery' 
	SET @cr = CHAR(13)+CHAR(10) --CHAR(13) + CHAR(10)
  SET @Conclusion = @cr + 
'To view your saved queries and their new citations, or to ' + 
'change your notification preference, please log on to ' +
'https://www.ACRJournalAdvisor.com, and select My Queries from ' + 
'the navigation bar.Please e-mail us at ' +
'ACRjournaladvisor@acr.org if you have any questions about ' +
'the ACR Journal Advisor system.' + @cr + @cr +
'Sincerely,' + @cr + @cr + 
'Brian Goldsmith MD' + @cr + 
'Moderator, ACR Journal Advisor' + @cr

	SET @emailLast = 'zzzz999919'

	SELECT 0 as SearchID, CAST('' AS varchar(100))		AS 'email',
				 CAST('' AS varchar(100))		AS 'firstname',
				 CAST('' AS varchar(100))		AS 'lastname',
				 CAST('' AS varchar(100))		AS 'searchname',
				 CAST('' AS varchar(100))		AS 'SpecialtyName',
				 CAST('' AS varchar(100))		AS 'TopicName',
				 CAST('' AS varchar(100))		AS 'SubTopicName',
				 CAST(0 AS int)		AS 'NewCitations'
		INTO #t 
	DELETE FROM #t		

	SET @SQL = 'INSERT INTO #t ' + 
						 'SELECT s.searchid, u.email, firstname, lastname, searchname, SpecialtyName, TopicName, SubTopicName, LastAutorunHits	AS ''NewCitations'' ' +
						 ' FROM ' + @UserDB + '..Users u' + 
						 ' JOIN AJA..SearchSummary s ON s.UserID = u.UserID' + 
						 ' LEFT JOIN ' + @UserDB + '..SubTopics h3 ON h3.SubTopicID = s.ResultsFolder2' + 
						 ' LEFT JOIN ' + @UserDB + '..Topics h2 ON h2.TopicID = h3.TopicID' + 
						 ' LEFT JOIN ' + @UserDB + '..Specialties h1 ON h1.SpecialtyID = h2.SpecialtyID' + 
						 ' WHERE u.email IS NOT NULL		AND' + 
						 ' 			s.LastAutorunHits > 0			AND' + 
						 ' 			s.LastAutorunDate = ''' + CAST(@ThisAutorunDate AS varchar(20)) + '''		AND' + 
						 ' 			AutoSearch	= 1			AND' + 
						 ' 			s.UserDB = ''' + @UserDB + '''		AND' + 
--' u.userid = 13788 	AND ' + 
--' u.userid = 2576 	AND ' + 
						 ' 			u.sasemail = 1'

	EXEC sp_executesql @SQL
select * from #t

  INSERT INTO AJA..LogSearch
		(SearchID, email, firstname, lastname, searchname, NewCitations)
  SELECT SearchID, email, firstname, lastname, searchname, NewCitations FROM #t

	DECLARE curM CURSOR FOR
		SELECT * FROM #t
			ORDER BY email			
			set @subject ='ACR Journal Advisor AutoQuery Update'
	OPEN curM
	FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
  WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @emailLast <> @email
				BEGIN
					IF @emailLast <> 'zzzz999919'
						BEGIN
						--set @mailRecipients ='';
						--set @mailRecipients = @email
							SET @MailOut = @MailOut + @Conclusion --+ '"'
							Print '1st : '+@mailRecipients
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
													@recipients = @mailRecipients,
													@body = @MailOut,
													@subject =@subject;
                        
						END					
						set @mailRecipients ='';
						set @mailRecipients =@email						
						set @MailOut='Dear '+ @firstname + ' ' + @lastname + ',' + @cr + @cr + 'Your AutoQuery status this week:' + @cr + @cr
					
							Print 'Loop : '+@mailRecipients	      
					SET @emailLast = @email
				END

		  IF @SpecialtyName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SpecialtyName)
					SET @SpecialtyName = SUBSTRING(@SpecialtyName,1,20)
					IF LEN(@SpecialtyName) <> @len
					  BEGIN
					    SET @SpecialtyName = REVERSE(@SpecialtyName)
						  SET @len = CHARINDEX(' ',@SpecialtyName)
						  IF @Len = 0
								  SET @SpecialtyName = REVERSE(@SpecialtyName) + '...'
						  ELSE
									SET @SpecialtyName = REVERSE(SUBSTRING(@SpecialtyName,@len+1,99)) + '...'
						END
				END

		  IF @TopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@TopicName)
					SET @TopicName = SUBSTRING(@TopicName,1,20)
					IF LEN(@TopicName) <> @len
					  BEGIN
					    SET @TopicName = REVERSE(@TopicName)
						  SET @len = CHARINDEX(' ',@TopicName)
						  IF @Len = 0
								  SET @TopicName = REVERSE(@TopicName) + '...'
						  ELSE
									SET @TopicName = REVERSE(SUBSTRING(@TopicName,@len+1,99)) + '...'
						END
				END

		  IF @SubTopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SubTopicName)
					SET @SubTopicName = SUBSTRING(@SubTopicName,1,20)
					IF LEN(@SubTopicName) <> @len
					  BEGIN
					    SET @SubTopicName = REVERSE(@SubTopicName)
						  SET @len = CHARINDEX(' ',@SubTopicName)
						  IF @Len = 0
								  SET @SubTopicName = REVERSE(@SubTopicName) + '...'
						  ELSE
									SET @SubTopicName = REVERSE(SUBSTRING(@SubTopicName,@len+1,99)) + '...'
						END
				END


			SET @MailOut = @MailOut + 'Query Title: ' + @SearchName + @cr + 
										'Destination Folder: ' + ISNULL(@SpecialtyName + '-->','') + @TopicName + '-->' + @SubTopicName + @cr +
										 CAST(@NewCitations AS varchar(10)) + ' citations' + @cr  + @cr
			FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
		END
  CLOSE curM
	DEALLOCATE curM
	DROP TABLE #t

	IF @emailLast <> 'zzzz999919'
	  BEGIN
	  begin try
	 Print '2st try: '+@mailRecipients
			SET @MailOut = @MailOut + @Conclusion 
			EXEC msdb.dbo.sp_send_dbmail  @profile_name = @profile_name,
    @recipients = @mailRecipients,
    @body = @MailOut,
    @subject =@subject;
    
			end try
	  begin catch
	  Print '2st catch: '+@mailRecipients
	    SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
        end catch
        Print 'last : '+@mailRecipients
    print @MailOut
		END
GO
/****** Object:  StoredProcedure [dbo].[ap_SAS_RunAll3]    Script Date: 10/28/2013 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ap_SAS_RunAll3]
	@ThisAutorunDateS		varchar(50),
	@UserDB							varchar(50)
AS

--exec ap_SAS_RunAll3 '2009-02-14', 'User_01'
--exec ap_SAS_RunAll3 '2009-03-20', 'User_01'

--update cogentsearch..searchsummary set lastautorundate = '2000-01-30 00:00:00' where searchid = 20566
-- select * from User_01..users where userid = 1799
SET NOCOUNT ON

	DECLARE @SearchID						int
	DECLARE @SearchResultsCount	int
	DECLARE @QueryDetails				varchar(2000)
	DECLARE @ErrorDesc					varchar(2000)
	DECLARE @ShelfLife					smallint
  DECLARE @LimitToUserLibrary	tinyint
  DECLARE @ResultsFolder1			int
  DECLARE @ResultsFolder2			int
	DECLARE @ThisAutorunDate		smalldatetime
  DECLARE @KeepDelete					tinyint
	SET @ThisAutorunDate = CAST(@ThisAutorunDateS AS smalldatetime)

	DECLARE curS CURSOR FOR
	  SELECT SearchID, ShelfLife, LimitToUserLibrary, ResultsFolder2, KeepDelete
		  FROM AJA..SearchSummary
			WHERE AutoSearch	= 1		
						AND UserDB			= @UserDB 

-- AND userid in (1799, 1459)
			ORDER BY UserID

	OPEN curS
	FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete

  WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC ap_SearchExecute 0,
														'',
													  @SearchID,
														1,
														@ShelfLife, 
														@LimitToUserLibrary, 
														@ThisAutorunDate,
														@ResultsFolder1, 
														@ResultsFolder2,
														@UserDB,
														@KeepDelete,
														0,
													  @SearchResultsCount	OUTPUT,
														@QueryDetails				OUTPUT,
														@ErrorDesc					OUTPUT											

			UPDATE AJA..SearchSummary
				SET LastAutorunDate = @ThisAutorunDate,
						LastAutorunHits	= @SearchResultsCount
				WHERE SearchID = @SearchID
--print 'ap_SAS_RunAll3:  @ThisAutorunDate: ' + isnull(cast(@ThisAutorunDate as varchar(40)),'')
--print 'ap_SAS_RunAll3:  @SearchResultsCount: ' + isnull(cast(@SearchResultsCount as varchar(40)),'')
			FETCH NEXT FROM curS INTO @SearchID, @ShelfLife, @LimitToUserLibrary, @ResultsFolder2, @KeepDelete
		END
  CLOSE curS
	DEALLOCATE curS


--print cast(@ResultsFolder2 as varchar(10))
-- Mailing --------------------------------------------------------------
	DECLARE @MailOut				varchar(4000)
	DECLARE @email					nvarchar(50)
	DECLARE @emailLast			nvarchar(50)
	DECLARE @firstname			nvarchar(50)
	DECLARE @lastname				nvarchar(50)
	DECLARE @title					nvarchar(50)
	DECLARE @SpecialtyName	nvarchar(50)
	DECLARE @TopicName			nvarchar(50)
	DECLARE @SubTopicName		nvarchar(50)
	DECLARE @SearchName			varchar(500)
	DECLARE @NewCitations		int
	DECLARE @cr							varchar(20)
	DECLARE @SQL						nvarchar(1000)
  DECLARE @Conclusion			varchar(1000)
  DECLARE @len						int
-- Misc. Initialization -------------------------------------------------
	SET @cr = '\r\n' --CHAR(13) + CHAR(10)
  SET @Conclusion = @cr + 
'To view your saved queries and their new citations, or to ' + 
'change your notification preference, please log on to ' +
'http://www.cogentmedicine.com, and select My Queries from ' + 
'the navigation bar.  Please e-mail us at ' +
'cogent@cogentmedicine.com if you have any questions about ' +
'the Cogent Medicine system.' + @cr + @cr +
'Sincerely,' + @cr + @cr + 
'Brian Goldsmith MD' + @cr + 
'Moderator, Cogent Medicine' + @cr
	SET @emailLast = 'zzzz999919'
	SELECT	0 as SearchID, 
			CAST('' AS varchar(100))		AS 'email',
			CAST('' AS varchar(100))		AS 'firstname',
			CAST('' AS varchar(100))		AS 'lastname',
			CAST('' AS varchar(100))		AS 'searchname',
			CAST('' AS varchar(100))		AS 'SpecialtyName',
			CAST('' AS varchar(100))		AS 'TopicName',
			CAST('' AS varchar(100))		AS 'SubTopicName',
			CAST(0 AS int)		AS 'NewCitations'
		INTO #t 
	DELETE FROM #t		
	SET @SQL = 'INSERT INTO #t ' + 
--	SET @SQL = 
						 'SELECT s.searchid, u.email, firstname, lastname, searchname, SpecialtyName, TopicName, SubTopicName, LastAutorunHits	AS ''NewCitations'' ' +
						 ' FROM ' + @UserDB + '..Users u' + 
						 ' JOIN AJA..SearchSummary s ON s.UserID = u.UserID' + 
						 ' LEFT JOIN ' + @UserDB + '..SubTopics h3 ON h3.SubTopicID = s.ResultsFolder2' + 
						 ' LEFT JOIN ' + @UserDB + '..Topics h2 ON h2.TopicID = h3.TopicID' + 
						 ' LEFT JOIN ' + @UserDB + '..Specialties h1 ON h1.SpecialtyID = h2.SpecialtyID' + 
						 ' WHERE u.email IS NOT NULL		AND' + 
						 --' 			s.LastAutorunHits > 0			AND' + 
						 ' 			s.LastAutorunDate = ''' + CAST(@ThisAutorunDate AS varchar(20)) + '''		AND' + 
						 ' 			AutoSearch	= 1			AND' + 
						 ' 			s.UserDB = ''' + @UserDB + '''		AND' + 
--						 ' u.userid  IN(1799, 1459) 	AND ' + 
						 ' 			u.sasemail = 1'
	EXEC sp_executesql @SQL
--select * from #t


  INSERT INTO AJA..LogSearch
		(SearchID, email, firstname, lastname, searchname, NewCitations)
	  SELECT SearchID, email, firstname, lastname, searchname, NewCitations FROM #t

	DECLARE curM CURSOR FOR
		SELECT SearchID, email, firstname, lastname, SearchName, SpecialtyName, TopicName, SubTopicName, NewCitations FROM #t
			ORDER BY email
	OPEN curM
	FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
  WHILE @@FETCH_STATUS = 0
		BEGIN

			--SET @email = 'andrewxgoodman@gmail.com'
			IF @emailLast <> @email
				BEGIN
					IF @emailLast <> 'zzzz999919'
						BEGIN
							SET @MailOut = @MailOut + @Conclusion + '"'
							EXEC master..xp_cmdshell @MailOut
						END
					SET @MailOut = 'postie -host:192.168.36.33 -to:' + 
												 @email + 
												 ' -from:cogent@cogentmedicine.com ' + 
												 ' -s:"Cogent Medicine AutoQuery Update"' + 
												 ' -msg:"Dear ' + 
												 @firstname + ' ' + @lastname + ':' + @cr + @cr +
												 'Your AutoQuery status this week:' + @cr + @cr
					SET @emailLast = @email
				END
		  IF @SpecialtyName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SpecialtyName)
					SET @SpecialtyName = SUBSTRING(@SpecialtyName,1,20)
					IF LEN(@SpecialtyName) <> @len
					  BEGIN
					    SET @SpecialtyName = REVERSE(@SpecialtyName)
						  SET @len = CHARINDEX(' ',@SpecialtyName)
						  IF @Len = 0
								  SET @SpecialtyName = REVERSE(@SpecialtyName) + '...'
						  ELSE
									SET @SpecialtyName = REVERSE(SUBSTRING(@SpecialtyName,@len+1,99)) + '...'
						END
				END
		  IF @TopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@TopicName)
					SET @TopicName = SUBSTRING(@TopicName,1,20)
					IF LEN(@TopicName) <> @len
					  BEGIN
					    SET @TopicName = REVERSE(@TopicName)
						  SET @len = CHARINDEX(' ',@TopicName)
						  IF @Len = 0
								  SET @TopicName = REVERSE(@TopicName) + '...'
						  ELSE
									SET @TopicName = REVERSE(SUBSTRING(@TopicName,@len+1,99)) + '...'
						END
				END
		  IF @SubTopicName IS NOT NULL
			  BEGIN
					SET @len = LEN(@SubTopicName)
					SET @SubTopicName = SUBSTRING(@SubTopicName,1,20)
					IF LEN(@SubTopicName) <> @len
					  BEGIN
					    SET @SubTopicName = REVERSE(@SubTopicName)
						  SET @len = CHARINDEX(' ',@SubTopicName)
						  IF @Len = 0
								  SET @SubTopicName = REVERSE(@SubTopicName) + '...'
						  ELSE
									SET @SubTopicName = REVERSE(SUBSTRING(@SubTopicName,@len+1,99)) + '...'
						END
				END
			SET @MailOut = @MailOut + 'Query Title: ' + @SearchName + @cr + 
										'Destination folder: ' + ISNULL(@SpecialtyName + '>','') + @TopicName + '>' + @SubTopicName + @cr +
										 CAST(@NewCitations AS varchar(10)) + ' citations' + @cr  + @cr

			FETCH NEXT FROM curM INTO @SearchID, @email, @firstname, @lastname, @SearchName, @SpecialtyName, @TopicName, @SubTopicName, @NewCitations
		END
  CLOSE curM

	DEALLOCATE curM
	DROP TABLE #t
	IF @emailLast <> 'zzzz999919'
	  BEGIN
			SET @MailOut = @MailOut + @Conclusion + '"'
			EXEC master..xp_cmdshell @MailOut
print @MailOut


		END
GO


/* End Stored Procedures */

--------------- Bug 8169 Fixed Author name Display ----
USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID]    Script Date: 11/26/2013 17:33:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ap_DisplayPMID]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate, ViewPMID) SELECT @UserID, 0, GETDATE(), PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2 '

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT distinct t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps ,sa , st ,sj,Seq '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
		  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp

  USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID_AJA_Dev]    Script Date: 11/26/2013 17:33:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ap_DisplayPMID_AJA_Dev]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate,ViewCountSummary, ViewPMID) SELECT @UserID, 0, GETDATE(),0, PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2 '

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT distinct t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps ,sa , st ,sj,Seq '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
	--	  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp


  USE [Cogent3]
GO
/****** Object:  StoredProcedure [dbo].[ap_DisplayPMID_AJA_Dev_Detailed]    Script Date: 11/26/2013 17:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ap_DisplayPMID_AJA_Dev_Detailed]
  @UserID					int,
	@PMIDList				varchar(max),
  @DisplayMode		int,  --1: Summary; 2: Full
  @SearchSort			tinyint
AS
  DECLARE @Pos				int
  DECLARE @PMIDThis		varchar(20)
  DECLARE @SQL				nvarchar(max)
  Declare @PMIDLength int
  
  SET NOCOUNT ON
	CREATE TABLE #tp (PMID int)
	SET @PMIDList = @PMIDList + ','
	SET @Pos = CHARINDEX(',',@PMIDList)
    set @PMIDLength = DATALENGTH(@PMIDList)
  WHILE @Pos > 0
		BEGIN
			SET @PMIDThis = LEFT(@PMIDList,@Pos-1)
			INSERT INTO #tp (PMID) VALUES (CAST(@PMIDThis AS int) )
			SET @PMIDList = SUBSTRING(@PMIDList,@Pos+1,@PMIDLength)
			SET @Pos = CHARINDEX(',',@PMIDList)
			
		END

  INSERT INTO AJA..SearchView (UserID, SearchID, ViewDate,ViewCountSummary, ViewPMID) SELECT @UserID, 0, GETDATE(),0, PMID FROM #tp
	SET @SQL = 'SELECT t.PMID,ISNULL(w.ArticleTitle,wn.ArticleTitle) AS ArticleTitle,AuthorList,MedlineTA,MedlinePgn,DisplayDate,DisplayNotes,StatusDisplay,dps '

  IF @DisplayMode = 2
		SET @SQL = @SQL + ',ISNULL(w.AbstractText,wn.AbstractText) AS AbstractText, ' + 
											' '''' AS AbstractText2 '

	SET @SQL = @SQL +	' FROM #tp t ' +
										' LEFT JOIN iCitation c ON t.PMID = c.PMID ' + 
										' LEFT JOIN xCitationStatus xcs ON xcs.StatusID = c.StatusID ' + 
										' LEFT JOIN iCitationScreen cs ON cs.PMID = c.PMID '

		SET @SQL = @SQL + ' LEFT JOIN iWide w ON w.PMID = c.PMID '
		SET @SQL = @SQL + ' LEFT JOIN iWideNew wn ON wn.PMID = c.PMID '

  IF @SearchSort = 1
	  SET @SQL = @SQL + ' ORDER BY dps DESC'
  IF @SearchSort = 2
	  SET @SQL = @SQL + ' ORDER BY sa'
  IF @SearchSort = 3
	  SET @SQL = @SQL + ' ORDER BY st'
  IF @SearchSort = 4
	  SET @SQL = @SQL + ' ORDER BY sj'
--  EXEC sp_executesql @SQL

  IF @DisplayMode = 2
		BEGIN
			SET @SQL = 'SELECT distinct t.PMID, RTRIM(LastName + '' '' + Initial1 + Initial2)  AS DisplayName, dps ,sa , st ,sj,Seq '+
								  ' FROM #tp t' + 
									' LEFT JOIN iAuthor a ON a.PMID = t.PMID' + 
									' LEFT JOIN xCollectiveName c ON c.CollectiveNameID = a.CollectiveNameID ' + 
									' LEFT JOIN xLastName l ON l.LastNameID = a.LastNameID AND a.LastNameID <> 0 ' + 
									' LEFT JOIN iCitationScreen cs ON cs.PMID = t.PMID '
		  IF @SearchSort = 1
			  SET @SQL = @SQL + ' ORDER BY dps DESC'
		  IF @SearchSort = 2
			  SET @SQL = @SQL + ' ORDER BY sa'
		  IF @SearchSort = 3
			  SET @SQL = @SQL + ' ORDER BY st'
		  IF @SearchSort = 4
			  SET @SQL = @SQL + ' ORDER BY sj'
			SET @SQL = @SQL + 	' ,t.PMID, Seq  '
			  
			--SET @SQL = @SQL + 	' ,t.PMID, CASE WHEN  a.CollectiveNameID = 0 THEN Seq ELSE 999 END '
		  EXEC sp_executesql @SQL
		END


  DROP TABLE #tp
 
 ---- End of Bug 8169 ----