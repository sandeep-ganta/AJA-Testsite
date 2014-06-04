
#region Pagelevel Comments
/*

 Name: RaviM
 Date: 17-June-2013
 Module: AJA Admin
 Purpose: Controller of Admin Functionality
 
 Copyright (c) 2000-2013 ACR
 All rights reserved
 
 History:
 Name               Date            Remarks
 
 */
#endregion

#region Usings

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
using MvcSiteMapProvider;
using System.Net;
using System.IO;
using System.Xml;
using System.Text.RegularExpressions;
using MVC4Grid;
using MVC4Grid.GridExtensions;
using MVC4Grid.GridAttributes;
#endregion

namespace AJA.Controllers
{
    [LayoutInjecter("AdminLayout")]
    [HandleError]
    [Authorize(Roles = "Administrator")]
    public class AdminController : Base_Controller
    {
        public static string ServerUrl = AJA_Core.Util.GetAppConfigKeyValue("ServerURL");
        //
        // GET: /Admin/
        /// <summary>
        /// Partial view for creating new Topic by Admin-RaviM
        /// </summary>
        /// <returns></returns>
        public PartialViewResult CreateTopic()
        {
            ManageTopics newtopic = new ManageTopics();
            newtopic = EditorsBL.GetAddTopicObject();

            ViewBag.FromGrid = true;
            return PartialView("_ManageTopics", newtopic);
        }

        #region Admin Home

        /// <summary>
        /// Used to Display Administrator Home Page -RaviM
        /// </summary>
        /// <returns></returns>        

        [Authorize(Roles = "Administrator")]
        public ActionResult AdminHome()
        {
            if (CurrentUser.IsAuthenticated && CurrentUser.IsAdmin)
            {
                ViewBag.Result = TempData["Result"];
                TempData["Mailmenu"] = null;
                Session["composetext"] = null;
                // Session["mailsent"] = null;
                return View();
            }
            else
            {
                return View();
            }
        }

        #endregion

        #region EditionsChoice
        /// <summary>
        ///  /// This actionresult gets Editions data in Grid & Bind to div_Editions in Editoinschoice.cshtml
        /// </summary>
        /// <returns>returns ViewBag with Editions Grid details</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Editionschoice()
        {
            TempData["Mailmenu"] = null;
            var EditionsFilter = MVC4Grid.Grid.GridFilter.NewFilter<Editionsmodel>();
            MVC4Grid.Grid grid = GetEditions(EditionsFilter);
            ViewBag.Grid = grid;
            return View();
        }

        private static MVC4Grid.Grid GetEditions(MVC4Grid.Grid.GridFilter Filter)
        {
            string url = ServerUrl + "/Admin/AjaxEditionsFields";
            var res = EditorsBL.GetAllEditionsList(Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="Editedition(this)"},
                                new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="Deletedition(this)"},
                                new MVC4Grid.Grid.ActionButton{DisplayName="Content",OnClick="Content(this)"}
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Create New Edition",OnClick="Createedition()"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_Editions",
                Caption = "Editors Choice Edition list"
            };
            return grid;

        }

        [HttpPost]
        public JsonResult AjaxEditionsFields(MVC4Grid.Grid.GridFilter Filter)
        {
            var grid = GetEditions(Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        /// <summary>
        /// This method returns Specialtylist and binds to div with id 'Editions_Edit_dialog' in Editionschoice.cshtml
        /// </summary>
        /// <returns></returns>
        public PartialViewResult CreateEditionwithID()
        {
            Editionsmodel edm = new Editionsmodel();
            edm.Specialtylist = EditorsBL.GetSpecialitListInUse();
            return PartialView("_EditionsPartial", edm);
        }
        /// <summary>
        /// This method gets Specialtylist and Pubdate with editionid and binds to div with id 'Editions_Update_dialog' in Editionschoice.cshtml
        /// </summary>
        /// <param name="EId"></param>
        /// <returns>returns partialview with Editiondetails</returns>
        public PartialViewResult GetEditionwithEID(int? EId)
        {
            Editionsmodel edm = EditorsBL.GetEditions(EId);
            edm.Specialtylist = EditorsBL.GetSpecialitListInUse();
            return PartialView("_EditionsUpdate", edm);
        }
        /// <summary>
        /// This method deletes Editiondetails with Editionid 
        /// </summary>
        /// <param name="EId"></param>
        /// <returns>returns json with bool value</returns>
        [HttpPost]
        public JsonResult DeleteEditionWithEID(int EId)
        {
            return Json(EditorsBL.DeleteEditionWithEID(EId));
        }
        /// <summary>
        /// This method create the new Edition with Pubdate & Specialty
        /// </summary>
        /// <param name="edm"></param>
        /// <returns>returns json with bool value of CreatedEdition</returns>
        [HttpPost]
        public JsonResult CreateEditions(Editionsmodel edm)
        {
            Edition edition = new Edition();
            edition.PubDate = edm.PubDate;
            edition.SpecialtyID = edm.SpecialtyID;
            return Json(EditorsBL.CreateEdition(edition));
        }
        /// <summary>
        /// This method updates Particular Edition with Pubdate or Specialty
        /// </summary>
        /// <param name="edm"></param>
        /// <returns>retuns json with bool of Updated Edition</returns>
        [HttpPost]
        public JsonResult UpdateEditions(Editionsmodel edm)
        {
            Edition edition = new Edition();
            edition.EditionID = edm.EditionId;
            edition.PubDate = edm.PubDate;
            edition.SpecialtyID = edm.SpecialtyID;
            return Json(EditorsBL.UpdateEdition(edition));
        }

        #endregion

        #region UserManagement

        #region UserDetails Grid
        /// <summary>
        /// Get all Users bind to Grid in Admin Section-Ravi M
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult UserManagement()
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = Grid.GridFilter.NewFilter<UserdetValues>();
            var grid = GetAllUsersGrid(Filter);
            ViewBag.GridData = grid;
            return View();
        }

        private static Grid GetAllUsersGrid(Grid.GridFilter Filter)
        {
            var AllUsers = UserBL.GetALLUsersForAdmin(Filter);

            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditUser(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteUser(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Reset Password",OnClick="ResetPassword(this)"}, 
                                };

            var TableActions = new List<Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Create User",OnClick="CreateUser()"}
                    };

            Grid grid = new Grid(AllUsers, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetAllUsers")
            {
                GridId = "tbl_AllUsers_Details",
                Caption = "User Management"
            };

            return grid;
        }


        [HttpPost]
        public JsonResult AjaxGetAllUsers(Grid.GridFilter Filter)
        {
            var grid = GetAllUsersGrid(Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        #region for old grid commented by -RaviM
        [HttpPost]
        //public PartialViewResult AjaxGetAllUsers(int pageid, int rowcount, string sortexpression, string SortType, string SearchText)
        //{
        //    int count = pageid * rowcount;

        //    int skip = 0;
        //    if (pageid == null)
        //    {
        //        pageid = 0;
        //    }
        //    if (pageid != 0)
        //        skip = (pageid - 1) * rowcount;
        //    var Allusers = new List<Dictionary<string, string>>();
        //    var SearchTextUser = new List<Dictionary<string, string>>();
        //    SearchText = SearchText.Trim().ToLower();
        //    if (SearchText != string.Empty && SearchText != null)
        //    {
        //        var AllKeys = AllDBUsers.FirstOrDefault().Keys;
        //        foreach (var user in AllDBUsers)
        //        {
        //            foreach (var key in AllKeys)
        //            {
        //                if (user[key].ToLower().Contains(SearchText))
        //                {
        //                    SearchTextUser.Add(user);
        //                    break;
        //                }
        //            }
        //        }
        //    }
        //    else
        //    {
        //        SearchTextUser = AllDBUsers;
        //    }

        //    if (SearchTextUser.Count < skip)
        //        skip = 0;

        //    if (SortType == "ASC")
        //        Allusers = SearchTextUser.OrderBy(i => i[sortexpression]).Take(count).Skip(skip).ToList();
        //    else
        //        Allusers = SearchTextUser.OrderByDescending(i => i[sortexpression]).Take(count).Skip(skip).ToList();
        //    int totalrowscount = AllDBUsers.Count;
        //    if (Allusers.Count == 0)
        //        totalrowscount = 0;

        //    Grid_old grid = GetAllUsersGrid(Allusers, totalrowscount, rowcount, pageid, "div_AllUsers", "../User/AjaxGetAllUsers", sortexpression, SortType, SearchText);

        //    return PartialView("GridView", grid);
        //}

        #endregion

        #endregion

        #region Create User by Admin
        /// <summary>
        /// Creating new user by Admin -RaviM
        /// </summary>
        /// <param name="uid"></param>
        /// <returns></returns>
        public PartialViewResult GetUserwithID(int uid)
        {
            UserDetails userDet = UserBL.GetUserwithID(uid);
            ViewBag.FromGrid = true;
            return PartialView("_UserDetails", userDet);
        }
        #endregion

        #region Get user details with EmailID
        /// <summary>
        /// Get user details with EmailID-RaviM
        /// </summary>
        /// <param name="emailid"></param>
        /// <param name="FromGrid"></param>
        /// <returns></returns>
        public PartialViewResult GetUserwithEmailID(int uid)
        {
            var model = new UserDetails
            {
                CountryList = UserBL.GetCountriesList(),
                SpecialtiesList = UserBL.GetSpecialitesList(),
                PracticeList = UserBL.GetPracticesList()
            };

            UserDetails det = UserBL.GetUserwithEmailID(uid);

            model.UserName = det.UserName;
            model.FirstName = det.FirstName;
            model.LastName = det.LastName;
            model.Password = det.Password;
            model.ConfirmPassword = det.Password;
            model.EmailID = det.EmailID;
            model.postalcode = det.postalcode;
            model.UserID = det.UserID;
            model.CountryID = det.CountryID;
            model.PracticeID = det.PracticeID;
            model.SpecialityID = det.SpecialityID;
            model.GraduationYr = det.GraduationYr;
            model.Profession = det.Profession;
            model.Title = det.Title;
            model.Isasemail = det.Isasemail;
            model.Isendemail = det.Isendemail;
            model.SpecialityID = det.SpecialityID;
            model.Roles = det.Roles;
            model.IsAdmin = det.IsAdmin;
            model.IsAJAUser = det.IsAJAUser;

            //ViewBag.FromGrid = FromGrid;

            return PartialView("_UserDetails", model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public PartialViewResult GetUserDetails()
        {
            UserDetails userDet = UserBL.GetUserwithEmailID(CurrentUser.UserId);
            ViewBag.FromGrid = false;

            return PartialView("_UserDetails", userDet);
        }
        /// <summary>
        /// Create or update user details by Admin -RaviM
        /// </summary>
        /// <param name="userDet"></param>
        /// <returns></returns>
        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateUserDetails(UserDetails userDet)
        {
            var res = "";
            var user = userDet.UpdateDetails();
            if (user != null)
            {
                if (userDet.UserID == 0)
                {
                    // EMailMessage.SendMail(user.EmailID, "Your user account is successfully created.", GetMailBody(user.UserName, "Your UserName/EmailId are : " + user.UserName + "/" + user.EmailID));
                    res = "newuser";
                    return Json(res, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    // EMailMessage.SendMail(user.EmailID, "your details are updated", GetMailBody(user.UserName, "Your UserName/EmailId are : " + user.UserName + "/" + user.EmailID));
                    res = "edituser";
                    return Json(res, JsonRequestBehavior.AllowGet);
                }
            }
            else
            {
                res = "false";
                return Json(res, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult DeleteUserwithEmailID(int Userid)
        {
            bool isdeleted = UserBL.DeleteUser(Userid);
            return Json(isdeleted);

        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public JsonResult ResetPasswordEmail(string Email)
        {
            string strkey = Util.GenerateNewPassword(Email);
            AJA_tbl_Users User = UserBL.ResetPassword(Email, strkey);

            if (User != null)
            {
                EMailMessage.SendMail(User.EmailID, "ACR JournalAdvisor Login Help", GetMailBody("User", "Your New Password is : " + strkey + "<br><br><br><br>Thank you,<br>American College of Radiology,<br>ACR JournalAdvisor<br>E-mail: ACRJournalAdvisor@acr.org"));
                return Json(true);
            }
            else
            {
                return Json(false);
            }
        }
        #endregion

        #endregion

        [Authorize(Roles = "Administrator")]
        public ActionResult TopicEditors(int EditionID = 0)
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = Grid.GridFilter.NewFilter<TopicEditorsModel>();
            MVC4Grid.Grid grid = GetTopicEditorsGrid(Filter);
            ViewBag.GridData = grid;
            if (EditionID != 0)
            {
                var FilterAss = MVC4Grid.Grid.GridFilter.NewFilter<EditorsBL.EditorTopics>();

                MVC4Grid.Grid gridAssignments = GetEditorAssignmentGrid(FilterAss, EditionID);
                ViewBag.Assignments = gridAssignments;
            }
            return View();

        }

        private static MVC4Grid.Grid GetTopicEditorsGrid(MVC4Grid.Grid.GridFilter Filter)
        {
            var res = EditorsBL.GetAllTopicEditorsDetails(Filter);

            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditEditor(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Assignments",OnClick="EditorAssignment(this)"},
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteTopicEditors(this)"}, 
                                };

            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Create New Editor",OnClick="CreateTopicEditor()"}
                    };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetTopicEditors")
            {
                GridId = "tbl_AllEditors",
                Caption = "Topic Editors"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxGetTopicEditors(MVC4Grid.Grid.GridFilter Filter)
        {
            var grid = GetTopicEditorsGrid(Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        [Authorize(Roles = "Administrator")]
        public ActionResult AtlargeEditors()
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<EditorsBL.EditorsdetValues>();
            MVC4Grid.Grid grid = GetAtlargeEditorsGrid(Filter);
            ViewBag.GridData = grid;
            return View();
        }

        private static MVC4Grid.Grid GetAtlargeEditorsGrid(MVC4Grid.Grid.GridFilter Filter)
        {
            var res = EditorsBL.GetAtlargeEditorsDetails(Filter);

            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditEditor(this)"},
                                new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteAtLargeEditor(this)"}
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add New Editor",OnClick="CreateEditor()"}
                                };
            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetAtlargeEditors")
            {
                GridId = "tbl_AtLargeEditors",
                Caption = "At-Large Editors"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxGetAtlargeEditors(MVC4Grid.Grid.GridFilter Filter)
        {
            var grid = GetAtlargeEditorsGrid(Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        #region Helpers
        private ActionResult RedirectToLocal(string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }
            else
            {
                return RedirectToAction("AdminHome", "Admin");
            }
        }

        #endregion

        public PartialViewResult GetEditorwithID(int Eid)
        {
            EditorsBL.EditorsdetValues EditorDel = EditorsBL.GetLargeEditorwithID(Eid);
            if (EditorDel != null & Eid != 0)
                EditorDel.SpecialityList = EditorsBL.GetSpecialitListInUse();
            ViewBag.FromGrid = true;
            return PartialView("_AtLargeEditors", EditorDel);
        }

        public PartialViewResult GetTopicEditorwithID(int Eid)
        {
            EditorsBL.EditorsdetValues EditorDel = EditorsBL.GetLargeEditorwithID(Eid);
            ViewBag.FromGrid = true;
            return PartialView("_TopicEditors", EditorDel);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateLargeEditors(EditorsBL.EditorsdetValues LargeEditors)
        {
            if (LargeEditors != null)
            {
                LargeEditors.IsLargeEditor = true;
                EditorsBL.UpdateLargeEditors(LargeEditors);
                alert(new MyResult() { Tittle = "At-Large Editors", Message = "Editor Saved Successfully", restype = true });
                return RedirectToAction("AtlargeEditors", "Admin");
            }
            return RedirectToLocal("");
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateTopicEditors(EditorsBL.EditorsdetValues TopicEditors)
        {
            if (TopicEditors != null)
            {
                TopicEditors.IsLargeEditor = false;
                EditorsBL.UpdateLargeEditors(TopicEditors);
                alert(new MyResult() { Tittle = "Topic Editors", Message = "Editor Saved Successfully", restype = true });
                return RedirectToAction("TopicEditors", "Admin");
            }
            return RedirectToLocal("");
        }

        #region TopicEditorAssignment
        public PartialViewResult EditorAssignment(int Eid)
        {
            if (Eid != null)
                Session["Eid"] = Eid;

            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<EditorsBL.EditorTopics>();
            MVC4Grid.Grid grid = GetEditorAssignmentGrid(Filter, Eid);

            ViewBag.gridData = grid;

            return PartialView("_GridViewPartial", grid);
        }

        private static Grid GetEditorAssignmentGrid(MVC4Grid.Grid.GridFilter Filter, int Eid)
        {


            var res = EditorsBL.getTopicsForEditor(Filter, Eid);

            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditField("+Eid+",this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteEditorAssignment("+Eid+",this)"},                            
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add Assignment",OnClick="CreateEditor("+Eid+")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetEditorAssignment")
            {
                GridId = "tbl_EditorAssignment",
                Caption = "Editor Assignments"
            };
            return grid;
        }


        [HttpPost]
        public JsonResult AjaxGetEditorAssignment(MVC4Grid.Grid.GridFilter Filter)
        {
            int EDid = 0;
            if (Session["Eid"] != null)
                EDid = Convert.ToInt32(Session["Eid"]);

            var grid = GetEditorAssignmentGrid(Filter, EDid);

            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        public PartialViewResult GetEditorTopicwithID(int Eid, int topicId)
        {
            EditorsBL.EditorTopics EditorDel = EditorsBL.GetEditorTopicwithID(Eid, topicId);
            if (EditorDel != null & topicId == 0)
                EditorDel.TopicList = EditorsBL.GetTopicsForAssignment();
            ViewBag.FromGrid = true;
            return PartialView("_EditorAssignment", EditorDel);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateEditorAssignment(EditorsBL.EditorTopics TopicEditors)
        {
            if (TopicEditors != null)
            {
                EditorsBL.UpdateEditorAssignment(TopicEditors);
                alert(new MyResult() { Tittle = "Editor Assignment", Message = "Assignment Saved Successfully", restype = true });
                return RedirectToAction("TopicEditors", "Admin", new { EditionID = TopicEditors.EditorID }); // new { Eid = TopicEditors.EditorID });
            }
            return RedirectToLocal("");
        }
        #endregion

        #region Add Manage Topics
        /// <summary>
        /// Used to display Topic Management view Get-RaviM
        /// </summary>
        /// <param name="SpecialityID"></param>
        /// <returns></returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult AddManageTopics(int? SpecialityID, string result, int topicID = 0)
        {
            TempData["Mailmenu"] = null; // for Menu
            Session["SPID"] = null;
            Session["TopicID"] = null;
            if (SpecialityID == null)
                SpecialityID = 24;
            Session["SPID"] = SpecialityID;

            var TopicFilter = Grid.GridFilter.NewFilter<EditorsBL.TopicDetValues>();

            Grid grid = GetAllTopicsGrid(TopicFilter, Convert.ToInt32(SpecialityID));
            ManageTopics EditTopics = new ManageTopics
            {
                SpecialityList = EditorsBL.GetSpecialitListInUse(),
            };

            ViewBag.GridData = grid;

            if (topicID != 0)
            {
                Session["TopicID"] = topicID;
                var SubTopicFilter = Grid.GridFilter.NewFilter<SubTopics>();
                Grid SubTopicgrid = GetSubTopicsGrid(SubTopicFilter, topicID);
                ViewBag.SubTopic = SubTopicgrid;
            } 
            return View(EditTopics);
        }

        /// <summary>
        /// Get all Topics Grid for New Migrated Grid -RaviM on 10/22/2013
        /// </summary>
        /// <param name="Filter"></param>
        /// <param name="SpecialityID"></param>
        /// <returns></returns>
        private static Grid GetAllTopicsGrid(Grid.GridFilter Filter, int SpecialityID)
        {
            var AllTopics = EditorsBL.GetTopicsBySpecIDMigGrid(Filter, SpecialityID);

            var RowActionButtons = new List<Grid.ActionButton> {
                               new Grid.ActionButton{DisplayName="Edit",OnClick="EditTopic(this)"}, 
                               new Grid.ActionButton{DisplayName="Delete",OnClick="DeleteTopic(this)"},
                               new Grid.ActionButton{DisplayName="View Sub-Topic",OnClick="ViewSubTopics(this)"},                               
                                };

            var TableActions = new List<Grid.ActionButton> {
                    new Grid.ActionButton{DisplayName="Create New Topic",OnClick="CreateNewTopic()"}
                    };

            Grid grid = new Grid(AllTopics, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetTopicDetails")
            {
                GridId = "tbl_AllTopics",
                Caption = "All Topics"
            };

            return grid;
        }

        /// <summary>
        /// Ajax post action for all Topics Grid new migrated Grid - 10/22/2013 RaviM
        /// </summary>
        /// <param name="Filter"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult AjaxGetTopicDetails(Grid.GridFilter Filter)
        {
            var grid = GetAllTopicsGrid(Filter, Convert.ToInt32(Session["SPID"]));

            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        /// <summary>
        /// Get Sub Topics Grid new migrated Grid - 10/22/2013 RaviM
        /// </summary>
        /// <param name="Filter"></param>
        /// <param name="topID"></param>
        /// <returns></returns>
        private static MVC4Grid.Grid GetSubTopicsGrid(Grid.GridFilter Filter, int topID)
        {
            var AllTopics = EditorsBL.GetSubTopicsWithTopicID(Filter, topID);
            string GridCaption = EditorsBL.GetTopicnameBytopicID(topID);
            var RowActionButtons = new List<Grid.ActionButton> {
                               new Grid.ActionButton{DisplayName="Edit Sub-Topic",OnClick="EditSubTopic(this)"}, 
                                new Grid.ActionButton{DisplayName="Delete",OnClick="DeleteSubTopic(this,'"+ topID +"')"},                              
                                };

            var TableActions = new List<Grid.ActionButton> {
                    new Grid.ActionButton{DisplayName="Add Sub-Topic",OnClick="CreateSubTopic("+topID+")"}
                    };
            Grid grid = new Grid(AllTopics, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetSubTopicsToTopic")
            {
                GridId = "tbl_SubTopics",
                Caption = "Topic: " + GridCaption,
            };

            return grid;
        }

        /// <summary>
        /// AjaxGet Subtopics Grid with topicID new migrated Grid - 10/22/2013 RaviM
        /// </summary>
        /// <param name="Filter"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult AjaxGetSubTopicsToTopic(Grid.GridFilter Filter)
        {
            var grid = GetSubTopicsGrid(Filter, Convert.ToInt32(Session["TopicID"]));

            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        #region GetAll Topics Grid
        /// <summary>
        /// Get all Topics for the grid -RaviM
        /// </summary>
        /// <param name="AllUsers"></param>
        /// <param name="TotalNoOfRows"></param>
        /// <param name="noofrows"></param>
        /// <param name="ActivePage"></param>
        /// <param name="div"></param>
        /// <param name="Ajaxmethod"></param>
        /// <param name="Sort_Expression"></param>
        /// <param name="Sort_Type"></param>
        /// <param name="SearchText"></param>
        /// <returns></returns>
        //private static Grid_old GetAllTopicsGrid(List<EditorsBL.TopicDetValues> AllUsers, int TotalNoOfRows, int noofrows, int ActivePage, string div, string Ajaxmethod, string Sort_Expression, string Sort_Type, string SearchText)
        //{
        //    int count = ActivePage * TotalNoOfRows;
        //    int skip = 0;
        //    if (ActivePage == null)
        //    {
        //        ActivePage = 0;
        //    }
        //    if (ActivePage != 0)
        //        skip = (ActivePage - 1) * TotalNoOfRows;


        //    Grid_old.GridResult res = new Grid_old.GridResult();
        //    res.DataSource = AllUsers;
        //    res.Count = TotalNoOfRows;
        //    Grid_old grid = new Grid_old("tbl_AllTopics", res, noofrows, ActivePage, div, Ajaxmethod, false, false);

        //    List<Grid_old.GridColumn> cols = new List<Grid_old.GridColumn>();
        //    cols.Add(new Grid_old.GridColumn { DisplayName = "TopicID", Property = "TopicID", idColumn = true });

        //    grid.Columns = new Grid_old.GridColumn[] {
        //                new Grid_old.GridColumn { DisplayName = "TopicID", Property = "TopicID",idColumn=true},
        //                new Grid_old.GridColumn{DisplayName="Topic Name", Property="TopicName",width="15%"}


        //                };
        //    grid.Caption = "All Topics";
        //    grid.SelectedRowCount = noofrows;
        //    grid.Sort_Expression = Sort_Expression;
        //    grid.Sort_Type = Sort_Type;
        //    grid.SearchText = SearchText;
        //    grid.RowCount = new int[] { 5, 10, 15 };
        //    grid.ActionButtons = new Grid_old.ActionButton[] {
        //                        new Grid_old.ActionButton{DisplayName="Edit Topic",OnClick="EditTopic(this)"},
        //                        new Grid_old.ActionButton{DisplayName="View Sub-Topic", OnClick="ViewSubTopics(this)"}
        //                        };

        //    grid.TableActions = new Grid_old.ActionButton[] {
        //            new Grid_old.ActionButton{DisplayName="Create New Topic",OnClick="CreateNewTopic()"}
        //            };
        //    return grid;

        //}

        #endregion

        #region GetAlltopics Grid Ajax
        /// <summary>
        /// Get all topics of the speciality after posting -RaviM
        /// </summary>
        /// <param name="pageid"></param>
        /// <param name="rowcount"></param>
        /// <param name="sortexpression"></param>
        /// <param name="SortType"></param>
        /// <param name="SearchText"></param>
        /// <returns></returns>
        //[HttpPost]
        //public PartialViewResult AjaxGetTopicDetails(int pageid, int rowcount, string sortexpression, string SortType, string SearchText)
        //{
        //    int count = pageid * rowcount;

        //    int skip = 0;
        //    if (pageid == null)
        //    {
        //        pageid = 0;
        //    }
        //    if (pageid != 0)
        //        skip = (pageid - 1) * rowcount;
        //    var Allusers = new List<EditorsBL.TopicDetValues>();
        //    var SearchTextUser = new List<EditorsBL.TopicDetValues>();
        //    int? spID = Convert.ToInt32(Session["SPID"]);
        //    SearchTextUser = EditorsBL.GetTopicsBySpecID(spID);


        //    if (SearchTextUser.Count < skip)
        //        skip = 0;

        //    Allusers = SearchTextUser.Take(count).Skip(skip).ToList();

        //    int totalrowscount = SearchTextUser.Count;
        //    if (Allusers.Count == 0)
        //        totalrowscount = 0;

        //    Grid_old grid = GetAllTopicsGrid(Allusers, totalrowscount, rowcount, pageid, "div_AllTopics", "../Admin/AjaxGetTopicDetails", sortexpression, SortType, SearchText);

        //    return PartialView("GridView", grid);
        //}

        #endregion

        #region Create New Topic
        /// <summary>
        /// Create new topic-RaviM
        /// </summary>
        /// <param name="TopicInsertion"></param>
        /// <param name="url"></param>
        /// <returns></returns>
        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult InsertTopic(ManageTopics TopicInsertion)
        {
            if (TopicInsertion != null)
            {
                bool result = EditorsBL.InsertTopicByAdmin(TopicInsertion);
                if (result == true)
                {
                    alert(new MyResult() { Tittle = "Speciality Topics", Message = "Topic Saved Successfully", restype = true });
                }
                else
                {
                    alert(new MyResult() { Tittle = "Speciality Topics", Message = "Topic Saving Failed !", restype = false });
                }
                return RedirectToAction("AddManageTopics", "Admin", new { SpecialityID = Session["SPID"] });
            }
            return RedirectToAction("AddManageTopics", "Admin");
        }

        #endregion

        #region Get Topic With TopicID
        /// <summary>
        /// Get Topic to Edit with Topic ID - RaviM
        /// </summary>
        /// <param name="ID"></param>
        /// <param name="FromGrid"></param>
        /// <returns></returns>
        public PartialViewResult GetTopictwithID(int ID, bool FromGrid)
        {
            ManageTopics EditTopics = new ManageTopics
            {
                SpecialityList = EditorsBL.GetSpecialitListInUse(),
            };

            var topics = EditorsBL.GetTopictwithID(ID);
            EditTopics.TopicName = topics.TopicName;
            EditTopics.TopicID = topics.TopicID;
            EditTopics.SpecialityID = topics.SpecialityID;
            // EditTopics.SubTopicsList = EditorsBL.GetSubTopicslist(ID);
            ViewBag.FromGrid = FromGrid;

            return PartialView("_ManageTopics", EditTopics);
        }
        #endregion

        #endregion

        #region Sub Topics Managing
        /// <summary>
        /// Get Sub Topic topic to edit with topicID - RaviM
        /// </summary>
        /// <param name="ID"></param>
        /// <param name="FromGrid"></param>
        /// <returns></returns>
        public PartialViewResult EditSubTopictwithSubTopicID(int ID, bool FromGrid)
        {
            var topics = EditorsBL.GetSubTopicWithID(ID);
            ViewBag.FromGrid = FromGrid;
            return PartialView("_ManageCreateSubTopics", topics);
        }

        /// <summary>
        /// Create Mew subTopic With Topic ID -RaviM
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        public PartialViewResult CreateNewSubTopicWithTopicID(int ID)
        {
            SubTopics EditSubTopics = new SubTopics();

            var topics = EditorsBL.CreateNewSubTopicWithTopicID(ID);

            EditSubTopics.TopicID = topics.TopicID;
            EditSubTopics.SubTopicID = Convert.ToInt32(topics.SubTopicID);
            EditSubTopics.SubTopicname = topics.SubTopicname;
            EditSubTopics.TopicName = topics.TopicName;
            EditSubTopics.SpecialityName = UserBL.GetUserSpeciality(topics.SpecialityID);

            return PartialView("_ManageCreateSubTopics", EditSubTopics);
        }

        /// <summary>
        /// Create Sub Topic With a speciality and topicID - RaviM
        /// </summary>
        /// <param name="SubTopicInsert"></param>
        /// <returns></returns>
        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult InsertSubTopic(SubTopics SubTopicInsert)
        {
            if (SubTopicInsert != null)
            {
                bool result = EditorsBL.InsertSubTopicByAdmin(SubTopicInsert);
                if (result == true)
                {
                    alert(new MyResult() { Tittle = "Speciality Topics", Message = "Sub-Topic Saved Successfully", restype = true });
                }
                else
                {
                    alert(new MyResult() { Tittle = "Speciality Topics", Message = "Sub-Topic Saving Failed !", restype = false });
                }
                return RedirectToAction("AddManageTopics", "Admin", new { SpecialityID = Session["SPID"], topicID = Session["TopicID"] });
            }
            return View();
        }

        /// <summary>
        /// Get Sub Topics by Topic ID -RaviM
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public PartialViewResult ViewSubTopics(int id)
        {
            Session["TopicID"] = null;
            Session["TopicID"] = id;
            var SubTopicFilter = Grid.GridFilter.NewFilter<SubTopics>();
            Grid SubTopicgrid = GetSubTopicsGrid(SubTopicFilter, id);
            ViewBag.SubTopic = SubTopicgrid;
            return PartialView("_GridViewPartial", SubTopicgrid);
        }
        #endregion

        #region ACR Document
        [Authorize(Roles = "Administrator")]
        public ActionResult ACRDocuments()
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<ACRDocumentsModel>();
            MVC4Grid.Grid grid = GetACRDocumentsContents(Filter);
            ViewBag.Grid = grid;
            return View();
        }

        private static MVC4Grid.Grid GetACRDocumentsContents(MVC4Grid.Grid.GridFilter Filter)
        {
            var res = ACRDocumentsBL.GetALLACRDocuments(Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditDocument(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteDocument(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Manage Relationship",OnClick="ManageRelationShip(this)"}, 
                                };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add Document",OnClick="AddDocument()"}
                    };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, "../Admin/AjaxACRDocumenstsContents")
            {
                GridId = "tbl_ACRDocumets_Content",
                Caption = "ACR Documents"
            };
            return grid;
        }

        //private static MVC4Grid.Grid GetACRDocumentsContents(List<ACRDocumentsModel> AllACRDocuments, int TotalNoOfRows, int noofrows, int ActivePage, string div, string Ajaxmethod, string Sort_Expression, string Sort_Type, string SearchText)
        //{
        //    int count = ActivePage * TotalNoOfRows;
        //    int skip = 0;
        //    if (ActivePage == null)
        //    {
        //        ActivePage = 0;
        //    }
        //    if (ActivePage != 0)
        //        skip = (ActivePage - 1) * TotalNoOfRows;


        //    Grid.GridResult res = new Grid.GridResult();
        //    res.DataSource = AllACRDocuments;
        //    res.Count = TotalNoOfRows;
        //    Grid grid = new Grid("tbl_ACRDocumets_Content", res, noofrows, ActivePage, div, Ajaxmethod, false, false);

        //    List<Grid.GridColumn> cols = new List<Grid.GridColumn>();
        //    cols.Add(new Grid.GridColumn { DisplayName = "Id", Property = "Id", idColumn = true });

        //    grid.Columns = new Grid.GridColumn[] {
        //                   new Grid.GridColumn { DisplayName = "Id", Property = "Id",width="15%"}, 
        //                new Grid.GridColumn { DisplayName = "Document Source", Property = "Source",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Document Name", Property = "Name",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Last Updated At", Property = "LastUpdatedDate",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Auto Update", Property = "IsAutoUpdate",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Clicks Count", Property = "ClicksCount",width="15%"}
        //                };
        //    grid.Caption = "ACR Documents";
        //    grid.SelectedRowCount = noofrows;
        //    grid.Sort_Expression = Sort_Expression;
        //    grid.Sort_Type = Sort_Type;
        //    grid.SearchText = SearchText;
        //    grid.RowCount = new int[] { 5, 10, 15 };
        //    grid.ActionButtons = new Grid.ActionButton[] {
        //                       new Grid.ActionButton{DisplayName="Edit",OnClick="EditDocument(this)"}, 
        //                       new Grid.ActionButton{DisplayName="Delete",OnClick="DeleteDocument(this)"}, 
        //                       new Grid.ActionButton{DisplayName="Manage Relationship",OnClick="ManageRelationShip(this)"}, 
        //                        };

        //    //grid.TableActions = new Grid.ActionButton[] {
        //    //        new Grid.ActionButton{DisplayName="Create New SubTopic",OnClick="CreateThreadSubTopic("+Cid+","+ Eid +")"}
        //    //        };

        //    grid.TableActions = new Grid.ActionButton[] {
        //            new Grid.ActionButton{DisplayName="Add Document",OnClick="AddDocument()"}
        //            };

        //    return grid;

        //}

        [HttpPost]
        public JsonResult AjaxACRDocumenstsContents(MVC4Grid.Grid.GridFilter Filter)
        {
            var grid = GetACRDocumentsContents(Filter);

            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        // To Get Add Document PopUp
        public PartialViewResult AddDocumentwithID()
        {
            ACRDocumentsModel acrdocm = new ACRDocumentsModel();
            return PartialView("_ACRDocumentsPartial", acrdocm);
        }


        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult AddACRDocument(ACRDocumentsModel adm)
        {
            if (adm.chkIsAutpUpdate == true)
            {
                adm.IsAutoUpdate = "True";
            }
            else
            {
                adm.IsAutoUpdate = "False";
            }
            bool Result = ACRDocumentsBL.AddDocument(adm);
            if (Result == true)
            {
                return RedirectToAction("ACRDocuments");
            }
            return RedirectToAction("ACRDocuments");
        }

        // Close Add Document


        // Edit Document
        public PartialViewResult GetDocumentWithId(int Id)
        {
            ACRDocumentsModel acrdocm = ACRDocumentsBL.GetDocumentWithId(Id);
            if (acrdocm.IsAutoUpdate == "True")
            {
                acrdocm.chkIsAutpUpdate = true;
            }
            else
            {
                acrdocm.chkIsAutpUpdate = false;
            }
            return PartialView("_ACRDocumentsEditPartial", acrdocm);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateDocument(ACRDocumentsModel adm)
        {
            if (adm.chkIsAutpUpdate == true)
            {
                adm.IsAutoUpdate = "True";
            }
            else
            {
                adm.IsAutoUpdate = "False";
            }
            bool Result = ACRDocumentsBL.EditDocument(adm);
            if (Result == true)
            {
                return RedirectToAction("ACRDocuments");
            }
            return RedirectToAction("ACRDocuments");
        }


        //Close Edit Document

        // For delete ACR Document
        [Authorize(Roles = "Administrator")]
        public ActionResult DeleteDocumentWithId(int docId)
        {
            bool result = ACRDocumentsBL.DeleteACRDocument(docId);
            return RedirectToAction("ACRDocuments");
        }


        #region ACR Documents Relations Grid

        // To get ManageRelationShipGrid
        [Authorize(Roles = "Administrator")]
        public ActionResult ManageACRDocumentRelations(int Doc_Id = 0)
        {
            if (Doc_Id == 0)
            {
                return RedirectToAction("ACRDocuments");
            }
            ACRDocumentRelationshipModel acrdr = ACRDocumentsBL.GetTopics(Doc_Id);
            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<ACRDocumentRelationshipModel>();
            Grid grid = GetACRDocumentRelationsContents(Doc_Id, Filter);
            ViewBag.Grid = grid;
            return View(acrdr);
        }

        private static MVC4Grid.Grid GetACRDocumentRelationsContents(int Doc_Id, MVC4Grid.Grid.GridFilter Filter)
        {

            var res = ACRDocumentsBL.GetALLACRDocumentRelations(Doc_Id, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteDocumentRelation(this)"} 
                                };
            var TableActions = new List<MVC4Grid.Grid.ActionButton>
            {
                //new MVC4Grid.Grid.ActionButton{DisplayName="Add Document",OnClick="AddDocument()"}
            };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, "/Admin/AjaxACRDocumentRelationsContents")
            {
                GridId = "tbl_ACRDocumetRelations_Content",
                Caption = "Document Relationships:"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxACRDocumentRelationsContents(Grid.GridFilter Filter)
        {
            int Doc_Id = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Doc_Id"]);
            var grid = GetACRDocumentRelationsContents(Doc_Id, Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        #endregion



        [HttpPost]
        public ActionResult ManageACRDocumentRelations(ACRDocumentRelationshipModel ACRDocumentRelations, FormCollection form)
        {
            string subtopicId = form["ddl_SubTopic"];
            bool result = ACRDocumentsBL.AddACRDocumentRelation(ACRDocumentRelations, subtopicId);
            if (result)
                return RedirectToAction("ManageACRDocumentRelations", new { Doc_Id = ACRDocumentRelations.DocId });
            else
                return RedirectToAction("ACRDocuments");
        }

        // To Get ACT Documents Relation Subtopics DropDownList
        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetACRDocsSubTopics(int? id)
        {
            TopicModels topics = new TopicModels();
            topics.SubTopicList = ACRDocumentsBL.GetACRDocsSubTopics(id);
            return Json(topics.SubTopicList, JsonRequestBehavior.AllowGet);
        }


        //To Delete ACR DocumentRelation
        [Authorize(Roles = "Administrator")]
        public ActionResult DeleteDocumentRelationWithId(int RelId)
        {
            bool result = ACRDocumentsBL.DeleteACRDocumentRelation(RelId);
            return RedirectToAction("ManageACRDocumentRelations", new { Doc_id = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Doc_Id"]) });
        }


        #endregion

        #region threads
        /// <summary>
        ///  This actionresult gets EditionThreads data in Grid & Bind to div_Threads in EditoinThreads.cshtml
        /// </summary>
        /// <param name="id">Passing Threadid</param>
        /// <returns>retuns View with Viewbag </returns>

        [Authorize(Roles = "Administrator")]
        public ActionResult EditionThreads(int? id)
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<DAL.EditorsBL.Threads>();
            MVC4Grid.Grid grid = GetThreads(Filter, id);
            ViewBag.Grid = grid;
            bool check = EditorsBL.checkEditions(id);
            if (check)
            {
                Editionsmodel edm = EditorsBL.GetEditions(id);
                if (!string.IsNullOrEmpty(edm.SpecialtyName))
                    ViewBag.Specialty = edm.SpecialtyName;
                if (edm.PubDate != null)
                    ViewBag.Pubdate = edm.PubDate.ToString("MMMM yyyy");
                ViewBag.Back = id;
            }
            return View();
        }

        private static MVC4Grid.Grid GetThreads(MVC4Grid.Grid.GridFilter Filter, int? id)
        {
            string url = ServerUrl + "/Admin/AjaxThreadsfields";
            var res = EditorsBL.GetAllThreads(id, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteditorialThread(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Content",OnClick="ContentThread(this,'"+ id +"')"}                               
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Create New Editorial Thread",OnClick="CreateEditorialThread('" + id + "')"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_Edition_Thread",
                Caption = "Edition Content (Threads)"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxThreadsfields(MVC4Grid.Grid.GridFilter Filter)
        {
            int? id = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["id"]);
            var grid = GetThreads(Filter, id);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        /// <summary>
        ///  This method returns Topicslist containing Topicid,TopicName with editionid
        /// </summary>
        /// <param name="Editionid"></param>
        /// <returns></returns>
        public PartialViewResult CreateEditorialThreadID(int Editionid)
        {
            TopicModels topics = new TopicModels();
            topics.TopicList = EditorsBL.GetTopicsList(Editionid);
            //  topics.ThreadId = EditorsBL.Getexistingthread(Threadid);
            return PartialView("_EditionThreadsPartial", topics);
        }

        /// <summary>
        /// This method returns SubTopicslist containing SubTopicid,SubTopicName with topicid
        /// </summary>
        /// <param name="id"></param>
        /// <returns>json with subtopicslist</returns>
        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetSubTopics(int? id)
        {
            TopicModels topics = new TopicModels();
            topics.SubTopicList = EditorsBL.GetSubTopics(id);
            return Json(topics.SubTopicList, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// This method Deletes EditorialThread with Threadid
        /// </summary>
        /// <param name="id"></param>
        /// <returns>json with bool value</returns>
        [HttpPost]
        public JsonResult DeleteEditorialThreadEID(int? id)
        {
            return Json(EditorsBL.DeleteEditorialThreadEID(id));
        }
        /// <summary>
        /// This method Create new EditionThreads with subtopicid,editionid,threadid in Subtopicreference & subtopicid,editionid,threadid,topicid in Subtopiceditref
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult CreatenewEditorialThreads(TopicModels model)
        {
            int editionid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["id"]);
            return Json(EditorsBL.CreatenewThreads(model, editionid));
        }

        #endregion

        #region ThreadsContents
        /// <summary>
        ///  This actionresult gets ThreadContents,Articleselections, EditorialComments data in Grid & Bind to particular div's in ThreadContents.cshtml
        /// </summary>
        /// <param name="Cid">Passing Threadid</param>
        /// <param name="Eid">Passing Editionid</param>
        /// <returns>returns view with Viewbag</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult ThreadContents(int? Cid, int? Eid)
        {
            TempData["Mailmenu"] = null; // for Menu
            var ThreadsFilter = MVC4Grid.Grid.GridFilter.NewFilter<TopicModels>();
            MVC4Grid.Grid grid = GetThreadContents(ThreadsFilter, Cid, Eid);
            ViewBag.Grid = grid;

            var ArticlesFilter = MVC4Grid.Grid.GridFilter.NewFilter<ArticleselectionsModel>();
            MVC4Grid.Grid articlegrid = GetArticles(ArticlesFilter, Cid);
            ViewBag.ArticleGrid = articlegrid;

            var commentsFilter = MVC4Grid.Grid.GridFilter.NewFilter<DAL.EditorsBL.EditorialComments>();
            MVC4Grid.Grid cgrid = GetComments(commentsFilter, Cid);
            ViewBag.CommentGrid = cgrid;

            bool check = EditorsBL.checkEditions(Eid);
            if (check)
            {
                Editionsmodel edm = EditorsBL.GetEditions(Eid);
                if (!string.IsNullOrEmpty(edm.SpecialtyName))
                    ViewBag.Specialty = edm.SpecialtyName;
                if (edm.PubDate != null)
                    ViewBag.Pubdate = edm.PubDate.ToString("MMMM yyyy");
                ViewBag.Cid = Cid;
                ViewBag.Eid = Eid;
            }
            return View();
        }

        private static MVC4Grid.Grid GetThreadContents(MVC4Grid.Grid.GridFilter Filter, int? Cid, int? Eid)
        {
            string url = ServerUrl + "/Admin/AjaxThreadsContents";
            var res = EditorsBL.GetThreadContent(Cid, Eid, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteThreadSubTopic("+ Eid +","+Cid+",this)"} 
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add New Sub-Topic",OnClick="CreateThreadSubTopic("+Cid+","+ Eid +")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_Edition_Content",
                Caption = "Sub Topics"
            };
            return grid;

        }

        [HttpPost]
        public JsonResult AjaxThreadsContents(MVC4Grid.Grid.GridFilter Filter)
        {
            int? Cid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Cid"]);
            int? Eid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Eid"]);
            var grid = GetThreadContents(Filter, Cid, Eid);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        /// <summary>
        /// This method CreateSubTopic to particular Thread with Threadid and editionid
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <param name="Editionid">Passing Editionid</param>
        /// <returns>returns partialview with Topicslist</returns>
        public PartialViewResult CreateThreadSubTopicId(int Threadid, int Editionid)
        {
            TopicModels topics = new TopicModels();
            topics.TopicList = EditorsBL.GetTopicsList(Editionid);
            topics.ThreadId = EditorsBL.Getexistingthread(Threadid);
            return PartialView("_Subtopics", topics);
        }

        /// <summary>
        /// Delete Subtopic from Subtopics, Subtopiceditorref,Subtopicreferences with editionid & Threadid,subtopicid
        /// </summary>
        /// <param name="Editionid">Passing Editionid</param>
        /// <param name="Threadid">Passing Threadid</param>
        /// <param name="SubTopicid">Passing SubTopicid</param>
        /// <returns>retuns bool value of Deleted Subtopic</returns>
        [HttpPost]
        public JsonResult DeleteSubTopicContent(int Editionid, int Threadid, int SubTopicid, MVC4Grid.Grid.GridFilter Filter)
        {
            return Json(EditorsBL.DeleteSubTopicContent(Editionid, Threadid, SubTopicid, Filter));
        }

        /// <summary>
        /// This method Create existing Thread
        /// </summary>
        /// <param name="model">TopicModels</param>
        /// <returns>json wth bool value</returns>
        [HttpPost]
        public JsonResult CreateExistThread(TopicModels model)
        {
            int editionid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Eid"]);
            return Json(EditorsBL.CreateExistingThread(model, editionid));
        }

        #endregion

        #region articleselections

        private static MVC4Grid.Grid GetArticles(MVC4Grid.Grid.GridFilter Filter, int? Cid)
        {
            string url = ServerUrl + "/Admin/AjaxArticleselections";
            var res = EditorsBL.GetArticleselections(Cid, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteArticleSelection(this)"} 
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add New Article",OnClick="CreateArticleSelection("+Cid+")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_Articles",
                Caption = "Citations"
            };
            return grid;

        }

        [HttpPost]
        public JsonResult AjaxArticleselections(MVC4Grid.Grid.GridFilter Filter)
        {
            int? Threadid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Cid"]);
            var grid = GetArticles(Filter, Threadid);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        /// <summary>
        /// This method returns Partialview with Articledetails
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <returns></returns>
        public PartialViewResult CreateArticleSelectionId(int Threadid)
        {
            ArticleselectionsModel article = new ArticleselectionsModel();
            // article.ThreadId = EditorsBL.Getarticle(Threadid); 
            article.ThreadId = Threadid.ToString();
            return PartialView("_ArticlePartial", article);
        }

        /// <summary>
        /// This method returns bool value of deleted Articleselection
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <param name="Pmid">Passing Pmid</param>
        /// <returns>returns json with bool value of deleted Articleselection</returns>
        [HttpPost]
        public JsonResult DeleteArticleSelection(int Threadid, int Pmid)
        {
            return Json(EditorsBL.DeleteArticle(Threadid, Pmid));
        }

        /// <summary>
        /// This method returns json with bool value of Saved Article with pmid & Threaid
        /// </summary>
        /// <param name="article">ArticleselectionsModel</param>
        /// <returns>returns json with bool value of Saved Article</returns>
        [HttpPost]
        public ActionResult SaveArticleselections(ArticleselectionsModel article)
        {
            string Editionid = HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Eid"];
            ArticleSelection artsc = new ArticleSelection();
            artsc.PMID = Convert.ToInt32(article.PMID);
            artsc.ThreadID = Convert.ToInt32(article.ThreadId);
            bool res = EditorsBL.CreateArticle(artsc);
            if (res != false)
            {
                alert(new MyResult() { Message = "ArticleSelections Created Successfully", restype = true });
                return RedirectToAction("ThreadContents", "Admin", new { Cid = article.ThreadId, Eid = Editionid });
            }
            else
            {
                alert(new MyResult() { Message = "Pmid already exists for particular Thread" });
                return RedirectToAction("ThreadContents", "Admin", new { Cid = article.ThreadId, Eid = Editionid });
            }

        }

        public JsonResult CheckPMIDCitations(int? PMID)
        {
            bool res = EditorsBL.CheckPMIDcitations(PMID);
            return Json(res, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// This method returns json with bool value of getting ArticleSelections with Pmid,threadid
        /// </summary>
        /// <param name="pmid">Pasing Pmid</param>
        /// <param name="threadid">Passing Threadid</param>
        /// <returns>returns json with bool value of Article</returns>
        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult Getarticleexistpmid(int? pmid, int threadid)
        {
            bool res = EditorsBL.CheckPMIDacrticle(Convert.ToInt32(pmid), threadid);
            if (res == true)
                return Json(new { success = true });
            else
                return Json(new { success = false });
        }

        #endregion

        #region EditorialComments

        private static MVC4Grid.Grid GetComments(MVC4Grid.Grid.GridFilter Filter, int? Cid)
        {
            string url = ServerUrl + "/Admin/AjaxEditorialComments";
            var res = EditorsBL.GeteditorialComments(Cid, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new Grid.ActionButton{DisplayName="Edit",OnClick="EditEditorialComment(this)"},
                               new Grid.ActionButton{DisplayName="Delete",OnClick="DeleteEditorialComment(this)"} 
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add New Editorial Comment",OnClick="CreateEditorialComment("+Cid+")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_Comments",
                Caption = "Editorial Comments"
            };
            return grid;

        }

        [HttpPost]
        public JsonResult AjaxEditorialComments(MVC4Grid.Grid.GridFilter Filter)
        {
            int? Threadid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Cid"]);
            var grid = GetComments(Filter, Threadid);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        /// <summary>
        /// This method returns Partialview with EditorialComments with Threadid
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <returns></returns>
        public PartialViewResult CreateEditorialCommentID(int Threadid)
        {
            EditorialCommentsModel commentmodel = new EditorialCommentsModel();
            commentmodel.Authorslist = EditorsBL.Getcommentauthors();
            commentmodel.Genelist = EditorsBL.GetGenes();
            // article.ThreadId = EditorsBL.Getarticle(Threadid); 
            return PartialView("_EditorialCommentPartial", commentmodel);
        }

        /// <summary>
        ///  This method returns Partialview with EditorialComments with commentid
        /// </summary>
        /// <param name="Cmnt"></param>
        /// <returns></returns>
        public PartialViewResult EditEditorialCommentId(int Cmnt)
        {
            EditorialCommentsModel model = new EditorialCommentsModel();
            model = EditorsBL.EditComentdetails(Cmnt);
            model.Authordetails = EditorsBL.Authordetails(Cmnt);
            model.Genedetails = EditorsBL.Genesdetails(Cmnt);
            model.Authorslist = EditorsBL.Getcommentauthors();
            model.Genelist = EditorsBL.GetGenes();
            //  var comentlist = EditorsBL.EditEditorial(Cmnt);
            return PartialView("_EditorialCommentPartial", model);
        }

        /// <summary>
        /// This method returns Json with bool value of Created EditorialComment with EditorialCommentsModel
        /// </summary>
        /// <param name="comentdetails">EditorialCommentsModel</param>
        /// <returns>returns Json with bool value of Created EditorialComment</returns>
        [HttpPost]
        public JsonResult SaveEditorialComments(EditorialCommentsModel comentdetails)
        {
            int Threadid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Cid"]);
            return Json(EditorsBL.CreateEditorialComment(comentdetails, Threadid));
        }

        /// <summary>
        /// This method returns Json with bool value of Updated EditorialComment with EditorialCommentsModel
        /// </summary>
        /// <param name="updatecoments"></param>
        /// <returns>returns Json with bool value of Updated EditorialComment</returns>
        [HttpPost]
        public JsonResult UpdateEditorialComments(EditorialCommentsModel updatecoments)
        {
            int Threadid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["Cid"]);
            return Json(EditorsBL.UpdateEditorialComments(updatecoments, Threadid));
        }

        /// <summary>
        /// This method returns Json with bool value of Deleted EditorialComment with Commentid
        /// </summary>
        /// <param name="commentid">Passing Commentid</param>
        /// <returns>returns Json with bool value of Deleted EditorialComment</returns>
        [HttpPost]
        public JsonResult DeleteEditorialComment(int commentid)
        {
            return Json(EditorsBL.DeleteEditorialComment(commentid));
        }
        #endregion

        #region MonthlyEditorsChoice

        /// <summary>
        /// This method returns View with RecentEditions
        /// </summary>
        /// <returns>returns Editionid & Editionname</returns>

        [Authorize(Roles = "Administrator")]
        public ActionResult CreateMailing()
        {
            if (CurrentUser.IsAuthenticated)
            {
                TempData["Mailmenu"] = "Mailmenu";
                Monthlyeditorsmail mailcontent = new Monthlyeditorsmail();
                mailcontent.RecentEditionsList = EditorsBL.GetRecentEditions();
                TempData["Mailmenu"] = "Mailmenu";
                return View("CreateMailing", mailcontent);
            }
            else
            {
                return View("AdminHome");
            }
        }

        /// <summary>
        /// This method returns View with Messageproperty containing Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Messageproperty(Monthlyeditorsmail mproperty)
        {
            if (mproperty.editionid != 0 || Session["composetext"] != null)
            {
                TempData["Mailmenu"] = null;
                if (mproperty.editionid != 0)
                {
                    mproperty.editionname = EditorsBL.GetRecentbasedEditions(mproperty.editionid);
                    Session["composetext"] = mproperty;
                }
                if (mproperty.editionid == 0)
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    mproperty.editionname = EditorsBL.GetRecentbasedEditions(mproperty.editionid);
                }
                string choice = mproperty.editionname;
                Session["composetext"] = mproperty.editionname;
                DateTime datevalue;
                char[] value = new char[] { '(', ')' };
                string[] data = choice.Split(value, StringSplitOptions.RemoveEmptyEntries);
                datevalue = Convert.ToDateTime(data[1]);
                mproperty.editionname = data[0];
                mproperty.senderaddres = "ACRJournalAdvisor@acr.org";
                mproperty.subject = "ACR JournalAdvisor Editors Choice for " + data[0] + datevalue.ToString("MMMM yyyy");
                mproperty.HeadingTemplist = EditorsBL.GetHeadingTemps();
                mproperty.Ishtml = true;
                Session["composetext"] = mproperty;
                ModelState.Clear();
                return View(mproperty);
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        /// This method returns View with Composeplaintext containing Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <param name="Command">Passing Button Command from Composeplaintext View</param>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Composeplaintext(Monthlyeditorsmail mproperty, string Command)
        {
            if (Session["composetext"] != null)
            {
                Monthlyeditorsmail mailcontent = new Monthlyeditorsmail();
                if (mproperty.editionid != 0)
                {
                    Session["composetext"] = mproperty;
                }
                if (mproperty.editionid == 0)
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                }
                if (Command == "Save")
                {
                    TempData["Mailmenu"] = "Mailmenu";
                }

                if (mproperty._message == null || mproperty._htmlmesage == null)
                {
                    int editonid = mproperty.editionid;
                    var maileditionslist = EditorsBL.GetEcmailedition(editonid);
                    mailcontent = EditorsBL.GetmailEditions(editonid);
                    string imageurl = @"" + ServerUrl + "/Content/images/logo.png";
                    mailcontent._message = "\r\nNew Editors Choice citations and comments have been filed in your"
                    + " ACR JournalAdvisor " + mailcontent.SpecialtyName + " library (" + ServerUrl + ")."
                    + "\r\n\r\nThis month's titles include:\r\n\r\n";
                    if (mproperty.Ishtml)
                    {
                        mailcontent._htmlmesage = "<body><div style=\"font-family:Verdana,Sans-Serif; font-size:10pt\"><p style=\"text-align:center\"><img src=" + imageurl + " height=83 width=279 ></img></p>"
                      + "<p>New Editors Choice citations and comments have been filed in your "
                      + "<a href=\"" + ServerUrl + "/MyLibrary\">"
                      + "ACR JournalAdvisor " + mailcontent.SpecialtyName
                      + " library</a>.<p>"
                      + "<p>This month's titles include:</p><ul>";
                    }
                    foreach (var item in maileditionslist)
                    {
                        MonthlyeditorsPmids articlemail = EditorsBL.DisplayMailPMIDS(CurrentUser.UserId, item.pmid.ToString(), 2, 1);
                        NonMedlineCitation getnonmed_articleinfo = EditorsBL.GetNonmedlineArticleTitle(item.pmid);
                        if (articlemail.ArticleTitle != null)
                        {
                            mailcontent._message += item.OrgFolderName + ": "
                           + "\"" + articlemail.ArticleTitle + "\"\r\n\r\n";
                        }
                        else
                        {
                            if (getnonmed_articleinfo != null)
                                mailcontent._message += item.OrgFolderName + ": "
                             + "\"" + getnonmed_articleinfo.ArticleTitle + "\"\r\n\r\n";
                        }


                        if (mproperty.Ishtml)
                        {
                            if (articlemail.ArticleTitle != null)
                            {
                                mailcontent._htmlmesage += "<li>" + item.OrgFolderName + ": "
                                    + "<a href=\"" + ServerUrl + "/User/ECRelatedEditions"
                                    + "?HasEditionID=" + mproperty.editionid
                                    + "&HasEditionDate=" + mailcontent.PubDate.ToShortDateString()
                                    + "&id=" + mailcontent.SpecialtyID.ToString()
                                    + "#t-" + item.ThreadID + "\" target=\"_blank\">"
                                    + articlemail.ArticleTitle + "</a></li>";
                            }
                            else
                            {
                                if (getnonmed_articleinfo != null)
                                    mailcontent._htmlmesage += "<li>" + item.OrgFolderName + ": "
                                       + "<a href=\"" + ServerUrl + "/User/ECRelatedEditions"
                                       + "?HasEditionID=" + mproperty.editionid
                                       + "&HasEditionDate=" + mailcontent.PubDate.ToShortDateString()
                                       + "&id=" + mailcontent.SpecialtyID.ToString()
                                       + "#t-" + item.ThreadID + "\" target=\"_blank\">"
                                       + getnonmed_articleinfo.ArticleTitle + "</a></li>";
                            }
                        }
                    }
                    mailcontent._message += "\r\n\r\nStarred (*) folders contain citations and comments less than 1 month old. ";
                    mailcontent._message += "All New Editors Choice content, combined in a single document, can be viewed ";
                    mailcontent._message += "at " + ServerUrl + "/User/ECRelatedEditions?HasEditionID=" + mproperty.editionid + "&HasEditionDate=" + mailcontent.PubDate.ToShortDateString() + "&id=" + mailcontent.SpecialtyID.ToString();
                    // mailcontent._message += "<a href=\"" + ServerUrl + "/User/ECRelatedEditions";
                    // mailcontent._message += "?HasEditionID=" + mproperty.editionid + "&HasEditionDate=" + mailcontent.PubDate.ToShortDateString();
                    // mailcontent._message += "&id=" + mailcontent.SpecialtyID.ToString() + "\" target=\"_blank\">" + ServerUrl + "/User/ECRelatedEditions</a>.";
                    mailcontent._message += "\r\n\r\nSincerely,\r\n\r\n";
                    mailcontent._message += mproperty.sendername;
                    mailcontent._message += "\r\nModerator, ACR JournalAdvisor\r\n";
                    mailcontent._message += "\r\nP.S. If you would prefer to not receive email updates from us, please check ";
                    mailcontent._message += "the no-email permission button found on your My Profile page at ";

                    mailcontent._message += "" + ServerUrl + "/User/MyProfile";
                    if (mproperty.Ishtml)
                    {
                        mailcontent._htmlmesage += "</ul>";
                        mailcontent._htmlmesage += "<p>Starred (*) folders contain citations and comments less than 1 month old. ";
                        mailcontent._htmlmesage += "All New Editors Choice content, combined in a single document, can be viewed ";
                        mailcontent._htmlmesage += "<a href=\"" + ServerUrl + "/User/ECRelatedEditions";
                        mailcontent._htmlmesage += "?HasEditionID=" + mproperty.editionid + "&HasEditionDate=" + mailcontent.PubDate.ToShortDateString();
                        mailcontent._htmlmesage += "&id=" + mailcontent.SpecialtyID.ToString() + "\" target=\"_blank\">here</a>.</p>";
                        mailcontent._htmlmesage += "<p>Sincerely,</p>";
                        mailcontent._htmlmesage += "<p>" + mproperty.sendername + "</p>";
                        mailcontent._htmlmesage += "<p>Moderator, ACR JournalAdvisor</p>";
                        mailcontent._htmlmesage += "<p>P.S. If you would prefer to not receive email updates from us, please check ";
                        mailcontent._htmlmesage += "the no-email permission button found on your ";
                        mailcontent._htmlmesage += "<a href=\"" + ServerUrl + "/User/MyProfile\">My Profile page</a>.";
                        mailcontent._htmlmesage += "</div></body>";
                    }
                    mailcontent.Ishtml = true;
                    if (mproperty.Ishtml)
                        mailcontent.Ishtml = true;
                    else
                        mailcontent.Ishtml = false;
                    mailcontent.editionid = mproperty.editionid;
                    mailcontent.senderaddres = mproperty.senderaddres;
                    mailcontent.sendername = mproperty.sendername;
                    mailcontent.subject = mproperty.subject;
                    Session["composetext"] = mailcontent;
                    return View(mailcontent);
                }
                return View(mproperty);
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        /// This method returns View with PreviewPlaintext containing Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <param name="Command">Passing Button Command from PreviewPlaintext View</param>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult PreviewPlaintext(Monthlyeditorsmail mproperty, string Command)
        {
            if (Session["composetext"] != null)
            {
                if (Command == "Preview Message")
                {
                    Session["composetext"] = mproperty;
                    return View(mproperty);
                }
                else if (Command == "Save & Contine >>")
                {
                    Session["composetext"] = mproperty;
                    if (mproperty.Ishtml)
                    {
                        //Session["composetext"] = mproperty;
                        return RedirectToAction("Composehtml", "Admin");
                    }
                    else
                    {
                        //Session["composetext"] = mproperty;
                        return RedirectToAction("SendTest", "Admin");
                    }
                }
                if (Command == "Edit")
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    return RedirectToAction("Composeplaintext", "Admin");

                }
                else if (Command == "Continue")
                {
                    Session["composetext"] = mproperty;
                    if (mproperty.Ishtml)
                    {
                        // Session["composetext"] = mproperty;
                        return RedirectToAction("Composehtml", "Admin");
                    }
                    else
                    {
                        // Session["composetext"] = mproperty;
                        return RedirectToAction("SendTest", "Admin");
                    }
                }
                else
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    return View(mproperty);
                }
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        ///  This method returns View with Composehtml containing Monthlyeditorsmail class object data
        /// </summary>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Composehtml()
        {
            if (Session["composetext"] != null)
            {
                Monthlyeditorsmail mproperty = (Monthlyeditorsmail)Session["composetext"];
                return View(mproperty);
            }
            else
            {
                return RedirectToAction("CreateMailing", "Admin");
            }
        }

        /// <summary>
        /// This method returns  PreviewHtml View containing Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <param name="Command">Passing Button Command from PreviewHtml View</param>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult PreviewHtml(Monthlyeditorsmail mproperty, string Command)
        {
            if (Session["composetext"] != null)
            {
                if (Command == "Preview Message")
                {
                    Session["composetext"] = mproperty;
                    return View(mproperty);
                }
                else if (Command == "Save & Contine >>")
                {
                    Session["composetext"] = mproperty;
                    return RedirectToAction("SendTest", "Admin");
                }
                if (Command == "Edit")
                {
                    Session["composetext"] = mproperty;
                    return RedirectToAction("Composehtml", "Admin");
                }
                else if (Command == "Continue")
                {
                    Session["composetext"] = mproperty;
                    return RedirectToAction("SendTest", "Admin");
                }
                else
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    return View(mproperty);
                }
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        /// This method returns View with SendTest containing Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <param name="Command">Passing Button Command from SendTest View</param>
        /// <returns>returns Monthlyeditorsmail class object data</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult SendTest(Monthlyeditorsmail mproperty, string Command)
        {
            List<Usermailsdetails> userexcludedetails = new List<Usermailsdetails>();
            Usermailsdetails excludemails = new Usermailsdetails();
            if (Session["composetext"] != null)
            {
                if (Command == "Skip Test")
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    Session["composetext"] = mproperty;
                    return RedirectToAction("SelectRecipients", "Admin");
                }
                else if (Command == "Send Test Message")
                {
                    if (string.IsNullOrEmpty(mproperty.testEmail))
                    {
                        alert(new MyResult() { Message = "Please Enter EmailAddress", restype = true });
                        return View(mproperty);
                    }
                    if (mproperty.Ishtml)
                    {
                        var mails = new Monthlyeditorsmail();
                        mails = (Monthlyeditorsmail)Session["composetext"];
                        if (!string.IsNullOrEmpty(mproperty.testEmail) && !string.IsNullOrEmpty(mproperty.senderaddres))
                            //EMailMessage.SendTestMail(mproperty.senderaddres, mproperty.testname, mproperty.testEmail, mproperty.subject, GetMailBody(mproperty.testname, mproperty._htmlmesage));
                            EMailMessage.SendEmbeddedMail(mproperty.senderaddres, mproperty.testname, mproperty.testEmail, mproperty.subject, GetMailBody(mproperty.testname, mproperty._htmlmesage));
                        excludemails.FirstName = !string.IsNullOrEmpty(mproperty.testname) ? mproperty.testname : "  ";
                        excludemails.email = mproperty.testEmail;
                        excludemails.Status = "Message sent";
                        userexcludedetails.Add(excludemails);
                        if (mails.Usersentmails != null)
                            mails.Usersentmails.Add(excludemails);
                        else
                            mails.Usersentmails = userexcludedetails;

                        mproperty.Usersentmails = mails.Usersentmails;
                        Session["mailsent"] = mproperty;
                        return RedirectToAction("Sendstatus", "Admin");
                    }
                    else
                    {
                        var mails = new Monthlyeditorsmail();
                        mails = (Monthlyeditorsmail)Session["composetext"];
                        if (!string.IsNullOrEmpty(mproperty.testEmail) && !string.IsNullOrEmpty(mproperty.senderaddres))
                            EMailMessage.SendTestMail(mproperty.senderaddres, mproperty.testname, mproperty.testEmail, mproperty.subject, GetMailBody(mproperty.testname, mproperty._message));
                        excludemails.FirstName = !string.IsNullOrEmpty(mproperty.testname) ? mproperty.testname : "  ";
                        excludemails.email = mproperty.testEmail;
                        excludemails.Status = "Message sent";
                        userexcludedetails.Add(excludemails);
                        if (mails.Usersentmails != null)
                            mails.Usersentmails.Add(excludemails);
                        else
                            mails.Usersentmails = userexcludedetails;

                        mproperty.Usersentmails = mails.Usersentmails;
                        Session["mailsent"] = mproperty;
                        //alert(new MyResult() { Message = "Message Sent", restype = true }); 
                        return RedirectToAction("Sendstatus", "Admin");
                    }
                }
                else
                {
                    mproperty = (Monthlyeditorsmail)Session["composetext"];
                    return View(mproperty);
                }
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        /// This method returns SelectRecipients View containing Monthlyeditorsmail class object data
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Administrator")]
        [OutputCache(NoStore = true, Duration = 0, VaryByParam = "*")]
        public ActionResult SelectRecipients()
        {
            if (Session["composetext"] != null)
            {
                Monthlyeditorsmail mproperty;
                mproperty = (Monthlyeditorsmail)(Session["composetext"]);
                if (mproperty.Usermaildetails == null)
                {
                    mproperty.Usermaildetails = EditorsBL.GetEmaildetails(mproperty.SpecialtyID);
                }
                else
                {
                    if (mproperty.BackUsermaildetails != null)
                    {
                        mproperty.Usermaildetails = mproperty.BackUsermaildetails;
                    }
                }
                return View(mproperty);
            }
            else { return RedirectToAction("CreateMailing", "Admin"); }
        }

        /// <summary>
        /// This method is used to send mails to Recipients
        /// </summary>
        /// <param name="mproperty">Monthlyeditorsmail class object</param>
        /// <returns>returns bool value of Mails sent Recipients</returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Mailing(Monthlyeditorsmail mproperty, FormCollection collection)
        {
            string Ids = collection["Usermaildetails"];
            string[] split = !string.IsNullOrEmpty(Ids)?Ids.Split(','):null;
            var splitemailwithname = new List<Usermailsdetails>();
            var backusermaildetails = new List<Usermailsdetails>();
            var userexcludedetails = new List<Usermailsdetails>();
            if (split != null)
            {
                foreach (var item in split)
                {
                    try
                    {
                        Usermailsdetails mail = new Usermailsdetails();
                        mail.FirstName = item.Substring(0, item.IndexOf('(')) != null ? item.Substring(0, item.IndexOf('(')) : " ";
                        mail.email = item.Substring(item.IndexOf("(") + 1);
                        mail.email = mail.email.Substring(0, mail.email.Length - 1);
                        splitemailwithname.Add(mail);
                        Usermailsdetails backsentmails = new Usermailsdetails();
                        backsentmails.emailwithname = item.ToString();
                        backusermaildetails.Add(backsentmails);
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            foreach (var item in splitemailwithname)
            {
                if (!string.IsNullOrEmpty(item.email))
                {
                    if (!string.IsNullOrEmpty(mproperty.senderaddres))
                    {
                        try
                        {
                            if (mproperty.Ishtml)
                            {
                                //EMailMessage.SendTestMail(mproperty.senderaddres, mproperty.sendername, item.email, mproperty.subject, GetMailBody(item.FirstName, mproperty._htmlmesage));
                                EMailMessage.SendEmbeddedMail(mproperty.senderaddres, mproperty.sendername, item.email, mproperty.subject, GetMailBody(item.FirstName, mproperty._htmlmesage));
                                item.Status = "Mail sent";
                            }
                            else
                            {
                                EMailMessage.SendTestMail(mproperty.senderaddres, mproperty.sendername, item.email, mproperty.subject, GetMailBody(item.FirstName, mproperty._message));
                                item.Status = "Mail sent";
                            }
                        }
                        catch (Exception)
                        {
                        }
                    }
                }
            }

            string excludeids = collection["lstExcluded"] != null ? collection["lstExcluded"] : collection["Userexcludedmaildetails"] != null ? collection["Userexcludedmaildetails"] : null;
            if (!string.IsNullOrEmpty(excludeids))
            {
                string[] splitexcludes = excludeids.Split(',');
                if (splitexcludes.Length != 0 && splitexcludes != null)
                {
                    foreach (var item in splitexcludes)
                    {
                        try
                        {
                            if (!string.IsNullOrEmpty(item))
                            {
                                Usermailsdetails mail = new Usermailsdetails();
                                mail.emailwithname = item.ToString();
                                userexcludedetails.Add(mail);
                            }
                        }
                        catch (Exception)
                        {
                        }
                    }
                }
            }
            mproperty.Usersentmails = splitemailwithname;
            mproperty.Userexcludedmaildetails = userexcludedetails;
            mproperty.BackUsermaildetails = backusermaildetails;
            Session["mailsent"] = mproperty;
            Session["composetext"] = mproperty;
            return RedirectToAction("Sendstatus", "Admin");
        }

        /// <summary>
        /// This method gets Specialties not related to selected specialty based on Editors Choice Edition
        /// </summary>
        /// <returns></returns>
        [MvcSiteMapNode(ParentKey = "Recipients")]
        [AcceptVerbs(HttpVerbs.Get)]
        [OutputCache(NoStore = true, Duration = 0, VaryByParam = "*")]
        public JsonResult Getotherspecalities()
        {
            Monthlyeditorsmail editorsmails = (Monthlyeditorsmail)(Session["composetext"]);
            editorsmails.excludemaildetails = EditorsBL.Getotherspecalities(editorsmails.SpecialtyID);
            return Json(editorsmails.excludemaildetails, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// This method returns SentStatus Details of Mails sent
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Administrator")]
        public ActionResult Sendstatus(MVC4Grid.Grid.GridFilter filter)
        {
            Monthlyeditorsmail editorsmails = (Monthlyeditorsmail)(Session["mailsent"]);

            var mailFilter = MVC4Grid.Grid.GridFilter.NewFilter<Usermailsdetails>();
            MVC4Grid.Grid gridmail = GetMailSentdetails(mailFilter, editorsmails);
            ViewBag.Mailgrid = gridmail;
            return View();
        }

        private static MVC4Grid.Grid GetMailSentdetails(MVC4Grid.Grid.GridFilter Filter, Monthlyeditorsmail editorsmails)
        {
            string url = ServerUrl + "/Admin/AjaxMailsentFields";

            var res = EditorsBL.GetUsersentmaildetials(editorsmails, Filter);

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, url)
            {
                GridId = "tbl_Mailsent",
                Caption = "Message Status Summary"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxMailsentFields(MVC4Grid.Grid.GridFilter Filter)
        {
            Monthlyeditorsmail editorsmails = (Monthlyeditorsmail)(Session["mailsent"]);
            var grid = GetMailSentdetails(Filter, editorsmails);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }

        #endregion

        #region Personalized Medicine Test
        [Authorize(Roles = "Administrator")]
        public ActionResult Test(int? testid, int? Pmid)
        {
            TempData["Mailmenu"] = null; // for Menu
            TestGene testmodel = new TestGene();
            var model = new TestGene();
            var testarticles = new List<TestGene>();
            var newtestarticles = new List<TestGene>();
            var pmidlist = new List<int>();
            var newpmidlist = new List<int>();
            int[] newpmid, existedpmid;

            testmodel.Testnameslist = EditorsBL.GetTestNames(testid);
            testmodel.TestFullname = EditorsBL.GeneTestFullname(testid);
            bool check = EditorsBL.checkTestexists(testid);
            if (check)
            {
                testmodel.TestID = Convert.ToInt32(testid);

                if (testid != null)
                {
                    testmodel = EditorsBL.GetGeneTests(testid);
                }

                testmodel.TestFullname = EditorsBL.GeneTestFullname(testid);
                testmodel.TestGeneslist = EditorsBL.GetTestGenes();
                testmodel.Testnameslist = EditorsBL.GetTestNames(testid);
                testmodel.GenesAttachedtoTest = EditorsBL.GetAttachedGenestoTest(testid);
                testmodel.AttachedGeneslist = EditorsBL.GetAttachedGenestoTest(testid);

                testmodel.GetAddedEditorComment = EditorsBL.GetAddedTestEditorComment(testid);
                foreach (var item in testmodel.GetAddedEditorComment)
                {
                    newpmid = EditorsBL.GetTestpmids(item.Threadid);
                    foreach (int s in newpmid)
                    {
                        if (!pmidlist.Contains(s))
                        {
                            pmidlist.Add(s);
                        }

                    }
                }
                foreach (var data in pmidlist)
                {
                    var getaddedarticlemodel = new TestGene();
                    getaddedarticlemodel = EditorsBL.DisplayTestPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                    testarticles.Add(getaddedarticlemodel);
                    testmodel.GetAddedArticle = testarticles;
                }

                testmodel.Getlinks = EditorsBL.GetTestlinkinfo(testid);
                testmodel.Test_citationslist = EditorsBL.GetTestCitations(CurrentUser.UserId, testid);

                var testsFilter = MVC4Grid.Grid.GridFilter.NewFilter<TestGene>();
                MVC4Grid.Grid grid = testComments(testsFilter, testid);
                ViewBag.CommentGrid = grid;

                testmodel.TestPmidCitations = EditorsBL.GetTestPmidCitations(CurrentUser.UserId, Pmid);
                foreach (var item in testmodel.TestPmidCitations)
                {
                    existedpmid = EditorsBL.GetTestpmids(item.Threadid);
                    foreach (int s in existedpmid)
                    {
                        if (!newpmidlist.Contains(s))
                        {
                            newpmidlist.Add(s);
                        }

                    }
                }
                foreach (var data in newpmidlist)
                {
                    var getarticlemodel = new TestGene();
                    getarticlemodel = EditorsBL.DisplayTestPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                    newtestarticles.Add(getarticlemodel);
                    testmodel.GetArticles = newtestarticles;
                }
            }
            return View(testmodel);
        }

        private static MVC4Grid.Grid testComments(MVC4Grid.Grid.GridFilter Filter, int? testid)
        {
            string url = ServerUrl + "/Admin/AjaxTestComments";
            var res = EditorsBL.Get_Test_Comments(testid, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                 new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditTestComment(this)"},
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteTestComment(this)"}                               
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add Test Comment",OnClick="CreateTestComment("+testid+")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_TestComments",
                Caption = "Test Comments"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxTestComments(MVC4Grid.Grid.GridFilter Filter)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            var grid = testComments(Filter, testid);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        public PartialViewResult CreateTestCommentwithId(int? newtestid)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            var testmodel = new TestGene();
            testmodel.TestID = Convert.ToInt32(testid);
            testmodel.Specialtylist = EditorsBL.GetSpecialitListInUse();
            testmodel.CommentAuthorslist = EditorsBL.GetGene_Authors();
            return PartialView("_TestComment", testmodel);
        }

        public PartialViewResult EditTestCommentwithId(int? TestComentid)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            var model = new TestGene();
            model = EditorsBL.EditTestComentdetails(TestComentid, testid);
            model.Specialtylist = EditorsBL.GetSpecialitListInUse();
            model.Testcomentdetails = EditorsBL.GetTestComments(testid, TestComentid);
            model.CommentAuthorslist = EditorsBL.Get_Authors_Gene(model.Authorid);
            return PartialView("_TestCommentsUpdate", model);
        }

        [HttpPost]
        public JsonResult SaveTestComments(TestGene testmodel)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            return Json(EditorsBL.AddComments_Test(testmodel, testid));
        }


        [HttpPost]
        public JsonResult UpdateTestComments(TestGene testmodel)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            return Json(EditorsBL.UpdateTestComments(testmodel, testid));
        }


        [HttpPost]
        public JsonResult DeleteTestCommentwithId(int? deletetest)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            return Json(EditorsBL.DeleteTestCommentwithId(testid, deletetest));
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateTestgene(TestGene testgene)
        {
            TestGene test = new TestGene();
            test.TestID = testgene.TestID;
            test.Name = testgene.Name;
            test.Summary = testgene.Summary;
            EditorsBL.UpdateTestgene(test);
            alert(new MyResult() { Message = "Test Gene is Updated Successfully", restype = true });
            return RedirectToAction("Test");
        }

        [HttpPost]
        public ActionResult AddNewTest(string Newtest)
        {
            bool check;
            check = EditorsBL.AddNewTest(Newtest);
            if (check)
            {
                return Json("Addedtest", JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("exists", JsonRequestBehavior.AllowGet);
                //alert(new MyResult() { Message = "This test already exists, choose another test name", restype = true });
                // return RedirectToAction("Test", "Admin", new { testid = testid });
            }

        }

        [HttpPost]
        public ActionResult Test_Citations(TestGene Model)
        {
            string checkexists = string.Empty;

            bool check = EditorsBL.CheckTest_citations(Model.TestID, Model.Pmid);
            var test = new TestGene();
            test = EditorsBL.DisplayTestPMIDS(CurrentUser.UserId, Model.Pmid.ToString(), 2, 1);

            if (test.Pmid != 0)
            {
                if (check)
                {
                    checkexists = "Addednewcit";
                    EditorsBL.InsertTestCitations(CurrentUser.UserId, Model.TestID, Model.Pmid);
                    return Json(new { checkexists, Model.TestID }, JsonRequestBehavior.AllowGet);
                    //return RedirectToAction("Test", "Admin", new { testid = testid, Pmid = int.Parse(Model.Testcitations) });
                }
                else
                {
                    checkexists = "exists";
                    return Json(checkexists, JsonRequestBehavior.AllowGet);

                    // alert(new MyResult() { Message = "Citation Pmid already exists", restype = true });
                    //  return RedirectToAction("Test", "Admin", new { testid = testid });
                }
            }
            else
            {
                checkexists = "inexist";
                return Json(checkexists, JsonRequestBehavior.AllowGet);

            }

        }

        [HttpPost]
        public ActionResult AddSelectedTestComment(TestGene Testmodel)
        {

            string exists = "false";
            var genemodel = new TestGene();
            if (Testmodel.Getcheckedcomments != null)
            {
                genemodel.CheckEditorcomment = EditorsBL.AddSelectedTestComment(Testmodel);
                if (genemodel.CheckEditorcomment)
                {
                    return Json(Testmodel.TestID, JsonRequestBehavior.AllowGet);
                }
                //else { exists = "exists"; return Json(exists, JsonRequestBehavior.AllowGet); }
            }
            return Json(exists, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteEditorTestComment(int? te_cmnt, int? TestCommentid)
        {
            EditorsBL.DeleteEditorTestComment(te_cmnt, TestCommentid);
            return Json(te_cmnt, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteCitationTEST(int? test_cit, int? Citationpmidtest)
        {
            EditorsBL.DeleteCitationTEST(test_cit, Citationpmidtest);
            return Json(test_cit, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteTestSclink(int? test_lnk, int? TestLinkid)
        {
            EditorsBL.DeleteTestSclink(test_lnk, TestLinkid);
            return Json(test_lnk, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteTest(int? testdel)
        {
            EditorsBL.DeleteTestGene(testdel);
            return Json(testdel, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult ScreenTestResourceLinks(TestGene Model, int? linkid)
        {
            bool Checksclink;
            if (Model.Sclink != null)
            {
                Checksclink = EditorsBL.AddTestScLink(Model.TestID, Model.Sclink, Model.Linkid);
                return Json(Model.TestID, JsonRequestBehavior.AllowGet);
                //return RedirectToAction("Test", "Admin", new { testid = testid });
            }

            return Json(Model.TestID, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UpdateNameDescription(TestGene Testmodel)
        {
            int? testid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["testid"]);
            if (Testmodel.TestID != 0)
            {
                var test = new Test();
                test = EditorsBL.UpdateTestgene(Testmodel);
                return Json(test.TestID, JsonRequestBehavior.AllowGet);
            }
            return Json(testid, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult AttachGenetoTest(TestGene TestModel)
        {
            bool checktest = EditorsBL.AttachGenetoTest(TestModel.TestID, TestModel.GeneId);
            return Json(new { checktest, TestModel.TestID }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult unlink_gene_from_test(TestGene TestModel)
        {
            bool checkdeleted = EditorsBL.unlink_gene_from_test(TestModel.TestID, TestModel.GeneId);
            return Json(new { checkdeleted, TestModel.TestID }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult findposiblecomments(TestGene test)
        {
            var testmodel = new TestGene(); var newpmidlist = new List<int>(); var newtestarticles = new List<TestGene>();
            int[] existedpmid; bool check;
            testmodel.TestPmidCitations = EditorsBL.GetTestPmidCitations(CurrentUser.UserId, test.Pmid);
            foreach (var item in testmodel.TestPmidCitations)
            {
                existedpmid = EditorsBL.GetTestpmids(item.Threadid);
                foreach (int s in existedpmid)
                {
                    if (!newpmidlist.Contains(s))
                    {
                        newpmidlist.Add(s);
                    }

                }
            }
            foreach (var data in newpmidlist)
            {
                var getarticlemodel = new TestGene();
                getarticlemodel = EditorsBL.DisplayTestPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                newtestarticles.Add(getarticlemodel);
                testmodel.GetArticles = newtestarticles;
            }
            if (testmodel.GetArticles != null)
                check = true;
            else check = false;
            return Json(check, JsonRequestBehavior.AllowGet);
        }

        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetTopics_Test(int? specialtytest)
        {
            var test = new TestGene();
            test.Topiclist = EditorsBL.GetGeneTopics(specialtytest);
            return Json(test.Topiclist, JsonRequestBehavior.AllowGet);
        }

        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetSubTopics_Test(int? Topictest)
        {
            var test = new TestGene();
            test.Subtopiclist = EditorsBL.GetSubTopics(Topictest);
            return Json(test.Subtopiclist, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region Personalized Medicine Gene
        [Authorize(Roles = "Administrator")]
        public ActionResult Gene(int? geneid, int? Pmid, PersonalizedGene Genecit, string Sclink, int? linkid)
        {
            TempData["Mailmenu"] = null; // for Menu
            PersonalizedGene genemodel = new PersonalizedGene();
            var genearticles = new List<PersonalizedGene>();
            var newgenearticles = new List<PersonalizedGene>();
            // genemodel = EditorsBL.DisplayPMIDS(CurrentUser.UserId, Pmid.ToString(), 2, 1);
            var pmidlist = new List<int>();
            var newpmidlist = new List<int>();
            int[] newpmid, existedpmid;
            bool check = EditorsBL.checkGeneexists(geneid);
            genemodel.Genenameslist = EditorsBL.GetGeneNames(geneid);
            genemodel.FullName = EditorsBL.Genename(geneid);
            if (check)
            {
                genemodel.GeneID = Convert.ToInt32(geneid);
                genemodel.GetAddedEditorComment = EditorsBL.GetAddedEditorComment(geneid);
                foreach (var item in genemodel.GetAddedEditorComment)
                {
                    newpmid = EditorsBL.Getpmids(item.Threadid);
                    foreach (int s in newpmid)
                    {
                        if (!pmidlist.Contains(s))
                        {
                            pmidlist.Add(s);
                        }

                    }
                }
                foreach (var data in pmidlist)
                {
                    var getaddedarticlemodel = new PersonalizedGene();
                    getaddedarticlemodel = EditorsBL.DisplayPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                    genearticles.Add(getaddedarticlemodel);
                    genemodel.GetAddedArticle = genearticles;
                }
                //if (Genecit.Sclink != null)
                //{
                //    EditorsBL.AddScLink(Genecit.GeneID, Genecit.Sclink, Genecit.Linkid);
                //}
                genemodel.FullName = EditorsBL.Genename(geneid);
                genemodel.Genenameslist = EditorsBL.GetGeneNames(geneid);
                genemodel.Gene_citationslist = EditorsBL.GetGeneCitations(CurrentUser.UserId, geneid);
                genemodel.Specialtylist = EditorsBL.GetSpecialitListInUse();
                genemodel.CommentAuthorslist = EditorsBL.GetGene_Authors();

                genemodel.Getlinks = EditorsBL.Getlinkinfo(geneid);

                var genesFilter = MVC4Grid.Grid.GridFilter.NewFilter<PersonalizedGene>();
                MVC4Grid.Grid grid = geneComments(genesFilter, geneid);
                ViewBag.CommentGrid = grid;

                genemodel.GenePmidCitations = EditorsBL.GetPmidCitations(CurrentUser.UserId, Pmid);
                foreach (var item in genemodel.GenePmidCitations)
                {
                    existedpmid = EditorsBL.Getpmids(item.Threadid);
                    foreach (int s in existedpmid)
                    {
                        if (!newpmidlist.Contains(s))
                        {
                            newpmidlist.Add(s);
                        }

                    }
                }
                foreach (var data in newpmidlist)
                {
                    var getarticlemodel = new PersonalizedGene();
                    getarticlemodel = EditorsBL.DisplayPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                    newgenearticles.Add(getarticlemodel);
                    genemodel.GetArticles = newgenearticles;
                }
            }
            ModelState.Clear();
            return View(genemodel);
        }


        private static MVC4Grid.Grid geneComments(MVC4Grid.Grid.GridFilter Filter, int? geneid)
        {
            string url = ServerUrl + "/Admin/AjaxGeneComments";
            var res = EditorsBL.Get_Gene_Comments(geneid, Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                 new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditGeneComment(this)"},
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteGeneComment(this)"}                               
                        };
            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add Gene Comment",OnClick="CreateGeneComment("+geneid+")"}
                                };

            MVC4Grid.Grid grid = new MVC4Grid.Grid(res, Filter, RowActionButtons, TableActions, url)
            {
                GridId = "tbl_GeneComments",
                Caption = "Gene Comments"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxGeneComments(MVC4Grid.Grid.GridFilter Filter)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            var grid = geneComments(Filter, geneid);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        public PartialViewResult CreateGeneCommentwithId(int? crtgeneid)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            PersonalizedGene genemodel = new PersonalizedGene();
            genemodel.GeneID = Convert.ToInt32(geneid);
            genemodel.Specialtylist = EditorsBL.GetSpecialitListInUse();
            genemodel.CommentAuthorslist = EditorsBL.GetGene_Authors();
            return PartialView("_GenecommentPartial", genemodel);
        }

        public PartialViewResult EditGeneCommentwithId(int? Comentid)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            PersonalizedGene model = new PersonalizedGene();
            // model.GeneID = Convert.ToInt32(geneid);
            model = EditorsBL.EditGeneComentdetails(Comentid, geneid);
            model.Specialtylist = EditorsBL.GetSpecialitListInUse();
            model.Genecomentdetails = EditorsBL.GetGeneComments(geneid, Comentid);
            model.CommentAuthorslist = EditorsBL.Get_Authors_Gene(model.Authorid);
            return PartialView("_GeneCommentsUpdate", model);
        }

        [HttpPost]
        public JsonResult SaveGeneComments(PersonalizedGene Genecit)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            return Json(EditorsBL.AddComments_Gene(Genecit, geneid));
        }


        [HttpPost]
        public JsonResult UpdateGeneComments(PersonalizedGene Genecits)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            return Json(EditorsBL.UpdateGeneComments(Genecits, geneid));
        }


        [HttpPost]
        public JsonResult DeleteGeneCommentwithId(int? delcmntgene)
        {
            int? geneid = int.Parse(HttpUtility.ParseQueryString(Request.UrlReferrer.Query)["geneid"]);
            return Json(EditorsBL.DeleteGeneCommentwithId(geneid, delcmntgene));
        }

        [HttpPost]
        public ActionResult AddNewGene(PersonalizedGene Model, int? newgene)
        {
            string checktest = string.Empty;

            bool check;
            string getgenes = string.Empty;
            string uri = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=gene&amp;retmode=xml&amp;id=" + newgene + "";
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(uri);
            req.Method = "GET";
            req.MaximumAutomaticRedirections = 3;
            req.Timeout = 50000;
            HttpWebResponse res = (HttpWebResponse)req.GetResponse();
            Stream resst = res.GetResponseStream();
            StreamReader sr = new StreamReader(resst);
            getgenes = sr.ReadToEnd();
            sr.Close();
            resst.Close();
            string name = Regex.Match(getgenes, "<Item Name=\"Name\" Type=\"String\">(.*?)</Item>").Groups[1].Value;
            string full_name = Regex.Match(getgenes, "<Item Name=\"NomenclatureName\" Type=\"String\">(.*?)</Item>").Groups[1].Value;
            string symbol = Regex.Match(getgenes, "<Item Name=\"NomenclatureSymbol\" Type=\"String\">(.*?)</Item>").Groups[1].Value;
            string aliases = (Regex.Match(getgenes, "<Item Name=\"OtherAliases\" Type=\"String\">(.*?)</Item>").Groups[1].Value);
            string Summary = Regex.Match(getgenes, "<Item Name=\"Summary\" Type=\"String\">(.*?)</Item>").Groups[1].Value;
            if (!string.IsNullOrEmpty(name))
            {
                check = EditorsBL.Addgene(Convert.ToInt32(newgene), name, full_name, symbol, aliases, Summary);
                if (check)
                {
                    checktest = "AddedGene";
                    return Json(checktest, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    checktest = "exists";
                    return Json(checktest, JsonRequestBehavior.AllowGet);

                }
            }
            // return Json("invalid");
            else
            {
                checktest = "inexist";
                return Json(checktest, JsonRequestBehavior.AllowGet);

                // alert(new MyResult() { Message = "There is No Gene existed related to GeneId Entered", restype = true });
                // return RedirectToAction("Gene", "Admin", new { geneid = geneid });
            }

        }

        [HttpPost]
        public ActionResult Gene_Citations(PersonalizedGene Model)
        {
            string checkexists = string.Empty;

            bool check = EditorsBL.CheckGene_citations(Model.GeneID, Model.Pmid);
            PersonalizedGene gene = new PersonalizedGene();
            gene = EditorsBL.DisplayPMIDS(CurrentUser.UserId, Model.Pmid.ToString(), 2, 1);

            if (gene.Pmid != 0)
            {
                if (check)
                {
                    checkexists = "Addednewcit";
                    EditorsBL.InsertGeneCitations(CurrentUser.UserId, Model.GeneID, Model.Pmid);
                    return Json(new { checkexists, Model.GeneID }, JsonRequestBehavior.AllowGet);
                    // return RedirectToAction("Gene", "Admin", new { geneid = geneid, Pmid = int.Parse(Model.Genecitations) });
                }
                else
                {
                    checkexists = "exists";
                    return Json(checkexists, JsonRequestBehavior.AllowGet);
                    // alert(new MyResult() { Message = "Citation Pmid already exists", restype = true });
                    // return RedirectToAction("Gene", "Admin", new { geneid = geneid });
                }
            }
            else
            {
                checkexists = "inexist";
                return Json(checkexists, JsonRequestBehavior.AllowGet);
            }
        }


        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetTopics_Gene(int? specialty)
        {
            PersonalizedGene gene = new PersonalizedGene();
            gene.Topiclist = EditorsBL.GetGeneTopics(specialty);
            return Json(gene.Topiclist, JsonRequestBehavior.AllowGet);
        }

        [AcceptVerbs(HttpVerbs.Get)]
        public JsonResult GetSubTopics_Gene(int? Topic)
        {
            PersonalizedGene gene = new PersonalizedGene();
            gene.Subtopiclist = EditorsBL.GetSubTopics(Topic);
            return Json(gene.Subtopiclist, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        public ActionResult AddSelectedComment(PersonalizedGene Genecit)
        {

            string exists = "false";
            PersonalizedGene genemodel = new PersonalizedGene();
            if (Genecit.Getcheckedcomments != null)
            {
                genemodel.CheckEditorcomment = EditorsBL.AddSelectedComment(Genecit);
                if (genemodel.CheckEditorcomment)
                {
                    return Json(Genecit.GeneID, JsonRequestBehavior.AllowGet);
                }
                //else { exists = "exists"; return Json(exists, JsonRequestBehavior.AllowGet); }
            }
            return Json(exists, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteEditorComment(int? ge_cmnt, int? Commentid)
        {
            EditorsBL.DeleteEditorComment(ge_cmnt, Commentid);
            return Json(ge_cmnt, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteCitationGENE(int? ge_cit, int? Citationpmid)
        {
            EditorsBL.DeleteCitationGENE(ge_cit, Citationpmid);
            return Json(ge_cit, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteSclink(int? ge_sclnk, int? Linkid)
        {
            EditorsBL.DeleteSclink(ge_sclnk, Linkid);
            return Json(ge_sclnk, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult DeleteGene(int? delgeneid)
        {
            EditorsBL.DeleteGene(delgeneid);
            return Json(delgeneid, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult ScreenResourceLinks(PersonalizedGene Model)
        {

            bool Checksclink;
            if (Model.Sclink != null)
            {
                //if (IsAjaxRequest)
                //{
                Checksclink = EditorsBL.AddScLink(Model.GeneID, Model.Sclink, Model.Linkid);
                return Json(Model.GeneID, JsonRequestBehavior.AllowGet);
                //}

                // Checksclink = EditorsBL.AddScLink(geneid, Model.Sclink, Model.Linkid); 
                //return Json(geneid, JsonRequestBehavior.AllowGet);
                //  return RedirectToAction("Gene", "Admin", new { geneid = geneid });
            }
            return Json(Model.GeneID, JsonRequestBehavior.AllowGet);
        }

        public ActionResult findposiblegenecomments(PersonalizedGene gene)
        {
            PersonalizedGene genemodel = new PersonalizedGene(); var newpmidlist = new List<int>(); var newgenearticles = new List<PersonalizedGene>();
            int[] existedpmid; bool check;
            genemodel.GenePmidCitations = EditorsBL.GetPmidCitations(CurrentUser.UserId, gene.Pmid);
            foreach (var item in genemodel.GenePmidCitations)
            {
                existedpmid = EditorsBL.Getpmids(item.Threadid);
                foreach (int s in existedpmid)
                {
                    if (!newpmidlist.Contains(s))
                    {
                        newpmidlist.Add(s);
                    }

                }
            }
            foreach (var data in newpmidlist)
            {
                var getarticlemodel = new PersonalizedGene();
                getarticlemodel = EditorsBL.DisplayPMIDS(CurrentUser.UserId, data.ToString(), 2, 1);
                newgenearticles.Add(getarticlemodel);
                genemodel.GetArticles = newgenearticles;
            }
            if (genemodel.GetArticles != null)
                check = true;
            else check = false;
            return Json(check, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region Non - Medline Citations
        [Authorize(Roles = "Administrator")]
        public ActionResult NonMedlineCitations()
        {
            TempData["Mailmenu"] = null; // for Menu
            var Filter = MVC4Grid.Grid.GridFilter.NewFilter<EditorsBL.NonMedlineCitations>();
            MVC4Grid.Grid grid = GetNonMedlineCitationsGrid(Filter);
            ViewBag.GridData = grid;
            return View();


        }

        private static MVC4Grid.Grid GetNonMedlineCitationsGrid(MVC4Grid.Grid.GridFilter Filter)
        {
            var AllNonMDBCitations = EditorsBL.GetNonMedlineCitations(Filter);
            var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
                               new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditCitation(this)"}, 
                               new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteCitation(this)"},                              
                                };

            var TableActions = new List<MVC4Grid.Grid.ActionButton> {
                    new MVC4Grid.Grid.ActionButton{DisplayName="Add Non-Medline Citation",OnClick="CreateCitation()"}
                                };
            MVC4Grid.Grid grid = new MVC4Grid.Grid(AllNonMDBCitations, Filter, RowActionButtons, TableActions, "../Admin/AjaxGetNonMedlineCitations")
            {
                GridId = "tbl_NonMedlineCitations",
                Caption = "Non-Medline Citations"
            };
            return grid;
        }

        [HttpPost]
        public JsonResult AjaxGetNonMedlineCitations(Grid.GridFilter Filter)
        {
            var grid = GetNonMedlineCitationsGrid(Filter);
            return Json(grid, JsonRequestBehavior.DenyGet);
        }


        public PartialViewResult GetNonMedlineCitationwithID(int PMID)
        {
            EditorsBL.NonMedlineCitations Citation = EditorsBL.GetNonMedlineCitationwithID(PMID);
            ViewBag.FromGrid = true;
            return PartialView("_NonMedlineCitation", Citation);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public ActionResult UpdateNonMedlineCitations(EditorsBL.NonMedlineCitations nonMedlineCitations)
        {
            if (nonMedlineCitations != null)
            {
                EditorsBL.UpdateNonMedlineCitations(nonMedlineCitations);
                alert(new MyResult() { Tittle = "Non-Medline Citation", Message = "Non-Medline Citation Saved Successfully", restype = true });
                return RedirectToAction("NonMedlineCitations", "Admin");
            }
            return RedirectToLocal("");
        }
        #endregion

        public JsonResult CheckPMIDExists(int? PMID)
        {
            bool res = EditorsBL.CheckPMIDExists(PMID);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult DeleteCitation(int CitationId)
        {
            return Json(EditorsBL.DeleteCitation(CitationId));
        }


        [HttpPost]
        public JsonResult DeleteEditorAssignment(int Eid, int topicId)
        {
            return Json(EditorsBL.DeleteEditorAssignment(Eid, topicId));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult DeleteTopic(int? TopicID)
        {
            return Json(EditorsBL.SubTopicsforTopic(TopicID));
        }


        [HttpPost]
        public JsonResult DeleteSubTopic(int? SubTopicID)
        {
            return Json(EditorsBL.DelSubTopic(SubTopicID));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="Eid"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult DeleteTopicEditors(int? Eid)
        {
            return Json(EditorsBL.DeleteTopicEditors(Eid));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="Eid"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult DeleteAtLargeEditor(int? Eid)
        {
            return Json(EditorsBL.DeleteAtLargeEditor(Eid));
        }
    }
}