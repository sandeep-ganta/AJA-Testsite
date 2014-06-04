using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Security;

namespace AJA_Core
{
    public class Base_Application : System.Web.HttpApplication
    {
        protected void Application_Error(object sender, EventArgs e)
        {

            HttpApplication httpApp = (HttpApplication)sender;

            var ex = httpApp.Server.GetLastError() as HttpException;

            HttpException lastErrorWrapper = Server.GetLastError() as HttpException;

            Exceptions.TraceExceptions(lastErrorWrapper, Request);
           
        }
         
    }
}
