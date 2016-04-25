CREATE OR REPLACE PACKAGE BODY dbax.dbax_log
AS
   --Default Log level is ERROR
   g_log_level   NUMBER := k_log_level_error;
   g_log         CLOB;

   FUNCTION is_numeric (str IN VARCHAR2)
      RETURN BOOLEAN
   IS
      val   NUMBER (10);
   BEGIN
      val         := TO_NUMBER (str);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END is_numeric;


   FUNCTION get_log_level (p_log_level IN VARCHAR2)
      RETURN NUMBER
   AS
      l_returnvalue   NUMBER;
   BEGIN
      l_returnvalue :=
         CASE p_log_level
            WHEN k_log_level_none_str THEN k_log_level_none
            WHEN k_log_level_error_str THEN k_log_level_error
            WHEN k_log_level_warn_str THEN k_log_level_warn
            WHEN k_log_level_info_str THEN k_log_level_info
            WHEN k_log_level_debug_str THEN k_log_level_debug
            WHEN k_log_level_trace_str THEN k_log_level_trace
            ELSE k_log_level_none
         END;

      RETURN l_returnvalue;
   END get_log_level;

   FUNCTION get_log_level_str (p_log_level IN NUMBER)
      RETURN VARCHAR2
   AS
      l_returnvalue   VARCHAR2 (11);
   BEGIN
      l_returnvalue :=
         CASE p_log_level
            WHEN k_log_level_none THEN k_log_level_none_str
            WHEN k_log_level_error THEN k_log_level_error_str
            WHEN k_log_level_warn THEN k_log_level_warn_str
            WHEN k_log_level_info THEN k_log_level_info_str
            WHEN k_log_level_debug THEN k_log_level_debug_str
            WHEN k_log_level_trace THEN k_log_level_trace_str
            ELSE k_log_level_none_str
         END;

      RETURN l_returnvalue;
   END get_log_level_str;

   PROCEDURE open_log (p_log_level IN VARCHAR2)
   AS
   BEGIN
      g_log_level := get_log_level (LOWER (p_log_level));
   END open_log;

   FUNCTION get_log_context
      RETURN VARCHAR2
   AS
   BEGIN
      RETURN g_log_level;
   END get_log_context;

   PROCEDURE close_log
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_cgi_env      VARCHAR2 (32000);
      l_log_rt       tapi_wdx_log.wdx_log_rt;
      l_session_id   wdx_sessions.session_id%TYPE;
   BEGIN
      --If DEBUG
      IF g_log_level >= 4
      THEN
         g_log       :=
            g_log || CHR (10) || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff') || ' debug CGI ENV ' || CHR (10);

         FOR i IN 1 .. OWA.num_cgi_vars
         LOOP
            g_log       := g_log || CHR (9) || OWA.cgi_var_name (i) || ' = ' || OWA.cgi_var_val (i) || CHR (10);
         END LOOP;
      END IF;


      IF g_log IS NOT NULL
      THEN
         IF dbax_session.g$session.EXISTS ('session_id')
         THEN
            l_session_id := dbax_session.g$session ('session_id');
         END IF;

         l_log_rt.appid := NVL (dbax_core.g$appid, 'DEFAULT');
         l_log_rt.dbax_session := l_session_id;
         l_log_rt.log_user := NVL (dbax_security.get_username (dbax_core.g$appid, l_session_id), USER);
         l_log_rt.log_level := get_log_level_str (g_log_level);
         l_log_rt.log_text := g_log;

         tapi_wdx_log.ins (l_log_rt);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Log never raise error
         BEGIN
            g_log       := g_log || CHR (10) || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();

            l_log_rt.appid := NVL (dbax_core.g$appid, 'NULL');
            l_log_rt.dbax_session := 'DBAX_LOG ERROR!';
            l_log_rt.log_user := USER;
            l_log_rt.log_level := 'error';
            l_log_rt.log_text := g_log;

            tapi_wdx_log.ins (l_log_rt);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         COMMIT;
   END close_log;

   PROCEDURE trace (p_log_text IN CLOB)
   AS
      oname           VARCHAR2 (100);
      pname           VARCHAR2 (100);
      lnumb           VARCHAR2 (100);
      callr           VARCHAR2 (100);
      who_called_me   VARCHAR2 (400);
   BEGIN
      OWA_UTIL.who_called_me (oname
                            , pname
                            , lnumb
                            , callr);
      who_called_me := oname || '.' || pname || ':' || lnumb;

      IF k_log_level_trace <= g_log_level
      THEN
         g_log       :=
               g_log
            || CHR (10)
            || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff')
            || ' '
            || k_log_level_trace_str
            || ' '
            || who_called_me
            || ' '
            || p_log_text;
      END IF;
   END trace;


   PROCEDURE debug (p_log_text IN CLOB)
   AS
      oname           VARCHAR2 (100);
      pname           VARCHAR2 (100);
      lnumb           VARCHAR2 (100);
      callr           VARCHAR2 (100);
      who_called_me   VARCHAR2 (400);
   BEGIN
      OWA_UTIL.who_called_me (oname
                            , pname
                            , lnumb
                            , callr);
      who_called_me := oname || '.' || pname || ':' || lnumb;

      IF k_log_level_debug <= g_log_level
      THEN
         g_log       :=
               g_log
            || CHR (10)
            || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff')
            || ' '
            || k_log_level_debug_str
            || ' '
            || who_called_me
            || ' '
            || p_log_text;
      END IF;
   END debug;

   PROCEDURE info (p_log_text IN CLOB)
   AS
      oname           VARCHAR2 (100);
      pname           VARCHAR2 (100);
      lnumb           VARCHAR2 (100);
      callr           VARCHAR2 (100);
      who_called_me   VARCHAR2 (400);
   BEGIN
      OWA_UTIL.who_called_me (oname
                            , pname
                            , lnumb
                            , callr);
      who_called_me := oname || '.' || pname || ':' || lnumb;

      IF k_log_level_info <= g_log_level
      THEN
         g_log       :=
               g_log
            || CHR (10)
            || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff')
            || ' '
            || k_log_level_info_str
            || ' '
            || who_called_me
            || ' '
            || p_log_text;
      END IF;
   END info;


   PROCEDURE warn (p_log_text IN CLOB)
   AS
      oname           VARCHAR2 (100);
      pname           VARCHAR2 (100);
      lnumb           VARCHAR2 (100);
      callr           VARCHAR2 (100);
      who_called_me   VARCHAR2 (400);
   BEGIN
      OWA_UTIL.who_called_me (oname
                            , pname
                            , lnumb
                            , callr);
      who_called_me := oname || '.' || pname || ':' || lnumb;

      IF k_log_level_warn <= g_log_level
      THEN
         g_log       :=
               g_log
            || CHR (10)
            || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff')
            || ' '
            || k_log_level_warn_str
            || ' '
            || who_called_me
            || ' '
            || p_log_text;
      END IF;
   END warn;

   PROCEDURE error (p_log_text IN CLOB)
   AS
      oname           VARCHAR2 (100);
      pname           VARCHAR2 (100);
      lnumb           VARCHAR2 (100);
      callr           VARCHAR2 (100);
      who_called_me   VARCHAR2 (400);
   BEGIN
      OWA_UTIL.who_called_me (oname
                            , pname
                            , lnumb
                            , callr);
      who_called_me := oname || '.' || pname || ':' || lnumb;

      IF k_log_level_error <= g_log_level
      THEN
         g_log       :=
               g_log
            || CHR (10)
            || TO_CHAR (SYSTIMESTAMP, 'dd-mm-yyyy hh24:mi:ss.ff')
            || ' '
            || k_log_level_error_str
            || ' '
            || who_called_me
            || ' '
            || p_log_text;
      END IF;
   END error;
END dbax_log;
/