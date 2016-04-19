--
-- DBAX_SESSION  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_session
AS
   PROCEDURE load_session_variable (p_session_variable IN VARCHAR2)
   AS
      l_assoc_array   dbax_core.g_assoc_array;
      l_key           VARCHAR2 (4000);
   BEGIN
      l_assoc_array := dbax_utils.query_string_to_array (p_session_variable);

      --Concatenate with g$session array
      l_key       := l_assoc_array.FIRST;

      LOOP
         EXIT WHEN l_key IS NULL;
         g$session (l_key) := l_assoc_array (l_key);
         l_key       := l_assoc_array.NEXT (l_key);
      END LOOP;
   END load_session_variable;

   FUNCTION valid_session (p_session_id IN VARCHAR2)
      RETURN BOOLEAN
   AS
      l_applications_rt   tapi_wdx_applications.wdx_applications_rt;
   BEGIN
      FOR c1 IN (SELECT   1
                   FROM   wdx_sessions
                  WHERE   session_id = p_session_id AND appid = dbax_core.g$appid AND expired = '0')
      LOOP
         RETURN TRUE;
      END LOOP;

      RETURN FALSE;
   END valid_session;

   PROCEDURE update_session (p_username IN VARCHAR2 DEFAULT NULL )
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_cgi_env          VARCHAR2 (32000);
      v_username         VARCHAR2 (256) := NVL (p_username, 'ANONYMOUS');
      l_exists_session   BOOLEAN := FALSE;
   BEGIN
      --Guardo el entorno del usuario
      FOR i IN 1 .. OWA.num_cgi_vars
      LOOP
         v_cgi_env   := v_cgi_env || OWA.cgi_var_name (i) || ' = ' || OWA.cgi_var_val (i) || CHR (10);
      END LOOP;

      v_cgi_env   := SUBSTR (v_cgi_env, 1, 4000);

      dbax_log.trace('UPDATE_SESSION Username=' || v_username);

      IF g$session.EXISTS ('session_id')
      THEN
         FOR c1 IN (SELECT   appid, session_id, session_variable
                      FROM   wdx_sessions
                     WHERE   session_id = g$session ('session_id') AND appid = dbax_core.g$appid)
         LOOP
            dbax_log.trace('UPDATE_SESSION Session exists Update=' || g$session ('session_id'));

            l_exists_session := TRUE;

            load_session_variable (c1.session_variable);

            UPDATE   wdx_sessions
               SET /*expired = 0,*/
                  last_access = SYSTIMESTAMP, cgi_env = v_cgi_env
             WHERE   appid = c1.appid AND session_id = c1.session_id;
         END LOOP;
      END IF;

      IF NOT l_exists_session
      THEN
         dbax_log.trace('UPDATE_SESSION Session Not exists Inserting=' || g$session ('session_id'));

         --Gaurdo la session
         INSERT INTO wdx_sessions (appid
                                 , session_id
                                 , username
                                 , expired
                                 , created_date
                                 , last_access
                                 , cgi_env)
           VALUES   (NVL (dbax_core.g$appid, 'DEFAULT')
                   , g$session ('session_id')
                   , UPPER (v_username)
                   , 0
                   , SYSTIMESTAMP
                   , NULL
                   , v_cgi_env);
      END IF;

      COMMIT;
   END update_session;

   FUNCTION get_session (p_cookies IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
      --v_my_session     OWA_COOKIE.cookie;
      l_cookie_name    VARCHAR2 (2000);
      l_cookie_value   VARCHAR2 (200);
      l_session_id     VARCHAR2 (200);
      --
      v_owner                  VARCHAR2 (32767);
      v_name                   VARCHAR2 (32767);
      v_lineno                 NUMBER;
      v_caller_t               VARCHAR2 (32767);
      v_whois                  VARCHAR2 (32767);
   BEGIN
      l_cookie_name := dbax_core.get_property ('session_cookie_name');
      dbax_log.trace('GET_SESSION l_cookie_name=' || l_cookie_name);

      IF p_cookies IS NOT NULL
      THEN
         dbax_log.trace('GET_SESSION p_cookies=' || p_cookies);
         dbax_cookie.load_cookies (p_cookies);
      END IF;

      IF dbax_utils.get (g$session, 'session_id') IS NULL
      THEN        
         IF dbax_utils.get (dbax_cookie.g$req_cookies, l_cookie_name) IS NULL
         THEN
            --No cookie session
            dbax_log.trace('GET_SESSION  No Cookie session');
            g$session ('session_id') := NULL;
            RETURN NULL;
         ELSE
            --l_session_id := v_my_session.vals (1);
            l_session_id := dbax_cookie.g$req_cookies (l_cookie_name);
            dbax_log.trace('GET_SESSION Cookie session is not null=' || l_session_id);

            IF valid_session (l_session_id)
            THEN
               dbax_log.trace('GET_SESSION Session is valid ' || l_session_id);
               g$session ('session_id') := l_session_id;
            ELSE
               dbax_log.trace('GET_SESSION Session is Not valid ' || l_session_id);
               g$session ('session_id') := NULL;
               RETURN NULL;
            END IF;
         END IF;
      ELSIF NOT valid_session (g$session ('session_id'))
      THEN
         RETURN NULL;
      END IF;

      update_session;

      dbax_log.info ('Returning session_id=' || dbax_utils.get (g$session, 'session_id'));
      RETURN dbax_utils.get (g$session, 'session_id');
   END get_session;

   /* Inicia una nueva session, se genera el ticket en al tabla de sesiones. Se define la caducidad de la misma*/
   PROCEDURE session_start (p_username IN VARCHAR2 DEFAULT NULL , p_session_expires IN DATE DEFAULT NULL )
   AS
      l_session_id    VARCHAR2 (50);
      l_cookie_name   VARCHAR2 (255);
   BEGIN
      l_cookie_name := dbax_core.get_property ('session_cookie_name');
      
      -- If the session not exists
      -- IF dbax_utils.get (g$session, 'session_id') IS NULL
      --    AND dbax_utils.get (dbax_cookie.g$req_cookies, l_cookie_name) IS NULL
      -- THEN
      --Generamos el id de la session
      l_session_id := DBMS_SESSION.unique_session_id || ROUND (DBMS_RANDOM.VALUE (10000, 99999));
      --Creo cookie
      dbax_cookie.g$res_cookies (l_cookie_name).VALUE := l_session_id;
      dbax_cookie.g$res_cookies (l_cookie_name).expires := p_session_expires;
      dbax_cookie.g$res_cookies (l_cookie_name).PATH := '/';
      -- ELSE
      --    l_session_id :=
      --       NVL (dbax_utils.get (dbax_cookie.g$req_cookies, l_cookie_name), dbax_utils.get (g$session, 'session_id'));
      -- END IF;

      --Global user session variable
      g$session ('session_id') := l_session_id;

      update_session (p_username);
   END session_start;

   /*Finaliza una sesion. Borra las cookies del usaurio y borra las variables globales*/

   PROCEDURE session_end
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_session_id    VARCHAR2 (50);
      l_cookie_name   VARCHAR2 (255) := dbax_core.get_property ('session_cookie_name');
   BEGIN
      l_session_id := get_session ();

      UPDATE   wdx_sessions
         SET   expired = '1', last_access = SYSTIMESTAMP
       WHERE   session_id = l_session_id AND appid = dbax_core.g$appid;

      COMMIT;

      --Remove cookie Session
      dbax_cookie.g$res_cookies (l_cookie_name).VALUE := 'session_end';
      dbax_cookie.g$res_cookies (l_cookie_name).expires := SYSDATE - 100;
      dbax_cookie.g$res_cookies (l_cookie_name).PATH := '/';

      --Remove g$session
      g$session.delete;
   END session_end;

   PROCEDURE save_sesison_variable
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_session_variable   VARCHAR2 (4000);
   BEGIN
      IF g$session.EXISTS ('session_id')
      THEN
         l_session_variable := dbax_utils.array_to_query_string (g$session);

         FOR c1 IN (SELECT   appid, session_id
                      FROM   wdx_sessions
                     WHERE   session_id = g$session ('session_id') AND appid = dbax_core.g$appid)
         LOOP
            UPDATE   wdx_sessions
               SET   session_variable = l_session_variable
             WHERE   appid = c1.appid AND session_id = c1.session_id;
         END LOOP;

         COMMIT;
      END IF;
   END save_sesison_variable;

   PROCEDURE reset_sesison_variable
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_session_id   VARCHAR2 (50);
   BEGIN
      l_session_id := get_session ();

      UPDATE   wdx_sessions
         SET   session_variable = NULL
       WHERE   session_id = l_session_id AND appid = dbax_core.g$appid;

      COMMIT;

      --Remove g$session
      g$session.delete;
   END reset_sesison_variable;
END dbax_session;
/


