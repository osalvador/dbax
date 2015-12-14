--
-- DBAX_COOKIE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_cookie
AS
   PROCEDURE load_cookies (p_cookies IN VARCHAR2 DEFAULT NULL )
   AS
      l_http_cookie   VARCHAR2 (32767);
      l_name          VARCHAR2 (4000);
   BEGIN
      --Load HTTP Cookie string
      l_http_cookie := NVL (p_cookies, OWA_UTIL.get_cgi_env ('HTTP_COOKIE'));

      --Parse Cookie String to g$req_cookies array
      g$req_cookies := dbax_utils.query_string_to_array (l_http_cookie, '; ', '=');
      
      --For Trace Only
      dbax_log.trace ('load_cookies from http_cookie=' || l_http_cookie);
      l_name      := g$req_cookies.FIRST;

      LOOP
         EXIT WHEN l_name IS NULL;
         dbax_log.trace ('load_cookies ' || l_name || '=' || g$req_cookies (l_name));
         l_name      := g$req_cookies.NEXT (l_name);
      END LOOP;
   END load_cookies;

   FUNCTION generate_cookie_header
      RETURN VARCHAR2
   AS
      l_name        VARCHAR2 (4000);
      l_return      VARCHAR2 (32000);
      expires_gmt   DATE;
   BEGIN
      l_name      := g$res_cookies.FIRST;

      LOOP
         EXIT WHEN l_name IS NULL;

         l_return    := l_return || 'Set-Cookie: ' || l_name || '=' || g$res_cookies (l_name).VALUE;

         IF g$res_cookies (l_name).domain IS NOT NULL
         THEN
            l_return    := l_return || '; Domain=' || g$res_cookies (l_name).domain;
         END IF;

         IF g$res_cookies (l_name).PATH IS NOT NULL
         THEN
            l_return    := l_return || '; Path=' || g$res_cookies (l_name).PATH;
         END IF;

         -- When setting the cookie expiration header
         -- we need to set the nls date language to AMERICAN
         --IF (OWA_CUSTOM.dbms_server_gmtdiff IS NOT NULL)
         --THEN
         --   expires_gmt := g$res_cookies (l_name).expires - (OWA_CUSTOM.dbms_server_gmtdiff / 24);
         --ELSE
         --  expires_gmt := NEW_TIME (g$res_cookies (l_name).expires, OWA_CUSTOM.dbms_server_timezone, 'GMT');
         --END IF;
         expires_gmt := g$res_cookies (l_name).expires;

         IF expires_gmt IS NOT NULL
         THEN
            l_return    :=
                  l_return
               || '; Expires='
               || RTRIM (TO_CHAR (expires_gmt, 'Dy', 'NLS_DATE_LANGUAGE = American'))
               || TO_CHAR (expires_gmt, ', DD-Mon-YYYY HH24:MI:SS', 'NLS_DATE_LANGUAGE = American')
               || ' GMT';
         END IF;

         IF g$res_cookies (l_name).secure
         THEN
            l_return    := l_return || '; Secure';
         END IF;

         IF g$res_cookies (l_name).httponly
         THEN
            l_return    := l_return || '; HttpOnly';
         END IF;

         l_return    := l_return || CHR (10);

         l_name      := g$res_cookies.NEXT (l_name);
      END LOOP;

      IF l_return IS NOT NULL
      THEN
        dbax_log.debug ('generate_cookie_header='||l_return);
      END IF;

      RETURN l_return;
   END generate_cookie_header;
END dbax_cookie;
/


