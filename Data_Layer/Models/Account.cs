#region Namespaces

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using MVC4Grid;
using MVC4Grid.GridAttributes;

#endregion

namespace DAL.Models
{
    #region RegisterModel

    public class RegisterModel
    {
        public int UserID { get; set; }

        [Required]
        [Display(Name = "User Name")]
        [Remote("CheckUserNameInuse", "User", ErrorMessage = "UserName InUse Try another !")]
        public string UserName { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "{0} must be at least {2} characters long.", MinimumLength = 6)]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Re-enter Password")]
        [System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Did not match with Password field.")]
        public string ConfirmPassword { get; set; }

        [Required]
        [Display(Name = "First Name")]
        public string FirstName { get; set; }

        [Required]
        [Display(Name = "Last Name")]
        public string LastName { get; set; }

        [Required(ErrorMessage = "Enter Postal Code")]
        [Display(Name = "Postal Code")]
        //[StringLength(5)]
        //[RegularExpression(@"\d{5}(-\d{4})?", ErrorMessage = " Invalid Zip Code")]
        public string postalcode { get; set; }

        [Required]
        [Remote("EmailTaken", "User", ErrorMessage = "EmailId already Taken !.")]
        [Display(Name = "Email")]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string Email { get; set; }

        [Required]
        public string Profession { get; set; }

        [Required]
        [Display(Name = "Title")]
        public string UserTitle { get; set; }

        [Required]
        [Display(Name = "Country")]
        public string CountryID { get; set; }
        public List<SelectListItem> CountryList { get; set; }

        [Required]
        [Display(Name = "Specialty")]
        public int SpecialityID { get; set; }
        public List<SelectListItem> SpecialtiesList { get; set; }

        public string Speciality { get; set; }

        [Required]
        [Display(Name = "Type of Practices")]
        public string PracticeID { get; set; }
        public List<SelectListItem> PracticeList { get; set; }

        //[Required]
        //[RegularExpression (@"^(\d{4})$",ErrorMessage"Invalid Entry !")]
        [RegularExpression(@"^(\d{4})$", ErrorMessage = " Invalid Year")]
        [Display(Name = "Graduation Year")]
        public string GraduationYr { get; set; }

        [Required]
        [Display(Name = "I agree to the terms and conditions")]
        public bool IsTermsAccepted { get; set; }

        public bool Isendemail { get; set; }
        public bool Isasemail { get; set; }

        [Required]
        public virtual IEnumerable<Roles> Roles { get; set; }

        public bool Isactivate { get; set; }

        public string Title { get; set; }
        public string val { get; set; }

        public RegisterModel UpdateDetails()
        {
            UserBL.CreatingUser(this);
            return this;
        }

        public IEnumerable<RegisterModel> GetTitles()
        {
            return new List<RegisterModel>
                            {
                                new RegisterModel() {val = "n/a", Title = "N/A"},
                                new RegisterModel() {val = "MD", Title = "M.D."},
                                new RegisterModel() {val = "DO", Title = "D.O."},
                                new RegisterModel() {val = "PhD", Title = "Ph.D."},
                                new RegisterModel() {val = "DSci", Title = "D.Sc."},
                                new RegisterModel() {val = "RN", Title = "R.N."},
                                new RegisterModel() {val = "Mr", Title = "Mr."},
                                new RegisterModel() {val = "Mrs", Title = "Mrs."},
                                new RegisterModel() {val = "Ms", Title = "Ms."}
                            };
        }

        public IEnumerable<RegisterModel> GetProfession()
        {
            return new List<RegisterModel>
                            {
                                new RegisterModel() {val = "Physician", Title = "Physician"},
                                new RegisterModel() {val = "Physical Therapist", Title = "Physical Therapist"},
                                new RegisterModel() {val = "Occupational Therapist", Title = "Occupational Therapist"},
                                new RegisterModel() {val = "Registered Nurse", Title = "Registered Nurse"},
                                new RegisterModel() {val = "Medical Equipment/Supplies/Services Industry", Title = "Medical Equipment/Supplies/Services Industry"},
                                new RegisterModel() {val = "Physicist", Title = "Physicist"},
                                new RegisterModel() {val = "Other", Title = "Other"}
                            };
        }

    }

    #endregion

    #region UserProfileModel class

    public class MyProfileModel
    {
        public int UserID { get; set; }

        [Required]
        [Display(Name = "User Name")]
        public string UserName { get; set; }

        [Required]
        //[StringLength(100, ErrorMessage = "{0} must be at least {1} characters long.", MinimumLength = 1)]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Re-enter Password")]
        [System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Did not match with Password field.")]
        public string ConfirmPassword { get; set; }

        [Required]
        [Display(Name = "First name")]
        public string FirstName { get; set; }

        [Required]
        [Display(Name = "Last name")]
        public string LastName { get; set; }

        [Required(ErrorMessage = "Enter Postal Code")]
        [Display(Name = "Zip/Postal Code")]
        //[StringLength(5)]
        //[RegularExpression(@"\d{5}(-\d{4})?", ErrorMessage = " Invalid Zip Code")]
        public string postalcode { get; set; }

        [Required]
        [Display(Name = "Email")]
        [Remote("CheckDuplicateEmail", "User", AdditionalFields = "UserID", ErrorMessage = "EmailId Already InUse.")]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string EmailID { get; set; }

        [Required]
        public string Profession { get; set; }

        [Required]
        [Display(Name = "Title")]
        public string UserTitle { get; set; }

        public string Title { get; set; }

        [Required]
        [Display(Name = "Country")]
        public string CountryID { get; set; }
        public List<SelectListItem> CountryList { get; set; }

        [Required]
        [Display(Name = "Specialty")]
        public string SpecialityID { get; set; }
        public List<SelectListItem> SpecialtiesList { get; set; }

        public string Speciality { get; set; }

        [Required]
        [Display(Name = "Type of Practices")]
        public string PracticeID { get; set; }
        public List<SelectListItem> PracticeList { get; set; }

        [Required]
        [RegularExpression(@"^(\d{4})$", ErrorMessage = " Invalid Year ")]
        [Display(Name = "Graduation Year")]
        public string GraduationYr { get; set; }

        public bool Isendemail { get; set; }
        public bool Isasemail { get; set; }


        [Required]
        public virtual IEnumerable<Roles> Roles { get; set; }

        public bool Isactivate { get; set; }

        public string val { get; set; }

        [Display(Name = "Remember me")]
        public bool RememberMe { get; set; }

        public bool IsPersistentCookie
        {
            get
            {
                return RememberMe;
            }
        }



        public IEnumerable<MyProfileModel> GetTitles()
        {
            return new List<MyProfileModel>
                            {
                                new MyProfileModel() {val = "n/a", Title = "N/A"},
                                new MyProfileModel() {val = "MD", Title = "M.D."},
                                new MyProfileModel() {val = "DO", Title = "D.O."},
                                new MyProfileModel() {val = "PhD", Title = "Ph.D."},
                                new MyProfileModel() {val = "DSci", Title = "D.Sc."},
                                new MyProfileModel() {val = "RN", Title = "R.N."},
                                new MyProfileModel() {val = "Mr", Title = "Mr."},
                                new MyProfileModel() {val = "Mrs", Title = "Mrs."},
                                new MyProfileModel() {val = "Ms", Title = "Ms."}
                            };
        }


        public IEnumerable<MyProfileModel> GetProfession()
        {
            return new List<MyProfileModel>
                            {
                                new MyProfileModel() {val = "Physician", Title = "Physician"},
                                new MyProfileModel() {val = "Physical Therapist", Title = "Physical Therapist"},
                                new MyProfileModel() {val = "Occupational Therapist", Title = "Occupational Therapist"},
                                new MyProfileModel() {val = "Registered Nurse", Title = "Registered Nurse"},
                                new MyProfileModel() {val = "Medical Equipment/Supplies/Services Industry", Title = "Medical Equipment/Supplies/Services Industry"},
                                new MyProfileModel() {val = "Physicist", Title = "Physicist"},
                                new MyProfileModel() {val = "Other", Title = "Other"}
                            };
        }
    }

    #endregion

    #region Login Model
    public class LoginModel
    {
        [Required]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        [Display(Name = "Email ID", Prompt = "Email ID")]
        public string EmailID { get; set; }

        [Required]
        // [StringLength(50, MinimumLength = 3, ErrorMessage = "Minimum 6 Characters.")]
        [Display(Name = "User Name")]
        public string LoginID { get; set; }


        [Required]
        // [StringLength(50, MinimumLength = 6, ErrorMessage = "Minimum 6 Characters")]
        [DataType(DataType.Password)]
        [Display(Name = "Password", Prompt = "Password")]

        public string Password { get; set; }

        [Display(Name = "Remember me")]
        public bool RememberMe { get; set; }


        public bool IsPersistentCookie
        {
            get
            {
                return RememberMe;
            }
        }

        /// <summary>
        /// from isvalid property we get the userdetails from database
        /// </summary>
        private AJA_tbl_Users DBuser { get; set; }

        /// <summary>
        /// Check the user is valid or not from data base;
        /// </summary>
        public bool IsValid
        {
            get
            {
                DBuser = ValidateUser();
                if (DBuser != null)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }


        public string Roles
        {
            get
            {
                if (DBuser != null)
                {
                    List<string> roles = DBuser.AJA_tbl_Roles.Select(i => i.RoleName).ToList();

                    return string.Join(",", roles.ToArray());
                }
                else
                    return string.Empty;

            }
        }


        public string UserName
        {
            get
            {
                if (DBuser != null)
                    return DBuser.UserName;
                else
                    return string.Empty;
            }
        }

        public int UserID
        {
            get
            {
                if (DBuser != null)
                    return DBuser.UserID;
                else
                    return 0;
            }
        }

        #region Methods
        //Check Is user is valid or not;
        private AJA_tbl_Users ValidateUser()
        {
            AJA_tbl_Users user = UserBL.GetUser(LoginID, Password);

            return user;
        }

        #endregion

    }

    #endregion

    /// <summary>
    /// Model class used for admin user registration 
    /// </summary>    
    public class UserDetails
    {
        public UserDetails()
        {

        }


        public int UserID { get; set; }

        [Required]
        [Remote("CheckUserNameInuse", "User", AdditionalFields = "UserID", ErrorMessage = "UserName Already InUse.")]
        [Display(Name = "User Name")]
        [StringLength(50, ErrorMessage = "Max Length 50 characters")]
        public string UserName { get; set; }

        [Required]
        [Display(Name = "First Name")]
        [StringLength(50, ErrorMessage = "Max Length 50 characters")]
        public string FirstName { get; set; }

        [Required]
        [Display(Name = "Last Name")]
        [StringLength(50, ErrorMessage = "Max Length 50 characters")]
        public string LastName { get; set; }


        [Required]
        [EmailAddress(ErrorMessage = "Invalid Email Address.")]
        [Remote("CheckDuplicateEmail", "User", AdditionalFields = "UserID", ErrorMessage = "EmailId Already InUse.")]
        [Display(Name = "Email ID")]
        public string EmailID { get; set; }

        [Display(Name = "Send Email")]
        public bool Iseditoremailsend { get; set; }

        [Display(Name = "Country")]
        public int? CountryID { get; set; }
        public List<SelectListItem> CountryList { get; set; }

        [Required]
        [Display(Name = "Specialty")]
        public int? SpecialityID { get; set; }
        public List<SelectListItem> SpecialtiesList { get; set; }

        //[Required]
        [Display(Name = "Type of Practices")]
        public int? PracticeID { get; set; }
        public List<SelectListItem> PracticeList { get; set; }


        [Display(Name = "Graduation Year")]
        [RegularExpression(@"^(\d{4})$", ErrorMessage = " Invalid Year ")]
        public int? GraduationYr { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [StringLength(150, ErrorMessage = "Max Length 150 characters")]
        public string Password { get; set; }


        [System.Web.Mvc.Compare("Password", ErrorMessage = "Passwords do not match.")]
        [DataType(DataType.Password)]
        [Display(Name = "Re-enter Password")]
        public string ConfirmPassword { get; set; }


        [Display(Name = "Postal Code")]
        [StringLength(50, ErrorMessage = "Max Length 50 characters")]
        public string postalcode { get; set; }

        public string Speciality { get; set; }

        public string Profession { get; set; }

        public string Title { get; set; }

        public bool isSelected { get; set; }

        public string val { get; set; }

        public bool? Isendemail { get; set; }

        public bool? Isasemail { get; set; }

        [Display(Name = "Administrator")]
        public bool IsAdmin { get; set; }

        [Display(Name = "AJA User")]
        public bool IsAJAUser { get; set; }

        public bool NotNulIsendmail
        {
            get
            {
                return Isendemail == true;
            }
            set
            {
                Isendemail = value;
            }
        }


        public bool NotNullIsSavedQueryemail
        {
            get
            {
                return Isasemail == true;
            }
            set
            {
                Isasemail = value;
            }
        }


        public Nullable<int> Activated { get; set; }

        public Nullable<System.DateTime> CreatedDate
        {
            get;
            set;
        }


        public virtual IEnumerable<Roles> Roles { get; set; }

        #region Public Methods
        public UserDetails UpdateDetails()
        {
            UserBL.CreateOrUpdateUser(this);
            //need to change
            return this;
        }

        public IEnumerable<UserDetails> GetTitles()
        {
            return new List<UserDetails>
                            {
                                new UserDetails() {val = "n/a", Title = "N/A"},
                                new UserDetails() {val = "MD", Title = "M.D."},
                                new UserDetails() {val = "DO", Title = "D.O."},
                                new UserDetails() {val = "PhD", Title = "Ph.D."},
                                new UserDetails() {val = "DSci", Title = "D.Sc."},
                                new UserDetails() {val = "RN", Title = "R.N."},
                                new UserDetails() {val = "Mr", Title = "Mr."},
                                new UserDetails() {val = "Mrs", Title = "Mrs."},
                                new UserDetails() {val = "Ms", Title = "Ms."}
                            };
        }


        public IEnumerable<UserDetails> GetProfession()
        {
            return new List<UserDetails>
                            {
                                new UserDetails() {val = "Physician", Title = "Physician"},
                                new UserDetails() {val = "Physical Therapist", Title = "Physical Therapist"},
                                new UserDetails() {val = "Occupational Therapist", Title = "Occupational Therapist"},
                                new UserDetails() {val = "Registered Nurse", Title = "Registered Nurse"},
                                new UserDetails() {val = "Medical Equipment/Supplies/Services Industry", Title = "Medical Equipment/Supplies/Services Industry"},
                                new UserDetails() {val = "Physicist", Title = "Physicist"},
                                new UserDetails() {val = "Other", Title = "Other"}
                                
                            };
        }
        #endregion

        #region Private Methods

        private UserDetails SetUserDetails()
        {
            UserDetails userDet = new UserDetails();

            userDet.UserID = this.UserID;
            userDet.EmailID = this.EmailID;
            userDet.Password = this.Password;
            userDet.Roles = this.Roles;
            userDet.Activated = this.Activated;
            userDet.Roles = this.Roles;
            return userDet;
        }



        private UserDetails GetUserDetailsFromDb(int userid)
        {
            UserDetails userDet = UserBL.GetUserwithID(userid);

            userDet.UserID = this.UserID;
            userDet.EmailID = this.EmailID;
            userDet.Password = this.Password;
            userDet.Roles = this.Roles;
            userDet.Activated = this.Activated;
            userDet.Roles = this.Roles;
            return userDet;
        }
        #endregion
    }

    public class Roles
    {
        public int RoleID { get; set; }
        [Display(Name = "Role")]
        public string RoleName { get; set; }
        public bool IsSelected { get; set; }
    }

    #region unused
    //public class FieldOption
    //{
    //    public long OptionID { get; set; }
    //    public string OptionText { get; set; }
    //    public string OptionValue { get; set; }
    //    public int OptionType { get; set; }
    //}

    //public class UserFieldModel
    //{
    //    public UserFieldModel()
    //    { }
    //    public UserFieldModel(int fieldid)
    //    {

    //    }

    //    public Int32 FieldID { get; set; }
    //    public string Role { get; set; }
    //    public int RoleID { get; set; }

    //    [Required]
    //    [StringLength(50, MinimumLength = 2, ErrorMessage = "Minimum 2 Characters.")]
    //    [Remote("CheckDuplicateFieldName", "User", AdditionalFields = "FieldID", ErrorMessage = "Field Name Already Exists.")]
    //    [Display(Name = "Field Name")]
    //    public string FieldName { get; set; }

    //    [Display(Name = "Field Type")]
    //    public string FieldType { get; set; }

    //    public int TypeID { get; set; }

    //    public Int32 ShowOrder { get; set; }

    //    [Display(Name = "Is Mandatory")]
    //    public bool IsMandatory { get; set; }

    //    [Display(Name = "Is Active")]
    //    public bool IsActive { get; set; }
    //    public DateTime CreatedDate { get; set; }

    //    public bool Isactivate { get; set; }

    //    public IEnumerable<System.Web.Mvc.SelectListItem> Roles
    //    {
    //        get
    //        {
    //            return UserBL.GetRoles().AsEnumerable().Select(p => new System.Web.Mvc.SelectListItem { Text = p.RoleName, Value = p.RoleID.ToString() });
    //        }
    //    }

    //    public IEnumerable<System.Web.Mvc.SelectListItem> FieldTypes
    //    {
    //        get
    //        {
    //            return UserBL.GetFieldTypes().AsEnumerable().Select(p => new System.Web.Mvc.SelectListItem { Text = p.TypeName.ToString(), Value = p.TypeID.ToString() });
    //        }
    //    }

    //    public List<FieldOption> Options
    //    {
    //        get
    //        {
    //            return UserBL.GetOptionsForField(this.FieldID);
    //        }
    //    }
    //}

    //public class UserField
    //{
    //    public int FieldID { get; set; }
    //    public int RoleID { get; set; }
    //    public string FieldName { get; set; }
    //    public bool IsActive { get; set; }
    //    public bool IsMandatory { get; set; }
    //    public int TypeID { get; set; }
    //    public List<FieldOption> Options { get; set; }
    //}

    #endregion

    public class ChangePassword
    {
        [HiddenInput]
        public string EmailId { get; set; }

        [Display(Name = "Current Password")]
        [Remote("CheckPassword", "User", AdditionalFields = "EmailId", ErrorMessage = "Wrong Password.")]
        [Required]
        [DataType(DataType.Password)]
        public string CurrentPassword { get; set; }

        [Display(Name = "New Password")]
        [Required]
        //[StringLength(50, MinimumLength = 6, ErrorMessage = "Minimum 6 Characters.")]
        [DataType(DataType.Password)]
        public string NewPassword { get; set; }

        [Display(Name = "Confirm New Password")]
        [Required]
        [System.Web.Mvc.Compare("NewPassword", ErrorMessage = "Passwords you typed do not match.")]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set; }
    }

    public class ForgotPassword
    {
        [Required]
        [Remote("CheckEmailExists", "User", ErrorMessage = "EmailId/Username does not match")]
        [Display(Name = "Email ID/User Name", Prompt = "Email ID/User Name")]
        public string EmailId { get; set; }
    }

    public class ManageTopics
    {
        public ManageTopics()
        {

        }

        public int TopicID { get; set; }

        [Required]
        // [Remote("CheckDuplicateTopic", "Admin", AdditionalFields = "TopicID,SpecialityID", ErrorMessage = "Topic Name already exists for this speciality !")]
        [Display(Name = "Topic Name")]
        [StringLength(50,ErrorMessage="Max Length 50 characters")]
        public string TopicName { get; set; }

        public int? Type { get; set; }

        public int? SubTopicID { get; set; }

        [Required]
        [Display(Name = "Sub-Topic Name")]
        public string SubTopicname { get; set; }
        public string SpecialityName { get; set; }

        [Display(Name = "Specialty")]
        public int SpecialityID { get; set; }
        public DateTime CreatedDate { get; set; }

        public virtual IEnumerable<SubTopic> SubTopicsList { get; set; }
        public List<SelectListItem> SpecialityList { get; set; }
        public List<SelectListItem> TopicsList { get; set; }

    }

    /// <summary>
    /// Model for Edition
    /// </summary>
    [GridPaging(NoofRows = 10)]
    [GridSearching]
    [GridSorting]
    public class Editionsmodel
    {
        public Editionsmodel()
        {

        }

        [Key]
        [HiddenInput]
        public int EditionId { get; set; }

        [Required]
        [Display(Name = "SpecialtyName")]
        public string SpecialtyName { get; set; }

        [HiddenInput]
        public int SpecialtyID { get; set; }
        
        [GridSearching(Searching = false)]
        [GridSorting(Default = true,isAscending=false)]
        [Required]
        [Display(Name = "PubDate")]
        [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
        public DateTime PubDate { get; set; }

        public List<SelectListItem> Specialtylist { get; set; }
    }

    /// <summary>
    /// Model for Edition Topics
    /// </summary>
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class TopicModels
    {
        public TopicModels()
        { }

        [HiddenInput]
        public int EditionID { get; set; }
        [HiddenInput]
        [Key]
        public int SubTopicID { get; set; }
        [HiddenInput]
        public int ThreadId { get; set; }
        [HiddenInput]
        public int EditorID { get; set; }
        [HiddenInput]
        public int TopicID { get; set; }
        [HiddenInput]
        public int CommenAuthorId { get; set; }
        [HiddenInput]
        public int EditorTopicsId { get; set; }

        [HiddenInput]
        [GridSearching(Searching = false)]
        public DateTime OriginalPubDate { get; set; }

        [Required]
        [HiddenInput]
        [Display(Name = "TopicName")]
        public string TopicName { get; set; }

        [GridSorting(Default = true)]
        public string SubTopicName { get; set; }

        [HiddenInput]
        public List<SelectListItem> TopicList { get; set; }
        [HiddenInput]
        public List<SelectListItem> SubTopicList { get; set; }
    }

    /// <summary>
    /// Model for Articleselections
    /// </summary>
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class ArticleselectionsModel
    {
        public ArticleselectionsModel()
        { }

        [Key]
        [HiddenInput]
        public string ThreadId { get; set; }

        [GridSorting(Default = true)]
        [Required]
        [Display(Name = "PMID")]
        [RegularExpression(@"^-?[0-9]{0,9}$", ErrorMessage = "Enter till 9 digit number")]
        [Remote("CheckPMIDcitations", "Admin", ErrorMessage = "PMID doesnot exists!")]
        public string PMID { get; set; }

        [HiddenInput]
        [GridSearching(Searching = false)]
        public int Sortorder { get; set; }
    }

    /// <summary>
    /// Model for Editorial Comments
    /// </summary>
    public class EditorialCommentsModel
    {
        public EditorialCommentsModel()
        { }

        public long GeneID { get; set; }
        public int AuthorID { get; set; }

        [Display(Name = "Genes:")]
        public string Name { get; set; }

        [Required]
        [Display(Name = "Authors")]
        public string AuthorName { get; set; }

        public int Sortorder { get; set; }
        public int CommentID { get; set; }
        public string Authors { get; set; }
        [Required]
        [Display(Name = "Comment")]
        public string Comment { get; set; }

        public List<SelectListItem> Genelist { get; set; }
        public List<SelectListItem> Authorslist { get; set; }
        public List<FieldAuthors> NewAuthorValues { get; set; }
        public List<GeneValues> NewGeneValues { get; set; }
        public List<CommentAuthor> Authordetails { get; set; }
        public List<Gene> Genedetails { get; set; }
    }

    public class FieldAuthors
    {
        public int AuthorID { get; set; }
        public string AuthorText { get; set; }
        public string AuthorValue { get; set; }
    }

    public class GeneValues
    {
        public int GeneId { get; set; }
        public string GeneText { get; set; }
        public string GeneValue { get; set; }
    }

    /// <summary>
    /// Model for SubTopics
    /// </summary>

    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class SubTopics
    {
        public SubTopics()
        {

        }

        [HiddenInput]
        public int TopicID { get; set; }

        [HiddenInput]
        public int? Type { get; set; }

        [HiddenInput]
        [Key]
        public int SubTopicID { get; set; }

        [Required]
        [GridSorting(Default = true)]
        [Display(Name = "Sub-Topic Name")]
        [StringLength(100, ErrorMessage = "Max Length 100 characters")]
        public string SubTopicname { get; set; }

        [HiddenInput]
        [Display(Name = "Topic Name")]
        public string TopicName { get; set; }

        [HiddenInput]
        public string SpecialityName { get; set; }

        [HiddenInput]
        public int SpecialityID { get; set; }

        [HiddenInput]
        public DateTime CreatedDate { get; set; }

        public virtual IEnumerable<SubTopic> SubTopicsList { get; set; }

        public List<SelectListItem> TopicsList { get; set; }

        public List<SelectListItem> SpecialityList { get; set; }

    }

    /// <summary>
    /// Model for Monthly Editors Choice
    /// </summary>
    public class Monthlyeditorsmail
    {
        public Monthlyeditorsmail()
        { }
        [Required]
        public int editionid { get; set; }
        public string editionname { get; set; }
        [Required]
        public string RecentEditions { get; set; }
        public List<SelectListItem> RecentEditionsList { get; set; }
        [Required]
        [RegularExpression(@"^[a-zA-Z,. ]+$", ErrorMessage = "Numerics are not accepted in Sendername")]
        public string sendername { get; set; }
        [Required]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string senderaddres { get; set; }
        [Required]
        public string subject { get; set; }
        public bool Ishtml { get; set; }
        public string Headingtemp { get; set; }
        public List<SelectListItem> HeadingTemplist { get; set; }
        public string _message { get; set; }
        public string _htmlmesage { get; set; }
        public int pmid { get; set; }
        public string OrgFolderName { get; set; }
        public int ThreadID { get; set; }
        public string SpecialtyName { get; set; }
        public int SpecialtyID { get; set; }
        public DateTime PubDate { get; set; }
        public string ArticleTitle { get; set; }
        //[Required]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string testEmail { get; set; }
        public string testname { get; set; }
        public int SelectedCategoryIds { get; set; }
        public List<Usermailsdetails> Usermaildetails { get; set; }
        public List<Usermailsdetails> Usersentmails { get; set; }
        public List<Usermailsdetails> Userexcludedmaildetails { get; set; }
        public List<Usermailsdetails> BackUsermaildetails { get; set; }
        public IEnumerable<SelectListItem> excludemaildetails { get; set; }
        public string Editorschoicedata { get; set; }
        public string Status { get; set; }
        public bool checkallrecipients { get; set; }
        public string Excludedusers { get; set; }
        public string Othersinspecialty { get; set; }
        public string Allotherusers { get; set; }
    }

    /// <summary>
    /// This class is Related to Monthly EditorsMail to Get ArticleTitles& Authorslist with Pmid
    /// </summary>
    public class MonthlyeditorsPmids
    {
        public string ArticleTitle { get; set; }
        public string AuthorList { get; set; }
        public string Displaydate { get; set; }
    }
    /// <summary>
    /// This Class is Related to Monthlyeditorsmail to GET Userdetails with userid
    /// </summary>
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class Usermailsdetails
    {
        [HiddenInput]
        public int id { get; set; }

        [Display(Name = "Email")]
        public string email { get; set; }

        [GridSorting(Default = true)]
        [HiddenInput]
        public string Name { get; set; }

        [Key]
        [Display(Name = "Name")]
        public string FirstName { get; set; }

        [Display(Name = "Status")]
        public string Status { get; set; }

        [HiddenInput]
        public string LastName { get; set; }

        [HiddenInput]
        public int InSpecialty { get; set; }

        [GridSearching(Searching = false)]
        [HiddenInput]
        public bool? IsSendmail { get; set; }

        [HiddenInput]
        public string emailwithname { get; set; }
    }

    public class UserSpecialityName
    {
        public int SpecialtyID { get; set; }
        public string SpecialtyName { get; set; }
        public int userID { get; set; }
    }


    /// <summary>
    ///   //Model for Test in Personalized Medicine
    /// </summary>
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class TestGene
    {
        [HiddenInput]
        public int TestID { get; set; }
        [HiddenInput]
        public int GeneId { get; set; }
        [HiddenInput]
        public string TestFullname { get; set; }
        [HiddenInput]

        public string Name { get; set; }
        [HiddenInput]
        [Required]
        [StringLength(100, ErrorMessage = "Max Length 100 characters")]
        public string TestName { get; set; }
        [HiddenInput]
        [Required]
        public string Summary { get; set; }
        [HiddenInput]
        public string Genename { get; set; }
        [HiddenInput]
        public string NewTest { get; set; }
        [HiddenInput]
        public int Specialtyid { get; set; }
        [HiddenInput]
        public int Topicid { get; set; }
        [HiddenInput]
        public int SubTopicid { get; set; }
        [HiddenInput]
        public string SpecialtyName { get; set; }
        [HiddenInput]
        public string Topicname { get; set; }
        [HiddenInput]
        public string Subtopicname { get; set; }
        [HiddenInput]
        public int Authorid { get; set; }
        [HiddenInput]
        public string Authorsgene { get; set; }
        [Key]
        [HiddenInput]
        public int commentid { get; set; }

        [GridSorting(Default = true)]
        [DisplayFormat(HtmlEncode = true)]
        public string testComment { get; set; }

        [HiddenInput]
        [GridSearching(Searching = false)]
        [DataType(DataType.DateTime)]
        public DateTime testcomnt_date { get; set; }
        [HiddenInput]
        public int Pmid { get; set; }
        [HiddenInput]
        public string Attachedgene { get; set; }
        [HiddenInput]
        [RegularExpression(@"^[0-9]+$", ErrorMessage = "Enter only Numbers")]
        public string Editorscommentid { get; set; }
        [HiddenInput]
        public string Editorschoicecomment { get; set; }
        [HiddenInput]
        public int Threadid { get; set; }
        [HiddenInput]
        [GridSearching(Searching = false)]
        public bool checktestcitation { get; set; }
        [HiddenInput]
        [GridSearching(Searching = false)]
        public bool CheckEditorcomment { get; set; }
        [HiddenInput]
        public int Editorpmid { get; set; }
        [HiddenInput]
        public int[] Newpmid { get; set; }
        [HiddenInput]
        public string Displaydate { get; set; }
        [HiddenInput]
        public string Testcitations { get; set; }
        [HiddenInput]
        public string ArticleTitle { get; set; }
        [HiddenInput]
        public string AuthorList { get; set; }

        // [RegularExpression(@"^(http(s)?://)?([\w-]+\.)+[\w-]+(/[\w- ;,./?%&=]*)?$", ErrorMessage = "Enter only URL")]
        [HiddenInput]
        [StringLength(400, ErrorMessage = "Max Length 400 characters")]
        public string Sclink { get; set; }
        [HiddenInput]
        public int Linkid { get; set; }


        public List<SelectListItem> Testnameslist { get; set; }
        public List<SelectListItem> TestGeneslist { get; set; }

        public List<SelectListItem> Specialtylist { get; set; }
        public List<SelectListItem> Topiclist { get; set; }
        public List<SelectListItem> Subtopiclist { get; set; }
        public List<SelectListItem> CommentAuthorslist { get; set; }

        public List<TestGene> Testcomentdetails { get; set; }
        public List<FieldGeneComments> NewTestComments { get; set; }

        public List<TestGene> TestPmidCitations { get; set; }
        public List<TestGene> GetArticles { get; set; }

        public List<TestGene> GetAddedEditorComment { get; set; }
        public List<TestGene> GetAddedArticle { get; set; }
        public List<TestGene> Getcheckedcomments { get; set; }
        public List<TestGene> Test_citationslist { get; set; }
        public List<TestGene> AttachedGeneslist { get; set; }
        public List<TestGene> GenesAttachedtoTest { get; set; }
        public List<Sclink> Getlinks { get; set; }
    }

    /// <summary>
    ///   //Model for Gene in Personalized Medicine
    /// </summary>
    [GridPaging(NoofRows = 5)]
    [GridSearching]
    [GridSorting]
    public class PersonalizedGene
    {
        [HiddenInput]
        public int GeneID { get; set; }
        [HiddenInput]
        public string Name { get; set; }
        [HiddenInput]
        public string Symbol { get; set; }
        [HiddenInput]
        public string FullName { get; set; }
        [HiddenInput]
        public string Summary { get; set; }

        // [RegularExpression(@"^[0-9]+$", ErrorMessage = "Enter only Numbers")]
        [HiddenInput]
        public string Newgene { get; set; }

        // [RegularExpression(@"^[0-9]+$", ErrorMessage = "Enter only Numbers")]
        [HiddenInput]
        public string Genecitations { get; set; }
        [HiddenInput]
        public string ArticleTitle { get; set; }
        [HiddenInput]
        public int Pmid { get; set; }
        [HiddenInput]
        public int[] Newpmid { get; set; }
        [HiddenInput]
        public string Displaydate { get; set; }
        [HiddenInput]
        public string AuthorList { get; set; }

        [HiddenInput]
        public int Specialtyid { get; set; }
        [HiddenInput]
        public int Topicid { get; set; }
        [HiddenInput]
        public int SubTopicid { get; set; }
        [HiddenInput]
        public string SpecialtyName { get; set; }
        [HiddenInput]
        public string Topicname { get; set; }
        [HiddenInput]
        public string Subtopicname { get; set; }
        [HiddenInput]
        public int Authorid { get; set; }
        [HiddenInput]
        public string Authorsgene { get; set; }

        [Key]
        [HiddenInput]
        public int commentid { get; set; }

        [GridSorting(Default = true)]
        [DisplayFormat(HtmlEncode = true)]
        public string geneComment { get; set; }

        [HiddenInput]
        [GridSearching(Searching = false)]
        [DataType(DataType.DateTime)]
        public DateTime genecomnt_date { get; set; }

        [HiddenInput]
        [RegularExpression(@"^[0-9]+$", ErrorMessage = "Enter only Numbers")]
        public string Editorscommentid { get; set; }
        [HiddenInput]
        public string Editorschoicecomment { get; set; }
        [HiddenInput]
        public int Threadid { get; set; }
        [HiddenInput]
        [GridSearching(Searching = false)]
        public bool checkgenecitation { get; set; }
        [HiddenInput]
        [GridSearching(Searching = false)]
        public bool CheckEditorcomment { get; set; }
        [HiddenInput]
        public int Editorpmid { get; set; }

        //  [RegularExpression(@"^(http(s)?://)?([\w-]+\.)+[\w-]+(/[\w- ;,./?%&=]*)?$", ErrorMessage = "Enter only Url")]
        [HiddenInput]
        [StringLength(4000, ErrorMessage = "Max Length 4000 characters")]
        public string Sclink { get; set; }
        [HiddenInput]
        public int Linkid { get; set; }

        public List<SelectListItem> Specialtylist { get; set; }
        public List<SelectListItem> Topiclist { get; set; }
        public List<SelectListItem> Subtopiclist { get; set; }
        public List<SelectListItem> CommentAuthorslist { get; set; }
        public List<SelectListItem> Genenameslist { get; set; }
        public List<PersonalizedGene> Gene_citationslist { get; set; }
        public List<FieldGeneComments> NewGeneComments { get; set; }
        public List<PersonalizedGene> Genecomentdetails { get; set; }
        public List<PersonalizedGene> GenePmidCitations { get; set; }
        public List<PersonalizedGene> GetArticles { get; set; }

        public List<PersonalizedGene> GetAddedEditorComment { get; set; }
        public List<PersonalizedGene> GetAddedArticle { get; set; }

        public List<PersonalizedGene> Getcheckedcomments { get; set; }
        public List<Sclink> Getlinks { get; set; }
    }

    /// <summary>
    /// This Class is Related to PersonalizedGene to GET Spcialty,Topic,Subtopic
    /// </summary>
    public class FieldGeneComments
    {
        public int SpecialtyId { get; set; }
        public int Topicid { get; set; }
        public int SubTopicid { get; set; }
        public string GeneText { get; set; }
        public string GeneValue { get; set; }
    }

    /// <summary>
    ///  This Class is Related to PersonalizedGene & PersonalizedTest to GET ScreenRESOURCELinks
    /// </summary>
    public class Sclink
    {
        public int testid { get; set; }
        public int geneid { get; set; }
        public int Linkid { get; set; }
        public string sclink { get; set; }
    }

    public class PersonalizedMedicine_User
    {
        public int GeneId { get; set; }
        public int TestId { get; set; }
        public string aliasid { get; set; }
        public string GeneName { get; set; }
        public string GeneAlias { get; set; }
        public string GeneTest { get; set; }

        public string Name { get; set; }
        public string Symbol { get; set; }
        public string FullName { get; set; }
        public string Summary { get; set; }
        public int CommentID { get; set; }
        public string Commnet { get; set; }
        public DateTime CommnetDate { get; set; }
        public string Author { get; set; }
        public string Attachedgene { get; set; }

        public int EditorCommentID { get; set; }
        public string EditorCommnet { get; set; }
        public int EditorCommentDate { get; set; }
        public string EditorCommentMonth { get; set; }
        public string EditorCommentAuthor { get; set; }

        public int Pmid { get; set; }
        public string ArticleTitle { get; set; }
        public string Displaydate { get; set; }
        public string AuthorList { get; set; }

        public string SpecialtyName { get; set; }
        public string Topicname { get; set; }
        public string Subtopicname { get; set; }

        public bool checkgene { get; set; }
        public bool checktest { get; set; }
        public Dictionary<int, string> Aliases { get; set; }

        public List<SelectListItem> Geneslist { get; set; }
        public List<SelectListItem> GeneAliaslist { get; set; }
        public List<SelectListItem> GeneTestlist { get; set; }
        public List<SelectListItem> GetGenesrelatedtoTest { get; set; }

        public List<PersonalizedMedicine_User> Gene_citationslist { get; set; }
        public List<PersonalizedMedicine_User> GetGeneComments { get; set; }
        public List<PersonalizedMedicine_User> GetRelatededitorscomments { get; set; }
        public List<PersonalizedMedicine_User> GetGenealiases { get; set; }
        public List<Sclink> GetGeneslinks { get; set; }
        public List<PersonalizedMedicinespecialties> Getspecialties { get; set; }

        public List<PersonalizedMedicine_User> Test_citationslist { get; set; }
        public List<PersonalizedMedicine_User> GetTestComments { get; set; }
        public List<PersonalizedMedicine_User> GetRelatededitorsTestcomments { get; set; }
        public List<Sclink> GetTestslinks { get; set; }
        public List<PersonalizedMedicinespecialties> GetTestspecialties { get; set; }
        public List<clinicalsciencelinks> Getclinicalinks { get; set; }
        public List<PersonalizedMedicine_User> GetAttachedGenealias { get; set; }

    }

    public class PersonalizedMedicinespecialties
    {
        public string SpecialtyName { get; set; }
        public string Topicname { get; set; }
        public string Subtopicname { get; set; }
    }

    public class clinicalsciencelinks
    {
        public int gene { get; set; }
        public int ArticleId { get; set; }
        public string ArticleTitle { get; set; }
        public int Year { get; set; }
        public string AuthorList { get; set; }
    }


    public class AboutROEditors
    {
        public int TopicId { get; set; }
        public string TopicName { get; set; }
        public int Specialtyid { get; set; }
        public string showspecialty { get; set; }
        public string SpecialtyName { get; set; }
        public int Editorid { get; set; }
        public int id { get; set; }
        public string name { get; set; }
        public string affiliations { get; set; }
        public List<SelectListItem> Specialtylist { get; set; }
        public List<AboutROEditors> GetRoTopics { get; set; }
        public List<AboutROEditors> GetRoTopicEditors { get; set; }
        public List<AboutROEditors> GetRoAtlargeeditors { get; set; }
    }

}