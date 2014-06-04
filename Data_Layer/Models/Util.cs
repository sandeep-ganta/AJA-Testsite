#region Usings 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
#endregion

namespace DAL.Models
{
    public class MyResult
    {
        public bool restype { get; set; }

        public string Message { get; set; }

        public string Tittle { get; set; }

        public string ClassName
        {
            get
            {
                if (restype)
                {
                    return "ui-icon ui-icon-circle-check";

                }
                else
                {
                    return "ui-icon ui-icon-alert";
                }
            }
        }

    }


    public class EmailMessageBody
    {
        public string Names { get; set; }

        public string EmailBody { get; set; }
    }


}
