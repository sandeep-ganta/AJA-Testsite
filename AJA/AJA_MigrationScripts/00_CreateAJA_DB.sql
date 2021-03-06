USE [AJA]
GO
/****** Object:  Table [dbo].[Tests]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tests](
	[TestID] [int] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Summary] [ntext] NOT NULL,
 CONSTRAINT [PK_Tests] PRIMARY KEY CLUSTERED 
(
	[TestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SponsorTopics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SponsorTopics](
	[SponsorID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[Relevance] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SponsorFolderBackup20051014]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SponsorFolderBackup20051014](
	[id] [int] NOT NULL,
	[FolderName] [varchar](50) NULL,
	[QueryId] [int] NULL,
	[LinkText] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SponsorFolder]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SponsorFolder](
	[id] [int] NOT NULL,
	[FolderName] [varchar](50) NULL,
	[QueryId] [int] NULL,
	[LinkText] [varchar](50) NULL,
 CONSTRAINT [PK_SponsorFolder] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SponsorCitations]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SponsorCitations](
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
 CONSTRAINT [PK_SponsorCitations] PRIMARY KEY CLUSTERED 
(
	[SubTopicID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SponsorCitation]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SponsorCitation](
	[SponsorFolderId] [int] NOT NULL,
	[pmid] [int] NOT NULL,
 CONSTRAINT [PK_SponsorCitation] PRIMARY KEY CLUSTERED 
(
	[SponsorFolderId] ASC,
	[pmid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SpecialtyBanner]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecialtyBanner](
	[SpecialtyId] [int] NOT NULL,
	[BannerId] [int] NOT NULL,
	[BannerPercentage] [int] NULL,
 CONSTRAINT [PK_SpecialtyBanner] PRIMARY KEY CLUSTERED 
(
	[SpecialtyId] ASC,
	[BannerId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Specialties]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Specialties](
	[SpecialtyID] [int] NOT NULL,
	[SpecialtyName] [nvarchar](50) NULL,
	[isInUse] [bit] NOT NULL,
 CONSTRAINT [PK_Specialties] PRIMARY KEY CLUSTERED 
(
	[SpecialtyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SeminalCitations]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SeminalCitations](
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
 CONSTRAINT [PK_SeminalCitations] PRIMARY KEY CLUSTERED 
(
	[SubTopicID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SearchView]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchView](
	[UserID] [int] NOT NULL,
	[SearchID] [int] NOT NULL,
	[ViewDate] [datetime] NOT NULL,
	[ViewCountSummary] [int] NOT NULL,
	[ViewPMID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SearchSummary]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SearchSummary](
	[SearchID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[SearchName] [varchar](100) NOT NULL,
	[RunOriginal] [datetime] NOT NULL,
	[FoundOriginal] [int] NOT NULL,
	[RunLast] [datetime] NOT NULL,
	[FoundLast] [int] NOT NULL,
	[PublicationTypeMask] [smallint] NOT NULL,
	[LanguageMask] [tinyint] NOT NULL,
	[SpeciesMask] [tinyint] NOT NULL,
	[GenderMask] [tinyint] NOT NULL,
	[SubjectAgeMask] [smallint] NOT NULL,
	[DateStart] [smalldatetime] NOT NULL,
	[DateEnd] [smalldatetime] NOT NULL,
	[AbstractMask] [tinyint] NOT NULL,
	[PaperAge] [tinyint] NOT NULL,
	[SearchSort] [tinyint] NOT NULL,
	[FastFullText] [tinyint] NOT NULL,
	[ShelfLife] [smallint] NOT NULL,
	[Description] [varchar](500) NULL,
	[LastAutorunHits] [int] NOT NULL,
	[LimitToUserLibrary] [tinyint] NOT NULL,
	[LastAutorunDate] [smalldatetime] NULL,
	[ResultsFolder1] [int] NOT NULL,
	[ResultsFolder2] [int] NOT NULL,
	[Autosearch] [tinyint] NOT NULL,
	[UserDB] [varchar](50) NULL,
	[KeepDelete] [tinyint] NOT NULL,
 CONSTRAINT [PK_SearchSummary] PRIMARY KEY NONCLUSTERED 
(
	[SearchID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SearchResults]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchResults](
	[SearchID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
	[List] [int] NOT NULL,
 CONSTRAINT [PK_SearchResults] PRIMARY KEY CLUSTERED 
(
	[SearchID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserComment]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserComment](
	[userid] [int] NOT NULL,
	[pmid] [int] NOT NULL,
	[nickname] [varchar](64) NULL,
	[comment] [varchar](1024) NULL,
	[updatedate] [datetime] NULL,
	[createdate] [datetime] NULL,
 CONSTRAINT [PK_UserComment] PRIMARY KEY CLUSTERED 
(
	[userid] ASC,
	[pmid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserCitationSurvey]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCitationSurvey](
	[PMID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [pk_UserCitationSurvey] PRIMARY KEY CLUSTERED 
(
	[PMID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserCitationsSubtopicIDZeroBackup]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCitationsSubtopicIDZeroBackup](
	[UserID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[IsAutoQueryCitation] [bit] NOT NULL,
	[SearchID] [int] NOT NULL,
	[ExpireDate] [smalldatetime] NOT NULL,
	[KeepDelete] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserCitations]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCitations](
	[UserID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[IsAutoQueryCitation] [bit] NOT NULL,
	[SearchID] [int] NOT NULL,
	[ExpireDate] [smalldatetime] NOT NULL,
	[KeepDelete] [bit] NOT NULL,
 CONSTRAINT [PK_UserCitations] PRIMARY KEY NONCLUSTERED 
(
	[UserID] ASC,
	[SubTopicID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_orginal]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_orginal](
	[userID] [int] IDENTITY(10000,1) NOT NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[title] [nvarchar](50) NULL,
	[specialtyid] [int] NULL,
	[countryID] [int] NULL,
	[postalCode] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[userName] [nvarchar](50) NOT NULL,
	[password] [nvarchar](50) NULL,
	[userType] [nvarchar](50) NULL,
	[graduationYear] [int] NULL,
	[yrsPractice] [nvarchar](50) NULL,
	[typePractice] [nvarchar](50) NULL,
	[profession] [nvarchar](50) NULL,
	[sendEmail] [bit] NOT NULL,
	[DateAdded] [char](10) NULL,
	[sasemail] [smallint] NOT NULL,
	[deleted_ind] [nchar](1) NULL,
	[surveyValidated] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TypePractice]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypePractice](
	[id] [int] NOT NULL,
	[TypePractice] [nvarchar](50) NULL,
 CONSTRAINT [PK_TypePractice] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Topics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Topics](
	[TopicID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[Type] [tinyint] NOT NULL,
	[UserID] [int] NULL,
	[TopicName] [nvarchar](50) NOT NULL,
	[createtime] [datetime] NOT NULL,
	[LegacyID] [int] NULL,
 CONSTRAINT [PK_Topics] PRIMARY KEY CLUSTERED 
(
	[TopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SearchDetails]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SearchDetails](
	[SearchID] [int] NOT NULL,
	[Seq] [tinyint] NOT NULL,
	[Op] [char](3) NOT NULL,
	[Terms] [varchar](400) NOT NULL,
	[Tab] [varchar](35) NOT NULL,
 CONSTRAINT [PK_SearchDetails] PRIMARY KEY CLUSTERED 
(
	[SearchID] ASC,
	[Seq] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SearchControl]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SearchControl](
	[Setting] [varchar](100) NOT NULL,
	[Value] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Results]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Results](
	[ColumnName] [nvarchar](370) NULL,
	[ColumnValue] [nvarchar](3630) NULL
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[RemoveNonASCII]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  Table [dbo].[RecipientLists]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecipientLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AdminID] [int] NOT NULL,
	[Specialty] [int] NOT NULL,
	[CreateDate] [smalldatetime] NULL,
	[MailingDate] [smalldatetime] NULL,
	[Type] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserSpecialties]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSpecialties](
	[UserID] [int] NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[DateAdded] [datetime] NOT NULL,
 CONSTRAINT [PK_UserSpecialties] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[SpecialtyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[userID] [int] IDENTITY(10000,1) NOT NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[title] [nvarchar](50) NULL,
	[specialtyid] [int] NULL,
	[countryID] [int] NULL,
	[postalCode] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[userName] [nvarchar](50) NOT NULL,
	[password] [nvarchar](50) NULL,
	[userType] [nvarchar](50) NULL,
	[graduationYear] [int] NULL,
	[yrsPractice] [nvarchar](50) NULL,
	[typePractice] [nvarchar](50) NULL,
	[profession] [nvarchar](50) NULL,
	[sendEmail] [bit] NOT NULL,
	[DateAdded] [char](10) NULL,
	[sasemail] [smallint] NOT NULL,
	[deleted_ind] [nchar](1) NULL,
	[surveyValidated] [bit] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserPreferences]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPreferences](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[OrgFolderID] [int] NULL,
	[OrgFolderName] [nvarchar](50) NULL,
	[FunFolderID] [int] NULL,
	[FunFolderName] [nvarchar](50) NULL,
	[MedlineID] [int] NULL,
	[SearchString] [ntext] NULL,
	[DateAdded] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserHasSponsorTopic]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserHasSponsorTopic](
	[UserID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[CreatedOn] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserHasSponsorFolder]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserHasSponsorFolder](
	[UserId] [int] NOT NULL,
	[SponsorFolderId] [int] NOT NULL,
	[UserFolderId] [int] NULL,
	[AutoQueryId] [int] NULL,
	[createtime] [datetime] NULL,
 CONSTRAINT [PK_UserHasSponsorFolder] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[SponsorFolderId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserDBs]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserDBs](
	[ConnectionString] [varchar](256) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CNID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UserDBs] PRIMARY KEY CLUSTERED 
(
	[ConnectionString] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Genes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Genes](
	[GeneID] [bigint] NOT NULL,
	[Name] [varchar](10) NOT NULL,
	[Symbol] [varchar](10) NULL,
	[FullName] [varchar](500) NULL,
	[Summary] [text] NOT NULL,
 CONSTRAINT [PK_Genes] PRIMARY KEY CLUSTERED 
(
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IIS_LogStage]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IIS_LogStage](
	[HitDate] [datetime] NULL,
	[HitTime] [datetime] NULL,
	[IP1] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[IP2] [varchar](50) NULL,
	[Port] [int] NULL,
	[Method] [varchar](50) NULL,
	[URL] [varchar](200) NULL,
	[Args] [varchar](500) NULL,
	[Status] [int] NULL,
	[Other] [varchar](500) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IIS_LogDistinctHitDateIP2]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IIS_LogDistinctHitDateIP2](
	[HitDate] [datetime] NULL,
	[IP1] [varchar](50) NULL,
	[PriorHitDate] [datetime] NULL,
	[Seq] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IIS_LogDistinctHitDateIP]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IIS_LogDistinctHitDateIP](
	[HitDate] [datetime] NULL,
	[IP1] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IIS_LogAnalysis]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IIS_LogAnalysis](
	[HitDate] [datetime] NULL,
	[IP1] [varchar](50) NULL,
	[URL] [varchar](200) NULL,
	[Args] [varchar](500) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HiddenTopics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HiddenTopics](
	[TopicID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_HiddenTopics] PRIMARY KEY CLUSTERED 
(
	[TopicID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HiddenSubTopics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HiddenSubTopics](
	[SubTopicID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_HiddenSubTopics] PRIMARY KEY CLUSTERED 
(
	[SubTopicID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CitationRate]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CitationRate](
	[PMID] [int] NOT NULL,
	[UsersNumber] [int] NOT NULL,
	[ImpactScores] [int] NOT NULL,
	[PracticalityScores] [int] NOT NULL,
	[EffectPoint1Voices] [int] NOT NULL,
	[EffectPoint2Voices] [int] NOT NULL,
	[EffectPoint3Voices] [int] NOT NULL,
 CONSTRAINT [pk_CitationRate] PRIMARY KEY CLUSTERED 
(
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[iWideNew_temp]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[iWideNew_temp](
	[PMID] [int] NOT NULL,
	[ArticleTitle] [text] NULL,
	[AbstractText] [text] NULL,
	[CopyrightInformation] [text] NULL,
	[VernacularTitle] [text] NULL,
	[Affiliation] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[iWide_temp]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[iWide_temp](
	[PMID] [int] NOT NULL,
	[ArticleTitle] [text] NULL,
	[AbstractText] [text] NULL,
	[CopyrightInformation] [text] NULL,
	[VernacularTitle] [text] NULL,
	[Affiliation] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[lib_GetGeneLinksByGeneID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[preLep_SponsorFolder]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[preLep_SponsorFolder](
	[UserId] [int] NOT NULL,
	[SponsorFolderId] [int] NOT NULL,
	[UserFolderId] [int] NULL,
	[AutoQueryId] [int] NULL,
	[createtime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PageTracking]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PageTracking](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[URL] [varchar](200) NOT NULL,
	[Arguments] [varchar](200) NULL,
	[DateStamp] [datetime] NULL,
 CONSTRAINT [PK_PageTracking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OutOfRangeUser]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OutOfRangeUser](
	[UserID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[IsAutoQueryCitation] [bit] NOT NULL,
	[SearchID] [int] NOT NULL,
	[ExpireDate] [smalldatetime] NOT NULL,
	[KeepDelete] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OutOfRangeSeminal]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OutOfRangeSeminal](
	[SubTopicID] [int] NOT NULL,
	[PMID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NonMedlineCitations]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NonMedlineCitations](
	[PMID] [int] NOT NULL,
	[ArticleTitle] [nvarchar](max) NULL,
	[AuthorList] [nvarchar](max) NULL,
	[Abstract] [nvarchar](max) NULL,
	[CitationDate] [datetime] NULL,
	[DisplayDate] [nvarchar](250) NULL,
	[DisplayNotes] [nvarchar](250) NULL,
	[ExpireDate] [datetime] NULL,
	[KeepDelete] [nvarchar](50) NULL,
	[MedlinePgn] [nvarchar](500) NULL,
	[MedlineTA] [nvarchar](500) NULL,
	[Nickname] [varchar](100) NULL,
	[SearchID] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[StatusDisplay] [varchar](100) NULL,
	[dps]  AS (CONVERT([int],[CitationDate],(0))-(21914)),
 CONSTRAINT [PK_NonMedlineCitations] PRIMARY KEY CLUSTERED 
(
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NoiseWord]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NoiseWord](
	[Word] [varchar](50) NOT NULL,
 CONSTRAINT [PK_NoiseWord] PRIMARY KEY CLUSTERED 
(
	[Word] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LogSearch]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogSearch](
	[LogSearchID] [int] IDENTITY(1,1) NOT NULL,
	[RunTime] [datetime] NOT NULL,
	[SearchID] [int] NOT NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[SearchName] [varchar](500) NULL,
	[NewCitations] [int] NOT NULL,
	[email] [varchar](50) NULL,
 CONSTRAINT [PK_LogSearch] PRIMARY KEY CLUSTERED 
(
	[LogSearchID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkOutSubjects]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkOutSubjects](
	[SubjectText] [varchar](80) NOT NULL,
	[LinkID] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkOutQueries]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkOutQueries](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[PMID] [int] NOT NULL,
	[RequestType] [smallint] NOT NULL,
	[RequestDate] [datetime] NOT NULL,
	[UserID] [int] NOT NULL,
	[IsCacheHit] [bit] NOT NULL,
	[CanQuery] [bit] NULL,
	[IsComplete] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LinkOutProviders]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkOutProviders](
	[ProviderID] [int] NOT NULL,
	[ProviderName] [varchar](80) NOT NULL,
	[ProviderURL] [varchar](255) NOT NULL,
	[IconURL] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkOutLinks]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkOutLinks](
	[LinkID] [int] IDENTITY(1,1) NOT NULL,
	[PMID] [int] NOT NULL,
	[RequestType] [smallint] NOT NULL,
	[URL] [varchar](255) NOT NULL,
	[LinkName] [varchar](80) NULL,
	[ProviderID] [int] NULL,
	[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LinkOutControl]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkOutControl](
	[ControlID] [int] NOT NULL,
	[MaxCacheSeconds] [int] NOT NULL,
	[MinRequestWaitMS] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LinkOutAttributes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LinkOutAttributes](
	[AttributeText] [varchar](80) NOT NULL,
	[LinkID] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TempUserTable]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempUserTable](
	[userid] [int] NULL,
	[specialtyid] [int] NULL,
	[postalCode] [nvarchar](50) NULL,
	[PracticeType] [nvarchar](50) NULL,
	[graduationYear] [int] NULL,
	[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblLinkout_trace_13904]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLinkout_trace_13904](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[CPU] [int] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[Duration] [bigint] NULL,
	[ClientProcessID] [int] NULL,
	[SPID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[BinaryData] [image] NULL,
	[EventSequence] [bigint] NULL,
	[GroupID] [int] NULL,
	[HostName] [nvarchar](128) NULL,
	[IsSystem] [int] NULL,
	[LoginSid] [image] NULL,
	[NTDomainName] [nvarchar](128) NULL,
	[ObjectName] [nvarchar](128) NULL,
	[RequestID] [int] NULL,
	[ServerName] [nvarchar](128) NULL,
	[SessionLoginName] [nvarchar](128) NULL,
	[TransactionID] [bigint] NULL,
	[XactSequence] [bigint] NULL,
	[ObjectID] [int] NULL,
	[ObjectType] [int] NULL,
	[LineNumber] [int] NULL,
	[NestLevel] [int] NULL,
	[RowCounts] [bigint] NULL,
	[SourceDatabaseID] [int] NULL,
	[IntegerData] [int] NULL,
	[IntegerData2] [int] NULL,
	[Offset] [int] NULL,
	[State] [int] NULL,
	[Handle] [int] NULL,
	[EventSubClass] [int] NULL,
	[SqlHandle] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Survey]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Survey](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [pk_Survey] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubTopics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubTopics](
	[SubTopicID] [int] IDENTITY(1,1) NOT NULL,
	[TopicID] [int] NOT NULL,
	[Type] [tinyint] NOT NULL,
	[UserID] [int] NULL,
	[SubTopicName] [nvarchar](50) NOT NULL,
	[createtime] [datetime] NOT NULL,
	[LegacyID] [int] NULL,
	[Priority] [tinyint] NOT NULL,
 CONSTRAINT [PK_SubTopics] PRIMARY KEY CLUSTERED 
(
	[SubTopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Editions]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Editions](
	[EditionID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[PubDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Editions] PRIMARY KEY CLUSTERED 
(
	[EditionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_sched_opt]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[doc_sched_opt](
	[cd] [varchar](128) NOT NULL,
	[val] [varchar](512) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [ntext] NOT NULL,
 CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EditorTopics]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EditorTopics](
	[EditorID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[StartDate] [smalldatetime] NULL,
	[RetireDate] [smalldatetime] NULL,
 CONSTRAINT [PK_EditorTopics] PRIMARY KEY CLUSTERED 
(
	[EditorID] ASC,
	[TopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CampImportTemp]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampImportTemp](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[MarID] [char](6) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[PostalCode] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](50) NULL,
	[Specialty] [nvarchar](50) NOT NULL,
	[Profession] [nvarchar](50) NOT NULL,
	[PracticeEnvironment] [nvarchar](50) NOT NULL,
 CONSTRAINT [pk_CampImportTemp] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClickThru]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClickThru](
	[id] [int] NOT NULL,
	[bannerid] [int] NULL,
	[userid] [int] NULL,
	[refurl] [nvarchar](1024) NULL,
	[createtime] [datetime] NULL,
 CONSTRAINT [PK_ClickThru] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EditorialThreads]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EditorialThreads](
	[ThreadID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalPubDate] [smalldatetime] NOT NULL,
	[ThreadName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_EditorialThread] PRIMARY KEY CLUSTERED 
(
	[ThreadID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Campaigns]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaigns](
	[CampaignID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](24) NOT NULL,
	[Owner] [nvarchar](32) NOT NULL,
	[StartDate] [smalldatetime] NULL,
	[EndDate] [smalldatetime] NULL,
 CONSTRAINT [pk_Campaigns] PRIMARY KEY CLUSTERED 
(
	[CampaignID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Banner]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Banner](
	[id] [int] NOT NULL,
	[Nickname] [varchar](50) NULL,
	[SponsorFolderId] [int] NULL,
	[url] [varchar](512) NULL,
	[FileName] [varchar](50) NULL,
	[Comment] [varchar](500) NULL,
	[width] [int] NULL,
	[height] [int] NULL,
	[IsTargetNew] [tinyint] NULL,
	[IsInternal] [tinyint] NULL,
 CONSTRAINT [PK_Banner] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Autoquerydetails]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Autoquerydetails](
	[SearchID] [float] NOT NULL,
	[email] [nvarchar](255) NULL,
	[firstname] [nvarchar](255) NULL,
	[lastname] [nvarchar](255) NULL,
	[searchname] [nvarchar](255) NULL,
	[SpecialtyName] [nvarchar](255) NULL,
	[TopicName] [nvarchar](255) NULL,
	[SubTopicName] [nvarchar](255) NULL,
	[NewCitations] [float] NULL,
 CONSTRAINT [PK_Autoquerydetails] PRIMARY KEY CLUSTERED 
(
	[SearchID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AtLargeEditors]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AtLargeEditors](
	[EditorID] [int] NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[RetireDate] [datetime] NULL,
 CONSTRAINT [PK_AtLargeEditors] PRIMARY KEY CLUSTERED 
(
	[EditorID] ASC,
	[SpecialtyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AdminUsers]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdminUsers](
	[AdminID] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[PrivManageUsers] [char](1) NOT NULL,
	[PrivViewUserReports] [char](1) NOT NULL,
	[PrivSubscriptionStatus] [char](1) NOT NULL,
	[PrivWebTrends] [char](1) NOT NULL,
	[PrivRepairLib] [char](1) NOT NULL,
	[PrivBannerDisplay] [char](1) NOT NULL,
 CONSTRAINT [PK_AdminUsers] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[doc]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[doc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source] [varchar](512) NOT NULL,
	[nm] [varchar](256) NOT NULL,
	[last_updated_dt] [datetime] NOT NULL,
	[auto_upd] [varchar](5) NOT NULL,
	[clicks_count] [int] NOT NULL,
 CONSTRAINT [PK_doc] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[debug_tblTrackSearchAdd]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[debug_tblTrackSearchAdd](
	[AttemptID] [int] IDENTITY(1,1) NOT NULL,
	[SearchName] [varchar](100) NOT NULL,
	[UserID] [int] NOT NULL,
	[UserDB] [varchar](50) NOT NULL,
	[RecCount] [int] NOT NULL,
	[TimeOfAttempt] [smalldatetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomMailHeader]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomMailHeader](
	[Order] [int] NULL,
	[FileName] [varchar](50) NOT NULL,
	[Description] [varchar](80) NOT NULL,
 CONSTRAINT [PK_CustomMailHeader] PRIMARY KEY CLUSTERED 
(
	[FileName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[countryID] [int] NOT NULL,
	[countryName] [nvarchar](255) NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[countryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoreSponsorAds]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoreSponsorAds](
	[BannerID] [int] NOT NULL,
	[PlacementID] [int] NOT NULL,
	[ImpressionPercentage] [float] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BannerID] ASC,
	[PlacementID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CommentAuthors]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommentAuthors](
	[id] [int] IDENTITY(45,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[affiliations] [nvarchar](1000) NULL,
	[email] [nvarchar](128) NULL,
 CONSTRAINT [PK_Editor] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AJA_tbl_Roles]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AJA_tbl_Roles](
	[RoleID] [int] IDENTITY(0,1) NOT NULL,
	[RoleName] [varchar](20) NOT NULL,
 CONSTRAINT [PK_AJA_tbl_Roles_RoleID] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AJA_tbl_FieldTypes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[AJA_tbl_FieldTypes](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](50) NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_AJA_tbl_ConTrolType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AJA_tbl_Users]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AJA_tbl_Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[EmailID] [varchar](150) NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](150) NOT NULL,
	[Activated] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[Fname] [nvarchar](50) NULL,
	[Lname] [nvarchar](50) NULL,
	[Pincode] [nvarchar](50) NULL,
	[specialtyID] [int] NULL,
	[CountryID] [int] NULL,
	[graduationYear] [int] NULL,
	[profession] [nvarchar](50) NULL,
	[typePracticeID] [int] NULL,
	[UserTitle] [nvarchar](50) NULL,
	[IseditorEmaiSend] [bit] NOT NULL,
	[IsSavedAqemaisend] [bit] NULL,
	[deleted_ind] [nvarchar](1) NULL,
	[surveyValidated] [bit] NULL,
	[userType] [nvarchar](50) NULL,
	[yrsPractice] [nvarchar](50) NULL,
 CONSTRAINT [PK_AJA_tbl_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CampAuthorizations]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampAuthorizations](
	[AuthID] [int] IDENTITY(1,1) NOT NULL,
	[CampaignID] [int] NULL,
	[AuthType] [char](1) NULL,
 CONSTRAINT [pk_CampAuthorizations] PRIMARY KEY CLUSTERED 
(
	[AuthID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AJA_tbl_UserRoles]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AJA_tbl_UserRoles](
	[UserID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_AJA_tbl_UserRoles_UserIDRoleID] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AJA_tbl_UserFields]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[AJA_tbl_UserFields](
	[UserFieldID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NOT NULL,
	[FieldName] [varchar](150) NULL,
	[TypeID] [int] NULL,
	[ShowOrder] [int] NULL,
	[IsActive] [bit] NULL,
	[IsMandatory] [bit] NULL,
	[DisplayYN] [bit] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_AJA_tbl_UserFields] PRIMARY KEY CLUSTERED 
(
	[UserFieldID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[adm_GetLibrarySubTopics]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_GetEditionTopics]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_GetEditions]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_GetEditionDetails]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  Table [dbo].[ArticleSelections]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticleSelections](
	[ThreadID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_ArticleSelections] PRIMARY KEY CLUSTERED 
(
	[ThreadID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EditorialCommentsTests]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EditorialCommentsTests](
	[CommentID] [int] NOT NULL,
	[TestID] [int] NOT NULL,
 CONSTRAINT [PK_EditorialCommentsTests] PRIMARY KEY NONCLUSTERED 
(
	[CommentID] ASC,
	[TestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EditorialCommentsGenes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EditorialCommentsGenes](
	[CommentID] [int] NOT NULL,
	[GeneID] [bigint] NOT NULL,
 CONSTRAINT [PK_EditorialCommentsGenes] PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC,
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EditorialComments]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EditorialComments](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[ThreadID] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[Comment] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_EditorialComments] PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_in_subtopic]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_in_subtopic](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[subtopic_id] [int] NOT NULL,
	[doc_id] [int] NOT NULL,
 CONSTRAINT [PK_UserACRDocuments] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CitationsTests]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CitationsTests](
	[TestID] [int] NOT NULL,
	[PMID] [int] NOT NULL,
 CONSTRAINT [PK_SeminalCitationsTests] PRIMARY KEY NONCLUSTERED 
(
	[TestID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CitationsGenes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CitationsGenes](
	[GeneID] [bigint] NOT NULL,
	[PMID] [int] NOT NULL,
 CONSTRAINT [PK_SeminalCitationsGenes] PRIMARY KEY CLUSTERED 
(
	[GeneID] ASC,
	[PMID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[ap_SearchFetchPMID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[ExcludedRecipients]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcludedRecipients](
	[ListID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ListID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[EditorsChoiceAuth]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EditorsChoiceAuth](
	[AdminID] [int] NOT NULL,
	[SpecialtyID] [int] NOT NULL,
 CONSTRAINT [PK__EditorsChoiceAut__25869641] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC,
	[SpecialtyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubTopicReferences]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubTopicReferences](
	[EditionID] [int] NOT NULL,
	[ThreadID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
 CONSTRAINT [PK_SubTopicReference] PRIMARY KEY CLUSTERED 
(
	[EditionID] ASC,
	[ThreadID] ASC,
	[SubTopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubTopicEditorRefs]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubTopicEditorRefs](
	[EditionID] [int] NOT NULL,
	[ThreadID] [int] NOT NULL,
	[EditorID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[Seniority] [int] NOT NULL,
 CONSTRAINT [PK_SubTopicEditorRef] PRIMARY KEY CLUSTERED 
(
	[EditionID] ASC,
	[ThreadID] ASC,
	[EditorID] ASC,
	[TopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[lib_RemoveSponsorTopic]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_KeepCitationsBySearch]    Script Date: 12/09/2013 11:15:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_KeepCitationsBySearch]
	@SearchID INT,
	@UserID INT
AS
BEGIN
	UPDATE UserCitations SET IsAutoQueryCitation = 0
	WHERE UserID = @UserID
	AND Searchid = @SearchID 
	and IsAutoQueryCitation = 1
	and Deleted = 0
END
GO
/****** Object:  StoredProcedure [dbo].[lib_GetNonMedlineCitation]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSponsorCitations]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSponCitExtraInfo]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSeminalCitations]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSemCitExtraInfo]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSearchCitationList]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetSavedCitationList]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetUserSubTopics]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetUnsubscribedSpecialties]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetDefaultSubTopic]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[IncludedRecipients]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncludedRecipients](
	[ListID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[Email] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ListID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GeneAliases]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneAliases](
	[GeneID] [bigint] NOT NULL,
	[AliasID] [int] NOT NULL,
	[AliasName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_GeneAliases] PRIMARY KEY CLUSTERED 
(
	[GeneID] ASC,
	[AliasID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[lib_DeleteUserAutoQueries]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_DeleteSearchesFromSubTopic]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_DeleteCitationsBySearch]    Script Date: 12/09/2013 11:15:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[lib_DeleteCitationsBySearch]
	@UserID INT,
	@SearchID INT
AS
BEGIN
	UPDATE UserCitations SET Deleted = 1
	WHERE UserID = @UserID
	AND SearchID = @SearchID 
	AND IsAutoQueryCitation = 1
END
GO
/****** Object:  StoredProcedure [dbo].[lib_CreateSponsorFolderSFE]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_CopyUserCitation_MyQueries]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_CopyUserCitation]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[GenesLinks]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GenesLinks](
	[GeneID] [bigint] NOT NULL,
	[LinkID] [int] NOT NULL,
	[Link] [varchar](4000) NOT NULL,
 CONSTRAINT [PK_GenesLinks] PRIMARY KEY NONCLUSTERED 
(
	[GeneID] ASC,
	[LinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GenesArticles]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GenesArticles](
	[GeneID] [bigint] NOT NULL,
	[ArticleID] [int] NOT NULL,
	[ArticleTitle] [varchar](300) NOT NULL,
	[Year] [int] NOT NULL,
 CONSTRAINT [PK_GenesArticles] PRIMARY KEY NONCLUSTERED 
(
	[ArticleID] ASC,
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GeneComments]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneComments](
	[GeneID] [bigint] NOT NULL,
	[id] [int] NOT NULL,
	[CommentID] [int] NOT NULL,
	[Comment] [text] NULL,
	[CommentDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GeneComments] PRIMARY KEY NONCLUSTERED 
(
	[GeneID] ASC,
	[id] ASC,
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserCommentTests]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCommentTests](
	[userid] [int] NOT NULL,
	[pmid] [int] NOT NULL,
	[TestID] [int] NOT NULL,
 CONSTRAINT [PK_UserCommentTests] PRIMARY KEY NONCLUSTERED 
(
	[userid] ASC,
	[pmid] ASC,
	[TestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserCommentGenes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCommentGenes](
	[userid] [int] NOT NULL,
	[pmid] [int] NOT NULL,
	[GeneID] [bigint] NOT NULL,
 CONSTRAINT [PK_UserCommentGenes] PRIMARY KEY CLUSTERED 
(
	[userid] ASC,
	[pmid] ASC,
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Question]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Question](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sequence] [int] NOT NULL,
	[Body] [text] NOT NULL,
	[SurveyID] [int] NOT NULL,
 CONSTRAINT [pk_Question] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwRecentEditions]    Script Date: 12/09/2013 11:15:30 ******/
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
/****** Object:  Table [dbo].[ThreadsTests]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThreadsTests](
	[ThreadID] [int] NOT NULL,
	[TestID] [int] NOT NULL,
 CONSTRAINT [PK_ThreadsTests] PRIMARY KEY NONCLUSTERED 
(
	[ThreadID] ASC,
	[TestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThreadsGenes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThreadsGenes](
	[ThreadID] [int] NOT NULL,
	[GeneID] [bigint] NOT NULL,
 CONSTRAINT [PK_ThreadsGenes] PRIMARY KEY NONCLUSTERED 
(
	[ThreadID] ASC,
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestsLinks]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TestsLinks](
	[TestID] [int] NOT NULL,
	[LinkID] [int] NOT NULL,
	[Link] [varchar](400) NOT NULL,
 CONSTRAINT [PK_TestsLinks] PRIMARY KEY NONCLUSTERED 
(
	[TestID] ASC,
	[LinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TestsGenes]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestsGenes](
	[TestID] [int] NOT NULL,
	[GeneID] [bigint] NOT NULL,
 CONSTRAINT [PK_TestsGenes] PRIMARY KEY CLUSTERED 
(
	[TestID] ASC,
	[GeneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[SearchQueryGet]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[TestComments]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestComments](
	[TestID] [int] NOT NULL,
	[id] [int] NOT NULL,
	[CommentID] [int] NOT NULL,
	[Comment] [text] NULL,
	[CommentDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TestComments] PRIMARY KEY NONCLUSTERED 
(
	[TestID] ASC,
	[id] ASC,
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestCommentCombos]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestCommentCombos](
	[TestID] [int] NOT NULL,
	[id] [int] NOT NULL,
	[CommentID] [int] NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
 CONSTRAINT [PK_TestCommentCombos] PRIMARY KEY NONCLUSTERED 
(
	[TestID] ASC,
	[id] ASC,
	[CommentID] ASC,
	[SpecialtyID] ASC,
	[TopicID] ASC,
	[SubTopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[lib_GetECEditionThreads]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCitations]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[GeneCommentCombos]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneCommentCombos](
	[GeneID] [bigint] NOT NULL,
	[id] [int] NOT NULL,
	[CommentID] [int] NOT NULL,
	[SpecialtyID] [int] NOT NULL,
	[TopicID] [int] NOT NULL,
	[SubTopicID] [int] NOT NULL,
 CONSTRAINT [PK_GeneCommentCombos] PRIMARY KEY NONCLUSTERED 
(
	[GeneID] ASC,
	[id] ASC,
	[CommentID] ASC,
	[SpecialtyID] ASC,
	[TopicID] ASC,
	[SubTopicID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[lib_GetAbstractCommentsEC20]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[CampCustomPages]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampCustomPages](
	[PageID] [int] NOT NULL,
	[FileName] [nvarchar](24) NOT NULL,
	[PostDate] [smalldatetime] NULL,
	[RetireDate] [smalldatetime] NULL,
 CONSTRAINT [pk_CampCustomPages] PRIMARY KEY CLUSTERED 
(
	[PageID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CampProspects]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampProspects](
	[ProspectID] [int] NOT NULL,
	[AuthID] [int] NOT NULL,
	[LoginDate] [smalldatetime] NULL,
	[LoginType] [char](1) NULL,
	[EmailDate] [smalldatetime] NULL,
 CONSTRAINT [pk_CampProspects] PRIMARY KEY CLUSTERED 
(
	[ProspectID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[lib_AddEditorCommentToGene]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetThreadPMIDList]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGeneEditorCommentsByGeneID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetFoldersEC20Citations]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetFoldersAndEC20Citations]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetFolderListSFE]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceExtraInfo]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  UserDefinedFunction [dbo].[lib_GetThreadTopics]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  UserDefinedFunction [dbo].[lib_GetThreadEditors]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForThread]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForGeneByGeneID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForEditorComments]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestsForCitation]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetTestEditorCommentsByTestID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetRelatedEditions]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForThread]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForTestByTestID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForEditorsChoice]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForEditorComments]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetGenesForCitation]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[doc_in_subtopic_find]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[Answer]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Answer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sequence] [int] NOT NULL,
	[QuestionID] [int] NOT NULL,
	[Body] [text] NOT NULL,
 CONSTRAINT [pk_Answer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CampImportFiles]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampImportFiles](
	[ListID] [int] NOT NULL,
	[FileName] [nvarchar](48) NOT NULL,
	[Source] [nvarchar](64) NOT NULL,
	[Editor] [nvarchar](32) NOT NULL,
	[ImportDate] [smalldatetime] NULL,
 CONSTRAINT [pk_CampImportFiles] PRIMARY KEY CLUSTERED 
(
	[ListID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArticlesAuthors]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ArticlesAuthors](
	[GeneID] [bigint] NOT NULL,
	[ArticleID] [int] NOT NULL,
	[AuthorName] [varchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_ArticlesAuthors] PRIMARY KEY NONCLUSTERED 
(
	[AuthorName] ASC,
	[GeneID] ASC,
	[ArticleID] ASC,
	[SortOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorCommentFromTest]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorCommentFromGene]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_AttachGeneToTest]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_AddEditorCommentToTest]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_AddEditorCommentToGene]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_UnlinkGeneFromTest]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[CommentAuthorReferences]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommentAuthorReferences](
	[AuthorID] [int] NOT NULL,
	[CommentID] [int] NOT NULL,
 CONSTRAINT [PK_CommentAuthorReference] PRIMARY KEY CLUSTERED 
(
	[AuthorID] ASC,
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AJA_tbl_FieldOptions]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[AJA_tbl_FieldOptions](
	[OptionID] [int] IDENTITY(1,1) NOT NULL,
	[UserFieldID] [int] NOT NULL,
	[OptionText] [varchar](50) NULL,
	[OptionValue] [varchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_AJA_tbl_FieldOptions] PRIMARY KEY CLUSTERED 
(
	[OptionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AJA_tbl_FieldValues]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[AJA_tbl_FieldValues](
	[UserID] [int] NOT NULL,
	[OptionID] [int] NOT NULL,
	[Value] [varchar](max) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
 CONSTRAINT [PK_AJA_tbl_FieldValues_UFIDUserIDValue] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[OptionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[adm_GetECMailingByEdition]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteThread]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteTestByTestID]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteGene]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_DeleteEditorialComment]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_InsertEditorialComment]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[adm_GetThreads]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[CampImportItem]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampImportItem](
	[ItemID] [int] NOT NULL,
	[MarID] [char](6) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[PostalCode] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[Specialty] [nvarchar](50) NOT NULL,
	[Profession] [nvarchar](50) NOT NULL,
	[PracticeEnvironment] [nvarchar](50) NOT NULL,
 CONSTRAINT [pk_CampImportItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[lib_IsEditorComment]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCommentsForTestByTestID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetEditorsChoiceCommentsForGeneByGeneID]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  UserDefinedFunction [dbo].[lib_GetCommentAuthors]    Script Date: 12/09/2013 11:15:33 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetECThreadAttributes]    Script Date: 12/09/2013 11:15:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Paul Keister
--	Copyright (c) 2006 Cogent Medicine
-- =============================================
CREATE PROCEDURE [dbo].[lib_GetECThreadAttributes] 
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
/****** Object:  StoredProcedure [dbo].[lib_GetECEditorSort]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetECThreadComments]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  StoredProcedure [dbo].[lib_GetCommentContext]    Script Date: 12/09/2013 11:15:32 ******/
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
/****** Object:  Table [dbo].[CampImportErrors]    Script Date: 12/09/2013 11:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampImportErrors](
	[ItemID] [int] NOT NULL,
	[TempID] [int] NOT NULL,
	[ColumnName] [varchar](24) NOT NULL,
	[ErrorType] [char](1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[adm_GetThreadComments]    Script Date: 12/09/2013 11:15:31 ******/
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
/****** Object:  Default [DF__AdminUser__PrivM__19DFD96B]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivM__19DFD96B]  DEFAULT ('N') FOR [PrivManageUsers]
GO
/****** Object:  Default [DF__AdminUser__PrivV__1AD3FDA4]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivV__1AD3FDA4]  DEFAULT ('N') FOR [PrivViewUserReports]
GO
/****** Object:  Default [DF__AdminUser__PrivS__1BC821DD]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivS__1BC821DD]  DEFAULT ('N') FOR [PrivSubscriptionStatus]
GO
/****** Object:  Default [DF__AdminUser__PrivW__1CBC4616]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivW__1CBC4616]  DEFAULT ('N') FOR [PrivWebTrends]
GO
/****** Object:  Default [DF__AdminUser__PrivR__1DB06A4F]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivR__1DB06A4F]  DEFAULT ('N') FOR [PrivRepairLib]
GO
/****** Object:  Default [DF__AdminUser__PrivB__1EA48E88]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AdminUsers] ADD  CONSTRAINT [DF__AdminUser__PrivB__1EA48E88]  DEFAULT ('N') FOR [PrivBannerDisplay]
GO
/****** Object:  Default [DF_AtLargeEditors_StartDate]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AtLargeEditors] ADD  CONSTRAINT [DF_AtLargeEditors_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
/****** Object:  Default [DF_debug_tblTrackSearchAdd_RecCount]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[debug_tblTrackSearchAdd] ADD  CONSTRAINT [DF_debug_tblTrackSearchAdd_RecCount]  DEFAULT ((0)) FOR [RecCount]
GO
/****** Object:  Default [DF_debug_tblTrackSearchAdd_TimeOfAttempt]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[debug_tblTrackSearchAdd] ADD  CONSTRAINT [DF_debug_tblTrackSearchAdd_TimeOfAttempt]  DEFAULT (getdate()) FOR [TimeOfAttempt]
GO
/****** Object:  Default [DF_EditorTopics_StartDate]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorTopics] ADD  CONSTRAINT [DF_EditorTopics_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
/****** Object:  Default [DF_ELMAH_Error_ErrorId]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
GO
/****** Object:  Default [DF_LogSearch_RunTime]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[LogSearch] ADD  CONSTRAINT [DF_LogSearch_RunTime]  DEFAULT (getdate()) FOR [RunTime]
GO
/****** Object:  Default [DF_LogSearch_NewCitations]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[LogSearch] ADD  CONSTRAINT [DF_LogSearch_NewCitations]  DEFAULT ((0)) FOR [NewCitations]
GO
/****** Object:  Default [DF__Recipient__Creat__2B0A656D]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[RecipientLists] ADD  CONSTRAINT [DF__Recipient__Creat__2B0A656D]  DEFAULT (getdate()) FOR [CreateDate]
GO
/****** Object:  Default [DF_RecipientLists_Type]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[RecipientLists] ADD  CONSTRAINT [DF_RecipientLists_Type]  DEFAULT ((1)) FOR [Type]
GO
/****** Object:  Default [DF_SearchHeader_UserID]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchHeader_UserID]  DEFAULT ((0)) FOR [UserID]
GO
/****** Object:  Default [DF_SearchHeader_RunOriginal]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchHeader_RunOriginal]  DEFAULT (getdate()) FOR [RunOriginal]
GO
/****** Object:  Default [DF_SearchHeader_FoundOriginal]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchHeader_FoundOriginal]  DEFAULT ((-1)) FOR [FoundOriginal]
GO
/****** Object:  Default [DF_SearchHeader_RunLast]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchHeader_RunLast]  DEFAULT (getdate()) FOR [RunLast]
GO
/****** Object:  Default [DF_SearchHeader_FoundLast]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchHeader_FoundLast]  DEFAULT ((0)) FOR [FoundLast]
GO
/****** Object:  Default [DF_SearchSummary_PublicationTypeMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_PublicationTypeMask]  DEFAULT ((0)) FOR [PublicationTypeMask]
GO
/****** Object:  Default [DF_SearchSummary_LanguageMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_LanguageMask]  DEFAULT ((0)) FOR [LanguageMask]
GO
/****** Object:  Default [DF_SearchSummary_SpeciesMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_SpeciesMask]  DEFAULT ((0)) FOR [SpeciesMask]
GO
/****** Object:  Default [DF_SearchSummary_GenderMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_GenderMask]  DEFAULT ((0)) FOR [GenderMask]
GO
/****** Object:  Default [DF_SearchSummary_SubjectAgeMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_SubjectAgeMask]  DEFAULT ((0)) FOR [SubjectAgeMask]
GO
/****** Object:  Default [DF_SearchSummary_AbstractMask]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_AbstractMask]  DEFAULT ((0)) FOR [AbstractMask]
GO
/****** Object:  Default [DF_SearchSummary_PaperAge]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_PaperAge]  DEFAULT ((0)) FOR [PaperAge]
GO
/****** Object:  Default [DF_SearchSummary_SearchSort]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_SearchSort]  DEFAULT ((0)) FOR [SearchSort]
GO
/****** Object:  Default [DF_SearchSummary_FastFullText]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_FastFullText]  DEFAULT ((1)) FOR [FastFullText]
GO
/****** Object:  Default [DF_SearchSummary_ShelfLife]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_ShelfLife]  DEFAULT ((0)) FOR [ShelfLife]
GO
/****** Object:  Default [DF_SearchSummary_LastAutorunHits]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_LastAutorunHits]  DEFAULT ((0)) FOR [LastAutorunHits]
GO
/****** Object:  Default [DF_SearchSummary_LimitToUserLibrary]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_LimitToUserLibrary]  DEFAULT ((0)) FOR [LimitToUserLibrary]
GO
/****** Object:  Default [DF_SearchSummary_ResultsFolder1]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_ResultsFolder1]  DEFAULT ((0)) FOR [ResultsFolder1]
GO
/****** Object:  Default [DF_SearchSummary_ResultsFolder2]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_ResultsFolder2]  DEFAULT ((0)) FOR [ResultsFolder2]
GO
/****** Object:  Default [DF_SearchSummary_Autosearch]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_Autosearch]  DEFAULT ((0)) FOR [Autosearch]
GO
/****** Object:  Default [DF_SearchSummary_KeepDelete]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchSummary] ADD  CONSTRAINT [DF_SearchSummary_KeepDelete]  DEFAULT ((0)) FOR [KeepDelete]
GO
/****** Object:  Default [DF_SearchView_ViewDate]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchView] ADD  CONSTRAINT [DF_SearchView_ViewDate]  DEFAULT (getdate()) FOR [ViewDate]
GO
/****** Object:  Default [DF_SearchView_ViewCountSummary]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchView] ADD  CONSTRAINT [DF_SearchView_ViewCountSummary]  DEFAULT ((0)) FOR [ViewCountSummary]
GO
/****** Object:  Default [DF_SearchView_ViewPMID]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SearchView] ADD  CONSTRAINT [DF_SearchView_ViewPMID]  DEFAULT ((0)) FOR [ViewPMID]
GO
/****** Object:  Default [DF_Specialties_isInUse]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Specialties] ADD  CONSTRAINT [DF_Specialties_isInUse]  DEFAULT ((0)) FOR [isInUse]
GO
/****** Object:  Default [DF_SubTopics_createtime]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopics] ADD  CONSTRAINT [DF_SubTopics_createtime]  DEFAULT (getdate()) FOR [createtime]
GO
/****** Object:  Default [DF_SubTopics_Priority]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopics] ADD  CONSTRAINT [DF_SubTopics_Priority]  DEFAULT ((0)) FOR [Priority]
GO
/****** Object:  Default [DF_Topics_createtime]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Topics] ADD  CONSTRAINT [DF_Topics_createtime]  DEFAULT (getdate()) FOR [createtime]
GO
/****** Object:  Default [DF_UserCitations_Deleted]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCitations] ADD  CONSTRAINT [DF_UserCitations_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
/****** Object:  Default [DF_UserCitations_IsAutoQueryCitation]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCitations] ADD  CONSTRAINT [DF_UserCitations_IsAutoQueryCitation]  DEFAULT ((0)) FOR [IsAutoQueryCitation]
GO
/****** Object:  Default [DF_UserCitations_SearchID]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCitations] ADD  CONSTRAINT [DF_UserCitations_SearchID]  DEFAULT ((0)) FOR [SearchID]
GO
/****** Object:  Default [DF_UserCitations_ExpireDate]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCitations] ADD  CONSTRAINT [DF_UserCitations_ExpireDate]  DEFAULT ('1/1/1960') FOR [ExpireDate]
GO
/****** Object:  Default [DF_UserCitations_KeepDelete]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCitations] ADD  CONSTRAINT [DF_UserCitations_KeepDelete]  DEFAULT ((1)) FOR [KeepDelete]
GO
/****** Object:  Default [DF_UserDBs_IsActive]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserDBs] ADD  CONSTRAINT [DF_UserDBs_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
/****** Object:  Default [DF_UserHasSponsorTopic_CreatedOn]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserHasSponsorTopic] ADD  CONSTRAINT [DF_UserHasSponsorTopic_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
/****** Object:  Default [DF_Users_sasemail]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_sasemail]  DEFAULT ((0)) FOR [sasemail]
GO
/****** Object:  Default [DF_Users_deleted_ind]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_deleted_ind]  DEFAULT ('N') FOR [deleted_ind]
GO
/****** Object:  Default [DF__Users__surveyVal__78BEDCC2]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF__Users__surveyVal__78BEDCC2]  DEFAULT ((0)) FOR [surveyValidated]
GO
/****** Object:  Default [DF_UserSpecialties_DateAdded]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserSpecialties] ADD  CONSTRAINT [DF_UserSpecialties_DateAdded]  DEFAULT (getdate()) FOR [DateAdded]
GO
/****** Object:  Check [ck_CampAuthType]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampAuthorizations]  WITH NOCHECK ADD  CONSTRAINT [ck_CampAuthType] CHECK  (([AuthType]='P' OR [AuthType]='I'))
GO
ALTER TABLE [dbo].[CampAuthorizations] CHECK CONSTRAINT [ck_CampAuthType]
GO
/****** Object:  Check [ck_CampErrorType]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampImportErrors]  WITH CHECK ADD  CONSTRAINT [ck_CampErrorType] CHECK  (([ErrorType]='I' OR [ErrorType]='M'))
GO
ALTER TABLE [dbo].[CampImportErrors] CHECK CONSTRAINT [ck_CampErrorType]
GO
/****** Object:  Check [ck_CampLoginType]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampProspects]  WITH NOCHECK ADD  CONSTRAINT [ck_CampLoginType] CHECK  (([LoginType]='P' OR [LoginType]='A'))
GO
ALTER TABLE [dbo].[CampProspects] CHECK CONSTRAINT [ck_CampLoginType]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_FieldOptions_AJA_tbl_UserFields]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_FieldOptions]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_FieldOptions_AJA_tbl_UserFields] FOREIGN KEY([UserFieldID])
REFERENCES [dbo].[AJA_tbl_UserFields] ([UserFieldID])
GO
ALTER TABLE [dbo].[AJA_tbl_FieldOptions] CHECK CONSTRAINT [FK_AJA_tbl_FieldOptions_AJA_tbl_UserFields]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_FieldValues_AJA_tbl_FieldOptions]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_FieldValues]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_FieldValues_AJA_tbl_FieldOptions] FOREIGN KEY([OptionID])
REFERENCES [dbo].[AJA_tbl_FieldOptions] ([OptionID])
GO
ALTER TABLE [dbo].[AJA_tbl_FieldValues] CHECK CONSTRAINT [FK_AJA_tbl_FieldValues_AJA_tbl_FieldOptions]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_FieldValues_AJA_tbl_Users]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_FieldValues]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_FieldValues_AJA_tbl_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[AJA_tbl_Users] ([UserID])
GO
ALTER TABLE [dbo].[AJA_tbl_FieldValues] CHECK CONSTRAINT [FK_AJA_tbl_FieldValues_AJA_tbl_Users]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_UserFields_AJA_tbl_FieldTypes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_UserFields]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_UserFields_AJA_tbl_FieldTypes] FOREIGN KEY([TypeID])
REFERENCES [dbo].[AJA_tbl_FieldTypes] ([TypeID])
GO
ALTER TABLE [dbo].[AJA_tbl_UserFields] CHECK CONSTRAINT [FK_AJA_tbl_UserFields_AJA_tbl_FieldTypes]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_UserFields_AJA_tbl_Roles]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_UserFields]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_UserFields_AJA_tbl_Roles] FOREIGN KEY([RoleID])
REFERENCES [dbo].[AJA_tbl_Roles] ([RoleID])
GO
ALTER TABLE [dbo].[AJA_tbl_UserFields] CHECK CONSTRAINT [FK_AJA_tbl_UserFields_AJA_tbl_Roles]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_UserRoles_AJA_tbl_Roles]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_UserRoles_AJA_tbl_Roles] FOREIGN KEY([RoleID])
REFERENCES [dbo].[AJA_tbl_Roles] ([RoleID])
GO
ALTER TABLE [dbo].[AJA_tbl_UserRoles] CHECK CONSTRAINT [FK_AJA_tbl_UserRoles_AJA_tbl_Roles]
GO
/****** Object:  ForeignKey [FK_AJA_tbl_UserRoles_AJA_tbl_Users]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[AJA_tbl_UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AJA_tbl_UserRoles_AJA_tbl_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[AJA_tbl_Users] ([UserID])
GO
ALTER TABLE [dbo].[AJA_tbl_UserRoles] CHECK CONSTRAINT [FK_AJA_tbl_UserRoles_AJA_tbl_Users]
GO
/****** Object:  ForeignKey [fk_Answer_1]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [fk_Answer_1] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Question] ([ID])
GO
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [fk_Answer_1]
GO
/****** Object:  ForeignKey [FK_GenesArticles_ArticlesAuthors]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ArticlesAuthors]  WITH CHECK ADD  CONSTRAINT [FK_GenesArticles_ArticlesAuthors] FOREIGN KEY([ArticleID], [GeneID])
REFERENCES [dbo].[GenesArticles] ([ArticleID], [GeneID])
GO
ALTER TABLE [dbo].[ArticlesAuthors] CHECK CONSTRAINT [FK_GenesArticles_ArticlesAuthors]
GO
/****** Object:  ForeignKey [FK_ArticleSelections_EditorialThreads]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ArticleSelections]  WITH CHECK ADD  CONSTRAINT [FK_ArticleSelections_EditorialThreads] FOREIGN KEY([ThreadID])
REFERENCES [dbo].[EditorialThreads] ([ThreadID])
GO
ALTER TABLE [dbo].[ArticleSelections] CHECK CONSTRAINT [FK_ArticleSelections_EditorialThreads]
GO
/****** Object:  ForeignKey [fk_CampAuthCamp]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampAuthorizations]  WITH NOCHECK ADD  CONSTRAINT [fk_CampAuthCamp] FOREIGN KEY([CampaignID])
REFERENCES [dbo].[Campaigns] ([CampaignID])
GO
ALTER TABLE [dbo].[CampAuthorizations] CHECK CONSTRAINT [fk_CampAuthCamp]
GO
/****** Object:  ForeignKey [fk_CampPagesAuth]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampCustomPages]  WITH CHECK ADD  CONSTRAINT [fk_CampPagesAuth] FOREIGN KEY([PageID])
REFERENCES [dbo].[CampAuthorizations] ([AuthID])
GO
ALTER TABLE [dbo].[CampCustomPages] CHECK CONSTRAINT [fk_CampPagesAuth]
GO
/****** Object:  ForeignKey [fk_CampErrorItem]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampImportErrors]  WITH CHECK ADD  CONSTRAINT [fk_CampErrorItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[CampImportItem] ([ItemID])
GO
ALTER TABLE [dbo].[CampImportErrors] CHECK CONSTRAINT [fk_CampErrorItem]
GO
/****** Object:  ForeignKey [fk_CampImportTemp]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampImportErrors]  WITH CHECK ADD  CONSTRAINT [fk_CampImportTemp] FOREIGN KEY([TempID])
REFERENCES [dbo].[CampImportTemp] ([ItemID])
GO
ALTER TABLE [dbo].[CampImportErrors] CHECK CONSTRAINT [fk_CampImportTemp]
GO
/****** Object:  ForeignKey [fk_CampImportAuth]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampImportFiles]  WITH NOCHECK ADD  CONSTRAINT [fk_CampImportAuth] FOREIGN KEY([ListID])
REFERENCES [dbo].[CampAuthorizations] ([AuthID])
GO
ALTER TABLE [dbo].[CampImportFiles] CHECK CONSTRAINT [fk_CampImportAuth]
GO
/****** Object:  ForeignKey [fk_CampItemProspects]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampImportItem]  WITH NOCHECK ADD  CONSTRAINT [fk_CampItemProspects] FOREIGN KEY([ItemID])
REFERENCES [dbo].[CampProspects] ([ProspectID])
GO
ALTER TABLE [dbo].[CampImportItem] CHECK CONSTRAINT [fk_CampItemProspects]
GO
/****** Object:  ForeignKey [fk_CampProspectsAuth]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CampProspects]  WITH NOCHECK ADD  CONSTRAINT [fk_CampProspectsAuth] FOREIGN KEY([AuthID])
REFERENCES [dbo].[CampAuthorizations] ([AuthID])
GO
ALTER TABLE [dbo].[CampProspects] CHECK CONSTRAINT [fk_CampProspectsAuth]
GO
/****** Object:  ForeignKey [FK_Genes_CitationsGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CitationsGenes]  WITH CHECK ADD  CONSTRAINT [FK_Genes_CitationsGenes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[CitationsGenes] CHECK CONSTRAINT [FK_Genes_CitationsGenes]
GO
/****** Object:  ForeignKey [FK_Tests_SeminalCitationsTests]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CitationsTests]  WITH CHECK ADD  CONSTRAINT [FK_Tests_SeminalCitationsTests] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[CitationsTests] CHECK CONSTRAINT [FK_Tests_SeminalCitationsTests]
GO
/****** Object:  ForeignKey [FK_CommentAuthorReferences_CommentAuthors]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CommentAuthorReferences]  WITH CHECK ADD  CONSTRAINT [FK_CommentAuthorReferences_CommentAuthors] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[CommentAuthors] ([id])
GO
ALTER TABLE [dbo].[CommentAuthorReferences] CHECK CONSTRAINT [FK_CommentAuthorReferences_CommentAuthors]
GO
/****** Object:  ForeignKey [FK_CommentAuthorReferences_EditorialComments]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[CommentAuthorReferences]  WITH CHECK ADD  CONSTRAINT [FK_CommentAuthorReferences_EditorialComments] FOREIGN KEY([CommentID])
REFERENCES [dbo].[EditorialComments] ([CommentID])
GO
ALTER TABLE [dbo].[CommentAuthorReferences] CHECK CONSTRAINT [FK_CommentAuthorReferences_EditorialComments]
GO
/****** Object:  ForeignKey [FK_doc_in_subtopic_doc]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[doc_in_subtopic]  WITH CHECK ADD  CONSTRAINT [FK_doc_in_subtopic_doc] FOREIGN KEY([doc_id])
REFERENCES [dbo].[doc] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[doc_in_subtopic] CHECK CONSTRAINT [FK_doc_in_subtopic_doc]
GO
/****** Object:  ForeignKey [FK_EditorialComments_EditorialThreads]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorialComments]  WITH CHECK ADD  CONSTRAINT [FK_EditorialComments_EditorialThreads] FOREIGN KEY([ThreadID])
REFERENCES [dbo].[EditorialThreads] ([ThreadID])
GO
ALTER TABLE [dbo].[EditorialComments] CHECK CONSTRAINT [FK_EditorialComments_EditorialThreads]
GO
/****** Object:  ForeignKey [FK_Genes_EditorialCommentsGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorialCommentsGenes]  WITH CHECK ADD  CONSTRAINT [FK_Genes_EditorialCommentsGenes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[EditorialCommentsGenes] CHECK CONSTRAINT [FK_Genes_EditorialCommentsGenes]
GO
/****** Object:  ForeignKey [FK_Tests_EditorialCommentsTests]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorialCommentsTests]  WITH CHECK ADD  CONSTRAINT [FK_Tests_EditorialCommentsTests] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[EditorialCommentsTests] CHECK CONSTRAINT [FK_Tests_EditorialCommentsTests]
GO
/****** Object:  ForeignKey [FK__EditorsCh__Admin__534D60F1]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorsChoiceAuth]  WITH NOCHECK ADD  CONSTRAINT [FK__EditorsCh__Admin__534D60F1] FOREIGN KEY([AdminID])
REFERENCES [dbo].[AdminUsers] ([AdminID])
GO
ALTER TABLE [dbo].[EditorsChoiceAuth] CHECK CONSTRAINT [FK__EditorsCh__Admin__534D60F1]
GO
/****** Object:  ForeignKey [FK__EditorsCh__Speci__5441852A]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[EditorsChoiceAuth]  WITH NOCHECK ADD  CONSTRAINT [FK__EditorsCh__Speci__5441852A] FOREIGN KEY([SpecialtyID])
REFERENCES [dbo].[Specialties] ([SpecialtyID])
GO
ALTER TABLE [dbo].[EditorsChoiceAuth] CHECK CONSTRAINT [FK__EditorsCh__Speci__5441852A]
GO
/****** Object:  ForeignKey [FK__ExcludedR__ListI__00DF2177]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ExcludedRecipients]  WITH NOCHECK ADD FOREIGN KEY([ListID])
REFERENCES [dbo].[RecipientLists] ([ID])
GO
/****** Object:  ForeignKey [FK_GeneAliases_Genes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[GeneAliases]  WITH CHECK ADD  CONSTRAINT [FK_GeneAliases_Genes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[GeneAliases] CHECK CONSTRAINT [FK_GeneAliases_Genes]
GO
/****** Object:  ForeignKey [FK_GeneComments_GeneCommentCombos]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[GeneCommentCombos]  WITH CHECK ADD  CONSTRAINT [FK_GeneComments_GeneCommentCombos] FOREIGN KEY([GeneID], [id], [CommentID])
REFERENCES [dbo].[GeneComments] ([GeneID], [id], [CommentID])
GO
ALTER TABLE [dbo].[GeneCommentCombos] CHECK CONSTRAINT [FK_GeneComments_GeneCommentCombos]
GO
/****** Object:  ForeignKey [FK_Genes_GeneComments]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[GeneComments]  WITH CHECK ADD  CONSTRAINT [FK_Genes_GeneComments] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[GeneComments] CHECK CONSTRAINT [FK_Genes_GeneComments]
GO
/****** Object:  ForeignKey [FK_Genes_GenesArticles]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[GenesArticles]  WITH CHECK ADD  CONSTRAINT [FK_Genes_GenesArticles] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[GenesArticles] CHECK CONSTRAINT [FK_Genes_GenesArticles]
GO
/****** Object:  ForeignKey [FK_Genes_GenesLinks]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[GenesLinks]  WITH CHECK ADD  CONSTRAINT [FK_Genes_GenesLinks] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[GenesLinks] CHECK CONSTRAINT [FK_Genes_GenesLinks]
GO
/****** Object:  ForeignKey [FK__IncludedR__ListI__0697FACD]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[IncludedRecipients]  WITH NOCHECK ADD FOREIGN KEY([ListID])
REFERENCES [dbo].[RecipientLists] ([ID])
GO
/****** Object:  ForeignKey [fk_Question_1]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[Question]  WITH CHECK ADD  CONSTRAINT [fk_Question_1] FOREIGN KEY([SurveyID])
REFERENCES [dbo].[Survey] ([ID])
GO
ALTER TABLE [dbo].[Question] CHECK CONSTRAINT [fk_Question_1]
GO
/****** Object:  ForeignKey [FK_SubTopicEditorRef_EditorTopics]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopicEditorRefs]  WITH CHECK ADD  CONSTRAINT [FK_SubTopicEditorRef_EditorTopics] FOREIGN KEY([EditorID], [TopicID])
REFERENCES [dbo].[EditorTopics] ([EditorID], [TopicID])
GO
ALTER TABLE [dbo].[SubTopicEditorRefs] CHECK CONSTRAINT [FK_SubTopicEditorRef_EditorTopics]
GO
/****** Object:  ForeignKey [FK_SubTopicEditorRefs_Editions]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopicEditorRefs]  WITH CHECK ADD  CONSTRAINT [FK_SubTopicEditorRefs_Editions] FOREIGN KEY([EditionID])
REFERENCES [dbo].[Editions] ([EditionID])
GO
ALTER TABLE [dbo].[SubTopicEditorRefs] CHECK CONSTRAINT [FK_SubTopicEditorRefs_Editions]
GO
/****** Object:  ForeignKey [FK_SubTopicEditorRefs_EditorialThreads]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopicEditorRefs]  WITH CHECK ADD  CONSTRAINT [FK_SubTopicEditorRefs_EditorialThreads] FOREIGN KEY([ThreadID])
REFERENCES [dbo].[EditorialThreads] ([ThreadID])
GO
ALTER TABLE [dbo].[SubTopicEditorRefs] CHECK CONSTRAINT [FK_SubTopicEditorRefs_EditorialThreads]
GO
/****** Object:  ForeignKey [FK_SubTopicReference_Editions]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopicReferences]  WITH CHECK ADD  CONSTRAINT [FK_SubTopicReference_Editions] FOREIGN KEY([EditionID])
REFERENCES [dbo].[Editions] ([EditionID])
GO
ALTER TABLE [dbo].[SubTopicReferences] CHECK CONSTRAINT [FK_SubTopicReference_Editions]
GO
/****** Object:  ForeignKey [FK_SubTopicReference_EditorialThreads]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[SubTopicReferences]  WITH CHECK ADD  CONSTRAINT [FK_SubTopicReference_EditorialThreads] FOREIGN KEY([ThreadID])
REFERENCES [dbo].[EditorialThreads] ([ThreadID])
GO
ALTER TABLE [dbo].[SubTopicReferences] CHECK CONSTRAINT [FK_SubTopicReference_EditorialThreads]
GO
/****** Object:  ForeignKey [FK_TestComments_TestCommentCombos]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[TestCommentCombos]  WITH CHECK ADD  CONSTRAINT [FK_TestComments_TestCommentCombos] FOREIGN KEY([TestID], [id], [CommentID])
REFERENCES [dbo].[TestComments] ([TestID], [id], [CommentID])
GO
ALTER TABLE [dbo].[TestCommentCombos] CHECK CONSTRAINT [FK_TestComments_TestCommentCombos]
GO
/****** Object:  ForeignKey [FK_Tests_TestComments]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[TestComments]  WITH CHECK ADD  CONSTRAINT [FK_Tests_TestComments] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[TestComments] CHECK CONSTRAINT [FK_Tests_TestComments]
GO
/****** Object:  ForeignKey [FK_Genes_TestsGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[TestsGenes]  WITH CHECK ADD  CONSTRAINT [FK_Genes_TestsGenes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[TestsGenes] CHECK CONSTRAINT [FK_Genes_TestsGenes]
GO
/****** Object:  ForeignKey [FK_Tests_TestsGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[TestsGenes]  WITH CHECK ADD  CONSTRAINT [FK_Tests_TestsGenes] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[TestsGenes] CHECK CONSTRAINT [FK_Tests_TestsGenes]
GO
/****** Object:  ForeignKey [FK_Tests_TestsLinks]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[TestsLinks]  WITH CHECK ADD  CONSTRAINT [FK_Tests_TestsLinks] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[TestsLinks] CHECK CONSTRAINT [FK_Tests_TestsLinks]
GO
/****** Object:  ForeignKey [FK_Genes_ThreadsGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ThreadsGenes]  WITH CHECK ADD  CONSTRAINT [FK_Genes_ThreadsGenes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[ThreadsGenes] CHECK CONSTRAINT [FK_Genes_ThreadsGenes]
GO
/****** Object:  ForeignKey [FK_Tests_ThreadsTests]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[ThreadsTests]  WITH CHECK ADD  CONSTRAINT [FK_Tests_ThreadsTests] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[ThreadsTests] CHECK CONSTRAINT [FK_Tests_ThreadsTests]
GO
/****** Object:  ForeignKey [FK_Genes_UserCommentGenes]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCommentGenes]  WITH CHECK ADD  CONSTRAINT [FK_Genes_UserCommentGenes] FOREIGN KEY([GeneID])
REFERENCES [dbo].[Genes] ([GeneID])
GO
ALTER TABLE [dbo].[UserCommentGenes] CHECK CONSTRAINT [FK_Genes_UserCommentGenes]
GO
/****** Object:  ForeignKey [FK_Tests_UserCommentTests]    Script Date: 12/09/2013 11:15:29 ******/
ALTER TABLE [dbo].[UserCommentTests]  WITH CHECK ADD  CONSTRAINT [FK_Tests_UserCommentTests] FOREIGN KEY([TestID])
REFERENCES [dbo].[Tests] ([TestID])
GO
ALTER TABLE [dbo].[UserCommentTests] CHECK CONSTRAINT [FK_Tests_UserCommentTests]
GO
