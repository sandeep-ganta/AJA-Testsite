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
using MVC4Grid.GridExtensions;
using MVC4Grid;

namespace DAL
{
    public class ACRDocumentsBL
    {       

        public static MVC4Grid.Grid.GridResult GetALLACRDocuments(MVC4Grid.Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var res = (from a in entity.docs
                           select new ACRDocumentsModel
                           {
                               Id = a.id,
                               Source = a.source,
                               Name = a.nm,
                               LastUpdatedDate =  a.last_updated_dt,
                               IsAutoUpdate = a.auto_upd,
                               ClicksCount = a.clicks_count
                           }).GridFilterBy(Filter);
                return res;
            }
        }


        public static bool AddDocument(ACRDocumentsModel ModelAddDocument)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc newDoc = new doc();
                newDoc.source = ModelAddDocument.Source;
                newDoc.nm = ModelAddDocument.Name;
                newDoc.last_updated_dt = ModelAddDocument.LastUpdatedDate;
                newDoc.clicks_count = ModelAddDocument.ClicksCount;
                newDoc.auto_upd = ModelAddDocument.IsAutoUpdate;
                entity.docs.Add(newDoc);
                entity.SaveChanges();
            }
            return true;
        }

        public static ACRDocumentsModel GetDocumentWithId(int docId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var document = (from a in entity.docs
                                where a.id == docId
                                select new ACRDocumentsModel
                                {
                                    Id = a.id,
                                    Source = a.source,
                                    Name = a.nm,
                                    LastUpdatedDate = a.last_updated_dt,
                                    IsAutoUpdate = a.auto_upd,
                                    ClicksCount = a.clicks_count
                                }).Single();
                return document;
            }
        }

        // for update ACR Document

        public static bool EditDocument(ACRDocumentsModel EditDocumentModel)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc editDoc = entity.docs.Find(EditDocumentModel.Id);
                if (editDoc != null)
                {
                    editDoc.source = EditDocumentModel.Source;
                    editDoc.nm = EditDocumentModel.Name;
                    editDoc.last_updated_dt = EditDocumentModel.LastUpdatedDate;
                    editDoc.clicks_count = EditDocumentModel.ClicksCount;
                    editDoc.auto_upd = EditDocumentModel.IsAutoUpdate;
                    entity.Entry(editDoc).State = EntityState.Modified;
                    entity.SaveChanges();
                }

                return true;
            }
        }

        // For delete ACR Document

        public static bool DeleteACRDocument(int docId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc DeleteDoc = entity.docs.Find(docId);
                if (DeleteDoc != null)
                {
                    entity.docs.Remove(DeleteDoc);
                    entity.SaveChanges();
                }
                return true;
            }
        }

        // Get Topics

        public static ACRDocumentRelationshipModel GetTopics(int doc_id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                ACRDocumentRelationshipModel acrdr = new ACRDocumentRelationshipModel();

                acrdr.TopicList = (from c in entity.CommentAuthors.AsEnumerable()
                                   join e in entity.EditorTopics on c.id equals e.EditorID
                                   join t in entity.Topics on e.TopicID equals t.TopicID
                                   join s in entity.Specialties on t.SpecialtyID equals s.SpecialtyID
                                   where t.SpecialtyID == 1 && c.affiliations != ""
                                   orderby t.TopicName
                                   select new
                                   {
                                       t.TopicID,
                                       t.TopicName
                                   }).Distinct().Select(x => new SelectListItem
                                   {
                                       Value = x.TopicID.ToString(),
                                       Text = x.TopicName
                                   }).ToList();

                acrdr.DocId = doc_id;
                return acrdr;
            }
        }

        // Get All ACR Document Relations based on Doc Id

        public static MVC4Grid.Grid.GridResult GetALLACRDocumentRelations(int DocId, MVC4Grid.Grid.GridFilter Filter)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var ACRDocumentRelations = (from r in entity.doc_in_subtopic
                                            join d in entity.docs on r.doc_id equals d.id
                                            join s in entity.SubTopics on r.subtopic_id equals s.SubTopicID
                                            join t in entity.Topics on s.TopicID equals t.TopicID
                                            where r.doc_id == DocId
                                            select new ACRDocumentRelationshipModel
                                            {
                                                DocId = r.doc_id,
                                                DocName = d.nm,
                                                DocSource = d.source,
                                                RelationId = r.id,
                                                SubTopicId = r.subtopic_id,
                                                SubTopicName = s.SubTopicName,
                                                TopicName = t.TopicName
                                            }).GridFilterBy(Filter);
                return ACRDocumentRelations;
            }
        }

        // To add ACRDocument Relation

        public static bool AddACRDocumentRelation(ACRDocumentRelationshipModel NewRelation, string subtopicId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc ACRDocument = entity.docs.Find(NewRelation.DocId);
                if (ACRDocument != null)
                {
                    doc_in_subtopic newRelationDB = new doc_in_subtopic();
                    newRelationDB.doc_id = NewRelation.DocId;
                    newRelationDB.subtopic_id = Convert.ToInt32(subtopicId);
                    entity.doc_in_subtopic.Add(newRelationDB);
                    entity.SaveChanges();
                    return true;
                }
                else
                    return false;
            }
        }


        // To get ACR Document Relation Subtopics dropdwn list

        public static List<SelectListItem> GetACRDocsSubTopics(int? id)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var query = (from SubTopics in entity.SubTopics.AsEnumerable()
                             where SubTopics.TopicID == id && SubTopics.UserID == null
                             orderby SubTopics.SubTopicName
                             select new SelectListItem
                             {
                                 Value = SubTopics.SubTopicID.ToString(),
                                 Text = SubTopics.SubTopicName
                             }).ToList();
                return query;
            }
        }

        // For Delete ACR Document Relation
        public static bool DeleteACRDocumentRelation(int RelId)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                doc_in_subtopic docRelation = entity.doc_in_subtopic.Find(RelId);
                if (docRelation != null)
                {
                    entity.doc_in_subtopic.Remove(docRelation);
                    entity.SaveChanges();
                }
                return true;
            }
        }
    }
}