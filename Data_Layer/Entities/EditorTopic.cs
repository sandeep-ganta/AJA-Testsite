//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace DAL.Entities
{
    using System;
    using System.Collections.Generic;
    
    public partial class EditorTopic
    {
        public EditorTopic()
        {
            this.SubTopicEditorRefs = new HashSet<SubTopicEditorRef>();
        }
    
        public int EditorID { get; set; }
        public int TopicID { get; set; }
        public Nullable<System.DateTime> StartDate { get; set; }
        public Nullable<System.DateTime> RetireDate { get; set; }
    
        public virtual ICollection<SubTopicEditorRef> SubTopicEditorRefs { get; set; }
    }
}
