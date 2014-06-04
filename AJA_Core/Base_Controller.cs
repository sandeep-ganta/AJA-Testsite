using System;
using System.Collections.Generic;
using System.IO;
using System.Web.Mvc;
using DAL;
using DAL.Models;

namespace AJA_Core
{
    [CheckUserCookie]
    public class Base_Controller : Controller
    {
        /// <summary>
        /// Write Exception to Log files
        /// </summary>
        /// <param name="filterContext"></param>
        protected override void OnException(ExceptionContext filterContext)
        {
            Exceptions.LogException(filterContext);

            // Response.Redirect("~/Home/Error");

        }

        /// <summary>
        /// Check The Request is Ajax or Not
        /// </summary>
        public bool IsAjaxRequest
        {
            get
            {
                if (this.Request == null)
                {
                    throw new ArgumentNullException("request");
                }
                return (Request["X-Requested-With"] == "XMLHttpRequest") || ((Request.Headers != null) && (Request.Headers["X-Requested-With"] == "XMLHttpRequest"));
            }
        }


        /// <summary>
        /// strore All User in session
        /// </summary>
        //public List<Dictionary<string, string>> AllDBUsers
        //{
        //    get
        //    {
        //        if (Session["AllUsers"] != null)
        //            return (List<Dictionary<string, string>>)Session["AllUsers"];
        //        else
        //            return UserBL.GetAllUserDetails();
        //    }
        //    set
        //    {
        //        if (value == null)
        //            Session.Remove("AllUsers");
        //        Session["AllUsers"] = value;
        //    }
        //}

        public string GetMailBody(string Names, string Body)
        {
            EmailMessageBody ebody = new EmailMessageBody() { Names = Names, EmailBody = Body };
            //string emailbody = ebody.Names +":"+ ebody.EmailBody;
            // return emailbody;  
            return  RenderPartialViewToString("_EmailMessageBody", ebody);
        }

         

        protected string RenderPartialViewToString()
        {
            return RenderPartialViewToString(null, null);
        }

        protected string RenderPartialViewToString(string viewName)
        {
            return RenderPartialViewToString(viewName, null);
        }

        protected string RenderPartialViewToString(object model)
        {
            return RenderPartialViewToString(null, model);
        }

        protected string RenderPartialViewToString(string viewName, object model)
        {
            if (string.IsNullOrEmpty(viewName))
                viewName = ControllerContext.RouteData.GetRequiredString("action");

            ViewData.Model = model;

            using (StringWriter sw = new StringWriter())
            {
                ViewEngineResult viewResult = ViewEngines.Engines.FindPartialView(ControllerContext, viewName);
                ViewContext viewContext = new ViewContext(ControllerContext, viewResult.View, ViewData, TempData, sw);
                viewResult.View.Render(viewContext, sw);

                return sw.GetStringBuilder().ToString();
            }
        }

        public void alert(MyResult res)
        {
            TempData["Result"] = res;
        }
    }
}
