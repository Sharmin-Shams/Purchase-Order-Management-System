
using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;



namespace CodeNB.Service
{
    public class EmailService
    {
        //private readonly EmailConfiguration _emailConfig;
        //public EmailService(EmailConfiguration emailConfig)
        //{
        //    _emailConfig = emailConfig;
        //}
        //public void SendEmail(EmailMessageDto message)
        //{
        //    //var emailMessage = CreateEmailMessage(message);
        //    //Send(emailMessage);
        //}

        //private MimeMessage CreateEmailMessage(EmailMessageDto message)
        //{
        //    var emailMessage = new MimeMessage();
        //    emailMessage.From.Add(new MailboxAddress(string.Empty, _emailConfig.From));

        //    emailMessage.To.AddRange(message.To);
        //    emailMessage.Subject = message.Subject;
        //    emailMessage.Body = new TextPart(MimeKit.Text.TextFormat.Text) { Text = message.Content };
        //    return emailMessage;
        //}

        //private void Send(MimeMessage emailMessage)
        //{

        //    using (var client = new SmtpClient())
        //    {
        //        try
        //        {
        //            client.Connect(_emailConfig.SmtpServer, _emailConfig.port);
        //            // client.Authenticate(_emailConfig.Username, _emailConfig.Password);

        //            client.Send(emailMessage);
        //        }
        //        catch
        //        {

        //            throw;
        //        }
        //        finally
        //        {
        //            client.Disconnect(true);
        //            client.Dispose();
        //        }
        //    }

        //}
    }


}
