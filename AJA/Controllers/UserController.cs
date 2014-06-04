
#region Page History
/*
 * Author       : RaviM
 * Created On   : 06-June-2013
 * Purpose      : Controller of UserManagement Functionality
 * Module      : AJA Admin
  
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
using System.Net;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Xml.XPath;
using MVC4Grid;
using Microsoft.Web.WebPages.OAuth;
#endregion

namespace AJA.Controllers
{
    [HandleError]
    public class UserController : Base_Controller
    {
        //
        // GET: /Account/Register
        /// <summary>
        /// Get User Register view-RaviM
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [AllowAnonymous]
        public ActionResult Register(int? id)
        {
            var model = new RegisterModel
            {
                CountryList = UserBL.GetCountriesList(),
                PracticeList = UserBL.GetPracticesList(),
                Isendemail = true,
                Isasemail = true
            };

            if (id == null)
                id = 24;
            model.SpecialtiesList = UserBL.GetSpecialitesLists(Convert.ToInt32(id));
            model.SpecialityID = Convert.ToInt32(id);
            return View(model);
        }

        #region Unused commented by RaviM

        /// <summary>
        /// Post the action for registring new user to AJA
        /// </summary>
        /// <param name="Register"></param>
        /// <returns></returns>
        //[HttpPost]
        //public ActionResult CreateUser(RegisterModel Register)
        //{
        //    if (Register != null)
        //    {
        //        if (Register.IsTermsAccepted == true)
        //        {
        //            UserBL.RegisterUsers(Register);
        //            alert(new MyResult() { Tittle = "Registration Details", Message = "Registered Successfully", restype = true });
        //            return RedirectToAction("Index", "Home");
        //        }
        //        else
        //        {
        //            alert(new MyResult() { Tittle = "Accept Terms and conditions", Message = "Please Accept Terms and condition", restype = true });
        //            return RedirectToAction("Register", "User");
        //        }

        //    }
        //    else
        //    {
        //        ModelState.AddModelError("", "Registration Failed");
        //    }
        //    return View(Register);
        //}

        #endregion

        #region Register Post
        /// <summary>
        /// post the newly register user details RaviM
        /// </summary>
        /// <param name="Register"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpPost]
        public ActionResult Register(RegisterModel Register)
        {
            if (Register != null)
            {
                if (Register.IsTermsAccepted == true)
                {
                    var NewID = UserBL.RegisterUsers(Register);
                    Response.Cookies.Clear();
                    string UserData = NewID.ToString() + "|" + Register.Email + "|" + Register.UserName + "|" + "AJA User";
                    var expirytime = DateTime.Now.AddMinutes(120);
                    FormsAuthentication.Initialize();
                    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, NewID.ToString(), DateTime.Now, expirytime, false, UserData);
                    // HttpCookie authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));
                    // authenticationCookie.Expires = ticket.Expiration;
                    // Response.Cookies.Add(authenticationCookie);
                    if (SecureCookieEnabled() == true)
                    {
                        var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                        {
                            Expires = ticket.Expiration,
                            Secure = true
                        };

                        Response.Cookies.Add(authenticationCookie);
                    }
                    else
                    {
                        var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                        {
                            Expires = ticket.Expiration
                            //,Secure = true
                        };

                        Response.Cookies.Add(authenticationCookie);
                    }
                    return RedirectToAction("index", "mylibrary");
                }
                else
                {
                    alert(new MyResult() { Tittle = "Registration", Message = "You must read and accept the terms for website use.", restype = false });
                    Register.CountryList = UserBL.GetCountriesList();
                    Register.PracticeList = UserBL.GetPracticesList();
                    Register.SpecialtiesList = UserBL.GetSpecialitesLists(Convert.ToInt32(Register.SpecialityID));
                    return View(Register);
                }
            }
            else
            {
                ModelState.AddModelError("", "Registration Failed");
            }
            return View(Register);
        }
        #endregion

        // GET: /User_/

        #region Login/Logof Methods
        /// <summary>
        /// Login authenticated user RaviM
        /// </summary>
        /// <param name="returnUrl"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [ClearCache]
        public ActionResult Login(string returnUrl)
        {
            if (AJA_Core.CurrentUser.IsAuthenticated)
            {
                if (AJA_Core.CurrentUser.IsAdmin)
                {
                    return RedirectToAction("AdminHome", "Admin");
                }
                else
                {
                    return RedirectToAction("Index", "Home");
                }
            }
            else
            {
                ViewBag.ReturnUrl = returnUrl;
                LoginModel Model = new LoginModel();
                Model.RememberMe = true;
                return View(Model);
            }

        }
        [ChildActionOnly]
        public ActionResult LoginForm(string returnUrl)
        {
            ViewBag.returnUrl = returnUrl;
            return View(new LoginModel());
        }

        [ChildActionOnly]
        public ActionResult ForgotPasswordForm(string returnUrl)
        {
            ViewBag.returnUrl = returnUrl;
            return View(new ForgotPassword());
        }


        [AllowAnonymous]
        [HttpPost]
        public ActionResult Login(LoginModel LoginUser, string returnUrl)
        {
            if (LoginUser.IsValid)
            {
                // SetAuthenticationCookie(LoginUser, LoginUser.RememberMe);
                Response.Cookies.Clear();
                string UserData = LoginUser.UserID.ToString() + "|" + LoginUser.EmailID + "|" + LoginUser.UserName + "|" + LoginUser.Roles;
                var expirytime = DateTime.Now.AddMinutes(120);
                string str = LoginUser.Roles;
                ViewBag.Roles = str;

                if (LoginUser.IsPersistentCookie)
                    expirytime = DateTime.Now.AddDays(30);

                FormsAuthentication.Initialize();
                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, LoginUser.UserID.ToString(), DateTime.Now, expirytime, LoginUser.IsPersistentCookie, UserData);

                // HttpCookie authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));

                //authenticationCookie.Expires = ticket.Expiration;
                // Response.Cookies.Add(authenticationCookie);

                if (SecureCookieEnabled() == true)
                {
                    var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                    {
                        Expires = ticket.Expiration,
                        Secure = true
                    };

                    Response.Cookies.Add(authenticationCookie);
                }
                else
                {
                    var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                    {
                        Expires = ticket.Expiration
                        //,Secure = true
                    };

                    Response.Cookies.Add(authenticationCookie);
                }


                if (str.Contains("Administrator") && str.Contains("AJA User"))
                {
                    Session["Switchrole"] = str;
                    return RedirectToAction("AdminHome", "Admin");
                    //  Response.Redirect("~/Admin/AdminHome");

                }

                if (str.Contains("All Users,Administrator") || str.Contains("All Users") || str.Contains("Administrator"))
                {
                    return RedirectToAction("AdminHome", "Admin");
                    //Response.Redirect("~/Admin/AdminHome");
                }

                else
                {
                    if (Url.IsLocalUrl(returnUrl) && returnUrl.Length > 1 && returnUrl.StartsWith("/")
                    && !returnUrl.StartsWith("//") && !returnUrl.StartsWith("/\\"))
                    {
                        return Redirect(returnUrl);
                    }
                    else
                    {
                        return RedirectToAction("index", "mylibrary");
                    }
                }
            }
            else
            {
                alert(new MyResult() { Message = "Invalid Credentials", restype = false, Tittle = "Login Failed" });
                return View(LoginUser);
            }
        }

        #region unused authenticationcookie
        //private void SetAuthenticationCookie(LoginModel LoginUser, bool p)
        //{
        //    Response.Cookies.Clear();
        //    string UserData = LoginUser.UserID.ToString() + "|" + LoginUser.EmailID + "|" + LoginUser.UserName + "|" + LoginUser.Roles;
        //    var expirytime = DateTime.Now.AddMinutes(120);
        //    string str = LoginUser.Roles;
        //    ViewBag.Roles = str;
        //    if (LoginUser.IsPersistentCookie)
        //        expirytime = DateTime.Now.AddYears(1);

        //    FormsAuthentication.Initialize();
        //    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, LoginUser.UserID.ToString(), DateTime.Now, expirytime, LoginUser.IsPersistentCookie, UserData);

        //    HttpCookie authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));

        //    authenticationCookie.Expires = ticket.Expiration;

        //    Response.Cookies.Add(authenticationCookie);

        //    if (str.Contains("All Users,Administrator") || str.Contains("All Users") || str.Contains("Administrator"))
        //    {
        //        Response.Redirect("~/Admin/AdminHome");
        //    }

        //    else
        //    {
        //        Response.Redirect("~/mylibrary/index");
        //    }

        //}
        #endregion

        [AllowAnonymous]
        [ClearCache]
        public ActionResult ForgotPassword()
        {
            return View();
        }

        [HttpPost]
        public ActionResult ForgotPassword(ForgotPassword model)
        {
            string strkey = Util.GenerateNewPassword(model.EmailId);
            AJA_tbl_Users User = UserBL.GetfrgtPasswordetails(model.EmailId, strkey);
            if (User != null)
            {
                string useremail = User.EmailID;
                string username = User.UserName;
                string passmsg = "We received a request to recover the Password for your  ACR JournalAdvisor  account. <br><br>";
                string usermsg = "We received a request to recover the User Name for your  ACR JournalAdvisor  account. <br><br>";
                if (!string.IsNullOrEmpty(useremail))
                {
                    System.Text.RegularExpressions.Regex rEMail = new System.Text.RegularExpressions.Regex(@"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$");
                    if (rEMail.IsMatch(useremail))
                    {
                        try
                        {
                            if (useremail == model.EmailId.ToLower())
                            {
                                EMailMessage.SendMail(useremail, "ACR JournalAdvisor Login Help", GetMailBody("User", usermsg + "Your UserName is: " + User.UserName + "<br><br><br><br>Thank you,<br>American College of Radiology,<br>ACR JournalAdvisor<br>E-mail: ACRJournalAdvisor@acr.org"));
                                alert(new MyResult() { Tittle = "Details Sent successfully", Message = "Your login information was sent to the confirmed email address", restype = true });
                                return RedirectToAction("Index", "Home");
                            }

                            else if (User.UserName == model.EmailId)
                            {
                                UserBL.SetNewforgotpassword(useremail, strkey);
                                EMailMessage.SendMail(useremail, "ACR JournalAdvisor Login Help", GetMailBody("User", passmsg + "Your Password is: " + strkey + "<br><br><br><br>Thank you,<br>American College of Radiology,<br>ACR JournalAdvisor<br>E-mail: ACRJournalAdvisor@acr.org"));
                                alert(new MyResult() { Tittle = "Details Sent successfully", Message = "Your login information was sent to the confirmed email address", restype = true });
                                return RedirectToAction("Index", "Home");
                            }
                            else
                            {
                                alert(new MyResult() { Tittle = "Your EmailId is not correct way", Message = "Your EmailId is not correct way Please update your profile" });
                                return RedirectToAction("Index", "Home");
                            }
                        }
                        catch (Exception e)
                        {
                            return RedirectToAction("Login", "User");
                        }
                    }
                    else
                    {
                        alert(new MyResult() { Tittle = "Your EmailId is not correct way", Message = "Your EmailId is not correct way Please update your profile" });
                        return RedirectToAction("Index", "Home");
                    }
                }
                else
                {
                    alert(new MyResult() { Tittle = "Your Email details are empty", Message = "Your Email details are empty Please Contact AJA Administrator" });
                    return RedirectToAction("Index", "Home");
                }
            }
            else
            {
                alert(new MyResult() { Tittle = "Error in Password Reset", Message = "An Error occurred while reset password.", restype = false });
                return RedirectToAction("Index", "Home");
            }
        }


        [HttpGet]
        [ClearCache]
        public ActionResult LogOff()
        {
            FormsAuthentication.SignOut();
            TempData["Mailmenu"] = null;
            Session.Clear();
            Session.Abandon();
            Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", ""));
            HttpContext.Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(1));
            HttpContext.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            HttpContext.Response.Cache.SetNoStore();
            TempData["Switchrole"] = null;
            TempData["NewMenu"] = null;
            //Session["logout"] = "logout";
            return RedirectToAction("Login", "User");
        }

        public JsonResult CheckEmailExists(string EmailId)
        {
            var res = UserBL.CheckEmailExists(EmailId);
            return Json(res, JsonRequestBehavior.AllowGet);
        }


        #endregion

        public void ExternalLogin(string provider)
        {
            // just pass a provider to make it work
            OAuthWebSecurity.RequestAuthentication(provider, Url.Action("ExternalLoginCallback"));
        }

        public ActionResult ExternalLoginCallback()
        {
            var result = OAuthWebSecurity.VerifyAuthentication();

            if (result.IsSuccessful == false)
            {
                return RedirectToAction("Login", "User");
            }
            //Make all things you need before setting cookies
            Response.Cookies.Clear();

            var provider = result.Provider;
            var providerid = result.ProviderUserId;
            var Email = result.ExtraData["email"];
            var firstName = result.ExtraData.ContainsKey("firstName")
                            ? result.ExtraData["firstName"] : string.Empty;
            var lastname = result.ExtraData.ContainsKey("lastName")
                            ? result.ExtraData["lastName"] : string.Empty;
            var username = User.Identity.Name;
            var expirytime = DateTime.Now.AddMinutes(120);

            FormsAuthentication.Initialize();
            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, result.ProviderUserId, DateTime.Now, expirytime, true, result.UserName);

            if (SecureCookieEnabled() == true)
            {
                var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                {
                    Expires = ticket.Expiration,
                    Secure = true
                };

                Response.Cookies.Add(authenticationCookie);
            }
            else
            {
                var authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
                {
                    Expires = ticket.Expiration
                    //,Secure = true
                };

                Response.Cookies.Add(authenticationCookie);
            }
            // FormsAuthentication.SetAuthCookie(result.UserName, false); 
            return Redirect(Url.Action("Index", "mylibrary"));
        }

        #region checkusers
        public JsonResult EmailTaken(string Email)
        {
            bool res = UserBL.CheckEmailExistsReg(Email);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }


        public JsonResult CheckDuplicateEmail(string EmailID, int UserId)
        {
            bool res = UserBL.CheckEmailExists(EmailID, UserId);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }

        public JsonResult CheckDuplicateUserName(string UserName, int uid)
        {
            bool res = UserBL.CheckUserNameExists(UserName, uid);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }

        public JsonResult CheckUserNameInuse(string UserName)
        {
            bool res = UserBL.CheckUserNameInUse(UserName);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }
        #endregion

        //#region Unused UserManagement

        //#region UserDetails Grid
        ///// <summary>
        ///// Get all Users bind to Grid in Admin Section-Ravi M
        ///// </summary>
        ///// <returns></returns>
        //[Authorize(Roles = "Administrator")]
        //public ActionResult UserManagement()
        //{
        //    var Filter = Grid.GridFilter.NewFilter<UserdetValues>();
        //    var grid = GetAllUsersGrid(Filter);
        //    ViewBag.GridData = grid;
        //    return View();
        //}

        //private static Grid GetAllUsersGrid(Grid.GridFilter Filter)
        //{
        //    var AllUsers = UserBL.GetALLUsersForAdmin(Filter);

        //    var RowActionButtons = new List<MVC4Grid.Grid.ActionButton> {
        //                       new MVC4Grid.Grid.ActionButton{DisplayName="Edit",OnClick="EditUser(this)"}, 
        //                       new MVC4Grid.Grid.ActionButton{DisplayName="Delete",OnClick="DeleteUser(this)"}, 
        //                       new MVC4Grid.Grid.ActionButton{DisplayName="Reset Password",OnClick="ResetPassword(this)"}, 
        //                        };

        //    var TableActions = new List<Grid.ActionButton> {
        //            new MVC4Grid.Grid.ActionButton{DisplayName="Create User",OnClick="CreateUser()"}
        //            };

        //    Grid grid = new Grid(AllUsers, Filter, RowActionButtons, TableActions, "../User/AjaxGetAllUsers")
        //    {
        //        GridId = "tbl_AllUsers_Details",
        //        Caption = "User Management"
        //    };

        //    return grid;
        //}


        //[HttpPost]
        //public JsonResult AjaxGetAllUsers(Grid.GridFilter Filter)
        //{
        //    var grid = GetAllUsersGrid(Filter);
        //    return Json(grid, JsonRequestBehavior.DenyGet);

        //}

        //#region for old grid commented by -RaviM
        //[HttpPost]
        ////public PartialViewResult AjaxGetAllUsers(int pageid, int rowcount, string sortexpression, string SortType, string SearchText)
        ////{
        ////    int count = pageid * rowcount;

        ////    int skip = 0;
        ////    if (pageid == null)
        ////    {
        ////        pageid = 0;
        ////    }
        ////    if (pageid != 0)
        ////        skip = (pageid - 1) * rowcount;
        ////    var Allusers = new List<Dictionary<string, string>>();
        ////    var SearchTextUser = new List<Dictionary<string, string>>();
        ////    SearchText = SearchText.Trim().ToLower();
        ////    if (SearchText != string.Empty && SearchText != null)
        ////    {
        ////        var AllKeys = AllDBUsers.FirstOrDefault().Keys;
        ////        foreach (var user in AllDBUsers)
        ////        {
        ////            foreach (var key in AllKeys)
        ////            {
        ////                if (user[key].ToLower().Contains(SearchText))
        ////                {
        ////                    SearchTextUser.Add(user);
        ////                    break;
        ////                }
        ////            }
        ////        }
        ////    }
        ////    else
        ////    {
        ////        SearchTextUser = AllDBUsers;
        ////    }

        ////    if (SearchTextUser.Count < skip)
        ////        skip = 0;

        ////    if (SortType == "ASC")
        ////        Allusers = SearchTextUser.OrderBy(i => i[sortexpression]).Take(count).Skip(skip).ToList();
        ////    else
        ////        Allusers = SearchTextUser.OrderByDescending(i => i[sortexpression]).Take(count).Skip(skip).ToList();
        ////    int totalrowscount = AllDBUsers.Count;
        ////    if (Allusers.Count == 0)
        ////        totalrowscount = 0;

        ////    Grid_old grid = GetAllUsersGrid(Allusers, totalrowscount, rowcount, pageid, "div_AllUsers", "../User/AjaxGetAllUsers", sortexpression, SortType, SearchText);

        ////    return PartialView("GridView", grid);
        ////}

        //#endregion

        //#endregion

        //#region Create User by Admin
        ///// <summary>
        ///// Creating new user by Admin -RaviM
        ///// </summary>
        ///// <param name="uid"></param>
        ///// <returns></returns>
        //public PartialViewResult GetUserwithID(int uid)
        //{
        //    UserDetails userDet = UserBL.GetUserwithID(uid);
        //    ViewBag.FromGrid = true;
        //    return PartialView("_UserDetails", userDet);
        //}
        //#endregion

        //#region Get user details with EmailID
        ///// <summary>
        ///// Get user details with EmailID-RaviM
        ///// </summary>
        ///// <param name="emailid"></param>
        ///// <param name="FromGrid"></param>
        ///// <returns></returns>
        //public PartialViewResult GetUserwithEmailID(int uid)
        //{
        //    var model = new UserDetails
        //    {
        //        CountryList = UserBL.GetCountriesList(),
        //        SpecialtiesList = UserBL.GetSpecialitesList(),
        //        PracticeList = UserBL.GetPracticesList()
        //    };

        //    UserDetails det = UserBL.GetUserwithEmailID(uid);

        //    model.UserName = det.UserName;
        //    model.FirstName = det.FirstName;
        //    model.LastName = det.LastName;
        //    model.Password = det.Password;
        //    model.ConfirmPassword = det.Password;
        //    model.EmailID = det.EmailID;
        //    model.postalcode = det.postalcode;
        //    model.UserID = det.UserID;
        //    model.CountryID = det.CountryID;
        //    model.PracticeID = det.PracticeID;
        //    model.SpecialityID = det.SpecialityID;
        //    model.GraduationYr = det.GraduationYr;
        //    model.Profession = det.Profession;
        //    model.Title = det.Title;
        //    model.Isasemail = det.Isasemail;
        //    model.Isendemail = det.Isendemail;
        //    model.SpecialityID = det.SpecialityID;
        //    model.Roles = det.Roles;
        //    model.IsAdmin = det.IsAdmin;
        //    model.IsAJAUser = det.IsAJAUser;

        //    //ViewBag.FromGrid = FromGrid;

        //    return PartialView("_UserDetails", model);
        //}

        ///// <summary>
        ///// 
        ///// </summary>
        ///// <returns></returns>
        //public PartialViewResult GetUserDetails()
        //{
        //    UserDetails userDet = UserBL.GetUserwithEmailID(CurrentUser.UserId);
        //    ViewBag.FromGrid = false;

        //    return PartialView("_UserDetails", userDet);
        //}



        ///// <summary>
        ///// Create or update user details by Admin -RaviM
        ///// </summary>
        ///// <param name="userDet"></param>
        ///// <returns></returns>
        //[HttpPost]
        //[Authorize(Roles = "Administrator")]
        //public ActionResult UpdateUserDetails(UserDetails userDet)
        //{ 
        //    var user = userDet.UpdateDetails(); 
        //    if (user != null)
        //    {
        //        if (userDet.UserID == 0)
        //        {
        //            EMailMessage.SendMail(user.EmailID, "your user account is successfully created", GetMailBody(user.UserName, "Your UserName/EmailId are : " + user.UserName + "/" + user.EmailID));

        //            // alert(new MyResult() { Tittle = "User Details", Message = "User Created Successfully", restype = true });
        //            // return RedirectToAction("UserManagement", "User");
        //            return Json(true, JsonRequestBehavior.AllowGet);
        //        }
        //        else
        //        {
        //            EMailMessage.SendMail(user.EmailID, "your details are updated", GetMailBody(user.UserName, "Your UserName/EmailId are : " + user.UserName + "/" + user.EmailID)); 
        //            return Json(true, JsonRequestBehavior.AllowGet);
        //            // alert(new MyResult() { Tittle = "User Details", Message = "User Saved Successfully", restype = true });
        //            // return RedirectToAction("UserManagement", "User");
        //        }
        //    }
        //    else
        //    { 
        //        return Json(false, JsonRequestBehavior.AllowGet);
        //    } 
        //}

        //[HttpPost]
        //public JsonResult DeleteUserwithEmailID(int Userid)
        //{
        //    bool isdeleted = UserBL.DeleteUser(Userid);
        //    return Json(isdeleted);

        //}

        //[HttpPost]
        //[Authorize(Roles = "Administrator")]
        //public JsonResult ResetPasswordEmail(string Email)
        //{
        //    string strkey = Util.GenerateNewPassword(Email);
        //    AJA_tbl_Users User = UserBL.ResetPassword(Email, strkey);

        //    if (User != null)
        //    {
        //        EMailMessage.SendMail(Email, "Password Change", GetMailBody("User", "Your New Password is : " + strkey));
        //        return Json(true);
        //    }
        //    else
        //    {
        //        return Json(false);
        //    }
        //}


        //#endregion

        //#endregion

        #region Feild management Unnecessary Deleted by RaviM


        //[Authorize(Roles = "Administrator")]
        //public ActionResult FieldManagement()
        //{
        //    Grid grid = GetUserFeilds(1, 5, "ShowOrder", "ASC", "");
        //    ViewBag.GridData = grid;
        //    return View();
        //}

        //private static Grid GetUserFeilds(int pageid, int rowcount, string sortexpression, string SortType, string SearchText)
        //{

        //    int count = pageid * rowcount;
        //    int skip = 0;
        //    if (pageid == null)
        //    {
        //        pageid = 0;
        //    }
        //    if (pageid != 0)
        //        skip = (pageid - 1) * rowcount;


        //    Grid.GridResult gr = UserBL.GetUserFields(count, skip, sortexpression, SortType, SearchText);
        //    Grid grid = new Grid("tbl_UserFields", gr, rowcount, pageid, "div_UserFields", "../User/AjaxUserFields", false, false);

        //    List<Grid.GridColumn> cols = new List<Grid.GridColumn>();
        //    cols.Add(new Grid.GridColumn { DisplayName = "FieldId", Property = "FieldId", idColumn = true });

        //    grid.Columns = new Grid.GridColumn[] {
        //                new Grid.GridColumn { DisplayName = "FieldID", Property = "FieldID",idColumn=true},
        //                new Grid.GridColumn { DisplayName = "Field Name", Property = "FieldName",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Field Type", Property = "FieldType",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Role", Property = "Role",width="15%"},
        //                new Grid.GridColumn { DisplayName = "Is Mandatory", Property = "IsMandatory",width="08%"},
        //                new Grid.GridColumn { DisplayName = "Is Active", Property = "IsActive",width="08%" },
        //                new Grid.GridColumn { DisplayName = "Created Date", Property = "CreatedDate" ,width="17%" }
        //                };
        //    grid.Caption = "User Fields Management";
        //    grid.SelectedRowCount = rowcount;
        //    grid.Sort_Expression = sortexpression;
        //    grid.Sort_Type = SortType;
        //    grid.SearchText = SearchText;
        //    grid.RowCount = new int[] { 5, 10, 15 };
        //    grid.ActionButtons = new Grid.ActionButton[] {
        //                        new Grid.ActionButton{DisplayName="Edit",OnClick="EditField(this)"},
        //                        new Grid.ActionButton{DisplayName="Delete",OnClick="DeleteField(this)"}
        //                        };

        //    grid.TableActions = new Grid.ActionButton[] {
        //            new Grid.ActionButton{DisplayName="Create New Field",OnClick="CreateField()"}
        //            };
        //    return grid;
        //}

        //[HttpPost]
        //public PartialViewResult AjaxUserFields(int pageid, int rowcount, string sortexpression, string SortType, string SearchText)
        //{

        //    Grid grid = GetUserFeilds(pageid, rowcount, sortexpression, SortType, SearchText);

        //    return PartialView("GridView", grid);

        //}


        //public PartialViewResult GetNewField()
        //{
        //    UserFieldModel ufm = new UserFieldModel();
        //    return PartialView("_EditFieldsPartial", ufm);
        //}

        //public PartialViewResult GetExistingField(int fieldid)
        //{
        //    UserFieldModel ufm = UserBL.GetField(fieldid);
        //    return PartialView("_EditFieldsPartial", ufm);
        //}

        //[HttpPost]
        //public JsonResult ShowOptions(int fieldid)
        //{
        //    List<FieldOption> lstvals = UserBL.GetOptionsForField(fieldid);
        //    return Json(lstvals);
        //}

        //[HttpPost]
        //public JsonResult DeleteField(int fieldid)
        //{
        //    return Json(UserBL.DeleteField(fieldid));
        //}

        //[HttpPost]
        //public JsonResult CreateField(UserField newfield)
        //{
        //    return Json(UserBL.SaveNewField(newfield));
        //}

        //[HttpPost]
        //public JsonResult UpdateField(UserField newfield)
        //{
        //    return Json(UserBL.UpdateField(newfield));
        //}

        //[HttpPost]
        //public JsonResult DeleteOption(long optid)
        //{
        //    return Json(UserBL.DeleteOption(optid));
        //}

        //[HttpPost]
        //public JsonResult CreateOption(FieldOption newfield)
        //{
        //    return Json(UserBL.SaveOptions(newfield, Convert.ToInt32(newfield.OptionID)));
        //}

        //[HttpPost]
        //public JsonResult UpdateOption(FieldOption newfield)
        //{
        //    return Json(UserBL.UpdateOption(newfield));
        //}

        #endregion

        public JsonResult CheckDuplicateFieldName(string FieldName, int? FieldID)
        {
            bool res = UserBL.CheckFieldNameExists(FieldName, FieldID);
            return Json(!res, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SwitchUser()
        {
            string url = Request.UrlReferrer.AbsolutePath;
            string Roles;
            HttpCookie authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
            if (authCookie != null)
            {
                //Extract the forms authentication cookie
                FormsAuthenticationTicket authTicket = FormsAuthentication.Decrypt(authCookie.Value);
                string ActiveRole = "";
                if ((authTicket.UserData != null) && (!String.IsNullOrEmpty(authTicket.UserData)))
                {

                    // you have to parse the string and get the ActiveRole and Roles.

                    ActiveRole = authTicket.UserData.ToString();

                    Roles = authTicket.UserData;

                    if (Roles.Contains("Administrator"))
                    {
                        if (CurrentUser.IsAdmin)
                        {
                            TempData["NewMenu"] = "NewMenu";
                            return Redirect("~/mylibrary/index");
                        }
                        else { TempData["NewMenu"] = null; }
                    }
                }
            }
            return View();
        }

        public ActionResult SwitchAdmin()
        {
            TempData["NewMenu"] = null;
            return Redirect("~/Admin/AdminHome");
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
                return RedirectToAction("Index", "Home");
            }
        }

        #endregion

        #  region Change Password

        [Authorize]
        public PartialViewResult ChangePassword()
        {
            DAL.Models.ChangePassword cp = new ChangePassword();
            cp.EmailId = CurrentUser.EmailId;
            return PartialView("_ChangePassword", cp);
        }

        [Authorize]
        [HttpPost]
        public JsonResult ChangePassword(ChangePassword cp)
        {
            var user = UserBL.ChangePassword(cp.EmailId, cp.NewPassword);
            if (User != null)
            {
                EMailMessage.SendMail(cp.EmailId, "ACR JournalAdvisor Login Help", GetMailBody(CurrentUser.UserName, "Your New Password is : " + cp.NewPassword + "<br><br><br><br>Thank you,<br>American College of Radiology,<br>ACR JournalAdvisor<br>E-mail: ACRJournalAdvisor@acr.org"));
                return Json(true, JsonRequestBehavior.DenyGet);
            }
            else
            {
                ModelState.AddModelError("", "Error in Updating Password. Please Try again.");
                return Json(false, JsonRequestBehavior.DenyGet);
            }

        }

        public JsonResult CheckPassword(string CurrentPassword, string EmailId)
        {
            bool res = UserBL.CheckUser(EmailId, CurrentPassword);
            return Json(res, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region User Profile Get Action
        /// <summary>
        /// get user profile details -RaviM
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "AJA User")]
        public ActionResult MyProfile()
        {
            var model = new MyProfileModel
            {
                CountryList = UserBL.GetCountriesList(),
                PracticeList = UserBL.GetPracticesList()
            };

            HttpCookie authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
            if (authCookie != null)
            {
                //Extract the Existed cookie
                FormsAuthenticationTicket authTicket = FormsAuthentication.Decrypt(authCookie.Value);
                if ((authTicket.UserData != null) && (!String.IsNullOrEmpty(authTicket.UserData)))
                {
                    if (authTicket.IsPersistent)
                        model.RememberMe = true;

                }
            }

            AJA_tbl_Users det = UserBL.GetUserdet(CurrentUser.UserId);

            model.UserName = det.UserName;
            model.FirstName = det.Fname;
            model.LastName = det.Lname;
            model.Password = det.Password;
            model.ConfirmPassword = det.Password;
            model.EmailID = det.EmailID;

            model.postalcode = Convert.ToString(det.Pincode);
            model.UserID = det.UserID;
            model.CountryID = Convert.ToString(det.CountryID);
            model.PracticeID = Convert.ToString(det.typePracticeID);
            model.SpecialityID = Convert.ToString(det.specialtyID);
            model.GraduationYr = det.graduationYear.ToString();
            model.Profession = det.profession;
            model.UserTitle = det.UserTitle;
            model.Isasemail = Convert.ToBoolean(det.IsSavedAqemaisend);
            model.Isendemail = Convert.ToBoolean(det.IseditorEmaiSend);
            model.Speciality = UserBL.GetUserSpeciality(det.specialtyID);
            return View(model);
        }

        #endregion

        #region Myprofile details Save
        /// <summary>
        /// Post My profile page for update user details-Ravi M
        /// </summary>
        /// <param name="register"></param>
        /// <returns></returns>
        [Authorize(Roles = "AJA User")]
        [HttpPost]
        public ActionResult MyProfile(MyProfileModel register)
        {
            if (register != null)
            {
                bool result = UserBL.ModifyUser(register);

                Response.Cookies.Clear();
                string UserData = register.UserID.ToString() + "|" + register.EmailID + "|" + register.UserName + "|" + CurrentUser.Roles;
                var expirytime = DateTime.Now.AddHours(1);

                if (register.IsPersistentCookie)
                    expirytime = DateTime.Now.AddDays(30);

                //FormsAuthentication.Initialize();

                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, register.UserID.ToString(), DateTime.Now, expirytime, register.IsPersistentCookie, UserData);
                HttpCookie authenticationCookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));
                authenticationCookie.Expires = ticket.Expiration;
                Response.Cookies.Add(authenticationCookie);

                if (result == true)
                {
                    return RedirectToAction("UpdateProfileText", "User");
                }
            }
            else
            {
                alert(new MyResult() { Tittle = "Profile Details", Message = "Update details Failed !", restype = false });
            }
            return View(register);
        }

        #endregion

        #region After UPdate the User Profile
        /// <summary>
        /// Get Update profile text view after user clicked on update profile view - RaviM
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "AJA User")]
        [ClearCache]
        public ActionResult UpdateProfileText()
        {
            return View();
        }



        #endregion

        #region User unsubscribe with userid
        /// <summary>
        /// This will return bool valu of the user deleted or not-Ravi M
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Authorize(Roles = "AJA User")]
        public ActionResult DeleteMyProfile()
        {
            bool isdeleted = UserBL.DeleteUserByUserID(CurrentUser.UserId);
            if (isdeleted == true)
            {
                alert(new MyResult() { Tittle = "User Delete", Message = "User Deleted Successfully Thank You !", restype = true });
                FormsAuthentication.SignOut();
                return RedirectToAction("Login", "User");
            }
            return RedirectToAction("Index", "Home");
        }
        #endregion

        #region EditorsChoice
        /// <summary>
        /// gets the editors choice based on speciality ID -RaviM
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        /// 

        [Authorize(Roles = "AJA User")]
        public ActionResult EditorsChoice(int? id)
        {
            EditorsChoicemodel Model = new EditorsChoicemodel
            {
                SpecialityList = EditorsBL.GetSpecialitListInUse(),
                CurrentMonthYear = DateTime.Now.ToString("MMMM yyyy")
            };

            var FID = UserBL.GetSpecialiteswithID(CurrentUser.UserId);

            Model.UserSpeciality = FID;

            var FirstID = (from s in FID select s).FirstOrDefault();

            if (id == null)
            {
                if (FirstID != null)
                    id = Int32.Parse(FirstID.Value.ToString());
            }

            Model.EditonExists = UserBL.specialtyhascurrentedition(Convert.ToInt32(id));
            Model.SpecialtyName = UserBL.GetUserSpeciality(id);
            Model.SpecialtyID = Convert.ToInt32(id);

            if (Model.EditonExists == true)
            {
                int EditionID = UserBL.GetLatestEditon(Convert.ToInt32(id));

                Model.Displaylist = UserBL.GetECTopicSort(EditionID);
                Model.EditionId = EditionID;

                var EditionThreads = UserBL.GetEcEditionThreads(EditionID);

                Model.GetECeditonThreads = EditionThreads;

                List<EditorsChoicemodel> EditSelect = new List<EditorsChoicemodel>();

                foreach (var thID in EditionThreads)
                {
                    EditorsChoicemodel tempp = new EditorsChoicemodel();

                    tempp.originalpubdatewords = thID.OriginalPubDate.ToString("MMMM yyyy");
                    var attrib = UserBL.GetECThreadAttributes(EditionID, Convert.ToInt32(thID.ThreadId));
                    tempp.ThreadEditors = attrib.ThreadEditors;
                    tempp.ThreadTopics = attrib.ThreadTopics;
                    tempp.ThreadId = thID.ThreadId;
                    var threadcit = UserBL.GetECThreadCitations(Convert.ToInt32(thID.ThreadId));
                    List<EditorsChoicemodel> ThreadCitation = new List<EditorsChoicemodel>();

                    foreach (var PMID in threadcit)
                    {
                        EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);

                        if (citations.ArticleTitle == null && citations.AbstractText == null)
                        {
                            var obj = UserBL.GetNonMedlineCitations(PMID);
                            obj.EditionId = EditionID;
                            obj.SpecialtyID = Convert.ToInt32(id);
                            obj.PMID = PMID;
                            ThreadCitation.Add(obj);
                        }
                        else
                        {
                            citations.EditionId = EditionID;
                            citations.SpecialtyID = Convert.ToInt32(id);
                            ThreadCitation.Add(citations);
                        }
                        tempp.ThreadCitations = ThreadCitation;
                    }

                    var ThrdComments = UserBL.GetECThredComments1(EditionID, Convert.ToInt32(thID.ThreadId));

                    foreach (var Thdcmnt in ThrdComments)
                    {
                        var GetGenes = UserBL.GetGenesForEC(Thdcmnt.CommentID);
                        Thdcmnt.GetGeneslst = GetGenes;
                    }

                    tempp.GetecThreadCommentsGne = ThrdComments;
                    EditSelect.Add(tempp);

                    Model.GetEditorSelection = EditSelect;
                }

                List<EditorsChoicemodel> allcitations = new List<EditorsChoicemodel>();
                foreach (var item in Model.Displaylist)
                {
                    EditorsChoicemodel Citationslist = UserBL.DisplayPMIDS(CurrentUser.UserId, item.PMID.ToString(), 2, 4);
                    if (Citationslist.ArticleTitle != null && Citationslist.AbstractText != null)
                    {
                        Citationslist.TopicName = item.TopicName;
                        Citationslist.SubTopicname = item.SubTopicname;
                        Citationslist.PMID = item.PMID;
                        Citationslist.ThreadId = item.ThreadId;
                        Citationslist.SubTopicID = item.SubTopicID;

                        allcitations.Add(Citationslist);
                    }
                    else
                    {
                        var obj = UserBL.GetNonMedlineCitations(item.PMID);
                        obj.TopicName = item.TopicName;
                        obj.SubTopicname = item.SubTopicname;
                        obj.PMID = item.PMID;
                        obj.ThreadId = item.ThreadId;
                        obj.SubTopicID = item.SubTopicID;
                        allcitations.Add(obj);
                    }
                    Model.GetCitaitons = allcitations;
                }
            }

            return View(Model);

        }
        #endregion

        #region Get PrintallAbstractsView
        /// <summary>
        /// To Print the sections in Editors Choice page based on the condition-RaviM
        /// </summary>
        /// <param name="SpecialityID"></param>
        /// <param name="EditionID"></param>
        /// <param name="thrdID"></param>
        /// <param name="ThreadPMID"></param>
        /// <returns></returns>

        [Authorize(Roles = "AJA User")]
        public ActionResult PrintAllAbstractEC(int? SpecialityID, int? EditionID, int? thrdID, int? ThreadPMID)
        {
            EditorsChoicemodel ECModel = new EditorsChoicemodel();

            if (thrdID != null && ThreadPMID == null)
            {
                EditorsChoicemodel tempp = new EditorsChoicemodel();

                var EditionThreads = UserBL.Gets(Convert.ToInt32(EditionID));
                tempp.originalpubdatewords = EditionThreads.OriginalPubDate.ToString("MMMM yyyy");

                var attrib = UserBL.GetECThreadAttributes(Convert.ToInt32(EditionID), Convert.ToInt32(thrdID));
                tempp.ThreadEditors = attrib.ThreadEditors;
                tempp.ThreadTopics = attrib.ThreadTopics;
                tempp.ThreadId = thrdID;

                var threadcit = UserBL.GetECThreadCitations(Convert.ToInt32(thrdID));

                List<EditorsChoicemodel> ThreadCitation = new List<EditorsChoicemodel>();

                foreach (var PMID in threadcit)
                {
                    EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);
                    if (citations.ArticleTitle != null && citations.AbstractText != null)
                    {
                        citations.EditionId = Convert.ToInt32(EditionID);
                        citations.SpecialtyID = Convert.ToInt32(SpecialityID);
                        ThreadCitation.Add(citations);
                    }
                    else
                    {
                        var obj = UserBL.GetNonMedlineCitations(PMID);
                        obj.EditionId = Convert.ToInt32(EditionID);
                        obj.SpecialtyID = Convert.ToInt32(SpecialityID);
                        obj.PMID = PMID;
                        ThreadCitation.Add(obj);
                    }

                    tempp.ThreadCitations = ThreadCitation;
                }

                tempp.GetecThreadComments = UserBL.GetECThredComments(Convert.ToInt32(EditionID), Convert.ToInt32(thrdID));
                ECModel = tempp;
            }
            else if (thrdID != null && ThreadPMID != null)
            {
                EditorsChoicemodel tempp = new EditorsChoicemodel();
                var EditionThreads = UserBL.Gets(Convert.ToInt32(EditionID));
                tempp.originalpubdatewords = EditionThreads.OriginalPubDate.ToString("MMMM yyyy");
                var attrib = UserBL.GetECThreadAttributes(Convert.ToInt32(EditionID), Convert.ToInt32(thrdID));
                tempp.ThreadEditors = attrib.ThreadEditors;
                tempp.ThreadTopics = attrib.ThreadTopics;
                tempp.ThreadId = thrdID;

                var citations = UserBL.DisplayPMIDS(CurrentUser.UserId, ThreadPMID.ToString(), 2, 1);
                if (citations.ArticleTitle != null && citations.AbstractText != null)
                {
                    citations.EditionId = Convert.ToInt32(EditionID);
                    citations.SpecialtyID = Convert.ToInt32(SpecialityID);
                    tempp.MedlinePgn = citations.MedlinePgn;
                    tempp.MedlineTA = citations.MedlineTA;
                    tempp.StatusDisplay = citations.StatusDisplay;
                    tempp.AbstractText = citations.AbstractText;
                    tempp.AbstractText2 = citations.AbstractText2;
                    tempp.ArticleTitle = citations.ArticleTitle;
                    tempp.AuthorList = citations.AuthorList;
                    tempp.PMID = citations.PMID;
                    tempp.DisplayDate = citations.DisplayDate;
                    tempp.AuthorFullList = citations.AuthorFullList;
                }
                else
                {
                    var obj = UserBL.GetNonMedlineCitations(Convert.ToInt32(ThreadPMID));
                    obj.EditionId = Convert.ToInt32(EditionID);
                    obj.SpecialtyID = Convert.ToInt32(SpecialityID);
                    tempp.MedlinePgn = obj.MedlinePgn;
                    tempp.MedlineTA = obj.MedlineTA;
                    tempp.StatusDisplay = obj.StatusDisplay;
                    tempp.AbstractText = obj.AbstractText;
                    tempp.AbstractText2 = obj.AbstractText2;
                    tempp.ArticleTitle = obj.ArticleTitle;
                    tempp.AuthorList = obj.AuthorList;
                    tempp.PMID = obj.PMID;
                    tempp.DisplayDate = obj.DisplayDate;
                    tempp.AuthorFullList = obj.AuthorFullList;
                }
                tempp.GetecThreadComments = UserBL.GetECThredComments(Convert.ToInt32(EditionID), Convert.ToInt32(thrdID));
                tempp.ThreadId = Convert.ToInt32(thrdID);
                tempp.PMID = Convert.ToInt32(ThreadPMID);
                ECModel = tempp;
            }

            else
            {
                ECModel.SpecialtyID = Convert.ToInt32(SpecialityID);
                ECModel.EditionId = Convert.ToInt32(EditionID);

                ECModel.Displaylist = UserBL.GetECTopicSort(Convert.ToInt32(EditionID));

                var EditionThreads = UserBL.GetEcEditionThreads(Convert.ToInt32(EditionID));

                ECModel.GetECeditonThreads = EditionThreads;

                List<EditorsChoicemodel> EditSelect = new List<EditorsChoicemodel>();

                foreach (var thID in EditionThreads)
                {
                    EditorsChoicemodel tempp = new EditorsChoicemodel();

                    tempp.originalpubdatewords = thID.OriginalPubDate.ToString("MMMM yyyy");
                    var attrib = UserBL.GetECThreadAttributes(Convert.ToInt32(EditionID), Convert.ToInt32(thID.ThreadId));
                    tempp.ThreadEditors = attrib.ThreadEditors;
                    tempp.ThreadTopics = attrib.ThreadTopics;
                    tempp.ThreadId = thID.ThreadId;
                    var threadcit = UserBL.GetECThreadCitations(Convert.ToInt32(thID.ThreadId));
                    List<EditorsChoicemodel> ThreadCitation = new List<EditorsChoicemodel>();

                    foreach (var PMID in threadcit)
                    {
                        EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);
                        if (citations.ArticleTitle != null && citations.AbstractText != null)
                        {
                            citations.EditionId = Convert.ToInt32(EditionID);
                            citations.SpecialtyID = Convert.ToInt32(SpecialityID);
                            ThreadCitation.Add(citations);
                        }
                        else
                        {
                            var obj = UserBL.GetNonMedlineCitations(PMID);
                            obj.EditionId = Convert.ToInt32(EditionID);
                            obj.SpecialtyID = Convert.ToInt32(SpecialityID);
                            obj.PMID = PMID;

                            ThreadCitation.Add(obj);
                        }

                        tempp.ThreadCitations = ThreadCitation;
                    }

                    tempp.GetecThreadComments = UserBL.GetECThredComments(Convert.ToInt32(EditionID), Convert.ToInt32(thID.ThreadId));
                    EditSelect.Add(tempp);
                    ECModel.GetEditorSelection = EditSelect;
                }

                List<EditorsChoicemodel> allcitations = new List<EditorsChoicemodel>();
                foreach (var item in ECModel.Displaylist)
                {
                    EditorsChoicemodel Citationslist = UserBL.DisplayPMIDS(CurrentUser.UserId, item.PMID.ToString(), 2, 4);
                    if (Citationslist.ArticleTitle != null && Citationslist.AbstractText != null)
                    {
                        Citationslist.TopicName = item.TopicName;
                        Citationslist.SubTopicname = item.SubTopicname;
                        Citationslist.PMID = item.PMID;
                        Citationslist.ThreadId = item.ThreadId;
                        Citationslist.SubTopicID = item.SubTopicID;
                        allcitations.Add(Citationslist);
                    }
                    else
                    {
                        var obj = UserBL.GetNonMedlineCitations(item.PMID);
                        obj.TopicName = item.TopicName;
                        obj.SubTopicname = item.SubTopicname;
                        obj.PMID = item.PMID;
                        obj.ThreadId = item.ThreadId;
                        obj.SubTopicID = item.SubTopicID;
                        allcitations.Add(obj);
                    }
                    ECModel.GetCitaitons = allcitations;
                }
            }
            ECModel.SpecialtyID = Convert.ToInt32(SpecialityID);
            return View(ECModel);
        }
        #endregion

        #region FullTextLinkOut
        /// <summary>
        /// Get Full Text Link out by PMID and speciality ID-Ravi M
        /// </summary>
        /// <param name="PMID"></param>
        /// <param name="SpecialityID"></param>
        /// <returns></returns>
        [Authorize(Roles = "AJA User")]
        public ActionResult ECLinkOut(int? PMID, int? SpecialityID)
        {
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
            citations.SpecialtyID = Convert.ToInt32(SpecialityID);
            citations.PMID = Convert.ToInt32(PMID);
            return View(citations);
        }

        #endregion

        #region ECRelatedEditions
        /// <summary>
        /// Get Related Editons in EC on 10/18/2013 -RaviM
        /// </summary>
        /// <param name="id"></param>
        /// <param name="HasEditionID"></param>
        /// <param name="HasEditionDate"></param>
        /// <returns></returns>
        [Authorize(Roles = "AJA User,Administrator")]
        public ActionResult ECRelatedEditions(int? id, int? HasEditionID, DateTime HasEditionDate)
        {
            //if (CurrentUser.IsAuthenticated)
            //{
            EditorsChoicemodel Model = new EditorsChoicemodel();
            Model.SpecialtyName = UserBL.GetUserSpeciality(id);
            Model.SpecialtyID = Convert.ToInt32(id);
            if (HasEditionID != null)
            {
                int EditionID = Convert.ToInt32(HasEditionID);
                Model.HasEditionDate = HasEditionDate;

                Model.Displaylist = UserBL.GetECTopicSort(EditionID);
                Model.EditionId = EditionID;

                var EditionThreadsRel = UserBL.GetEcEditionThreads(EditionID);

                Model.GetECeditonThreads = EditionThreadsRel;

                List<EditorsChoicemodel> EditSelectRel = new List<EditorsChoicemodel>();

                foreach (var thID in EditionThreadsRel)
                {
                    EditorsChoicemodel tempp = new EditorsChoicemodel();

                    tempp.originalpubdatewords = thID.OriginalPubDate.ToString("MMMM yyyy");
                    var attrib = UserBL.GetECThreadAttributes(EditionID, Convert.ToInt32(thID.ThreadId));
                    tempp.ThreadEditors = attrib.ThreadEditors;
                    tempp.ThreadTopics = attrib.ThreadTopics;
                    tempp.ThreadId = thID.ThreadId;
                    var threadcit = UserBL.GetECThreadCitations(Convert.ToInt32(thID.ThreadId));
                    List<EditorsChoicemodel> ThreadCitation = new List<EditorsChoicemodel>();

                    //List<EditorsChoicemodel> cit = UserBL.Display(CurrentUser.UserId, threadcit, 2, 1);
                    //foreach (var newcit in cit)
                    //{
                    //    if (newcit.ArticleTitle == null && newcit.AbstractText == null)
                    //    {
                    //        var obj = UserBL.GetNonMedlineCitations(newcit.PMID);
                    //        newcit.ArticleTitle = obj.ArticleTitle;
                    //        newcit.AbstractText = obj.AbstractText;
                    //        newcit.AuthorList = obj.AuthorList;
                    //        newcit.MedlinePgn = obj.MedlinePgn;
                    //        newcit.MedlineTA = obj.MedlineTA;
                    //        newcit.DisplayDate = obj.DisplayDate;
                    //        newcit.StatusDisplay = obj.StatusDisplay;
                    //        newcit.DisplayNotes = obj.DisplayNotes;
                    //        newcit.PMID = newcit.PMID;
                    //        newcit.EditionId = EditionID;
                    //        newcit.SpecialtyID = Convert.ToInt32(id);
                    //    }

                    //    else
                    //    {
                    //        newcit.EditionId = EditionID;
                    //        newcit.SpecialtyID = Convert.ToInt32(id);
                    //    }
                    //}
                    //tempp.ThreadCitations = cit;

                    foreach (var PMID in threadcit)
                    {
                        EditorsChoicemodel citations = UserBL.DisplayPMIDS(CurrentUser.UserId, PMID.ToString(), 2, 1);

                        if (citations.ArticleTitle == null && citations.AbstractText == null)
                        {
                            var obj = UserBL.GetNonMedlineCitations(PMID);
                            obj.EditionId = EditionID;
                            obj.SpecialtyID = Convert.ToInt32(id);
                            obj.PMID = PMID;
                            ThreadCitation.Add(obj);
                        }
                        else
                        {
                            citations.EditionId = EditionID;
                            citations.SpecialtyID = Convert.ToInt32(id);
                            ThreadCitation.Add(citations);
                        }
                        tempp.ThreadCitations = ThreadCitation;
                    }

                    var ThrdComments = UserBL.GetECThredComments1(EditionID, Convert.ToInt32(thID.ThreadId));

                    foreach (var Thdcmnt in ThrdComments)
                    {
                        var GetGenes = UserBL.GetGenesForEC(Thdcmnt.CommentID);
                        Thdcmnt.GetGeneslst = GetGenes;
                    }

                    tempp.GetecThreadCommentsGne = ThrdComments;
                    EditSelectRel.Add(tempp);

                    Model.GetEditorSelection = EditSelectRel;
                }

                List<EditorsChoicemodel> allcitationsRel = new List<EditorsChoicemodel>();


                foreach (var item in Model.Displaylist)
                {
                    EditorsChoicemodel Citationslist = UserBL.DisplayPMIDS(CurrentUser.UserId, item.PMID.ToString(), 2, 4);
                    if (Citationslist.ArticleTitle != null && Citationslist.AbstractText != null)
                    {
                        Citationslist.TopicName = item.TopicName;
                        Citationslist.SubTopicname = item.SubTopicname;
                        Citationslist.PMID = item.PMID;
                        Citationslist.ThreadId = item.ThreadId;
                        Citationslist.SubTopicID = item.SubTopicID;

                        allcitationsRel.Add(Citationslist);
                    }
                    else
                    {
                        var obj = UserBL.GetNonMedlineCitations(item.PMID);
                        obj.TopicName = item.TopicName;
                        obj.SubTopicname = item.SubTopicname;
                        obj.PMID = item.PMID;
                        obj.ThreadId = item.ThreadId;
                        obj.SubTopicID = item.SubTopicID;
                        allcitationsRel.Add(obj);
                    }
                    Model.GetCitaitons = allcitationsRel;
                }
            }

            return View(Model);
            //}

            //else
            //{
            //    return RedirectToAction("Login", "User", new { returnUrl = "/User/ECRelatedEditions?HasEditionID=" + HasEditionID + "&HasEditionDate=" + HasEditionDate.ToString("MM/dd/yyy") + "&id=" + id + "" });
            //}
        }

        #endregion

        public bool SecureCookieEnabled()
        {
            string myval = ConfigurationManager.AppSettings["SecureCookie"];

            if (myval == null) return false;

            if (myval.ToLower() == "true")
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
