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
using MVC4Grid;
using MVC4Grid.GridAttributes;
using MVC4Grid.GridExtensions;
#endregion

namespace DAL
{
    public class EditorsBL
    {
        #region large/topic Editor Details
        [GridPaging(NoofRows = 5)]
        [GridSearching]
        [GridSorting]
        public class EditorsdetValues
        {
            public EditorsdetValues()
            {

            }
            [Key]
            [HiddenInput]
            [GridSorting(Default = true)]
            public int EditorID { get; set; }

            [Required]
            [Display(Name = "Name")]
            [DisplayFormat(HtmlEncode = true)]
            [StringLength(50, ErrorMessage = "Max Length 50 characters")]
            public string name { get; set; }

            [Display(Name = "Email")]
            [EmailAddress(ErrorMessage = "Invalid Email Address.")]
            public string email { get; set; }

            [DisplayFormat(HtmlEncode = true)]
            [Display(Name = "Affiliations")]
            [StringLength(1000, ErrorMessage = "Max Length 1000 characters")]
            public string affiliations { get; set; }

            [Required]
            [HiddenInput]
            public int? SpecialityID { get; set; }

            [HiddenInput]
            public List<SelectListItem> SpecialityList { get; set; }

            [Display(Name = "Specialty")]
            public string SpecialtyName { get; set; }

            [Required]
            [Display(Name = "Start Date")]
            [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
            public DateTime? StartDate { get; set; }

            [Display(Name = "Retire Date")]
            [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
            public DateTime? RetireDate { get; set; }

            [HiddenInput]
            public int? TopicID { get; set; }

            [HiddenInput]
            public bool IsLargeEditor { get; set; }
        }
        #endregion

        #region Editor Topics
        [GridPaging(NoofRows = 5)]
        [GridSearching]
        [GridSorting]
        public class EditorTopics
        {
            [HiddenInput]
            [GridSorting(Default = true)]
            public int EditorID { get; set; }
            //[Required]

            [Display(Name = "Topic Name")]
            public string TopicName { get; set; }

            [Display(Name = "Start Date")]
            [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
            public DateTime? StartDate { get; set; }

            [Display(Name = "Retire Date")]
            [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
            public DateTime? RetireDate { get; set; }

            [Required(ErrorMessage = "Select Topic")]
            [Key]
            [HiddenInput]
            public int TopicID { get; set; }

            [HiddenInput]
            public List<SelectListItem> TopicList { get; set; }
        }
        #endregion

        #region editions

        /// <summary>
        /// This Class is used for Threads
        /// </summary>

        [GridPaging(NoofRows = 5)]
        [GridSearching]
        [GridSorting]
        public class Threads
        {
            public Threads()
            {

            }
            [Key]
            [HiddenInput]
            [GridSearching(Searching = false)]
            public int ThreadID { get; set; }

            [Display(Name = "Article Selections")]
            public string ArticleSelections { get; set; }

            [GridSorting(Default = true)]
            [Display(Name = "Editors")]
            public string Editors { get; set; }
        }


        /// <summary>
        /// This Class is used for Articleselections
        /// </summary>
        public class Articleselections
        {
            public Articleselections()
            { }

            public int ThreadId { get; set; }
            public string PMID { get; set; }
            public int Sortorder { get; set; }
        }

        /// <summary>
        /// This Class is used for EditionTopics
        /// </summary>

        [GridPaging(NoofRows = 10)]
        [GridSearching]
        [GridSorting]
        public class TopicDetValues
        {
            public TopicDetValues()
            {

            }
            [HiddenInput]
            [Key]
            public int TopicID { get; set; }

            [GridSorting(Default = true)]
            [Required]
            [Display(Name = "TopicName")]
            public string TopicName { get; set; }

            [HiddenInput]
            [Required]
            public int? SpecialityID { get; set; }
            [HiddenInput]
            public List<SelectListItem> SpecialityList { get; set; }

            [HiddenInput]
            [Display(Name = "Specialty")]
            public string SpecialtyName { get; set; }
            [HiddenInput]
            public DateTime? CreatedDate { get; set; }
            [HiddenInput]
            public int Type { get; set; }
            [HiddenInput]
            public int? SubTopicID { get; set; }
            [HiddenInput]
            public bool IsLargeEditor { get; set; }

        }

        /// <summary>
        /// This Class is used for EditorialComments
        /// </summary>
        [GridPaging(NoofRows = 5)]
        [GridSearching]
        [GridSorting]
        public class EditorialComments
        {
            public EditorialComments()
            { }
            [HiddenInput]
            public long GeneID { get; set; }
            [HiddenInput]
            public int AuthorID { get; set; }
            [HiddenInput]
            public string Name { get; set; }
            [HiddenInput]
            public string AuthorName { get; set; }
            [HiddenInput]
            public int Sortorder { get; set; }

            [Key]
            [HiddenInput]
            public int CommentID { get; set; }

            [GridSorting(Default = true)]
            [Display(Name = "Authors")]
            public string Authors { get; set; }
            [HiddenInput]
            public string Comment { get; set; }
            [HiddenInput]
            public List<CommentAuthor> Authordetails { get; set; }
            [HiddenInput]
            public List<Gene> Genedetails { get; set; }
        }

        /// <summary>
        /// This method returns List<Editions> 
        /// </summary>
        /// <returns>returns List<Editions> </returns>

        public static MVC4Grid.Grid.GridResult GetAllEditionsList(MVC4Grid.Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var editonssobj = (from e in entity.Editions
                                   join s in entity.Specialties on e.SpecialtyID equals s.SpecialtyID
                                   select new Editionsmodel
                                              {
                                                  EditionId = e.EditionID,
                                                  SpecialtyID = e.SpecialtyID,
                                                  PubDate = e.PubDate,
                                                  SpecialtyName = s.SpecialtyName
                                              }).GridFilterBy(Filter);
                return editonssobj;
            }
        }

        /// <summary>
        /// This method returns List<Threads> 
        /// </summary>
        /// <param name="id">Passing Threadid</param>
        /// <returns></returns>
        public static Grid.GridResult GetAllThreads(int? id, Grid.GridFilter filter)
        {
            List<Threads> thread = new List<Threads>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var edition = entity.adm_GetThreads(id).ToList();

                foreach (var edm in edition)
                {
                    Threads obj = new Threads();
                    obj.ThreadID = edm.ThreadID;
                    obj.ArticleSelections = edm.ArticleSelections ?? "";
                    obj.Editors = edm.Editors ?? "";
                    thread.Add(obj);
                }
                Grid.GridResult GridResult = new Grid.GridResult();
                GridResult.Count = thread.Count;
                GridResult.DataSource = (thread.AsQueryable<Threads>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);
                return GridResult;
            }
        }

        public static List<Threads> GetAllThreads(int? id)
        {
            List<Threads> thread = new List<Threads>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var edition = entity.adm_GetThreads(id).ToList();

                foreach (var edm in edition)
                {
                    Threads obj = new Threads();
                    obj.ThreadID = edm.ThreadID;
                    obj.ArticleSelections = edm.ArticleSelections;
                    obj.Editors = edm.Editors;
                    thread.Add(obj);
                }
                return thread;
            }
        }

        public static MVC4Grid.Grid.GridResult GetThreadContent(int? Cid, int? Eid, MVC4Grid.Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var contentsobj = (from st in entity.SubTopics
                                   join stref in entity.SubTopicReferences on st.SubTopicID equals stref.SubTopicID
                                   join t in entity.Topics on st.TopicID equals t.TopicID
                                   where
                                     stref.EditionID == Eid &&
                                     stref.ThreadID == Cid
                                   orderby
                                     st.SubTopicName
                                   select new TopicModels
                                                   {
                                                       EditionID = stref.EditionID,
                                                       ThreadId = stref.ThreadID,
                                                       SubTopicID = st.SubTopicID,
                                                       SubTopicName = (t.TopicName + "/" + st.SubTopicName)
                                                   }).GridFilterBy(Filter);
                return contentsobj;
            }
        }

        /// <summary>
        /// This method returns List<Articleselections> with Threadid
        /// </summary>
        /// <param name="threadid"></param>
        /// <returns>returns List<Articleselections></returns>
        public static MVC4Grid.Grid.GridResult GetArticleselections(int? threadid, MVC4Grid.Grid.GridFilter Filter)
        {
            //List<Articleselections> articles = new List<Articleselections>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var articleobj = (from Articles in entity.ArticleSelections
                                  where
                Articles.ThreadID == threadid
                                  orderby
                Articles.SortOrder
                                  select new ArticleselectionsModel
                                                           {
                                                               ThreadId = SqlFunctions.StringConvert((double)Articles.ThreadID).TrimStart() + "_" + SqlFunctions.StringConvert((double)Articles.PMID).TrimStart(),
                                                               PMID = SqlFunctions.StringConvert((double)Articles.PMID)
                                                           }).GridFilterBy(Filter);
                return articleobj;
            }
        }

        /// <summary>
        /// This method returns List of EditorialComments object with Threadid
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <returns>returns List of EditorialComments object</returns>
        public static Grid.GridResult GeteditorialComments(int? Threadid, Grid.GridFilter filter)
        {
            List<EditorialComments> coments = new List<EditorialComments>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = entity.adm_GetThreadComments(Threadid);
                foreach (var item in query)
                {
                    EditorialComments commentdetails = new EditorialComments();
                    commentdetails.Authors = item.Authors;
                    commentdetails.CommentID = item.CommentID;
                    coments.Add(commentdetails);
                }
                Grid.GridResult GridResult = new Grid.GridResult();
                GridResult.Count = coments.Count;
                GridResult.DataSource = (coments.AsQueryable<EditorialComments>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);
                return GridResult;
            }
        }

        public static List<EditorialComments> GeteditorialComments(int? Threadid)
        {
            List<EditorialComments> coments = new List<EditorialComments>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = entity.adm_GetThreadComments(Threadid);
                foreach (var item in query)
                {
                    EditorialComments commentdetails = new EditorialComments();
                    commentdetails.Authors = item.Authors;
                    commentdetails.CommentID = item.CommentID;
                    coments.Add(commentdetails);
                }
            }
            return coments;
        }
        /// <summary>
        /// This method returns EditorialCommentsModel with commentid
        /// </summary>
        /// <param name="cmid">Commentid</param>
        /// <returns></returns>
        public static EditorialCommentsModel EditComentdetails(int cmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorialCommentsModel model = new EditorialCommentsModel();
                model = (from m in entity.EditorialComments.Where(i => i.CommentID == cmid) select new EditorialCommentsModel { CommentID = m.CommentID, Comment = m.Comment }).FirstOrDefault();
                return model;
            }
        }

        /// <summary>
        /// This method returns List of EditorialCommentsModel with Commentid
        /// </summary>
        /// <param name="commentid">Passing Commentid</param>
        /// <returns>returns List of EditorialCommentsModel</returns>
        public static List<EditorialCommentsModel> EditEditorial(int commentid)
        {
            List<EditorialCommentsModel> co = new List<EditorialCommentsModel>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorialCommentsModel comdetails = new EditorialCommentsModel();
                var query = entity.EditorialComments.FirstOrDefault(i => i.CommentID == commentid);

                EditorialComment comnt = (from s in entity.EditorialComments.Include("CommentAuthors")
                                          where s.CommentID == commentid
                                          select s).FirstOrDefault<EditorialComment>();

                comdetails.Authordetails = comnt.CommentAuthors.ToList<CommentAuthor>();
                comdetails.Genedetails = comnt.Genes.ToList<Gene>();
                co.Add(comdetails);
                return co;
            }
        }

        /// <summary>
        /// This method returns List of CommentAuthor with Commentid
        /// </summary>
        /// <param name="commentid">Passing Commentid</param>
        /// <returns>returns List of CommentAuthor</returns>
        public static List<CommentAuthor> Authordetails(int commentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorialCommentsModel comdetails = new EditorialCommentsModel();
                var query = entity.EditorialComments.FirstOrDefault(i => i.CommentID == commentid);

                EditorialComment comnt = (from s in entity.EditorialComments.Include("CommentAuthors")
                                          where s.CommentID == commentid
                                          select s).FirstOrDefault<EditorialComment>();

                comdetails.Authordetails = comnt.CommentAuthors.ToList<CommentAuthor>();
                return comdetails.Authordetails;
            }
        }

        /// <summary>
        /// This method returns list of Genes with commentid
        /// </summary>
        /// <param name="commentid">Passing Commentid</param>
        /// <returns></returns>
        public static List<Gene> Genesdetails(int commentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorialCommentsModel comdetails = new EditorialCommentsModel();
                var query = entity.EditorialComments.FirstOrDefault(i => i.CommentID == commentid);

                EditorialComment comnt = (from s in entity.EditorialComments.Include("CommentAuthors")
                                          where s.CommentID == commentid
                                          select s).FirstOrDefault<EditorialComment>();

                comdetails.Genedetails = comnt.Genes.ToList<Gene>();
                return comdetails.Genedetails;
            }
        }

        /// <summary>
        /// This method returns listitem of Genes
        /// </summary>
        /// <returns>returns listitem of Genes</returns>
        public static List<SelectListItem> GetGenes()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var geneobj = (from m in entity.Genes.AsEnumerable()
                               orderby
                                 m.Name
                               select new SelectListItem
                               {
                                   Value = m.GeneID.ToString(),
                                   Text = m.Name
                               }).Distinct().ToList();

                return geneobj;
            }
        }

        /// <summary>
        /// This method returns listitem of CommentAuthors
        /// </summary>
        /// <returns>returns listitem of CommentAuthors</returns>
        public static List<SelectListItem> Getcommentauthors()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var authorobj = (from m in entity.CommentAuthors.AsEnumerable()
                                 orderby
                                  m.name
                                 select new SelectListItem
                                 {
                                     Value = m.id.ToString(),
                                     Text = m.name,
                                 }).Distinct().ToList();
                return authorobj;
            }

        }

        /// <summary>
        /// This method returns bool value of getting Articleselections with pmid, threadid
        /// </summary>
        /// <param name="pmid">Passing Pmid</param>
        /// <param name="threadid">Passing Threadid</param>
        /// <returns>returns bool value of getting Articleselections</returns>
        public static bool CheckPMIDacrticle(int pmid, int threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var res = entity.ArticleSelections.Where(i => i.PMID == pmid && i.ThreadID == threadid).FirstOrDefault();
                //   var res = entity.ArticleSelections.FirstOrDefault(i => i.PMID == pmid);
                if (res == null)
                    return false;
                else if (res.PMID == pmid)
                    return true;
                else
                    return false;
            }
        }

        public static bool CheckPMIDcitations(int? pmid)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                var res = entity.iCitations.Where(i => i.PMID == pmid).FirstOrDefault();
                using (EditorsEntities nonentit = new EditorsEntities())
                {
                    var result = nonentit.NonMedlineCitations.Where(i => i.PMID == pmid).FirstOrDefault();
                    if (res == null && result == null)
                        return false;
                    else if ((res != null && res.PMID == pmid) || (result != null && result.PMID == pmid))
                        return true;
                    else
                        return false;
                }
            }
        }
        /// <summary>
        /// This methor returns bool value of Deleted Edition with Editionid
        /// </summary>
        /// <param name="EId">Passing Editionsid</param>
        /// <returns>returns bool value of Deleted Edition</returns>
        public static bool DeleteEditionWithEID(int EId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var AllThreadslist = EditorsBL.GetAllThreads(EId);

                foreach (var item in AllThreadslist)
                {
                    var CommentsList = EditorsBL.GeteditorialComments(item.ThreadID);
                    foreach (var data in CommentsList)
                    {
                        DeleteEditorialComment(data.CommentID);
                    }

                    DeleteEditorialThreadEID(item.ThreadID);
                }

                var querySubTopicEditorRefs = (from SubTopicEditorRefs in entity.SubTopicEditorRefs where SubTopicEditorRefs.EditionID == EId select SubTopicEditorRefs).ToList();
                foreach (var del in querySubTopicEditorRefs)
                {
                    entity.SubTopicEditorRefs.Remove(del);
                    entity.SaveChanges();
                }

                var querySubTopicReferences = (from SubTopicReferences in entity.SubTopicReferences where SubTopicReferences.EditionID == EId select SubTopicReferences).ToList();
                foreach (var del in querySubTopicReferences)
                {
                    entity.SubTopicReferences.Remove(del);
                    entity.SaveChanges();

                }

                var queryeditions = (from m in entity.Editions where m.EditionID == EId select m).ToList();
                foreach (var item in queryeditions)
                {
                    entity.Editions.Remove(item);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        /// <summary>
        ///  This method returns bool value of Created Edition with Editionid
        /// </summary>
        /// <param name="edm">Edition class object</param>
        /// <returns>returns bool value of Created Edition</returns>
        public static bool CreateEdition(Edition edm)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (edm.PubDate != null)
                {
                    Edition Edition = new Edition();
                    Edition.PubDate = edm.PubDate;
                    Edition.SpecialtyID = edm.SpecialtyID;
                    entity.Editions.Add(Edition);
                    entity.SaveChanges();
                    return true;
                }
                else { return false; }
            }
        }

        /// <summary>
        /// This method returns bool value of Updated Edition with Editionid
        /// </summary>
        /// <param name="edition">Edition class object</param>
        /// <returns>returns bool value of Updated Edition</returns>
        public static bool UpdateEdition(Edition edition)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var queryEditions = (from m in entity.Editions where m.EditionID == edition.EditionID select m).FirstOrDefault();
                queryEditions.SpecialtyID = edition.SpecialtyID;
                queryEditions.PubDate = edition.PubDate;
                entity.SaveChanges();
                return true;
            }
        }

        /// <summary>
        /// This method returns Editionsmodel class object data with editionid
        /// </summary>
        /// <param name="EId">Passing Editionid</param>
        /// <returns>returns Editionsmodel class object data</returns>
        public static Editionsmodel GetEditions(int? EId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                Editionsmodel obj = new Editionsmodel();

                obj = (from e in entity.Editions
                       join s in entity.Specialties on e.SpecialtyID equals s.SpecialtyID
                       where e.EditionID == EId
                       select new Editionsmodel
                   {
                       EditionId = e.EditionID,
                       SpecialtyID = e.SpecialtyID,
                       PubDate = e.PubDate,
                       SpecialtyName = s.SpecialtyName
                   }).FirstOrDefault();

                return obj;
            }
        }


        public static bool checkEditions(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var check = entity.Editions.Any(i => i.EditionID == id);
                if (check == true)
                {
                    return true;
                }
                else { return false; }
            }
        }

        /// <summary>
        ///  This method returns Topicslist containing Topicid,TopicName with editionid
        /// </summary>
        /// <param name="Editionid">Passing Editionid</param>
        /// <returns>Listitem of Topics</returns>
        public static List<SelectListItem> GetTopicsList(int Editionid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from t in entity.Topics.AsEnumerable()
                             join e in entity.Editions on t.SpecialtyID equals e.SpecialtyID
                             where
                               e.EditionID == Editionid &&
                               t.Type == 1
                             orderby
                               t.TopicName
                             select new SelectListItem
                             {
                                 Value = t.TopicID.ToString(),
                                 Text = t.TopicName
                             }).ToList();
                return query;
            }

        }
        /// <summary>
        /// This method returns SubTopicslist containing SubTopicid,SubTopicName with topicid
        /// </summary>
        /// <param name="id">Passing Topicid</param>
        /// <returns>Listitem of Subtopics</returns>
        public static List<SelectListItem> GetSubTopics(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from SubTpics in entity.SubTopics.AsEnumerable()
                             where SubTpics.Type == 1 && SubTpics.TopicID == id
                             orderby SubTpics.SubTopicName
                             select new SelectListItem
                             {
                                 Value = SubTpics.SubTopicID.ToString(),
                                 Text = SubTpics.SubTopicName
                             }).ToList();
                return query;
            }
        }
        /// <summary>
        /// This method returns bool value of Deleted EditorialThread with Threadid
        /// </summary>
        /// <param name="id">Passing Threadid</param>
        /// <returns>bool value of Deleted Thread</returns>
        public static bool DeleteEditorialThreadEID(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var CommentsList = EditorsBL.GeteditorialComments(id);
                foreach (var data in CommentsList)
                {
                    DeleteEditorialComment(data.CommentID);
                }

                entity.adm_DeleteThread(id);
                entity.SaveChanges();
                return true;
            }
        }

        /// <summary>
        /// This method returns Pubdate from Editions with editionid
        /// </summary>
        /// <param name="editionid">Passing Editionid</param>
        /// <returns></returns>
        public static DateTime GetPubdate(int editionid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from m in entity.Editions where m.EditionID == editionid select m.PubDate).FirstOrDefault();
                return query;
            }
        }

        /// <summary>
        /// This method returns bool value of Created Thread
        /// </summary>
        /// <param name="model"></param>
        /// <param name="editionid">Passing Editionid</param>
        /// <returns>returns bool value of Created Thread</returns>
        public static string CreateExistingThread(TopicModels model, int editionid)
        {
            string checkres = string.Empty;
            if (model.SubTopicID != 0)
            {
                bool res = EditorsBL.CheckSubTopicExists(model.SubTopicID, editionid, model.ThreadId);
                if (!res)
                {
                    EditorsBL.CreateSubTopicReference(editionid, model.ThreadId, model.SubTopicID);
                    int Seniority = 1;
                    List<TopicModels> data = EditorsBL.GetAuthors(model.SubTopicID);
                    foreach (TopicModels item in data)
                    {
                        int commentid = item.CommenAuthorId;
                        int editortopicid = item.TopicID;
                        bool result = EditorsBL.CheckSubTopicEditref(editionid, model.ThreadId, commentid, editortopicid);
                        if (!result)
                        {
                            EditorsBL.CreateSubTopicEditorRef(editionid, model.ThreadId, commentid, editortopicid, Seniority);
                            Seniority = Seniority + 1;
                        }

                    }
                    checkres = "true";
                    return checkres;
                }
                else
                {
                    checkres = "exists";
                    return checkres;
                }
            }
            else
            {
                checkres = "false";
                return checkres;
                //return false;
            }
        }
        /// <summary>
        /// This method Create new Threads with subtopicid,editionid,threadid in Subtopicreference, Subtopiceditref
        /// </summary>
        /// <param name="model"></param>
        /// <param name="editionid"></param>
        /// <returns>returns bool of CreatednewThread</returns>
        public static string CreatenewThreads(TopicModels model, int editionid)
        {
            string checkres = string.Empty;
            if (model.SubTopicID != 0)
            {
                TopicModels topic = new TopicModels();
                topic.OriginalPubDate = EditorsBL.GetPubdate(editionid);
                bool check = EditorsBL.CreateNewThread(topic.OriginalPubDate);
                if (check)
                {
                    topic.ThreadId = EditorsBL.Getnewthread();
                    bool res = EditorsBL.CheckSubTopicExists(model.SubTopicID, editionid, topic.ThreadId);
                    if (res == false)
                    {
                        EditorsBL.CreateSubTopicReference(editionid, topic.ThreadId, model.SubTopicID);
                        int Seniority = 1;

                        List<TopicModels> data = EditorsBL.GetAuthors(model.SubTopicID);
                        foreach (TopicModels item in data)
                        {
                            int commentid = item.CommenAuthorId;
                            int editortopicid = item.TopicID;
                            bool result = EditorsBL.CheckSubTopicEditref(editionid, topic.ThreadId, commentid, editortopicid);
                            if (result == false)
                            {
                                EditorsBL.CreateSubTopicEditorRef(editionid, topic.ThreadId, commentid, editortopicid, Seniority);
                                Seniority = Seniority + 1;
                            }
                        }
                    }
                }
                checkres = "true";
                return checkres;
            }
            else
            {
                checkres = "false";
                return checkres;
            }
        }

        /// <summary>
        /// This method returns bool value of creatednew Thread with datetime
        /// </summary>
        /// <param name="edm">Passing DateTime to OriginalPubDate </param>
        /// <returns>returns bool value of creatednew Thread</returns>
        public static bool CreateNewThread(DateTime edm)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorialThread ethread = new EditorialThread();
                ethread.OriginalPubDate = edm;
                ethread.ThreadName = "Thread name not in use";
                entity.EditorialThreads.Add(ethread);
                entity.SaveChanges();
                return true;
            }
        }

        /// <summary>
        /// This method gets int value of Threads order by Threadid
        /// </summary>
        /// <returns>returns int value of Threads</returns>
        public static int Getnewthread()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int id = (from EditorialThreads in entity.EditorialThreads
                          orderby EditorialThreads.ThreadID descending
                          select EditorialThreads.ThreadID).First();
                return id;
            }
        }

        /// <summary>
        /// This method gets bool value of Subtopics with Subtopicid,editionid,threadid
        /// </summary>
        /// <param name="subtopicid">Passing Subtopicid</param>
        /// <param name="editionid">Passing Editionid</param>
        /// <param name="threadid">Passing Threadid</param>
        /// <returns></returns>
        public static bool CheckSubTopicExists(int subtopicid, int editionid, int threadid)
        {
            bool res = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = from SubTopicReferences in entity.SubTopicReferences
                            where
                              SubTopicReferences.EditionID == editionid &&
                              SubTopicReferences.ThreadID == threadid &&
                              SubTopicReferences.SubTopicID == subtopicid
                            select SubTopicReferences;
                foreach (var item in query)
                {
                    if (item.EditionID == null)
                        res = false;
                    else
                        res = true;
                }
                return res;
            }
        }

        /// <summary>
        /// This method gets bool value of Subtopics with Subtopicid,editionid,threadid,commentid
        /// </summary>
        /// <param name="editionid"></param>
        /// <param name="threadid"></param>
        /// <param name="commentid"></param>
        /// <param name="editortopicid"></param>
        /// <returns>returns bool value of Subtopics</returns>
        public static bool CheckSubTopicEditref(int editionid, int threadid, int commentid, int editortopicid)
        {
            bool res = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = from SubTopicEditRef in entity.SubTopicEditorRefs
                            where
                              SubTopicEditRef.EditionID == editionid &&
                              SubTopicEditRef.ThreadID == threadid &&
                              SubTopicEditRef.EditorID == commentid &&
                              SubTopicEditRef.TopicID == editortopicid
                            select SubTopicEditRef;

                foreach (var item in query)
                {
                    if (item.EditionID == null)
                        res = false;
                    else
                        res = true;
                }
                return res;
            }
        }

        /// <summary>
        /// This method gets bool value of Subtopics with Subtopicid,editionid,threadid
        /// </summary>
        /// <param name="editionid"></param>
        /// <param name="threadid"></param>
        /// <param name="subtopicid"></param>
        /// <returns>returns bool value of Subtopics</returns>
        public static bool CreateSubTopicReference(int editionid, int threadid, int subtopicid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                SubTopicReference stref = new SubTopicReference();
                stref.EditionID = editionid;
                stref.ThreadID = threadid;
                stref.SubTopicID = subtopicid;
                entity.SubTopicReferences.Add(stref);
                entity.SaveChanges();
                return true;
            }
        }

        public static bool CreateSubTopicEditorRef(int editionid, int threadid, int commentid, int editortopicid, int Seniority)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                SubTopicEditorRef stedref = new SubTopicEditorRef();
                stedref.EditionID = editionid;
                stedref.ThreadID = threadid;
                stedref.EditorID = commentid;
                stedref.TopicID = editortopicid;
                stedref.Seniority = Seniority;
                entity.SubTopicEditorRefs.Add(stedref);
                entity.SaveChanges();
                return true;
            }
        }

        public static List<TopicModels> GetAuthors(int SubTopicid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var queruy = (from CommentAuthorss in entity.CommentAuthors
                              join EditorTopicss in entity.EditorTopics on CommentAuthorss.id equals EditorTopicss.EditorID
                              join SubTopicss in entity.SubTopics on EditorTopicss.TopicID equals SubTopicss.TopicID
                              where
                                SubTopicss.SubTopicID == SubTopicid &&
                                EditorTopicss.RetireDate == null
                              orderby
                                EditorTopicss.StartDate
                              select new TopicModels
                              {
                                  CommenAuthorId = CommentAuthorss.id,
                                  TopicID = EditorTopicss.TopicID
                              }).ToList();
                return queruy;
            }
        }

        /// <summary>
        /// This method returns editorialthreads with Threadid
        /// </summary>
        /// <param name="threadid">Passing Threadid to Get Thread list</param>
        /// <returns></returns>
        public static int Getexistingthread(int threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int query = (from m in entity.EditorialThreads where m.ThreadID == threadid select m.ThreadID).FirstOrDefault();
                return query;
            }
        }

        /// <summary>
        /// Delete Subtopic from Subtopics, Subtopiceditorref,Subtopicreferences Tables with editionid & Threadid,subtopicid
        /// </summary>
        /// <param name="Editionid">Passing Editionid</param>
        /// <param name="Threadid">Passing Threadid</param>
        /// <param name="SubTopicid">Passing SubTopicid</param>
        /// <returns>returns bool value of Deleted subtopic</returns>
        public static bool DeleteSubTopicContent(int Editionid, int Threadid, int SubTopicid, MVC4Grid.Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var checklist = GetThreadContent(Threadid, Editionid, Filter);
                if (checklist.Count < 2)
                {
                    return false;
                }

                else
                {
                    int topicid = (from m in entity.SubTopics where m.SubTopicID == SubTopicid select m.TopicID).First();

                    var querySubTopicEditorRefs = from SubTopicEditorRefs in entity.SubTopicEditorRefs where SubTopicEditorRefs.EditionID == Editionid && SubTopicEditorRefs.ThreadID == Threadid && SubTopicEditorRefs.TopicID == topicid select SubTopicEditorRefs;
                    foreach (var del in querySubTopicEditorRefs)
                    {
                        entity.SubTopicEditorRefs.Remove(del);
                    }
                    entity.SaveChanges();

                    var querySubTopicReferences = from SubTopicReferences in entity.SubTopicReferences where SubTopicReferences.EditionID == Editionid && SubTopicReferences.ThreadID == Threadid && SubTopicReferences.SubTopicID == SubTopicid select SubTopicReferences;
                    foreach (var del in querySubTopicReferences)
                    {
                        entity.SubTopicReferences.Remove(del);
                    }
                    entity.SaveChanges();

                    return true;
                }
            }
        }

        /// <summary>
        /// This method returns Article details with Threadid
        /// </summary>
        /// <param name="threadid">Passing Threadid</param>
        /// <returns>returns int value of article</returns>
        public static int Getarticle(int threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int query = (from m in entity.ArticleSelections
                             where
                               m.ThreadID == threadid
                             orderby
                               m.SortOrder
                             select m.ThreadID).FirstOrDefault();
                return query;
            }
        }

        /// <summary>
        /// This method returns bool value of New CreatedArticle with ArticleSelection
        /// </summary>
        /// <param name="article">ArticleSelection</param>
        /// <returns></returns>
        public static bool CreateArticle(ArticleSelection article)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var res = entity.ArticleSelections.Where(i => i.PMID == article.PMID && i.ThreadID == article.ThreadID).FirstOrDefault();
                //   var res = entity.ArticleSelections.FirstOrDefault(i => i.PMID == pmid);
                if (res != null)
                    return false;
                else
                {
                    ArticleSelection artclselction = new ArticleSelection();
                    // int order = (from m in entity.ArticleSelections where m.ThreadID == article.ThreadID select entity.ArticleSelections.Max(x => (int)x.SortOrder)).FirstOrDefault();
                    int? order = (from m in entity.ArticleSelections where m.ThreadID == article.ThreadID select m.SortOrder).DefaultIfEmpty(0).Max();
                    if (order == null || order == 0)
                        order = 1;
                    else
                        order = order + 1;
                    artclselction.ThreadID = article.ThreadID;
                    artclselction.PMID = article.PMID;
                    artclselction.SortOrder = order;
                    entity.ArticleSelections.Add(artclselction);
                    entity.SaveChanges();
                    return true;
                }
            }
        }

        /// <summary>
        /// This method returns bool value of deleted Articleselection with threadid, pmid
        /// </summary>
        /// <param name="Threadid">Passing Threadid</param>
        /// <param name="pmid">Passing Pmid</param>
        /// <returns>returns bool value of deleted Articleselection</returns>
        public static bool DeleteArticle(int Threadid, int pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var queryarticles = (from m in entity.ArticleSelections where m.ThreadID == Threadid && m.PMID == pmid select m).ToList();
                foreach (var del in queryarticles)
                {
                    entity.ArticleSelections.Remove(del);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        /// <summary>
        /// This method returns Json with bool of Crated EditorialComment with EditorialCommentsModel & Threadid
        /// </summary>
        /// <param name="comentdetails"></param>
        /// <param name="Threadid">Passing Threadid</param>
        /// <returns>returns Json with bool of Created EditorialComment</returns>
        public static bool CreateEditorialComment(EditorialCommentsModel comentdetails, int Threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (comentdetails != null)
                {
                    EditorialComment details = new EditorialComment();
                    details.ThreadID = Threadid;
                    details.Comment = comentdetails.Comment;
                    details.SortOrder = null;
                    entity.EditorialComments.Add(details);
                    entity.SaveChanges();
                    int id = details.CommentID;
                    CommentAuthor cm = new CommentAuthor();
                    if (comentdetails.NewAuthorValues != null)
                    {
                        foreach (var item in comentdetails.NewAuthorValues)
                        {
                            cm = entity.CommentAuthors.Where(c => c.id == item.AuthorID).FirstOrDefault();
                            details.CommentAuthors.Add(cm);
                        }
                    }

                    Gene ge = new Gene();
                    if (comentdetails.NewGeneValues != null)
                    {
                        foreach (var data in comentdetails.NewGeneValues)
                        {
                            ge = entity.Genes.Where(m => m.GeneID == data.GeneId).FirstOrDefault();
                            details.Genes.Add(ge);
                        }
                    }
                    entity.SaveChanges();
                    return true;
                }
                else { return false; }
            }
        }

        /// <summary>
        ///  This method returns Json with bool of Updated EditorialComment with EditorialCommentsModel & Threadid
        /// </summary>
        /// <param name="comentdetails">EditorialCommentsModel</param>
        /// <param name="Threadid">Threadid</param>
        /// <returns>returns Json with bool of Updated EditorialComment</returns>
        public static bool UpdateEditorialComments(EditorialCommentsModel comentdetails, int Threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (comentdetails != null)
                {
                    EditorialComment comnt = (from s in entity.EditorialComments
                                              where s.CommentID == comentdetails.CommentID
                                              select s).FirstOrDefault<EditorialComment>();
                    ///delete
                    List<CommentAuthor> cours = comnt.CommentAuthors.ToList<CommentAuthor>();
                    foreach (var item in cours)
                    {
                        comnt.CommentAuthors.Remove(item);
                        entity.SaveChanges();
                    }

                    List<Gene> genes = comnt.Genes.ToList<Gene>();
                    foreach (var data in genes)
                    {
                        comnt.Genes.Remove(data);
                        entity.SaveChanges();
                    }
                    ///insert 
                    CommentAuthor cm = new CommentAuthor();
                    if (comentdetails.NewAuthorValues != null)
                    {
                        foreach (var item in comentdetails.NewAuthorValues)
                        {
                            cm = entity.CommentAuthors.Where(c => c.id == item.AuthorID).FirstOrDefault();
                            comnt.CommentAuthors.Add(cm);
                        }
                    }
                    Gene ge = new Gene();
                    if (comentdetails.NewGeneValues != null)
                    {
                        foreach (var data in comentdetails.NewGeneValues)
                        {
                            ge = entity.Genes.Where(m => m.GeneID == data.GeneId).FirstOrDefault();
                            comnt.Genes.Add(ge);
                        }
                    }
                    comnt.Comment = comentdetails.Comment;
                    entity.SaveChanges();
                    return true;
                }
                else { return false; }
            }
        }

        /// <summary>
        /// This method returns bool value of Deleted EditorialComment with commentid
        /// </summary>
        /// <param name="commentid">Passing Commentid</param>
        /// <returns>returns bool value of Deleted EditorialComment</returns>
        public static bool DeleteEditorialComment(int commentid)
        {

            using (EditorsEntities entity = new EditorsEntities())
            {
                if (commentid != 0)
                {
                    EditorialComment comnt = (from s in entity.EditorialComments
                                              where s.CommentID == commentid
                                              select s).FirstOrDefault<EditorialComment>();

                    List<CommentAuthor> cours = comnt.CommentAuthors.ToList<CommentAuthor>();
                    foreach (var item in cours)
                    {
                        comnt.CommentAuthors.Remove(item);
                        entity.SaveChanges();
                    }

                    List<Gene> genes = comnt.Genes.ToList<Gene>();
                    foreach (var data in genes)
                    {
                        comnt.Genes.Remove(data);
                        entity.SaveChanges();
                    }

                    entity.EditorialComments.Remove(comnt);
                    entity.SaveChanges();
                    return true;
                }
                else { return false; }
            }
        }
        #endregion

        #region EditorsMonthlychoiceMail
        /// <summary>
        /// This method returns listitem values of Recent Editions based on selected  Editors Choice Edition
        /// </summary>
        /// <returns></returns>
        public static List<SelectListItem> GetRecentEditions()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from vRE in entity.vwRecentEditions.AsEnumerable() select new SelectListItem { Value = vRE.EditionID.ToString(), Text = vRE.Edition_Name }).ToList();
                return query;
            }

        }

        /// <summary>
        ///  This method returns listitem values of Heading Templates 
        /// </summary>
        /// <returns></returns>
        public static List<SelectListItem> GetHeadingTemps()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from cmh in entity.CustomMailHeaders.AsEnumerable() select new SelectListItem { Value = cmh.Order.ToString(), Text = cmh.Description }).ToList();
                return query;
            }
        }

        /// <summary>
        /// This method returns Monthlyeditorsmail class object data with editionid
        /// </summary>
        /// <param name="editionid">Passing Editionid</param>
        /// <returns></returns>
        public static List<Monthlyeditorsmail> GetEcmailedition(int editionid)
        {
            List<Monthlyeditorsmail> maileditions = new List<Monthlyeditorsmail>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = entity.adm_GetECMailingByEdition(editionid).ToList();
                foreach (var item in query)
                {
                    Monthlyeditorsmail content = new Monthlyeditorsmail();
                    content.pmid = item.pmid;
                    content.OrgFolderName = item.OrgFolderName;
                    content.ThreadID = item.ThreadID;
                    maileditions.Add(content);
                }
                return maileditions;
            }
        }

        /// <summary>
        /// This method returns Monthlyeditorsmail class object data
        /// </summary>
        /// <param name="EId">Passing Editionid</param>
        /// <returns></returns>
        public static Monthlyeditorsmail GetmailEditions(int? EId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                Monthlyeditorsmail obj = new Monthlyeditorsmail();

                obj = (from e in entity.Editions
                       join s in entity.Specialties on e.SpecialtyID equals s.SpecialtyID
                       where e.EditionID == EId
                       select new Monthlyeditorsmail
                       {
                           SpecialtyID = e.SpecialtyID,
                           PubDate = e.PubDate,
                           SpecialtyName = s.SpecialtyName
                       }).FirstOrDefault();

                return obj;
            }
        }

        /// <summary>
        /// This method returns String value of ArticleTitle from IWide with pmid
        /// </summary>
        /// <param name="pmid">Passing Pmid</param>
        /// <returns></returns>
        public static string Getarticlemail(int pmid)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                var query = (from iw in entity.iWides where iw.PMID == pmid select iw.ArticleTitle).FirstOrDefault();
                return query;
            }
        }

        /// <summary>
        /// This method returns list of Usermailsdetails class object with specialtyid
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static List<Usermailsdetails> GetEmaildetails(int id)
        {
            List<Usermailsdetails> editormail = new List<Usermailsdetails>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                List<Usermailsdetails> gmdetails = (from u in entity.AJA_tbl_Users.AsEnumerable()
                                                    where u.specialtyID == id && u.IseditorEmaiSend == true && u.Activated == 1
                                                    select new Usermailsdetails
                                                      {
                                                          id = u.UserID,
                                                          Name = (u.Lname + ", " + u.Fname),
                                                          FirstName = u.Fname,
                                                          LastName = u.Lname,
                                                          emailwithname = u.Lname + " " + u.Fname + "(" + u.EmailID + ")",
                                                          email = u.EmailID,
                                                          InSpecialty = Convert.ToInt32(
                                                            (from us in entity.AJA_tbl_Users
                                                             where
                                                               us.UserID == u.UserID &&
                                                               us.specialtyID == id
                                                             select us
                                                              ).Count()),
                                                          IsSendmail = u.IseditorEmaiSend
                                                      }).ToList();

                editormail.AddRange(gmdetails);
            }
            return editormail;
        }

        public static Usermailsdetails GetPrevRecipientsEmails(int? id, int? userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                Usermailsdetails gmdetails = (from u in entity.AJA_tbl_Users.AsEnumerable()
                                              where u.specialtyID == id && u.UserID == userid && u.Activated == 1
                                              select new Usermailsdetails
                                              {
                                                  id = u.UserID,
                                                  Name = (u.Lname + ", " + u.Fname),
                                                  FirstName = u.Fname,
                                                  LastName = u.Lname,
                                                  emailwithname = u.Lname + " " + u.Fname + "(" + u.EmailID + ")",
                                                  email = u.EmailID,
                                                  InSpecialty = Convert.ToInt32(
                                                    (from us in entity.AJA_tbl_Users
                                                     where
                                                       us.UserID == u.UserID &&
                                                       us.specialtyID == id
                                                     select us
                                                      ).Count()),
                                                  IsSendmail = u.IseditorEmaiSend
                                              }).FirstOrDefault();

                return gmdetails;
            }
        }

        /// <summary>
        /// This method returns Usermailsdetails class object data of Users with Userid
        /// </summary>
        /// <param name="userid"></param>
        /// <returns></returns>
        public static Usermailsdetails Getuseremails(int userid)
        {
            //  List<Usermailsdetails> editormail = new List<Usermailsdetails>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                Usermailsdetails gmdetails = ((from u in entity.AJA_tbl_Users.AsEnumerable()
                                               where u.UserID == userid
                                               select new Usermailsdetails
                                               {
                                                   email = u.EmailID,
                                                   Name = (u.Fname + " " + u.Lname)
                                               }).FirstOrDefault());
                return gmdetails;
            }

        }

        public static Grid.GridResult GetUsersentmaildetials(Monthlyeditorsmail editorsmails, Grid.GridFilter filter)
        {
            List<Usermailsdetails> Allmailslist = new List<Usermailsdetails>();
            Grid.GridResult GridResult = new Grid.GridResult();
            if (editorsmails != null)
            {
                if (editorsmails.Usersentmails != null)
                {
                    foreach (var item in editorsmails.Usersentmails)
                    {
                        if (string.IsNullOrEmpty(item.Status))
                        {
                            item.Status = "Failure Sending Mail";
                        }
                    }
                }

                GridResult.Count = editorsmails.Usersentmails.Count();
                GridResult.DataSource = (editorsmails.Usersentmails.AsQueryable<Usermailsdetails>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);
                if (!string.IsNullOrEmpty(filter.SearchText))
                    GridResult.Count = (editorsmails.Usersentmails.AsQueryable<Usermailsdetails>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip).Count();
            }
            else
            {
                Monthlyeditorsmail editors = new Monthlyeditorsmail();
                List<Usermailsdetails> List = new List<Usermailsdetails>();
                Usermailsdetails obj = new Usermailsdetails();
                obj.email = " "; obj.FirstName = " "; obj.Status = " "; obj.id = 0;
                List.Add(obj);
                editors.Usersentmails = List;
                GridResult.Count = editors.Usersentmails.Count();
                GridResult.DataSource = (editors.Usersentmails.AsQueryable<Usermailsdetails>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);

            }
            return GridResult;
        }

        /// <summary>
        /// This method returns Ienumerable listitem values of Specialties which are not related to selected specialty based on Editors Choice Edition 
        /// </summary>
        /// <param name="id">Passing Specialtyid</param>
        /// <returns></returns>
        public static IEnumerable<SelectListItem> Getotherspecalities(int id)
        {
            // List<Userotherspeacialtymails> editormail = new List<Userotherspeacialtymails>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var gmdetails = ((from u in entity.AJA_tbl_Users.AsEnumerable().Where(x => x.specialtyID == id && x.IseditorEmaiSend == false && x.Activated == 1)
                                  select new SelectListItem
                                  {
                                      Value = u.Lname + " " + u.Fname + "(" + u.EmailID + ")",
                                      Text = u.Lname + " " + u.Fname + "(" + u.EmailID + ")"
                                  }).ToList());
                //editormail.AddRange(gmdetails);
                return gmdetails;
            }

        }

        /// <summary>
        /// This method returns Recent Editions with editionid
        /// </summary>
        /// <param name="id">Passing Editionid</param>
        /// <returns></returns>
        public static string GetRecentbasedEditions(int id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from vRE in entity.vwRecentEditions.AsEnumerable() where vRE.EditionID == id select vRE.Edition_Name).FirstOrDefault();
                return query;
            }

        }

        public static MonthlyeditorsPmids DisplayMailPMIDS(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                MonthlyeditorsPmids result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);
                result = entity.Database.SqlQuery<MonthlyeditorsPmids>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();
                return result;
            }
        }


        /// <summary>
        /// To get Article Title from Non Medlinecitations with Pmid
        /// </summary>
        /// <param name="Pmid"></param>
        /// <returns></returns>
        public static NonMedlineCitation GetNonmedlineArticleTitle(int Pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getarticle = (from nm in entity.NonMedlineCitations.Where(i => i.PMID == Pmid) select nm).FirstOrDefault();
                return getarticle;
            }
        }

        #endregion

        #region personalized medicine Test
        /// <summary>
        /// Gets Test details in SelectListItem
        /// </summary>
        /// <returns>returns SelectListItem of Test</returns>
        public static List<SelectListItem> GetTestNames(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test = (from t in entity.Tests.AsEnumerable().OrderBy(k => k.Name) select new SelectListItem { Value = t.TestID.ToString(), Text = t.Name, Selected = (t.TestID == id) }).ToList();
                return test;
            }

        }


        public static string GeneTestFullname(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var testname = (from g in entity.Tests.Where(i => i.TestID == id) select g.Name).FirstOrDefault();
                return testname;
            }
        }

        /// <summary>
        /// To get Name & Summary of Particular Gene Test with Testid
        /// </summary>
        /// <param name="testid">Passing Testid</param>
        /// <returns></returns>
        public static List<TestGene> GetGeneTestsList(int? testid)
        {
            List<TestGene> tests = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<TestGene> testsobj = (from t in entity.Tests
                                           where t.TestID == testid
                                           select new TestGene
                                           {
                                               TestID = t.TestID,
                                               Name = t.Name,
                                               Summary = t.Summary
                                           }).ToList();
                tests.AddRange(testsobj);

            }
            return tests;
        }

        public static TestGene GetGeneTests(int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                TestGene testsobj = (from t in entity.Tests
                                     where t.TestID == testid
                                     select new TestGene
                                     {
                                         TestID = t.TestID,
                                         TestName = t.Name,
                                         Summary = t.Summary
                                     }).FirstOrDefault();
                return testsobj;
            }
        }


        public static List<TestGene> GetAttachedGenestoTest(int? testid)
        {
            var attchgenes = new List<TestGene>();

            using (EditorsEntities entity = new EditorsEntities())
            {
                var getlist = new List<TestGene>();
                var getgeneid = entity.lib_GetGenesForTestByTestID(testid).ToList();

                foreach (var data in getgeneid)
                {
                    var attchedtestgenes = new TestGene();
                    attchedtestgenes.Attachedgene = data.Name;
                    attchedtestgenes.GeneId = Convert.ToInt32(data.GeneID);
                    getlist.Add(attchedtestgenes);
                    attchgenes = getlist;
                }
                return attchgenes;
            }

        }

        public static bool unlink_gene_from_test(int? testid, int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testid != null && geneid != null)
                {
                    entity.adm_UnlinkGeneFromTest(testid, geneid);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }



        /// <summary>
        /// This method Gets Name,summary of Test with Testid
        /// </summary>
        /// <param name="Testid">Passing Testid</param>
        /// <returns></returns>
        public static TestGene GetTestdetails(int? Testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                TestGene testgeneobj = (from t in entity.Tests
                                        where t.TestID == Testid
                                        select new TestGene
                                        {
                                            TestID = t.TestID,
                                            Name = t.Name,
                                            Summary = t.Summary
                                        }).FirstOrDefault();

                return testgeneobj;
            }
        }

        /// <summary>
        /// This method updates Test details
        /// </summary>
        /// <param name="test">Passing TestGene object parameters from UpdateTestgene method</param>
        /// <returns></returns>
        public static Test UpdateTestgene(TestGene test)
        {
            var testdetals = new Test();
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (test.TestID != 0)
                {
                    var querytestgene = (from t in entity.Tests
                                         where t.TestID == test.TestID
                                         select t).FirstOrDefault();
                    querytestgene.Name = test.TestName;
                    if (!string.IsNullOrEmpty(test.Summary))
                        querytestgene.Summary = test.Summary;
                    else
                        querytestgene.Summary = string.Empty;
                    entity.SaveChanges();
                    return querytestgene;
                }
                return testdetals;
            }
        }

        /// <summary>
        /// Gets Gene details in SelectListItem
        /// </summary>
        /// <returns>returns SelectListItem of GENE</returns>
        public static List<SelectListItem> GetTestGenes()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var genes = (from gn in entity.Genes.AsEnumerable().OrderBy(k => k.Name) where gn.Name != "" select new SelectListItem { Value = gn.GeneID.ToString(), Text = gn.Name }).Distinct().ToList();
                return genes;
            }

        }

        public static bool AttachGenetoTest(int? Testid, int? Geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                bool checktest = false;
                if (Testid != null)
                {
                    entity.adm_AttachGeneToTest(Testid, Geneid);
                    entity.SaveChanges();
                    checktest = true;
                    return checktest;
                }
                return checktest;
            }
        }

        public static bool AddNewTest(string NewTest)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (!string.IsNullOrEmpty(NewTest))
                {
                    var gettestname = entity.Tests.FirstOrDefault(x => x.Name == NewTest);
                    if (gettestname != null)
                    {
                        return false;
                    }

                    else
                    {
                        int gettestid = (from t in entity.Tests select t.TestID).DefaultIfEmpty(0).Max();
                        gettestid = gettestid + 1;
                        var Testdetails = new Test
                        {
                            TestID = gettestid,
                            Name = NewTest,
                            Summary = "",
                        };
                        entity.Tests.Add(Testdetails);
                        entity.SaveChanges();
                        return true;
                    }
                }
                return false;
            }
        }

        public static Grid.GridResult Get_Test_Comments(int? testid, Grid.GridFilter filter)
        {
            List<TestGene> coments = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var testcomments = entity.TestComments.Where(i => i.TestID == testid).ToList();
                foreach (var data in testcomments)
                {
                    var testcmnt = new TestGene()
                    {
                        TestID = Convert.ToInt32(testid),
                        Authorid = data.id,
                        commentid = data.CommentID,
                        testComment = data.Comment,
                        testcomnt_date = data.CommentDate,
                    };
                    coments.Add(testcmnt);
                }
                Grid.GridResult GridResult = new Grid.GridResult();
                GridResult.Count = coments.Count;
                GridResult.DataSource = (coments.AsQueryable<TestGene>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);
                return GridResult;
            }

        }

        public static bool AddComments_Test(TestGene testmodel, int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testmodel != null)
                {
                    int maxid = (from tc in entity.TestComments where tc.TestID == testid select tc.CommentID).DefaultIfEmpty(0).Max();
                    maxid = maxid + 1;
                    var test_comment = new TestComment()
                    {
                        Comment = testmodel.testComment,
                        TestID = Convert.ToInt32(testid),
                        id = testmodel.Authorid,
                        CommentID = maxid,
                        CommentDate = testmodel.testcomnt_date
                    };
                    entity.TestComments.Add(test_comment);
                    entity.SaveChanges();

                    if (testmodel.NewTestComments != null)
                    {
                        foreach (var item in testmodel.NewTestComments)
                        {
                            var testcommentcombo = new TestCommentCombo()
                            {
                                CommentID = maxid,
                                TestID = Convert.ToInt32(testid),
                                id = testmodel.Authorid,
                                SpecialtyID = item.SpecialtyId,
                                TopicID = item.Topicid,
                                SubTopicID = item.SubTopicid
                            };
                            entity.TestCommentCombos.Add(testcommentcombo);
                            entity.SaveChanges();
                        }
                    }

                    return true;
                }
                return false;
            }
        }

        public static bool UpdateTestComments(TestGene testmodel, int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testmodel != null)
                {
                    var getcombodetails = entity.TestCommentCombos.Where(i => i.TestID == testid && i.CommentID == testmodel.commentid).ToList();
                    foreach (var rem in getcombodetails)
                    {
                        entity.TestCommentCombos.Remove(rem);
                        entity.SaveChanges();
                    }

                    var querytestcomnts = (from tc in entity.TestComments where tc.TestID == testid && tc.CommentID == testmodel.commentid select tc).ToList();
                    foreach (var rem in querytestcomnts)
                    {
                        entity.TestComments.Remove(rem);
                        entity.SaveChanges();
                    }

                    var test_comment = new TestComment()
                    {
                        Comment = testmodel.testComment != null ? testmodel.testComment : null,
                        TestID = Convert.ToInt32(testid),
                        id = testmodel.Authorid,
                        CommentID = testmodel.commentid,
                        CommentDate = testmodel.testcomnt_date
                    };
                    entity.TestComments.Add(test_comment);
                    entity.SaveChanges();

                    if (testmodel.NewTestComments != null)
                    {
                        foreach (var item in testmodel.NewTestComments)
                        {

                            var testcommentcombo = new TestCommentCombo()
                            {
                                CommentID = testmodel.commentid,
                                TestID = Convert.ToInt32(testid),
                                id = testmodel.Authorid,
                                SpecialtyID = item.SpecialtyId,
                                TopicID = item.Topicid,
                                SubTopicID = item.SubTopicid
                            };
                            entity.TestCommentCombos.Add(testcommentcombo);
                            entity.SaveChanges();
                        }
                    }
                    return true;
                }
                return false;
            }
        }

        public static TestGene EditTestComentdetails(int? cmid, int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var model = new TestGene();
                model = (from m in entity.TestComments.AsEnumerable().Where(i => i.CommentID == cmid && i.TestID == testid) select new TestGene { commentid = m.CommentID, testComment = m.Comment, TestID = m.TestID, testcomnt_date = m.CommentDate, Authorid = m.id }).FirstOrDefault();
                return model;
            }
        }

        public static List<TestGene> GetTestComments(int? testid, int? Commentid)
        {
            var Testcomments = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var genecmnt = new TestGene();
                var test_comment_combo = (from tcc in entity.TestCommentCombos.AsEnumerable() where tcc.TestID == testid && tcc.CommentID == Commentid select tcc).ToList();
                var testdetails = new List<TestGene>();
                foreach (var item in test_comment_combo)
                {
                    var testcomentcombos = new TestGene();

                    testcomentcombos.Specialtyid = item.SpecialtyID;
                    testcomentcombos.SpecialtyName = (from p in entity.Specialties.AsEnumerable()
                                                      where p.isInUse == true && p.SpecialtyID == item.SpecialtyID
                                                      select p.SpecialtyName
                                ).FirstOrDefault();
                    testcomentcombos.Topicid = item.TopicID;
                    testcomentcombos.Topicname = (from Tpics in entity.Topics.AsEnumerable()
                                                  where Tpics.Type == 1 && Tpics.TopicID == item.TopicID
                                                  select Tpics.TopicName).FirstOrDefault();
                    testcomentcombos.SubTopicid = item.SubTopicID;
                    testcomentcombos.Subtopicname = (from SubTpics in entity.SubTopics.AsEnumerable()
                                                     where SubTpics.Type == 1 && SubTpics.SubTopicID == item.SubTopicID
                                                     select SubTpics.SubTopicName).FirstOrDefault();
                    testdetails.Add(testcomentcombos);
                    Testcomments = testdetails;
                }

            }
            return Testcomments;
        }

        public static bool DeleteTestCommentwithId(int? testid, int? comentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var querytestcombo = (from tcmb in entity.TestCommentCombos where tcmb.TestID == testid && tcmb.CommentID == comentid select tcmb).ToList();
                foreach (var rem in querytestcombo)
                {
                    entity.TestCommentCombos.Remove(rem);
                    entity.SaveChanges();
                }

                var querytestcomnt = (from testcoment in entity.TestComments where testcoment.TestID == testid && testcoment.CommentID == comentid select testcoment).ToList();
                foreach (var del in querytestcomnt)
                {
                    entity.TestComments.Remove(del);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        public static bool CheckTest_citations(int? testid, int? pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gettest = (from ct in entity.CitationsTests.AsEnumerable() where ct.TestID == testid && ct.PMID == pmid select ct).FirstOrDefault();
                if (gettest != null)
                {
                    return false;
                }
                else { return true; }
            }
        }

        public static TestGene DisplayTestPMIDS(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                TestGene result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);
                result = entity.Database.SqlQuery<TestGene>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();
                return result;
            }
        }

        public static bool InsertTestCitations(int userid, int? testid, int? pmid)
        {
            //string gene_cit;
            using (EditorsEntities entity = new EditorsEntities())
            {
                var ciatationstest = new CitationsTest()
                {
                    TestID = Convert.ToInt32(testid),
                    PMID = Convert.ToInt32(pmid)
                };
                entity.CitationsTests.Add(ciatationstest);
                entity.SaveChanges();
                return true;
            }

        }

        public static List<TestGene> GetTestCitations(int? userid, int? testid)
        {
            var test_citlist = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var test_citations = (from ct in entity.CitationsTests.AsEnumerable() where ct.TestID == testid select ct.PMID).ToList();
                if (test_citations != null)
                {
                    foreach (var data in test_citations)
                    {
                        if (data != 0)
                        {
                            TestGene test = DisplayTestPMIDS(Convert.ToInt32(userid), data.ToString(), 2, 1);
                            test.Displaydate = !string.IsNullOrEmpty(test.Displaydate) ? test.Displaydate.Substring(0, 4) : null;
                            test.Pmid = Convert.ToInt32(data);
                            test_citlist.Add(test);
                            test.Test_citationslist = test_citlist;
                        }
                    }
                    return test_citlist;
                }
                return test_citlist;
            }

        }

        public static bool DeleteCitationTEST(int? testid, int? Pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var querygetcitations = (from citationtest in entity.CitationsTests where citationtest.TestID == testid && citationtest.PMID == Pmid select citationtest).ToList();
                foreach (var del in querygetcitations)
                {
                    entity.CitationsTests.Remove(del);
                    entity.SaveChanges();
                }
                return true;
            }
        }


        public static bool AddSelectedTestComment(TestGene Testmodel)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (Testmodel.TestID != 0)
                {
                    if (Testmodel.Getcheckedcomments != null)
                    {
                        int testid = Testmodel.TestID;
                        foreach (var data in Testmodel.Getcheckedcomments)
                        {
                            int comentid = Convert.ToInt32(data.Editorscommentid);
                            var testcomments = (from gettestcoments in entity.lib_GetTestEditorCommentsByTestID(Testmodel.TestID) select gettestcoments.CommentID).ToList();
                            if (testcomments.Count == 0)
                            {
                                entity.adm_AddEditorCommentToTest(testid, comentid);
                                entity.SaveChanges();

                            }
                            else
                            {
                                int result = testcomments.Find(item => item == comentid);
                                if (result == 0)
                                {
                                    entity.adm_AddEditorCommentToTest(testid, comentid);
                                    entity.SaveChanges();
                                }
                            }
                        }
                        return true;
                    }
                    return false;
                }
                return false;
            }
        }

        public static bool DeleteEditorTestComment(int? testid, int? Commentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testid != null && Commentid != null)
                {
                    entity.adm_DeleteEditorCommentFromTest(testid, Commentid);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }

        public static List<TestGene> GetAddedTestEditorComment(int? testid)
        {
            var Test = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Testcomments = entity.lib_GetTestEditorCommentsByTestID(testid).ToList();
                foreach (var data in Testcomments)
                {
                    var objeditorcomment = new TestGene()
                    {
                        Editorschoicecomment = data.Comment,
                        Editorscommentid = data.CommentID.ToString(),
                        Threadid = data.ThreadID,
                        TestID = Convert.ToInt32(testid),
                        Newpmid = GetTestpmids(data.ThreadID)
                    };
                    Test.Add(objeditorcomment);
                }
                return Test;
            }
        }

        public static int[] GetTestpmids(int? Threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getthreads = (from sa in entity.ArticleSelections where sa.ThreadID == Threadid select sa.PMID).ToArray();
                return getthreads;
            }
        }


        public static List<TestGene> GetTestPmidCitations(int? Userid, int? pmid)
        {
            var Test = new List<TestGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<TestGene> getgc = (from t1 in entity.EditorialComments.AsEnumerable()
                                        join t2 in entity.ArticleSelections on t1.ThreadID equals t2.ThreadID
                                        where
                                          t2.PMID == pmid
                                        select new TestGene
                                      {
                                          Editorscommentid = t1.CommentID.ToString(),
                                          Editorschoicecomment = t1.Comment,
                                          Threadid = t1.ThreadID,
                                          Pmid = t2.PMID
                                      }).ToList();
                Test.AddRange(getgc);
                return Test;
            }
        }

        public static bool AddTestScLink(int? testid, string Sclink, int? linkid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int checklink = (from link in entity.TestsLinks where link.TestID == testid && link.LinkID == linkid select link.LinkID).FirstOrDefault();
                if (checklink == 0)
                {
                    int LinkID = (from gl in entity.TestsLinks select gl.LinkID).DefaultIfEmpty(0).Max();
                    LinkID = LinkID + 1;
                    var tlink = new TestsLink()
                    {
                        LinkID = LinkID,
                        TestID = Convert.ToInt32(testid),
                        Link = Sclink
                    };
                    entity.TestsLinks.Add(tlink);
                    entity.SaveChanges();
                    return true;
                }
                else
                {
                    var getlink = (from l in entity.TestsLinks where l.LinkID == linkid select l).FirstOrDefault();
                    getlink.Link = Sclink;
                    getlink.LinkID = Convert.ToInt32(linkid);
                    getlink.TestID = Convert.ToInt32(testid);
                    entity.SaveChanges();
                    return true;
                }
            }

        }

        public static List<Sclink> GetTestlinkinfo(int? testid)
        {
            var linkdata = new List<Sclink>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var LinkID = (from gl in entity.TestsLinks where gl.TestID == testid select gl).ToList();
                foreach (var item in LinkID)
                {
                    Sclink linkinfo = new Sclink();
                    linkinfo.testid = Convert.ToInt32(item.TestID);
                    linkinfo.Linkid = item.LinkID;
                    linkinfo.sclink = item.Link;
                    linkdata.Add(linkinfo);
                }
                return linkdata;
            }
        }

        public static bool DeleteTestSclink(int? testid, int? Linkid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testid != null && Linkid != null)
                {
                    var querylink = (from link in entity.TestsLinks where link.TestID == testid && link.LinkID == Linkid select link).ToList();
                    foreach (var rem in querylink)
                    {
                        entity.TestsLinks.Remove(rem);
                        entity.SaveChanges();
                    }
                    return true;
                }
                return false;
            }
        }

        public static bool DeleteTestGene(int? testid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (testid != null)
                {
                    entity.adm_DeleteTestByTestID(testid);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }


        #endregion

        #region Personalized Medicine Gene
        ////// Personalized Gene 

        public static List<SelectListItem> GetGeneNames(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgenes = (from g in entity.Genes.AsEnumerable().OrderBy(k => k.Name) select new SelectListItem { Value = g.GeneID.ToString(), Text = g.Name, Selected = (g.GeneID == id) }).ToList();
                return getgenes;
            }

        }

        public static string Genename(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var genename = (from g in entity.Genes.Where(i => i.GeneID == id) select g.Name).FirstOrDefault();
                return genename;
            }
        }

        public static bool Addgene(int? gene, string Name, string fullname, string Symbol, string Aliases, string Summary)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgene = (from genealias in entity.Genes.AsEnumerable() where genealias.GeneID == Convert.ToInt64(gene) select genealias).FirstOrDefault();
                if (getgene != null)
                {
                    return false;
                }
                else
                {
                    Gene genedata = new Gene();
                    genedata.GeneID = Convert.ToInt64(gene);
                    genedata.Name = Name;
                    genedata.FullName = fullname;
                    genedata.Symbol = Symbol;
                    genedata.Summary = Summary;
                    entity.Genes.Add(genedata);
                    entity.SaveChanges();
                    long geneid = genedata.GeneID;
                    string[] aliasdata = Aliases.Split(',');
                    if (aliasdata != null)
                    {
                        int id = 1;
                        foreach (var data in aliasdata)
                        {
                            GeneAlias aliasgene = new GeneAlias();
                            aliasgene.AliasID = id;
                            aliasgene.AliasName = data;
                            aliasgene.GeneID = geneid;
                            entity.GeneAliases.Add(aliasgene);
                            entity.SaveChanges();
                            id++;
                        }
                    }
                    return true;
                }
            }
        }

        /// <summary>
        /// This method gets Userid,pmid from DisplayPMIDS StoredProcedure
        /// </summary>
        /// <param name="UserID"></param>
        /// <param name="PMIDList"></param>
        /// <param name="DisplayMode"></param>
        /// <param name="SearchSort"></param>
        /// <returns></returns>
        public static PersonalizedGene DisplayPMIDS(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                PersonalizedGene result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);
                result = entity.Database.SqlQuery<PersonalizedGene>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();
                return result;
            }
        }

        public static bool InsertGeneCitations(int userid, int? geneid, int? pmid)
        {
            //string gene_cit;
            using (EditorsEntities entity = new EditorsEntities())
            {
                CitationsGene genedata = new CitationsGene();
                genedata.GeneID = Convert.ToInt64(geneid);
                genedata.PMID = Convert.ToInt32(pmid);
                entity.CitationsGenes.Add(genedata);
                entity.SaveChanges();
                return true;
            }

        }

        public static List<PersonalizedGene> GetGeneCitations(int userid, int? geneid)
        {
            var gene_citlist = new List<PersonalizedGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gene_citations = (from cg in entity.CitationsGenes.AsEnumerable() where cg.GeneID == Convert.ToInt64(geneid) select cg.PMID).ToList();
                if (gene_citations != null)
                {
                    foreach (var data in gene_citations)
                    {
                        if (data != 0)
                        {
                            PersonalizedGene gene = DisplayPMIDS(Convert.ToInt32(userid), data.ToString(), 2, 1);
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


        public static bool CheckGene_citations(int? geneid, int? pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getgene = (from cg in entity.CitationsGenes.AsEnumerable() where cg.GeneID == Convert.ToInt64(geneid) && cg.PMID == pmid select cg).FirstOrDefault();
                if (getgene != null)
                {
                    return false;
                }
                else { return true; }
            }
        }

        public static List<SelectListItem> GetGene_Authors()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from CA in entity.CommentAuthors.AsEnumerable()
                             orderby
                              CA.name
                             select new SelectListItem
                             {
                                 Value = CA.id.ToString(),
                                 Text = CA.name,
                             }).Distinct(new SelectListItemComparer()).ToList();
                return query;

            }
        }

        public static List<SelectListItem> Get_Authors_Gene(int? authorid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from CA in entity.CommentAuthors.AsEnumerable()
                             orderby
                              CA.name
                             select new SelectListItem
                             {
                                 Value = CA.id.ToString(),
                                 Text = CA.name,
                                 Selected = (CA.id == authorid)
                             }).Distinct(new SelectListItemComparer()).ToList();
                return query;

            }
        }

        public static List<SelectListItem> GetGeneTopics(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from Tpics in entity.Topics.AsEnumerable()
                             where Tpics.Type == 1 && Tpics.SpecialtyID == id
                             orderby Tpics.TopicName
                             select new SelectListItem
                             {
                                 Value = Tpics.TopicID.ToString(),
                                 Text = Tpics.TopicName
                             }).ToList();
                return query;
            }
        }

        public class SelectListItemComparer : EqualityComparer<SelectListItem>
        {
            public override bool Equals(SelectListItem x, SelectListItem y)
            {
                return x.Value.Equals(y.Value);
            }

            public override int GetHashCode(SelectListItem obj)
            {
                return obj.Value.GetHashCode();
            }
        }


        public static bool AddComments_Gene(PersonalizedGene Genecit, int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (Genecit != null)
                {
                    int maxid = (from gc in entity.GeneComments where gc.GeneID == geneid select gc.CommentID).DefaultIfEmpty(0).Max();
                    maxid = maxid + 1;
                    GeneComment gene_comment = new GeneComment();
                    gene_comment.Comment = Genecit.geneComment;
                    gene_comment.GeneID = Convert.ToInt64(geneid);
                    gene_comment.id = Genecit.Authorid;
                    gene_comment.CommentID = maxid;
                    gene_comment.CommentDate = Genecit.genecomnt_date;
                    entity.GeneComments.Add(gene_comment);
                    entity.SaveChanges();


                    if (Genecit.NewGeneComments != null)
                    {
                        foreach (var item in Genecit.NewGeneComments)
                        {
                            GeneCommentCombo Commentcombo = new GeneCommentCombo();
                            Commentcombo.CommentID = maxid;
                            Commentcombo.GeneID = Convert.ToInt64(geneid);
                            Commentcombo.id = Genecit.Authorid;
                            Commentcombo.SpecialtyID = item.SpecialtyId;
                            Commentcombo.TopicID = item.Topicid;
                            Commentcombo.SubTopicID = item.SubTopicid;
                            entity.GeneCommentCombos.Add(Commentcombo);
                            entity.SaveChanges();
                        }
                    }

                    return true;
                }
                return false;
            }
        }

        public static Grid.GridResult Get_Gene_Comments(int? geneid, Grid.GridFilter filter)
        {
            List<PersonalizedGene> coments = new List<PersonalizedGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gene_comments = (from cg in entity.GeneComments.AsEnumerable() where cg.GeneID == Convert.ToInt64(geneid) select cg).ToList();
                foreach (var data in gene_comments)
                {
                    PersonalizedGene genecmnt = new PersonalizedGene();
                    genecmnt.GeneID = Convert.ToInt32(data.GeneID);
                    genecmnt.Authorid = data.id;
                    genecmnt.commentid = data.CommentID;
                    genecmnt.geneComment = data.Comment;
                    genecmnt.genecomnt_date = data.CommentDate;
                    coments.Add(genecmnt);
                }
                Grid.GridResult GridResult = new Grid.GridResult();
                GridResult.Count = coments.Count;
                GridResult.DataSource = (coments.AsQueryable<PersonalizedGene>()).Search(filter.SearchProps, filter.SearchText).OrderBy(filter.SortProp, !filter.isAscending).Take(filter.Take).Skip(filter.Skip);
                return GridResult;
            }

        }

        public static List<PersonalizedGene> GetGeneComments(int? geneid, int? Commentid)
        {
            var Genecomments = new List<PersonalizedGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var gene_comment_combo = (from gc in entity.GeneCommentCombos.AsEnumerable() where gc.GeneID == geneid && gc.CommentID == Commentid select gc).ToList();
                List<PersonalizedGene> genedetails = new List<PersonalizedGene>();
                foreach (var item in gene_comment_combo)
                {
                    var genecomentcombos = new PersonalizedGene();
                    genecomentcombos.Specialtyid = item.SpecialtyID;
                    genecomentcombos.SpecialtyName = (from p in entity.Specialties.AsEnumerable()
                                                      where p.isInUse == true && p.SpecialtyID == item.SpecialtyID
                                                      select p.SpecialtyName
                                ).FirstOrDefault();
                    genecomentcombos.Topicid = item.TopicID;
                    genecomentcombos.Topicname = (from Tpics in entity.Topics.AsEnumerable()
                                                  where Tpics.Type == 1 && Tpics.TopicID == item.TopicID
                                                  select Tpics.TopicName).FirstOrDefault();
                    genecomentcombos.SubTopicid = item.SubTopicID;
                    genecomentcombos.Subtopicname = (from SubTpics in entity.SubTopics.AsEnumerable()
                                                     where SubTpics.Type == 1 && SubTpics.SubTopicID == item.SubTopicID
                                                     select SubTpics.SubTopicName).FirstOrDefault();

                    genedetails.Add(genecomentcombos);
                    Genecomments = genedetails;
                }

            }
            return Genecomments;
        }

        public static PersonalizedGene EditGeneComentdetails(int? cmid, int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                PersonalizedGene model = new PersonalizedGene();
                model = (from m in entity.GeneComments.AsEnumerable().Where(i => i.CommentID == cmid && i.GeneID == geneid) select new PersonalizedGene { commentid = m.CommentID, geneComment = m.Comment, GeneID = Convert.ToInt32(m.GeneID), genecomnt_date = m.CommentDate, Authorid = m.id }).FirstOrDefault();
                return model;
            }
        }

        public static bool DeleteGeneCommentwithId(int? geneid, int? comentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var querygcombo = (from gcmb in entity.GeneCommentCombos where gcmb.GeneID == geneid && gcmb.CommentID == comentid select gcmb).ToList();
                foreach (var rem in querygcombo)
                {
                    entity.GeneCommentCombos.Remove(rem);
                    entity.SaveChanges();
                }

                var querygc = (from gc in entity.GeneComments where gc.GeneID == geneid && gc.CommentID == comentid select gc).ToList();
                foreach (var del in querygc)
                {
                    entity.GeneComments.Remove(del);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        public static bool UpdateGeneComments(PersonalizedGene Genecit, int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (Genecit != null)
                {
                    var updategenedet = new PersonalizedGene();
                    var querygcombo = (from gcmb in entity.GeneCommentCombos where gcmb.GeneID == geneid && gcmb.CommentID == Genecit.commentid select gcmb).ToList();
                    foreach (var rem in querygcombo)
                    {
                        entity.GeneCommentCombos.Remove(rem);
                        entity.SaveChanges();
                    }

                    var querygc = (from gc in entity.GeneComments where gc.GeneID == geneid && gc.CommentID == Genecit.commentid select gc).ToList();
                    foreach (var rem in querygc)
                    {
                        entity.GeneComments.Remove(rem);
                        entity.SaveChanges();
                    }

                    var gene_comment = new GeneComment();
                    gene_comment.Comment = Genecit.geneComment != null ? Genecit.geneComment : null;
                    gene_comment.GeneID = Convert.ToInt64(geneid);
                    gene_comment.id = Genecit.Authorid;
                    gene_comment.CommentID = Genecit.commentid;
                    gene_comment.CommentDate = Genecit.genecomnt_date;
                    entity.GeneComments.Add(gene_comment);
                    entity.SaveChanges();

                    if (Genecit.NewGeneComments != null)
                    {
                        foreach (var item in Genecit.NewGeneComments)
                        {
                            GeneCommentCombo Commentcombo = new GeneCommentCombo();
                            Commentcombo.CommentID = Genecit.commentid;
                            Commentcombo.GeneID = Convert.ToInt64(geneid);
                            Commentcombo.id = Genecit.Authorid;
                            Commentcombo.SpecialtyID = item.SpecialtyId;
                            Commentcombo.TopicID = item.Topicid;
                            Commentcombo.SubTopicID = item.SubTopicid;
                            entity.GeneCommentCombos.Add(Commentcombo);
                            entity.SaveChanges();
                        }
                    }
                    return true;
                }
                return false;
            }
        }

        public static List<PersonalizedGene> GetPmidCitations(int? Userid, int? pmid)
        {
            var Gene = new List<PersonalizedGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<PersonalizedGene> getgc = (from t1 in entity.EditorialComments.AsEnumerable()
                                                join t2 in entity.ArticleSelections on t1.ThreadID equals t2.ThreadID
                                                where
                                                  t2.PMID == pmid
                                                select new PersonalizedGene
                                                {
                                                    Editorscommentid = t1.CommentID.ToString(),
                                                    Editorschoicecomment = t1.Comment,
                                                    Threadid = t1.ThreadID,
                                                    Pmid = t2.PMID
                                                }).ToList();
                Gene.AddRange(getgc);
                return Gene;
            }
        }

        public static List<PersonalizedGene> GetAddedEditorComment(int? geneid)
        {
            var Gene = new List<PersonalizedGene>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Genecomments = entity.lib_GetGeneEditorCommentsByGeneID(geneid).ToList();
                foreach (var gecg in Genecomments)
                {
                    var objeditorcomment = new PersonalizedGene();
                    objeditorcomment.Editorschoicecomment = gecg.Comment;
                    objeditorcomment.Editorscommentid = gecg.CommentID.ToString();
                    objeditorcomment.Threadid = gecg.ThreadID;
                    objeditorcomment.GeneID = Convert.ToInt32(geneid);
                    objeditorcomment.Newpmid = EditorsBL.Getpmids(gecg.ThreadID);
                    Gene.Add(objeditorcomment);
                }
                return Gene;
            }
        }

        public static int[] Getpmids(int? Threadid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var getthreads = (from sa in entity.ArticleSelections where sa.ThreadID == Threadid select sa.PMID).ToArray();
                return getthreads;
            }
        }


        public static bool AddSelectedComment(PersonalizedGene Genecit)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (Genecit.GeneID != 0)
                {
                    if (Genecit.Getcheckedcomments != null)
                    {
                        int Geneid = Genecit.GeneID;
                        foreach (var data in Genecit.Getcheckedcomments)
                        {
                            int comentid = Convert.ToInt32(data.Editorscommentid);
                            var Genecomments = (from gecgid in entity.lib_GetGeneEditorCommentsByGeneID(Genecit.GeneID) select gecgid.CommentID).ToList();
                            if (Genecomments.Count == 0)
                            {
                                entity.adm_AddEditorCommentToGene(Geneid, comentid);
                                entity.SaveChanges();
                                // return true;
                            }
                            else
                            {
                                int result = Genecomments.Find(item => item == comentid);
                                if (result == 0)
                                {
                                    entity.adm_AddEditorCommentToGene(Geneid, comentid);
                                    entity.SaveChanges();
                                    // return true;
                                }
                            }
                        }
                        return true;
                    }
                    return false;
                }
                return false;
            }
        }

        public static bool DeleteEditorComment(int? geneid, int? Commentid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (geneid != null && Commentid != null)
                {
                    entity.adm_DeleteEditorCommentFromGene(geneid, Commentid);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }

        public static bool DeleteCitationGENE(int? geneid, int? Pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var querygetcitations = (from citationgene in entity.CitationsGenes where citationgene.GeneID == geneid && citationgene.PMID == Pmid select citationgene).ToList();
                foreach (var del in querygetcitations)
                {
                    entity.CitationsGenes.Remove(del);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        public static bool AddScLink(int? geneid, string Sclink, int? linkid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int checklink = (from link in entity.GenesLinks where link.GeneID == geneid && link.LinkID == linkid select link.LinkID).FirstOrDefault();
                if (checklink == 0)
                {
                    int LinkID = (from gl in entity.GenesLinks select gl.LinkID).DefaultIfEmpty(0).Max();
                    LinkID = LinkID + 1;
                    GenesLink glink = new GenesLink();
                    glink.LinkID = LinkID;
                    glink.GeneID = Convert.ToInt64(geneid);
                    glink.Link = Sclink;
                    entity.GenesLinks.Add(glink);
                    entity.SaveChanges();
                    return true;
                }
                else
                {
                    var getlink = (from l in entity.GenesLinks where l.LinkID == linkid select l).FirstOrDefault();
                    getlink.Link = Sclink;
                    getlink.LinkID = Convert.ToInt32(linkid);
                    getlink.GeneID = Convert.ToInt32(geneid);
                    entity.SaveChanges();
                    return true;
                }
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

        public static bool DeleteSclink(int? geneid, int? Linkid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (geneid != null && Linkid != null)
                {
                    var querylink = (from link in entity.GenesLinks where link.GeneID == geneid && link.LinkID == Linkid select link).ToList();
                    foreach (var rem in querylink)
                    {
                        entity.GenesLinks.Remove(rem);
                        entity.SaveChanges();
                    }
                    return true;
                }
                return false;
            }
        }

        public static bool DeleteGene(int? geneid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (geneid != null)
                {
                    entity.adm_DeleteGene(geneid);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }


        #endregion

        #region NonMedlineCitations
        [GridPaging(NoofRows = 10)]
        [GridSearching]
        [GridSorting]
        public class NonMedlineCitations
        {


            [Key]
            [Required]
            [GridSorting(Default = true)]
            [Remote("CheckPMIDExists", "Admin", ErrorMessage = "PMID already exists!")]
            public int PMID { get; set; }

            [Display(Name = "Article Title")]
            [DisplayFormat(HtmlEncode = true)]
            public string ArticleTitle { get; set; }

            [Display(Name = "Author List")]
            [HiddenInput]
            public string AuthorList { get; set; }

            [HiddenInput]
            public string Abstract { get; set; }

            [HiddenInput]
            [GridSearching(Searching = false)]
            [Display(Name = "Citation Date")]

            public DateTime? CitationDate { get; set; }
            [HiddenInput]
            [Display(Name = "Display Date")]
            [StringLength(250, ErrorMessage = "Max Length 250 characters")]
            public string DisplayDate { get; set; }
            [HiddenInput]
            [Display(Name = "Display Notes")]
            [StringLength(250, ErrorMessage = "Max Length 250 characters")]
            public string DisplayNotes { get; set; }
            [HiddenInput]
            [GridSearching(Searching = false)]
            [Display(Name = "Expire Date")]
            public DateTime? ExpireDate { get; set; }
            [HiddenInput]
            [Display(Name = "Keep Delete")]
            [StringLength(50, ErrorMessage = "Max Length 50 characters")]
            public string KeepDelete { get; set; }
            [HiddenInput]
            [Display(Name = "Medline Pgn")]
            [StringLength(500, ErrorMessage = "Max Length 500 characters")]
            public string MedlinePgn { get; set; }
            [HiddenInput]
            [Display(Name = "Medline TA")]
            [StringLength(500, ErrorMessage = "Max Length 500 characters")]
            public string MedlineTA { get; set; }
            [HiddenInput]
            [StringLength(100, ErrorMessage = "Max Length 100 characters")]
            public string Nickname { get; set; }
            [HiddenInput]
            [StringLength(100, ErrorMessage = "Max Length 100 characters")]
            public string SearchID { get; set; }
            [HiddenInput]
            [StringLength(100, ErrorMessage = "Max Length 100 characters")]
            public string Status { get; set; }
            [HiddenInput]
            [Display(Name = "Status Display")]
            [StringLength(100, ErrorMessage = "Max Length 100 characters")]
            public string StatusDisplay { get; set; }
            [HiddenInput]
            public int? dps { get; set; }
        }
        #endregion

        #region alltopics Manage Class
        /// <summary>
        /// This class is used to get all the topics and bindit to grid
        /// </summary>
        public class ManageTopicdet
        {
            public ManageTopicdet()
            {

            }
            public int? TopicID { get; set; }

            public string TopicName { get; set; }

            public int Type { get; set; }

            public int? SubTopicID { get; set; }
            public List<SelectListItem> SpecialityList { get; set; }
            public string SubTopicname { get; set; }
            public string SpecialityName { get; set; }
            public int? SpecialityID { get; set; }
            public DateTime CreatedDate { get; set; }
        }

        #endregion

        #region GetAllTopicEditorsDetails

        public static Grid.GridResult GetAllTopicEditorsDetails(Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var feildsobj = (from CA in entity.CommentAuthors
                                 where !(from Le in entity.AtLargeEditors
                                         select new
                                         {
                                             Le.EditorID
                                         }).Contains(new { EditorID = CA.id })
                                 orderby
                                   CA.name
                                 select new TopicEditorsModel
                                                    {
                                                        EditorID = CA.id,
                                                        name = CA.name,
                                                        email = CA.email,
                                                        affiliations = CA.affiliations
                                                    }).GridFilterBy(Filter);
                return feildsobj;
            }
        }
        #endregion

        #region GetAtlargeEditorsDetails

        public static Grid.GridResult GetAtlargeEditorsDetails(MVC4Grid.Grid.GridFilter Filter)
        {

            using (EditorsEntities entity = new EditorsEntities())
            {
                var feildsobj = (from t1 in entity.AtLargeEditors
                                 join t2 in entity.CommentAuthors on new { EditorID = t1.EditorID } equals new { EditorID = t2.id }
                                 join t3 in entity.Specialties on t1.SpecialtyID equals t3.SpecialtyID
                                 select new EditorsdetValues
                                 {
                                     EditorID = t1.EditorID,
                                     SpecialityID = (int?)t1.SpecialtyID,
                                     StartDate = t1.StartDate,
                                     RetireDate = t1.RetireDate,
                                     name = t2.name,
                                     SpecialtyName = t3.SpecialtyName,
                                     affiliations = t2.affiliations,
                                     email = t2.email
                                 }).GridFilterBy(Filter);
                return feildsobj;

            }

        }
        #endregion

        #region Topics/ Sub-Topics
        #region Get All topics and bind it to Grid
        /// <summary>
        /// This will return all the topic details and bind it to Grid, and passing speciality id in specialites table getting speciality name for the topic
        /// </summary>
        /// <returns></returns>
        public static List<ManageTopicdet> GetAllTopicDetails()
        {
            List<ManageTopicdet> Topic = new List<ManageTopicdet>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<ManageTopicdet> SpecialityTopic = (from Tps in entity.Topics
                                                        join t3 in entity.Specialties on Tps.SpecialtyID equals t3.SpecialtyID
                                                        where Tps.Type == 1
                                                        select new ManageTopicdet
                                                        {
                                                            TopicID = Tps.TopicID,
                                                            TopicName = Tps.TopicName,
                                                            SpecialityID = Tps.SpecialtyID,
                                                            SpecialityName = t3.SpecialtyName,
                                                        }).ToList();
                Topic.AddRange(SpecialityTopic);

            }

            return Topic;
        }

        #endregion

        #region Checking Existed Topic in DB for selected speciality in JSON
        /// <summary>
        /// Checking the topic name is existing or not  for selected speciality
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static bool CheckTopicExisted(ManageTopics obj)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var topic = (from tpc in entity.Topics where (tpc.TopicName == obj.TopicName && tpc.Type == 1 && tpc.SpecialtyID == obj.SpecialityID) select tpc).FirstOrDefault();
                if (topic == null)
                    return false;
                else if (topic.TopicID == obj.TopicID)
                    return false;
                else
                    return true;

            }
        }

        #endregion

        #region Get an object to load the partial view for creatig topic
        /// <summary>
        /// This method will  return new obj for partial view to load with dropdown specialities
        /// </summary>
        /// <returns></returns>
        public static ManageTopics GetAddTopicObject()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                ManageTopics topic = new ManageTopics();
                topic.TopicID = 0;
                topic.TopicName = "";
                topic.SpecialityList = GetSpecialitListInUse();
                return topic;
            }
        }
        #endregion

        #region Get Specialites Is In use
        /// <summary>
        /// This will return Specialities list who all are in use
        /// </summary>
        /// <returns></returns>
        public static List<SelectListItem> GetSpecialitListInUse()
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from p in entity.Specialties.AsEnumerable()
                             where p.isInUse == true
                             orderby p.SpecialtyName
                             select new SelectListItem
                             {
                                 Value = p.SpecialtyID.ToString(),
                                 Text = p.SpecialtyName
                             }).ToList();
                return query;
            }
        }

        #endregion

        #region Creating a Topic under speciality
        /// <summary>
        /// This will insert the new topic created by Admin in Topics Table where as type=1 for admin and type =2 for user .
        /// </summary>
        /// <param name="Topic"></param>
        public static bool InsertTopicByAdmin(ManageTopics Topic)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (Topic.TopicID == 0)
                {
                    var CreateTopic = new Topic
                    {
                        TopicName = Topic.TopicName,
                        createtime = DateTime.Now,
                        SpecialtyID = Topic.SpecialityID,
                        Type = 1,
                        UserID = 0
                    };
                    entity.Topics.Add(CreateTopic);
                }
                else
                {
                    #region UpdateSpeciality Topic

                    var EditedTopic = entity.Topics.Where(u => u.TopicID == Topic.TopicID).FirstOrDefault();

                    if (Topic.TopicName != null)
                    {
                        EditedTopic.TopicName = Topic.TopicName;
                    }
                    #endregion
                }

                entity.SaveChanges();
                return true;
            }

        }

        #endregion

        #region GetTopic With TopicID
        /// <summary>
        /// Get the Topic with topic ID for admin in edit Topic
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        public static ManageTopics GetTopictwithID(int ID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Topic2Edit = (from t in entity.Topics
                                  where t.TopicID == ID && t.Type == 1
                                  select new ManageTopics
                                      {
                                          TopicID = t.TopicID,
                                          TopicName = t.TopicName,
                                          SpecialityID = t.SpecialtyID,
                                      }).FirstOrDefault();
                return Topic2Edit;
            }
        }

        public static List<TopicDetValues> GetTopicsBySpecID(int? ID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var AllTopics = (from s in entity.Topics
                                 where s.SpecialtyID == ID && s.Type == 1
                                 orderby s.TopicName
                                 select new TopicDetValues
                                 {
                                     TopicID = s.TopicID,
                                     TopicName = s.TopicName,
                                     SpecialityID = s.SpecialtyID,
                                     Type = s.Type,
                                     CreatedDate = s.createtime,
                                 }).ToList();
                return AllTopics;
            }
        }
        #endregion

        #region Create Sub-Topic to a Topic
        /// <summary>
        /// This will save a new sub-topic with related topic ID
        /// </summary>
        /// <param name="SubTopicInsertion"></param>
        public static bool InsertSubTopicByAdmin(ManageTopics SubTopicInsertion)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if ((SubTopicInsertion.SubTopicID == 0 || SubTopicInsertion.SubTopicID == null) && SubTopicInsertion.TopicID != 0)
                {
                    var subtopic = new SubTopic
                    {
                        TopicID = SubTopicInsertion.TopicID,
                        SubTopicName = SubTopicInsertion.SubTopicname,
                        createtime = DateTime.Now,
                        Type = 1,
                        Priority = 0
                    };
                    entity.SubTopics.Add(subtopic);
                }
                else
                {
                    var EditedSubTopic = entity.SubTopics.Where(u => u.TopicID == SubTopicInsertion.TopicID && u.Type == 1).FirstOrDefault();

                    if (SubTopicInsertion.SubTopicname != null)
                    {
                        EditedSubTopic.SubTopicName = SubTopicInsertion.SubTopicname;
                    }
                }
                entity.SaveChanges();
                return true;
            }

        }



        #endregion



        #endregion

        public static EditorsdetValues GetLargeEditorwithID(int EditorID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {

                EditorsdetValues obj = new EditorsdetValues();

                if (EditorID == 0)
                {
                    obj.EditorID = 0;
                    obj.email = "";
                    obj.affiliations = "";
                    obj.name = "";
                    obj.SpecialityList = GetSpecialitListInUse();
                }
                else
                {
                    obj = (from CA in entity.CommentAuthors
                           join LE in entity.AtLargeEditors on new { Id = CA.id } equals new { Id = LE.EditorID } into LE_join
                           from LE in LE_join.DefaultIfEmpty()
                           join s in entity.Specialties on LE.SpecialtyID equals s.SpecialtyID into s_join
                           from s in s_join.DefaultIfEmpty()
                           where
                             CA.id == EditorID
                           select new EditorsdetValues
                           {
                               EditorID = CA.id,
                               name = CA.name,
                               affiliations = CA.affiliations,
                               email = CA.email,
                               StartDate = (DateTime?)LE.StartDate,
                               RetireDate = (DateTime?)LE.RetireDate,
                               SpecialtyName = s.SpecialtyName,
                               SpecialityID = s.SpecialtyID
                           }).FirstOrDefault();

                }



                return obj;
            }
        }

        #region UpdateTopicEditors
        public static bool UpdateTopicEditors(EditorsdetValues eDl)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (eDl.EditorID != 0)
                {
                    var topiceEditors = entity.CommentAuthors.Where(e => e.id == eDl.EditorID).FirstOrDefault();
                    if (eDl.email != null)
                        topiceEditors.email = eDl.email;
                    else
                        topiceEditors.email = string.Empty;
                    if (eDl.affiliations != null)
                        topiceEditors.affiliations = eDl.affiliations;
                    else
                        topiceEditors.affiliations = string.Empty;
                    if (eDl.name != null)
                        topiceEditors.name = eDl.name;
                    else
                        topiceEditors.name = string.Empty;
                    entity.SaveChanges();

                }
                else
                {
                    var createTopicEditor = new CommentAuthor
                    {
                        name = eDl.name,
                        affiliations = eDl.affiliations,
                        email = eDl.email
                    };
                    entity.CommentAuthors.Add(createTopicEditor);
                    entity.SaveChanges();
                }
            }
            return result;
        }
        #endregion

        #region UpdateLargeEditors
        public static bool UpdateLargeEditors(EditorsdetValues eDl)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (eDl.EditorID != 0)
                {
                    var largeEditorsC = entity.CommentAuthors.Where(e => e.id == eDl.EditorID).FirstOrDefault();
                    if (eDl.email != null)
                        largeEditorsC.email = eDl.email;
                    else
                        largeEditorsC.email = string.Empty;
                    if (eDl.affiliations != null)
                        largeEditorsC.affiliations = eDl.affiliations;
                    else largeEditorsC.affiliations = string.Empty;

                    if (eDl.name != null)
                        largeEditorsC.name = eDl.name;
                    else largeEditorsC.affiliations = string.Empty;

                    var largeEditorsL = entity.AtLargeEditors.Where(e => e.EditorID == eDl.EditorID).FirstOrDefault();
                    if (largeEditorsL != null)
                    {
                        if (eDl.StartDate != null)
                            largeEditorsL.StartDate = (DateTime)eDl.StartDate;

                        if (eDl.RetireDate != null)
                            largeEditorsL.RetireDate = eDl.RetireDate;
                        else largeEditorsL.RetireDate = null;
                        if (eDl.SpecialityID != null)
                            largeEditorsL.SpecialtyID = (int)eDl.SpecialityID;
                    }
                    entity.SaveChanges();

                }
                else
                {
                    var createTopicEditor = new CommentAuthor
                    {
                        name = eDl.name,
                        affiliations = eDl.affiliations,
                        email = eDl.email
                    };
                    entity.CommentAuthors.Add(createTopicEditor);
                    entity.SaveChanges();

                    if (eDl.IsLargeEditor == true)
                    {
                        var createLargeEditor = new AtLargeEditor
                        {
                            EditorID = createTopicEditor.id,
                            SpecialtyID = (int)eDl.SpecialityID,
                            StartDate = (DateTime)eDl.StartDate,
                            RetireDate = eDl.RetireDate
                        };
                        entity.AtLargeEditors.Add(createLargeEditor);
                        entity.SaveChanges();
                    }

                }
            }
            return result;
        }
        #endregion

        #region getTopicsForEditor
        public static Grid.GridResult getTopicsForEditor(MVC4Grid.Grid.GridFilter Filter, int EditorId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var feildsobj = (from t1 in entity.EditorTopics
                                 join t2 in entity.Topics on t1.TopicID equals t2.TopicID
                                 where
                                   t1.EditorID == (((int?)EditorId ?? (int?)0))
                                 select new EditorTopics
                                 {
                                     EditorID = t1.EditorID,
                                     StartDate = t1.StartDate,
                                     RetireDate = t1.RetireDate,
                                     TopicName = t2.TopicName,
                                     TopicID = t1.TopicID
                                 }).GridFilterBy(Filter);
                return feildsobj;
            }

        }
        #endregion

        #region GetEditorTopicwithID
        public static EditorTopics GetEditorTopicwithID(int EditorID, int TopicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorTopics obj = new EditorTopics();

                if (EditorID != 0 && TopicId == 0)
                {
                    obj.EditorID = EditorID;
                    obj.TopicName = string.Empty;
                    obj.TopicID = 0;
                }
                else
                {
                    obj = (from t1 in entity.EditorTopics
                           join t2 in entity.Topics on t1.TopicID equals t2.TopicID
                           where
                             t1.EditorID == EditorID && t1.TopicID == TopicId
                           select new EditorTopics
                           {
                               EditorID = t1.EditorID,
                               StartDate = t1.StartDate,
                               RetireDate = t1.RetireDate,
                               TopicName = t2.TopicName,
                               TopicID = t1.TopicID
                           }).FirstOrDefault();

                }
                return obj;
            }
        }
        #endregion

        #region UpdateEditorAssignment
        public static bool UpdateEditorAssignment(EditorTopics eDl)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (eDl.EditorID != 0 && eDl.TopicID != 0)
                {
                    var EditorAssignment = entity.EditorTopics.Where(e => e.EditorID == eDl.EditorID && e.TopicID == eDl.TopicID).FirstOrDefault();
                    if (EditorAssignment != null)
                    {
                        //if (eDl.StartDate != null)
                        EditorAssignment.StartDate = eDl.StartDate;
                        //if (eDl.RetireDate != null)
                        EditorAssignment.RetireDate = eDl.RetireDate;
                        entity.SaveChanges();
                    }
                    else
                    {
                        var createEditorAss = new EditorTopic
                        {
                            EditorID = (int)eDl.EditorID,
                            TopicID = (int)eDl.TopicID,
                            StartDate = eDl.StartDate,
                            RetireDate = eDl.RetireDate
                        };
                        entity.EditorTopics.Add(createEditorAss);
                        entity.SaveChanges();
                    }
                }
            }

            return result;
        }

        #endregion

        #region GetTopicsForAssignment data from DB

        /// <summary>
        /// Get Topics For Assignment from DB bind it to Drop Down list while adding Assignment
        /// </summary> method of binding dropdown with orderby clause
        /// <returns></returns>
        public static List<SelectListItem> GetTopicsForAssignment()
        {
            using (EditorsEntities db = new EditorsEntities())
            {
                var query = (from s in db.Specialties.AsEnumerable()
                             join t in db.Topics on s.SpecialtyID equals t.SpecialtyID
                             where
                               s.isInUse == true &&
                               t.Type == 1
                             select new SelectListItem
                             {
                                 Text = (s.SpecialtyName + "/" + t.TopicName),
                                 Value = t.TopicID.ToString()

                             }).ToList();
                return query;

            }
        }
        #endregion

        #region GetNonMedlineCitations New Grid
        /// <summary>
        /// This will return all Non-Medline Citations details order by PMID
        /// </summary>
        /// <returns></returns>

        public static Grid.GridResult GetNonMedlineCitations(MVC4Grid.Grid.GridFilter Filter)
        {

            //List<NonMedlineCitations> Citations = new List<NonMedlineCitations>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var feildsobj = (from NC in entity.NonMedlineCitations
                                 orderby
                                   NC.PMID
                                 select new NonMedlineCitations
                                 {
                                     PMID = NC.PMID,
                                     ArticleTitle = NC.ArticleTitle,
                                     AuthorList = NC.AuthorList,
                                     Abstract = NC.Abstract,
                                     CitationDate = NC.CitationDate,
                                     DisplayDate = NC.DisplayDate,
                                     DisplayNotes = NC.DisplayNotes,
                                     ExpireDate = NC.ExpireDate,
                                     KeepDelete = NC.KeepDelete,
                                     MedlinePgn = NC.MedlinePgn,
                                     MedlineTA = NC.MedlineTA,
                                     Nickname = NC.Nickname,
                                     SearchID = NC.SearchID,
                                     Status = NC.Status,
                                     StatusDisplay = NC.StatusDisplay,
                                     dps = NC.dps
                                 }).GridFilterBy(Filter);
                return feildsobj;
            }


        }

        #endregion

        #region GetEditorTopicwithID
        public static NonMedlineCitations GetNonMedlineCitationwithID(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                NonMedlineCitations obj = new NonMedlineCitations();

                if (PMID == 0)
                {
                    obj.SearchID = string.Empty;
                    obj.Status = string.Empty;
                    obj.ArticleTitle = string.Empty;
                    obj.AuthorList = string.Empty;
                    // obj.CitationDate = System.DateTime.Now;
                    obj.DisplayDate = string.Empty;
                    obj.DisplayNotes = string.Empty;
                    // obj.ExpireDate = string.Empty;
                    obj.KeepDelete = string.Empty;
                    obj.MedlinePgn = string.Empty;
                    obj.MedlineTA = string.Empty;
                    obj.Nickname = string.Empty;
                    obj.SearchID = string.Empty;
                    obj.Status = string.Empty;
                    obj.StatusDisplay = string.Empty;
                    obj.dps = 0;
                }
                else
                {
                    obj = (from NC in entity.NonMedlineCitations
                           where NC.PMID == PMID
                           select new NonMedlineCitations
                           {
                               PMID = NC.PMID,
                               ArticleTitle = NC.ArticleTitle,
                               AuthorList = NC.AuthorList,
                               Abstract = NC.Abstract,
                               CitationDate = NC.CitationDate,
                               DisplayDate = NC.DisplayDate,
                               DisplayNotes = NC.DisplayNotes,
                               ExpireDate = NC.ExpireDate,
                               KeepDelete = NC.KeepDelete,
                               MedlinePgn = NC.MedlinePgn,
                               MedlineTA = NC.MedlineTA,
                               Nickname = NC.Nickname,
                               SearchID = NC.SearchID,
                               Status = NC.Status,
                               StatusDisplay = NC.StatusDisplay,
                               dps = NC.dps
                           }).FirstOrDefault();

                }
                return obj;
            }
        }
        #endregion

        #region UpdateNonMedlineCitations
        public static bool UpdateNonMedlineCitations(NonMedlineCitations nMC)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (nMC.PMID != 0)
                {
                    var nonMedlineCit = entity.NonMedlineCitations.Where(p => p.PMID == nMC.PMID).FirstOrDefault();
                    if (nonMedlineCit != null)
                    {
                        nonMedlineCit.ArticleTitle = nMC.ArticleTitle;
                        nonMedlineCit.AuthorList = nMC.AuthorList;
                        nonMedlineCit.Abstract = nMC.Abstract;
                        nonMedlineCit.CitationDate = nMC.CitationDate;
                        nonMedlineCit.DisplayDate = nMC.DisplayDate;
                        nonMedlineCit.DisplayNotes = nMC.DisplayNotes;
                        nonMedlineCit.ExpireDate = nMC.ExpireDate;
                        nonMedlineCit.KeepDelete = nMC.KeepDelete;
                        nonMedlineCit.MedlinePgn = nMC.MedlinePgn;
                        nonMedlineCit.MedlineTA = nMC.MedlineTA;
                        nonMedlineCit.Nickname = nMC.Nickname;
                        nonMedlineCit.SearchID = nMC.SearchID;
                        nonMedlineCit.Status = nMC.Status;
                        nonMedlineCit.StatusDisplay = nMC.StatusDisplay;

                        entity.SaveChanges();
                    }



                    else
                    {
                        var createNonMedlineCitation = new NonMedlineCitation
                        {
                            PMID = (int)nMC.PMID,
                            ArticleTitle = nMC.ArticleTitle,
                            AuthorList = nMC.AuthorList,
                            Abstract = nMC.Abstract,
                            CitationDate = nMC.CitationDate,
                            DisplayDate = nMC.DisplayDate,
                            DisplayNotes = nMC.DisplayNotes,
                            ExpireDate = nMC.ExpireDate,
                            KeepDelete = nMC.KeepDelete,
                            MedlinePgn = nMC.MedlinePgn,
                            MedlineTA = nMC.MedlineTA,
                            Nickname = nMC.Nickname,
                            SearchID = nMC.SearchID,
                            Status = nMC.Status,
                            StatusDisplay = nMC.StatusDisplay

                        };
                        entity.NonMedlineCitations.Add(createNonMedlineCitation);
                        entity.SaveChanges();
                    }
                }
            }
            return result;
        }


        #endregion

        public static bool CheckPMIDExists(int? pmid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var res = entity.NonMedlineCitations.FirstOrDefault(i => i.PMID == pmid);
                if (res == null)
                    return false;
                else if (res.PMID == pmid)
                    return true;
                else
                    return false;
            }
        }

        public static bool DeleteCitation(int CitationID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var cld = (from f in entity.NonMedlineCitations where f.PMID == CitationID select f).FirstOrDefault();
                entity.NonMedlineCitations.Remove(cld);
                entity.SaveChanges();
                return true;
            }
        }


        public static bool DeleteEditorAssignment(int Eid, int topicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Sr = (from f in entity.SubTopicEditorRefs where f.EditorID == Eid && f.TopicID == topicId select f);
                if (Sr != null)
                {
                    foreach (var agShare in Sr)
                    {
                        if (agShare != null)
                            entity.SubTopicEditorRefs.Remove(agShare);
                    }
                }

                var cld = (from f in entity.EditorTopics where f.EditorID == Eid && f.TopicID == topicId select f).FirstOrDefault();
                entity.EditorTopics.Remove(cld);
                entity.SaveChanges();
                return true;
            }
        }

        #region GetSubTopicBy Sub-Topic ID
        /// <summary>
        /// This will return a sub-topic object by passing sub-topic ID and return an object of sub-topic to edit
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        public static SubTopics GetSubTopicWithID(int ID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var SubtopicEdit = (from s in entity.SubTopics
                                    where s.SubTopicID == ID && s.Type == 1
                                    select new SubTopics
                                    {
                                        SubTopicID = s.SubTopicID,
                                        SubTopicname = s.SubTopicName,
                                        TopicID = s.TopicID
                                    }).FirstOrDefault();
                return SubtopicEdit;

            }
        }

        #endregion

        #region Sub-Topic Creation or Updation
        /// <summary>
        /// This will add or update a sub-topic to the DB and return a bool value 
        /// </summary>
        /// <param name="SubTopic"></param>
        /// <returns></returns>
        public static bool InsertSubTopicByAdmin(SubTopics SubTopic)
        {
            bool result = false;
            using (EditorsEntities entity = new EditorsEntities())
            {
                if (SubTopic.SubTopicID == 0)
                {
                    var CreateSubTopic = new SubTopic
                    {
                        SubTopicName = SubTopic.SubTopicname,
                        TopicID = SubTopic.TopicID,
                        createtime = DateTime.Now,
                        UserID = 0,
                        Type = 1,
                        Priority = 0
                    };
                    entity.SubTopics.Add(CreateSubTopic);
                }
                else
                {
                    #region Update Speciality Sub-Topic

                    var EditedSubTopic = entity.SubTopics.Where(u => u.SubTopicID == SubTopic.SubTopicID && u.TopicID == SubTopic.TopicID).FirstOrDefault();

                    if (SubTopic.SubTopicname != null)
                    {
                        EditedSubTopic.SubTopicName = SubTopic.SubTopicname;
                    }

                    #endregion
                }

                entity.SaveChanges();
                return true;
            }

        }

        #endregion

        #region GetSubTopic object with TopicID
        /// <summary>
        /// This will return an object of Sub topic to load a partial view of create sub-topic
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        public static SubTopics CreateNewSubTopicWithTopicID(int ID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var newSubtopic = (from s in entity.Topics
                                   where s.TopicID == ID && s.Type == 1
                                   select new SubTopics
                                   {
                                       TopicID = s.TopicID,
                                       SpecialityID = s.SpecialtyID,
                                       TopicName = s.TopicName
                                   }).FirstOrDefault();
                return newSubtopic;
            }
        }

        #endregion

        #region GetSubTopicsWith TopicID

        /// <summary>
        /// This will return list of all Subtopics present in a Topic and bind it to  Manage Sub Topics Grid
        /// </summary>
        /// <param name="TopicId"></param>
        /// <returns></returns>
        public static List<SubTopics> GetSubTopicsWithID(int TopicId)
        {
            List<SubTopics> Subtopics = new List<SubTopics>();
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<SubTopics> Newobj = (from s in entity.SubTopics
                                          where s.TopicID == TopicId && s.Type == 1
                                          select new SubTopics
                                          {
                                              SubTopicID = s.SubTopicID,
                                              SubTopicname = s.SubTopicName,
                                              CreatedDate = s.createtime
                                          }).ToList();
                Subtopics.AddRange(Newobj);

            }
            return Subtopics;
        }

        #endregion

        #region Get Topics By Speciality ID for Grid
        /// <summary>
        /// Get Topics By Speciality ID for new DLL grid 10/22/2013-RaviM
        /// </summary>
        /// <param name="Filter"></param>
        /// <param name="ID"></param>
        /// <returns></returns>
        public static MVC4Grid.Grid.GridResult GetTopicsBySpecIDMigGrid(MVC4Grid.Grid.GridFilter Filter, int? ID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var AllTopics = (from s in entity.Topics.Where(i => i.SpecialtyID == ID && i.Type == 1)
                                 orderby s.TopicName
                                 select new TopicDetValues
                                 {
                                     TopicID = s.TopicID,
                                     TopicName = s.TopicName,
                                     SpecialityID = s.SpecialtyID,
                                     Type = s.Type,
                                     CreatedDate = s.createtime,
                                 }).GridFilterBy(Filter);
                return AllTopics;
            }
        }

        #endregion

        #region Get SubTopics With Topic ID For New DLL Grid on 10/22/2013
        /// <summary>
        /// Get Sub Topics With Topic ID-RaviM
        /// </summary>
        /// <param name="SubTopicFilter"></param>
        /// <param name="topID"></param>
        /// <returns></returns>
        public static MVC4Grid.Grid.GridResult GetSubTopicsWithTopicID(MVC4Grid.Grid.GridFilter SubTopicFilter, int topID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var AllRelatedSubTopics = (from s in entity.SubTopics.Where(i => i.TopicID == topID && i.Type == 1)
                                           orderby s.SubTopicName
                                           select new SubTopics
                                           {
                                               TopicID = s.TopicID,
                                               SubTopicID = s.SubTopicID,
                                               SubTopicname = s.SubTopicName,
                                               CreatedDate = s.createtime
                                           }).GridFilterBy(SubTopicFilter);
                return AllRelatedSubTopics;
            }
        }

        #endregion

        #region GetTopicName
        /// <summary>
        /// This will return a string of Topic name by passing TopicID
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string GetTopicnameBytopicID(int id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Topicname = (from t in entity.Topics where t.TopicID == id select t.TopicName).FirstOrDefault();
                return Topicname;
            }
        }
        #endregion

        #region AboutROeditiors
        public static List<AboutROEditors> GetROSpecialtyeditors(int? Specialtyid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var editors = (from t in entity.CommentAuthors
                               join t0 in entity.EditorTopics on new { id = t.id } equals new { id = t0.EditorID }
                               join t1 in entity.Topics on t0.TopicID equals t1.TopicID
                               join t2 in entity.Specialties on t1.SpecialtyID equals t2.SpecialtyID
                               where
                                 t1.SpecialtyID == Specialtyid &&
                                 t.affiliations != ""
                               orderby
                                 t1.TopicName
                               select new AboutROEditors
                               {
                                   TopicId = t1.TopicID,
                                   TopicName = t1.TopicName,
                                   SpecialtyName = t2.SpecialtyName
                               }).Distinct().ToList();
                return editors;
            }
        }

        public static string GetSpecialityName(int? specialtyid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from p in entity.Specialties
                             where p.SpecialtyID == specialtyid
                             select p.SpecialtyName).FirstOrDefault();
                return query;

            }
        }

        public static List<SelectListItem> GetSpecialityInUse(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from p in entity.Specialties.AsEnumerable()
                             where p.isInUse == true
                             orderby p.SpecialtyID
                             select new SelectListItem
                             {
                                 Value = p.SpecialtyID.ToString(),
                                 Text = p.SpecialtyName,
                                 Selected = (p.SpecialtyID == id)
                             }).ToList();
                return query;

            }
        }

        public static List<AboutROEditors> GetTopicEditors(int? Specialtyid, int? Topicid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var editors = (from t in entity.CommentAuthors
                               join t0 in entity.EditorTopics on new { id = t.id } equals new { id = t0.EditorID }
                               join t1 in entity.Topics on t0.TopicID equals t1.TopicID
                               where
                                 t1.SpecialtyID == Specialtyid &&
                                 t1.TopicID == Topicid &&
                                 t0.RetireDate == null
                               orderby
                                 t1.TopicName
                               select new AboutROEditors
                               {
                                   id = t.id,
                                   name = t.name,
                                   affiliations = t.affiliations,
                                   TopicId = t0.TopicID,
                                   TopicName = t1.TopicName,
                                   Specialtyid = t1.SpecialtyID
                               }).ToList();
                return editors;
            }

        }

        public static List<AboutROEditors> GetROAtlargeeditors(int? Specialtyid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var atlargeeditors = (from ed in entity.CommentAuthors
                                      join ale in entity.AtLargeEditors on new { id = ed.id } equals new { id = ale.EditorID }
                                      where
                                        ale.SpecialtyID == Specialtyid &&
                                        ale.StartDate <= DateTime.Now &&
                                        (ale.RetireDate == null ||
                                        ale.RetireDate >= DateTime.Now)
                                      select new AboutROEditors
                                      {
                                          Editorid = ale.EditorID,
                                          name = ed.name,
                                          affiliations = ed.affiliations
                                      }).ToList();
                return atlargeeditors;
            }
        }

        #endregion

        #region Delete Functionality for Topics,TopicEditors,At-Large Editors
        /// <summary>
        /// Check Delete Topics for Existed Subtopics
        /// </summary>
        /// <param name="TopicID"></param>
        /// <returns></returns>
        public static bool SubTopicsforTopic(int? TopicID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var IsSubTopicExist = entity.SubTopics.Where(i => i.TopicID == TopicID).FirstOrDefault();
                if (IsSubTopicExist != null)
                    return false;
                else
                {
                    var TopicObj = entity.Topics.Where(i => i.TopicID == TopicID).FirstOrDefault();
                    entity.Topics.Remove(TopicObj);
                    entity.SaveChanges();
                    return true;
                }
            }
        }

        /// <summary>
        /// Deleting Sub Topic if no related saved cits or Editions
        /// </summary>
        /// <param name="SubTopicID"></param>
        /// <returns></returns>
        public static bool DelSubTopic(int? SubTopicID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var RefSubTopics = entity.SubTopicReferences.Where(i => i.SubTopicID == SubTopicID).FirstOrDefault();
                var MysaveCits = entity.UserCitations.Where(i => i.SubTopicID == SubTopicID).FirstOrDefault();

                if (RefSubTopics == null)
                {
                    if (MysaveCits == null)
                    {
                        var SubTopicObj = entity.SubTopics.Where(i => i.SubTopicID == SubTopicID).FirstOrDefault();
                        entity.SubTopics.Remove(SubTopicObj);
                        entity.SaveChanges();
                        return true;
                    }
                    if (MysaveCits != null && MysaveCits.Deleted == true)
                    {
                        var SubTopicObj = entity.SubTopics.Where(i => i.SubTopicID == SubTopicID).FirstOrDefault();
                        entity.SubTopics.Remove(SubTopicObj);
                        entity.SaveChanges();
                        return true;
                    }
                    else
                        return false;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// Delete Topic Editors if no Comments Existed
        /// </summary>
        /// <param name="Eid"></param>
        /// <returns></returns>
        public static bool DeleteTopicEditors(int? Eid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var TopicEditObj = (from t1 in entity.EditorTopics
                                    join t2 in entity.Topics on t1.TopicID equals t2.TopicID
                                    where
                                      t1.EditorID == Eid
                                    select t1).FirstOrDefault();
                if (TopicEditObj != null)
                    return false;
                else
                {
                    var CmtAut = entity.CommentAuthors.Where(i => i.id == Eid).FirstOrDefault();
                    var IsCmmtExist = entity.CommentAuthors.Any(i => i.id == Eid && i.EditorialComments.Count > 0);
                    if (IsCmmtExist)
                    {
                        return false;
                    }
                    if (CmtAut != null)
                    {
                        entity.CommentAuthors.Remove(CmtAut);
                        entity.SaveChanges();
                        return true;
                    }
                }
                return false;
            }
        }

        /// <summary>
        /// Delete At-Large Editors if , no comments existed for respective Delete at large editor
        /// </summary>
        /// <param name="Eid"></param>
        /// <returns></returns>
        public static bool DeleteAtLargeEditor(int? Eid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var CmtAut = entity.CommentAuthors.Where(i => i.id == Eid).FirstOrDefault();
                var AtLargeEdit = entity.AtLargeEditors.Where(i => i.EditorID == Eid).FirstOrDefault();
                var cnt = entity.CommentAuthors.Any(i => i.id == Eid && i.EditorialComments.Count > 0);

                if (cnt)
                {
                    return false;
                }
                if (AtLargeEdit != null)
                {
                    entity.AtLargeEditors.Remove(AtLargeEdit);
                    if (CmtAut != null)
                        entity.CommentAuthors.Remove(CmtAut);
                    entity.SaveChanges();
                    return true;
                }
                return false;
            }
        }

        #endregion

    }
}
