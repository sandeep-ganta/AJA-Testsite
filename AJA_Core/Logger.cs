using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using log4net;
using log4net.Appender;
using System.Web;
using System.Web.Configuration;

namespace AJA_Core
{
    public class Logger
    {
        public Logger()
        {
            string filename = System.DateTime.Today.ToString("dd-MMM-yyyy");
            string path = Path.Combine(HttpContext.Current.Request.MapPath("~"), "LogFiles\\" + filename + ".log");
            log4net.GlobalContext.Properties["LogFile"] = path;
            var logconfigpath = Path.Combine(HttpContext.Current.Request.MapPath("~"), WebConfigurationManager.AppSettings["Log4netConfig"].ToString());
            log4net.Config.XmlConfigurator.ConfigureAndWatch(new System.IO.FileInfo(logconfigpath));
            logger = LogManager.GetLogger(typeof(Logger).FullName.ToString());
        }


        private static ILog logger;



        public void WriteException(string emsg)
        {
            logger.Error(emsg);
        }
    }
}
