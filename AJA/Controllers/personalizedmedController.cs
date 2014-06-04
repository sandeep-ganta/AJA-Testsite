#region Usings

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using DAL;
using DAL.Entities;
using DAL.Models;
using AJA_Core;
using MvcSiteMapProvider;
using System.Net;
using System.IO;
using System.Xml;
using System.Text.RegularExpressions;

#endregion


namespace AJA.Controllers
{
    [HandleError]
    public class personalizedmedController : Base_Controller
    {
        //
        // GET: /PersonalizedMedicine/
        [Authorize(Roles = "AJA User")]
        public ActionResult personalized_medicine(int? geneid, string aliasid, int? testid)
        {
            var pmusermodel = new PersonalizedMedicine_User();
            pmusermodel.checkgene = PersonalizedMedicine.checkGeneexists(geneid);
            pmusermodel.checktest = PersonalizedMedicine.checkTestexists(testid);

            pmusermodel.GetGenealiases = PersonalizedMedicine.GetGenealiases(geneid);
            pmusermodel.GeneTestlist = PersonalizedMedicine.GetTestNames(testid);
            pmusermodel.Geneslist = PersonalizedMedicine.GetGeneNames(geneid);

            if (geneid != null && pmusermodel.checkgene)
            {
                pmusermodel = PersonalizedMedicine.GetGeneDetails(geneid);
                pmusermodel.GetGeneComments = PersonalizedMedicine.getCommentsSection(geneid);
                pmusermodel.GetRelatededitorscomments = PersonalizedMedicine.getRelatedEditorsChoiceSection(geneid, CurrentUser.UserId);
                pmusermodel.Getclinicalinks = PersonalizedMedicine.Getclinicallinks(geneid);
                pmusermodel.Gene_citationslist = PersonalizedMedicine.GetGeneCitations(CurrentUser.UserId, geneid);
                pmusermodel.GetGeneslinks = PersonalizedMedicine.Getlinkinfo(geneid);
                pmusermodel.GetGenealiases = PersonalizedMedicine.GetGenealiases(geneid);
                pmusermodel.GeneTestlist = PersonalizedMedicine.GetTestsforGenebygeneid(geneid);
                pmusermodel.Geneslist = PersonalizedMedicine.GetGeneNames(geneid);
                if (!string.IsNullOrEmpty(aliasid)) { pmusermodel.Geneslist = PersonalizedMedicine.GetparticularGeneNames(geneid); }
            }


            if (testid != null && pmusermodel.checktest)
            {
                pmusermodel = PersonalizedMedicine.GetTestDetails(testid);
                pmusermodel.GetTestComments = PersonalizedMedicine.getTestCommentsSection(testid);
                pmusermodel.GetRelatededitorsTestcomments = PersonalizedMedicine.getRelatedEditorsTestChoiceSection(testid, CurrentUser.UserId);

                pmusermodel.Test_citationslist = PersonalizedMedicine.GetTestCitations(CurrentUser.UserId, testid);
                pmusermodel.GetTestslinks = PersonalizedMedicine.GetTestlinkinfo(testid);
                pmusermodel.GetGenesrelatedtoTest = PersonalizedMedicine.GetGenesForTestByTestID(testid);
                pmusermodel.GetGenealiases = PersonalizedMedicine.GetGenealiases(geneid);
                pmusermodel.GeneTestlist = PersonalizedMedicine.GetTestNames(testid);
                pmusermodel.Geneslist = PersonalizedMedicine.GetparticularGeneNames(geneid);
            }

            if (geneid != null) pmusermodel.GeneId = Convert.ToInt32(geneid);
            if (testid != null) pmusermodel.TestId = Convert.ToInt32(testid);
            pmusermodel.checkgene = PersonalizedMedicine.checkGeneexists(geneid);
            pmusermodel.checktest = PersonalizedMedicine.checkTestexists(testid);
            if ((geneid != null && pmusermodel.checkgene == false) || (testid != null && pmusermodel.checktest == false))
                pmusermodel.Geneslist = PersonalizedMedicine.GetGeneNames(geneid);

            return View(pmusermodel);
        }

        public ActionResult GetGenealiasbyGeneId(PersonalizedMedicine_User gene)
        {
            var pmmodel = new PersonalizedMedicine_User(); var pmusermodel = new List<PersonalizedMedicine_User>();
            // List<SelectListItem> genealis = PersonalizedMedicine.GeneGenesalias(gene.GeneId);
            List<SelectListItem> genetests = PersonalizedMedicine.GetTestsforGenebygeneid(gene.GeneId);
            pmusermodel = PersonalizedMedicine.GetaliasesforGene(gene.GeneId);

            pmmodel.GetGenealiases = PersonalizedMedicine.GetGenealiases(gene.GeneId);
            pmmodel.GeneTestlist = PersonalizedMedicine.GetTestNames(gene.TestId);
            return Json(new { pmusermodel, genetests, pmmodel.GetGenealiases, pmmodel.GeneTestlist }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetGenealiasbyTestid(PersonalizedMedicine_User gene)
        {
            var pmusermodel = new PersonalizedMedicine_User();
            pmusermodel.GetAttachedGenealias = PersonalizedMedicine.GetAttachedGenealiastoTest(gene.TestId);
            List<SelectListItem> genestest = PersonalizedMedicine.GetGenesForTestByTestID(gene.TestId);

            pmusermodel.Geneslist = PersonalizedMedicine.GetGeneNames(gene.GeneId);
            //pmusermodel.GeneTestlist = PersonalizedMedicine.GetTestNames(gene.TestId);
            pmusermodel.GetGenealiases = PersonalizedMedicine.GetGenealiases(gene.GeneId);
            return Json(new { pmusermodel.GetAttachedGenealias, genestest, pmusermodel.Geneslist, pmusermodel.GetGenealiases }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetGeneandTestsbyaliasID(PersonalizedMedicine_User gene)
        {
            var pmusermodel = new PersonalizedMedicine_User();
            List<SelectListItem> getgenesbyaliasid = PersonalizedMedicine.GetAliasNameByGeneIDAliasID(gene.GeneId, Convert.ToInt32(gene.aliasid));
            List<SelectListItem> genestest = PersonalizedMedicine.GetGenesForTestByTestID(gene.GeneId);
            // pmusermodel.GetAttachedGenealias = PersonalizedMedicine.GetAttachedGenealiastoTest(gene.TestId); 

            pmusermodel.Geneslist = PersonalizedMedicine.GetGeneNames(gene.GeneId);
            pmusermodel.GeneTestlist = PersonalizedMedicine.GetTestNames(gene.TestId);
            return Json(new { getgenesbyaliasid, genestest, pmusermodel.Geneslist, pmusermodel.GeneTestlist }, JsonRequestBehavior.AllowGet);
        }

        public PartialViewResult Editclinicallinks(PersonalizedMedicine_User gene)
        {
            var pmusermodel = new PersonalizedMedicine_User();
            pmusermodel.Getclinicalinks = PersonalizedMedicine.Getclinicallinks(gene.GeneId);
            return PartialView("_Clinicalsciencelinks", pmusermodel);
        }

    }
}
