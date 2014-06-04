using System;
using System.Configuration;


namespace AJA_Core
{
    public static class Util
    {

        #region Encrytion/Decrytion
        public static string Encrypt(string key)
        {
            string res = string.Empty;
            res = SymmetricEncryption.EncryptString(key);
            return res;
        }

        public static string Decrypt(string key)
        {
            string res = string.Empty;
            res = SymmetricEncryption.DecryptString(key);
            return res;
        }

        public static string GenerateNewPassword(string key)
        {
            string res = string.Empty;
            Random rn = new Random();
            var random = rn.Next(1000, 10000);
            res = SymmetricEncryption.EncryptString(key + random);

            return res;
        }

        #endregion


        #region ReadConfigDetails
        /// <summary>
        /// To get the value from the appSettings configuration using key.
        /// </summary>
        /// <param name="appKeyName"></param>
        /// <returns></returns>
        public static string GetAppConfigKeyValue(this string appKeyName)
        {
            string returnValue = string.Empty;

            if (!string.IsNullOrEmpty(appKeyName))
            {
                returnValue = ConfigurationManager.AppSettings[appKeyName];
            }

            return returnValue;
        }
        #endregion



    }
}
