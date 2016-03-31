CREATE OR REPLACE PACKAGE BODY dbax_google_recaptcha
AS
   FUNCTION siteverify (p_recaptcha_response   IN VARCHAR2
                      , p_secret_key           IN VARCHAR2
                      , p_api_url              IN VARCHAR2 DEFAULT 'https://www.google.com/recaptcha/api/siteverify' )
      RETURN BOOLEAN
   AS
      req                 UTL_HTTP.req;
      res                 UTL_HTTP.resp;
      buffer              VARCHAR2 (32767);
      l_buffer_response   VARCHAR2 (32767);
      l_content           VARCHAR2 (4000);
      l_response          json;
   BEGIN
      --Make POST Request to google
      l_content   := 'secret=' || p_secret_key || '&response=' || p_recaptcha_response;

      req         := UTL_HTTP.begin_request (p_api_url, 'POST', ' HTTP/1.1');
      UTL_HTTP.set_header (req, 'user-agent', 'mozilla/4.0');
      UTL_HTTP.set_header (req, 'content-type', 'application/x-www-form-urlencoded');
      UTL_HTTP.set_header (req, 'Content-Length', LENGTH (l_content));

      UTL_HTTP.write_text (req, l_content);
      res         := UTL_HTTP.get_response (req);

      -- process the response from the HTTP call
      BEGIN
         LOOP
            UTL_HTTP.read_text (res, buffer);
            l_buffer_response := l_buffer_response || buffer;
         END LOOP;

         UTL_HTTP.end_response (res);
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (res);
      END;

      dbax_log.debug ('l_buffer_response = ' || l_buffer_response);

      --Parse resoponse
      l_response  := json (l_buffer_response);

      IF l_response.get ('success').get_bool = TRUE
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         dbax_log.error ('res.status_code = ' || res.status_code);
         dbax_log.error ('res.reason_phrase = ' || res.reason_phrase);
         dbax_log.error ('res.http_version  = ' || res.http_version);
         dbax_log.error ('res.private_hndl  = ' || res.private_hndl);
         dbax_log.error ('l_buffer_response = ' || l_buffer_response);
         dbax_log.error (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());

         RAISE;
   END siteverify;
END dbax_google_recaptcha;
/
