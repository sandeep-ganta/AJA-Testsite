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
    
    public partial class GenesLink
    {
        public long GeneID { get; set; }
        public int LinkID { get; set; }
        public string Link { get; set; }
    
        public virtual Gene Gene { get; set; }
    }
}
