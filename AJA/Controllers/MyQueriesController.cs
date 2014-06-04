using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using DAL.Models;
using AJA_Core;
using System.Xml;
using System.Xml.Linq;

namespace AJA.Controllers
{
    [HandleError]
    [Authorize(Roles = "AJA User")]
    public class MyQueriesController : Base_Controller
    {
        //
        // GET: /MyQueries/

        #region

        public ActionResult MyQueries(int? FID, int? searchid, string SearchName, string searchfolder = "", int start = 1)
        {
            int userid = AJA_Core.CurrentUser.UserId;
            SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();
            List<SearchBL.MyQueryForm> myQueriesList = new List<SearchBL.MyQueryForm>();
            myQueriesList = SearchBL.MyQueriesList(userid);
            myQyeryForm.myQueriesList = myQueriesList;
            myQyeryForm.Isendemail = SearchBL.GetIsSendEmail(userid);
            if (searchid != 0 && !string.IsNullOrEmpty(SearchName))
            {
                myQyeryForm.queryDetails = SearchBL.GetSearchQuery(userid, SearchName, searchid);
                myQyeryForm.searchInfo = SearchBL.GetSearchInfo(userid, SearchName, Convert.ToInt32(searchid));
                SearchBL.ManageQuery MQ = new SearchBL.ManageQuery();
                MQ.SearchId = searchid; MQ.QueryDetails = myQyeryForm.searchInfo.QueryDetails; MQ.Name = myQyeryForm.queryDetails.SearchName;
                MQ.Description = myQyeryForm.queryDetails.Description; MQ.Autosearch = Convert.ToBoolean(myQyeryForm.queryDetails.AutoSearch);
                MQ.KeepDelete = Convert.ToInt32(myQyeryForm.queryDetails.KeepDelete);
                MQ.ShelfLife = myQyeryForm.queryDetails.ShelfLife.ToString();

                if (FID != 0)
                {
                    myQyeryForm.queryDestination = SearchBL.GetQueryDestination(Convert.ToInt32(FID));
                    MQ.FolderID = FID;
                    if (myQyeryForm.queryDestination != null)
                        MQ.DestinationFolder = myQyeryForm.queryDestination.SpecialtyName + " / " + myQyeryForm.queryDestination.TopicName + " / " + myQyeryForm.queryDestination.SubTopicName;

                    myQyeryForm.Citations = SearchBL.GetSearchCitations(Convert.ToInt32(searchid), CurrentUser.UserId);

                    if (myQyeryForm.Citations.Count > 0)
                    {
                        myQyeryForm.CitationDetails = MyLibraryBL.GetCitationDetails(myQyeryForm.Citations, "date", CurrentUser.UserId, 1);
                        TimeSpan timespan = (DateTime.Now - Convert.ToDateTime(myQyeryForm.Citations[0].expiredate));
                        if (myQyeryForm.Citations[0].keepdelete)
                            myQyeryForm.TrackDays = timespan.Days.ToString() + " days until keep";
                        else
                            myQyeryForm.TrackDays = timespan.Days.ToString() + " days until delete";
                    }
                    else
                    {
                        myQyeryForm.CitationDetails = null;
                    }

                }
                if (!string.IsNullOrEmpty(searchfolder))
                {
                    myQyeryForm.CitationDetails = myQyeryForm.CitationDetails.Where(c => c.pmid.ToString() == searchfolder || (c.AuthorList ?? "").Contains(searchfolder) || (c.ArticleTitle ?? "").Contains(searchfolder) || (c.MedlinePgn ?? "").Contains(searchfolder) || (c.MedlineTA ?? "").Contains(searchfolder)).ToList();
                }
                if (myQyeryForm.CitationDetails != null)
                {
                    myQyeryForm.CitationDetailsTotal = myQyeryForm.CitationDetails;
                    myQyeryForm.CitationDetails = myQyeryForm.CitationDetailsTotal.Skip(start - 1).Take(15).ToList();
                }

                Session["ManageQuery"] = MQ;
            }
            return View(myQyeryForm);
        }
        #endregion

        [HttpPost]
        public JsonResult updateUserProfile(int UserId, bool IsSendEmail)
        {
            return Json(SearchBL.updateUserProfile(UserId, IsSendEmail));
        }

        public ActionResult ManageQuery(int? SearchID)
        {
            SearchBL.ManageQuery MQ = new SearchBL.ManageQuery();
            if (Session["ManageQuery"] != null)
            {
                MQ = Session["ManageQuery"] as SearchBL.ManageQuery;
                MQ.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);
            }
            return View("ManageQuery", MQ);
        }


        public ActionResult DeleteQuery()
        {
            int UserID = AJA_Core.CurrentUser.UserId;
            int SearchID = Convert.ToInt32((Session["ManageQuery"] as SearchBL.ManageQuery).SearchId);
            bool delQuery = SearchBL.DeleteQuery(SearchID, UserID);
            alert(new MyResult() { Tittle = "Delete Query", Message = "Query Deleted Successfully", restype = true });
            return RedirectToAction("MyQueries", "MyQueries");
        }

        [HttpPost]
        public ActionResult UpdateManageQuery(SearchBL.ManageQuery MQ, FormCollection Collection)
        {
            if (MQ != null)
            {
                if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
                    MQ.resultFolder2 = Convert.ToInt32(Collection["ddlUserSubTopic"]);
                if (MQ.Autosearch)
                {
                    if (!String.IsNullOrEmpty(MQ.DestinationFolder))
                    {
                        SearchBL.SaveQuery(MQ);
                        alert(new MyResult() { Tittle = "Update Query", Message = "Query Saved Successfully", restype = true });
                        return RedirectToAction("MyQueries", "MyQueries");
                    }
                    else if (MQ.FolderID == null || MQ.FolderID == 0 || MQ.resultFolder2 == null || MQ.resultFolder2 == 0)
                    {
                        alert(new MyResult() { Tittle = "Manage Query", Message = "select a results folder", restype = true });
                        MQ.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);
                        return RedirectToAction("ManageQuery", MQ);
                    }
                    else
                    {
                        SearchBL.SaveQuery(MQ);
                        alert(new MyResult() { Tittle = "Update Query", Message = "Query Saved Successfully", restype = true });
                        return RedirectToAction("MyQueries", "MyQueries");
                    }
                }
                else
                {
                    SearchBL.SaveQuery(MQ);
                    alert(new MyResult() { Tittle = "Update Query", Message = "Query Saved Successfully", restype = true });
                    return RedirectToAction("MyQueries", "MyQueries");
                }

            }

            return RedirectToAction("MyQueries", "MyQueries");
        }


        public ActionResult QueryCitationAbstract(string sort = "date", string searchfolder = "", int MID = 0, int Search = 0)
        {
            SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();

            List<SearchBL.MyQueryForm> myQueriesList = new List<SearchBL.MyQueryForm>();
            myQueriesList = SearchBL.MyQueriesList(CurrentUser.UserId);
            myQyeryForm.myQueriesList = myQueriesList;

            myQyeryForm.Isendemail = SearchBL.GetIsSendEmail(CurrentUser.UserId);
            myQyeryForm.TopicsList = SearchBL.GetTopicsList(CurrentUser.UserId);
            if (MID != 0)
            {
                CitationsModel pmid = new CitationsModel();
                pmid.pmid = MID;
                List<CitationsModel> PMIDCitation = new List<CitationsModel>();
                PMIDCitation.Add(pmid);
                myQyeryForm.CitationDetails = SearchBL.GetCitationDetails(PMIDCitation, sort, CurrentUser.UserId, 2);
                myQyeryForm.UserComment = MyLibraryBL.GetUserComment(MID, CurrentUser.UserId);
                myQyeryForm.AbstractCommentsECList = MyLibraryBL.GetAbstractCommentsEC(MID);
                myQyeryForm.SearchID = Search; myQyeryForm.queryDetails = SearchBL.GetSearchQuery(CurrentUser.UserId, "", Search);
            }
            return View(myQyeryForm);
        }

        public ActionResult AbstractPrintable(string sort = "date", string searchfolder = "", int MID = 0)
        {
            SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();


            if (MID != 0)
            {
                CitationsModel pmid = new CitationsModel();
                pmid.pmid = MID;
                List<CitationsModel> PMIDCitation = new List<CitationsModel>();
                PMIDCitation.Add(pmid);
                myQyeryForm.CitationDetails = SearchBL.GetCitationDetails(PMIDCitation, sort, CurrentUser.UserId, 2);
                myQyeryForm.UserComment = MyLibraryBL.GetUserComment(MID, CurrentUser.UserId);
                myQyeryForm.AbstractCommentsECList = MyLibraryBL.GetAbstractCommentsEC(MID);
            }
            return View(myQyeryForm);
        }

        public ActionResult LinkOut(string SearchID,int PMID = 0)
        {
            SearchBL.MyQueryForm myQyeryForm = new SearchBL.MyQueryForm();

            string Query = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?tool=CogentMedicineWebSite&email=cogentmedicine@acr.org&dbfrom=pubmed&id=" + PMID + "&cmd=llinkslib";

            EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);
            // citations.SpecialtyID = Convert.ToInt32(SpecialityID);
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
            //  citations.SpecialtyID = Convert.ToInt32(SpecialityID);
            citations.PMID = Convert.ToInt32(PMID);
            myQyeryForm.LinkoutModelVar = citations;
            myQyeryForm.LinkoutModelVar.SearchID = SearchID;
            return View(myQyeryForm);
        }



        //[HttpPost]
        public ActionResult SearchFolder(FormCollection collection)
        {
            return RedirectToAction("MyQueries", new { FID = collection["FID"], searchid = collection["searchid"], SearchName = collection["SearchName"], sort = "Date", searchfolder = collection["search"], start = 1 });
        }


        public ActionResult keepcitation(int MID, int FID, int Search, string searchName)
        {
            if (FID > 0)
            {
                SearchBL.KeepMyQueryCitation(CurrentUser.UserId, MID, FID);
            }
            return RedirectToAction("MyQueries", new { FID = FID, searchid = Search, SearchName = searchName, sort = "Date", start = 1 });
        }

        public ActionResult Deletecitation(int MID, int FID, int Search, string searchName)
        {
            if (FID > 0)
            {
                SearchBL.DeleteMyQueryCitation(CurrentUser.UserId, MID, FID);
            }
            return RedirectToAction("MyQueries", new { FID = FID, searchid = Search, SearchName = searchName, sort = "Date", start = 1 });
        }

        public ActionResult keepAllCitations(int searchID)
        {
            if (searchID > 0)
                SearchBL.KeepAllMyQueryCitations(CurrentUser.UserId, searchID);
            return RedirectToAction("MyQueries", "MyQueries");
        }

        public ActionResult DeleteAllCitations(int searchID)
        {
            if (searchID > 0)
                SearchBL.DeleteAllMyQueryCitations(CurrentUser.UserId, searchID);
            return RedirectToAction("MyQueries", "MyQueries");
        }


        public ActionResult CopyCitation(SearchBL.MyQueryForm Model, string actionFirst, string actionSecond, int MID, FormCollection Collection, int start = 1)
        {
            //int specid , oid,fid;
            bool keepDelete;
            if (Collection["KeepDelete"] == "0")
                keepDelete = false;
            else
                keepDelete = true;

            short? DateEnd = Convert.ToInt16(Collection["dateEnd"]);

            if (actionFirst != null)
            {
                if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
                {
                    var Result = SearchBL.CopyCitation(MID, Collection["ddlUserSubTopic"], CurrentUser.UserId, Convert.ToInt32(Collection["SearchId"]), DateEnd, keepDelete);

                    return RedirectToAction("index", "mylibrary", new { specid = Result, oid = Model.FolderID, fid = Collection["ddlUserSubTopic"], selaction = "saved", start = start });

                }
                else
                {
                    return RedirectToAction("QueryCitationAbstract", "MyQueries", new { MID = MID });
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(Collection["ddlUserSubTopicSecond"]))
                {
                    var Result = SearchBL.CopyCitation(MID, Collection["ddlUserSubTopicSecond"], CurrentUser.UserId, Convert.ToInt32(Collection["SearchId"]), DateEnd, keepDelete);

                    return RedirectToAction("index", "mylibrary", new { specid = Result, oid = Model.FolderID, fid = Collection["ddlUserSubTopicSecond"], selaction = "saved", start = start });
                }
                else
                {
                    return RedirectToAction("QueryCitationAbstract", "MyQueries", new { MID = MID });
                }
            }
        }
    }
}
