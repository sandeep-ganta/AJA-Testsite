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
    
    public partial class GenesArticle
    {
        public GenesArticle()
        {
            this.ArticlesAuthors = new HashSet<ArticlesAuthor>();
        }
    
        public long GeneID { get; set; }
        public int ArticleID { get; set; }
        public string ArticleTitle { get; set; }
        public int Year { get; set; }
    
        public virtual ICollection<ArticlesAuthor> ArticlesAuthors { get; set; }
        public virtual Gene Gene { get; set; }
    }
}
