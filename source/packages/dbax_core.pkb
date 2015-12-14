--
-- DBAX_CORE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_core
AS
   /*Global Variables*/
   g_parser                 BOOLEAN := FALSE;

   --k_default_app CONSTANT   VARCHAR2 (50) := 'default';

   /*This function fetch de OWA page to CLOB*/
   FUNCTION dump_owa_page
      RETURN CLOB
   AS
      l_thepage   HTP.htbuf_arr;
      l_lines     NUMBER DEFAULT 99999999 ;
      l_found     BOOLEAN := FALSE;

      l_clob      CLOB;
   --l_string    varchar2(256);
   BEGIN
      OWA.get_page (l_thepage, l_lines);
      DBMS_LOB.createtemporary (l_clob, TRUE);

      --The interpreter prints a comment thats indicates start of HTML content.
      --Delete this comment from page and the rest text of buffer
      FOR i IN 1 .. l_lines
      LOOP
         IF NOT l_found
         THEN
            l_found     := l_thepage (i) LIKE '%<!%';


            IF l_found
            THEN
               l_thepage (i) := REPLACE (l_thepage (i), '<!-- DBAX interpreter -->');
            END IF;
         END IF;

         IF l_found
         THEN
            IF LENGTH (l_thepage (i)) > 0
            THEN
               DBMS_LOB.writeappend (l_clob, LENGTH (l_thepage (i)), l_thepage (i));
            END IF;
         END IF;
      END LOOP;

      RETURN l_clob;
   END dump_owa_page;


   FUNCTION gzip_clob (p_clob IN CLOB)
      RETURN BLOB
   IS
      v_blob            BLOB;
      l_blob            BLOB;
      l_dest_offset     INTEGER := 1;

      l_source_offset   INTEGER := 1;
      l_lang_context    INTEGER := DBMS_LOB.default_lang_ctx;
      l_warning         INTEGER := DBMS_LOB.warn_inconvertible_char;
   BEGIN
      DBMS_LOB.createtemporary (v_blob, TRUE);

      --Convert CLOB to BLOB
      DBMS_LOB.converttoblob (dest_lob    => v_blob
                            , src_clob    => p_clob
                            , amount      => DBMS_LOB.lobmaxsize
                            , dest_offset => l_dest_offset
                            , src_offset  => l_source_offset
                            , blob_csid   => DBMS_LOB.default_csid
                            , lang_context => l_lang_context
                            , warning     => l_warning);


      -- Initialize BLOBs to something.
      l_blob      := to_blob ('1');

      -- Compress the data.
      UTL_COMPRESS.lz_compress (src => v_blob, dst => l_blob, quality => 1);

      RETURN l_blob;

      -- Free temporary BLOBs.

      DBMS_LOB.freetemporary (v_blob);
   END;


   FUNCTION get_propertie (p_key IN wdx_properties.key%TYPE)
      RETURN VARCHAR2
   AS
      v_value   wdx_properties.VALUE%TYPE;
   BEGIN
      SELECT /*+ result_cache */
            VALUE
        INTO   v_value
        FROM   wdx_properties
       WHERE   key = LOWER (get_propertie.p_key) AND appid = g$appid;

      RETURN v_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_propertie;

   FUNCTION set_app (p_app_path IN VARCHAR)
      RETURN BOOLEAN
   AS      
   BEGIN
      --TODO Revisar el "contexto" de aplicacion
      g$appid     := UPPER (p_app_path);
      g$app_url   := g$appid;

      RETURN TRUE;
   END set_app;

   PROCEDURE set_app (p_appid IN VARCHAR2 DEFAULT NULL )
   AS
   BEGIN
      --TODO Revisar el "contexto" de aplicacion
      g$appid     := UPPER (p_appid);
      g$app_url   := get_path;
   END set_app;

   PROCEDURE routing (p_path                IN     VARCHAR2
                    , p_controller_method      OUT VARCHAR2
                    , p_view_name              OUT VARCHAR2
                    , p_return_path            OUT VARCHAR2)
   AS
      l_retval            PLS_INTEGER := 0;
      l_return            VARCHAR2 (1000);
      l_tab               DBMS_UTILITY.maxname_array;

      l_replace_string    VARCHAR2 (1000);
      l_position          VARCHAR2 (1000);
      l_occurrence        VARCHAR2 (1000);
      l_match_parameter   VARCHAR2 (1000);
   BEGIN
      /**
      *   Esta funcion se encarga de buscar una mapeo de rutas que valide con el path
      *   en caso de encontrar un mapeo, se ejecuta y se devuelve la ruta mepada
      */

      FOR c1 IN (  SELECT   route_name
                          , url_pattern
                          , controller_method
                          , view_name
                     FROM   wdx_map_routes
                    WHERE   appid = g$appid AND active = 'Y'
                 ORDER BY   priority)
      LOOP
         c1.url_pattern := '^' || c1.url_pattern || '(/|$)';

         l_retval    := REGEXP_INSTR (p_path, c1.url_pattern);


         IF l_retval > 0
         THEN
            dbax_log.debug ('Route Matched:' || c1.route_name || ' URL_PATTERN:' || c1.url_pattern);


            --Ejecutamos el enrutado y salimos
            l_tab       := dbax_utils.tokenizer (NVL (c1.controller_method, c1.view_name));

            IF l_tab.EXISTS (1)
            THEN
               l_replace_string := l_tab (1);
            ELSE
               l_replace_string := NVL (c1.controller_method, c1.view_name);
            END IF;

            IF l_tab.EXISTS (2) AND NVL (l_tab (2), 0) <> 0
            THEN
               l_position  := l_tab (2);
            ELSE
               l_position  := '1';
            END IF;

            IF l_tab.EXISTS (3)
            THEN
               l_occurrence := l_tab (3);
            ELSE
               l_occurrence := '0';
            END IF;

            IF l_tab.EXISTS (4)
            THEN
               l_match_parameter := l_tab (4);
            END IF;

            l_return    :=
               REGEXP_REPLACE (p_path
                             , c1.url_pattern
                             , l_replace_string || '/'
                             , l_position
                             , l_occurrence
                             , l_match_parameter);

            p_return_path := l_return;


            --Split the l_return path
            IF INSTR (l_return, '/', 1) > 0
            THEN
               l_return    := SUBSTR (l_return, 1, INSTR (l_return, '/', 1) - 1);
            END IF;

            --Return Valuesz
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

   PROCEDURE execute_controller (p_controller IN VARCHAR2) --, p_method IN VARCHAR2)
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
               --TODO Delegate this exception to DBAX_EXCEPTION
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

   PROCEDURE log_view_variables
   AS
      l_key   VARCHAR2 (256);
   BEGIN
      IF g$view.COUNT () <> 0
      THEN
         l_key       := g$view.FIRST;

         LOOP
            EXIT WHEN l_key IS NULL;
            dbax_log.debug ('Global View Variable g$view (' || l_key || ') = ' || g$view (l_key));
            l_key       := g$view.NEXT (l_key);
         END LOOP;
      END IF;
   END log_view_variables;


   PROCEDURE dispatcher (p_appid       IN VARCHAR2
                       , name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                       , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr )
   AS
      -- v_title           VARCHAR2 (50) := 'Home';
      v_response     CLOB;
      --l_before_header   CLOB;
      l_path         VARCHAR2 (4000);
      l_app_path     VARCHAR2 (4000);
      --l_dummy           VARCHAR2 (50);
      l_retval       BOOLEAN;
      l_check_auth   VARCHAR2 (4);
      l_ret_arr      DBMS_UTILITY.maxname_array;
      --
      l_application_rt  tapi_wdx_applications.wdx_applications_rt;
      --
      e_stop_process exception;
      e_inactive_app exception;   

   BEGIN
      -- 1. Definir la aplicacion
      -- 2. Obtener la URL para enrutar
      -- 2. Realizar Enrutado
      -- 3. A partir de la URL enrutada, o no, recuperar el Controlador, La funcion y los Parametros
      -- 4. Buscar la pagina en la caché. (por la URL)
      -- 4.1 SEGURIDAD. realiza un tratamiento de seguridad sobre la entrada que tengamos, tanto de la información que haya en la URL como de la información que haya en un posible POST
      -- 5. Invocar al controlador.función, los parametros podrán estár en un array global por ahí...
      -- 6. Interpretar las vistas que el controlador ha cargado
      -- 7. Meter el HTML generado en la caché, si procede
      -- 8. Imprimir la pagina

      /***************
      *  1. Defining the application
      ***************/

      set_app (p_appid);

      --Definimos el log
      dbax_log.set_log_context (get_propertie ('LOG_LEVEL'));
      --
      --      p('log context=' || dbax_log.get_log_context );
      --      htp.br;
      --      p ('DISPATCHER p_appid = ' || p_appid);
      --      htp.br;
      --      p('LOG_LEVEL='||get_propertie ('LOG_LEVEL'));


      dbax_log.info ('Start Dispatcher');
      dbax_log.info ('Parameter p_appid=' || p_appid);

      dbax_log.debug ('g$appid=' || g$appid);
      dbax_log.debug ('g$app_url=' || g$app_url);

      --Check active application
      l_application_rt := tapi_wdx_applications.rt(p_appid);
      
      if l_application_rt.active = 'N'
      then
        raise e_inactive_app;
      end if;

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
      --      p('IN l_path:'||l_path);
      --      htp.br;

      routing (p_path      => l_path
             , p_controller_method => g$controller
             , p_view_name => g$view_name
             , p_return_path => l_path);

      dbax_log.debug ('Routing Out l_path=' || l_path);
      dbax_log.info ('Routing Out g$controller=' || g$controller);
      dbax_log.info ('Routing Out g$view_name=' || g$view_name);

      --      p('g$controller: '|| g$controller);
      --      htp.br;
      --      p('g$view_name:'||g$view_name);
      --      htp.br;
      --      p('OUT l_path:'||l_path);
      --      htp.br;
      --      --p(''||);

      --      return;

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
      --      p('Tokeneizer l_path:'||l_path);
      --      htp.br;
      --      --p(''||);
      --      return;

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

      --                                    HTP.br;
      --                                    p ( 'g$appid = ' || g$appid );
      --                                    HTP.br;
      --                                    p ('l_path = ' || l_path);
      --                                    HTP.br;

      --                                    p ('dbax_core.g$controller = ' || dbax_core.g$controller);
      --                                    HTP.br;
      --                                    p ('dbax_core.g$view_name = ' || dbax_core.g$view_name);
      --                                    HTP.br;

      --                              IF dbax_core.g$parameter.EXISTS (1)
      --                              THEN
      --                                 FOR i IN 1 .. dbax_core.g$parameter.LAST
      --                                 LOOP
      --                                    p ('dbax_core.g$parameter(' || i || ') = ' || dbax_core.g$parameter (i));
      --                                    HTP.br;
      --                                 END LOOP;
      --                              END IF;


      --                              declare
      --                                l_key VARCHAR2(4000);
      --                              begin
      --                                l_key       := dbax_core.g$post.FIRST;

      --                                       LOOP
      --                                          EXIT WHEN l_key IS NULL;
      --                                          HTP.p(l_key || '=' || dbax_core.g$post (l_key));
      --                                          htp.br;
      --                                          l_key       := dbax_core.g$post.NEXT (l_key);
      --                                       END LOOP;
      --                              end;

      --
      --                              RETURN;


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
      --TODO revisar el acceso del usuario en la aplicacion
      -- ¿Vale con solo validar si hay sesion activa?
      IF dbax_security.check_auth = '1'
      THEN
         IF FALSE
         THEN
            /***************
            * TODO 4. Get page from Cache
            ***************/
            NULL;
         ELSE
            /***************
            *  5. Invoke the CONTROLLER.METHOD
            ***************/

            IF g$controller IS NOT NULL
            THEN
               dbax_log.debug ('Start Execute Contoller ' || g$controller);
               execute_controller (g$controller);
               dbax_log.debug ('End Execute Contoller ' || g$controller);
            ELSIF g$view_name IS NOT NULL
            THEN
               -- Or load view
               dbax_log.debug ('Load view ' || g$view_name);
               load_view (g$view_name);
            END IF;

            --Page not Found
            IF g$h_view IS NULL AND g$controller IS NULL
            THEN
               --Load application Page not found
               dbax_log.info ('404 Page Not Found');
               load_view ('404');

               /*IF g$h_view IS NULL
               THEN
                  --Global 404 Page
                  load_view ('404', k_default_app);
                  set_app (p_appid => k_default_app);
                  g$status_line := 404;
               END IF;*/
               g$status_line := 404;
            END IF;

            --Check stop_process
            IF g_stop_process
            THEN
               RAISE e_stop_process;
            END IF;

            /***************
            *  6. Interpret the views loaded
            ***************/
            dbax_log.info ('g$content_type=' || g$content_type);

            IF g$content_type = 'text/html'
            THEN
               --debug view variables
               log_view_variables;

               --Lob Locator
               DBMS_LOB.createtemporary (v_response, TRUE);
               dbax_log.trace ('Interpreting data view ' || g$h_view);
               dbax_log.debug ('Start Interpreter');
               v_response  := dbax_core.interpreter (g$h_view);
               dbax_log.debug ('End Interpreter');
            ELSE
               v_response  := g$h_view;
            END IF;

            --Check stop_process
            IF g_stop_process
            THEN
               RAISE e_stop_process;
            END IF;
         /***************
         * TODO 7. Set page to cache
         ***************/

         END IF;
      ELSE
         --         IF l_check_auth <> 401
         --         THEN
         dbax_log.info ('User not logged');
         /*
         * Loading login page
         */

         dbax_log.info ('Redirect to login page');
         --Redirect app login if exists, else redirect to default login page

         routing (p_path      => 'login'
                , p_controller_method => g$controller
                , p_view_name => g$view_name
                , p_return_path => l_path);

         ----
         --                              p('g$app_url:' || g$app_url);
         --                         htp.br;
         --                        p('g$controller:'|| g$controller);
         --                        htp.br;
         --                        p('g$view_name:'||g$view_name);
         --                        htp.br;
         --                        p('l_path:'||l_path);

         --                        htp.br;
         --                        p('g$status_line:'||g$status_line);
         --                        return;

         --p(''||);
         IF g$controller IS NOT NULL
         THEN
            dbax_log.debug ('Execute Contoller ' || g$controller);
            execute_controller (g$controller);
         ELSIF g$view_name IS NOT NULL
         THEN
            -- Or load view
            dbax_log.debug ('Loading view ' || g$view_name);
            load_view (g$view_name);
         /*ELSE
            --Default login controller
            dbax_log.info ('Redirect to Default login page');
            set_app (k_default_app);
            routing (p_path      => 'login'
                   , p_controller_method => g$controller
                   , p_view_name => g$view_name
                   , p_return_path => l_path);

            dbax_log.debug ('Execute Contoller ' || g$controller);
            execute_controller (g$controller);*/
         END IF;

         --dbax_core.g_stop_process := TRUE;
         --         ELSE
         --            set_app (p_appid => dbax_core.k_default_app);
         --            load_view ('401');
         --            g$status_line := 401;
         --            dbax_log.info ('401 Unauthorized user');
         --         END IF;

         --Check stop_process
         IF g_stop_process
         THEN
            RAISE e_stop_process;
         END IF;

         /***************
         *  6. Interpret the view loaded
         ***************/
         dbax_log.info ('g$content_type=' || g$content_type);

         IF g$content_type = 'text/html'
         THEN
            --debug view variables
            log_view_variables;

            --Lob Locator
            DBMS_LOB.createtemporary (v_response, TRUE);
            dbax_log.trace ('Interpreting data view ' || g$h_view);
            dbax_log.debug ('Start Interpreter');
            v_response  := dbax_core.interpreter (g$h_view);
            dbax_log.debug ('End Interpreter');

            --Check stop_process
            IF g_stop_process
            THEN
               RAISE e_stop_process;
            END IF;
         ELSE
            v_response  := g$h_view;
         END IF;
      END IF;

      dbax_log.trace ('RESPONSE: ' || v_response);

      /***************
      *  8. Print Page
      ***************/
      dbax_log.debug ('Print HTTP Header');


      IF NOT g_stop_process
      THEN
         IF     g$content_type = 'text/html'
            AND dbax_utils.get (g$view, 'content-encoding') = 'gzip'
            AND v_response IS NOT NULL
         THEN
            DECLARE
               l_blob   BLOB;
            BEGIN
               l_blob      := gzip_clob (v_response);
               g$http_header ('Content-Encoding') := 'gzip';

               HTP.init;
               OWA_UTIL.mime_header (g$content_type, FALSE, get_propertie ('ENCODING'));
               OWA_UTIL.status_line (nstatus => g$status_line, creason => NULL, bclose_header => FALSE);
               HTP.prn (dbax_cookie.generate_cookie_header);
               print_http_header;
               OWA_UTIL.http_header_close;

               WPG_DOCLOAD.download_file (l_blob);
            END;
         ELSE
            HTP.init;
            OWA_UTIL.mime_header (g$content_type, FALSE, get_propertie ('ENCODING'));
            OWA_UTIL.status_line (nstatus => g$status_line, creason => NULL, bclose_header => FALSE);
            HTP.prn (dbax_cookie.generate_cookie_header);
            print_http_header;
            OWA_UTIL.http_header_close;

            dbax_log.debug ('Print Data to OUTPUT');
            dbax_core.PRINT (v_response);
         END IF;
      ELSE
         dbax_log.debug ('Stop Process? TRUE');
      END IF;

      dbax_log.close_log;
      dbax_session.save_sesison_variable;
   EXCEPTION
      WHEN e_stop_process
      THEN
         dbax_log.close_log;
         dbax_session.save_sesison_variable;
      WHEN e_inactive_app
      THEN
        dbax_log.error ('Application '|| p_appid || ' is marked as inactive.');
        dbax_log.close_log;
      WHEN OTHERS
      THEN
         dbax_exception.raise (SQLCODE, SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_log.close_log;
         dbax_session.save_sesison_variable;
   END dispatcher;



   PROCEDURE include (p_name IN VARCHAR2)
   AS
      l_source   CLOB;
   BEGIN
      SELECT /*+ result_cache */
            source
        INTO   l_source
        FROM   wdx_views
       WHERE   UPPER (name) = UPPER (p_name) AND appid = g$appid;

      dbax_core.PRINT (l_source);
   END include;


   FUNCTION load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
      RETURN CLOB
   AS
      l_source   CLOB;
   BEGIN
      SELECT /*+ result_cache */
            source, title
        INTO   l_source, dbax_core.g$view ('title')
        FROM   wdx_views
       WHERE   UPPER (name) = UPPER (p_name) AND appid = NVL (p_appid, g$appid) AND visible = 'Y';

      dbax_core.g$view ('view_loaded') := LOWER (p_name);
      RETURN l_source;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END load_view;


   PROCEDURE load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
   AS
      l_source   CLOB;
   BEGIN
      dbax_log.debug ('Loading view ' || UPPER (p_name) || ' from application ' || NVL (p_appid, g$appid));

      SELECT /*+ result_cache */
            source, title
        INTO   l_source, dbax_core.g$view ('title')
        FROM   wdx_views
       WHERE   UPPER (name) = UPPER (p_name) AND appid = NVL (p_appid, g$appid) AND visible = 'Y';

      dbax_core.g$view ('view_loaded') := LOWER (p_name);
      g$h_view    := g$h_view || l_source;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END load_view;


   FUNCTION get_path (p_local_path IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
   BEGIN
      RETURN get_propertie ('BASE_PATH') || p_local_path;
   END get_path;


   PROCEDURE bind_vars (p_source IN OUT NOCOPY CLOB)
   AS
      l_key   VARCHAR2 (256);
   BEGIN
      IF g$view.COUNT () <> 0
      THEN
         l_key       := g$view.FIRST;

         LOOP
            EXIT WHEN l_key IS NULL;
            p_source    := REPLACE (p_source, '${' || l_key || '}', TO_CLOB (g$view (l_key)));
            l_key       := g$view.NEXT (l_key);
         END LOOP;
      END IF;
   END bind_vars;

   /*Parse dbax sorurce */
   PROCEDURE parse (p_source IN CLOB)
   AS
      l_open_count    PLS_INTEGER;
      l_close_count   PLS_INTEGER;
   BEGIN
      l_open_count := regexp_count (p_source, '<\?dbax');

      l_close_count := regexp_count (p_source, '\?>');

      IF l_open_count <> l_close_count
      THEN
         raise_application_error (-20001
                                ,    '<h3>DBAX parser Exception: </h3> '
                                  || 'One or more DBAX tags (&lt;?dbax ?&gt;) are not closed: '
                                  || l_open_count
                                  || ' <> '
                                  || l_close_count
                                  || '<br><br>');
      END IF;
   END parse;

   PROCEDURE PRINT (p_data IN CLOB)
   AS
      v_pos   INTEGER;
      v_amt   BINARY_INTEGER := 32000;
      v_buf   VARCHAR2 (32767);
   BEGIN
      IF p_data IS NOT NULL
      THEN
         v_pos       := 1;

         LOOP
            DBMS_LOB.read (p_data
                         , v_amt
                         , v_pos
                         , v_buf);
            v_pos       := v_pos + v_amt;

            HTP.prn (v_buf);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END PRINT;


   FUNCTION interpreter (p_source IN CLOB, p_name IN VARCHAR2 DEFAULT NULL )
      RETURN CLOB
   AS
      l_start        NUMBER;
      l_end          NUMBER;

      l_result       CLOB;
      l_source       CLOB;
      l_dyn_sql      CLOB;
      l_out          CLOB := EMPTY_CLOB;

      ln_cursor      NUMBER;
      ln_result      NUMBER;

      --error control
      v_ind          NUMBER := 1;
      v_error_desc   VARCHAR2 (32000);
      e_stop_process exception;
   BEGIN
      IF g_stop_process
      THEN
         RAISE e_stop_process;
      END IF;

      --init
      l_source    := p_source;
      l_result    := p_source;

      --Bind the variables
      bind_vars (l_source);

      --Parse <?dbax ?> tags, done once

      IF NOT g_parser
      THEN
         parse (l_source);
         g_parser    := TRUE;
      END IF;

      l_start     := DBMS_LOB.INSTR (l_source, '<?dbax');
      l_end       := DBMS_LOB.INSTR (l_source, '?>');

      IF (NVL (l_start, 0) > 0)
      THEN
         DBMS_LOB.createtemporary (l_result, FALSE, DBMS_LOB.call);


         IF l_start > 1
         THEN
            DBMS_LOB.COPY (l_result
                         , l_source
                         , l_start - 1
                         , 1
                         , 1);
         END IF;

         --Obtenemos la instruccion a ejecutar
         l_dyn_sql   := DBMS_LOB.SUBSTR (l_source, (l_end) - (l_start + 7), l_start + 7);

         -- Le añadimos el BEGIN / END

         l_dyn_sql   :=
            'BEGIN htp.prn(''<!-- DBAX interpreter -->''); /*Your code starts here*/ ' || l_dyn_sql || 'END;';

         --DBMS_OUTPUT.PUT_LINE ('l_dyn_sql = ' || l_dyn_sql);

         --Execute DynSQL
         --ln_cursor   := DBMS_SQL.open_cursor;

         BEGIN
            --DBMS_SQL.parse (ln_cursor, l_dyn_sql, DBMS_SQL.native);
            --ln_result   := DBMS_SQL.execute (ln_cursor);
            EXECUTE IMMEDIATE l_dyn_sql;
         EXCEPTION
            WHEN OTHERS
            THEN
               --TODO Delegate this exception to DBAX_EXCEPTION
               -- v_ind       := DBMS_SQL.last_error_position;
               v_error_desc := 'Before this sentence [' || SUBSTR (l_dyn_sql, v_ind, 60) || '...] (' || v_ind || ') ';
               --Print error
               HTP.prn ('<!-- DBAX interpreter -->');
               HTP.prn ('<pre>');
               HTP.prn ('<h3>DBAX Inline Runtime Error </h3>');
               HTP.prn ('<h4>SQLERRM</h4>');
               HTP.prn (SQLERRM);
               HTP.br;
               HTP.prn (v_error_desc);

               HTP.br;
               HTP.prn ('<h4>SQL Statement </h4>');
               HTP.prn ('<pre><code>');
               PRINT (DBMS_XMLGEN.CONVERT (l_dyn_sql, 0));
               HTP.prn ('</code></pre>');
               HTP.prn ('<h4>Error BackTrace </h4>');
               HTP.prn (DBMS_UTILITY.format_error_backtrace ());
               HTP.prn ('</pre>');
         END;

         --DBMS_SQL.close_cursor (ln_cursor);

         --Recogemos el resultado de la ejecución

         l_out       := dump_owa_page;


         --Only if is not null
         --Añadimos el resultado de la ejecucion a la variable resultado
         IF LENGTH (l_out) > 0
         THEN
            DBMS_LOB.COPY (l_result
                         , l_out
                         , DBMS_LOB.getlength (l_out)
                         , DBMS_LOB.getlength (l_result) + 1
                         , 1);
         END IF;


         --Añadimos el resto de la fuente a la varbiable resultado
         DBMS_LOB.COPY (l_result
                      , l_source
                      , DBMS_LOB.getlength (l_source)
                      , DBMS_LOB.getlength (l_result) + 1
                      , l_end + 2);
      END IF;

      --La funcion es recursiva, si hay mas intrucciones dbax, se llama a sí misma.
      IF NVL (DBMS_LOB.INSTR (l_result, '<?dbax'), 0) > 0
      THEN
         RETURN interpreter (l_result);
      END IF;

      --Bind all View or Page variables
      bind_vars (l_result);
      --Null all variables not binded
      l_result    := REGEXP_REPLACE (l_result, '\$\{\S*\}', '');

      --Finalmente devuelve la variable resultado
      RETURN l_result;
   EXCEPTION
      WHEN e_stop_process
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         raise_application_error (-20001, SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END interpreter;


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

      IF g$server ('REQUEST_METHOD') = 'GET'
      THEN
         IF name_array.EXISTS (1) AND name_array (1) IS NOT NULL
         THEN
            --Get QueryString params
            g$get       := dbax_utils.query_string_to_array (g$server ('QUERY_STRING'));

            FOR i IN name_array.FIRST .. name_array.LAST
            LOOP
               --if the parameter ends with [ ] it is an array
               IF name_array (i) LIKE '%[]'
               THEN
                  j           := 1;
                  
                  --Set Name of the parameter[n]
                  l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';
                  
                  --Generate Array index
                  WHILE g$post.EXISTS(l_name_array)
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
            --Get QueryString params
            g$post      := dbax_utils.query_string_to_array (g$server ('QUERY_STRING'));

            FOR i IN name_array.FIRST .. name_array.LAST
            LOOP
               --if the parameter ends with [ ] it is an array
               IF name_array (i) LIKE '%[]'
               THEN
                  j           := 1;
                  
                  --Set Name of the parameter[n]
                  l_name_array := SUBSTR (name_array (i), 1, INSTR (name_array (i), '[]') - 1) || '[' || j || ']';
                  
                  --Generate Array index
                  WHILE g$post.EXISTS(l_name_array)
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
END dbax_core;
/


