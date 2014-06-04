using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Models;
using DAL.Entities;
using System.Data;
using System.Web.Mvc;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Web;
using System.Xml;
using System.Xml.Linq;

namespace DAL
{
    public class MyLibraryBL
    {
        public static List<UserSpecialitiesModel> GetUserSpecialities(int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var UserSpecialitiesList = (from us in entity.UserSpecialties
                                            join s in entity.Specialties on us.SpecialtyID equals s.SpecialtyID
                                            where us.UserID == UserId
                                            orderby us.DateAdded
                                            select new UserSpecialitiesModel
                                            {
                                                SpecialityId = us.SpecialtyID,
                                                SpecialityName = s.SpecialtyName
                                            }).ToList();
                return UserSpecialitiesList;
            }
        }

        // For User Folder List for DisplyLibrary
        public static List<UserFolderListDisplay> GetUserFolderList(int SpecId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<UserFolderListDisplay> folderList = null;
                string query = "[lib_GetFoldersAndEC20Citations] @UserID,@SpecialtyID";
                SqlParameter UserID = new SqlParameter("@UserID", UserId);
                SqlParameter SpecialtyID = new SqlParameter("@SpecialtyID", SpecId);
                folderList = entity.Database.SqlQuery<UserFolderListDisplay>(query, UserID, SpecialtyID).ToList();
                return folderList;
            }
        }


        public static List<UserFolderListEdit> GetUserFolderListEdit(int SpecId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<UserFolderListEdit> folderList = null;
                string query = "[lib_GetFolderListSFE] @UserID,@SpecialtyID";
                SqlParameter UserID = new SqlParameter("@UserID", UserId);
                SqlParameter SpecialtyID = new SqlParameter("@SpecialtyID", SpecId);
                folderList = entity.Database.SqlQuery<UserFolderListEdit>(query, UserID, SpecialtyID).ToList();
                return folderList;
            }
        }


        public static List<FolderEditorialComments> GetFolderECComments(int specId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<FolderEditorialComments> folderECList = null;
                string query = "lib_GetFoldersEC20Citations @SpecialtyID";
                SqlParameter SpecialtyID = new SqlParameter("@SpecialtyID", specId);
                folderECList = entity.Database.SqlQuery<FolderEditorialComments>(query, SpecialtyID).ToList();
                return folderECList;
            }
        }


        // For Getting All HiddenTopics of User

        public static List<int> GetHiddenTopicIds(int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var HiddenTopics = entity.HiddenTopics.Where(h => h.UserID == UserId).Select(s => s.TopicID).ToList();
                return HiddenTopics;
            }
        }


        // For Getting All HiddenSubTopics of User

        public static List<int> GetHiddenSubTopicIds(int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var HiddenSubTopics = entity.HiddenSubTopics.Where(h => h.UserID == UserId).Select(s => s.SubTopicID).ToList();
                return HiddenSubTopics;
            }
        }


        // To Add User Topic
        public static bool AddTopic(int SpecId, string TopicName, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                Topic NewUserTopic = new Topic();
                NewUserTopic.TopicName = TopicName;
                NewUserTopic.SpecialtyID = SpecId;
                NewUserTopic.Type = 2; // 2 Represents User Topic
                NewUserTopic.UserID = UserId;
                NewUserTopic.createtime = DateTime.Now;
                entity.Topics.Add(NewUserTopic);
                entity.SaveChanges();
                return true;
            }
        }


        // To Add User Sub Topic
        public static bool AddSubTopic(string TopicId, string SubTopicName, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                try
                {
                    SubTopic NewUserSubTopic = new SubTopic();
                    NewUserSubTopic.TopicID = Convert.ToInt32(TopicId);
                    NewUserSubTopic.UserID = UserId;
                    NewUserSubTopic.SubTopicName = SubTopicName;
                    NewUserSubTopic.Type = 2;  // 2 Represents User SubTopic
                    NewUserSubTopic.createtime = DateTime.Now;
                    entity.SubTopics.Add(NewUserSubTopic);
                    entity.SaveChanges();
                    return true;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }


        // Delete UserSubTopic
        public static bool DeleteSubTopic(int SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                DeleteUserSubTopic(entity, SubTopicId, UserId);
                return true;
            }
        }


        // For Deleting User SubTopic Calling from above
        static void DeleteUserSubTopic(EditorsEntities entity, int SubTopicId, int UserId)
        {
            // First, delete UserCitations for this SubTopic
            var UserCitationsToBeDeleted = entity.UserCitations.Where(u => u.SubTopicID == SubTopicId && u.UserID == UserId).ToList();
            foreach (UserCitation UC in UserCitationsToBeDeleted)
            {
                entity.UserCitations.Remove(UC);
            }

            // Deleted UserCitations by above statement

            // Second, delete searches for this SubTopic 

            entity.lib_DeleteSearchesFromSubTopic(SubTopicId, UserId);   // Executing lib_DeleteSearchesFromSubTopic Stored Procedure.

            // Delete searches for this SubTopic by above stored procedure

            // Third, delete this SubTopic from subtopics and userhas sponsersubtopic
            var UserSubTopicToBeDeleted = entity.SubTopics.Where(s => s.SubTopicID == SubTopicId && s.UserID == UserId && s.Type == 2).FirstOrDefault();
            if (UserSubTopicToBeDeleted != null)
                entity.SubTopics.Remove(UserSubTopicToBeDeleted);

            var UserSponsorFolderToBeDeleted = entity.UserHasSponsorFolders.Where(s => s.UserFolderId == SubTopicId && s.UserId == UserId).FirstOrDefault();
            if (UserSponsorFolderToBeDeleted != null)
                entity.UserHasSponsorFolders.Remove(UserSponsorFolderToBeDeleted);
            entity.SaveChanges();
        }



        // For Deleting User Topic
        public static bool DeleteTopic(int TopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                DeleteUserTopic(entity, TopicId, UserId);
                return true;
            }
        }


        static void DeleteUserTopic(EditorsEntities entity, int TopicId, int UserId)
        {
            // First need to Get and delete SubTopics in the Topic which is going to Delete
            var Subtopics = (from s in entity.SubTopics
                             where s.TopicID == TopicId && (((s.Type == 2) && s.UserID == UserId) || s.Type == 3)
                             select s.SubTopicID).ToList();
            foreach (var SubTopicId in Subtopics)
            {
                DeleteUserSubTopic(entity, SubTopicId, UserId);
            }

            // Completed Deleting Subtopics in Topics


            // Need to Delete UserTopic
            var UserTopicToBeDeleted = entity.Topics.Where(s => s.TopicID == TopicId && s.UserID == UserId && s.Type == 2).FirstOrDefault();
            if (UserTopicToBeDeleted != null)
                entity.Topics.Remove(UserTopicToBeDeleted);
            entity.SaveChanges();
        }


        // For Deleting Specialty

        public static bool DeleteSpecialty(int specid, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Topics = (from s in entity.Topics
                              where s.UserID == UserId && s.Type == 2 && s.SpecialtyID == specid
                              select s.TopicID).ToList();

                foreach (var TopicId in Topics)
                {
                    DeleteUserTopic(entity, TopicId, UserId);
                }


                //Nuke all auto-queries associated with this specialty

                entity.lib_DeleteUserAutoQueries(specid, UserId); // Executing lib_DeleteUserAutoQueries stored procedure 

                // Finally, delete the enclosing specialty itself

                var UserSpecialtyToBeDelete = entity.UserSpecialties.Where(s => s.SpecialtyID == specid && s.UserID == UserId).FirstOrDefault();
                if (UserSpecialtyToBeDelete != null)
                    entity.UserSpecialties.Remove(UserSpecialtyToBeDelete);
                entity.SaveChanges();
                return true;
            }
        }


        // For Deleting User Sponsor Topic
        public static bool DeleteSponsorTopic(int TopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                DeleteUserSposorTopic(entity, TopicId, UserId);
                return true;
            }
        }



        static void DeleteUserSposorTopic(EditorsEntities entity, int TopicId, int UserId)
        {
            // First need to Get and delete SubTopics in the Topic which is going to Delete
            var Subtopics = (from s in entity.SubTopics
                             where s.TopicID == TopicId && (((s.Type == 2) && s.UserID == UserId) || s.Type == 3)
                             select s.SubTopicID).ToList();
            foreach (var SubTopicId in Subtopics)
            {
                DeleteUserSubTopic(entity, SubTopicId, UserId);
            }
            entity.lib_RemoveSponsorTopic(UserId, TopicId);
            entity.SaveChanges();
        }




        // To Hide UserTopic

        public static bool HideTopics(List<int> TopicIds, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                foreach (var TopicId in TopicIds)
                {
                    HideTopic(entity, TopicId, UserId);
                }
                entity.SaveChanges();
                return true;
            }
        }

        static void HideTopic(EditorsEntities entity, int TopicId, int UserId)
        {
            HiddenTopic HT = entity.HiddenTopics.Where(h => h.UserID == UserId && h.TopicID == TopicId).FirstOrDefault();
            if (HT != null)
                entity.HiddenTopics.Remove(HT);

            HiddenTopic HTNew = new HiddenTopic();
            HTNew.TopicID = TopicId;
            HTNew.UserID = UserId;
            entity.HiddenTopics.Add(HTNew);
        }


        // For Show Topic 

        public static bool ShowTopics(List<int> TopicIds, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                foreach (var TopicId in TopicIds)
                {
                    HiddenTopic HT = entity.HiddenTopics.Where(h => h.UserID == UserId && h.TopicID == TopicId).FirstOrDefault();
                    if (HT != null)
                        entity.HiddenTopics.Remove(HT);
                }
                entity.SaveChanges();
                return true;
            }
        }


        public static bool ShowSubTopics(List<int> SubTopicIds, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                foreach (var SubTopicId in SubTopicIds)
                {
                    HiddenSubTopic HT = entity.HiddenSubTopics.Where(h => h.UserID == UserId && h.SubTopicID == SubTopicId).FirstOrDefault();
                    if (HT != null)
                        entity.HiddenSubTopics.Remove(HT);
                }
                entity.SaveChanges();
                return true;
            }
        }



        // For Hide SubTopic  

        public static bool HideSubTopics(List<int> SubTopicIds, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                foreach (var SubTopicId in SubTopicIds)
                {
                    HiddenSubTopic HT = entity.HiddenSubTopics.Where(h => h.UserID == UserId && h.SubTopicID == SubTopicId).FirstOrDefault();
                    if (HT != null)
                        entity.HiddenSubTopics.Remove(HT);
                    HiddenSubTopic HTNew = new HiddenSubTopic();
                    HTNew.SubTopicID = SubTopicId;
                    HTNew.UserID = UserId;
                    entity.HiddenSubTopics.Add(HTNew);
                }
                entity.SaveChanges();
                return true;
            }
        }

        // To Get User Specuialties
        public static List<GetUserSpecialtyModel> GetUserSpecialtyList(int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                List<GetUserSpecialtyModel> UserSpecialtyList = new List<GetUserSpecialtyModel>();
                var Result = entity.lib_GetUnsubscribedSpecialties(UserId);

                foreach (var item in Result)
                {
                    GetUserSpecialtyModel Model = new GetUserSpecialtyModel();
                    //Model.isInUse = item.isInUse;
                    Model.SpecialtyId = item.SpecialtyID;
                    Model.SpecialtyName = item.SpecialtyName;
                    UserSpecialtyList.Add(Model);
                }
                return UserSpecialtyList;
            }
        }

        // To Add User Specialty
        public static bool AddUserSpecialty(GetUserSpecialtyModel Model, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                UserSpecialty UsNew = new UserSpecialty();
                UsNew.SpecialtyID = (Int32)Model.SelectedSpecialtyId;
                UsNew.UserID = UserId;
                UsNew.DateAdded = DateTime.Now;
                entity.UserSpecialties.Add(UsNew);
                entity.SaveChanges();
                return true;
            }
        }



        // To Get Saved Citations
        public static List<CitationsModel> GetCitations(int SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetSavedCitationList(UserId, SubTopicId);
                List<CitationsModel> AllCitations = new List<CitationsModel>();
                foreach (var item in Result)
                {
                    CitationsModel Citation = new CitationsModel();
                    Citation.pmid = item.pmid;
                    Citation.status = item.status;
                    Citation.nickname = item.nickname;
                    Citation.comment = item.comment;
                    Citation.commentupdatedate = item.commentupdatedate;
                    Citation.searchid = item.searchid;
                    Citation.expiredate = item.expiredate;
                    Citation.keepdelete = item.keepdelete;
                    AllCitations.Add(Citation);
                }
                return AllCitations;
            }
        }

        // To Get Editors Choice Citations 

        public static List<CitationsModel> GetEditorsChoiceCitations(int SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetEditorsChoiceExtraInfo(UserId, SubTopicId);
                List<CitationsModel> AllCitations = new List<CitationsModel>();
                foreach (var item in Result)
                {
                    CitationsModel Citation = new CitationsModel();
                    Citation.pmid = item.pmid;
                    Citation.status = false;
                    Citation.nickname = item.nickname;
                    Citation.comment = item.comment;
                    Citation.commentupdatedate = item.commentupdatedate;
                    Citation.searchid = null;
                    Citation.expiredate = null;
                    Citation.keepdelete = false;
                    AllCitations.Add(Citation);
                }
                return AllCitations;
            }
        }

        // To Get Seminal Citations Details

        public static List<CitationsModel> GetSeminalCitations(int SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetSemCitExtraInfo(UserId, SubTopicId);
                List<CitationsModel> AllCitations = new List<CitationsModel>();
                foreach (var item in Result)
                {
                    CitationsModel Citation = new CitationsModel();
                    Citation.pmid = item.pmid;
                    Citation.status = false;
                    Citation.nickname = item.nickname;
                    Citation.comment = item.comment;
                    Citation.commentupdatedate = item.commentupdatedate;
                    Citation.searchid = null;
                    Citation.expiredate = null;
                    Citation.keepdelete = false;
                    AllCitations.Add(Citation);
                }
                return AllCitations;
            }
        }

        // To Get Sponsor Citations Details

        public static List<CitationsModel> GetSponsorCitations(int SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetSponCitExtraInfo(UserId, SubTopicId);
                List<CitationsModel> AllCitations = new List<CitationsModel>();
                foreach (var item in Result)
                {
                    CitationsModel Citation = new CitationsModel();
                    Citation.pmid = item.pmid;
                    Citation.status = false;
                    Citation.nickname = item.nickname;
                    Citation.comment = item.comment;
                    Citation.commentupdatedate = item.commentupdatedate;
                    Citation.searchid = null;
                    Citation.expiredate = null;
                    Citation.keepdelete = false;
                    AllCitations.Add(Citation);
                }
                return AllCitations;
            }
        }


        // To Get Citation Details
        public static List<CitationDetailsModel> GetCitationDetails(List<CitationsModel> CitationsPmids, string sort, int UserId, int displayMode, bool isAbstract = false)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                StringBuilder str = new StringBuilder();
                foreach (var item in CitationsPmids)
                {
                    str.Append(item.pmid + ",");
                }

                // For sort order
                short sortorder = 1;
                switch (sort)
                {
                    case "date":
                        sortorder = 1;
                        break;
                    case "authors":
                        sortorder = 2;
                        break;
                    case "title":
                        sortorder = 3;
                        break;
                    case "journal":
                        sortorder = 4;
                        break;
                    default:
                        sortorder = 1;
                        break;
                }

                string PMIDList = str.ToString();
                if (!string.IsNullOrEmpty(PMIDList))
                {
                    PMIDList = PMIDList.Remove(PMIDList.LastIndexOf(','), 1);
                }

                string query = "[ap_DisplayPMID_AJA_Dev] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserID = new SqlParameter("@UserID", UserId);
                SqlParameter Pmids = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayMode = new SqlParameter("@DisplayMode", displayMode);
                SqlParameter SearchSort = new SqlParameter("@SearchSort", sortorder);
                var AllCitationDetails = entity.Database.SqlQuery<CitationDetailsModel>(query, UserID, Pmids, DisplayMode, SearchSort).ToList();
                

                if (isAbstract)
                {
                    try
                    {
                        string query1 = "[ap_DisplayPMID_AJA_Dev_Detailed] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                        SqlParameter UserID1 = new SqlParameter("@UserID", UserId);
                        SqlParameter Pmids1 = new SqlParameter("@PMIDList", PMIDList);
                        SqlParameter DisplayMode1 = new SqlParameter("@DisplayMode", displayMode);
                        SqlParameter SearchSort1 = new SqlParameter("@SearchSort", sortorder);
                        var AllCitationDetailsDetailed = entity.Database.SqlQuery<CitationDetailsModelDetail>(query1, UserID1, Pmids1, DisplayMode1, SearchSort1).ToList();
                        AllCitationDetails[0].AuthorList = "";
                        foreach (var item in AllCitationDetailsDetailed)
                        {
                            AllCitationDetails[0].AuthorList += item.DisplayName + ", ";
                        }
                        AllCitationDetails[0].AuthorList = AllCitationDetails[0].AuthorList.Substring(0, AllCitationDetails[0].AuthorList.LastIndexOf(','));

                        if ((!AllCitationDetails[0].unicodeFixed.HasValue) || AllCitationDetails[0].unicodeFixed == false)
                        {
                            List<string> AbstractArticleTitleNew = GetAbstractWithNoIssue(AllCitationDetails[0].pmid);
                            if (AbstractArticleTitleNew.Count == 2)
                            {
                                int PMID = Convert.ToInt32(AllCitationDetails[0].pmid);
                                var IwideTable = (from iw in entity.iWides where iw.PMID == PMID select iw).FirstOrDefault();

                                if (IwideTable != null)
                                {
                                    AllCitationDetails[0].AbstractText = AbstractArticleTitleNew[0];  //AbstractArticleTitleNew[0] is for Abstract Text and AbstractArticleTitleNew[1] is for Article Title;;
                                    IwideTable.AbstractText = AbstractArticleTitleNew[0];
                                    AllCitationDetails[0].ArticleTitle = AbstractArticleTitleNew[1];
                                    IwideTable.ArticleTitle = AbstractArticleTitleNew[1];
                                    IwideTable.unicodeFixed = true;
                                    entity.Entry(IwideTable).State = EntityState.Modified;
                                }

                                var IwideNewTable = (from iw in entity.iWideNews where iw.PMID == PMID select iw).FirstOrDefault();

                                if (IwideNewTable != null)
                                {
                                    AllCitationDetails[0].AbstractText = AbstractArticleTitleNew[0];
                                    IwideNewTable.AbstractText = AbstractArticleTitleNew[0];

                                    AllCitationDetails[0].ArticleTitle = AbstractArticleTitleNew[1];
                                    IwideNewTable.ArticleTitle = AbstractArticleTitleNew[1];
                                    IwideNewTable.unicodeFixed = true;

                                    entity.Entry(IwideNewTable).State = EntityState.Modified;
                                }
                            }

                        }
                        entity.SaveChanges();
                    }
                    catch (Exception)
                    {
                    }
                }

                List<CitationDetailsModel> NonMedLineCitationsList = AllCitationDetails.Where(u => string.IsNullOrEmpty(u.ArticleTitle)).ToList();
                foreach (var item in NonMedLineCitationsList)
                {
                    using (EditorsEntities entityNM = new EditorsEntities())
                    {
                        CitationDetailsModel NMCitation = NonMedLineCitationsList.Find(u => u.pmid == item.pmid);
                        if (NMCitation != null)
                        {
                            NMCitation = (from nm in entityNM.NonMedlineCitations
                                          where nm.PMID == NMCitation.pmid
                                          select new CitationDetailsModel
                                          {
                                              AbstractText = nm.Abstract,
                                              ArticleTitle = nm.ArticleTitle,
                                              AuthorList = nm.AuthorList,
                                              DisplayDate = nm.DisplayDate,
                                              DisplayNotes = nm.DisplayNotes,
                                              MedlinePgn = nm.MedlinePgn,
                                              MedlineTA = nm.MedlineTA,
                                              StatusDisplay = nm.StatusDisplay,
                                              pmid = nm.PMID
                                          }).FirstOrDefault();

                            if (NMCitation != null)
                            {
                                int Index = AllCitationDetails.FindIndex(u => u.pmid == item.pmid);
                                AllCitationDetails.RemoveAt(Index);
                                AllCitationDetails.Insert(Index, NMCitation);
                            }
                        }
                    }
                }


                return AllCitationDetails;
            }
        }


        public static UserCommentAbstract GetUserComment(int Mid, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = (from uc in entity.UserComments
                              where uc.pmid == Mid && uc.userid == UserId
                              select new UserCommentAbstract
                              {
                                  nickname = uc.nickname,
                                  comment = uc.comment,
                                  updatedate = uc.updatedate
                              }).FirstOrDefault();
                return Result;
            }
        }

        // To Get Abstract Comments EC
        public static List<AbstractCommentsECModel> GetAbstractCommentsEC(int MID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_GetAbstractCommentsEC20] @PMID";
                SqlParameter PMID = new SqlParameter("@PMID", MID);
                var Result = entity.Database.SqlQuery<AbstractCommentsECModel>(query, PMID).ToList();
                return Result;
            }
        }

        public static CommentContext GetCommentContext(int TopicId, int ThreadId, int PMID, int CommentId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_GetCommentContext] @TopicId,@ThreadId,@PMID,@CommentId,@EditorIsAuthor OUT,@MultipleEditors OUT,@Editors  OUT,@Authors  OUT";

                var parameters = new[] 
                { 
                    new SqlParameter("@TopicId", TopicId),
                    new SqlParameter("@ThreadId", ThreadId),
                    new SqlParameter("@PMID", PMID),
                    new SqlParameter("@CommentId", CommentId),
                    new SqlParameter("@EditorIsAuthor",SqlDbType.Int){ Direction = ParameterDirection.Output } ,
                    new SqlParameter("@MultipleEditors",SqlDbType.Int){ Direction = ParameterDirection.Output } ,
                    new SqlParameter("@Editors", SqlDbType.NVarChar,1042){ Direction = ParameterDirection.Output } ,
                    new SqlParameter("@Authors", SqlDbType.NVarChar,1042){ Direction = ParameterDirection.Output }      
                };
                int EditorIsAuthor;
                int MultipleEditors;
                var ResRelatedCitations = entity.Database.SqlQuery<RelatedCitatins>(query, parameters).ToList();
                EditorsDetails editorDetails = new EditorsDetails();
                EditorIsAuthor = (Int32)parameters[4].Value;
                MultipleEditors = (Int32)parameters[5].Value;
                if (EditorIsAuthor == 0)
                    editorDetails.EditorIsAuthor = false;
                else
                    editorDetails.EditorIsAuthor = true;
                if (MultipleEditors == 0)
                    editorDetails.MultipleEditors = false;
                else
                    editorDetails.MultipleEditors = true;
                editorDetails.Editors = parameters[6].Value.ToString();
                editorDetails.Authors = parameters[7].Value.ToString();

                CommentContext Result = new CommentContext();
                Result.RelatedCitations = ResRelatedCitations;
                Result.EditorsDetails = editorDetails;

                return Result;
            }
        }

        // To Get PMIDS for EditorChoice
        public static List<PmidClass> GetEditorsChoicePMids(int SubTopicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_GetEditorsChoiceCitations] @SubTopicID";
                SqlParameter p_SubTopicId = new SqlParameter("@SubTopicID", SubTopicId);
                var PMIDs = entity.Database.SqlQuery<PmidClass>(query, p_SubTopicId).ToList();
                return PMIDs;
            }
        }

        // To Get PMIDS for SeminalCitation
        public static List<PmidClass> GetSeminalPMids(int SubTopicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_GetSeminalCitations] @SubTopicID";
                SqlParameter p_SubTopicId = new SqlParameter("@SubTopicID", SubTopicId);
                var PMIDs = entity.Database.SqlQuery<PmidClass>(query, p_SubTopicId).ToList();
                return PMIDs;
            }
        }

        // To Get PMIDS for Spponsor Citation
        public static List<PmidClass> GetSponsorPMids(int SubTopicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_GetSponsorCitations] @SubTopicID";
                SqlParameter p_SubTopicId = new SqlParameter("@SubTopicID", SubTopicId);
                var PMIDs = entity.Database.SqlQuery<PmidClass>(query, p_SubTopicId).ToList();
                return PMIDs;
            }
        }

        public static List<SelectListItem> GetUserSubTopics(int TopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetUserSubTopics(UserId, TopicId).ToList();
                var Result1 = Result.Select(s => new SelectListItem
                {
                    Text = s.SubTopicName,
                    Value = s.SubTopicID.ToString()
                }).ToList();
                return Result1;
            }
        }

        // Copy Citation
        public static int CopyCitation(int MID, string SubTopicId, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                string query = "[lib_CopyUserCitation] @pmid,@SubTopicID,@userid,@SpecialtyID  OUT";
                var parameters = new[] 
                { 
                    new SqlParameter("@pmid", MID),
                    new SqlParameter("@SubTopicID", SubTopicId),
                    new SqlParameter("@userid", UserId),                    
                    new SqlParameter("@SpecialtyID",SqlDbType.Int){ Direction = ParameterDirection.Output }
                };
                var ResRelatedCitations = entity.Database.SqlQuery<RelatedCitatins>(query, parameters).ToList();
                int SpecialtyId;
                SpecialtyId = (Int32)parameters[3].Value;
                return SpecialtyId;
            }
        }

        public static bool Annotate(MyLibraryModel Model, int pmid, int UserId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                UserComment UpdateComment = (from u in entity.UserComments where u.userid == UserId && u.pmid == pmid select u).FirstOrDefault();
                if (UpdateComment == null)
                {
                    UserComment NewUserComment = new UserComment();
                    NewUserComment.pmid = pmid;
                    NewUserComment.userid = UserId;
                    NewUserComment.nickname = Model.UserComment.nickname;
                    NewUserComment.comment = Model.UserComment.comment;
                    NewUserComment.updatedate = DateTime.Now;
                    NewUserComment.createdate = DateTime.Now;
                    entity.UserComments.Add(NewUserComment);
                }
                else
                {
                    UpdateComment.userid = UserId;
                    UpdateComment.nickname = Model.UserComment.nickname;
                    UpdateComment.comment = Model.UserComment.comment;
                    UpdateComment.updatedate = DateTime.Now;
                    entity.Entry(UpdateComment).State = EntityState.Modified;
                }
                entity.SaveChanges();
                return true;
            }
        }

        // To Delete UserCitation
        public static bool DeleteCitation(int fid, int mid, int userid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                UserCitation UC = entity.UserCitations.Where(c => c.UserID == userid && c.PMID == mid && c.SubTopicID == fid).FirstOrDefault();
                if (UC != null)
                {
                    UC.Deleted = true;
                    entity.Entry(UC).State = EntityState.Modified;
                    entity.SaveChanges();
                }
                return true;
            }
        }

        // To Get ACR Documents in Mylibrary
        public static List<AcrdocumentsMyLibrary> getAcrDocumentsList(int fid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var ACRDocList = entity.doc_in_subtopic_find(null, fid, null);

                List<AcrdocumentsMyLibrary> DocList = new List<AcrdocumentsMyLibrary>();
                foreach (var item in ACRDocList)
                {
                    AcrdocumentsMyLibrary doc = new AcrdocumentsMyLibrary();
                    doc.doc_id = item.doc_id;
                    doc.doc_nm = item.doc_nm;
                    doc.doc_clicks_count = item.doc_clicks_count;
                    doc.Id = item.id;
                    doc.subtopic_id = item.subtopic_id;
                    doc.subtopic_nm = item.subtopic_nm;
                    doc.doc_source = item.doc_source;
                    DocList.Add(doc);
                }

                return DocList;
            }
        }
        //// To check UserHas SPocsor Folder and retrive the values
        //public static int CheckForUserSponsorFolder(int SpocorFolderId, int UserId)
        //{
        //    using (EditorsEntities entity = new EditorsEntities())
        //    {
        //        var UserSposorFolder = (from us in entity.UserHasSponsorFolders
        //                                where us.SponsorFolderId == SpocorFolderId && us.UserId == UserId
        //                                select us).FirstOrDefault();
        //        if (UserSposorFolder == null)
        //        {
        //            return SpocorFolderId;
        //        }
        //        else
        //        {
        //            return 0;
        //        }
        //    }
        //}

        // To Add Sposor folder Id
        //public static bool AddSponsorFolder(int sfid, int userid)
        //{
        //    using (EditorsEntities entity = new EditorsEntities())
        //    {

        //        var CheckForUserHas = (from us in entity.UserHasSponsorFolders
        //                               where us.UserId == userid && us.SponsorFolderId == sfid
        //                               select us).FirstOrDefault();

        //        if (CheckForUserHas != null)
        //        {
        //            return false;
        //        }

        //        var CheckSposorFolderExists = (from s in entity.SponsorFolders
        //                                       where s.id == sfid
        //                                       select s).FirstOrDefault();
        //        if (CheckSposorFolderExists == null)
        //        {
        //            return false;
        //        }



        //        string query = "[lib_CreateSponsorFolderSFE] @UserID,@UserSpecialty,@SponsorFolderID,@TopicFolderID  OUT";
        //        var parameters = new[] 
        //        { 
        //            new SqlParameter("@UserID", userid),
        //            new SqlParameter("@UserSpecialty", 1),
        //            new SqlParameter("@SponsorFolderID", sfid),                    
        //            new SqlParameter("@TopicFolderID",SqlDbType.Int){ Direction = ParameterDirection.Output }
        //        };
        //        var AddSponsorFolderResult = entity.Database.SqlQuery<AddSponsorFolderTemp>(query, parameters).FirstOrDefault();

        //        int TopicFolderID;
        //        TopicFolderID = (Int32)parameters[0].Value;


        //        string query1 = "[lib_GetDefaultSubTopic] @UserID,@TopicID,@SubTopicID  OUT";
        //        var parameters1 = new[] 
        //        { 
        //            new SqlParameter("@UserID", userid),
        //            new SqlParameter("@TopicID", TopicFolderID),                                    
        //            new SqlParameter("@SubTopicID",SqlDbType.Int){ Direction = ParameterDirection.Output }
        //        };
        //        var GetSubTopicResult = entity.Database.SqlQuery<AddSponsorFolderTemp>(query1, parameters1).ToList();

        //        int SubTopicId = (Int32)parameters1[0].Value;

        //        // 
        //        if (CheckSposorFolderExists.FolderName == "EUSA")
        //        {
        //            //SearchBL.ManageQuery Model = new SearchBL.ManageQuery();
        //            //Model.SearchId = 0;
        //            //Model.Name="Caphosol(EUSA)";
        //            //Model.Autosearch = true;
        //            //Model.resultFolder2 = 2182;
        //            //Model.ShelfLife = "7";
        //            //Model.Description = "";
        //            //Model.KeepDelete = 0;
        //            //Model.tab

        //            //if (!string.IsNullOrEmpty(Collection["ddlUserSubTopic"]))
        //            //    Model.resultFolder2 = Convert.ToInt32(Collection["ddlUserSubTopic"]);
        //            //TempData["SavedQueryDet"] = SearchBL.UpdateSearchQuery(Model);


        //        }


        //        //   <!--- Create the Auto Query --->
        //        //<!--- we need a search ID no matter what for the update code below --->

        //        UserHasSponsorFolder NewSposorFolder = new UserHasSponsorFolder();
        //        NewSposorFolder.AutoQueryId = 0;
        //        NewSposorFolder.createtime = DateTime.Now;
        //        NewSposorFolder.SponsorFolderId = sfid;
        //        NewSposorFolder.UserFolderId = Convert.ToInt32(SubTopicId);
        //        NewSposorFolder.UserId = userid;

        //        entity.UserHasSponsorFolders.Add(NewSposorFolder);
        //        entity.SaveChanges();
        //        return true;
        //    }
        //}

        // To Get Genes
        public static List<GeneMyLibrary> GetGenesMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetGenesForCitation(PMID);
                List<GeneMyLibrary> ResultMain = new List<GeneMyLibrary>();
                foreach (var item in Result)
                {
                    GeneMyLibrary Gene = new GeneMyLibrary();
                    Gene.GeneId = item.GeneID;
                    Gene.Name = item.name;
                    ResultMain.Add(Gene);
                }
                return ResultMain;
            }
        }

        // Get GenesForThread

        public static List<GeneMyLibrary> GetGenesForThreadMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetGenesForThread(PMID);
                List<GeneMyLibrary> ResultMain = new List<GeneMyLibrary>();
                foreach (var item in Result)
                {
                    GeneMyLibrary Gene = new GeneMyLibrary();
                    Gene.GeneId = item.GeneID;
                    Gene.Name = item.name;
                    ResultMain.Add(Gene);
                }
                return ResultMain;
            }
        }


        // To Get GenesEditor
        public static List<GeneMyLibrary> GetGenesEditorMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetGenesForEditorComments(PMID);
                List<GeneMyLibrary> ResultMain = new List<GeneMyLibrary>();
                foreach (var item in Result)
                {
                    GeneMyLibrary Gene = new GeneMyLibrary();
                    Gene.GeneId = item.GeneID;
                    Gene.Name = item.name;
                    ResultMain.Add(Gene);
                }
                return ResultMain;
            }
        }


        // Get Tests 
        public static List<TestMyLibrary> GetTestsMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetTestsForCitation(PMID);
                List<TestMyLibrary> ResultMain = new List<TestMyLibrary>();
                foreach (var item in Result)
                {
                    TestMyLibrary Test = new TestMyLibrary();
                    Test.TestID = item.TestID;
                    Test.Name = item.Name;
                    ResultMain.Add(Test);
                }
                return ResultMain;
            }
        }

        // Get Tests Thread
        public static List<TestMyLibrary> GetTestsForThreadMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetTestsForThread(PMID);
                List<TestMyLibrary> ResultMain = new List<TestMyLibrary>();
                foreach (var item in Result)
                {
                    TestMyLibrary Test = new TestMyLibrary();
                    Test.TestID = item.TestID;
                    Test.Name = item.Name;
                    ResultMain.Add(Test);
                }
                return ResultMain;
            }
        }

        // Get Tests Editor
        public static List<TestMyLibrary> GetTestsEditorMyLibrary(int PMID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var Result = entity.lib_GetTestsForEditorComments(PMID);
                List<TestMyLibrary> ResultMain = new List<TestMyLibrary>();
                foreach (var item in Result)
                {
                    TestMyLibrary Test = new TestMyLibrary();
                    Test.TestID = item.TestID;
                    Test.Name = item.Name;
                    ResultMain.Add(Test);
                }
                return ResultMain;
            }
        }

        public static bool UpdateACRDocClickCount(int Id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc Result = (from ad in entity.docs
                              where
                                  ad.id == Id
                              select ad).FirstOrDefault();
                if (Result != null)
                {
                    Result.clicks_count++;
                    entity.Entry(Result).State = EntityState.Modified;
                    entity.SaveChanges();
                }
                return true;
            }
        }


        public static List<string> GetAbstractWithNoIssue(int? pmid)
        {
            try
            {
                string myurl = "http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid + "&report=xml";
                XmlDocument doc1 = new XmlDocument();
                using (var wc = new System.Net.WebClient())
                {
                    wc.Encoding = System.Text.Encoding.UTF8;
                    wc.Headers["Method"] = "GET";
                    wc.Headers["Accept"] = "application/xml";
                    wc.Headers["charset"] = "utf-8";
                    var response1 = wc.DownloadString(myurl);
                    var document = XDocument.Load(myurl);
                    string TestString = document.Root.Value;
                    doc1.LoadXml(TestString);
                    XmlNodeList xnList = doc1.SelectNodes("/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText");
                    StringBuilder AbstractBuilder = new StringBuilder();
                    foreach (XmlNode xn in xnList)
                    {
                        if (xn.Attributes["Label"] != null)
                        {
                            AbstractBuilder.Append(xn.Attributes["Label"].InnerText + " : ");
                        }
                        AbstractBuilder.Append(xn.InnerText + " ");
                    }

                    string ArticleTitle = "";
                    XmlNodeList xnListArticleTitle = doc1.SelectNodes("/PubmedArticle/MedlineCitation/Article/ArticleTitle");
                    foreach (XmlNode xn in xnListArticleTitle)
                    {
                        ArticleTitle = xn.InnerText;
                    }

                    List<string> AbstractArticleTitle = new List<string>();
                    AbstractArticleTitle.Add(AbstractBuilder.ToString());
                    AbstractArticleTitle.Add(ArticleTitle);
                    wc.Dispose();
                    return AbstractArticleTitle;
                }
            }
            catch (Exception)
            {
                return new List<string>();
            }
        }

    }
}
