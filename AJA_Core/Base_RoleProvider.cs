using System.Web.Security;

namespace AJA_Core
{
    public class Base_RoleProvider : RoleProvider
    {

        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new System.NotImplementedException();
        }

        public override string ApplicationName
        {
            get
            {
                throw new System.NotImplementedException();
            }
            set
            {
                throw new System.NotImplementedException();
            }
        }

        public override void CreateRole(string roleName)
        {
            throw new System.NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new System.NotImplementedException();
        }

        public override string[] FindUsersInRole(string roleName, string usernameToMatch)
        {
            throw new System.NotImplementedException();
        }

        public override string[] GetAllRoles()
        {
            return DAL.UserBL.GetAllRoles();
        }

        public override string[] GetRolesForUser(string username)
        {
            var userid = 0;
            if (int.TryParse(username, out userid))
            {
                return DAL.UserBL.GetRoles(userid).ToArray();
            }
            else
            {
                return new string[] { };
            }

        }

        public override string[] GetUsersInRole(string roleName)
        {
            return DAL.UserBL.GetUsersInRole(roleName);
        }

        public override bool IsUserInRole(string username, string roleName)
        {
            var userid = 0;
            if (int.TryParse(username, out userid))
            {
                return DAL.UserBL.IsUserInRole(userid, roleName);
            }
            else
            {
                return false;
            }
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new System.NotImplementedException();
        }

        public override bool RoleExists(string roleName)
        {
            throw new System.NotImplementedException();
        }
    }
}
