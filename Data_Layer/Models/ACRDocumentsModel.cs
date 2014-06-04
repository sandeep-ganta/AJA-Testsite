using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using MVC4Grid;
using MVC4Grid.GridAttributes;

namespace DAL.Models
{
    [GridPaging(NoofRows = 10)]
    [GridSearching]
    [GridSorting]
    public class ACRDocumentsModel
    {
        [Key]
        [GridSorting(Default = true)]
        public int Id { get; set; }

        [Required]
        [Display(Name = "Document Source")]
        [StringLength(512, ErrorMessage = "Max Length 512 characters")]
        public string Source { get; set; }
        [Required]
        [Display(Name = "Document Name")]
        [DisplayFormat(HtmlEncode = true)]
        [StringLength(256, ErrorMessage = "Max Length 256 characters")]
        public string Name { get; set; }

        [GridSearching(Searching = false)]
        [Required]
        [DataType(DataType.DateTime)]
        [Display(Name = "Last Updated At")]
        [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
        public DateTime LastUpdatedDate { get; set; }
        [HiddenInput]
        public string IsAutoUpdate { get; set; }

        [GridSearching(Searching = false)]
        [Display(Name = "Auto Update")]
        [HiddenInput]
        public bool chkIsAutpUpdate { get; set; }

        [Display(Name = "Clicks Count")]
        [RegularExpression(@"^-?[0-9]{0,9}$", ErrorMessage = "Enter till 9 digit number")]
        public int ClicksCount { get; set; }
    }

    [GridPaging(NoofRows = 10)]
    [GridSearching]
    [GridSorting]
    public class ACRDocumentRelationshipModel
    {
        [HiddenInput]
        [Key]
        [GridSorting(Default = true)]
        public int RelationId { get; set; }

        [HiddenInput]
        public int SubTopicId { get; set; }

        [Display(Name = "Doc Id", Order = 3)]
        public int DocId { get; set; }

        [Required]
        [Display(Name = "Topic Name", Order = 1)]
        public string TopicName { get; set; }

        [Display(Name = "Subtopic Name", Order = 2)]
        public string SubTopicName { get; set; }

        [HiddenInput]
        public string DocSource { get; set; }

        [Display(Name = "Doc Name", Order = 4)]
        public string DocName { get; set; }

        [HiddenInput]
        public List<SelectListItem> TopicList { get; set; }

        [HiddenInput]
        public List<SelectListItem> SubTopicList { get; set; }

    }
}
