#region using namespaces
using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using DAL.Models;
using System.ComponentModel.DataAnnotations;
using System.Data.SqlClient;
using System.Data;
using System.Data.Entity.Infrastructure;
#endregion

namespace DAL
{
    public class SearchBL
    {
        #region SearchForm
        public class SearchForm
        {
            public SearchForm()
            {

            }

            public SearchQueryGet_Result ResultQuery { get; set; }

            //public string _tab1;
            public string _op1, _tab1, _op2, _tab2, _op3, _tab3, _op4, _tab4, _op5, _tab5, _op6, _tab6, Dis_count;

            public int SpecId { get; set; }
            public int SearchId { get; set; }
            public string SearchName { get; set; }
            public string Description { get; set; }
            public string QueryDetails { get; set; }
            public bool AbstractMask { get; set; }
            //public DateTime? DateEnd { get; set; }
            //public DateTime? DateStart { get; set; }
            public int DateEnd { get; set; }
            public int DateStart { get; set; }
            public string Gender { get; set; }
            public string Language { get; set; }
            public string PublicationType { get; set; }
            public string Species { get; set; }
            public string PaperAge { get; set; }
            public string SubjectAge { get; set; }
            public int CitationCount { get; set; }
            public List<ap_SearchFetchRange_AJA_Result> ArticlesList { get; set; }
            public int? FolderID { get; set; }
            public int? TopicFolderID { get; set; }
            public List<SelectListItem> TopicsList { get; set; }
            public bool CheckedCitation { get; set; }
            public int PMID { get; set; }


            public bool FromPMedline { get; set; }
            public string resultFolder2 { get; set; }
            public int? KeepDelete { get; set; }
            public string ShelfLife { get; set; }

            public List<CitationDetailsModel> AllCitationDetails { get; set; }
            public CitationDetailsModel CitationDetails { get; set; }

            public bool Selected { get; set; }
            public string Title { get; set; }
            public string val { get; set; }

            public bool showGoToDestionation { get; set; }

            public string ErrorDesc { get; set; }
            public string DisplayCount
            {

                get
                {
                    if (!string.IsNullOrEmpty(Dis_count))
                        return Dis_count;
                    else
                        return "20";
                }
                set
                {
                    if (string.IsNullOrEmpty(value)) Dis_count = "20";
                    else Dis_count = value;
                }
            }
            public string op1
            {

                get { return _op1; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op1 = "all";
                    else _op1 = value;
                }
            }

            public string term1 { get; set; }

            public string tab1
            {
                get
                {
                    if (!string.IsNullOrEmpty(_tab1))
                        return _tab1;
                    else
                        return "Title/Abstract/MeSH Term";
                }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab1 = "Title/Abstract/MeSH Term";
                    else _tab1 = value;
                }
            }


            public string op2
            {

                get { return _op2; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op2 = "all";
                    else _op2 = value;
                }
            }

            public string term2 { get; set; }

            public string tab2
            {
                get { return _tab2; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab2 = "Title/Abstract/MeSH Term";
                    else _tab2 = value;
                }
            }


            public string op3
            {
                get { return _op3; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op3 = "all";
                    else _op3 = value;
                }
            }

            public string term3 { get; set; }

            public string tab3
            {

                get { return _tab3; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab3 = "Title/Abstract/MeSH Term";
                    else _tab3 = value;
                }
            }



            public string op4
            {

                get { return _op4; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op4 = "all";
                    else _op4 = value;
                }
            }

            public string term4 { get; set; }

            public string tab4
            {

                get { return _tab4; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab4 = "Title/Abstract/MeSH Term";
                    else _tab4 = value;
                }
            }


            public string op5
            {

                get { return _op5; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op5 = "all";
                    else _op5 = value;
                }
            }

            public string term5 { get; set; }

            public string tab5
            {
                get { return _tab5; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab5 = "Title/Abstract/MeSH Term";
                    else _tab5 = value;
                }
            }


            public string op6
            {
                get { return _op6; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _op6 = "all";
                    else _op6 = value;
                }
            }

            public string term6 { get; set; }

            public string tab6
            {
                get { return _tab6; }
                set
                {
                    if (string.IsNullOrEmpty(value)) _tab6 = "Title/Abstract/MeSH Term";
                    else _tab6 = value;
                }
            }

            public int MyQueryValue { get; set; }

            public List<SelectListItem> MyQueries { get; set; }

            #region searchfor
            public IEnumerable<SearchForm> GetSearchFor()
            {
                return new List<SearchForm>
                            {
                                new SearchForm() { val="all" , Title="ALL of:"},
                                new SearchForm() { val="any" , Title="ANY of:"},
                                new SearchForm() { val="not" , Title="NOT (Exclude):"}
                            };
            }
            #endregion

            #region searchIn
            public IEnumerable<SearchForm> GetSearchIn()
            {
                return new List<SearchForm>
                            {
                                new SearchForm() { val="MeSH Term" , Title="MeSH Term"},
                                new SearchForm() { val="Author" , Title="Author"},
                                new SearchForm() { val="Title" , Title="Title"},
                                new SearchForm() { val="Title/Abstract" , Title="Title/Abstract"},
                                new SearchForm() { val="Title/Abstract/MeSH Term" , Title="Title/Abstract/MeSH Term"},
                                new SearchForm() { val="Journal" , Title="Journal"},
                                new SearchForm() { val="Substance Name" , Title="Substance Name"},
                                new SearchForm() { val="PMID" , Title="PMID"}
                            };
            }
            #endregion

            #region Publication Types
            public IEnumerable<SearchForm> GetPublicationTypes()
            {
                return new List<SearchForm>
                            {
                                new SearchForm() {val = "0", Title = "Publication Types"},
                                new SearchForm() {val = "1", Title = "Clinical Trial"},
                                new SearchForm() {val = "2", Title = "Clinical Trial Phase I"},
                                new SearchForm() {val = "4", Title = "Clinical Trial Phase II"},
                                new SearchForm() {val = "8", Title = "Clinical Trial Phase II+"},
                                new SearchForm() {val = "16", Title = "Clinical Trial Phase III"},
                                new SearchForm() {val = "32", Title = "Clinical Trial Phase III+"},
                                new SearchForm() {val = "64", Title = "Clinical Trial Phase IV"},
                                new SearchForm() {val = "128", Title = "Editorial"},
                                new SearchForm() {val = "256", Title = "Letter"},
                                new SearchForm() {val = "512", Title = "Meta-Analysis"},
                                new SearchForm() {val = "1024", Title = "Multicenter Study"},
                                new SearchForm() {val = "2048", Title = "Practice Guideline"},
                                new SearchForm() {val = "4096", Title = "Randomized Controlled Trial"},
                                new SearchForm() {val = "8192", Title = "Review"}
                            };
            }
            #endregion

            #region Subject Ages
            public IEnumerable<SearchForm> GetSubjectAges()
            {
                return new List<SearchForm>
                            {
                                new SearchForm() { val="0" , Title="Subject Ages"},
                                  new SearchForm() {val = "3", Title = "All Infant (birth - 23 months)"},
                                  new SearchForm() {val = "128", Title = "All Child (0 - 18 years)"},
                                  new SearchForm() {val = "4096", Title = "All Adult (19+ years)"},
                                  new SearchForm() {val = "1", Title = "Newborn (birth - 1 month)"},
                                  new SearchForm() {val = "2", Title = "Infant (1 - 23 months)"},
                                  new SearchForm() {val = "16", Title = "Preschool Child (2 - 5 years)"},
                                  new SearchForm() {val = "32", Title = "Child (6 - 12 years)"},
                                  new SearchForm() {val = "64", Title = "Adolescent (13 - 18 years)"},
                                  new SearchForm() {val = "256", Title = "Adult (19 - 44 years)"},
                                  new SearchForm() {val = "512", Title = "Middle Aged (45 - 64 years)"},
                                  new SearchForm() {val = "1024", Title = "Aged (65+ years)"},
                                  new SearchForm() {val = "2048", Title = "80 and over (80+ years)"}
                            };
            }
            #endregion

            #region GetSpecies
            public IEnumerable<SearchForm> GetSpecies()
            {
                return new List<SearchForm>
                            {
                                  new SearchForm() {val = "0", Title = "Human or Animal"},
                                  new SearchForm() {val = "1", Title = "Human"},
                                  new SearchForm() {val = "2", Title = "Animal"}
                            };
            }
            #endregion

            #region Language
            public IEnumerable<SearchForm> GetLanguage()
            {
                return new List<SearchForm>
                            {
                                  new SearchForm() {val = "0", Title = "Languages"},
                                  new SearchForm() {val = "1", Title = "English"},
                                  new SearchForm() {val = "2", Title = "French"},
                                  new SearchForm() {val = "4", Title = "German"},
                                  new SearchForm() {val = "8", Title = "Italian"},
                                  new SearchForm() {val = "16", Title = "Japanese"},
                                  new SearchForm() {val = "32", Title = "Russian"},
                                    new SearchForm() {val = "64", Title = "Spanish"}
                            };
            }
            #endregion

            #region Gender
            public IEnumerable<SearchForm> GetGender()
            {
                return new List<SearchForm>
                            {
                                  new SearchForm() {val = "0", Title = "Gender"},
                                  new SearchForm() {val = "8", Title = "Female"},
                                  new SearchForm() {val = "4", Title = "Male"}
                            };
            }
            #endregion

            #region GePaperAge
            public IEnumerable<SearchForm> GetPaperAge()
            {
                return new List<SearchForm>
                            {
                                  new SearchForm() {val = "0", Title = "----"},
                                  new SearchForm() {val = "1", Title = "30 days"},
                                  new SearchForm() {val = "2", Title = "60 days"},
                                  new SearchForm() {val = "2", Title = "90 days"},
                                  new SearchForm() {val = "4", Title = "180 days"},
                                  new SearchForm() {val = "5", Title = "1 year"},
                                  new SearchForm() {val = "6", Title = "2 years"},
                                  new SearchForm() {val = "7", Title = "5 years"},
                                  new SearchForm() {val = "8", Title = "10 years"},
                                  new SearchForm() {val = "9", Title = "All Paper Ages"}
                            };
            }
            #endregion

            #region DispayCount
            public IEnumerable<SearchForm> GetDispayCount()
            {
                return new List<SearchForm>
                            {
                                  new SearchForm() {val = "10", Title = "10"},
                                  new SearchForm() {val = "15", Title = "15"},
                                  new SearchForm() {val = "20", Title = "20"},
                                  new SearchForm() {val = "25", Title = "25"},
                                  new SearchForm() {val = "50", Title = "50"}
                            };
            }
            #endregion

            public string Parameters { get; set; }

            public CommentContext CommentContext { get; set; }

            public List<AbstractCommentsECModel> AbstractCommentsECList { get; set; }
        }
        #endregion


        public class MyQueryForm
        {

            public MyQueryForm()
            {

            }
            public Int32? FolderID { get; set; }
            public String FolderName { get; set; }
            public Int32? SearchID { get; set; }
            public Int64? CitCount { get; set; }
            public Byte? Autosearch { get; set; }
            public bool Isendemail { get; set; }
            public List<MyQueryForm> myQueriesList { get; set; }
            public SearchQueryGet_Result queryDetails { get; set; }
            public SearchInfo searchInfo { get; set; }
            public QueryDestination queryDestination { get; set; }

            // For Citation Details
            public List<CitationsModel> Citations { get; set; }
            public List<CitationDetailsModel> CitationDetailsTotal { get; set; }
            public List<CitationDetailsModel> CitationDetails { get; set; }
            public string TrackDays { get; set; }

            // For citation abstract
            public UserCommentAbstract UserComment { get; set; }
            public List<AbstractCommentsECModel> AbstractCommentsECList { get; set; }

            public CommentContext CommentContext { get; set; }

            // For Copy Citation

            public int SelectedTopic { get; set; }
            public int SelectedSubTopic { get; set; }
            public int SelectedTopicSecond { get; set; }

            // For Geting Genes

            public List<GeneMyLibrary> GenesMylibrary { get; set; }
            public List<GeneMyLibrary> GenesForThreadMylibrary { get; set; }
            public List<GeneMyLibrary> GenesEditorMylibrary { get; set; }

            public List<TestMyLibrary> TestsMylibrary { get; set; }
            public List<TestMyLibrary> TestsForThreadMylibrary { get; set; }
            public List<TestMyLibrary> TestsEditorMylibrary { get; set; }
            // FOr Linkout
            public EditorsChoicemodel LinkoutModelVar { get; set; }
            public bool FromPMedline { get; set; }

            //For Copy Citation
            public int resultFolder2 { get; set; }
            public List<SelectListItem> TopicsList { get; set; }
        }

        #region SearchInfo
        public class SearchInfo
        {
            public int? SearchResultsCount { get; set; }
            public string QueryDetails { get; set; }
            public string ErrorDesc { get; set; }
        }
        #endregion

        #region QueryDestination
        public class QueryDestination
        {

            public QueryDestination()
            {

            }
            public String SpecialtyName { get; set; }
            public Int32? TopicID { get; set; }
            public String TopicName { get; set; }
            public Int32? SubTopicID { get; set; }
            public String SubTopicName { get; set; }
            public Int32? SpecialtyID { get; set; }
        }
        #endregion

        #region ManageQuery

        public class ManageQuery
        {
            public int? SearchId { get; set; }
            public string QueryDetails { get; set; }
            [Required]
            public string Name { get; set; }
            public string Description { get; set; }
            public string DestinationFolder { get; set; }
            public bool Autosearch { get; set; }
            public QueryDestination queryDestination { get; set; }

            public int? FolderID { get; set; }
            public int? KeepDelete { get; set; }
            public string ShelfLife { get; set; }

            public SearchInfo searchInfo { get; set; }
            public string Title { get; set; }
            public string val { get; set; }
            public int resultFolder2 { get; set; }
            public List<SelectListItem> TopicsList { get; set; }

            public ManageQuery()
            { }

            #region ShelfLife

            public IEnumerable<ManageQuery> GetShelfLife()
            {
                return new List<ManageQuery>
                            {
                                  new ManageQuery() {val = "7", Title = "7 days"},
                                  new ManageQuery() {val = "14", Title = "14 days"},
                                  new ManageQuery() {val = "30", Title = "30 days"},
                                  new ManageQuery() {val = "60", Title = "60 days"},
                                  new ManageQuery() {val = "90", Title = "90 days"}
                            };
            }
            #endregion

        }
        #endregion

        #region MyQueriesList
        /// <summary>
        /// Get Users Topics List from DB bind it to Drop Down list for Copy Citation
        /// </summary>
        /// <returns></returns>
        public static List<MyQueryForm> MyQueriesList(int UserId)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var query =
               (from ss in entity.SearchSummaries
                where
                ss.SearchName != "ADHOC_SEARCH" &&
                ss.UserID == UserId
                select new MyQueryForm
                {
                    FolderID = ss.ResultsFolder2,
                    FolderName = ss.SearchName,
                    SearchID = ss.SearchID,
                    CitCount = (Int64?)
                    (from uc in entity.UserCitations
                     where
                     uc.UserID == UserId &&
                     uc.IsAutoQueryCitation == true &&
                     uc.Deleted == false &&
                     uc.SearchID == ss.SearchID
                     select new
                     {
                         uc
                     }).Count(),
                    Autosearch = ss.Autosearch
                }).ToList();

                return query;

            }

        }
        #endregion

        #region MyQueries
        public static List<SelectListItem> GetMyQueriesForSearch(int userid, int? ddlvalue)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var query = (from ss in entity.SearchSummaries.AsEnumerable()
                             where
                             ss.SearchName != "ADHOC_SEARCH" &&
                             ss.UserID == userid

                             select new SelectListItem
                             {
                                 Text = ss.SearchName,
                                 Value = ss.SearchID.ToString(),
                                 Selected = (ss.SearchID == ddlvalue ? true : false)
                             }

                             ).ToList();
                return query;

            }
        }
        #endregion

        #region GetSearchName

        public static string GetSearchName(int? ddlvalue)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var searchname = (from sname in entity.SearchSummaries where sname.SearchID == ddlvalue select sname.SearchName).FirstOrDefault();
                return searchname;
            }

        }
        #endregion

        //#region GetSearchQuery
        // <summary>
        // Get Search Queries for  
        // </summary>
        // <param name="userid"></param>
        // <param name="x"></param>
        // <param name="ddlvalue"></param>
        // <returns></returns>
        //public static SearchQueryGet_Result GetSearchQuery(int userid, string x, int? ddlvalue)
        //{
        //    using (SearchEntities entity = new SearchEntities())
        //    {
        //        var queryresult = entity.SearchQueryGet(userid, x, ddlvalue).FirstOrDefault();
        //        return queryresult;

        //    }
        //}


        //#endregion

        #region GetSearchQuery
        /// <summary>
        /// Get Search Queries for  
        /// </summary>
        /// <param name="userid"></param>
        /// <param name="x"></param>
        /// <param name="ddlvalue"></param>
        /// <returns></returns>
        public static SearchQueryGet_Result GetSearchQuery(int userid, string x, int? ddlvalue)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var queryresult = entity.SearchQueryGet(userid, x, ddlvalue).FirstOrDefault();
                return queryresult;

            }
        }


        #endregion

        #region SearchInfo
        /// <summary>
        /// Get SearchInfo (op , terms , tabs values)
        /// </summary>
        /// <param name="userid"></param>
        /// <param name="x"></param>
        /// <param name="ddlvalue"></param>
        /// <returns></returns>
        public static SearchInfo GetSearchInfo(int userid, string SearchName, int SearchId)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                int searchmode = 0;
                int shlife = 0;
                int lmtsLib = 0;
                string thsautorundates = string.Empty;
                int resfold1 = 0;
                int resfold2 = 0;
                string Srhname = "ADHOC_SEARCH";
                string UserDbName = " ";
                int kepDel = 0;
                if (SearchName == null)
                    SearchName = Srhname;
                SearchInfo result = null;
                string query = "[ap_SearchExecute_AJA] @UserID,@SearchName, @SearchID,@SearchMode,@ShelfLife,@LimitToUserLibrary,@ThisAutorunDateS,@ResultsFolder1	,@ResultsFolder2,	@UserDB	,@KeepDelete, @DoNoExecute,@SearchResultsCount,@QueryDetails,@ErrorDesc";
                SqlParameter userId = new SqlParameter("@UserID", userid);
                SqlParameter searchName = new SqlParameter("@SearchName", SearchName);
                SqlParameter searchId = new SqlParameter("@SearchID", SearchId);
                SqlParameter SearchMode = new SqlParameter("@SearchMode", searchmode);
                SqlParameter ShelfLife = new SqlParameter("@ShelfLife", shlife);
                SqlParameter LimitToUserLibrary = new SqlParameter("@LimitToUserLibrary", lmtsLib);
                SqlParameter ThisAutorunDateS = new SqlParameter("@ThisAutorunDateS", thsautorundates);
                SqlParameter ResultsFolder1 = new SqlParameter("@ResultsFolder1", resfold1);
                SqlParameter ResultsFolder2 = new SqlParameter("@ResultsFolder2", resfold2);
                SqlParameter UserDb = new SqlParameter("@UserDB", UserDbName);
                SqlParameter KeepDelete = new SqlParameter("@KeepDelete", kepDel);
                SqlParameter DoNoExecute = new SqlParameter()
                {
                    ParameterName = "@DoNoExecute",
                    DbType = System.Data.DbType.Int32,
                    Value = 0,
                    Direction = System.Data.ParameterDirection.Input
                };
                SqlParameter res1 = new SqlParameter()
                {
                    ParameterName = "@SearchResultsCount",
                    DbType = System.Data.DbType.Int32,
                    Value = 0,
                    Direction = System.Data.ParameterDirection.Output
                };
                SqlParameter res2 = new SqlParameter()
                {
                    ParameterName = "@QueryDetails",
                    DbType = System.Data.DbType.String,
                    Value = "",
                    Direction = System.Data.ParameterDirection.Output
                };
                SqlParameter res3 = new SqlParameter()
                {
                    ParameterName = "@ErrorDesc",
                    DbType = System.Data.DbType.String,
                    Value = "",
                    Direction = System.Data.ParameterDirection.Output
                };

                // ((IObjectContextAdapter)entity).ObjectContext.CommandTimeout = 180;

                result = entity.Database.SqlQuery<SearchInfo>(query, userId, searchName, searchId, SearchMode, ShelfLife, LimitToUserLibrary,
                    ThisAutorunDateS, ResultsFolder1, ResultsFolder2, UserDb, KeepDelete, DoNoExecute, res1, res2, res3).FirstOrDefault();

                return result;
            }
        }


        #endregion

        #region GetQueryDestination

        public static QueryDestination GetQueryDestination(int SubTopicId)
        {
            using (EditorsEntities db = new EditorsEntities())
            {
                var query =
                   (from st in db.SubTopics
                    join t in db.Topics on st.TopicID equals t.TopicID
                    join s in db.Specialties on t.SpecialtyID equals s.SpecialtyID
                    where
                      st.SubTopicID == SubTopicId
                    select new QueryDestination
                    {
                        SpecialtyName = s.SpecialtyName,
                        TopicID = (System.Int32?)t.TopicID,
                        TopicName = t.TopicName,
                        SubTopicID = st.SubTopicID,
                        SubTopicName = st.SubTopicName,
                        SpecialtyID = (System.Int32?)t.SpecialtyID
                    }).FirstOrDefault();
                return query;
            }
        }

        #endregion

        #region GetIsSendEmail

        public static Boolean GetIsSendEmail(int userId)
        {
            using (AJA_UserEntities uE = new AJA_UserEntities())
            {
                var isSendEmail = (from t in uE.AJA_tbl_Users where t.UserID == userId select t.IsSavedAqemaisend).FirstOrDefault();
                return Convert.ToBoolean(isSendEmail);
            }
        }

        #endregion

        #region UpdateUserProfile for MyQueries
        public static bool updateUserProfile(int UserId, bool IsSave)
        {
            bool result = false;

            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                if (UserId != 0)
                {
                    var UserDetails = entity.AJA_tbl_Users.Where(e => e.UserID == UserId).FirstOrDefault();
                    if (UserDetails != null)
                    {
                        UserDetails.IsSavedAqemaisend = IsSave;
                        entity.SaveChanges();
                        result = true;
                    }
                }
                return result;
            }
        }
        #endregion

        #region Delete Query
        public static bool DeleteQuery(int SearchID, int UserID)
        {
            bool DelQuery = false;
            using (SearchEntities entity = new SearchEntities())
            {
                var Sr = (from f in entity.SearchResults where f.SearchID == SearchID select f);

                foreach (var agShare in Sr)
                {
                    entity.SearchResults.Remove(agShare);
                }

                var Sd = (from f in entity.SearchDetails where f.SearchID == SearchID select f);
                foreach (var agShare in Sd)
                {
                    entity.SearchDetails.Remove(agShare);
                }

                var Ss = (from f in entity.SearchSummaries where f.SearchID == SearchID select f).FirstOrDefault();
                if (Ss != null) entity.SearchSummaries.Remove(Ss);

                var queryUserCitations = (from t in entity.UserCitations
                                          where t.UserID == UserID && t.IsAutoQueryCitation == true &&
                                          t.SearchID == SearchID
                                          select t);
                foreach (var agShare in queryUserCitations)
                {
                    entity.UserCitations.Remove(agShare);
                }

                entity.SaveChanges();
                DelQuery = true;
                return DelQuery;
            }
        }
        #endregion

        #region UpdateNonMedlineCitations
        public static bool SaveQuery(ManageQuery mQ)
        {
            bool result = false;
            using (SearchEntities entity = new SearchEntities())
            {
                if (mQ.SearchId != 0)
                {
                    var Ss = entity.SearchSummaries.Where(s => s.SearchID == mQ.SearchId).FirstOrDefault();
                    if (Ss != null)
                    {
                        Ss.Autosearch = Convert.ToByte(mQ.Autosearch);
                        Ss.Description = mQ.Description;
                        Ss.KeepDelete = Convert.ToByte(mQ.KeepDelete);
                        Ss.SearchName = mQ.Name;
                        if (mQ.FolderID != null && mQ.FolderID > 0)
                            Ss.ResultsFolder1 = Convert.ToInt32(mQ.FolderID);
                        if (mQ.resultFolder2 != null && mQ.resultFolder2 > 0)
                            Ss.ResultsFolder2 = mQ.resultFolder2;
                        Ss.ShelfLife = Convert.ToInt16(mQ.ShelfLife);
                        entity.SaveChanges();
                        result = true;
                    }

                    var manageQuery = entity.UserCitations.Where(p => p.SearchID == mQ.SearchId && p.Deleted == false && p.IsAutoQueryCitation == true).FirstOrDefault();
                    if (manageQuery != null)
                    {
                        manageQuery.KeepDelete = Convert.ToBoolean(mQ.KeepDelete);
                        manageQuery.ExpireDate = manageQuery.ExpireDate.AddDays(Convert.ToInt32(mQ.ShelfLife));
                        entity.SaveChanges();
                        result = true;
                    }
                }
            }
            return result;
        }
        #endregion

        #region Delete SearchSearch query By UserID
        /// <summary>
        /// Delete Search Query 
        /// </summary>
        /// <param name="SearchID"></param>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public static bool DeleteSearchQuery(int UserID)
        {
            string searchname = "ADHOC_SEARCH";

            bool DelQuery = false;
            using (SearchEntities entity = new SearchEntities())
            {
                int searchID = (from s in entity.SearchSummaries where s.UserID == UserID && s.SearchName == searchname select s.SearchID).FirstOrDefault();

                if (searchID != 0)
                {
                    var Sr = (from f in entity.SearchResults where f.SearchID == searchID select f);
                    if (Sr != null)
                    {
                        foreach (var agShare in Sr)
                        {
                            if (agShare != null)
                                entity.SearchResults.Remove(agShare);
                        }
                    }

                    var Sd = (from f in entity.SearchDetails where f.SearchID == searchID select f);

                    if (Sd != null)
                    {
                        foreach (var agShare in Sd)
                        {
                            entity.SearchDetails.Remove(agShare);
                        }
                    }

                    var Ss = (from f in entity.SearchSummaries where f.SearchID == searchID select f).FirstOrDefault();
                    if (Ss != null)
                        entity.SearchSummaries.Remove(Ss);

                    entity.SaveChanges();

                    DelQuery = true;
                }
                return DelQuery;
            }
        }

        #endregion

        #region Get Search Citations
        // To Get Search Citations
        public static List<CitationsModel> GetSearchCitations(int SearchId, int UserId)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var Result = entity.lib_GetSearchCitationList(UserId, SearchId);
                List<CitationsModel> AllCitations = new List<CitationsModel>();
                foreach (var item in Result)
                {
                    CitationsModel Citation = new CitationsModel();
                    Citation.pmid = item.pmid;
                    // Citation.status = item.status;
                    Citation.nickname = item.nickname;
                    Citation.comment = item.comment;
                    Citation.commentupdatedate = item.commentupdatedate;
                    Citation.searchid = item.searchid;
                    Citation.expiredate = item.expiredate;
                    Citation.keepdelete = item.keepdelete;
                    AllCitations.Add(Citation);
                }
                return AllCitations;
            }
        }

        #endregion

        #region Keep My Query Citation

        public static bool KeepMyQueryCitation(int UserId, int pmid, int subTopicId)
        {
            bool result = false;

            using (SearchEntities entity = new SearchEntities())
            {
                if (UserId != 0)
                {
                    var UserCitation = entity.UserCitations.Where(e => e.UserID == UserId && e.PMID == pmid && e.SubTopicID == subTopicId).FirstOrDefault();
                    if (UserCitation != null)
                    {
                        UserCitation.IsAutoQueryCitation = false;
                        entity.SaveChanges();
                        result = true;
                    }
                }
                return result;
            }
        }

        #endregion

        #region Delete My Query Citation

        public static bool DeleteMyQueryCitation(int UserId, int pmid, int subTopicId)
        {
            bool result = false;

            using (SearchEntities entity = new SearchEntities())
            {
                if (UserId != 0)
                {
                    var UserCitation = entity.UserCitations.Where(e => e.UserID == UserId && e.PMID == pmid && e.SubTopicID == subTopicId).FirstOrDefault();
                    if (UserCitation != null)
                    {
                        UserCitation.Deleted = true;
                        entity.SaveChanges();
                        result = true;
                    }
                }
                return result;
            }
        }

        #endregion

        #region Keep My ALL Query Citations

        public static bool KeepAllMyQueryCitations(int UserId, int SearchId)
        {
            bool result = false;

            using (SearchEntities entity = new SearchEntities())
            {
                if (UserId != 0)
                {
                    //var UserCitation = entity.UserCitations.Where(e => e.UserID == UserId && e.SearchID == SearchId && e.IsAutoQueryCitation == true && e.Deleted == false).ToList();
                    //foreach (var item in UserCitation)
                    //{
                    //    item.IsAutoQueryCitation = false;

                    //}

                    SqlParameter param1 = new SqlParameter("@SearchID", SearchId);
                    SqlParameter param2 = new SqlParameter("@UserID", UserId);
                    entity.Database.ExecuteSqlCommand("lib_KeepCitationsBySearch @SearchID, @UserID",
                                                  param1, param2); 
                    result = true;
                }

                return result;
            }
        }

        #endregion

        #region Delete All My Query Citations

        public static bool DeleteAllMyQueryCitations(int UserId, int SearchId)
        {
            bool result = false;

            using (SearchEntities entity = new SearchEntities())
            {
                if (UserId != 0)
                {
                    //var UserCitation = entity.UserCitations.Where(e => e.UserID == UserId && e.SearchID == SearchId && e.IsAutoQueryCitation == true).ToList();
                    //foreach (var item in UserCitation)
                    //{
                    //    item.Deleted = true; 
                    //}
                    SqlParameter param1 = new SqlParameter("@UserID", UserId);
                    SqlParameter param2 = new SqlParameter("@SearchID", SearchId);
                    entity.Database.ExecuteSqlCommand("lib_DeleteCitationsBySearch @UserID, @SearchID",
                                                  param1, param2); 
                    result = true;
                }
                return result;
            }
        }

        #endregion

        #region  SearchQueryAdd
        /// <summary>
        /// Added newly created Search Parameter to Db by UserID
        /// </summary>
        /// <param name="SearParm"></param>
        /// <param name="userid"></param>
        /// <returns></returns>
        public static int SearchQueryAdd(SearchForm SearParm, int userid)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                short publicationMask = Convert.ToInt16(SearParm.PublicationType);
                short SubjectMask = Convert.ToInt16(SearParm.SubjectAge);
                byte LanguageMask = Convert.ToByte(SearParm.Language);
                byte SpecisMask = Convert.ToByte(SearParm.Species);
                byte GenderMask = Convert.ToByte(SearParm.Gender);
                byte AbstractMask = Convert.ToByte(SearParm.AbstractMask);
                byte PaperAge = Convert.ToByte(SearParm.PaperAge);

                //string sdate = SearParm.DateStart.ToString();// "1960-1-1";
                //string edate = SearParm.DateEnd.ToString();//"2030-12-31";
                DateTime DateStart, DateEnd;
                if (SearParm.DateStart != null)
                {
                    DateStart = Convert.ToDateTime(SearParm.DateStart.ToString() + "-01-01 00:00:00");
                }
                else
                {
                    DateStart = Convert.ToDateTime("1960-01-01 00:00:00.000");
                }
                //Convert.ToDateTime("1960-01-01 00:00:00.000");
                if (SearParm.DateEnd != null)
                    DateEnd = Convert.ToDateTime(SearParm.DateEnd.ToString() + "-12-31 00:00:00.000"); //Convert.ToDateTime("2030-12-31 00:00:00.000");
                else
                {
                    DateEnd = Convert.ToDateTime("2030-12-31 00:00:00.000");
                }

                var Search = new SearchSummary
                {
                    PublicationTypeMask = publicationMask,
                    SubjectAgeMask = SubjectMask,
                    LanguageMask = LanguageMask,
                    SpeciesMask = SpecisMask,
                    GenderMask = GenderMask,
                    AbstractMask = AbstractMask,
                    PaperAge = PaperAge,
                    DateStart = DateStart,
                    DateEnd = DateEnd,
                    UserID = userid,
                    LimitToUserLibrary = 0,
                    UserDB = "User_01",
                    SearchName = "ADHOC_SEARCH",
                    Autosearch = 0,
                    SearchSort = 1,
                    ShelfLife = 0,
                    Description = "",
                    RunLast = DateTime.Now,
                    RunOriginal = DateTime.Now,
                    ResultsFolder1 = 0,
                    ResultsFolder2 = 0,
                    KeepDelete = 0,
                };

                entity.SearchSummaries.Add(Search);
                entity.SaveChanges();

                int searchid = (from s in entity.SearchSummaries.Where(i => i.SearchName == "ADHOC_SEARCH" && i.UserID == userid) select s.SearchID).FirstOrDefault();

                if (SearParm.term1 != null)
                {
                    var searchDet1 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op1,
                        Terms = SearParm.term1,
                        Seq = 1,
                        Tab = SearParm.tab1,
                    };
                    entity.SearchDetails.Add(searchDet1);
                    entity.SaveChanges();

                }

                if (SearParm.term2 != null)
                {
                    var searchDet2 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op2,
                        Terms = SearParm.term2,
                        Seq = 2,
                        Tab = SearParm.tab2,
                    };
                    entity.SearchDetails.Add(searchDet2);
                    entity.SaveChanges();
                }

                if (SearParm.term3 != null)
                {
                    var searchDet3 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op3,
                        Terms = SearParm.term3,
                        Seq = 3,
                        Tab = SearParm.tab3,
                    };
                    entity.SearchDetails.Add(searchDet3);
                    entity.SaveChanges();
                }

                if (SearParm.term4 != null)
                {
                    var searchDet4 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op4,
                        Terms = SearParm.term4,
                        Seq = 4,
                        Tab = SearParm.tab4,
                    };
                    entity.SearchDetails.Add(searchDet4);
                    entity.SaveChanges();
                }

                if (SearParm.term5 != null)
                {
                    var searchDet5 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op5,
                        Terms = SearParm.term5,
                        Seq = 5,
                        Tab = SearParm.tab5,
                    };
                    entity.SearchDetails.Add(searchDet5);
                    entity.SaveChanges();
                }

                if (SearParm.term6 != null)
                {
                    var searchDet6 = new SearchDetail
                    {
                        SearchID = searchid,
                        Op = SearParm.op6,
                        Terms = SearParm.term6,
                        Seq = 6,
                        Tab = SearParm.tab6,
                    };
                    entity.SearchDetails.Add(searchDet6);
                    entity.SaveChanges();
                }
                return searchid;
            }
        }

        #endregion

        #region SearchFetchRange

        /// <summary>
        /// Get the Citations list from start range to end range
        /// </summary>
        /// <param name="userid"></param>
        /// <param name="searchname"></param>
        /// <param name="searchID"></param>
        /// <param name="rangestrt"></param>
        /// <param name="rangend"></param>
        /// <returns></returns>
        public static List<ap_SearchFetchRange_AJA_Result> SearchFetchRange(int userid, string searchname, int searchID, int rangestrt, int rangend)
        {
            List<ap_SearchFetchRange_AJA_Result> result = null;

            using (Cogent3Entities entity = new Cogent3Entities())
            {
                SearchEntities cntxt = new SearchEntities();
                {
                    var Sresult = (from s in cntxt.SearchResults where s.SearchID == searchID select s.SearchID).FirstOrDefault();
                    if (Sresult != 0)
                    {
                        var Eresult = entity.ap_SearchFetchRange_AJA(userid, searchname, searchID, rangestrt, rangend).ToList();
                        return Eresult;
                    }
                }
                return result;
            }
        }

        #endregion

        //#region GetTopicsList
        ///// <summary>
        ///// GetTopicsList by userID
        ///// </summary>
        ///// <param name="Userid"></param>
        ///// <returns></returns>
        //public static List<SelectListItem> GetTopicsList(int Userid)
        //{
        //    List<SelectListItem> UserTopic = new List<SelectListItem>();
        //    using (EditorsEntities db = new EditorsEntities())
        //    {

        //        var query = (from t in db.Topics
        //                     join us in db.UserSpecialties on t.SpecialtyID equals us.SpecialtyID into us_join
        //                     from us in us_join.DefaultIfEmpty()
        //                     join s in db.Specialties on us.SpecialtyID equals s.SpecialtyID into s_join
        //                     from s in s_join.DefaultIfEmpty()
        //                     where
        //                     us.UserID == Userid &&
        //                     (t.Type == 1 ||
        //                     (t.Type == 2 &&
        //                     t.UserID == Userid)
        //                     ||
        //                     (from t0 in db.UserHasSponsorTopics
        //                      where
        //                      t0.UserID == Userid
        //                      select new
        //                      {
        //                          t0.TopicID
        //                      }).Contains(new { t.TopicID }))
        //                     orderby
        //                     s.SpecialtyName,
        //                     t.TopicName
        //                     select new
        //                     {
        //                         SpecialtyName = s.SpecialtyName,
        //                         OrgId = t.TopicID,
        //                         OrgName = t.TopicName,
        //                         OrgType = t.Type,
        //                         SpecialtyID = (System.Int32?)t.SpecialtyID
        //                     }).Distinct().OrderBy(s => s.SpecialtyName);

        //        int SpecId = 0;
        //        string Specname = string.Empty;
        //        foreach (var r in query)
        //        {
        //            if (Specname != r.SpecialtyName)
        //            {
        //                UserTopic.Add(new SelectListItem
        //                {
        //                    Text = "---" + r.SpecialtyName + "---",
        //                    Value = SpecId.ToString()
        //                });
        //                Specname = r.SpecialtyName;
        //            }
        //            else
        //                UserTopic.Add(new SelectListItem
        //                {
        //                    Text = r.OrgName,
        //                    Value = r.OrgId.ToString()
        //                });
        //        }

        //    }
        //    return UserTopic;
        //}

        //#endregion

        #region GetTopicsList
        /// <summary>
        /// GetTopicsList by userID
        /// </summary>
        /// <param name="Userid"></param>
        /// <returns></returns>
        public static List<SelectListItem> GetTopicsList(int Userid)
        {
            List<SelectListItem> UserTopic = new List<SelectListItem>();
            using (EditorsEntities db = new EditorsEntities())
            {
                var UserSpect = (from us in db.UserSpecialties
                                 join spec in db.Specialties on us.SpecialtyID equals spec.SpecialtyID
                                 where us.UserID == Userid
                                 orderby us.DateAdded
                                 select new
                                 {
                                     SpecialtyID = (System.Int32?)us.SpecialtyID,
                                     spec.SpecialtyName
                                 });

                int SpecId = 0;

                foreach (var spect in UserSpect)
                {
                    UserTopic.Add(new SelectListItem
                    {
                        Text = "---" + spect.SpecialtyName + "---",
                        Value = SpecId.ToString()
                    });


                    //var query = (from t in db.Topics
                    //             join us in db.UserSpecialties on t.SpecialtyID equals us.SpecialtyID into us_join
                    //             from us in us_join.DefaultIfEmpty()
                    //             where
                    //             us.UserID == Userid && us.SpecialtyID == spect.SpecialtyID &&
                    //             (t.Type == 1 ||
                    //             (t.Type == 2 &&
                    //             t.UserID == Userid)
                    //             ||
                    //             (from t0 in db.UserHasSponsorTopics
                    //              where
                    //              t0.UserID == Userid
                    //              select new
                    //              {
                    //                  t0.TopicID
                    //              }).Contains(new { t.TopicID }))
                    //             orderby
                    //             t.TopicName
                    //             select new
                    //             {
                    //                 OrgId = t.TopicID,
                    //                 OrgName = t.TopicName

                    //             }).Distinct().OrderBy(s => s.OrgName);

                    var query = (from t in db.Topics
                                 join st in db.SubTopics on t.TopicID equals st.TopicID
                                 where
                                 (t.Type == 1 || (t.Type == 2 && t.UserID == Userid) ||
                                 (t.Type == 3 && (from t0 in db.UserHasSponsorTopics
                                                  where t0.UserID == Userid
                                                  select new
                                                  {
                                                      t0.TopicID
                                                  }).Contains(new { t.TopicID }))) &&
                                    (st.Type != 2 || st.UserID == Userid) && t.SpecialtyID == spect.SpecialtyID &&
                                     !(from t0 in db.HiddenTopics
                                       where t0.UserID == Userid
                                       select new
                                       {
                                           t0.TopicID
                                       }).Contains(new { t.TopicID })
                                 orderby t.TopicName
                                 select new
                                 {
                                     OrgId = (System.Int32?)t.TopicID,
                                     OrgName = t.TopicName
                                 }).Distinct().OrderBy(s => s.OrgName);



                    foreach (var r in query)
                    {
                        UserTopic.Add(new SelectListItem
                            {
                                Text = r.OrgName,
                                Value = r.OrgId.ToString()
                            });
                    }
                }
            }

            return UserTopic;
        }
        #endregion
        #region Copy Citation
        // Copy Citation
        public static int CopyCitation(int MID, string SubTopicId, int UserId, int searchID, short? expireDate, bool KeepDelete)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_CopyUserCitation_MyQueries] @pmid,@SubTopicID,@userid,@SearchID,@ExpireDate,@KeepDelete,@SpecialtyID  OUT";
                var parameters = new[] 
                { 
                    new SqlParameter("@pmid", MID),
                    new SqlParameter("@SubTopicID", SubTopicId),
                    new SqlParameter("@userid", UserId), 
                    new SqlParameter("@SearchID", searchID),
                    new SqlParameter("@ExpireDate", expireDate),
                    new SqlParameter("@KeepDelete", KeepDelete), 
                    new SqlParameter("@SpecialtyID",SqlDbType.Int){ Direction = ParameterDirection.Output }
                };
                var ResRelatedCitations = entity.Database.SqlQuery<RelatedCitatins>(query, parameters).ToList();
                int SpecialtyId;
                SpecialtyId = (Int32)parameters[6].Value;
                return SpecialtyId;
            }
        }

        #endregion

        #region Search Details Abstract

        /// <summary>
        /// Get Abstract by PMID
        /// </summary>
        /// <param name="UserID"></param>
        /// <param name="PMIDList"></param>
        /// <param name="DisplayMode"></param>
        /// <param name="SearchSort"></param>
        /// <returns></returns>
        public static CitationDetailsModel GetCitationabstract(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                CitationDetailsModel result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);

                result = entity.Database.SqlQuery<CitationDetailsModel>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();

                if ((!result.unicodeFixed.HasValue) || (result.unicodeFixed == false))
                {
                    if ((result.ArticleTitle ?? "").Contains("?") || (result.ArticleTitle ?? "").Contains("="))
                    {
                        List<string> ArticleTitleWithNoIssue = MyLibraryBL.GetAbstractWithNoIssue(result.pmid);

                        if (ArticleTitleWithNoIssue.Count == 2)
                        {
                            result.ArticleTitle = ArticleTitleWithNoIssue[1];
                        }
                    }
                }

                string query1 = "[ap_DisplayPMID_AJA_Dev_Detailed] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserID1 = new SqlParameter("@UserID", UserID);
                SqlParameter Pmids1 = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayMode1 = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSort1 = new SqlParameter("@SearchSort", SearchSort);
                var AllCitationDetailsDetailed = entity.Database.SqlQuery<CitationDetailsModelDetail>(query1, UserID1, Pmids1, DisplayMode1, SearchSort1).ToList();

                foreach (CitationDetailsModelDetail Author in AllCitationDetailsDetailed)
                {
                    result.AuthorFullList += Author.DisplayName + ", ";
                }

                result.AuthorFullList = result.AuthorFullList.TrimEnd().TrimEnd(',');


                if ((!result.unicodeFixed.HasValue) || result.unicodeFixed == false)
                {
                    List<string> AbstractArticleTitleNew = MyLibraryBL.GetAbstractWithNoIssue(result.pmid);
                    if (AbstractArticleTitleNew.Count == 2)
                    {
                        int PMID = Convert.ToInt32(result.pmid);
                        var IwideTable = (from iw in entity.iWides where iw.PMID == PMID select iw).FirstOrDefault();

                        if (IwideTable != null)
                        {
                            result.AbstractText = AbstractArticleTitleNew[0];  //AbstractArticleTitleNew[0] is for Abstract Text and AbstractArticleTitleNew[1] is for Article Title;;
                            IwideTable.AbstractText = AbstractArticleTitleNew[0];
                            result.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideTable.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideTable.unicodeFixed = true;

                            entity.Entry(IwideTable).State = EntityState.Modified;
                            entity.SaveChanges();
                        }

                        var IwideNewTable = (from iw in entity.iWideNews where iw.PMID == PMID select iw).FirstOrDefault();

                        if (IwideNewTable != null)
                        {
                            result.AbstractText = AbstractArticleTitleNew[0];
                            IwideNewTable.AbstractText = AbstractArticleTitleNew[0];

                            result.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideNewTable.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideNewTable.unicodeFixed = true;

                            entity.Entry(IwideNewTable).State = EntityState.Modified;
                            entity.SaveChanges();
                        }
                    }
                }

                return result;
            }
        }

        #endregion

        #region Save Search Query
        /// <summary>
        ///  Save or update the search summary table using model values 
        /// </summary>
        /// <param name="Model"></param>
        public static SearchSummary UpdateSearchQuery(ManageQuery Model)
        {
            using (SearchEntities entity = new SearchEntities())
            {
                var obj = entity.SearchSummaries.Where(i => i.SearchID == Model.SearchId).FirstOrDefault();

                if (obj != null)
                {
                    obj.SearchID = Convert.ToInt32(Model.SearchId);
                    obj.Description = Model.Description;
                    obj.SearchName = Model.Name;

                    if (Model.Autosearch == true)
                    {
                        obj.ShelfLife = Convert.ToByte(Model.ShelfLife);
                        obj.Autosearch = Convert.ToByte(Model.Autosearch);
                        obj.ResultsFolder1 = Convert.ToInt32(Model.FolderID);
                        obj.ResultsFolder2 = Model.resultFolder2;
                        obj.KeepDelete = Convert.ToByte(Model.KeepDelete);
                    }

                    entity.SaveChanges();
                }
                return obj;
            }

        }

        #endregion

        public static List<CitationDetailsModel> GetAllCitationAbstract(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {

                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);

                var result = entity.Database.SqlQuery<CitationDetailsModel>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).ToList();

                foreach (var item in result)
                {
                    if ((!item.unicodeFixed.HasValue) || (item.unicodeFixed == false))
                    {
                        if ((item.ArticleTitle ?? "").Contains("?") || (item.ArticleTitle ?? "").Contains("="))
                        {
                            List<string> ArticleTitleWithNoIssue = MyLibraryBL.GetAbstractWithNoIssue(item.pmid);

                            if (ArticleTitleWithNoIssue.Count == 2)
                            {
                                item.ArticleTitle = ArticleTitleWithNoIssue[1];
                            }
                        }
                    }
                }
                return result;
            }
        }
        // To Get Citation Details
        public static List<CitationDetailsModel> GetCitationDetails(List<CitationsModel> CitationsPmids, string sort, int UserId, int displayMode)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                StringBuilder str = new StringBuilder();
                foreach (var item in CitationsPmids)
                {
                    str.Append(item.pmid + ",");
                }

                // For sort order
                short sortorder = 1;
                switch (sort)
                {
                    case "date":
                        sortorder = 1;
                        break;
                    case "authors":
                        sortorder = 2;
                        break;
                    case "title":
                        sortorder = 3;
                        break;
                    case "journal":
                        sortorder = 4;
                        break;
                    default:
                        sortorder = 1;
                        break;
                }

                string PMIDList = str.ToString();
                if (!string.IsNullOrEmpty(PMIDList))
                {
                    PMIDList = PMIDList.Remove(PMIDList.LastIndexOf(','), 1);
                }

                string query = "[ap_DisplayPMID_AJA_Dev] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserID = new SqlParameter("@UserID", UserId);
                SqlParameter Pmids = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayMode = new SqlParameter("@DisplayMode", displayMode);
                SqlParameter SearchSort = new SqlParameter("@SearchSort", sortorder);
                var AllCitationDetails = entity.Database.SqlQuery<CitationDetailsModel>(query, UserID, Pmids, DisplayMode, SearchSort).ToList();

                string query1 = "[ap_DisplayPMID_AJA_Dev_Detailed] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserID1 = new SqlParameter("@UserID", UserId);
                SqlParameter Pmids1 = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayMode1 = new SqlParameter("@DisplayMode", displayMode);
                SqlParameter SearchSort1 = new SqlParameter("@SearchSort", sortorder);
                var AllCitationDetailsDetailed = entity.Database.SqlQuery<CitationDetailsModelDetail>(query1, UserID1, Pmids1, DisplayMode1, SearchSort1).ToList();

                foreach (CitationDetailsModelDetail Author in AllCitationDetailsDetailed)
                {
                    AllCitationDetails[0].AuthorFullList += Author.DisplayName + ", ";
                }

                AllCitationDetails[0].AuthorFullList = AllCitationDetails[0].AuthorFullList.Substring(0, AllCitationDetails[0].AuthorFullList.LastIndexOf(','));

                List<CitationDetailsModel> NonMedLineCitationsList = AllCitationDetails.Where(u => string.IsNullOrEmpty(u.ArticleTitle)).ToList();
                foreach (var item in NonMedLineCitationsList)
                {
                    using (EditorsEntities entityNM = new EditorsEntities())
                    {
                        CitationDetailsModel NMCitation = NonMedLineCitationsList.Find(u => u.pmid == item.pmid);
                        if (NMCitation != null)
                        {
                            NMCitation = (from nm in entityNM.NonMedlineCitations
                                          where nm.PMID == NMCitation.pmid
                                          select new CitationDetailsModel
                                          {
                                              AbstractText = nm.Abstract,
                                              ArticleTitle = nm.ArticleTitle,
                                              AuthorList = nm.AuthorList,
                                              DisplayDate = nm.DisplayDate,
                                              DisplayNotes = nm.DisplayNotes,
                                              MedlinePgn = nm.MedlinePgn,
                                              MedlineTA = nm.MedlineTA,
                                              StatusDisplay = nm.StatusDisplay,
                                              pmid = nm.PMID
                                          }).FirstOrDefault();

                            if (NMCitation != null)
                            {
                                int Index = AllCitationDetails.FindIndex(u => u.pmid == item.pmid);
                                AllCitationDetails.RemoveAt(Index);
                                AllCitationDetails.Insert(Index, NMCitation);
                            }
                        }
                    }
                }
                return AllCitationDetails;
            }
        }

        #region SearchResultsAsterik
        /// <summary>
        /// Get editor commented citation details-- RaviM
        /// </summary>
        /// <param name="p"></param>
        public static int SearchResultHasAsterisk(int p)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int value = (from s in entity.ArticleSelections where s.PMID == p select s.PMID).FirstOrDefault();
                if (value != 0)
                    return value = 1;
                else
                    return value = 0;

            }
        }

        #endregion
    }
}
