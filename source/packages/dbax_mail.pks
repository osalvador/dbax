CREATE OR REPLACE PACKAGE dbax_mail
IS
   /**
  * DBAX_MAIL
  *
  * Description: Send an email through a server that requires authentication
  */

   /**
  * Send an email to the recipients
  *
  * @param  p_recipient      The email address of the recipient.
  * @param  p_subject        The email subject.
  * @param  p_message        The email message.
  */
   PROCEDURE send (p_recipient IN VARCHAR2, p_subject IN VARCHAR2, p_message IN VARCHAR2);

   /**
  * Set connection parameters to the smtp server
  *
  * @param p_smtp_host      The SMTP host name to connect to
  * @param p_smtp_port      The port number of the SMTP server to connect to
  * @param p_smtp_domain    The domain of the sender
  * @param p_smtp_user      The SMPT user for auth login
  * @param p_smtp_password  The SMPT password for auth login
  */
   PROCEDURE set_connection (p_smtp_host       IN VARCHAR2
                           , p_smtp_port       IN PLS_INTEGER
                           , p_smtp_domain     IN VARCHAR2
                           , p_smtp_user       IN VARCHAR2
                           , p_smtp_password   IN VARCHAR2);
END dbax_mail;
/