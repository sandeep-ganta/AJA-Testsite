#region Using namespaces
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AJA_Core;
using DAL;
using DAL.Entities;
using DAL.Models;
using System.Web.Security;
using System.Net.Mail;
using System.Configuration;
using System.Text;
#endregion

namespace AJA.Controllers
{
    public class HomeController : Base_Controller
    {
        public ActionResult Index()
        {
            if (CurrentUser.IsAuthenticated)
            {
                if (CurrentUser.IsAdmin)
                {
                    ViewBag.Result = TempData["Result"];
                    return RedirectToAction("AdminHome", "Admin");
                }
                else 
                {
                    ViewBag.Result = TempData["Result"]; 
                    return View();
                }
                
            }
            else
            {
                return View();
            }
        }

        public ActionResult About()
        {
            return View();
        }

        public ActionResult Contact()
        {
            return View();
        }

        public ActionResult Preview()
        {
            return View();
        }

        public ActionResult Error()
        {
            Exception exception = Server.GetLastError();
            System.Diagnostics.Debug.WriteLine(exception);

            return View();
        }

        public ActionResult AboutROEditors(int? Specilatyid)
        {
            int? id = 1;
            AboutROEditors ROEditors = new AboutROEditors();
            var editorslist = new List<AboutROEditors>();
            if (Specilatyid != null)
            {
                ROEditors.GetRoTopics = EditorsBL.GetROSpecialtyeditors(Specilatyid);
                foreach (var item in ROEditors.GetRoTopics)
                {
                    var topiceditorslist = new List<AboutROEditors>();
                    topiceditorslist = EditorsBL.GetTopicEditors(Specilatyid, item.TopicId); 
                    editorslist.AddRange(topiceditorslist);
                    ROEditors.GetRoTopicEditors = editorslist;
                }
                ROEditors.GetRoAtlargeeditors = EditorsBL.GetROAtlargeeditors(Specilatyid);
                ROEditors.showspecialty = EditorsBL.GetSpecialityName(Specilatyid);
                ROEditors.Specialtylist = EditorsBL.GetSpecialityInUse(Specilatyid);
            }
            else
            {
                ROEditors.GetRoTopics = EditorsBL.GetROSpecialtyeditors(id);
                foreach (var item in ROEditors.GetRoTopics)
                {
                    var topiceditorslist = new List<AboutROEditors>();
                    topiceditorslist = EditorsBL.GetTopicEditors(id, item.TopicId);
                    editorslist.AddRange(topiceditorslist);
                    ROEditors.GetRoTopicEditors = editorslist;
                }
                ROEditors.GetRoAtlargeeditors = EditorsBL.GetROAtlargeeditors(id);
                ROEditors.showspecialty = EditorsBL.GetSpecialityName(id);
                ROEditors.Specialtylist = EditorsBL.GetSpecialityInUse(id);
            }
            return View(ROEditors);
        }
        public ActionResult Bios()
        {
            return View();
        }
        public ActionResult Biosdetailed(string info)
        {
            return View();
        }


    }

}
