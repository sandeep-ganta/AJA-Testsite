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
    
    public partial class SubTopicEditorRef
    {
        public int EditionID { get; set; }
        public int ThreadID { get; set; }
        public int EditorID { get; set; }
        public int TopicID { get; set; }
        public int Seniority { get; set; }
    
        public virtual Edition Edition { get; set; }
        public virtual EditorialThread EditorialThread { get; set; }
        public virtual EditorTopic EditorTopic { get; set; }
    }
}
