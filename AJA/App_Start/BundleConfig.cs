
using System.Web;
using System.Web.Optimization;

namespace AJA.App_Start
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            var _Jquery_UI_CDN = "https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js";

            var _Jquery_CDN = "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js";


            bundles.Add(new ScriptBundle("~/bundles/jquery", _Jquery_CDN).Include(
                "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/Commonscript", _Jquery_CDN).Include(
                "~/Scripts/Common.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryui", _Jquery_UI_CDN).Include(
                "~/Scripts/jquery-ui-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery_placeholder", _Jquery_CDN).Include(
                "~/Scripts/jquery_placeholder.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
 "~/Scripts/jquery.unobtrusive*",
 "~/Scripts/jquery.validate*",
 "~/Scripts/jquery.validate.unobtrusive.js"));

            bundles.Add(new ScriptBundle("~/bundles/Chosen").Include("~/Scripts/chosen.jquery.min.js"));
            bundles.Add(new ScriptBundle("~/bundles/Common").Include("~/Scripts/Common.js"));

            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                       "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/slimscroll").Include(
                       "~/Scripts/jquery.slimscroll.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/ckeditor").Include("~/Scripts/ckeditor.js")); 
            bundles.Add(new ScriptBundle("~/bundles/ckjquery").Include("~/Scripts/jquery.js"));
            bundles.Add(new ScriptBundle("~/bundles/jquery.cleditor").Include("~/Scripts/jquery.cleditor.js"));
             
            bundles.Add(new StyleBundle("~/Content/css").Include("~/Content/main.css"));
            bundles.Add(new StyleBundle("~/Content/Gridviewcss").Include("~/Content/GridView.css"));
            //bundles.Add(new StyleBundle("~/Content/Chosen-css").Include("~/Content/chosen.css"));

            bundles.Add(new StyleBundle("~/Content/themes/base/css").Include(
                "~/Content/themes/base/jquery.ui.css",
                        "~/Content/themes/base/jquery.ui.core.css",
                        "~/Content/themes/base/jquery.ui.resizable.css",
                        "~/Content/themes/base/jquery.ui.selectable.css",
                        "~/Content/themes/base/jquery.ui.accordion.css",
                        "~/Content/themes/base/jquery.ui.autocomplete.css",
                        "~/Content/themes/base/jquery.ui.button.css",
                        "~/Content/themes/base/jquery.ui.dialog.css",
                        "~/Content/themes/base/jquery.ui.slider.css",
                        "~/Content/themes/base/jquery.ui.tabs.css",
                        "~/Content/themes/base/jquery.ui.datepicker.css",
                        "~/Content/themes/base/jquery.ui.progressbar.css",
                        "~/Content/themes/base/jquery.ui.theme.css"));


            //bundles.Add(new StyleBundle("~/Content/themes/AC-theme/css").Include(
            //            "~/Content/themes/AC-theme/jquery-ui-1.10.3.custom.css"
            //          ));

            //bundles.Add(new StyleBundle("~/Content/themes/AC-Metro-theme/css").Include(
            //            "~/Content/themes/AC-Metro-Theme/jquery-ui.css"
                      //));
        }
    }
}
