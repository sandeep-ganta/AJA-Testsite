#region using namespaces
using System;
using System.Web;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using DAL;
using DAL.Entities;
using DAL.Models;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using MVC4Grid;
using MVC4Grid.GridAttributes;
using MVC4Grid.GridExtensions;
using System.ComponentModel.DataAnnotations;
using System.Data;

#endregion

namespace DAL
{
    public class UserBL
    {
        #region GetRoles

        public static IEnumerable<Roles> GetRoles()
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return (from r in entity.AJA_tbl_Roles select new Roles { RoleID = r.RoleID, RoleName = r.RoleName, IsSelected = false }).ToList();
            }
        }
        public static List<string> GetRoles(string EmailId)
        {
            List<string> roles = new List<string>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                roles = (entity.AJA_tbl_Users.FirstOrDefault(i => i.UserName == EmailId).AJA_tbl_Roles).Select(i => i.RoleName).ToList();
            }
            return roles;
        }

        public static List<string> GetRoles(int userid)
        {
            List<string> roles = new List<string>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                roles = entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == userid).AJA_tbl_Roles.Where(i => i.RoleID != 0).Select(i => i.RoleName).ToList();

            }
            return roles;
        }

        #endregion

        public static string GetUserEmailwithId(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == userid).EmailID;
            }
        }

        public static string GetFirstNamewithID(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var name = (from f in entity.AJA_tbl_Users.Where(i => i.UserID == userid) select f.Fname).FirstOrDefault();

                return name;
            }
        }

        public static string GetFullNamewithID(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var name = (from f in entity.AJA_tbl_Users.Where(i => i.UserID == userid && i.Activated == 1) select f.Fname + " " + f.Lname).FirstOrDefault();

                return name;
            }
        }

        public static string GetLastNamewithID(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var Lname = (from f in entity.AJA_tbl_Users.Where(i => i.UserID == userid) select f.Lname).FirstOrDefault();

                return Lname;
            }
        }

        public static string GetTitlewithID(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var Title = (from f in entity.AJA_tbl_Users.Where(i => i.UserID == userid) select f.UserTitle).FirstOrDefault();

                return Title;
            }
        }

        public static string GetUserNamewithId(int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == userid).UserName;
            }
        }


        #region Validate User with Email and password

        public static AJA_tbl_Users GetUser(string LoginId, string Password)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.AJA_tbl_Users.Include("AJA_tbl_Roles").Where(i => (i.EmailID == LoginId || i.UserName == LoginId) && i.Password == Password.Trim() && i.Activated == 1).ToList().FirstOrDefault(i => i.Password.Equals(Password.Trim()));
                //return entity.AJA_tbl_Users.Include("AJA_tbl_Roles").FirstOrDefault(i => (i.EmailID == LoginId || i.UserName == LoginId) && i.Password == Password);
            }
        }
        #endregion

        #region FeildsOptions
        public static IEnumerable<AJA_tbl_FieldOptions> getOptions(int UserFieldID)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.AJA_tbl_FieldOptions.Where(ufo => ufo.UserFieldID == UserFieldID);
            }
        }

        #endregion

        #region Reset Password
        /// <summary>
        /// Reset User Password
        /// </summary>
        /// <param name="ruser"></param>
        /// <returns></returns>
        public static AJA_tbl_Users ResetPassword(string Email, string strkey)
        {
            int id = Convert.ToInt32(Email);
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = (from s in entity.AJA_tbl_Users.Where(i => i.UserID == id && i.Activated == 1) select s).FirstOrDefault(); //entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID ==Convert.ToInt32(Email));
                if (user != null)
                {
                    user.Password = strkey;

                    entity.SaveChanges();
                }
                return user;
            }
        }

        public static AJA_tbl_Users ChangePassword(string Email, string strkey)
        {

            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = (from s in entity.AJA_tbl_Users.Where(i => i.EmailID == Email && i.Activated == 1) select s).FirstOrDefault(); //entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID ==Convert.ToInt32(Email));
                if (user != null)
                {
                    user.Password = strkey;

                    entity.SaveChanges();
                }
                return user;
            }
        }

        public static AJA_tbl_Users GetfrgtPasswordetails(string Email, string strkey)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = entity.AJA_tbl_Users.Where(i => i.EmailID == Email || i.UserName == Email).FirstOrDefault();
                return user;
            }
        }

        public static bool SetNewforgotpassword(string Email, string strkey)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = entity.AJA_tbl_Users.Where(i => i.EmailID == Email).FirstOrDefault();
                if (user != null)
                {
                    user.Password = strkey;
                    entity.SaveChanges();
                }
                return true;
            }
        }
        #endregion

        #region CheckEmailExists
        public static bool CheckEmailExists(string EmailId, int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var obj = entity.AJA_tbl_Users.FirstOrDefault(i => i.EmailID.ToLower() == EmailId.ToLower() && i.Activated != -1);
                if (obj == null)
                    return false;
                else if (obj.UserID == userid)
                    return false;
                else
                    return true;

            }
        }

        public static bool CheckEmailExistsReg(string EmailId)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var obj = entity.AJA_tbl_Users.FirstOrDefault(i => i.EmailID.ToLower() == EmailId.ToLower() && i.Activated != -1);
                if (obj == null)
                    return false;
                else
                    return true;

            }
        }


        public static bool CheckEmailExists(string Value)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var res = entity.AJA_tbl_Users.Any(i => i.EmailID.ToLower() == Value.ToLower() || i.UserName == Value);
                return res;
            }
        }

        #endregion

        #region CreatingUserByAdmin

        public static void CreateOrUpdateUser(UserDetails user)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {

                if (user.UserID != 0)
                {
                    #region Updateuser

                    #region Update/Add LoginTable

                    var loginuser = entity.AJA_tbl_Users.Where(u => u.UserID == user.UserID).FirstOrDefault();
                    if (user.EmailID != null)
                    {
                        loginuser.EmailID = user.EmailID;
                    }
                    if (user.UserName != null)
                    {
                        loginuser.UserName = user.UserName;
                    }
                    if (user.FirstName != null)
                    {
                        loginuser.Fname = user.FirstName;
                    }
                    if (user.LastName != null)
                    {
                        loginuser.Lname = user.LastName;
                    }
                    if (user.CountryID != null)
                    {
                        loginuser.CountryID = user.CountryID;
                    }
                    if (user.Profession != null)
                    {
                        loginuser.profession = user.Profession;
                    }
                    if (user.GraduationYr != null)
                    {
                        loginuser.graduationYear = user.GraduationYr;
                    }
                    if (user.Title != null)
                    {
                        loginuser.UserTitle = user.Title;
                    }
                    if (user.postalcode != null)
                    {
                        loginuser.Pincode = user.postalcode;
                    }
                    if (user.SpecialityID != null)
                    {
                        loginuser.specialtyID = user.SpecialityID;
                    }
                    if (user.PracticeID != null)
                    {
                        loginuser.typePracticeID = user.PracticeID;
                    }
                    if (user.NotNullIsSavedQueryemail != null)
                    {
                        loginuser.IsSavedAqemaisend = user.NotNullIsSavedQueryemail;
                    }
                    if (user.NotNulIsendmail != null)
                    {
                        loginuser.IseditorEmaiSend = user.NotNulIsendmail;
                    }

                    #endregion

                    #region Role ADD/Delete

                    var roles = loginuser.AJA_tbl_Roles;

                    var adminremove = loginuser.AJA_tbl_Roles.Where(r => r.RoleID == 1).FirstOrDefault();
                    var ajaRemove = loginuser.AJA_tbl_Roles.Where(r => r.RoleID == 2).FirstOrDefault();
                    var others = loginuser.AJA_tbl_Roles.Where(r => r.RoleID == 0).FirstOrDefault();//To remove other roles if any other roles added for testing .
                    if (adminremove != null)
                        roles.Remove(adminremove);

                    if (ajaRemove != null)
                        roles.Remove(ajaRemove);

                    if (others != null)
                        roles.Remove(others);

                    if (user.IsAdmin)
                    {
                        AJA_tbl_Roles r4 = entity.AJA_tbl_Roles.Where(ro => ro.RoleID == 1).FirstOrDefault();
                        roles.Add(r4);
                    }

                    if (user.IsAJAUser)
                    {
                        AJA_tbl_Roles r4 = entity.AJA_tbl_Roles.Where(ro => ro.RoleID == 2).FirstOrDefault();
                        roles.Add(r4);
                    }

                    #endregion

                    entity.SaveChanges();


                    #endregion
                }
                else
                {
                    List<AJA_tbl_Roles> userroles = new List<AJA_tbl_Roles>();
                    if (user.IsAdmin == true)
                    {
                        AJA_tbl_Roles Adminrole = entity.AJA_tbl_Roles.Where(i => i.RoleID == 1).FirstOrDefault();
                        userroles.Add(Adminrole);
                    }
                    if (user.IsAJAUser == true)
                    {
                        AJA_tbl_Roles AJAUser = entity.AJA_tbl_Roles.Where(i => i.RoleID == 2).FirstOrDefault();
                        userroles.Add(AJAUser);
                    }

                    #region CreateUser

                    var createLogin = new AJA_tbl_Users
                    {
                        EmailID = user.EmailID,
                        Password = user.Password,
                        UserName = user.UserName,
                        Fname = user.FirstName,
                        Lname = user.LastName,
                        CountryID = user.CountryID,
                        specialtyID = user.SpecialityID,
                        typePracticeID = user.PracticeID,
                        UserTitle = user.Title,
                        profession = user.Profession,
                        graduationYear = user.GraduationYr,
                        Pincode = user.postalcode,
                        IseditorEmaiSend = user.NotNulIsendmail,
                        IsSavedAqemaisend = user.NotNullIsSavedQueryemail,
                        CreatedDate = DateTime.Now,
                        UpdatedBy = 0,
                        Activated = 1,
                        AJA_tbl_Roles = userroles,
                    };
                    entity.AJA_tbl_Users.Add(createLogin);
                    entity.SaveChanges();

                    int newUID = (from s in entity.AJA_tbl_Users.Where(i => i.UserName == user.UserName && i.Activated == 1) select s.UserID).FirstOrDefault();

                    UserSpecialty userspec = new UserSpecialty();
                    userspec.UserID = newUID;
                    userspec.SpecialtyID = Convert.ToInt32(user.SpecialityID);
                    userspec.DateAdded = DateTime.Now;
                    entity.UserSpecialties.Add(userspec);

                    if (user.IsAJAUser == true)
                    {
                        bool IsInuse = (from sp in entity.Specialties.Where(i => i.SpecialtyID == user.SpecialityID) select sp.isInUse).FirstOrDefault();

                        if (IsInuse == false)
                        {
                            Topic createTopic = new Topic();
                            createTopic.UserID = newUID;
                            createTopic.SpecialtyID = Convert.ToInt32(user.SpecialityID);
                            createTopic.TopicName = "Topic";
                            createTopic.createtime = DateTime.Now;
                            createTopic.Type = 2;
                            entity.Topics.Add(createTopic);
                            entity.SaveChanges();

                            int newTopicID = (from s in entity.Topics.Where(i => i.UserID == newUID) select s.TopicID).FirstOrDefault();

                            SubTopic CreatSubTopic = new SubTopic();
                            CreatSubTopic.UserID = newUID;
                            CreatSubTopic.TopicID = newTopicID;
                            CreatSubTopic.SubTopicName = "Subtopic";
                            CreatSubTopic.createtime = DateTime.Now;
                            CreatSubTopic.Type = 2;
                            entity.SubTopics.Add(CreatSubTopic);
                        }
                    }
                    entity.SaveChanges();

                    #endregion
                }

            }

        }
        #endregion

        #region GetNew Users()
        public static UserDetails GetUserwithID(int UserID)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                UserDetails obj = new UserDetails();

                if (UserID == 0)
                {
                    obj.UserID = 0;
                    obj.UserName = "";
                    obj.EmailID = "";
                    obj.FirstName = "";
                    obj.LastName = "";
                    obj.Password = "";
                    obj.Roles = (from r in entity.AJA_tbl_Roles
                                 select new Roles { RoleID = r.RoleID, RoleName = r.RoleName, IsSelected = false }).ToList();

                    obj.CountryList = GetCountriesList();
                    obj.SpecialtiesList = GetSpecialitesList();
                    obj.PracticeList = GetPracticesList();
                    obj.Isendemail = true;
                    obj.Isasemail = true;
                }
                else
                {
                    //obj = (from ln in entity.AJA_tbl_Users.Where(tln => tln.UserID == UserID)
                    //       select new UserDetails
                    //       {
                    //           UserID = ln.UserID,
                    //           UserName = ln.UserName,
                    //           EmailID = ln.EmailID,
                    //           Password = ln.Password,
                    //           Roles = from r in entity.AJA_tbl_Roles
                    //                   join r1 in ln.AJA_tbl_Roles on r.RoleID equals r1.RoleID into r1_join
                    //                   from r2 in r1_join.DefaultIfEmpty()
                    //                   select new Roles { RoleID = r.RoleID, RoleName = r.RoleName, IsSelected = r2.RoleID == null ? false : true },
                    //           FirstName = ln.Fname,
                    //           LastName = ln.Lname,
                    //           postalcode = ln.Pincode,

                    //           Fvalue = from uf in entity.AJA_tbl_UserFields
                    //                    from r5 in entity.AJA_tbl_Roles.Where(rr => rr.RoleID == uf.RoleID)
                    //                    from ufo in uf.AJA_tbl_FieldOptions
                    //                    join b in entity.AJA_tbl_FieldValues on new { ufo.OptionID, ln.UserID } equals new { b.OptionID, b.UserID } into c
                    //                    from d in c.DefaultIfEmpty()
                    //                    orderby uf.ShowOrder
                    //                    select new UserFeildValues { fieldID = uf.UserFieldID, OptionID = ufo.OptionID, typID = uf.TypeID, FieldName = uf.FieldName, FieldValue = string.IsNullOrEmpty(ufo.OptionValue) ? d.Value : ufo.OptionValue, optionText = ufo.OptionText, IsSelected = (d.OptionID == null) ? false : true, cssclass = r5.RoleName.Replace(" ", ""), IsMandatory = uf.IsMandatory }
                    //       }).FirstOrDefault();
                }

                return obj;
            }
        }


        public static UserDetails GetUserwithEmailID(int uid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                UserDetails obj = new UserDetails();
                if (uid != 0)
                {
                    obj = (from ln in entity.AJA_tbl_Users.Where(tln => (tln.UserID == uid) && tln.Activated != -1)
                           select new UserDetails
                           {
                               UserID = ln.UserID,
                               UserName = ln.UserName,
                               EmailID = ln.EmailID,
                               Password = ln.Password,

                               Roles = from r in entity.AJA_tbl_Roles
                                       join r1 in ln.AJA_tbl_Roles on r.RoleID equals r1.RoleID into r1_join
                                       from r2 in r1_join.DefaultIfEmpty()
                                       select new Roles { RoleID = r.RoleID, RoleName = r.RoleName, IsSelected = r2.RoleID == null ? false : true },

                               postalcode = ln.Pincode,
                               IsAdmin = ln.AJA_tbl_Roles.Where(r => r.RoleID == 1).Count() > 0,
                               IsAJAUser = ln.AJA_tbl_Roles.Where(r => r.RoleID == 2).Count() > 0,

                               FirstName = ln.Fname,
                               LastName = ln.Lname,
                               CountryID = ln.CountryID,
                               SpecialityID = ln.specialtyID,
                               PracticeID = ln.typePracticeID,
                               Title = ln.UserTitle,
                               GraduationYr = ln.graduationYear,
                               Profession = ln.profession,
                               Isasemail = ln.IsSavedAqemaisend,
                               Isendemail = ln.IseditorEmaiSend,
                           }).FirstOrDefault();
                }
                else
                {
                    obj.UserID = 0;
                    obj.UserName = "";
                    obj.EmailID = "";
                    obj.FirstName = "";
                    obj.LastName = "";
                    obj.Password = "";
                    obj.Roles = (from r in entity.AJA_tbl_Roles
                                 select new Roles { RoleID = r.RoleID, RoleName = r.RoleName, IsSelected = false }).ToList();

                    obj.CountryList = GetCountriesList();
                    obj.SpecialtiesList = GetSpecialitesList();
                    obj.PracticeList = GetPracticesList();
                    obj.Isendemail = true;
                    obj.Isasemail = true;
                }
                return obj;
            }
        }
        #endregion

        #region GetAllUserDetails

        //public static List<Dictionary<string, string>> GetAllUserDetails()
        //{
        //    List<Dictionary<string, string>> GridUsers = new List<Dictionary<string, string>>();

        //    List<UserdetValues> users = new List<UserdetValues>();
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        List<UserdetValues> feildsobj = (from u in entity.AJA_tbl_Users
        //                                         where u.Activated == 1 && u.UserID != 0
        //                                         select new UserdetValues
        //                                         {
        //                                             FirstName = u.Fname,
        //                                             LastName = u.Lname,
        //                                             UserName = u.UserName,
        //                                             EmailId = u.EmailID,
        //                                             userId = u.UserID,
        //                                             Roles = (from r in u.AJA_tbl_Roles where r.RoleID != 0 select r.RoleName),
        //                                             Title = u.UserTitle,
        //                                             SpecialityID = u.specialtyID,
        //                                             Iseditoremailsend = u.IseditorEmaiSend,
        //                                             CreatedDate = u.CreatedDate
        //                                         }).ToList();
        //        users.AddRange(feildsobj);

        //    }
        //    Dictionary<int?, List<UserdetValues>> AllUsers = users.GroupBy(i => i.userId).ToDictionary(i => i.Key, i => i.ToList());
        //    List<Dictionary<string, object>> uservalues = new List<Dictionary<string, object>>();
        //    List<string> AllDicKeys = new List<string>();
        //    foreach (var user in AllUsers)
        //    {
        //        Dictionary<string, object> dt = new Dictionary<string, object>();
        //        dt.Add("Email", user.Value[0].EmailId);
        //        dt.Add("User Name", user.Value[0].UserName);
        //        dt.Add("First Name", user.Value[0].FirstName);
        //        dt.Add("Last Name", user.Value[0].LastName);
        //        dt.Add("Roles", user.Value[0].RoleName);
        //        dt.Add("Title", user.Value[0].Title);
        //        var spID = user.Value[0].SpecialityID;
        //        var speciality = GetUserSpeciality(spID);
        //        dt.Add("Specialty", speciality);
        //        dt.Add("Send Email", user.Value[0].Iseditoremailsend);
        //        dt.Add("Date Added", user.Value[0].CreatedDate);

        //        AllDicKeys.Add("Email");
        //        AllDicKeys.Add("First Name");
        //        AllDicKeys.Add("Last Name");
        //        AllDicKeys.Add("User Name");
        //        AllDicKeys.Add("Roles");
        //        AllDicKeys.Add("Title");
        //        AllDicKeys.Add("Specialty");
        //        AllDicKeys.Add("Send Email");
        //        AllDicKeys.Add("Date Added");
        //        uservalues.Add(dt);
        //    }

        //    var AllKeys = AllDicKeys.Distinct().ToList();

        //    foreach (var user in uservalues)
        //    {
        //        Dictionary<string, string> GridUser = new Dictionary<string, string>();

        //        foreach (var key in AllKeys)
        //        {
        //            var Value = "-";

        //            if (user.ContainsKey(key))
        //            {
        //                Value = user[key] != null ? user[key].ToString() : "-";
        //            }

        //            GridUser.Add(key, Value);
        //        }

        //        GridUsers.Add(GridUser);
        //    }
        //    return GridUsers;
        //}
        #endregion

        #region GetUserFields
        /// <summary>
        /// Gets all User Fields
        /// </summary>
        /// <returns></returns>
        //public static Grid.GridResult GetUserFields(int take, int skip, string sortexpression, string SortType, string SearchText)
        //{

        //    Grid.GridResult res = new Grid.GridResult();

        //    List<UserFieldModel> lstFields = new List<UserFieldModel>();
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        lstFields = (from f in entity.AJA_tbl_UserFields
        //                     join t in entity.AJA_tbl_FieldTypes on f.TypeID equals t.TypeID
        //                     join r in entity.AJA_tbl_Roles on f.RoleID equals r.RoleID
        //                     select new UserFieldModel
        //                     {
        //                         FieldID = f.UserFieldID,
        //                         FieldName = f.FieldName,
        //                         FieldType = t.TypeName,
        //                         Role = r.RoleName,
        //                         ShowOrder = f.ShowOrder ?? default(int),
        //                         IsMandatory = f.IsMandatory ?? default(bool),
        //                         IsActive = f.IsActive ?? default(bool),
        //                         CreatedDate = f.UpdatedDate ?? default(DateTime)
        //                     }).OrderBy(i => i.ShowOrder).Take(take).Skip(skip).ToList();

        //        res.DataSource = lstFields;
        //        res.Count = entity.AJA_tbl_UserFields.Count();
        //    }

        //    return res;
        //}
        #endregion

        #region GetOptionsForField
        //public static List<FieldOption> GetOptionsForField(int fieldid)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        return (from o in entity.AJA_tbl_FieldOptions
        //                where o.UserFieldID == fieldid
        //                select new FieldOption
        //                {
        //                    OptionID = o.OptionID,
        //                    OptionText = o.OptionText,
        //                    OptionValue = o.OptionValue,
        //                }).ToList();
        //    }

        //    return new List<FieldOption>();
        //}
        //#endregion

        //public static List<AJA_tbl_FieldTypes> GetFieldTypes()
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        return entity.AJA_tbl_FieldTypes.ToList();
        //    }
        //}

        //public static bool DeleteField(int fieldid)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var opts = (from o in entity.AJA_tbl_FieldOptions where o.UserFieldID == fieldid select o).ToList();
        //        foreach (var item in opts)
        //        {
        //            DeleteOption(item.OptionID);
        //        }
        //    }
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var fld = (from f in entity.AJA_tbl_UserFields where f.UserFieldID == fieldid select f).FirstOrDefault();
        //        entity.AJA_tbl_UserFields.Remove(fld);
        //        entity.SaveChanges();
        //        return true;
        //    }
        //}
        //public static UserFieldModel GetField(int fieldid)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        return (from f in entity.AJA_tbl_UserFields
        //                join t in entity.AJA_tbl_FieldTypes on f.TypeID equals t.TypeID
        //                join r in entity.AJA_tbl_Roles on f.RoleID equals r.RoleID
        //                where f.UserFieldID == fieldid
        //                select new UserFieldModel
        //                {
        //                    FieldID = f.UserFieldID,
        //                    FieldName = f.FieldName,
        //                    TypeID = t.TypeID,
        //                    FieldType = t.TypeName,
        //                    RoleID = r.RoleID,
        //                    Role = r.RoleName,
        //                    ShowOrder = f.ShowOrder ?? default(int),
        //                    IsMandatory = f.IsMandatory ?? default(bool),
        //                    IsActive = f.IsActive ?? default(bool),
        //                    CreatedDate = f.UpdatedDate ?? default(DateTime)
        //                }).FirstOrDefault();
        //    }
        //}

        //public static bool SaveNewField(UserField NewField)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var extfield = (from f in entity.AJA_tbl_UserFields where f.FieldName.ToLower().Trim() == NewField.FieldName.ToLower().Trim() select f).FirstOrDefault();
        //        if (extfield == null)
        //        {
        //            AJA_tbl_UserFields newfield = new AJA_tbl_UserFields();
        //            newfield.RoleID = NewField.RoleID;
        //            newfield.FieldName = NewField.FieldName;
        //            newfield.IsActive = NewField.IsActive;
        //            newfield.IsMandatory = NewField.IsMandatory;
        //            newfield.TypeID = NewField.TypeID;
        //            newfield.UpdatedDate = DateTime.Now;
        //            newfield.ShowOrder = (from i in entity.AJA_tbl_UserFields select i.ShowOrder).Max() + 1;
        //            var field = entity.AJA_tbl_UserFields.Add(newfield);
        //            entity.SaveChanges();

        //            if (NewField.TypeID > 2)
        //            {
        //                if (NewField.Options != null)
        //                {
        //                    foreach (var item in NewField.Options)
        //                    {
        //                        AJA_tbl_FieldOptions fldopts = new AJA_tbl_FieldOptions();
        //                        fldopts.UserFieldID = field.UserFieldID;
        //                        fldopts.OptionText = item.OptionText;
        //                        fldopts.OptionValue = item.OptionValue;// != "0" ? item.OptionValue : ((from o in entity.AC_tbl_FieldOptions where o.UserFieldID == field.UserFieldID select o.OptionID).Max() + 1).ToString();        //                        entity.AJA_tbl_FieldOptions.Add(fldopts);
        //                    }

        //                }
        //            }
        //            else
        //            {
        //                FieldOption fo = new FieldOption();
        //                AJA_tbl_FieldOptions fldopts = new AJA_tbl_FieldOptions();
        //                fldopts.UserFieldID = field.UserFieldID;
        //                entity.AJA_tbl_FieldOptions.Add(fldopts);
        //            }
        //            entity.SaveChanges();
        //            return true;
        //        }
        //        else
        //        {
        //            return false;
        //        }
        //    }

        //}

        //public static long SaveOptions(FieldOption option, int fieldid)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        AJA_tbl_FieldOptions fldopts = new AJA_tbl_FieldOptions();
        //        fldopts.UserFieldID = fieldid;
        //        fldopts.OptionText = option.OptionText;
        //        fldopts.OptionValue = option.OptionValue != "0" ? option.OptionValue : ((from o in entity.AJA_tbl_FieldOptions where o.UserFieldID == fieldid select o.OptionID).Max() + 1).ToString();
        //        entity.AJA_tbl_FieldOptions.Add(fldopts);
        //        entity.SaveChanges();
        //        return fldopts.OptionID;
        //    }
        //}

        //public static bool DeleteOption(long optid)
        //{
        //    bool rtn = false;
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var optval = (from v in entity.AJA_tbl_FieldValues where v.OptionID == optid select v).ToList();
        //        foreach (var item in optval)
        //        {
        //            entity.AJA_tbl_FieldValues.Remove(item);
        //            entity.SaveChanges();
        //        }

        //        var fldopts = (from o in entity.AJA_tbl_FieldOptions where o.OptionID == optid select o).FirstOrDefault();
        //        entity.AJA_tbl_FieldOptions.Remove(fldopts);
        //        entity.SaveChanges();
        //        rtn = true;
        //    }
        //    return rtn;
        //}

        //public static bool UpdateOption(FieldOption fldopt)
        //{
        //    bool rtn = false;
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var fldopts = (from o in entity.AJA_tbl_FieldOptions where o.OptionID == fldopt.OptionID select o).FirstOrDefault();
        //        fldopts.OptionText = fldopt.OptionText;
        //        entity.SaveChanges();
        //        rtn = true;
        //    }
        //    return rtn;
        //}


        //public static bool UpdateField(UserField Field)
        //{
        //    using (AJA_UserEntities entity = new AJA_UserEntities())
        //    {
        //        var obj = entity.AJA_tbl_UserFields.FirstOrDefault(i => i.UserFieldID == Field.FieldID);
        //        if (obj != null)
        //        {

        //            obj.RoleID = Field.RoleID;
        //            obj.FieldName = Field.FieldName;
        //            obj.IsActive = Field.IsActive;
        //            obj.IsMandatory = Field.IsMandatory;
        //            obj.TypeID = Field.TypeID;
        //            obj.UpdatedDate = DateTime.Now;
        //            if (obj.TypeID > 2)
        //            {
        //                foreach (var ao in Field.Options)
        //                {
        //                    if (ao.OptionType == 0)
        //                    {
        //                        AJA_tbl_FieldOptions fldopts = new AJA_tbl_FieldOptions();
        //                        fldopts.UserFieldID = Field.FieldID;
        //                        fldopts.OptionText = ao.OptionText;
        //                        fldopts.OptionValue = ao.OptionValue;// != "0" ? ao.OptionValue : ((from o in entity.AC_tbl_FieldOptions where o.UserFieldID == Field.FieldID select o.OptionID).Max() + 1).ToString();
        //                        entity.AJA_tbl_FieldOptions.Add(fldopts);
        //                    }
        //                    else if (ao.OptionType == 1)
        //                    {
        //                        var fldopts = (from o in entity.AJA_tbl_FieldOptions where o.OptionID == ao.OptionID select o).FirstOrDefault();
        //                        fldopts.OptionText = ao.OptionText;
        //                        fldopts.OptionValue = ao.OptionValue;
        //                    }
        //                    else if (ao.OptionType == -1)
        //                    {
        //                        var optval = (from v in entity.AJA_tbl_FieldValues where v.OptionID == ao.OptionID select v).ToList();
        //                        foreach (var item in optval)
        //                        {
        //                            entity.AJA_tbl_FieldValues.Remove(item);
        //                        }

        //                        var fldopts = (from o in entity.AJA_tbl_FieldOptions where o.OptionID == ao.OptionID select o).FirstOrDefault();
        //                        entity.AJA_tbl_FieldOptions.Remove(fldopts);
        //                    }
        //                }
        //            }
        //            entity.SaveChanges();
        //            return true;
        //        }
        //        else
        //        {
        //            return false;
        //        }
        //    }

        //}

        #endregion

        public static bool DeleteUser(int userId)
        {
            var result = true;
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == userId && i.Activated == 1);
                if (user != null)
                {
                    user.Activated = -1;
                    entity.SaveChanges();

                }
                else
                {
                    result = false;
                }

            }
            return result;
        }

        #region
        /// <summary>
        /// 
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public static bool DeleteUserByUserID(int UserID)
        {
            var result = true;
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == UserID);
                if (user != null)
                {
                    user.Activated = -1;
                    entity.SaveChanges();

                }
                else
                {
                    result = false;
                }

            }
            return result;
        }

        #endregion

        public static bool CheckUserNameExists(string UserName, int userid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var obj = entity.AJA_tbl_Users.FirstOrDefault(i => i.UserName.ToLower() == UserName.ToLower() && i.Activated != -1);
                if (obj == null)
                    return false;
                else if (obj.UserID == userid)
                    return false;
                else
                    return true;

            }
        }

        public static bool CheckUserNameInUse(string UserName)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var obj = entity.AJA_tbl_Users.FirstOrDefault(i => i.UserName.ToLower() == UserName.ToLower() && i.Activated != -1);
                if (obj == null)
                    return false;
                else
                    return true;

            }
        }

        public static bool CheckFieldNameExists(string FieldName, int? FieldID)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var obj = entity.AJA_tbl_UserFields.FirstOrDefault(i => i.FieldName.ToLower() == FieldName.ToLower());
                if (obj == null)
                    return false;
                else if (obj.UserFieldID == FieldID)
                    return false;
                else
                    return true;

            }
        }


        public static string[] GetUsersInRole(string roleName)
        {
            List<string> UserEmails = new List<string>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                UserEmails = (entity.AJA_tbl_Roles.FirstOrDefault(i => i.RoleName == roleName).AJA_tbl_Users).Select(i => i.EmailID).ToList();
            }
            return UserEmails.ToArray();
        }

        public static bool IsUserInRole(int UserId, string roleName)
        {
            try
            {
                bool res;
                using (AJA_UserEntities entity = new AJA_UserEntities())
                {
                    res = (entity.AJA_tbl_Users.FirstOrDefault(i => i.UserID == UserId).AJA_tbl_Roles).Any(i => i.RoleName == roleName);
                }
                return res;
            }
            catch (Exception ex)
            {
                System.Web.HttpContext.Current.Response.Redirect("/user/logoff");
                return false;
            }
        }

        public static string[] GetAllRoles()
        {
            List<string> Roles = new List<string>();
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                Roles = entity.AJA_tbl_Roles.Select(i => i.RoleName).ToList();
            }
            return Roles.ToArray();
        }

        public static bool CheckUser(string EmailId, string CurrentPassword)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                bool res = entity.AJA_tbl_Users.Any(i => i.EmailID.ToLower() == EmailId.ToLower() && i.Password == CurrentPassword);
                return res;
            }
        }

        public static void ChangePassword(ChangePassword cp)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var user = entity.AJA_tbl_Users.FirstOrDefault(i => i.EmailID == cp.EmailId);
                user.Password = cp.NewPassword;
                entity.SaveChanges();
            }
        }

        public static bool CheckUser(int p)
        {
            var res = true;
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                res = entity.AJA_tbl_Users.Any(i => i.UserID == p);
            }
            return res;
        }

        #region Creating and Updating userdetails

        public static int RegisterUsers(RegisterModel users)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                int newUID = 0, checkuserid;
                checkuserid = (from s in entity.AJA_tbl_Users.Where(i => i.UserName == users.UserName && i.Activated == 1) select s.UserID).FirstOrDefault();
                if (checkuserid == 0)
                {
                    List<AJA_tbl_Roles> useroles = entity.AJA_tbl_Roles.Where(i => i.RoleID == 2).ToList();//RoleID =2 default role become AJA User.

                    var newuser = new AJA_tbl_Users
                    {
                        UserTitle = users.UserTitle,
                        Password = users.Password,
                        Pincode = users.postalcode,
                        //Pincode = Convert.ToInt32(users.postalcode),
                        Lname = users.LastName,
                        Fname = users.FirstName,
                        UserName = users.UserName,
                        EmailID = users.Email,
                        IseditorEmaiSend = users.Isendemail,
                        IsSavedAqemaisend = users.Isasemail,
                        profession = users.Profession,
                        CountryID = Convert.ToInt32(users.CountryID),
                        specialtyID = Convert.ToInt32(users.SpecialityID),
                        typePracticeID = Convert.ToInt32(users.PracticeID),
                        graduationYear = Convert.ToInt32(users.GraduationYr),
                        CreatedDate = DateTime.Now,
                        Activated = 1,
                        AJA_tbl_Roles = useroles,
                    };
                    entity.AJA_tbl_Users.Add(newuser);
                    entity.SaveChanges();

                    newUID = (from s in entity.AJA_tbl_Users.Where(i => i.UserName == users.UserName && i.Activated == 1) select s.UserID).FirstOrDefault();

                    UserSpecialty userspec = new UserSpecialty();
                    userspec.UserID = newUID;
                    userspec.SpecialtyID = Convert.ToInt32(users.SpecialityID);
                    userspec.DateAdded = DateTime.Now;
                    entity.UserSpecialties.Add(userspec);

                    bool IsInuse = (from sp in entity.Specialties.Where(i => i.SpecialtyID == users.SpecialityID) select sp.isInUse).FirstOrDefault();

                    if (IsInuse == false)
                    {
                        Topic createTopic = new Topic();
                        createTopic.UserID = newUID;
                        createTopic.SpecialtyID = Convert.ToInt32(users.SpecialityID);
                        createTopic.TopicName = "Topic";
                        createTopic.createtime = DateTime.Now;
                        createTopic.Type = 2;
                        entity.Topics.Add(createTopic);
                        entity.SaveChanges();

                        int newTopicID = (from s in entity.Topics.Where(i => i.UserID == newUID) select s.TopicID).FirstOrDefault();

                        SubTopic CreatSubTopic = new SubTopic();
                        CreatSubTopic.UserID = newUID;
                        CreatSubTopic.TopicID = newTopicID;
                        CreatSubTopic.SubTopicName = "Subtopic";
                        CreatSubTopic.createtime = DateTime.Now;
                        CreatSubTopic.Type = 2;
                        entity.SubTopics.Add(CreatSubTopic);
                    }

                    entity.SaveChanges();
                }
                //else
                //{
                //    var loginuser = entity.AJA_tbl_Users.Where(u => u.UserID == users.UserID).FirstOrDefault();

                //    loginuser.EmailID = users.Email;
                //    loginuser.Fname = users.FirstName;
                //    loginuser.Lname = users.LastName;
                //    loginuser.UserTitle = users.UserTitle;
                //    loginuser.Password = users.Password;
                //    loginuser.UpdatedDate = DateTime.Now;
                //    loginuser.UpdatedBy = users.UserID;
                //    loginuser.Pincode = users.postalcode;
                //    loginuser.CountryID = Convert.ToInt32(users.CountryID);
                //    loginuser.typePracticeID = Convert.ToInt32(users.PracticeID);
                //    loginuser.graduationYear = Convert.ToInt32(users.GraduationYr);
                //    loginuser.profession = users.Profession;
                //    loginuser.IseditorEmaiSend = users.Isasemail;
                //    loginuser.IsSavedAqemaisend = users.Isasemail;
                //    entity.SaveChanges();
                //}
                return newUID;
            }
        }

        /// <summary>
        /// Update User Details at MyProfile
        /// </summary>
        /// <param name="users"></param>
        /// <returns></returns>
        public static bool ModifyUser(MyProfileModel users)
        {
            bool result = true;
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var loginuser = entity.AJA_tbl_Users.Where(u => u.UserID == users.UserID).FirstOrDefault();

                loginuser.EmailID = users.EmailID;
                loginuser.Fname = users.FirstName;
                loginuser.Lname = users.LastName;
                loginuser.UserTitle = users.UserTitle;
                loginuser.Password = users.Password;
                loginuser.UpdatedDate = DateTime.Now;
                loginuser.UpdatedBy = users.UserID;
                loginuser.Pincode = users.postalcode;
                loginuser.CountryID = Convert.ToInt32(users.CountryID);
                loginuser.typePracticeID = Convert.ToInt32(users.PracticeID);
                loginuser.graduationYear = Convert.ToInt32(users.GraduationYr);
                loginuser.profession = users.Profession;
                loginuser.IseditorEmaiSend = users.Isendemail;
                loginuser.IsSavedAqemaisend = users.Isasemail;
                entity.SaveChanges();
                return result;
            }
        }
        #endregion

        #region Dropdownlist data from DB

        /// <summary>
        /// Get Countries List from DB bind it to Drop Down list at Registration Page
        /// </summary> method of binding dropdown with orderby clause
        /// <returns></returns>
        public static List<SelectListItem> GetCountriesList()
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var query = (from p in entity.Countries.AsEnumerable()
                             orderby p.countryID
                             select new SelectListItem
                             {
                                 Value = p.countryID.ToString(),
                                 Text = p.countryName

                             }).ToList();
                return query;

            }
        }

        /// <summary>
        /// Get Specialities List from DB bind it to Drop Down list at Registration Page
        /// </summary>
        /// <returns></returns>
        public static List<SelectListItem> GetSpecialitesList()
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.Specialties.AsEnumerable().Select(c => new SelectListItem
                {
                    Value = c.SpecialtyID.ToString(),
                    Text = c.SpecialtyName,
                }).ToList();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static List<SelectListItem> GetSpecialitesLists(int? id)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.Specialties.AsEnumerable().Select(c => new SelectListItem
                {
                    Value = c.SpecialtyID.ToString(),
                    Text = c.SpecialtyName,
                    Selected = (c.SpecialtyID == id ? true : false)
                }).ToList();
            }
        }
        /// <summary>
        /// Get User Speciality  from SpecialitesList for Profile Page
        /// </summary>
        /// <returns></returns>
        public static string GetUserSpeciality(int? SPId)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                try
                {
                    return entity.Specialties.FirstOrDefault(s => s.SpecialtyID == SPId).SpecialtyName;
                }
                catch (Exception)
                {
                    return "";
                }

            }
        }

        /// <summary>
        /// Get Practices List from DB bind it to Drop Down list at Registration Page
        /// </summary>
        /// <returns></returns>
        public static List<SelectListItem> GetPracticesList()
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                return entity.TypePractices.AsEnumerable().Select(c => new SelectListItem
                {
                    Value = Convert.ToString(c.id),
                    Text = c.TypePractice1
                }).ToList();
            }
        }

        #endregion

        #region User Creation By Admin

        public static void CreatingUser(RegisterModel user)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                if (user.UserID == 0 || user.UserID == null)
                {
                    List<AJA_tbl_Roles> userroles = new List<AJA_tbl_Roles>();
                    if (user.Roles != null)
                    {
                        foreach (Roles r in user.Roles)
                        {
                            AJA_tbl_Roles r4 = entity.AJA_tbl_Roles.Where(ro => ro.RoleID == r.RoleID).FirstOrDefault();
                            userroles.Add(r4);
                        }
                    }

                    var createLogin = new AJA_tbl_Users
                    {
                        EmailID = user.Email,
                        Password = user.Password,
                        UserName = user.UserName,
                        Fname = user.FirstName,
                        Lname = user.LastName,
                        CountryID = Convert.ToInt32(user.CountryID),
                        specialtyID = Convert.ToInt32(user.SpecialityID),
                        typePracticeID = Convert.ToInt32(user.PracticeID),
                        profession = user.Profession,
                        UserTitle = user.UserTitle,
                        Pincode = user.postalcode,
                        graduationYear = Convert.ToInt32(user.GraduationYr),
                        IsSavedAqemaisend = user.Isasemail,
                        IseditorEmaiSend = user.Isendemail,
                        CreatedDate = DateTime.Now,
                        UpdatedBy = 0,
                        Activated = 1,
                        AJA_tbl_Roles = userroles,
                    };

                    entity.AJA_tbl_Users.Add(createLogin);
                    entity.SaveChanges();

                    int newUID = (from s in entity.AJA_tbl_Users.Where(i => i.UserName == user.UserName) select s.UserID).FirstOrDefault();

                    UserSpecialty userspec = new UserSpecialty();
                    userspec.UserID = newUID;
                    userspec.SpecialtyID = Convert.ToInt32(user.SpecialityID);
                    userspec.DateAdded = DateTime.Now;
                    entity.UserSpecialties.Add(userspec);
                    entity.SaveChanges();

                }
            }
        }

        public static AJA_tbl_Users GetUserdet(int uid)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                var model = (from e in entity.AJA_tbl_Users.Where(i => i.UserID == uid) select e).FirstOrDefault();
                return model;
            }
        }

        #endregion

        #region EditorsChoice

        #region SpecialityhasCurrentEditon
        /// <summary>
        /// Returns true or false based on result count
        /// </summary>
        /// <param name="SpecialityID"></param>
        /// <returns></returns>
        public static bool specialtyhascurrentedition(int SpecialityID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var year = DateTime.Now.ToString("yyyy");
                var month = DateTime.Now.ToString("mm");
                var result = (from Editions in entity.Editions
                              where (Editions.PubDate.Year == DateTime.Now.Year &&
                              Editions.PubDate.Month == DateTime.Now.Month &&
                              Editions.SpecialtyID == SpecialityID)
                              select Editions).Count();

                if (result > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        #endregion

        #region GetLatest Edition
        /// <summary>
        /// Get LatestEditionID of respective speciality
        /// </summary>
        /// <param name="SpecialityID"></param>
        /// <returns></returns>
        public static int GetLatestEditon(int SpecialityID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                int EditorID = (from Editions in entity.Editions
                                where
                                  (Editions.PubDate.Year == DateTime.Now.Year &&
                                  Editions.PubDate.Month == DateTime.Now.Month && Editions.SpecialtyID == SpecialityID)
                                orderby
                                Editions.PubDate descending
                                select Editions.EditionID).FirstOrDefault();
                return EditorID;
            }
        }

        #endregion

        #region GetECThreadCitations

        public static List<int> GetECThreadCitations(int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var rslt = (from p in entity.ArticleSelections where p.ThreadID == ThreadID select p.PMID).ToList();
                return rslt;

            }

        }
        #endregion

        #region ThreadAttributes
        /// <summary>
        /// This will return Editornames and Topic sub topics of the respective edition and thread
        /// </summary>
        /// <param name="EditionID"></param>
        /// <param name="ThreadID"></param>
        /// <returns></returns>
        public static ECThreadAttributes GetECThreadAttributes(int EditionID, int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                ECThreadAttributes value = new ECThreadAttributes();
                value.ThreadEditors = GetThreadEditors(EditionID, ThreadID);
                value.ThreadTopics = GetThreadTopics(EditionID, ThreadID);
                value.ThreadId = Convert.ToInt32(ThreadID);
                value.EditionId = Convert.ToInt32(EditionID);
                return value;
            }
        }


        #region GetThreadEditors
        /// <summary>
        /// This will returns the Thread Editors  of respective editonID and ThreadID
        /// </summary>
        /// <param name="EditionID"></param>
        /// <param name="ThreadID"></param>
        /// <returns></returns>
        public static string GetThreadEditors(int EditionID, int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var name = string.Empty;
                List<string> output = (from ster in entity.SubTopicEditorRefs
                                       join ed in entity.CommentAuthors on new { EditorID = ster.EditorID } equals new { EditorID = ed.id }
                                       where
                                       ster.EditionID == EditionID && ster.ThreadID == ThreadID
                                       orderby ster.Seniority
                                       select ed.name).ToList();
                foreach (var item in output)
                {
                    if (name == string.Empty)
                    {
                        name = item;
                    }
                    else
                    {
                        name = name + ", " + item;
                    }
                }

                return name;
            }
        }
        #endregion

        #region GetThreadTopics
        /// <summary>
        /// This will returns the Threadtopics present passed edition ID and Thread ID
        /// </summary>
        /// <param name="EditionID"></param>
        /// <param name="ThreadID"></param>
        /// <returns></returns>
        public static string GetThreadTopics(int EditionID, int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var TopicSubtopic = string.Empty;
                List<ECThreadAttributes> output = (from t in entity.Topics
                                                   join st in entity.SubTopics on t.TopicID equals st.TopicID
                                                   join stref in entity.SubTopicReferences on st.SubTopicID equals stref.SubTopicID
                                                   where
                                                     stref.EditionID == EditionID &&
                                                     stref.ThreadID == ThreadID
                                                   orderby
                                                     t.TopicName,
                                                     st.SubTopicName
                                                   select new ECThreadAttributes
                                                   {
                                                       TopicName = t.TopicName,
                                                       SubTopicName = st.SubTopicName
                                                   }).ToList();

                foreach (var item in output)
                {
                    if (TopicSubtopic == string.Empty)
                    {
                        TopicSubtopic = item.TopicName + " | " + item.SubTopicName;
                    }
                    else
                    {
                        TopicSubtopic = TopicSubtopic + ", " + item.TopicName + " | " + item.SubTopicName;
                    }
                }

                return TopicSubtopic;
            }
        }

        #endregion

        #endregion

        #region GetECThreadComments
        /// <summary>
        /// Gets the list of comments present in the passed threadID and editionID
        /// </summary>
        /// <param name="EditionID"></param>
        /// <param name="ThreadID"></param>
        /// <returns></returns>
        public static List<lib_GetECThreadComments_Result> GetECThredComments(int EditionID, int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var result = entity.lib_GetECThreadComments(EditionID, ThreadID).ToList();
                return result;
            }
        }


        public static List<GetECThreadComments> GetECThredComments1(int EditionID, int ThreadID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                //var result = entity.lib_GetECThreadComments(EditionID, ThreadID).ToList();
                //return result;
                string query = "[lib_GetECThreadComments] @EditionID,@ThreadID";
                SqlParameter EditID = new SqlParameter("@EditionID", EditionID);
                SqlParameter thid = new SqlParameter("@ThreadID", ThreadID);

                var result = entity.Database.SqlQuery<GetECThreadComments>(query, EditID, thid).ToList();
                return result;
            }
        }

        #endregion

        #region GetSpecialitiesWith userID
        /// <summary>
        /// This will return User speciality ID and speciality name for displaying selected Specialtiy
        /// </summary>
        /// <param name="uid"></param>
        /// <returns></returns>
        public static List<SelectListItem> GetSpecialiteswithID(int uid)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var result = (from us in entity.UserSpecialties.AsEnumerable()
                              join spec in entity.Specialties on us.SpecialtyID equals spec.SpecialtyID
                              where
                              us.UserID == uid
                              orderby
                              us.DateAdded
                              select new SelectListItem
                              {
                                  Value = us.SpecialtyID.ToString(),
                                  Text = spec.SpecialtyName
                              }).ToList();
                return result;
            }

        }

        #endregion

        #region GetRelatedEditions
        /// <summary>
        /// Get Related Editons passing PMID and editonID
        /// </summary>
        /// <param name="PMID"></param>
        /// <param name="EditonID"></param>
        /// <returns></returns>
        public static List<lib_GetRelatedEditions_Result> GetRelatedEditons(int PMID, int EditonID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var value = entity.lib_GetRelatedEditions(PMID, EditonID).ToList();
                return value;

                #region Linq converted above query
                //var value = (from arts in entity.ArticleSelections
                //             from stref in entity.SubTopicReferences
                //             join s in entity.Specialties on stref.Edition.SpecialtyID equals s.SpecialtyID
                //             where
                //                 arts.PMID == PMID &&
                //                 stref.Edition.EditionID != EditonID
                //             orderby
                //             stref.Edition.PubDate,
                //             s.SpecialtyName
                //             select new EditorsChoicemodel
                //             {
                //                 SpecialtyName = s.SpecialtyName,
                //                 PubDate = stref.Edition.PubDate,
                //                 EditionId = stref.Edition.EditionID,
                //                 SpecialtyID = s.SpecialtyID,
                //                 ThreadId = stref.EditorialThread.ThreadID
                //             }).Distinct().ToList();
                #endregion
            }
        }
        #endregion

        #region  Display PMIDs

        /// <summary>
        /// This will return authorslist etc requird for citations to display in Editors choice citation
        /// </summary>
        /// <param name="UserID"></param>
        /// <param name="PMIDList"></param>
        /// <param name="DisplayMode"></param>
        /// <param name="SearchSort"></param>
        /// <returns></returns>
        public static EditorsChoicemodel DisplayPMIDS(int? UserID, string PMIDList, int? DisplayMode, byte? SearchSort)
        {
            using (Cogent3Entities entity = new Cogent3Entities())
            {
                #region direct calling sp without interacting to entity

                EditorsChoicemodel result = null;
                string query = "[ap_DisplayPMID] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserIDs = new SqlParameter("@UserID", UserID);
                SqlParameter PMIDSlst = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayModes = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSorts = new SqlParameter("@SearchSort", SearchSort);
                result = entity.Database.SqlQuery<EditorsChoicemodel>(query, UserIDs, PMIDSlst, DisplayModes, SearchSorts).FirstOrDefault();

                // Added For Non-Medline Citations
                if ((!result.unicodeFixed.HasValue) || (result.unicodeFixed == false))
                {
                    if ((result.ArticleTitle ?? "").Contains("?") || (result.ArticleTitle ?? "").Contains("="))
                    {
                        List<string> ArticleTitleWithNoIssue = MyLibraryBL.GetAbstractWithNoIssue(result.PMID);

                        if (ArticleTitleWithNoIssue.Count == 2)
                        {
                            result.ArticleTitle = ArticleTitleWithNoIssue[1];
                        }
                    }

                }

                if (string.IsNullOrEmpty(result.AbstractText))
                {
                    using (EditorsEntities entityNM = new EditorsEntities())
                    {
                        var NMCitation = (from nm in entityNM.NonMedlineCitations
                                          where nm.PMID == result.PMID
                                          select nm).FirstOrDefault();

                        if (NMCitation != null)
                        {
                            result.AbstractText = NMCitation.Abstract;
                            result.ArticleTitle = NMCitation.ArticleTitle;
                            result.AuthorList = NMCitation.AuthorList;
                            result.AuthorFullList = NMCitation.AuthorList;
                            result.DisplayDate = NMCitation.DisplayDate;
                            result.DisplayNotes = NMCitation.DisplayNotes;
                            result.MedlinePgn = NMCitation.MedlinePgn;
                            result.MedlineTA = NMCitation.MedlineTA;
                            result.StatusDisplay = NMCitation.StatusDisplay;
                        }
                    }
                    if ((!result.unicodeFixed.HasValue) || (result.unicodeFixed == false))
                    {
                        if ((result.ArticleTitle ?? "").Contains("?") || (result.ArticleTitle ?? "").Contains("="))
                        {
                            List<string> ArticleTitleWithNoIssue = MyLibraryBL.GetAbstractWithNoIssue(result.PMID);

                            if (ArticleTitleWithNoIssue.Count == 2)
                            {
                                result.ArticleTitle = ArticleTitleWithNoIssue[1];
                            }
                        }
                    }
                }
                string query1 = "[ap_DisplayPMID_AJA_Dev_Detailed] @UserID,@PMIDList,@DisplayMode,@SearchSort";
                SqlParameter UserID1 = new SqlParameter("@UserID", UserID);
                SqlParameter Pmids1 = new SqlParameter("@PMIDList", PMIDList);
                SqlParameter DisplayMode1 = new SqlParameter("@DisplayMode", DisplayMode);
                SqlParameter SearchSort1 = new SqlParameter("@SearchSort", SearchSort);
                var AllCitationDetailsDetailed = entity.Database.SqlQuery<CitationDetailsAuthorslist>(query1, UserID1, Pmids1, DisplayMode1, SearchSort1).ToList();

                foreach (CitationDetailsAuthorslist Author in AllCitationDetailsDetailed)
                {
                    //to check if author name already exists to avoid duplicates
                    if (!string.IsNullOrEmpty(Author.DisplayName) && !(Author.DisplayName.IndexOf(Author.DisplayName + ",") > 0))
                    {
                        result.AuthorFullList += Author.DisplayName + ", ";
                    }
                }

                if (result.AuthorFullList != null)
                    result.AuthorFullList = result.AuthorFullList.TrimEnd().TrimEnd(',');


                if ((!result.unicodeFixed.HasValue) || result.unicodeFixed == false)
                {
                    List<string> AbstractArticleTitleNew = MyLibraryBL.GetAbstractWithNoIssue(result.PMID);
                    if (AbstractArticleTitleNew.Count == 2)
                    {
                        int PMID = Convert.ToInt32(result.PMID);
                        var IwideTable = (from iw in entity.iWides where iw.PMID == PMID select iw).FirstOrDefault();

                        if (IwideTable != null)
                        {
                            result.AbstractText = AbstractArticleTitleNew[0];  //AbstractArticleTitleNew[0] is for Abstract Text and AbstractArticleTitleNew[1] is for Article Title;;
                            IwideTable.AbstractText = AbstractArticleTitleNew[0];
                            result.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideTable.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideTable.unicodeFixed = true;

                            entity.Entry(IwideTable).State = EntityState.Modified;
                            entity.SaveChanges();
                        }

                        var IwideNewTable = (from iw in entity.iWideNews where iw.PMID == PMID select iw).FirstOrDefault();

                        if (IwideNewTable != null)
                        {
                            result.AbstractText = AbstractArticleTitleNew[0];
                            IwideNewTable.AbstractText = AbstractArticleTitleNew[0];

                            result.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideNewTable.ArticleTitle = AbstractArticleTitleNew[1];
                            IwideNewTable.unicodeFixed = true;

                            entity.Entry(IwideNewTable).State = EntityState.Modified;
                            entity.SaveChanges();
                        }
                    }
                }

                return result;

                #endregion

            }
        }
        #endregion


        public static EditorsChoicemodel GetNonMedlineCitations(int pmid)
        {
            EditorsChoicemodel temp = new EditorsChoicemodel();
            using (EditorsEntities entity = new EditorsEntities())
            {
                var result = (from NonCit in entity.NonMedlineCitations.Where(i => i.PMID == pmid) select NonCit).FirstOrDefault();
                if (result != null)
                {
                    temp.ArticleTitle = result.ArticleTitle;
                    temp.AbstractText = result.Abstract;
                    temp.AuthorList = result.AuthorList;
                    temp.MedlinePgn = result.MedlinePgn;
                    temp.MedlineTA = result.MedlineTA;
                    temp.DisplayDate = result.DisplayDate;
                    temp.StatusDisplay = result.StatusDisplay;
                    temp.DisplayNotes = result.DisplayNotes;
                    temp.PMID = result.PMID;
                }
                return temp;
            }
        }

        #region GetEC Editors Sort
        /// <summary>
        /// 
        /// </summary>
        /// <param name="EditionID"></param>
        /// <returns></returns>        
        public static List<lib_GetECEditorSort_Result> GetECEditorSort(int EditionID)
        {
            List<EditorsChoicemodel> coments = new List<EditorsChoicemodel>();

            using (EditorsEntities entity = new EditorsEntities())
            {

                var query = entity.lib_GetECEditorSort(EditionID).ToList();
                return query;

            }
        }
        #endregion

        #region Get Editors Choice Topic Sort
        /// <summary>
        /// Get editons sorted list by passing editionID
        /// </summary>
        /// <param name="EditonID"></param>
        /// <returns></returns>
        public static IEnumerable<EditorsChoicemodel> GetECTopicSort(int EditonID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var value = (from t in entity.Topics
                             join st in entity.SubTopics on t.TopicID equals st.TopicID
                             join stref in entity.SubTopicReferences on st.SubTopicID equals stref.SubTopicID
                             join asel in entity.ArticleSelections on stref.ThreadID equals asel.ThreadID
                             where
                             stref.EditionID == EditonID
                             orderby
                             t.TopicName,
                             st.SubTopicName,
                             asel.PMID
                             select new EditorsChoicemodel
                             {
                                 TopicName = t.TopicName.ToUpper(),
                                 SubTopicID = (System.Int32?)st.SubTopicID,
                                 SubTopicname = st.SubTopicName,
                                 ThreadId = asel.ThreadID,
                                 PMID = asel.PMID
                             }).ToList();

                return value;
            }
        }
        #endregion

        #region GetPMIDS for edition
        /// <summary>
        /// Get list of PMIDS present in the specified Edition
        /// </summary>
        /// <param name="EditionID"></param>
        /// <returns></returns>
        public static IEnumerable<int> GetPMIDsForEdition(int EditionID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var IDs = (from asel in entity.ArticleSelections
                           join stref in entity.SubTopicReferences on asel.ThreadID equals stref.ThreadID
                           where
                             stref.EditionID == EditionID
                           select asel.PMID).Distinct().ToList();
                return IDs;
            }
        }

        #endregion

        #region GetECEditionThreads
        /// <summary>
        /// gets the list of Threads and its content present in the specified Edition
        /// </summary>
        /// <param name="EditonID"></param>
        /// <returns></returns>
        public static List<EditorsChoicemodel> GetEcEditionThreads(int EditonID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                #region Linq   Convert SP
                //var result = from thds in
                //                 (
                //                     ((from strefs in entity.SubTopicReferences
                //                       where
                //                          strefs.EditionID == EditonID
                //                       select new EditorsChoicemodel
                //                       {
                //                           ThreadId = (System.Int32?)strefs.EditorialThread.ThreadID,
                //                           OriginalPubDate = (System.DateTime?)strefs.EditorialThread.OriginalPubDate
                //                       }).Distinct().ToList()))
                //             select new
                //             {
                //                 thds.ThreadId,
                //                 thds.OriginalPubDate,
                //                 TopicOrdering = ((from t in entity.Topics
                //                                   join st in entity.SubTopics on t.TopicID equals st.TopicID
                //                                   join strefs in entity.SubTopicReferences on st.SubTopicID equals strefs.SubTopicID
                //                                   where
                //                                   strefs.ThreadID == Convert.ToInt32(thds.ThreadId)
                //                                   select new
                //                                   {
                //                                       Column1 = (t.TopicName + st.SubTopicName)
                //                                   }).Take(1).First().Column1)
                //             };
                //return result;
                #endregion

                List<EditorsChoicemodel> result = null;
                string query = "[lib_GetECEditionThreads] @EditionID";
                SqlParameter EdtID = new SqlParameter("@EditionID", EditonID);
                result = entity.Database.SqlQuery<EditorsChoicemodel>(query, EdtID).ToList();
                return result;

            }
        }
        #endregion

        #region
        /// <summary>
        /// This will return the threads present in edition for printabstract all view
        /// </summary>
        /// <param name="EditonID"></param>
        /// <returns></returns>
        public static EditorsChoicemodel Gets(int EditonID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                EditorsChoicemodel result = null;
                string query = "[lib_GetECEditionThreads] @EditionID";
                SqlParameter EdtID = new SqlParameter("@EditionID", EditonID);
                result = entity.Database.SqlQuery<EditorsChoicemodel>(query, EdtID).FirstOrDefault();
                return result;
            }
        }
        #endregion

        #region GetGenesForEC
        /// <summary>
        /// returns list of Genes commented on that thread citation
        /// </summary>
        /// <param name="cmntID"></param>
        /// <returns></returns>
        public static List<lib_GetGenesForEditorsChoice_Result> GetGenesForEC(int cmntID)
        {
            using (EditorsEntities entity = new EditorsEntities())
            {
                var GetGene = entity.lib_GetGenesForEditorsChoice(cmntID).ToList();
                return GetGene;
            }
        }
        #endregion

        #endregion

        #region  GetALLUsersForAdmin
        /// <summary>
        /// Get Alll Users For admin New Grid -RaviM 10/23/2013
        /// </summary>
        /// <param name="Filter"></param>
        /// <returns></returns>
        public static Grid.GridResult GetALLUsersForAdmin(MVC4Grid.Grid.GridFilter Filter)
        {
            using (AJA_UserEntities entity = new AJA_UserEntities())
            {
                DateTime DateAdded = Convert.ToDateTime("2002-12-31");
                var result = (from s in entity.AJA_tbl_Users.Where(i => i.Activated == 1)
                              select new UserdetValues
                              {
                                  FirstName = s.Fname,
                                  LastName = s.Lname,
                                  EmailId = s.EmailID,
                                  userId = s.UserID,
                                  Title = s.UserTitle,
                                  UserName = s.UserName,
                                  SpecialityID = s.specialtyID,
                                  Speciality = ((from t in entity.Specialties
                                                 where
                                                   t.SpecialtyID == s.specialtyID
                                                 select new
                                                 {
                                                     t.SpecialtyName
                                                 }).FirstOrDefault().SpecialtyName),
                                  Roles = (from r in s.AJA_tbl_Roles where r.RoleID != 0 select r.RoleName),
                                  Iseditoremailsend = s.IseditorEmaiSend,
                                  CreatedDate = (DateTime)(s.CreatedDate ?? DateAdded),
                              }).GridFilterBy(Filter);
                return result;
            }
        }
        #endregion
    }

    [GridPaging(NoofRows = 15)]
    [GridSearching]
    [GridSorting]
    public class UserdetValues
    {
        public UserdetValues()
        {

        }
        [HiddenInput]
        [Key]
        public int userId { get; set; }

        [GridSorting(Default = true)]
        [Display(Name = "User Name")]
        public string UserName { get; set; }

        [Display(Name = "First Name")]
        public string FirstName { get; set; }
        [Display(Name = "Last Name")]
        public string LastName { get; set; }

        [Display(Name = "Email ID")]
        public string EmailId { get; set; }

        [HiddenInput]
        public int? SpecialityID { get; set; }

        [HiddenInput]
        [GridSearching(Searching = false)]
        public List<SelectListItem> SpecialtiesList { get; set; }

        [GridSearching(Searching = true)]
        public IEnumerable<string> Roles { get; set; }

        [GridSearching(Searching = false)]
        [HiddenInput]
        public DateTime? ModifiedDate { get; set; }

        [HiddenInput]
        public int? postalcode { get; set; }

        [HiddenInput]
        public string Profession { get; set; }

        public string Title { get; set; }
        [Display(Name = "Specialty")]
        public string Speciality { get; set; }

        [HiddenInput]
        public int? GraduationYr { get; set; }

        [Display(Name = "Send Email")]
        [GridSearching(Searching = false)]
        public bool Iseditoremailsend { get; set; }

        [GridSearching(Searching = false)]
        [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}")]
        public DateTime CreatedDate { get; set; }

        [HiddenInput]
        public string RoleName
        {
            get
            {
                var res = string.Empty;
                foreach (var r in this.Roles)
                {
                    res += r + ", ";
                }
                if (res.Length > 0)
                    return res.Remove(res.Length - 2);
                else
                    return res;
            }
        }
    }

    static class IQueryableExtensions
    {
        public static IQueryable<T> OrderBy<T>(this IQueryable<T> items, string propertyName)
        {
            var typeOfT = typeof(T);
            var parameter = Expression.Parameter(typeOfT, "parameter");
            var propertyType = typeOfT.GetProperty(propertyName).PropertyType;
            var propertyAccess = Expression.PropertyOrField(parameter, propertyName);
            var orderExpression = Expression.Lambda(propertyAccess, parameter);

            var expression = Expression.Call(typeof(Queryable), "OrderBy", new Type[] { typeOfT, propertyType }, items.Expression, Expression.Quote(orderExpression));
            return items.Provider.CreateQuery<T>(expression);
        }
    }
}
