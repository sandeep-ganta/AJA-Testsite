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
    
    public partial class lib_GetSearchCitationList_Result
    {
        public int pmid { get; set; }
        public int status { get; set; }
        public string nickname { get; set; }
        public string comment { get; set; }
        public Nullable<System.DateTime> commentupdatedate { get; set; }
        public int searchid { get; set; }
        public System.DateTime expiredate { get; set; }
        public bool keepdelete { get; set; }
    }
}
