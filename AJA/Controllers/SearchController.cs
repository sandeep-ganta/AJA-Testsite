#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using DAL;
using DAL.Entities;
using DAL.Models;
using AJA_Core;
using System.Xml.Linq;
using System.Xml;
using System.Text;

#endregion

namespace AJA.Controllers
{
    [Authorize(Roles = "AJA User")]
    [HandleError]
    public class SearchController : Base_Controller
    {
        //
        // GET: /Search/              

        #region Get Search Using MyQuries
        /// <summary>
        /// Get Search Form-- RaviM
        /// </summary>
        /// <param name="ddlValue"></param>
        /// <returns></returns>
        public ActionResult Search(int? ddlValue)
        {
            int userid = CurrentUser.UserId;
            string x = string.Empty;
            x = SearchBL.GetSearchName(ddlValue);

            SearchBL.SearchForm searchForm = new SearchBL.SearchForm();
            searchForm.SearchName = x;
            if (ddlValue == null || ddlValue == 0)
            {
                searchForm.MyQueries = SearchBL.GetMyQueriesForSearch(userid, ddlValue);
                searchForm.MyQueryValue = Convert.ToInt32(ddlValue);
                return View(searchForm);
            }
            else
            {
                searchForm.ResultQuery = SearchBL.GetSearchQuery(userid, x, ddlValue);
                searchForm.AbstractMask = Convert.ToBoolean(searchForm.ResultQuery.AbstractMask);
                searchForm.MyQueries = SearchBL.GetMyQueriesForSearch(userid, ddlValue);
                searchForm.MyQueryValue = Convert.ToInt32(ddlValue);

                return View(searchForm);
            }

        }
        #endregion

        #region Save Query Help
        public ActionResult save_query_help()
        {
            return View();
        }
        #endregion

        #region Search Post Parameter using Ajax

        /// <summary>
        /// Search posting form values - RaviM
        /// </summary>
        /// <param name="Model"></param>
        /// <returns></returns>
        [HttpPost]
        public ActionResult Search(SearchBL.SearchForm Model)
        {
            Session["SearchLimits"] = null;
            var result = SearchBL.DeleteSearchQuery(CurrentUser.UserId);//no need to check isDeleted or not to Add new search query.
            var newSearchID = SearchBL.SearchQueryAdd(Model, CurrentUser.UserId);
            Model.SearchId = newSearchID;

            Session["SearchLimits"] = Model;

            return Json(true, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region SearchResults

        /// <summary>
        /// Get Search Results View .. Search Post will be done through Ajax method - RaviM
        /// </summary>
        /// <param name="Model"></param>
        /// <returns></returns>
        public ActionResult SearchResults(int start = 1, string range = "20")
        {
            SearchBL.SearchForm obj = new SearchBL.SearchForm();
            if (Session["SearchLimits"] != null)
            {
                SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();
                int userid = CurrentUser.UserId;

                obj = (SearchBL.SearchForm)Session["SearchLimits"];
                int RangeCount = int.Parse(range);
                myQyeryForm.searchInfo = SearchBL.GetSearchInfo(userid, obj.SearchName, Convert.ToInt32(obj.SearchId));

                obj.ArticlesList = SearchBL.SearchFetchRange(userid, obj.SearchName, obj.SearchId, start, start + (RangeCount - 1));
                StringBuilder str = new StringBuilder();

                if (obj.ArticlesList != null)
                {
                    foreach (var item in obj.ArticlesList)
                    {
                        str.Append(item.PMID + ",");
                    }
                }

                string PMIDList = str.ToString();

                if (!string.IsNullOrEmpty(PMIDList))
                {
                    PMIDList = PMIDList.Remove(PMIDList.LastIndexOf(','), 1);
                }
                obj.AllCitationDetails = SearchBL.GetAllCitationAbstract(CurrentUser.UserId, PMIDList, 2, 1);
                obj.QueryDetails = myQyeryForm.searchInfo.QueryDetails;
                obj.ErrorDesc = myQyeryForm.searchInfo.ErrorDesc;
                obj.CitationCount = Convert.ToInt32(myQyeryForm.searchInfo.SearchResultsCount);
                obj.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);

                Session["SearchLimits"] = obj;

                obj.DisplayCount = range;
                if (Session["SearchResults"] != null)
                {
                    SearchBL.SearchForm keep = (SearchBL.SearchForm)Session["SearchResults"];
                    obj.showGoToDestionation = keep.showGoToDestionation; obj.TopicFolderID = keep.FolderID; obj.SpecId = keep.SpecId; obj.resultFolder2 = keep.resultFolder2;
                }

                Session["SearchResults"] = null;
                return View(obj);
            }
            else
            {
                return RedirectToAction("Search", "Search");
            }

            return View(obj);
        }

        #endregion

        #region SaveQuery Get View
        /// <summary>
        /// Get SaveQuery View - RaviM
        /// </summary>
        /// <returns></returns>
        public ActionResult SaveSearchQuery(string searchinfo, int? Sid)
        {
            SearchBL.ManageQuery MQ = new SearchBL.ManageQuery();

            MQ.searchInfo = SearchBL.GetSearchInfo(CurrentUser.UserId, MQ.Name, Convert.ToInt32(Sid));
            MQ.QueryDetails = MQ.searchInfo.QueryDetails;
            MQ.SearchId = Sid;
            MQ.KeepDelete = 0;
            MQ.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);
            return View(MQ);
        }
        #endregion

        #region SaveSearchQuery
        /// <summary>
        /// Saving Search Query-- RaviM
        /// </summary>
        /// <param name="Model"></param>
        /// <param name="Collection"></param>
        /// <returns></returns>
        [HttpPost]
        public ActionResult SaveSearchQueryOrUpdate(SearchBL.ManageQuery Model, FormCollection Collection)
        {
            if (Model != null)
            {
                if (Model.Autosearch == true)
                {
                    if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
                    {
                        Session["SavedQueryDet"] = null;
                        Model.resultFolder2 = Convert.ToInt32(Collection["ddlUserSubTopic"]);
                        Session["SavedQueryDet"] = SearchBL.UpdateSearchQuery(Model);
                        return RedirectToAction("SaveQuery_Complete", "Search", new { SearID = Model.SearchId, subtopicID = Model.resultFolder2 });
                    }
                    else
                    {
                        alert(new MyResult() { Tittle = "Save Query", Message = "Please specify a destination folder.", restype = false });
                        return RedirectToAction("SaveSearchQuery", "Search", new { searchinfo = Model.QueryDetails, Sid = Model.SearchId });
                    }
                }
                else
                {
                    Session["SavedQueryDet"] = null;
                    Session["SavedQueryDet"] = SearchBL.UpdateSearchQuery(Model);
                    return RedirectToAction("SaveQuery_Complete", "Search", new { SearID = Model.SearchId, subtopicID = Model.resultFolder2 });
                }

            }
            return View(Model);
        }

        #endregion

        #region SaveQuery_Complete
        /// <summary>
        /// Search Query After Saving View-- RaviM
        /// </summary>
        /// <param name="SearID"></param>
        /// <param name="subtopicID"></param>
        /// <returns></returns>
        public ActionResult SaveQuery_Complete(int? SearID, int? subtopicID)
        {
            SearchBL.ManageQuery form = new SearchBL.ManageQuery();
            form.searchInfo = SearchBL.GetSearchInfo(CurrentUser.UserId, form.Name, Convert.ToInt32(SearID));
            form.QueryDetails = form.searchInfo.QueryDetails;
            var ss = (SearchSummary)Session["SavedQueryDet"];
            form.SearchId = SearID;
            if (ss != null)
            {
                form.Description = ss.Description;
                form.Name = ss.SearchName;
                form.ShelfLife = ss.ShelfLife.ToString();
            }
            form.resultFolder2 = Convert.ToInt32(subtopicID);
            if (subtopicID != 0)
                form.queryDestination = SearchBL.GetQueryDestination(Convert.ToInt32(subtopicID));
            return View(form);
        }

        #endregion

        #region SearchDetials
        /// <summary>
        /// Get the search details based on PMID - RaviM
        /// </summary>
        /// <param name="PMID"></param>
        /// <returns></returns>
        public ActionResult SearchDetails(int? PMID, bool FromPMedline = false)
        {
            int ID = Convert.ToInt32(PMID);
            SearchBL.SearchForm obj = new SearchBL.SearchForm();
            obj.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);
            obj.AbstractCommentsECList = MyLibraryBL.GetAbstractCommentsEC(ID);
            obj.CitationDetails = SearchBL.GetCitationabstract(CurrentUser.UserId, ID.ToString(), 2, 1);
            obj.SearchId = obj.SearchId;
            obj.PMID = ID;
            obj.FolderID = 0;
            if (FromPMedline)
                obj.FromPMedline = true;

            return View(obj);

        }

        #endregion

        #region Keep Citation
        /// <summary>
        /// Keep the checked Citations in - RaviM
        /// </summary>
        /// <param name="keep"></param>
        /// <returns></returns>
        public ActionResult Action(SearchBL.SearchForm keep)
        {
            if (keep.Parameters != null)
            {
                string[] PMIDList = keep.Parameters.Split(',');
                if (keep.resultFolder2 != null)
                {
                    foreach (string pmid in PMIDList)
                    {
                        var Result = SearchBL.CopyCitation(Convert.ToInt32(pmid), keep.resultFolder2, CurrentUser.UserId, keep.SearchId, Convert.ToInt16(keep.DateEnd), true);
                        keep.SpecId = Result;
                        keep.showGoToDestionation = true;
                        Session["SearchResults"] = keep;
                    }
                    return RedirectToAction("SearchResults", "Search");
                }
            }
            return View(keep);
        }

        #endregion

        #region Search Details CopyCitation
        /// <summary>
        /// Copy Citations to library Folder.  - RaviM
        /// </summary>
        /// <param name="Model"></param>
        /// <param name="MID"></param>
        /// <param name="Collection"></param>
        /// <param name="start"></param>
        /// <returns></returns>
        public ActionResult CopyCitation(SearchBL.SearchForm Model, int MID, FormCollection Collection, int start = 1)
        {
            bool keepDelete;

            if (Collection["KeepDelete"] == "0")
                keepDelete = false;
            else
                keepDelete = true;

            short? DateEnd = Convert.ToInt16(Collection["dateEnd"]);

            if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
            {
                var Result = SearchBL.CopyCitation(MID, Collection["ddlUserSubTopic"], CurrentUser.UserId, Convert.ToInt32(Collection["SearchId"]), DateEnd, keepDelete);

                return RedirectToAction("index", "mylibrary", new { specid = Result, oid = Model.FolderID, fid = Collection["ddlUserSubTopic"], selaction = "saved", start = start });
            }
            else
            {
                alert(new MyResult() { Tittle = "Copy Citiations", Message = "Select Sub Topic", restype = false });
                return RedirectToAction("SearchDetails", "Search", new { PMID = MID });
            }

            return RedirectToAction("SearchDetails", "Search", new { PMID = MID });
        }


        #endregion

        #region SearchFulltextLinkout
        /// <summary>
        /// SearchFullText Linkout using PMID - RaviM
        /// </summary>
        /// <param name="PMID"></param>
        /// <returns></returns>
        public ActionResult SearchFullTextLinkout(int PMID = 0, bool FromPMedline = false)
        {
            SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();

            string Query = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?tool=CogentMedicineWebSite&email=cogentmedicine@acr.org&dbfrom=pubmed&id=" + PMID + "&cmd=llinkslib";

            EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);

            XmlDocument xdoc = new XmlDocument();
            xdoc.Load(Query);
            XDocument doc = XDocument.Load(Query);
            if (xdoc != null)
            {
                XmlNodeList xNodes = xdoc.DocumentElement.GetElementsByTagName("ObjUrl");

                List<FullTextLinkOuts> XMLDataList = new List<FullTextLinkOuts>();
                List<FullTextLinkOuts> Aggregatorslist = new List<FullTextLinkOuts>();
                List<FullTextLinkOuts> ProvList = new List<FullTextLinkOuts>();

                string str = string.Empty;

                foreach (XmlNode dStr in xNodes)
                {
                    FullTextLinkOuts XMLData = new FullTextLinkOuts();

                    XmlNode SubTypeNode = dStr.SelectSingleNode("SubjectType");

                    if (SubTypeNode != null)
                    {
                        if (SubTypeNode.InnerText.ToLower() == "publishers/providers")
                        {
                            var Description = xdoc.SelectNodes("eLinkResult/LinkSet/IdUrlList/IdUrlSet/ObjUrl/Attribute");
                            XMLData.ProviderName = ((dStr.LastChild).FirstChild).InnerText;
                            XMLData.URLS = (dStr.FirstChild).InnerText;
                            ProvList.Add(XMLData);
                        }
                        else if (SubTypeNode.InnerText.ToLower() == "aggregators")
                        {
                            string Description = xdoc.SelectSingleNode("eLinkResult/LinkSet/IdUrlList/IdUrlSet/ObjUrl/Attribute").InnerText;

                            XMLData.ProviderName = ((dStr.LastChild).FirstChild).InnerText;
                            XMLData.URLS = (dStr.FirstChild).InnerText;
                            Aggregatorslist.Add(XMLData);
                        }
                        else
                        {
                            str = (dStr.FirstChild).InnerText;

                            if (str.Substring(0, 1) == "/")
                            {
                                str = "http://www.ncbi.nlm.nih.gov" + str;
                            }
                            XMLData.URLS = str;
                            XMLData.ProviderName = ((dStr.LastChild).FirstChild).InnerText;

                            XMLDataList.Add(XMLData);
                        }
                    }
                }

                citations.linklist = XMLDataList;
                citations.ProviderPublis = ProvList;
                citations.Aggregator = Aggregatorslist;
            }

            citations.PMID = Convert.ToInt32(PMID);
            myQyeryForm.LinkoutModelVar = citations;
            if (FromPMedline)
                myQyeryForm.FromPMedline = true;
            return View(myQyeryForm);
        }

        #endregion

        #region AbstractPrintable
        /// <summary>
        /// Get Printable Citation and comments if any
        /// </summary>
        /// <param name="PMID"></param>
        /// <returns></returns>        
        public ActionResult AbstractPrintable(int specid = 0, int oid = 0, int fid = 0, string selaction = null, string sort = "date", string searchfolder = "", int MID = 0, bool FromPMedline = false)
        {
            int qsSpecId = specid;
            MyLibraryModel MainMyLibraryModel = new MyLibraryModel();

            if (MID != 0)
            {
                CitationsModel pmid = new CitationsModel();
                pmid.pmid = MID;
                List<CitationsModel> PMIDCitation = new List<CitationsModel>();
                PMIDCitation.Add(pmid);
                MainMyLibraryModel.CitationDetails = MyLibraryBL.GetCitationDetails(PMIDCitation, sort, CurrentUser.UserId, 2, true);
                MainMyLibraryModel.UserComment = MyLibraryBL.GetUserComment(MID, CurrentUser.UserId);
                MainMyLibraryModel.AbstractCommentsECList = MyLibraryBL.GetAbstractCommentsEC(MID);
            }
            MainMyLibraryModel.PMID = MID;
            if (FromPMedline)
                MainMyLibraryModel.FromPMedline = true;
            return View(MainMyLibraryModel);
        }
        #endregion

    }
}
