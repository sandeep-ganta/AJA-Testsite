using System.IO;
using System.Net.Mail;
using System;
using System.Configuration;
using System.Web.Configuration;
using System.Net.Configuration;
using System.Text;
using System.Net.Mime;
using System.Web;
using System.Text.RegularExpressions;

namespace AJA_Core
{
    public static class EMailMessage
    {
        /// <summary>
        /// Sends Email
        /// </summary>
        /// <param name="to"></param>
        /// <param name="subject"></param>
        /// <param name="body"></param>
        public static void SendMail(string to, string subject, string body)
        {
            var from = Util.GetAppConfigKeyValue("FromMailID");
            SmtpClient client = new SmtpClient();
            MailMessage message = new MailMessage(from, to, subject, body);
            message.IsBodyHtml = true;
            client.Send(message);
        }

        public static void SendTestMail(string from, string name, string to, string subject, string body)
        {
            SmtpClient client = null;
            try
            {
                MailMessage message = new MailMessage();
                message.From = new MailAddress(from, name);
                message.To.Add(to);
                message.Subject = subject;
                message.Body = body;
                client = new SmtpClient();
                //Configuration configurationFile = WebConfigurationManager.OpenWebConfiguration("~/");
                //MailSettingsSectionGroup mailSettings = (MailSettingsSectionGroup)configurationFile.GetSectionGroup("system.net/mailSettings");

                //client.Host = mailSettings.Smtp.Network.Host.ToString();
                //client.Port = mailSettings.Smtp.Network.Port;
                message.IsBodyHtml = true;
                client.Send(message);
            }
            catch (Exception ex)
            {
                Logger log = new Logger();
                log.WriteException(ex.ToString() + " " + client.Host.ToString() + " " + client.Port.ToString());
            }
        }

        /// <summary>
        /// Sends Email with CC
        /// </summary>
        /// <param name="to"></param>
        /// <param name="subject"></param>
        /// <param name="body"></param>
        /// <param name="cc"></param>
        public static void SendMail(string to, string subject, string body, string cc)
        {
            var from = Util.GetAppConfigKeyValue("FromMailID");
            SmtpClient client = new SmtpClient();
            MailMessage message = new MailMessage(from, to, subject, body);
            message.CC.Add(cc);
            message.IsBodyHtml = true;
            client.Send(message);
        }

        /// <summary>
        /// Sends Mail with CC and BCC
        /// </summary>
        /// <param name="to"></param>
        /// <param name="subject"></param>
        /// <param name="body"></param>
        /// <param name="cc"></param>
        /// <param name="bcc"></param>
        public static void SendMail(string to, string subject, string body, string cc, string bcc)
        {
            var from = Util.GetAppConfigKeyValue("FromMailID");
            SmtpClient client = new SmtpClient();
            MailMessage message = new MailMessage(from, to, subject, body);
            message.CC.Add(cc);
            message.Bcc.Add(bcc);
            message.IsBodyHtml = true;
            client.Send(message);
        }

        /// <summary>
        /// Sends Email with an attachment
        /// </summary>
        /// <param name="to"></param>
        /// <param name="subject"></param>
        /// <param name="body"></param>
        /// <param name="filepath"></param>
        public static void SendMailWithAttachment(string to, string subject, string body, string filepath)
        {
            var from = Util.GetAppConfigKeyValue("FromMailID");
            SmtpClient client = new SmtpClient();
            byte[] content = System.IO.File.ReadAllBytes(filepath);
            Attachment attach = new Attachment(new MemoryStream(content, true), "attachement.pdf");
            MailMessage message = new MailMessage(from, to, subject, body);
            message.IsBodyHtml = true;
            message.Attachments.Add(attach);
            client.Send(message);

            if (File.Exists(filepath))
            {
                File.Delete(filepath);
            }
        }

        public static void SendEmbeddedMail(string from, string name, string to, string subject, string body)
        {
            SmtpClient client = null;
            var url = Util.GetAppConfigKeyValue("ServerURL");

            try
            {
                MailMessage message = new MailMessage();
                message.From = new MailAddress(from, name);
                message.To.Add(to);
                message.Subject = subject;
                //  message.Body = body;
                string imageurl = @"" + url + "/Content/images/logo.png";
                string path = HttpContext.Current.Server.MapPath("~/Content/images/logo.jpg");
                LinkedResource logo = new LinkedResource(path);
                logo.ContentId = "image0";
                body = body.Replace(imageurl, "cid:image0");
                AlternateView av1 = AlternateView.CreateAlternateViewFromString(body, Encoding.UTF8, MediaTypeNames.Text.Html);
                //AlternateView htmlView  = AlternateView.CreateAlternateViewFromString(msgBody, Encoding.UTF8, MediaTypeNames.Text.Html);
                av1.LinkedResources.Add(logo);
                message.AlternateViews.Add(av1);
                client = new SmtpClient(); 
                message.IsBodyHtml = true;
                client.Send(message);
            }
            catch (Exception ex)
            {
                Logger log = new Logger();
                log.WriteException(ex.ToString() + " " + client.Host.ToString() + " " + client.Port.ToString());
            }
        }
    }
}
