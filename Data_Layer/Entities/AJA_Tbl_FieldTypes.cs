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
    
    public partial class AJA_tbl_FieldTypes
    {
        public AJA_tbl_FieldTypes()
        {
            this.AJA_tbl_UserFields = new HashSet<AJA_tbl_UserFields>();
        }
    
        public int TypeID { get; set; }
        public string TypeName { get; set; }
        public Nullable<int> UpdatedBy { get; set; }
        public Nullable<System.DateTime> UpdatedDate { get; set; }
    
        public virtual ICollection<AJA_tbl_UserFields> AJA_tbl_UserFields { get; set; }
    }
}
