using System.Web;
using System.Web.Mvc;
using AJA_Core;

namespace AJA
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new CustomHandleErrorAttribute());
            filters.Add(new ClearCacheAttribute());
            filters.Add(new CheckUserCookieAttribute());

        }
    }
}