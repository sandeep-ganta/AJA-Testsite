using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace AJA_Core
{
    public class CustomHandleErrorAttribute : HandleErrorAttribute
    {
        // private readonly ILog _logger;

        public CustomHandleErrorAttribute()
        {
            //  _logger = LogManager.GetLogger("MyLogger");
        }
    }
}
