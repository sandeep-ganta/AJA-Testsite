using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Security;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Web.Mvc;

namespace AJA_Core
{
    public class DynamicEntity : DynamicObject
    {
        private IDictionary<string, object> _values;

        public DynamicEntity(IDictionary<string, object> values)
        {
            _values = values;
        }
        public override bool TryGetMember(GetMemberBinder binder, out object result)
        {
            if (_values.ContainsKey(binder.Name))
            {
                result = _values[binder.Name];
                return true;
            }
            result = null;
            return false;
        }

        public string[] GetProperties()
        {
            List<string> props = new List<string>();
            foreach (var _val in _values)
            {
                props.Add(_val.Key);
            }
            return props.ToArray();
        }

        public string GetProperty(string key)
        {
            return key;
        }
    }


    public static class CurrentUser
    {
        public static bool IsAuthenticated
        {
            get
            {
                return HttpContext.Current.User.Identity.IsAuthenticated;
            }
        }
        private static string[] UserData
        {
            get
            {
                FormsIdentity id = (FormsIdentity)HttpContext.Current.User.Identity;
                FormsAuthenticationTicket ticket = id.Ticket;

                return ticket.UserData.Split('|');
            }
        }

        public static string EmailId
        {
            get
            {
                return DAL.UserBL.GetUserEmailwithId(UserId);
            }
        }

        public static int UserId
        {
            get
            {
                //var g = HttpContext.Current.User.Identity.Name;
                //string b = g.Substring(g.IndexOf('='), g.Length - 1);
                //var a = 9;
                //return Convert.ToInt32(a);
                return Convert.ToInt32(HttpContext.Current.User.Identity.Name);
            }
        } 

        public static string UserName
        {
            get
            {
                return DAL.UserBL.GetUserNamewithId(UserId);
            }
        }

        public static string[] Roles
        {
            get
            {
                return DAL.UserBL.GetRoles(UserId).ToArray();
            }
        }

        public static string FirstName
        {
            get
            {
                return DAL.UserBL.GetFirstNamewithID(UserId);
            }
        }

        public static string LastName
        {
            get
            {
                return DAL.UserBL.GetLastNamewithID(UserId);
            }
        }

        public static string Title
        {
            get
            {
                return DAL.UserBL.GetTitlewithID(UserId);
            }
        }

        public static bool IsAdmin
        {
            get
            {
                return DAL.UserBL.IsUserInRole(UserId, "Administrator");
            }
        }

    }

    public class ClearCacheAttribute : ActionFilterAttribute
    {
        public override void OnResultExecuting(ResultExecutingContext filterContext)
        {
            if (HttpContext.Current.Request.UrlReferrer != null)
            {
                string Url = HttpContext.Current.Request.UrlReferrer.AbsolutePath;
                if (!Url.Contains("CreateMailing") && !Url.Contains("Messageproperty") && !Url.Contains("Composeplaintext") && !Url.Contains("PreviewPlaintext") && !Url.Contains("Composehtml") && !Url.Contains("PreviewHtml") && !Url.Contains("SendTest") && !Url.Contains("SelectRecipients") && !Url.Contains("Sendstatus"))
                {
                    filterContext.HttpContext.Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
                    filterContext.HttpContext.Response.Cache.SetValidUntilExpires(false);
                    filterContext.HttpContext.Response.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);
                    filterContext.HttpContext.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                    filterContext.HttpContext.Response.Cache.SetNoStore();
                    base.OnResultExecuting(filterContext);
                }
            }

        }
    }

    public class CheckUserCookieAttribute : ActionFilterAttribute
    {
        public override void OnResultExecuting(ResultExecutingContext filterContext)
        {
            if (CurrentUser.IsAuthenticated)
            {
                var res = DAL.UserBL.CheckUser(CurrentUser.UserId);
                if (!res)
                {
                    FormsAuthentication.SignOut();
                }
            }
        }
    }

    /// <summary>
    /// This class is used to differentiate between multiple layouts.
    /// </summary>
    public class LayoutInjecterAttribute : ActionFilterAttribute
    {
        private readonly string _masterName;
        public LayoutInjecterAttribute(string masterName)
        {
            _masterName = masterName;
        }

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            base.OnActionExecuted(filterContext);
            var result = filterContext.Result as ViewResult;
            if (result != null)
            {
                result.MasterName = _masterName;
            }
        }
    }

    /// <summary>
    /// Admin only can authorize
    /// </summary>
    //public class AdminOnlyAttribute : AuthorizeAttribute
    //{
    //    protected override bool AuthorizeCore(HttpContextBase httpContext)
    //    {
    //        if (System.Web.HttpContext.Current.User.Identity.IsAuthenticated)
    //        {
    //            var ticket = ((FormsIdentity)User.Identity).Ticket;
    //            return ticket.UserData;
    //        }
    //        else
    //        {
    //            return false;
    //        }
    //    }
    //}




}
