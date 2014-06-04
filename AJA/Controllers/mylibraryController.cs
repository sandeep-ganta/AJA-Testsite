using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using DAL;
using DAL.Entities;
using DAL.Models;
using AJA_Core;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Xml.XPath;
using System.Data;

namespace AJA.Controllers
{
    [Authorize(Roles = "AJA User")]
    public class mylibraryController : Base_Controller
    {
        //
        // GET: /mylibrary/
        public ActionResult Index(int specid = 0, int oid = 0, int fid = 0, string selaction = null, string sort = "date", string searchfolder = "", string page = "", int start = 1)
        {
            int qsSpecId = specid;
            MyLibraryModel MainMyLibraryModel = new MyLibraryModel();
            var UserSpecialityList = MyLibraryBL.GetUserSpecialities(CurrentUser.UserId);
            if (qsSpecId == 0)
            {
                qsSpecId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();
            }
            var UserFolderList = MyLibraryBL.GetUserFolderList(qsSpecId, CurrentUser.UserId);
            MainMyLibraryModel.AllUserFolders = UserFolderList;
            MainMyLibraryModel.AllUserSpecialities = UserSpecialityList;
            ViewBag.SpecId = qsSpecId;
            ViewBag.PrimarySpecialityId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();

            // For Citation          

            if (selaction == "saved")
            {
                MainMyLibraryModel.Citations = MyLibraryBL.GetCitations(fid, CurrentUser.UserId);
                if (MainMyLibraryModel.Citations.Count > 0)
                {
                    MainMyLibraryModel.CitationDetails = MyLibraryBL.GetCitationDetails(MainMyLibraryModel.Citations, sort, CurrentUser.UserId, 2);
                }
                else
                {
                    MainMyLibraryModel.CitationDetails = null;
                }
            }
            else if (selaction == "editor")
            {
                MainMyLibraryModel.PMIDs = MyLibraryBL.GetEditorsChoicePMids(fid);
                MainMyLibraryModel.Citations = MyLibraryBL.GetEditorsChoiceCitations(fid, CurrentUser.UserId);
                if (MainMyLibraryModel.Citations.Count > 0)
                {
                    MainMyLibraryModel.CitationDetails = MyLibraryBL.GetCitationDetails(MainMyLibraryModel.Citations, sort, CurrentUser.UserId, 2);
                }
                else
                {
                    MainMyLibraryModel.CitationDetails = null;
                }
            }

            else if (selaction == "seminal")
            {
                MainMyLibraryModel.PMIDs = MyLibraryBL.GetSeminalPMids(fid);
                MainMyLibraryModel.Citations = MyLibraryBL.GetSeminalCitations(fid, CurrentUser.UserId);
                if (MainMyLibraryModel.Citations.Count > 0)
                {
                    MainMyLibraryModel.CitationDetails = MyLibraryBL.GetCitationDetails(MainMyLibraryModel.Citations, sort, CurrentUser.UserId, 2);
                }
                else
                {
                    MainMyLibraryModel.CitationDetails = null;
                }
            }

            else if (selaction == "sponsor")
            {
                MainMyLibraryModel.PMIDs = MyLibraryBL.GetSponsorPMids(fid);
                MainMyLibraryModel.Citations = MyLibraryBL.GetSponsorCitations(fid, CurrentUser.UserId);
                if (MainMyLibraryModel.Citations.Count > 0)
                {
                    MainMyLibraryModel.CitationDetails = MyLibraryBL.GetCitationDetails(MainMyLibraryModel.Citations, sort, CurrentUser.UserId, 2);
                }
                else
                {
                    MainMyLibraryModel.CitationDetails = null;
                }
            }

            else if (selaction == "acr")
            {
                MainMyLibraryModel.AcrDocumentsMyLibraryList = MyLibraryBL.getAcrDocumentsList(fid);
            }

            if (!string.IsNullOrEmpty(searchfolder))
            {
                MainMyLibraryModel.CitationDetails = MainMyLibraryModel.CitationDetails.Where(c => c.pmid.ToString() == searchfolder || (c.AuthorList ?? "").Contains(searchfolder) || (c.ArticleTitle ?? "").Contains(searchfolder) || (c.MedlinePgn ?? "").Contains(searchfolder) || (c.MedlineTA ?? "").Contains(searchfolder)).ToList();
            }

            if (MainMyLibraryModel.CitationDetails != null)
            {
                MainMyLibraryModel.CitationDetailsTotal = MainMyLibraryModel.CitationDetails;
                MainMyLibraryModel.CitationDetails = MainMyLibraryModel.CitationDetailsTotal.Skip(start - 1).Take(25).ToList();

                using (Cogent3Entities entity = new Cogent3Entities())
                {


                    foreach (var item in MainMyLibraryModel.CitationDetails)
                    {
                        if ((!item.unicodeFixed.HasValue) || (item.unicodeFixed == false))
                        {
                            if ((item.ArticleTitle ?? "").Contains("?") || (item.ArticleTitle ?? "").Contains("="))
                            {
                                List<string> ArticleTitleWithNoIssue = MyLibraryBL.GetAbstractWithNoIssue(item.pmid);

                                if (ArticleTitleWithNoIssue.Count == 2)
                                {
                                    item.ArticleTitle = ArticleTitleWithNoIssue[1];

                                    int PMID = Convert.ToInt32(item.pmid);
                                    var IwideTable = (from iw in entity.iWides where iw.PMID == item.pmid select iw).FirstOrDefault();

                                    if (IwideTable != null)
                                    {                                    //AbstractArticleTitleNew[0] is for Abstract Text and AbstractArticleTitleNew[1] is for Article Title;;

                                        item.ArticleTitle = ArticleTitleWithNoIssue[1];
                                        IwideTable.ArticleTitle = ArticleTitleWithNoIssue[1];
                                        entity.Entry(IwideTable).State = EntityState.Modified;
                                    }

                                    var IwideNewTable = (from iw in entity.iWideNews where iw.PMID == item.pmid select iw).FirstOrDefault();

                                    if (IwideNewTable != null)
                                    {
                                        item.ArticleTitle = ArticleTitleWithNoIssue[1];
                                        IwideNewTable.ArticleTitle = ArticleTitleWithNoIssue[1];
                                        entity.Entry(IwideNewTable).State = EntityState.Modified;
                                    }
                                }
                            }
                        }
                    }

                    entity.SaveChanges();
                }
            }

            return View(MainMyLibraryModel);
        }


        [HttpPost]
        public ActionResult SearchFolder(FormCollection collection)
        {
            return RedirectToAction("Index", new { specid = collection["searchspecid"], oid = collection["searchoid"], fid = collection["searchfid"], selaction = collection["searchselaction"], sort = "Date", searchfolder = collection["search"], start = 1 });
        }

        // To Add Spocsor Folder
        //public ActionResult CreateSposorFolder(int sponsorFolderId)
        //{
        //    var Result = MyLibraryBL.AddSponsorFolder(sponsorFolderId, CurrentUser.UserId);
        //    return RedirectToAction("index");
        //}


        public ActionResult DeleteCitation(int specid = 0, int oid = 0, int fid = 0, string selaction = null, string sort = "date", int MID = 0, int start = 1)
        {
            var Result = MyLibraryBL.DeleteCitation(fid, MID, CurrentUser.UserId);
            return RedirectToAction("Index", new { specid = specid, oid = oid, fid = fid, selaction = "saved", start = start });
        }


        public ActionResult Abstract(int specid = 0, int oid = 0, int fid = 0, string selaction = null, string sort = "date", string searchfolder = "", int MID = 0)
        {
            int qsSpecId = specid;
            MyLibraryModel MainMyLibraryModel = new MyLibraryModel();
            var UserSpecialityList = MyLibraryBL.GetUserSpecialities(CurrentUser.UserId);
            if (qsSpecId == 0)
            {
                qsSpecId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();
            }
            var UserFolderList = MyLibraryBL.GetUserFolderList(qsSpecId, CurrentUser.UserId);
            MainMyLibraryModel.AllUserFolders = UserFolderList;
            MainMyLibraryModel.AllUserSpecialities = UserSpecialityList;
            ViewBag.SpecId = qsSpecId;
            ViewBag.PrimarySpecialityId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();

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
            return View(MainMyLibraryModel);
        }


        public ActionResult AbstractPrintable(int specid = 0, int oid = 0, int fid = 0, string selaction = null, string sort = "date", string searchfolder = "", int MID = 0)
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
            return View(MainMyLibraryModel);
        }



        public ActionResult EditLibrary(int specid = 0)
        {
            int qsSpecId = specid;
            MyLibraryModel MainMyLibraryModel = new MyLibraryModel();
            var UserSpecialityList = MyLibraryBL.GetUserSpecialities(CurrentUser.UserId);
            if (qsSpecId == 0)
            {
                qsSpecId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();
            }
            var UserFolderList = MyLibraryBL.GetUserFolderListEdit(qsSpecId, CurrentUser.UserId);
            MainMyLibraryModel.AllUserFoldersEdit = UserFolderList;
            MainMyLibraryModel.AllUserSpecialities = UserSpecialityList;
            MainMyLibraryModel.HiddenTopicIds = MyLibraryBL.GetHiddenTopicIds(CurrentUser.UserId);
            MainMyLibraryModel.HiddenSubTopicIds = MyLibraryBL.GetHiddenSubTopicIds(CurrentUser.UserId);
            ViewBag.SpecId = qsSpecId;
            ViewBag.DefaultSpecId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();
            return View(MainMyLibraryModel);
        }

        [HttpPost]
        public ActionResult EditLibrary(string btnAddTopic, string btnAddSubTopic, string btnShowFolder, string btnHideFolder, FormCollection collection)
        {
            string SpecialityId = collection["DisplaySpecialityId"];


            if (btnAddTopic != null)
            {
                switch (btnAddTopic)
                {
                    case "Add":
                        if (!string.IsNullOrEmpty(collection["FolderName0"].Trim()))
                        {
                            var Result = MyLibraryBL.AddTopic(int.Parse(SpecialityId), collection["FolderName0"], CurrentUser.UserId);
                        }
                        break;
                }
            }
            if (btnAddSubTopic != null)
            {
                string TopicId = collection["FolderParent"];
                string SubTopicName = collection["FolderName" + TopicId];
                switch (btnAddSubTopic)
                {
                    case "Add":
                        if (!string.IsNullOrEmpty(SubTopicName.Trim()))
                        {
                            var Result = MyLibraryBL.AddSubTopic(TopicId, SubTopicName, CurrentUser.UserId);
                        }
                        break;
                }
            }

            // For Hiding User Topics and User SubTopics
            if (btnHideFolder != null)
            {
                if (collection["TopicIdCheckboxList"] != null)
                {
                    // Checking Selected Topics and Displying Hide
                    var TopicIdCheckboxList = collection["TopicIdCheckboxList"];
                    List<int> TopicIds = new List<int>(TopicIdCheckboxList.Split(',').Select(int.Parse));
                    MyLibraryBL.HideTopics(TopicIds, CurrentUser.UserId);
                }

                // Checking Selected SubTopics and Displying Hide
                if (collection["SubTopicIdCheckboxList"] != null)
                {
                    var SubTopicIdCheckboxList = collection["SubTopicIdCheckboxList"];
                    List<int> SubTopicIds = new List<int>(SubTopicIdCheckboxList.Split(',').Select(int.Parse));
                    MyLibraryBL.HideSubTopics(SubTopicIds, CurrentUser.UserId);
                }

            }

            // For Showing User Topics and User SubTopics
            if (btnShowFolder != null)
            {
                // For Topics Show Folder                
                if (collection["TopicIdCheckboxList"] != null)
                {
                    var TopicIdCheckboxList = collection["TopicIdCheckboxList"];
                    List<int> TopicIds = new List<int>(TopicIdCheckboxList.Split(',').Select(int.Parse));
                    MyLibraryBL.ShowTopics(TopicIds, CurrentUser.UserId);
                }

                // Checking Selected SubTopics and Displying Hide
                if (collection["SubTopicIdCheckboxList"] != null)
                {
                    var SubTopicIdCheckboxList = collection["SubTopicIdCheckboxList"];
                    List<int> SubTopicIds = new List<int>(SubTopicIdCheckboxList.Split(',').Select(int.Parse));
                    MyLibraryBL.ShowSubTopics(SubTopicIds, CurrentUser.UserId);
                }
            }
            return RedirectToAction("EditLibrary", new { specid = SpecialityId });
        }



        // For Delete User SubTopic
        public ActionResult DeleteUserSubTopic(string DisplaySpecialityId, int TopicId, int FolderId)
        {
            var Result = MyLibraryBL.DeleteSubTopic(FolderId, CurrentUser.UserId); // FolderId means SubTopicId here
            return RedirectToAction("EditLibrary", new { specid = DisplaySpecialityId });
        }

        public ActionResult DeleteUserTopic(string DisplaySpecialityId, int TopicId)
        {
            var Result = MyLibraryBL.DeleteTopic(TopicId, CurrentUser.UserId);
            return RedirectToAction("EditLibrary", new { specid = DisplaySpecialityId });
        }

        // To Remove User SpopcsorTopic
        public ActionResult DeleteUserSponsorTopic(string DisplaySpecialityId, int TopicId)
        {
            var Result = MyLibraryBL.DeleteSponsorTopic(TopicId, CurrentUser.UserId);
            return RedirectToAction("EditLibrary", new { specid = DisplaySpecialityId });
        }


        // For Deleitng UserSpecialty

        public ActionResult DeleteSpecialty(int specid)
        {
            var Result = MyLibraryBL.DeleteSpecialty(specid, CurrentUser.UserId);

            int SpecId = MyLibraryBL.GetUserSpecialities(CurrentUser.UserId).Select(n => n.SpecialityId).FirstOrDefault();

            return RedirectToAction("EditLibrary", new { specid = SpecId });
        }


        public ActionResult GetSpecialty()
        {
            var UserSpecialtyList = MyLibraryBL.GetUserSpecialtyList(CurrentUser.UserId);

            GetUserSpecialtyModel Model = new GetUserSpecialtyModel();
            Model.UserSpecialtyListDropDwon = UserSpecialtyList.Select(s => new SelectListItem
                {
                    Value = s.SpecialtyId.ToString(),
                    Text = s.SpecialtyName
                });
            return PartialView(Model);
        }

        [HttpPost]
        public ActionResult GetSpecialty(GetUserSpecialtyModel Model)
        {
            var Result = MyLibraryBL.AddUserSpecialty(Model, CurrentUser.UserId);
            return RedirectToAction("editlibrary", new { specid = Model.SelectedSpecialtyId });
        }

        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetUserSubTopics(int TopicId)
        {
            List<SelectListItem> UserSubTopics = MyLibraryBL.GetUserSubTopics(TopicId, CurrentUser.UserId);
            return Json(UserSubTopics, JsonRequestBehavior.AllowGet);
        }

        // CopyCitaion PostMethod
        [HttpPost]
        public ActionResult CopyCitation(MyLibraryModel Model, int specid, string actionFirst, string actionSecond, int oid, int fid, int MID, FormCollection Collection, int start = 1)
        {
            if (actionFirst != null)
            {
                if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
                {
                    var Result = MyLibraryBL.CopyCitation(MID, Collection["ddlUserSubTopic"], CurrentUser.UserId);
                    return RedirectToAction("index", "mylibrary", new { specid = Result, oid = Collection["SelectedTopic"], fid = Collection["ddlUserSubTopic"], selaction = "saved", start = start });
                }
                else
                {
                    return RedirectToAction("abstract", "mylibrary", new { specid = specid, oid = oid, fid = fid, MID = MID });
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(Collection["ddlUserSubTopicSecond"]))
                {
                    var Result = MyLibraryBL.CopyCitation(MID, Collection["ddlUserSubTopicSecond"], CurrentUser.UserId);
                    return RedirectToAction("index", "mylibrary", new { specid = Result, oid = Collection["SelectedTopicSecond"], fid = Collection["ddlUserSubTopicSecond"], selaction = "saved", start = start });
                }
                else
                {
                    return RedirectToAction("abstract", "mylibrary", new { specid = specid, oid = oid, fid = fid, MID = MID });
                }
            }
        }

        [HttpPost]
        public ActionResult Annotate(MyLibraryModel Model, int specid, int pmid, int oid, int fid, string selaction)
        {
            var Result = MyLibraryBL.Annotate(Model, pmid, CurrentUser.UserId);
            return RedirectToAction("abstract", "mylibrary", new { specid = specid, oid = oid, fid = fid, MID = pmid, selaction = selaction });
        }


        public ActionResult LinkOut(int PMID = 0, int SpecialityID = 0, int oid = 0, int fid = 0)
        {
            int qsSpecId = SpecialityID;
            MyLibraryModel MainMyLibraryModel = new MyLibraryModel();
            var UserSpecialityList = MyLibraryBL.GetUserSpecialities(CurrentUser.UserId);
            if (qsSpecId == 0)
            {
                qsSpecId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();
            }
            var UserFolderList = MyLibraryBL.GetUserFolderList(qsSpecId, CurrentUser.UserId);
            MainMyLibraryModel.AllUserFolders = UserFolderList;
            MainMyLibraryModel.AllUserSpecialities = UserSpecialityList;
            ViewBag.SpecId = qsSpecId;
            ViewBag.PrimarySpecialityId = UserSpecialityList.Select(n => n.SpecialityId).FirstOrDefault();


            string Query = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?tool=CogentMedicineWebSite&email=cogentmedicine@acr.org&dbfrom=pubmed&id=" + PMID + "&cmd=llinkslib";

            EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);
            citations.SpecialtyID = Convert.ToInt32(SpecialityID);
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
                    try
                    {
                        FullTextLinkOuts XMLData = new FullTextLinkOuts();

                        XmlNode SubTypeNode = dStr.SelectSingleNode("SubjectType");

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
                    catch (Exception)
                    {
                    }
                }
                citations.linklist = XMLDataList;
                citations.ProviderPublis = ProvList;
                citations.Aggregator = Aggregatorslist;
            }
            citations.SpecialtyID = Convert.ToInt32(SpecialityID);
            citations.PMID = Convert.ToInt32(PMID);


            MainMyLibraryModel.LinkoutModelVar = citations;
            return View(MainMyLibraryModel);
        }

        public void viewacrdocument(string src, int id = 0)
        {
            if (!string.IsNullOrEmpty(src))
            {
                var Result = MyLibraryBL.UpdateACRDocClickCount(id);
                if (src.Length > 4)
                {
                    if (src.Substring(0, 4) != "http")
                    {
                        src = "http://" + src;
                    }
                }
                Response.Redirect(src);
            }
        }
    }
}
