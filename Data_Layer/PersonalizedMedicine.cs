#region using namespaces
using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using DAL.Models;
using System.ComponentModel.DataAnnotations;
using System.Data.SqlClient;
using System.Globalization;
#endregion

namespace DAL
{
    public class PersonalizedMedicine
    {
        public static List<SelectListItem> GetGeneNames(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgenes = (from g in entity.Genes.AsEnumerable().OrderBy(k => k.Name) select new SelectListItem { Value = g.GeneID.ToString(), Text = g.Name, Selected = (g.GeneID == id) }).ToList();
                return getgenes;
            }

        }

        public static List<SelectListItem> GetparticularGeneNames(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgenes = (from g in entity.Genes.AsEnumerable().Where(i => i.GeneID == id).OrderBy(k => k.Name) select new SelectListItem { Value = g.GeneID.ToString(), Text = g.Name, Selected = (g.GeneID == id) }).ToList();
                return getgenes;
            }

        }


        public static List<SelectListItem> GeneGenesalias(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (id != null && id != 0)
                {
                    var getgenes = (from g in entity.GeneAliases.AsEnumerable().Where(i => i.GeneID == id).OrderBy(k => k.AliasName) select new SelectListItem { Value = g.AliasID.ToString(), Text = g.AliasName, Selected = (g.GeneID == id) }).ToList();
                    return getgenes;
                }
                else
                {
                    var genealias = (from g in entity.GeneAliases.AsEnumerable().OrderBy(k => k.AliasName) select new SelectListItem { Value = g.AliasID.ToString(), Text = g.AliasName }).ToList();
                    return genealias;
                }
            }
        }

        public static List<SelectListItem> GetTestNames(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test = (from t in entity.Tests.AsEnumerable().OrderBy(k => k.Name) select new SelectListItem { Value = t.TestID.ToString(), Text = t.Name, Selected = (t.TestID == id) }).ToList();
                return test;

            }
        }

        public static List<SelectListItem> GetTestsforGenebygeneid(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test = (from t in entity.lib_GetTestsForGeneByGeneID(id).OrderBy(k => k.Name) select new SelectListItem { Value = t.TestID.ToString(), Text = t.Name }).ToList();
                return test;
            }
        }

        public static List<SelectListItem> GetGenesForTestByTestID(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test = (from t in entity.lib_GetGenesForTestByTestID(id).OrderBy(k => k.Name) select new SelectListItem { Value = t.GeneID.ToString(), Text = t.Name }).ToList();
                return test;
            }
        }

        public static List<SelectListItem> GetAliasNameByGeneIDAliasID(int? geneid, int? aliasid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var genes = (from t in entity.GeneAliases.AsEnumerable() where t.GeneID == geneid && t.AliasID == aliasid select t.GeneID).FirstOrDefault();
                var getgenes = (from g in entity.Genes.AsEnumerable().Where(i => i.GeneID == genes).OrderBy(k => k.Name) select new SelectListItem { Value = g.GeneID.ToString(), Text = g.Name }).ToList();
                return getgenes;
            }
        }

        public static List<PersonalizedMedicine_User> GetGenealiases(int? geneid)
        {
            bool check = checkGeneexists(geneid);
            if (geneid != null && geneid != 0 && check)
            {
                var genealiasdata = new List<PersonalizedMedicine_User>();
                using (EditorsEntities entity = new EditorsEntities())
                {
                    var genes = (from gl in entity.GeneAliases.Where(i => i.GeneID == geneid).OrderBy(k => k.AliasName) select gl).ToList();
                    foreach (var item in genes)
                    {
                        var getgenealias = new PersonalizedMedicine_User();
                        getgenealias.aliasid = item.AliasID + "_" + item.GeneID;
                        getgenealias.GeneAlias = item.AliasName;
                        genealiasdata.Add(getgenealias);
                    }
                    return genealiasdata;
                }
            }
            else
            {
                var genealiasdata = new List<PersonalizedMedicine_User>();
                using (EditorsEntities entity = new EditorsEntities())
                {
                    var genes = (from gl in entity.GeneAliases.OrderBy(k => k.AliasName) select gl).ToList();
                    foreach (var item in genes)
                    {
                        var getgenealias = new PersonalizedMedicine_User();
                        getgenealias.aliasid = item.AliasID + "_" + item.GeneID;
                        getgenealias.GeneAlias = item.AliasName;
                        genealiasdata.Add(getgenealias);
                    }
                    return genealiasdata;
                }
            }
        }

        #region Genedetails

        public static PersonalizedMedicine_User GetGeneDetails(int? Geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgene = (from genes in entity.Genes.AsEnumerable()
                               where genes.GeneID == Convert.ToInt64(Geneid)
                               select new PersonalizedMedicine_User
                               {
                                   Symbol = genes.Symbol,
                                   FullName = genes.FullName,
                                   Summary = genes.Summary,
                                   Aliases = (entity.GeneAliases.Where(i => i.GeneID == Geneid).ToList().ToDictionary(t => t.AliasID, t => t.AliasName))
                               }).FirstOrDefault();

                return getgene;
            }
        }


        public static bool checkGeneexists(int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var check = entity.Genes.Any(i => i.GeneID == geneid);
                if (check == true)
                {
                    return true;
                }
                else { return false; }
            }
        }

        public static bool checkTestexists(int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var check = entity.Tests.Any(i => i.TestID == testid);
                if (check == true)
                {
                    return true;
                }
                else { return false; }
            }
        }

        /// <summary>
        /// TO GET Clinical science links with Geneid
        /// </summary>
        /// <param name="geneid"></param>
        /// <returns></returns>
        public static List<clinicalsciencelinks> Getclinicallinks(int? geneid)
        {
            var linkdata = new List<clinicalsciencelinks>();
            using (EditorsEntities entity = new EditorsEntities())
            {

                var clinicallinks = (from csl in entity.GenesArticles
                                     where csl.GeneID == geneid
                                     select new clinicalsciencelinks
                                     {
                                         ArticleId = csl.ArticleID,
                                         ArticleTitle = csl.ArticleTitle,
                                         Year = csl.Year,
                                         AuthorList = ((from t1 in entity.ArticlesAuthors
                                                        where
                                                          t1.ArticleID == csl.ArticleID
                                                        select
                                                          t1.AuthorName).Take(1).FirstOrDefault())
                                     }).ToList();

                foreach (var item in clinicallinks)
                {
                    clinicalsciencelinks linkinfo = new clinicalsciencelinks();
                    linkinfo.ArticleId = item.ArticleId;
                    linkinfo.ArticleTitle = item.ArticleTitle;
                    linkinfo.Year = item.Year;
                    linkinfo.AuthorList = item.AuthorList;
                    linkinfo.gene = Convert.ToInt32(geneid);
                    linkdata.Add(linkinfo);
                }
                return linkdata;
            }
        }


        public static List<PersonalizedMedicine_User> getCommentsSection(int? Geneid)
        {
            var Getcommentslist = new List<PersonalizedMedicine_User>();
            using (EditorsEntities entity = new EditorsEntities())
            {

                var commentslist = new List<PersonalizedMedicine_User>();
                var getcomments = (from gc in entity.GeneComments
                                   join ca in entity.CommentAuthors on gc.id equals ca.id
                                   where gc.GeneID == Geneid
                                   select new PersonalizedMedicine_User
                                   {
                                       CommentID = gc.CommentID,
                                       Commnet = gc.Comment,
                                       CommnetDate = gc.CommentDate,
                                       Author = ca.name
                                   }).ToList();
                if (getcomments != null && getcomments.Count != 0)
                {
                    foreach (var data in getcomments)
                    {
                        var comments = new PersonalizedMedicine_User();
                        comments.CommentID = data.CommentID;
                        comments.Commnet = data.Commnet;
                        comments.CommnetDate = data.CommnetDate;
                        comments.Author = data.Author;
                        comments.Getspecialties = (from gcc in entity.GeneCommentCombos
                                                   join sc in entity.Specialties on gcc.SpecialtyID equals sc.SpecialtyID
                                                   join tp in entity.Topics on gcc.TopicID equals tp.TopicID
                                                   join sbp in entity.SubTopics on gcc.SubTopicID equals sbp.SubTopicID
                                                   where gcc.GeneID == Geneid && gcc.CommentID == data.CommentID
                                                   select new PersonalizedMedicinespecialties
                                                   {
                                                       SpecialtyName = sc.SpecialtyName,
                                                       Topicname = tp.TopicName,
                                                       Subtopicname = sbp.SubTopicName
                                                   }).ToList();
                        commentslist.Add(comments);
                        Getcommentslist = commentslist;
                    }
                    return Getcommentslist;
                }
                return Getcommentslist;
            }
        }


        public static List<PersonalizedMedicine_User> getRelatedEditorsChoiceSection(int? Geneid, int? Userid)
        {
            var editorcommentslist = new List<PersonalizedMedicine_User>();
            int[] newpmid;
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getrelatededitorscomments = (entity.lib_GetEditorsChoiceCommentsForGeneByGeneID(Geneid)).ToList();
                var commentslist = new List<PersonalizedMedicine_User>();
                foreach (var item in getrelatededitorscomments)
                {
                    var editorcmnts = new PersonalizedMedicine_User();
                    newpmid = Getpmids(item.CommentID);

                    foreach (var data in newpmid)
                    {
                        editorcmnts = DisplayPmids(Userid, data.ToString(), 2, 1);

                        editorcmnts.EditorCommentID = item.CommentID;
                        editorcmnts.EditorCommnet = item.Comment;
                        editorcmnts.EditorCommentDate = Convert.ToInt32(item.CommentDate);
                        editorcmnts.EditorCommentMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(Convert.ToInt32(item.CommentMonth));

                        editorcmnts.EditorCommentAuthor = item.Author;
                        editorcmnts.Getspecialties = (from ecc in entity.EditorialComments
                                                      join stref in entity.SubTopicReferences on ecc.ThreadID equals stref.ThreadID
                                                      join sbtpc in entity.SubTopics on stref.SubTopicID equals sbtpc.SubTopicID
                                                      join tpc in entity.Topics on sbtpc.TopicID equals tpc.TopicID
                                                      join sp in entity.Specialties on tpc.SpecialtyID equals sp.SpecialtyID
                                                      where ecc.CommentID == item.CommentID
                                                      select new PersonalizedMedicinespecialties
                                                      {
                                                          SpecialtyName = sp.SpecialtyName,
                                                          Topicname = tpc.TopicName,
                                                          Subtopicname = sbtpc.SubTopicName
                                                      }).ToList();

                        commentslist.Add(editorcmnts);
                        editorcommentslist = commentslist;
                    }

                }
                return editorcommentslist;
            }
        }

        //lib_GetEditorsChoiceCommentsCitationsForCommentByCommentID
        public static PersonalizedMedicine_User DisplayPmids(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                PersonalizedMedicine_User result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);
                result = entity.Database.SqlQuery<PersonalizedMedicine_User>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();
                return result;
            }
        }


        public static int[] Getpmids(int? Commentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getpmids = (from t1 in entity.EditorialComments.AsEnumerable()
                                join t2 in entity.ArticleSelections on t1.ThreadID equals t2.ThreadID
                                where
                                 t1.CommentID == Commentid
                                select t2.PMID).ToArray();
                return getpmids;
            }
        }



        public static List<PersonalizedMedicine_User> GetAttachedGenealiastoTest(int? testid)
        {
            var attchgenes = new List<PersonalizedMedicine_User>();

            using (EditorsEntities entity = new EditorsEntities())
            {
                var getlist = new List<PersonalizedMedicine_User>();
                var getgeneid = entity.lib_GetGenesForTestByTestID(testid).ToList();
                foreach (var data in getgeneid)
                {
                    var getgalias = entity.GeneAliases.AsEnumerable().Where(i => i.GeneID == data.GeneID).ToList();
                    foreach (var item in getgalias)
                    {
                        var attchedtestgenes = new PersonalizedMedicine_User();
                        attchedtestgenes.Attachedgene = item.AliasName;
                        attchedtestgenes.aliasid = item.AliasID + "_" + item.GeneID;
                        getlist.Add(attchedtestgenes);
                        attchgenes = getlist;
                    }
                }
                return attchgenes;
            }

        }

        public static List<PersonalizedMedicine_User> GetaliasesforGene(int? geneid)
        {
            var attchgenes = new List<PersonalizedMedicine_User>();

            using (EditorsEntities entity = new EditorsEntities())
            {
                var getlist = new List<PersonalizedMedicine_User>();
                var getgeneid = entity.GeneAliases.AsEnumerable().Where(i => i.GeneID == geneid).ToList();
                foreach (var data in getgeneid)
                {
                    var attchedtestgenes = new PersonalizedMedicine_User();
                    attchedtestgenes.Attachedgene = data.AliasName;
                    attchedtestgenes.aliasid = data.AliasID + "_" + data.GeneID;
                    getlist.Add(attchedtestgenes);
                    attchgenes = getlist;
                }
                return attchgenes;
            }

        }


        //lib_GetGeneCitationsDirectlyByGeneID
        public static List<PersonalizedMedicine_User> GetGeneCitations(int userid, int? geneid)
        {
            var gene_citlist = new List<PersonalizedMedicine_User>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gene_citations = (from cg in entity.CitationsGenes.AsEnumerable() where cg.GeneID == Convert.ToInt64(geneid) select cg.PMID).ToList();
                if (gene_citations != null)
                {
                    foreach (var data in gene_citations)
                    {
                        if (data != 0)
                        {
                            PersonalizedMedicine_User gene = DisplayPmids(Convert.ToInt32(userid), data.ToString(), 2, 1);
                            gene.Displaydate = !string.IsNullOrEmpty(gene.Displaydate) ? gene.Displaydate.Substring(0, 4) : null;
                            gene.Pmid = Convert.ToInt32(data);
                            gene_citlist.Add(gene);
                            gene.Gene_citationslist = gene_citlist;
                        }
                    }
                    return gene_citlist;
                }
                return gene_citlist;
            }

        }

        public static List<Sclink> Getlinkinfo(int? geneid)
        {
            var linkdata = new List<Sclink>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var LinkID = (from gl in entity.GenesLinks where gl.GeneID == geneid select gl).ToList();
                foreach (var item in LinkID)
                {
                    Sclink linkinfo = new Sclink();
                    linkinfo.geneid = Convert.ToInt32(item.GeneID);
                    linkinfo.Linkid = item.LinkID;
                    linkinfo.sclink = item.Link;
                    linkdata.Add(linkinfo);
                }
                return linkdata;
            }
        }

        #endregion

        #region Testdetails

        //lib_GetTestCommentsByTestID
        //lib_GetTestCommentSTSByTestID
        /// <summary>
        /// To get Test Comments with Testid
        /// </summary>
        /// <param name="testid"></param>
        /// <returns></returns>
        public static List<PersonalizedMedicine_User> getTestCommentsSection(int? testid)
        {
            var Getcommentslist = new List<PersonalizedMedicine_User>();
            using (EditorsEntities entity = new EditorsEntities())
            {

                var commentslist = new List<PersonalizedMedicine_User>();
                var getcomments = (from tc in entity.TestComments
                                   join ca in entity.CommentAuthors on tc.id equals ca.id
                                   where tc.TestID == testid
                                   select new PersonalizedMedicine_User
                                   {
                                       CommentID = tc.CommentID,
                                       Commnet = tc.Comment,
                                       CommnetDate = tc.CommentDate,
                                       Author = ca.name
                                   }).ToList();
                if (getcomments != null && getcomments.Count != 0)
                {
                    foreach (var data in getcomments)
                    {
                        var comments = new PersonalizedMedicine_User();
                        comments.CommentID = data.CommentID;
                        comments.Commnet = data.Commnet;
                        comments.CommnetDate = data.CommnetDate;
                        comments.Author = data.Author;
                        comments.GetTestspecialties = (from tcc in entity.TestCommentCombos
                                                       join sc in entity.Specialties on tcc.SpecialtyID equals sc.SpecialtyID
                                                       join tp in entity.Topics on tcc.TopicID equals tp.TopicID
                                                       join sbp in entity.SubTopics on tcc.SubTopicID equals sbp.SubTopicID
                                                       where tcc.TestID == testid && tcc.CommentID == data.CommentID
                                                       select new PersonalizedMedicinespecialties
                                                       {
                                                           SpecialtyName = sc.SpecialtyName,
                                                           Topicname = tp.TopicName,
                                                           Subtopicname = sbp.SubTopicName
                                                       }).ToList();
                        commentslist.Add(comments);
                        Getcommentslist = commentslist;
                    }
                    return Getcommentslist;
                }
                return Getcommentslist;
            }
        }

        //lib_GetEditorsChoiceCommentsForTestByTestID
        public static List<PersonalizedMedicine_User> getRelatedEditorsTestChoiceSection(int? testid, int? Userid)
        {
            var editorcommentslist = new List<PersonalizedMedicine_User>();
            int[] newpmid;
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getrelatededitorscomments = (entity.lib_GetEditorsChoiceCommentsForTestByTestID(testid)).ToList();
                var commentslist = new List<PersonalizedMedicine_User>();
                foreach (var item in getrelatededitorscomments)
                {
                    var editorcmnts = new PersonalizedMedicine_User();
                    newpmid = Getpmids(item.CommentID);

                    foreach (var data in newpmid)
                    {
                        editorcmnts = DisplayPmids(Userid, data.ToString(), 2, 1);

                        editorcmnts.EditorCommentID = item.CommentID;
                        editorcmnts.EditorCommnet = item.Comment;
                        editorcmnts.EditorCommentDate = Convert.ToInt32(item.CommentDate);
                        editorcmnts.EditorCommentMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(Convert.ToInt32(item.CommentMonth));
                        editorcmnts.EditorCommentAuthor = item.Author;
                        editorcmnts.GetTestspecialties = (from ecc in entity.EditorialComments
                                                          join stref in entity.SubTopicReferences on ecc.ThreadID equals stref.ThreadID
                                                          join sbtpc in entity.SubTopics on stref.SubTopicID equals sbtpc.SubTopicID
                                                          join tpc in entity.Topics on sbtpc.TopicID equals tpc.TopicID
                                                          join sp in entity.Specialties on tpc.SpecialtyID equals sp.SpecialtyID
                                                          where ecc.CommentID == item.CommentID
                                                          select new PersonalizedMedicinespecialties
                                                          {
                                                              SpecialtyName = sp.SpecialtyName,
                                                              Topicname = tpc.TopicName,
                                                              Subtopicname = sbtpc.SubTopicName
                                                          }).ToList();

                        commentslist.Add(editorcmnts);
                        editorcommentslist = commentslist;
                    }
                }
                return editorcommentslist;
            }
        }


        public static PersonalizedMedicine_User GetTestDetails(int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gettests = (from tests in entity.Tests.AsEnumerable()
                                where tests.TestID == Convert.ToInt64(testid)
                                select new PersonalizedMedicine_User
                                {
                                    Name = tests.Name,
                                    Summary = tests.Summary
                                }).FirstOrDefault();
                return gettests;
            }
        }

        public static List<PersonalizedMedicine_User> GetTestCitations(int userid, int? testid)
        {
            var test_citlist = new List<PersonalizedMedicine_User>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test_citations = (from ct in entity.CitationsTests.AsEnumerable() where ct.TestID == Convert.ToInt64(testid) select ct.PMID).ToList();
                if (test_citations != null)
                {
                    foreach (var data in test_citations)
                    {
                        if (data != 0)
                        {
                            PersonalizedMedicine_User test = DisplayPmids(Convert.ToInt32(userid), data.ToString(), 2, 1);
                            test.Displaydate = !string.IsNullOrEmpty(test.Displaydate) ? test.Displaydate.Substring(0, 4) : null;
                            test.Pmid = Convert.ToInt32(data);
                            test_citlist.Add(test);
                            test.Gene_citationslist = test_citlist;
                        }
                    }
                    return test_citlist;
                }
                return test_citlist;
            }

        }

        public static List<Sclink> GetTestlinkinfo(int? testid)
        {
            var linkdata = new List<Sclink>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var LinkID = (from tl in entity.TestsLinks where tl.TestID == testid select tl).ToList();
                foreach (var item in LinkID)
                {
                    Sclink linkinfo = new Sclink();
                    linkinfo.geneid = Convert.ToInt32(item.TestID);
                    linkinfo.Linkid = item.LinkID;
                    linkinfo.sclink = item.Link;
                    linkdata.Add(linkinfo);
                }
                return linkdata;
            }
        }


        #endregion

    }
}
