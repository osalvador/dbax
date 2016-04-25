CREATE OR REPLACE PACKAGE BODY dbax_core
AS
   PROCEDURE print_http_header;

   PROCEDURE set_request (name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                        , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr );

   PROCEDURE print_owa_page (p_thepage IN HTP.htbuf_arr, p_lines IN NUMBER)
   AS
      l_found     BOOLEAN := FALSE;
      l_thepage   HTP.htbuf_arr := p_thepage;
   BEGIN
      --Response content start with <!--DBAX-->
      FOR i IN 1 .. p_lines
      LOOP
         IF NOT l_found
         THEN
            l_found     := l_thepage (i) LIKE '%<!%';

            IF l_found
            THEN
               l_thepage (i) := REPLACE (l_thepage (i), '<!--DBAX-->');
            END IF;
         END IF;

         IF l_found
         THEN
            HTP.prn (l_thepage (i));
         END IF;
      END LOOP;
   END print_owa_page;

   FUNCTION get_property (p_key IN wdx_properties.key%TYPE)
      RETURN VARCHAR2
   AS
      v_value   wdx_properties.VALUE%TYPE;
   BEGIN
      SELECT /*+ result_cache */
            VALUE
        INTO   v_value
        FROM   wdx_properties
       WHERE   key = LOWER (get_property.p_key) AND appid = g$appid;

      RETURN v_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_property;

   PROCEDURE routing (p_path                IN     VARCHAR2
                    , p_controller_method      OUT VARCHAR2
                    , p_view_name              OUT VARCHAR2
                    , p_return_path            OUT VARCHAR2)
   AS
      l_retval            PLS_INTEGER := 0;
      l_return            VARCHAR2 (1000);
      l_replace_string    VARCHAR2 (1000);
      l_position          PLS_INTEGER;
      l_occurrence        PLS_INTEGER;
      l_match_parameter   VARCHAR2 (100);

      /**
      * Gets the regex variables from the string
      */
      PROCEDURE advanced_regex (p_string            IN     VARCHAR2
                              , p_pattern              OUT VARCHAR2
                              , p_postion              OUT PLS_INTEGER
                              , p_occurrence           OUT PLS_INTEGER
                              , p_match_parameter      OUT VARCHAR2)
      AS
         l_regex_pos   PLS_INTEGER;
         l_param_tab   DBMS_UTILITY.maxname_array;
      BEGIN
         l_regex_pos := INSTR (p_string, '@', -1);

         IF l_regex_pos <> 0
         THEN
            p_pattern   := SUBSTR (p_string, 1, l_regex_pos - 1);

            l_param_tab := dbax_utils.tokenizer (SUBSTR (p_string, l_regex_pos + 1));

            IF l_param_tab.EXISTS (1) AND l_param_tab (1) IS NOT NULL
            THEN
               p_postion   := l_param_tab (1);
            ELSE
               p_postion   := 1;
            END IF;

            IF l_param_tab.EXISTS (2)
            THEN
               p_occurrence := l_param_tab (2);
            ELSE
               p_occurrence := 0;
            END IF;

            IF l_param_tab.EXISTS (3)
            THEN
               p_match_parameter := l_param_tab (3);
            END IF;
         ELSE
            --Default values
            p_pattern   := p_string;
            p_postion   := 1;
            p_occurrence := NULL; --The default value of REGEX_INSTR is 1, but default value for REGEX_REPLACE is 0.
            p_match_parameter := NULL;
         END IF;
      END;
   BEGIN
      /**
      * Regex URL pattern
      * regex_patren@position,occurrence,match_parameter
      *
      * Regex Controller replace
      * replace_string@position,occurrence,match_parameter
      */

      FOR c1 IN (  SELECT /*+ result_cache */
                         route_name
                          , url_pattern
                          , controller_method
                          , view_name
                     FROM   wdx_map_routes
                    WHERE   appid = g$appid AND active = 'Y'
                 ORDER BY   priority)
      LOOP
         advanced_regex (c1.url_pattern
                       , c1.url_pattern
                       , l_position
                       , l_occurrence
                       , l_match_parameter);

         c1.url_pattern := '^' || c1.url_pattern || '(/|$)';

         /*dbax_log.trace(   'Parameters for REGEXP_INSTR: '
                        || CHR (10)
                        || 'source_char='
                        || p_path
                        || CHR (10)
                        || 'pattern='
                        || c1.url_pattern
                        || CHR (10)
                        || 'position='
                        || l_position
                        || CHR (10)
                        || 'occurrence='
                        || NVL (l_occurrence, 1)
                        || CHR (10)
                        || 'match_parameter='
                        || l_match_parameter);*/

         BEGIN
            l_retval    :=
               REGEXP_INSTR (p_path
                           , c1.url_pattern
                           , l_position
                           , NVL (l_occurrence, 1)
                           , '0'
                           , l_match_parameter);
         EXCEPTION
            WHEN OTHERS
            THEN
               l_retval    := 0;
               dbax_log.error(   'Routing error with '
                              || c1.route_name
                              || ' route. Check the advanced parameters to REGEXP_INSTR in the URL Pattern. '
                              || SQLERRM);
         END;


         IF l_retval > 0
         THEN
            dbax_log.debug ('Route Matched:' || c1.route_name || ' URL_PATTERN:' || c1.url_pattern);

            l_replace_string := NVL (c1.controller_method, c1.view_name);

            advanced_regex (l_replace_string
                          , l_replace_string
                          , l_position
                          , l_occurrence
                          , l_match_parameter);

            /*dbax_log.trace(   'Parameters for REGEXP_REPLACE: '
                        || CHR (10)
                        || 'source_char='
                        || p_path
                        || CHR (10)
                        || 'pattern='
                        || c1.url_pattern
                        || CHR (10)
                        || 'replace_string='
                        || l_replace_string
                        || CHR (10)
                        || 'position='
                        || l_position
                        || CHR (10)
                        || 'occurrence='
                        || NVL (l_occurrence, 0)
                        || CHR (10)
                        || 'match_parameter='
                        || l_match_parameter);*/

            BEGIN
               l_return    :=
                  REGEXP_REPLACE (p_path
                                , c1.url_pattern
                                , l_replace_string || '/'
                                , l_position
                                , NVL (l_occurrence, 0)
                                , l_match_parameter);
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_return    := NULL;
                  dbax_log.error(   'Routing error with '
                                 || c1.route_name
                                 || ' route. Check the advanced parameters to REGEXP_REPLACE in Controller or Method. '
                                 || SQLERRM);
            END;

            p_return_path := l_return;

            --Split the l_return path
            IF INSTR (l_return, '/', 1) > 0
            THEN
               l_return    := SUBSTR (l_return, 1, INSTR (l_return, '/', 1) - 1);
            END IF;

            --Return Values
            IF c1.controller_method IS NOT NULL
            THEN
               p_controller_method := l_return;
            ELSIF c1.view_name IS NOT NULL
            THEN
               p_view_name := l_return;
            END IF;

            EXIT;
         END IF;
      END LOOP;
   END routing;

   PROCEDURE execute_controller (p_controller IN VARCHAR2)
   AS
      l_procedure   VARCHAR2 (100);
   BEGIN
      l_procedure := 'BEGIN ' || p_controller || '; END;';

      -- Execute l_procedure
      BEGIN
         EXECUTE IMMEDIATE l_procedure;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -06550
            THEN
               dbax_exception.raise (100, 'The controller that are trying to execute does not exist');
            ELSIF SQLCODE = -06503
            THEN
               --Function returned without value

               NULL;
            ELSE
               --TODO Log and Raise this exception
               dbax_exception.raise (SQLCODE, SQLERRM || ' <b>Executing: ' || p_controller || ' </b>');
            END IF;
      END;
   END execute_controller;

   /*This procedure load properties variables into view global variables ${name}*/
   PROCEDURE load_properties
   AS
   BEGIN
      FOR c1 IN (SELECT   key, VALUE
                   FROM   wdx_properties
                  WHERE   appid = g$appid)
      LOOP
         g$view (LOWER (c1.key)) := c1.VALUE;
      END LOOP;

      g$view ('appid') := g$appid;
   END;

   PROCEDURE log_array (p_array IN g_assoc_array)
   AS
      l_key   VARCHAR2 (256);
   BEGIN
      IF p_array.COUNT () <> 0
      THEN
         l_key       := p_array.FIRST;

         LOOP
            EXIT WHEN l_key IS NULL;
            dbax_log.debug (l_key || '=' || p_array (l_key));
            l_key       := p_array.NEXT (l_key);
         END LOOP;
      END IF;
   END log_array;


   PROCEDURE dispatcher (p_appid       IN VARCHAR2
                       , name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                       , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr )
   AS
      l_path             VARCHAR2 (4000);
      l_check_auth       VARCHAR2 (4);
      l_ret_arr          DBMS_UTILITY.maxname_array;
      --
      l_http_output      HTP.htbuf_arr;
      l_lines            NUMBER DEFAULT 99999999 ;
      --
      l_application_rt   tapi_wdx_applications.wdx_applications_rt;
      --
      e_stop_process exception;
      e_inactive_app exception;
   BEGIN
      -- 1. Definir la aplicacion
      -- 2. Obtener la URL para enrutar
      -- 2. Realizar Enrutado
      -- 3. A partir de la URL enrutada, o no, recuperar el Controlador, La funcion y los Parametros
      -- 4. Buscar la pagina en la cach¿. (por la URL)
      -- 4.1 SEGURIDAD. realiza un tratamiento de seguridad sobre la entrada que tengamos, tanto de la informaci¿n que haya en la URL como de la informaci¿n que haya en un posible POST
      -- 5. Invocar al controlador.funci¿n, los parametros podr¿n est¿r en un array global por ah¿...
      -- 6. Interpretar las vistas que el controlador ha cargado
      -- 7. Meter el HTML generado en la cach¿, si procede
      -- 8. Imprimir la pagina

      /***************
      *  1. Defining the application
      ***************/
      HTP.prn ('<!--DBAX-->');
      g$appid     := p_appid;

      --Defining log level
      dbax_log.open_log (get_property ('LOG_LEVEL'));
      dbax_log.info ('Start Dispatcher');
      dbax_log.info ('g$appid=' || g$appid);

      --Check active application
      l_application_rt := tapi_wdx_applications.rt_simple (p_appid);

      IF l_application_rt.active = 'N'
      THEN
         RAISE e_inactive_app;
      END IF;

      --Set Request parameters
      set_request (name_array, value_array);

      /***************
      * 4.1 Obtener la URL para enrutar
      ***************/

      --If is a queryString model, get de URL to route from reserved parameter 'p' in g$get or g$post array
      IF g$get.EXISTS ('p')
      THEN
         l_path      := '/' || p_appid || g$get ('p');
      ELSIF g$post.EXISTS ('p')
      THEN
         l_path      := '/' || p_appid || g$post ('p');
      ELSE
         l_path      := g$server ('PATH_INFO');
      END IF;

      --Split the URL
      IF INSTR (l_path, '/', 2) > 0
      THEN
         l_path      := SUBSTR (l_path, INSTR (l_path, '/', 2) + 1);
      ELSE
         l_path      := 'NULL';
      END IF;

      /***************
      *  2. Routing
      ***************/
      -- The l_path has <controller>/<parameter1>/<parameterN>
      IF l_path IS NULL
      THEN
         l_path      := 'NULL';
      END IF;

      dbax_log.debug ('Routing in l_path = ' || l_path);

      routing (p_path      => l_path
             , p_controller_method => g$controller
             , p_view_name => g$view_name
             , p_return_path => l_path);

      dbax_log.debug ('Routing Out l_path=' || l_path);
      dbax_log.info ('Routing Out g$controller=' || g$controller);
      dbax_log.info ('Routing Out g$view_name=' || g$view_name);

      /***************
      * 3. Get Controller
      ***************/

      --Split the URL
      IF INSTR (l_path, '/', 1) > 0
      THEN
         l_path      := SUBSTR (l_path, INSTR (l_path, '/', 1) + 1);
      ELSE
         l_path      := NULL;
      END IF;

      dbax_log.debug ('Tokeneizer In l_path=' || l_path);

      --Tokenizer the Url
      -- The l_path has <parameter1>/<parameterN>
      l_ret_arr   := dbax_utils.tokenizer (l_path, '/');

      --Parameters are the rest of the url
      IF l_ret_arr.EXISTS (1)
      THEN
         FOR i IN 1 .. l_ret_arr.LAST
         LOOP
            g$parameter (i) := l_ret_arr (i);
            dbax_log.info ('Paramter g$parameter(' || i || ') = ' || g$parameter (i));
         END LOOP;
      END IF;

      /***************
      * 3.1 Load Application properties
      ***************/
      --View Variables: ${name}
      load_properties;

      /***************
      * 3.1 Load User's cookies
      ***************/
      dbax_cookie.load_cookies;

      /***************
      * 3.1 Check authentication
      ***************/
      IF dbax_security.check_auth = '0'
      THEN
         /*
         * Loading login page
         */
         dbax_log.info ('User not logged. Redirect to login page');

         routing (p_path      => 'login'
                , p_controller_method => g$controller
                , p_view_name => g$view_name
                , p_return_path => l_path);
      END IF;


      IF g$view_name IS NOT NULL
      THEN
         load_view (g$view_name);
      END IF;

      IF FALSE
      THEN
         /***************
         * TODO 4. Get page from Cache
         ***************/
         NULL;
      ELSE
         /***************
         *  5. Execute controller
         ***************/
         IF g$controller IS NOT NULL
         THEN
            dbax_log.debug ('Start Execute Contoller ' || g$controller);
            execute_controller (g$controller);
            dbax_log.debug ('End Execute Contoller ' || g$controller);

            --Check stop_process
            IF g_stop_process
            THEN
               RAISE e_stop_process;
            END IF;
         END IF;
      END IF;

      --Page not Found
      IF g$view_name IS NULL AND g$controller IS NULL
      THEN
         --Load application Page not found
         dbax_log.info ('404 Page Not Found');
         load_view ('404');
         g$status_line := 404;
      END IF;

      /***************
      * TODO 7. Set page to cache
      ***************/

      OWA.get_page (l_http_output, l_lines);

      /***************
      *  8. Print Page
      ***************/
      IF NOT g_stop_process
      THEN
         HTP.init;
         OWA_UTIL.mime_header (g$content_type, FALSE, get_property ('ENCODING'));
         OWA_UTIL.status_line (nstatus => g$status_line, creason => NULL, bclose_header => FALSE);
         HTP.prn (dbax_cookie.generate_cookie_header);
         dbax_log.debug ('Print HTTP Header');
         print_http_header;
         OWA_UTIL.http_header_close;

         dbax_log.debug ('Print HTTP Data');
         print_owa_page (l_http_output, l_lines);

         IF g$view_name IS NOT NULL
         THEN
            dbax_log.debug ('Execute view: ' || g$view_name);
            dbax_teplsql.execute (p_template_name => g$view_name);
         END IF;
      ELSE
         dbax_log.debug ('Stop Process: TRUE');
      END IF;

      dbax_session.save_sesison_variable;
      dbax_log.close_log;
   EXCEPTION
      WHEN e_stop_process
      THEN
         dbax_session.save_sesison_variable;
         dbax_log.close_log;
      WHEN e_inactive_app
      THEN
         dbax_log.error ('Application ' || p_appid || ' is marked as inactive.');
         dbax_log.close_log;
      WHEN OTHERS
      THEN
         dbax_log.error (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_session.save_sesison_variable;
         --dbax_exception.raise (SQLCODE, SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_log.close_log;
         RAISE;
   END dispatcher;

   PROCEDURE load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
   AS
      l_source   CLOB;
   BEGIN
      dbax_log.debug ('Loading view ' || UPPER (p_name) || ' from application ' || NVL (p_appid, g$appid));

      SELECT /*+ result_cache */
            title, name
        INTO   dbax_core.g$view ('title'), g$view_name
        FROM   wdx_views
       WHERE   UPPER (name) = UPPER (p_name) AND appid = NVL (p_appid, g$appid) AND visible = 'Y';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END load_view;


   FUNCTION get_path (p_local_path IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
   BEGIN
      RETURN get_property ('BASE_PATH') || p_local_path;
   END get_path;


   FUNCTION request_validation_function (procedure_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_procedure_name   VARCHAR2 (300) := request_validation_function.procedure_name;
   BEGIN
      FOR c1 IN (SELECT   1
                   FROM   wdx_request_valid_function a
                  WHERE   UPPER (l_procedure_name) LIKE UPPER (a.procedure_name))
      LOOP
         RETURN TRUE;
      END LOOP;

      RETURN FALSE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END request_validation_function;

   --Establece los parametros globales g$get y g$set en funcion de la request realizada
   PROCEDURE set_request (name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                        , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr )
   AS
      l_query_string   g_assoc_array;
      --
      j                PLS_INTEGER;
      l_name_array     VARCHAR2 (255);
   BEGIN
      --Set server parameters get from CGI ENV
      FOR i IN 1 .. OWA.num_cgi_vars
      LOOP
         g$server (OWA.cgi_var_name (i)) := OWA.cgi_var_val (i);
      END LOOP;

      dbax_log.info ('REQUEST_METOD=' || g$server ('REQUEST_METHOD'));

      --Get QueryString params
      g$get       := dbax_utils.query_string_to_array (dbax_utils.get (g$server, 'QUERY_STRING'));

      IF g$server ('REQUEST_METHOD') = 'GET'
      THEN
         IF name_array.EXISTS (1) AND name_array (1) IS NOT NULL
         THEN
            FOR i IN name_array.FIRST .. name_array.LAST
            LOOP
               --if the parameter ends with [ ] it is an array
               IF name_array (i) LIKE '%[]'
               THEN
                  j           := 1;

                  --Set Name of the parameter[n]
                  l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';

                  --Generate Array index
                  WHILE g$get.EXISTS (l_name_array)
                  LOOP
                     j           := j + 1;
                     l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';
                  END LOOP;

                  g$get (LOWER (l_name_array)) := CONVERT (value_array (i), g$server ('REQUEST_CHARSET'), 'AL32UTF8');
                  dbax_log.debug (LOWER (l_name_array) || ':' || g$get (LOWER (l_name_array)));
               ELSE
                  g$get (LOWER (name_array (i))) := CONVERT (value_array (i), g$server ('REQUEST_CHARSET'), 'AL32UTF8');
                  dbax_log.debug (LOWER (name_array (i)) || ':' || g$get (LOWER (name_array (i))));
               END IF;
            END LOOP;
         END IF;
      ELSIF g$server ('REQUEST_METHOD') = 'POST'
      THEN
         IF name_array.EXISTS (1) AND name_array (1) IS NOT NULL
         THEN
            FOR i IN name_array.FIRST .. name_array.LAST
            LOOP
               --if the parameter ends with [ ] it is an array
               IF name_array (i) LIKE '%[]'
               THEN
                  j           := 1;

                  --Set Name of the parameter[n]
                  l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';

                  --Generate Array index
                  WHILE g$post.EXISTS (l_name_array)
                  LOOP
                     j           := j + 1;
                     l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';
                  END LOOP;

                  g$post (LOWER (l_name_array)) := CONVERT (value_array (i), g$server ('REQUEST_CHARSET'), 'AL32UTF8');
                  dbax_log.debug (LOWER (l_name_array) || ':' || g$post (LOWER (l_name_array)));
               ELSE
                  g$post (LOWER (name_array (i))) := CONVERT (value_array (i), g$server ('REQUEST_CHARSET'), 'AL32UTF8');
                  dbax_log.debug (LOWER (name_array (i)) || ':' || g$post (LOWER (name_array (i))));
               END IF;
            END LOOP;
         END IF;
      END IF;
   END set_request;

   PROCEDURE print_http_header
   AS
      l_key   VARCHAR2 (256);
   BEGIN
      IF g$http_header.COUNT () <> 0
      THEN
         l_key       := g$http_header.FIRST;

         LOOP
            EXIT WHEN l_key IS NULL;
            HTP.p (l_key || ':' || g$http_header (l_key));
            dbax_log.debug ('HTTP Header ' || l_key || ':' || g$http_header (l_key));
            l_key       := g$http_header.NEXT (l_key);
         END LOOP;
      END IF;
   END print_http_header;

   PROCEDURE PRINT (p_data IN CLOB)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;

   PROCEDURE p (p_data IN CLOB)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;

   PROCEDURE PRINT (p_data IN VARCHAR2)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;

   PROCEDURE p (p_data IN VARCHAR2)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;

   PROCEDURE PRINT (p_data IN NUMBER)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;

   PROCEDURE p (p_data IN NUMBER)
   AS
   BEGIN
      dbax_teplsql.p (p_data);
   END;
END dbax_core;
/