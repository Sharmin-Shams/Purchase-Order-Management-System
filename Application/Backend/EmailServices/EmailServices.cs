using CodeNB.Model;
using MailKit.Net.Smtp;
using MimeKit;

namespace EmailServices
{
    public class EmailService
    {
        public class EmailConfiguration
        {
            public string? From { get; set; }
            public string? SmtpServer { get; set; }
            public int port { get; set; }
            public string? Username { get; set; }
            public string? Password { get; set; }


        }

        public class EmailMessageDto
        {

            public List<MailboxAddress>? To { get; set; }
            public string? Subject { get; set; }
            public string? Content { get; set; }
            public List<MailboxAddress>? CC { get; set; } = [];
            public EmailMessageDto(
                IEnumerable<string> to,
                string subject,
                string content,
                 IEnumerable<string>? cc = null)
            {
                To = new List<MailboxAddress>();
                To.AddRange(to.Select(x => new MailboxAddress(string.Empty, x)));
                Subject = subject;
                Content = content;

                if (cc != null)
                    CC = cc.Select(x => new MailboxAddress(string.Empty, x)).ToList();
            }
        }

        public interface IEmailSender
        {
            void SendEmail(EmailMessageDto message);
        }

        public class EmailSender : IEmailSender
        {
            private readonly EmailConfiguration _emailConfig;
            public EmailSender(EmailConfiguration emailConfig)
            {
                _emailConfig = emailConfig;
            }
            public void SendEmail(EmailMessageDto message)
            {
                var emailMessage = CreateEmailMessage(message);
                Send(emailMessage);
            }

            private MimeMessage CreateEmailMessage(EmailMessageDto message)
            {
                var emailMessage = new MimeMessage();
                emailMessage.From.Add(new MailboxAddress(string.Empty, _emailConfig.From));

                if (message.CC != null)
                    emailMessage.Cc.AddRange(message.CC);
                
                emailMessage.To.AddRange(message.To);
                emailMessage.Subject = message.Subject;
                emailMessage.Body = new TextPart(MimeKit.Text.TextFormat.Text) { Text = message.Content };
                return emailMessage;
            }

            private void Send(MimeMessage emailMessage)
            {

                using (var client = new SmtpClient())
                {
                    try
                    {
                        client.Connect(_emailConfig.SmtpServer, _emailConfig.port);
                        // client.Authenticate(_emailConfig.Username, _emailConfig.Password);

                        client.Send(emailMessage);
                    }
                    catch
                    {

                        throw;
                    }
                    finally
                    {
                        client.Disconnect(true);
                        client.Dispose();
                    }
                }

            }
        }
    }
}