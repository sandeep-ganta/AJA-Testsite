/* Created for Editors Choice to use the model - 08/12/2013 RaviM */

#region Using namespace
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using MVC4Grid;
using MVC4Grid.GridAttributes;
using MVC4Grid.GridExtensions;
#endregion

namespace DAL.Models
{
    /// <summary>
    /// Model used for Editors Choice Citations load
    /// </summary>
    public class EditorsChoicemodel
    {
        public string SearchID { get; set; }
        public List<SelectListItem> UserSpeciality { get; set; }

        public string AuthorFullList { get; set; }

        public string CurrentMonthYear { get; set; }

        public string SpecialtyName { get; set; }

        public string TopicOrdering { get; set; }

        public int SpecialtyID { get; set; }

        public int EditionId { get; set; }

        public DateTime PubDate { get; set; }

        public DateTime OriginalPubDate { get; set; }

        public string originalpubdatewords { get; set; }

        public List<SelectListItem> SpecialityList { get; set; }

        public int? ThreadId { get; set; }

        public string SubTopicname { get; set; }

        public int? SubTopicID { get; set; }

        public string TopicName { get; set; }

        public int PMID { get; set; }

        public int Sortorder { get; set; }

        public long GeneID { get; set; }

        public int AuthorID { get; set; }

        public string Name { get; set; }

        public string AuthorName { get; set; }

        public int CommentID { get; set; }

        public string Authors { get; set; }

        public string Comment { get; set; }

        public List<SelectListItem> Genelist { get; set; }

        public List<SelectListItem> Authorslist { get; set; }

        public List<FieldAuthors> NewAuthorValues { get; set; }

        public List<GeneValues> NewGeneValues { get; set; }

        public List<CommentAuthor> Authordetails { get; set; }

        public List<Gene> Genedetails { get; set; }

        public IEnumerable<EditorsChoicemodel> Displaylist { get; set; }

        public bool EditonExists { get; set; }

        public List<lib_GetECEditorSort_Result> Editors { get; set; }

        public string ArticleTitle { get; set; }

        public string AbstractText { get; set; }

        public string AbstractText2 { get; set; }

        public string AuthorList { get; set; }

        public string MedlineTA { get; set; }

        public string MedlinePgn { get; set; }

        public string DisplayDate { get; set; }

        public string DisplayNotes { get; set; }

        public string StatusDisplay { get; set; }

        public List<EditorsChoicemodel> GetEditorSelection { get; set; }

        public List<EditorsChoicemodel> GetCitaitons { get; set; }

        public List<EditorsChoicemodel> ThreadCitations { get; set; }

        public List<EditorsChoicemodel> GetECeditonThreads { get; set; }

        public List<lib_GetECThreadComments_Result> GetecThreadComments { get; set; }

        public List<GetECThreadComments> GetecThreadCommentsGne { get; set; }

        public ECThreadAttributes ThreadAttributes { get; set; }

        public List<lib_GetGenesForEditorsChoice_Result> GetGeneslst { get; set; }

        public string ThreadEditors { get; set; }

        public string ThreadTopics { get; set; }

        public List<FullTextLinkOuts> Libraries { get; set; }

        public string content { get; set; }

        public List<FullTextLinkOuts> linklist { get; set; }

        public List<FullTextLinkOuts> Aggregator { get; set; }

        public List<FullTextLinkOuts> ProviderPublis { get; set; }

        public List<lib_GetRelatedEditions_Result> RelatedEditionsList { get; set; }

        public lib_GetRelatedEditions_Result EachEdition { get; set; }

        public DateTime HasEditionDate { get; set; }

        public bool RelatedEdition { get; set; }

        public bool? unicodeFixed { get; set; }
    }

    public class CitationDetailsAuthorslist
    {
        public int? PMID { get; set; }
        public string DisplayName { get; set; }
        public short? dps { get; set; }
    }



    /// <summary>
    /// 
    /// </summary>
    public class EditorsChoiceTopicSubTopic
    {
        public List<EditorsChoiceTopicSubTopic> Displaylist { get; set; }

        public int ThreadId { get; set; }

        public string SubTopicname { get; set; }

        public int? SubTopicID { get; set; }

        public string TopicName { get; set; }

        public int PMID { get; set; }

        public string ArticleTitle { get; set; }

        public string AuthorList { get; set; }

        public string MedlineTA { get; set; }

        public string MedlinePgn { get; set; }

        public string DisplayDate { get; set; }

        public string DisplayNotes { get; set; }

        public string StatusDisplay { get; set; }



    }

    /// <summary>
    /// 
    /// </summary>
    public class ECThreadAttributes
    {
        public int EditionId { get; set; }

        public int ThreadId { get; set; }

        public string ThreadEditors { get; set; }

        public string ThreadTopics { get; set; }

        public string TopicName { get; set; }

        public string SubTopicName { get; set; }

    }

    /// <summary>
    /// 
    /// </summary>
    public class GetECThreadComments
    {
        public int EditionId { get; set; }

        public int ThreadId { get; set; }

        public int CommentID { get; set; }

        public string Authors { get; set; }

        public string Comment { get; set; }

        public bool IsEditor { get; set; }

        public List<lib_GetGenesForEditorsChoice_Result> GetGeneslst { get; set; }

    }

    /// <summary>
    /// 
    /// </summary>
    public class GetEditionThreads
    {
        public int ThreadId { get; set; }

        public DateTime OriginalPubDate { get; set; }
    }


    public class ThreadCitationlists
    {
        public int PMID { get; set; }

        public string ArticleTitle { get; set; }

        public string AbstractText { get; set; }

        public string AbstractText2 { get; set; }

        public string AuthorList { get; set; }

        public string MedlineTA { get; set; }

        public string MedlinePgn { get; set; }

        public string DisplayDate { get; set; }

        public string DisplayNotes { get; set; }

        public string StatusDisplay { get; set; }

        public int dps { get; set; }

        public string DisplayName { get; set; }

        public string SubTopicname { get; set; }

    }

    public class FullTextLinkOuts
    {
        public string URLS { get; set; }
        public string ProviderName { get; set; }

    }

    #region TopicEditors
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class TopicEditorsModel
    {

        [Key]
        [HiddenInput]
        [GridSorting(Default = true)]
        public int EditorID { get; set; }
        [Required]
        [Display(Name = "Name")]
        public string name { get; set; }

        [Display(Name = "Email")]
        [EmailAddress(ErrorMessage = "Invalid Email Address.")]
        public string email { get; set; }


        [Display(Name = "Affiliations")]
        [DisplayFormat(HtmlEncode=true)]
        public string affiliations { get; set; }


    }
    #endregion

}
