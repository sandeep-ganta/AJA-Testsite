using Microsoft.Web.WebPages.OAuth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace AJA.App_Start
{
    public class OAuthConfig
    {
        public static void RegisterProviders()
        {
            // OAuthWebSecurity.RegisterGoogleClient();
            OAuthWebSecurity.RegisterClient(new GoogleCustomClient(), "Google", null);
            OAuthWebSecurity.RegisterClient(new MyFacebookClient(appId: "400271466779149", appSecret: "11df9681e7dad0b05130348f741ccbe4"), "MyFacebook", null);
           // OAuthWebSecurity.RegisterFacebookClient(appId: "400271466779149", appSecret: "11df9681e7dad0b05130348f741ccbe4");
        }
    }
}