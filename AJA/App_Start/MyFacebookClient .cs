using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Web.WebPages.OAuth;
using DotNetOpenAuth.AspNet.Clients;
using DotNetOpenAuth.OpenId.RelyingParty;
using DotNetOpenAuth.OpenId.Extensions.AttributeExchange;
using System.Net;
using System.Collections.Specialized;
using System.Web.Helpers;
using DotNetOpenAuth.AspNet;

namespace AJA.App_Start
{
    public class MyFacebookClient: DotNetOpenAuth.AspNet.Clients.OAuth2Client
    {
        private const string AuthorizationEP = "https://www.facebook.com/dialog/oauth";
        private const string TokenEP = "https://graph.facebook.com/oauth/access_token";
        private readonly string _appId;
        private readonly string _appSecret;

        public MyFacebookClient(string appId, string appSecret)
            : base("myfacebook")
        {
            this._appId = appId;
            this._appSecret = appSecret;
        }


        protected override Uri GetServiceLoginUrl(Uri returnUrl)
        {
            return new Uri(
                        AuthorizationEP
                        + "?client_id=" + this._appId
                        + "&redirect_uri=" + HttpUtility.UrlEncode(returnUrl.ToString())
                        + "&scope=email,user_about_me"
                        + "&display=page"
                    );
        }

        protected override IDictionary<string, string> GetUserData(string accessToken)
        {
            WebClient client = new WebClient();
            string content = client.DownloadString(
                "https://graph.facebook.com/me?access_token=" + accessToken
            );
            dynamic data = Json.Decode(content);
            var retval= new Dictionary<string, string> {
                {
                    "Id",
                    data.id
                },
                {
                    "Name",
                    data.name
                },
                {
                    "Photo",
                    "https://graph.facebook.com/" + data.id + "/picture"
                },
                {
                    "Email",
                    data.email
                }
            };
            return retval;
        }

        protected override string QueryAccessToken(Uri returnUrl, string authorizationCode)
        {
            WebClient client = new WebClient();
            string content = client.DownloadString(
                TokenEP
                + "?client_id=" + this._appId
                + "&client_secret=" + this._appSecret
                + "&redirect_uri=" + HttpUtility.UrlEncode(returnUrl.ToString())
                + "&code=" + authorizationCode
            );

            NameValueCollection nameValueCollection = HttpUtility.ParseQueryString(content);
            if (nameValueCollection != null)
            {
                string result = nameValueCollection["access_token"];
                return result;
            }
            return null;
        }

        public override AuthenticationResult VerifyAuthentication(HttpContextBase context, Uri returnPageUrl)
        {
            string code = context.Request.QueryString["code"];
            string u = context.Request.Url.ToString();

            if (string.IsNullOrEmpty(code))
                return AuthenticationResult.Failed;

            string accessToken = this.QueryAccessToken(returnPageUrl, code);
            if (accessToken == null)
                return AuthenticationResult.Failed;

            IDictionary<string, string> userData = this.GetUserData(accessToken);
            if (userData == null)
                return AuthenticationResult.Failed;


            string id = userData["Id"];
            //string name = string.Empty;

            return new AuthenticationResult(
                isSuccessful: true, provider: "Facebook", providerUserId: id, userName: userData["Name"], extraData: userData);
        }   
    }
}