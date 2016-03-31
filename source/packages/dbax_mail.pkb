CREATE OR REPLACE PACKAGE BODY dbax.dbax_mail
IS
   g_smtp_host        VARCHAR2 (256);
   g_smtp_port        PLS_INTEGER; 
   g_smtp_domain      VARCHAR2 (256); 
   g_smtp_user        VARCHAR2 (256); 
   g_smtp_password    VARCHAR2 (256); 

   -- Write a MIME header
   PROCEDURE write_mime_header (p_conn IN OUT NOCOPY UTL_SMTP.connection, p_name IN VARCHAR2, p_value IN VARCHAR2)
   IS
   BEGIN
      UTL_SMTP.write_data (p_conn, p_name || ': ' || p_value || UTL_TCP.crlf);
   END;

   PROCEDURE send (p_recipient IN VARCHAR2, p_subject IN VARCHAR2, p_message IN VARCHAR2)
   IS
      l_conn        UTL_SMTP.connection;
      nls_charset   VARCHAR2 (255);

      l_subject     VARCHAR2 (32767);
      l_message     VARCHAR2 (32767);
   BEGIN
      -- get characterset
      SELECT   VALUE
        INTO   nls_charset
        FROM   nls_database_parameters
       WHERE   parameter = 'NLS_CHARACTERSET';

      -- establish connection and autheticate
      l_conn      := UTL_SMTP.open_connection (g_smtp_host, g_smtp_port);
      UTL_SMTP.ehlo (l_conn, g_smtp_domain);
      UTL_SMTP.command (l_conn, 'auth login');
      UTL_SMTP.command (l_conn, UTL_ENCODE.text_encode (g_smtp_user, nls_charset, 1));
      UTL_SMTP.command (l_conn, UTL_ENCODE.text_encode (g_smtp_password, nls_charset, 1));
      -- set from/recipient
      UTL_SMTP.command (l_conn, 'MAIL FROM: <' || g_smtp_user || '>');
      UTL_SMTP.command (l_conn, 'RCPT TO: <' || p_recipient || '>');


      -- encode subject text
      l_subject   := UTL_ENCODE.text_encode (p_subject, nls_charset, UTL_ENCODE.quoted_printable);
      l_subject   := '=?utf-8?Q?' || l_subject || '?=';
      -- write mime headers
      UTL_SMTP.open_data (l_conn);

      write_mime_header (l_conn, 'MIME-version', '1.0');
      write_mime_header (l_conn, 'From', g_smtp_user);
      write_mime_header (l_conn, 'To', p_recipient);
      write_mime_header (l_conn, 'Subject', l_subject);
      write_mime_header (l_conn, 'Content-Type', 'text/html;charset=utf-8');
      write_mime_header (l_conn, 'Content-Transfer-Encoding', 'quoted-printable');
      write_mime_header (l_conn, 'X-Mailer', 'dbax mail API through Oracle UTL_SMTP');
      UTL_SMTP.write_data (l_conn, UTL_TCP.crlf);
      -- write message body
      UTL_SMTP.write_raw_data (l_conn, UTL_ENCODE.quoted_printable_encode (UTL_RAW.cast_to_raw (p_message)));
      UTL_SMTP.close_data (l_conn);
      -- end connection
      UTL_SMTP.quit (l_conn);
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            UTL_SMTP.quit (l_conn);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;
         RAISE;
   END send;

   PROCEDURE set_connection (p_smtp_host        IN VARCHAR2
                           , p_smtp_port        IN PLS_INTEGER
                           , p_smtp_domain      IN VARCHAR2
                           , p_smtp_user        IN VARCHAR2
                           , p_smtp_password    IN VARCHAR2)
   AS
   BEGIN
      g_smtp_host := p_smtp_host;
      g_smtp_port := p_smtp_port;
      g_smtp_domain := p_smtp_domain;
      g_smtp_user := p_smtp_user;
      g_smtp_password := p_smtp_password;
   END set_connection;
END dbax_mail;
/