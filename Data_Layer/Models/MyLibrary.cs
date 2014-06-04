using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace DAL.Models
{
    public class UserSpecialitiesModel
    {
        public int SpecialityId { get; set; }
        public string SpecialityName { get; set; }
        public int UserId { get; set; }
    }

    public class UserFolderListDisplay
    {
        public int? OrgFolderId { get; set; }
        public string OrgFolderName { get; set; }
        public int? FunFolderId { get; set; }
        public string FunFolderName { get; set; }
        public byte? OrgType { get; set; }
        public byte? FunType { get; set; }
        public int? UserId { get; set; }
        public int? SpecialtyID { get; set; }
        public int? TopicOrder { get; set; }
        public int? doccount { get; set; }
    }


    public class UserFolderListEdit
    {
        public int? OrgId { get; set; }
        public string OrgName { get; set; }
        public int? FunId { get; set; }
        public string FunName { get; set; }
        public byte? OrgType { get; set; }
        public byte? FunType { get; set; }
        public int? UserId { get; set; }
        public int? SpecialtyID { get; set; }
        public int? TopicOrder { get; set; }
        public int? doccount { get; set; }
    }

    public class FolderEditorialComments
    {
        public int PMID { get; set; }
        public int oid { get; set; } // oid means topic id
        public int fid { get; set; } // fid means subtopic id
    }


    public class MyLibraryModel
    {
        public int UserId { get; set; }
        public List<UserSpecialitiesModel> AllUserSpecialities { get; set; }
        public List<UserFolderListDisplay> AllUserFolders { get; set; }
        public List<UserFolderListEdit> AllUserFoldersEdit { get; set; }
        public List<FolderEditorialComments> FolderECList { get; set; }
        public List<int> HiddenTopicIds { get; set; }
        public List<int> HiddenSubTopicIds { get; set; }

        // For Citation Details
        public List<CitationsModel> Citations { get; set; }
        public List<CitationDetailsModel> CitationDetailsTotal { get; set; }
        public List<CitationDetailsModel> CitationDetails { get; set; }

        // For citation abstract
        public UserCommentAbstract UserComment { get; set; }
        public List<AbstractCommentsECModel> AbstractCommentsECList { get; set; }

        public CommentContext CommentContext { get; set; }

        // For EditorChoice

        public List<PmidClass> PMIDs { get; set; }

        // For Copy Citation

        public int SelectedTopic { get; set; }
        public int SelectedSubTopic { get; set; }
        public int SelectedTopicSecond { get; set; }

        // For Annotate Form
        public Annotate AnnotateForm { get; set; }

        // For ACR Documents in Mylibrary
        public List<AcrdocumentsMyLibrary> AcrDocumentsMyLibraryList { get; set; }

        // For Geting Genes

        public List<GeneMyLibrary> GenesMylibrary { get; set; }
        public List<GeneMyLibrary> GenesForThreadMylibrary { get; set; }
        public List<GeneMyLibrary> GenesEditorMylibrary { get; set; }

        public List<TestMyLibrary> TestsMylibrary { get; set; }
        public List<TestMyLibrary> TestsForThreadMylibrary { get; set; }
        public List<TestMyLibrary> TestsEditorMylibrary { get; set; }
        // FOr Linkout
        public EditorsChoicemodel LinkoutModelVar { get; set; }

        public int PMID { get; set; }
        public bool FromPMedline { get; set; }

    }

    public class GetUserSpecialtyModel
    {
        public int? SpecialtyId { get; set; }
        public string SpecialtyName { get; set; }
        public int isInUse { get; set; }
        public IEnumerable<SelectListItem> UserSpecialtyListDropDwon { get; set; }
        public int SelectedSpecialtyId { get; set; }
    }


    public class CitationsModel
    {
        public int pmid { get; set; }
        public bool status { get; set; }
        public string nickname { get; set; }
        public string comment { get; set; }
        public DateTime? commentupdatedate { get; set; }
        public int? searchid { get; set; }
        public DateTime? expiredate { get; set; }
        public bool keepdelete { get; set; }
    }

    public class CitationDetailsModel
    {
        public int? pmid { get; set; }
        public string ArticleTitle { get; set; }
        public string AuthorList { get; set; }
        public string MedlineTA { get; set; }
        public string MedlinePgn { get; set; }
        public string DisplayDate { get; set; }
        public string DisplayNotes { get; set; }
        public string StatusDisplay { get; set; }
        public short? dps { get; set; }
        public string AbstractText { get; set; }
        public string AbstractText2 { get; set; }

        public string AuthorFullList { get; set; }
        public string DisplayName { get; set; }
        public bool? unicodeFixed { get; set; }
    }


    public class CitationDetailsModelDetail
    {
        public int? PMID { get; set; }
        public string DisplayName { get; set; }
        public short? dps { get; set; }
    }


    public class UserCommentAbstract
    {
        public string nickname { get; set; }
        public string comment { get; set; }
        public DateTime? updatedate { get; set; }
    }

    public class AbstractCommentsECModel
    {
        public int ThreadId { get; set; }
        public int CommentId { get; set; }
        public DateTime OriginalPubDate { get; set; }
        public string Comment { get; set; }
    }


    public class CommentContext
    {
        public List<RelatedCitatins> RelatedCitations { get; set; }
        public EditorsDetails EditorsDetails { get; set; }
    }

    public class RelatedCitatins
    {
        public int PMID { get; set; }
        public int? TopicId { get; set; }
        public int? SubTopicId { get; set; }
    }
    public class EditorsDetails
    {
        public bool @EditorIsAuthor { get; set; }
        public bool @MultipleEditors { get; set; }
        public string @Editors { get; set; }
        public string @Authors { get; set; }
    }

    public class PmidClass
    {
        public int PMID { get; set; }
    }
    public class UserSubTopicModel
    {
        //  public List<SelectListItem> UserSubTopics { get; set; }
        public int SubTopicId { get; set; }
        public string SubTopicName { get; set; }
    }

    public class Annotate
    {
        public int PMID { get; set; }
        public string Title { get; set; }
        [Required]
        public string Nickname { get; set; }
        [Required]
        public string Comment { get; set; }
    }

    public class AcrdocumentsMyLibrary
    {
        public int Id { get; set; }
        public int subtopic_id { get; set; }
        public string subtopic_nm { get; set; }
        public int doc_id { get; set; }
        public string doc_nm { get; set; }
        public int doc_clicks_count { get; set; }
        public string doc_source { get; set; }
    }
    public class AddSponsorFolderTemp
    {
        public int TopicFolderId { get; set; }
    }

    public class GeneMyLibrary
    {
        public long GeneId { get; set; }
        public string Name { get; set; }
    }

    public class TestMyLibrary
    {
        public long TestID { get; set; }
        public string Name { get; set; }
    }

}
