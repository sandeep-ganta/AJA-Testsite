using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace AJA_Core
{
    public static class Exceptions
    {


        public static void TraceExceptions(HttpException lastErrorWrapper, HttpRequest Request)
        {
            if (lastErrorWrapper != null)
            {
                Exception lastError = lastErrorWrapper;
                if (lastErrorWrapper.InnerException != null)
                    lastError = lastErrorWrapper.InnerException;

                string lastErrorTypeName = lastError.GetType().ToString();
                string lastErrorMessage = lastError.Message;
                var UserName = "Anonymous User";
                if (HttpContext.Current.User != null)
                {
                    if (HttpContext.Current.User.Identity.Name != null || HttpContext.Current.User.Identity.Name != string.Empty)
                        UserName = HttpContext.Current.User.Identity.Name;
                }


                //string lastErrorStackTrace = lastError.StackTrace;

                var emsg = Request.RawUrl + " " + Request.HttpMethod + " " + " " + UserName + " " + lastErrorMessage;

                Logger log = new Logger();

                log.WriteException(emsg);
            }
        }
        public static void LogException(ExceptionContext filterContext)
        {
            var stacktrace = filterContext.Exception.StackTrace.ToString();
            Logger _log = new Logger();
            var controllerName = (string)filterContext.RouteData.Values["controller"];
            var actionName = (string)filterContext.RouteData.Values["action"];
            var msg = filterContext.Exception.Message;
            var UserName = HttpContext.Current.User.Identity.Name;
            if (UserName == null || UserName == string.Empty)
                UserName = "Anonymous User";

            var emsg = controllerName + "/" + actionName + " " + UserName + " -  " + msg + "\r\n" + stacktrace;
            _log.WriteException(emsg);

            filterContext.HttpContext.Response.Clear();
            //filterContext.HttpContext.Response.StatusCode = 500;
            //filterContext.ExceptionHandled = true;
        }


    }
}
