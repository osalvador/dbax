CREATE OR REPLACE PACKAGE BODY pk_c_dbax_console
AS
   FUNCTION f_admin_user
      RETURN BOOLEAN
   AS
   BEGIN
      /**
      * The user must have Admin Role
      **/
      IF dbax_security.user_hash_role (p_rolename  => 'R_DBAX_ADMIN'
                                     , p_appid     => dbax_core.g$appid
                                     , p_username  => dbax_core.g$username) = 0
      THEN
         dbax_log.warn ('User must have R_DBAX_ADMIN role. Username=' || dbax_core.g$username);
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END f_admin_user;


   PROCEDURE index_
   AS
      l_count    PLS_INTEGER;
      l_cursor   sys_refcursor;
   BEGIN
      --Applications
      dbax_core.g$view ('count_apps') := tapi_wdx_applications.num_rows;

      --Views
      dbax_core.g$view ('count_views') := tapi_wdx_views.num_rows;

      --Routes
      dbax_core.g$view ('count_routes') := tapi_wdx_map_routes.num_rows;

      --Users
      dbax_core.g$view ('count_users') := tapi_wdx_users.num_rows;

      --Sessions
      dbax_core.g$view ('count_sessions') := tapi_wdx_sessions.num_rows;

      --Logs
      dbax_core.g$view ('count_logs') := tapi_wdx_log.num_rows;

      --activityChartTime
      l_cursor    := pk_m_dbax_console.get_activity_chart_time (480, 30);
      dbax_core.g$view ('activityChartTimes') :=
         json_util_pkg.ref_cursor_to_json_2 (p_ref_cursor => l_cursor, p_format_type => 1);

      --activityChartData
      l_cursor    := pk_m_dbax_console.get_activity_chart_data (480, 30);
      dbax_core.g$view ('activityChartData') :=
         json_util_pkg.ref_cursor_to_json_2 (p_ref_cursor => l_cursor, p_format_type => 1);

      --Browser usage
      l_cursor    := pk_m_dbax_console.get_browser_usage_chart_data (480);
      dbax_core.g$view ('pieChartValues') :=
         json_util_pkg.ref_cursor_to_json_2 (p_ref_cursor => l_cursor, p_format_type => 1);

      dbax_core.load_view ('index');
   END index_;

   PROCEDURE login
   IS
      l_retval        BOOLEAN;
      l_remember_me   DATE;
   BEGIN
      IF dbax_core.g$post.EXISTS ('username')
      THEN
         dbax_log.debug ('LOGIN username: ' || dbax_core.g$post ('username'));

         IF dbax_core.g$post.EXISTS ('remember_me')
         THEN
            --Remember the user and active session during 2 days
            l_remember_me := SYSDATE + 2;
         END IF;

         l_retval    :=
            dbax_security.login (p_username  => dbax_core.g$post ('username')
                               , p_password  => dbax_core.g$post ('password')
                               , p_appid     => dbax_core.g$appid);

         -- Redirect the user
         IF l_retval
         THEN
            --Set User Session
            dbax_log.debug ('Starting session');
            dbax_session.session_start (p_username => dbax_core.g$post ('username'), p_session_expires => l_remember_me);
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
         ELSE
            --Login failed
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/login/loginError');
         END IF;
      ELSE
         --Is user logged?
         dbax_log.debug ('LOGIN GET_SESSION=' || dbax_session.get_session);

         IF dbax_session.get_session IS NULL
         THEN
            dbax_core.load_view ('login');
         ELSE
            --Redirect to home
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
         END IF;
      END IF;
   END login;

   PROCEDURE LOGOUT
   AS
   BEGIN
      --End session
      dbax_session.session_end;
      --Redirect to home
      dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
   END LOGOUT;

   PROCEDURE get_log
   AS
      l_return   CLOB;
   BEGIN
      --Esto es una prueba y no deberia ir en un controlador, sino en el Modelo
      SELECT   DBMS_XMLGEN.getxml('SELECT appid, dbax_session, created_date, log_user, log_level, substr(log_text, 1,2000) log_text
              FROM wdx_log
              where dbax_session = NVL('''
                                  || dbax_core.g$parameter (1)
                                  || ''',dbax_session)
              order by created_date desc')
        INTO   l_return
        FROM   DUAL;

      dbax_core.g$content_type := 'text/xml';
      dbax_core.p (l_return);
   END;

   PROCEDURE download
   AS
   BEGIN
      --Donwload file from parameter /console/download/file_to_download
      --If parameter is not null
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         dbax_document.download (dbax_core.g$parameter (1), dbax_core.g$appid);

         dbax_core.g_stop_process := TRUE;
      ELSE
         --Redirect to documents
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/documents');
      END IF;
   END download;

   PROCEDURE applications
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/

      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      dbax_core.load_view ('applications');
   END applications;

   PROCEDURE new_app
   AS
      l_json             json := json ();
      l_application_rt   tapi_wdx_applications.wdx_applications_rt;
      l_appid_template   tapi_wdx_applications.appid;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      -- IF METHOD is GET load view else create application
      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('newApp');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         --Post parameters
         l_application_rt.appid := UPPER (dbax_utils.get (dbax_core.g$post, 'new_appid'));
         l_application_rt.name := dbax_utils.get (dbax_core.g$post, 'new_name');
         l_application_rt.description := dbax_utils.get (dbax_core.g$post, 'new_desc');
         l_appid_template := dbax_utils.get (dbax_core.g$post, 'new_appid_template');

         IF dbax_utils.get (dbax_core.g$post, 'new_active') = 'on'
         THEN
            l_application_rt.active := 'Y';
         ELSE
            l_application_rt.active := 'N';
         END IF;

         l_application_rt.access_control := dbax_utils.get (dbax_core.g$post, 'new_access_control');
         l_application_rt.auth_scheme := dbax_utils.get (dbax_core.g$post, 'new_auth_scheme');

         --Create new application with default values
         pk_m_dbax_console.new_application (l_application_rt, l_appid_template);

         l_json.put ('text', 'Ok');

         --Return json
         dbax_core.p (l_json.TO_CHAR);
      ELSE
         NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM);
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         RAISE;
   END new_app;

   PROCEDURE edit_app
   AS
      l_application_rt   tapi_wdx_applications.wdx_applications_rt;
      l_appid            tapi_wdx_applications.appid;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications

      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get application Info
      l_application_rt := tapi_wdx_applications.rt (l_appid);

      --Load view variables
      dbax_core.g$view ('current_app_id') := UPPER (l_appid);

      dbax_core.g$view ('app_name') := l_application_rt.name;
      dbax_core.g$view ('app_desc') := DBMS_XMLGEN.CONVERT (l_application_rt.description, 0);

      IF l_application_rt.active = 'Y'
      THEN
         dbax_core.g$view ('app_active') := 'checked';
      END IF;

      dbax_core.g$view ('app_access_control') := l_application_rt.access_control;
      dbax_core.g$view ('app_auth_scheme') := l_application_rt.auth_scheme;
      dbax_core.g$view ('app_hash') := l_application_rt.hash;

      dbax_core.g$view ('app_created_by') := l_application_rt.created_by;

      dbax_core.g$view ('app_created_date') := TO_CHAR (l_application_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('app_modified_by') := l_application_rt.modified_by;
      dbax_core.g$view ('app_modified_date') := TO_CHAR (l_application_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');


      dbax_core.load_view ('manage_applications');
   END edit_app;

   PROCEDURE upsert_app
   AS
      l_application_rt   tapi_wdx_applications.wdx_applications_rt;
      l_json             json := json ();
      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response type
      dbax_core.g$content_type := 'application/json';


      --Post parameters
      l_application_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_application_rt.name := dbax_utils.get (dbax_core.g$post, 'app_name');
      l_application_rt.description := dbax_utils.get (dbax_core.g$post, 'app_desc');

      IF dbax_utils.get (dbax_core.g$post, 'app_active') = 'on'
      THEN
         l_application_rt.active := 'Y';
      ELSE
         l_application_rt.active := 'N';
      END IF;

      l_application_rt.access_control := dbax_utils.get (dbax_core.g$post, 'app_access_control');

      l_application_rt.auth_scheme := dbax_utils.get (dbax_core.g$post, 'app_auth_scheme');
      l_application_rt.modified_by := dbax_security.get_username (dbax_core.g$appid);
      l_application_rt.row_id := dbax_utils.get (dbax_core.g$post, 'app_rowid');
      l_application_rt.hash := dbax_utils.get (dbax_core.g$post, 'app_hash');


      IF l_application_rt.appid IS NOT NULL AND l_application_rt.hash IS NOT NULL
      THEN
         --Update
         tapi_wdx_applications.web_upd (p_wdx_applications_rec => l_application_rt, p_ignore_nulls => FALSE);
      ELSIF l_application_rt.appid IS NOT NULL
      THEN
         --Insert propertie

         tapi_wdx_applications.ins (p_wdx_applications_rec => l_application_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_application_rt := tapi_wdx_applications.rt (l_application_rt.appid);

      --Return JSON
      l_json.put ('hash', l_application_rt.hash);
      l_json.put ('created_by', l_application_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_application_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_application_rt.modified_by);

      l_json.put ('modified_date', TO_CHAR (l_application_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');
      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id is mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_app;


   PROCEDURE delete_app
   AS
      l_out_json      json;
      l_appid         tapi_wdx_applications.appid;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));


      --Delete selected app
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --l_appid is escaped
         l_appid     := utl_url.unescape (l_data_values (i));

         --Delete application
         pk_m_dbax_console.del_application (l_appid);
      END LOOP;

      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_app;

   PROCEDURE import_app
   AS
      l_new_appid        tapi_wdx_applications.appid;
      l_real_file_name   VARCHAR2 (256);
      l_zipped_file      BLOB;
      e_null_param exception;
   BEGIN
      -- The user must be an Admin
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('importApplication');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         --Post parameters
         l_new_appid := dbax_utils.get (dbax_core.g$post, 'new_app_id');

         IF l_new_appid IS NULL
         THEN
            RAISE e_null_param;
         END IF;

         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_zipped_file := dbax_document.get_file_content (l_real_file_name);

         pk_m_dbax_console.import_app (l_zipped_file, UPPER (l_new_appid));

         -- Everything well
         dbax_core.g$status_line := 303;
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
      END IF;
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') := 'New application Id is required.';
         dbax_core.load_view ('importApplication');
      WHEN DUP_VAL_ON_INDEX
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Application "' || l_new_appid || '" that has entered already exists. Please choose another appId.';
         dbax_core.load_view ('importApplication');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing application: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('importApplication');
   END import_app;


   PROCEDURE export_app
   AS
      l_appid            tapi_wdx_applications.appid;
      l_real_file_name   VARCHAR2 (256);
      l_zipped_file      BLOB;
      e_null_param exception;
   BEGIN
      -- The user must be an Admin
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('exportApplication');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         --Post parameters
         l_appid     := dbax_utils.get (dbax_core.g$post, 'appid');

         IF l_appid IS NULL
         THEN
            RAISE e_null_param;
         END IF;

         l_zipped_file := pk_m_dbax_console.export_app (l_appid);

         -- TODO dbax_document.download_this
         HTP.init;
         OWA_UTIL.mime_header ('application/zip', FALSE);
         HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_zipped_file));
         HTP.p ('Content-Disposition: attachment; filename="dbax_' || l_appid || '_app.zip"');
         OWA_UTIL.http_header_close;

         WPG_DOCLOAD.download_file (l_zipped_file);

         DBMS_LOB.freetemporary (l_zipped_file);

         --Stop process and return
         dbax_core.g_stop_process := TRUE;
      END IF;
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') := 'New application Id is required.';
         dbax_core.load_view ('exportApplication');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing application: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('exportApplication');
   END export_app;



   PROCEDURE properties
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (dbax_core.g$parameter (1)) || '#Properties');
         RETURN;
      ELSE
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      END IF;
   END properties;

   PROCEDURE edit_propertie
   AS
      l_appid          tapi_wdx_properties.appid;
      l_key            tapi_wdx_properties.key;
      l_propertie_rt   tapi_wdx_properties.wdx_properties_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_key       := UPPER (dbax_core.g$parameter (2));
      END IF;

      --Get propertie Info
      l_propertie_rt := tapi_wdx_properties.rt (l_appid, l_key);

      --Load view variables
      dbax_core.g$view ('current_app_id') := l_propertie_rt.appid;
      dbax_core.g$view ('key') := l_propertie_rt.key;
      dbax_core.g$view ('value') := l_propertie_rt.VALUE;
      dbax_core.g$view ('description') := l_propertie_rt.description;
      dbax_core.g$view ('created_by') := l_propertie_rt.created_by;

      dbax_core.g$view ('created_date') := TO_CHAR (l_propertie_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_propertie_rt.modified_by;
      dbax_core.g$view ('modified_date') := TO_CHAR (l_propertie_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_propertie_rt.row_id;
      dbax_core.g$view ('hash') := l_propertie_rt.hash;


      dbax_core.load_view ('editPropertie');
   END edit_propertie;

   PROCEDURE new_propertie
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo

         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('newPropertie');
   END new_propertie;

   PROCEDURE upsert_propertie
   AS
      l_propertie_rt   tapi_wdx_properties.wdx_properties_rt;
      l_json           json := json ();

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';


      --Post parameters
      l_propertie_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_propertie_rt.key := dbax_utils.get (dbax_core.g$post, 'key');
      l_propertie_rt.VALUE := dbax_utils.get (dbax_core.g$post, 'value');
      l_propertie_rt.description := dbax_utils.get (dbax_core.g$post, 'description');
      l_propertie_rt.modified_by := dbax_security.get_username (dbax_core.g$appid);
      l_propertie_rt.modified_date := SYSDATE;
      l_propertie_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');

      IF l_propertie_rt.appid IS NOT NULL AND l_propertie_rt.hash IS NOT NULL AND l_propertie_rt.key IS NOT NULL
      THEN
         --Update

         tapi_wdx_properties.web_upd (p_wdx_properties_rec => l_propertie_rt, p_ignore_nulls => TRUE);
      ELSIF l_propertie_rt.appid IS NOT NULL AND l_propertie_rt.key IS NOT NULL
      THEN
         --Insert
         tapi_wdx_properties.ins (p_wdx_properties_rec => l_propertie_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_propertie_rt := tapi_wdx_properties.rt (l_propertie_rt.appid, l_propertie_rt.key);

      --Return JSON

      l_json.put ('hash', l_propertie_rt.hash);
      l_json.put ('created_by', l_propertie_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_propertie_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_propertie_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_propertie_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_propertie;


   PROCEDURE delete_propertie
   AS
      l_out_json      json;
      l_appid         tapi_wdx_properties.appid;
      l_key           tapi_wdx_properties.key;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));


      --Delete selected Properties
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_key       := utl_url.unescape (l_data_values (i));

         tapi_wdx_properties.del (l_appid, l_key);
      /*dbax_log.LOG ('DEBUG'
                  , 'DELETE_PROPERTIE L_DATA_VALUE'
                  , utl_url.unescape(l_data_values(i)));*/
      END LOOP;


      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_propertie;

   PROCEDURE export_properties (p_appid IN tapi_wdx_applications.appid)
   AS
      l_blob_content   BLOB;
      l_xml_data       CLOB;
   BEGIN
      l_xml_data  := tapi_wdx_properties.get_xml (UPPER (p_appid)).getclobval ();
      l_blob_content := as_zip.clob_to_blob (l_xml_data);

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || UPPER (p_appid) || '_properties.xml"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
   END export_properties;

   PROCEDURE import_properties (p_appid IN tapi_wdx_applications.appid)
   AS
      l_real_file_name   VARCHAR2 (256);
      l_tmp_blob         BLOB;
      l_properties_rt    tapi_wdx_properties.wdx_properties_rt;
      l_xml_data         XMLTYPE;
      e_different_application exception;
   BEGIN
      dbax_core.g$view ('module') := 'Properties';
      dbax_core.g$view ('current_app_id') := p_appid;
      dbax_core.g$view ('module_icon') := 'fa fa-cog';

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('importApplicationFile');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_tmp_blob  := dbax_document.get_file_content (l_real_file_name);

         l_xml_data  := xmltype (as_zip.blob_to_clob (l_tmp_blob));

         FOR c1 IN (SELECT   * FROM table (tapi_wdx_properties.get_tt (l_xml_data)))
         LOOP
            l_properties_rt := c1;

            IF l_properties_rt.appid <> p_appid
            THEN
               RAISE e_different_application;
            END IF;

            --Upsert Propertie
            BEGIN
               tapi_wdx_properties.ins (l_properties_rt);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  tapi_wdx_properties.upd (l_properties_rt);
            END;
         END LOOP;

         -- Everything well
         dbax_core.g$status_line := 303;
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (p_appid) || '#Properties');
      END IF;
   EXCEPTION
      WHEN e_different_application
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing properties. You can not import properties from other applications';
         dbax_core.load_view ('importApplicationFile');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing properties: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('importApplicationFile');
   END import_properties;

   PROCEDURE routes
   AS
   BEGIN
      /**

      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (dbax_core.g$parameter (1)) || '#Routing');

         RETURN;
      ELSE
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      END IF;
   END routes;


   PROCEDURE edit_route
   AS
      l_appid        tapi_wdx_map_routes.appid;
      l_route_name   tapi_wdx_map_routes.route_name;
      l_routes_rt    tapi_wdx_map_routes.wdx_map_routes_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get RouteName parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_route_name := UPPER (dbax_core.g$parameter (2));
      END IF;

      --Get route data
      l_routes_rt := tapi_wdx_map_routes.rt (l_appid, l_route_name);

      --Load view variables
      dbax_core.g$view ('current_app_id') := l_routes_rt.appid;
      dbax_core.g$view ('route_name') := l_routes_rt.route_name;
      dbax_core.g$view ('priority') := l_routes_rt.priority;
      dbax_core.g$view ('url_pattern') := l_routes_rt.url_pattern;
      dbax_core.g$view ('controller_method') := l_routes_rt.controller_method;

      dbax_core.g$view ('view_name') := l_routes_rt.view_name;
      dbax_core.g$view ('description') := l_routes_rt.description;

      IF l_routes_rt.active = 'Y'
      THEN
         dbax_core.g$view ('routeActive') := 'checked';
      END IF;

      dbax_core.g$view ('created_by') := l_routes_rt.created_by;
      dbax_core.g$view ('created_date') := TO_CHAR (l_routes_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_routes_rt.modified_by;
      dbax_core.g$view ('modified_date') := TO_CHAR (l_routes_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_routes_rt.row_id;

      dbax_core.g$view ('hash') := l_routes_rt.hash;

      dbax_core.load_view ('editRoute');
   END edit_route;

   PROCEDURE upsert_route
   AS
      l_routes_rt   tapi_wdx_map_routes.wdx_map_routes_rt;
      --
      l_json        json := json ();
      e_null_param exception;
   BEGIN
      /**

      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is json
      dbax_core.g$content_type := 'application/json';

      --Post parameters
      l_routes_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');

      l_routes_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');
      l_routes_rt.route_name := dbax_utils.get (dbax_core.g$post, 'route_name');
      l_routes_rt.priority := dbax_utils.get (dbax_core.g$post, 'priority');
      l_routes_rt.url_pattern := dbax_utils.get (dbax_core.g$post, 'url_pattern');
      l_routes_rt.controller_method := dbax_utils.get (dbax_core.g$post, 'controller_method');
      l_routes_rt.view_name := dbax_utils.get (dbax_core.g$post, 'view_name');
      l_routes_rt.description := dbax_utils.get (dbax_core.g$post, 'description');

      IF dbax_utils.get (dbax_core.g$post, 'active') = 'on'
      THEN
         l_routes_rt.active := 'Y';
      ELSE
         l_routes_rt.active := 'N';
      END IF;


      IF l_routes_rt.appid IS NOT NULL AND l_routes_rt.hash IS NOT NULL AND l_routes_rt.route_name IS NOT NULL
      THEN
         --Update route
         tapi_wdx_map_routes.web_upd (p_wdx_map_routes_rec => l_routes_rt, p_ignore_nulls => FALSE);
         tapi_wdx_map_routes.reorder_routes(l_routes_rt.appid, l_routes_rt.route_name);
      ELSIF l_routes_rt.appid IS NOT NULL AND l_routes_rt.route_name IS NOT NULL
      THEN
         --Insert propertie
         tapi_wdx_map_routes.ins (p_wdx_map_routes_rec => l_routes_rt);
         tapi_wdx_map_routes.reorder_routes(l_routes_rt.appid, l_routes_rt.route_name);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_routes_rt := tapi_wdx_map_routes.rt (l_routes_rt.appid, l_routes_rt.route_name);

      --Return JSON
      l_json.put ('hash', l_routes_rt.hash);
      l_json.put ('created_by', l_routes_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_routes_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_routes_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_routes_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');


      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and route_name are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();

         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_route;

   PROCEDURE new_route
   AS
      l_appid   tapi_wdx_map_routes.appid;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
       * Check APPID Parameter
       **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;


      dbax_core.g$view ('current_app_id') := l_appid;
      dbax_core.g$view ('max_priority') := tapi_wdx_map_routes.max_priority (l_appid) + 1;

      dbax_core.load_view ('newRoute');
   END new_route;


   PROCEDURE delete_route
   AS
      l_json          json := json ();
      l_appid         tapi_wdx_map_routes.appid;
      l_route_name    tapi_wdx_map_routes.route_name;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      --The response is json
      dbax_core.g$content_type := 'application/json';

      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));

      --Delete selected Properties
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_route_name := utl_url.unescape (l_data_values (i));
         tapi_wdx_map_routes.del (l_appid, l_route_name);
      END LOOP;

     tapi_wdx_map_routes.reorder_routes(l_appid);

      l_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());

         dbax_core.p (l_json.TO_CHAR);
   END delete_route;

   PROCEDURE save_routes_order
   AS
      l_json                 json := json ();
      l_arr                  json_list := json_list ();
      l_val_arr              json_list := json_list ();
      l_appid                tapi_wdx_map_routes.appid;
      l_route_name           tapi_wdx_map_routes.route_name;
      l_priority             tapi_wdx_map_routes.priority;

      l_wdx_map_routes_rec   tapi_wdx_map_routes.wdx_map_routes_rt;
   BEGIN
      --The response is json
      dbax_core.g$content_type := 'application/json';

      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;


      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Data are JSON Array

      l_arr       := json_list (dbax_core.g$post ('data'));


      FOR i IN 1 .. l_arr.COUNT ()
      LOOP
         --Values are Json Array
         l_val_arr   := json_list (l_arr.get (i));

         l_priority  := l_val_arr.get (1).value_of ();
         l_route_name := l_val_arr.get (2).value_of ();

         --Get Route Record
         l_wdx_map_routes_rec := tapi_wdx_map_routes.rt (l_appid, l_route_name);


         l_wdx_map_routes_rec.priority := l_priority;

         --Update Priority
         tapi_wdx_map_routes.web_upd (l_wdx_map_routes_rec);
      END LOOP;

      l_json.put ('text', 'Routes order saved succesfully.');

      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END save_routes_order;

   PROCEDURE test_route
   AS
      l_url_pattern         VARCHAR2 (1000);
      l_test_url            VARCHAR2 (1000);
      l_controller_method   VARCHAR2 (1000);

      l_retval              PLS_INTEGER := 0;
      l_return              VARCHAR2 (1000);
      l_json                json := json ();
   BEGIN
      --The response is json
      dbax_core.g$content_type := 'application/json';

      l_test_url  := dbax_utils.get (dbax_core.g$post, 'test_url');
      l_url_pattern := dbax_utils.get (dbax_core.g$post, 'url_pattern');
      l_controller_method := dbax_utils.get (dbax_core.g$post, 'test_controller_method');

      l_url_pattern := '^' || l_url_pattern || '(/|$)';


      l_retval    := REGEXP_INSTR (l_test_url, l_url_pattern);


      IF l_retval > 0
      THEN
         l_return    := REGEXP_REPLACE (l_test_url, l_url_pattern, l_controller_method);

         l_json.put ('return', l_return);
      ELSE
         l_json.put ('return', 'Pattern not match');
      END IF;

      --Return values

      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END test_route;

   PROCEDURE export_routes (p_appid IN tapi_wdx_applications.appid)
   AS
      l_blob_content   BLOB;
      l_xml_data       CLOB;
   BEGIN
      l_xml_data  := tapi_wdx_map_routes.get_xml (UPPER (p_appid)).getclobval ();
      l_blob_content := as_zip.clob_to_blob (l_xml_data);

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || UPPER (p_appid) || '_routes.xml"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
   END export_routes;

   PROCEDURE import_routes (p_appid IN tapi_wdx_applications.appid)
   AS
      l_real_file_name   VARCHAR2 (256);
      l_tmp_blob         BLOB;
      l_routes_rt        tapi_wdx_map_routes.wdx_map_routes_rt;
      l_xml_data         XMLTYPE;
      e_different_application exception;
   BEGIN
      dbax_core.g$view ('module') := 'Routes';
      dbax_core.g$view ('current_app_id') := p_appid;
      dbax_core.g$view ('module_icon') := 'fa fa-road';

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('importApplicationFile');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_tmp_blob  := dbax_document.get_file_content (l_real_file_name);

         l_xml_data  := xmltype (as_zip.blob_to_clob (l_tmp_blob));

         FOR c1 IN (SELECT   * FROM table (tapi_wdx_map_routes.get_tt (l_xml_data)))
         LOOP
            l_routes_rt := c1;

            IF l_routes_rt.appid <> p_appid
            THEN
               RAISE e_different_application;
            END IF;

            --Upsert Propertie
            BEGIN
               tapi_wdx_map_routes.ins (l_routes_rt);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  tapi_wdx_map_routes.upd (l_routes_rt);
            END;
         END LOOP;

         -- Everything well
         dbax_core.g$status_line := 303;
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (p_appid) || '#Routes');
      END IF;
   EXCEPTION
      WHEN e_different_application
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing routes. You can not import properties from other applications';
         dbax_core.load_view ('importApplicationFile');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing routes: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('importApplicationFile');
   END import_routes;

   PROCEDURE views_
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      --Get appId parameter if not exists return to applications
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (dbax_core.g$parameter (1)) || '#Views');
         RETURN;
      ELSE
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      END IF;
   END views_;

   PROCEDURE edit_view
   AS
      l_appid     tapi_wdx_views.appid;
      l_name      tapi_wdx_views.name;
      l_view_rt   tapi_wdx_views.wdx_views_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;


      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := dbax_core.g$parameter (1);
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_name      := dbax_core.g$parameter (2);
      END IF;


      --Get propertie Info
      l_view_rt   := tapi_wdx_views.rt (l_appid, l_name);

      --Load view variables

      dbax_core.g$view ('current_app_id') := l_view_rt.appid;
      dbax_core.g$view ('name') := l_view_rt.name;
      dbax_core.g$view ('view_title') := l_view_rt.title;
      dbax_core.g$view ('description') := l_view_rt.description;

      IF l_view_rt.visible = 'Y'
      THEN
         dbax_core.g$view ('view_visible') := 'checked';
      END IF;

      dbax_core.g$view ('created_by') := l_view_rt.created_by;
      dbax_core.g$view ('created_date') := TO_CHAR (l_view_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_view_rt.modified_by;

      dbax_core.g$view ('modified_date') := TO_CHAR (l_view_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_view_rt.row_id;
      dbax_core.g$view ('hash') := l_view_rt.hash;

      dbax_core.load_view ('editView');
   END edit_view;

   PROCEDURE upsert_view
   AS
      l_view_rt   tapi_wdx_views.wdx_views_rt;
      --
      l_json      json := json ();
      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'application/json';


      --Post parameters
      l_view_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_view_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');
      l_view_rt.name := dbax_utils.get (dbax_core.g$post, 'name');
      l_view_rt.title := dbax_utils.get (dbax_core.g$post, 'title');
      l_view_rt.description := dbax_utils.get (dbax_core.g$post, 'description');
      l_view_rt.modified_by := dbax_security.get_username (dbax_core.g$appid);
      l_view_rt.modified_date := SYSDATE;

      IF dbax_utils.get (dbax_core.g$post, 'visible') = 'on'
      THEN
         l_view_rt.visible := 'Y';
      ELSE
         l_view_rt.visible := 'N';
      END IF;

      --The source code is stored in the controller save_source_view
      --l_view_rt.source := dbax_utils.get (dbax_core.g$post, 'code');

      IF l_view_rt.appid IS NOT NULL AND l_view_rt.hash IS NOT NULL AND l_view_rt.name IS NOT NULL
      THEN
         --Update
         tapi_wdx_views.web_upd (p_wdx_views_rec => l_view_rt, p_ignore_nulls => TRUE);
      ELSIF l_view_rt.appid IS NOT NULL AND l_view_rt.name IS NOT NULL
      THEN
         --Insert

         tapi_wdx_views.ins (p_wdx_views_rec => l_view_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      l_view_rt   := tapi_wdx_views.rt (l_view_rt.appid, l_view_rt.name);

      --Return JSON
      l_json.put ('hash', l_view_rt.hash);
      l_json.put ('modified_by', l_view_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_view_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');


      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and name are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);

         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_view;

   PROCEDURE get_source_view
   AS
      l_appid     tapi_wdx_views.appid;
      l_name      tapi_wdx_views.name;
      l_view_rt   tapi_wdx_views.wdx_views_rt;

      l_source    CLOB;
      l_json      json := json ();
   BEGIN
      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := dbax_core.g$parameter (1);
      END IF;

      --Get name parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_name      := dbax_core.g$parameter (2);
      END IF;

      --Get view
      l_view_rt   := tapi_wdx_views.rt (l_appid, l_name);

      --Return values
      --Source code is a CLOB type, json.to_CLOB fails so I return plain text.
      IF NOT dbax_core.g$parameter.EXISTS (3) OR dbax_core.g$parameter (3) IS NULL
      THEN
         dbax_core.p (l_view_rt.source);
      ELSE
         IF dbax_core.g$parameter (3) = 'compiled'
         THEN
            dbax_core.p (l_view_rt.compiled_source);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END get_source_view;

   PROCEDURE save_source_view
   AS
      l_view_rt          tapi_wdx_views.wdx_views_rt;
      --
      l_error_template   CLOB;
      --
      l_json             json := json ();
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'application/json';

      --Update Propertie
      l_view_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_view_rt.name := dbax_utils.get (dbax_core.g$post, 'name');

      --Get textarea CLOB from code(n) parameter
      l_view_rt.source := dbax_utils.get_clob (dbax_core.g$post, 'code');

      --Delete Control Chars excep tabs and newlines
      l_view_rt.source := REPLACE (l_view_rt.source, CHR (10), '@|;newline@|;');
      l_view_rt.source := REPLACE (l_view_rt.source, CHR (09), '@|;tab@|;');
      l_view_rt.source := REGEXP_REPLACE (l_view_rt.source, '[[:cntrl:]]', '');
      l_view_rt.source := REPLACE (l_view_rt.source, '@|;newline@|;', CHR (10));
      --Replace tabs to 4 spaces
      l_view_rt.source := REPLACE (l_view_rt.source, '@|;tab@|;', '    ');

      --Update view
      tapi_wdx_views.web_upd (p_wdx_views_rec => l_view_rt, p_ignore_nulls => TRUE);

      IF     dbax_core.g$parameter.EXISTS (2)
         AND dbax_core.g$parameter (2) IS NOT NULL
         AND dbax_core.g$parameter (2) = 'compiled'
      THEN
         --Compile
         BEGIN
            dbax_teplsql.compile (l_view_rt.name, l_view_rt.appid, l_error_template);
         EXCEPTION
            WHEN OTHERS
            THEN
               dbax_log.error(   'Error compiling view :'
                              || l_error_template
                              || SQLERRM
                              || ' '
                              || DBMS_UTILITY.format_error_backtrace ());
               RAISE;
         END;

         --Compile dependencies
         BEGIN
            dbax_teplsql.compile_dependencies (l_view_rt.name, l_view_rt.appid, l_error_template);
         EXCEPTION
            WHEN OTHERS
            THEN
               dbax_log.error(   'Error compiling dependencies:'
                              || l_error_template
                              || SQLERRM
                              || ' '
                              || DBMS_UTILITY.format_error_backtrace ());
               RAISE;
         END;

         l_json.put ('text', 'Saved and Compiled');
      ELSE
         l_json.put ('text', 'Only Saved');
      END IF;

      l_view_rt   := tapi_wdx_views.rt (l_view_rt.appid, l_view_rt.name);

      --Return JSON
      l_json.put ('hash', l_view_rt.hash);
      l_json.put ('modified_by', l_view_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_view_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));

      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END save_source_view;

   PROCEDURE new_view
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
       * Check APPID Parameter
       **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('newView');
   END new_view;

   PROCEDURE delete_view
   AS
      l_json          json := json ();
      l_appid         tapi_wdx_views.appid;
      l_view_name     tapi_wdx_views.name;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      --The response is json
      dbax_core.g$content_type := 'application/json';

      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
      * Check APPID Parameter
      **/

      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));

      --Delete selected Views
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_view_name := utl_url.unescape (l_data_values (i));
         tapi_wdx_views.del (l_appid, l_view_name);
      END LOOP;

      l_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json      := json ();
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END delete_view;

   PROCEDURE import_view
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('importViewFiles');
   END import_view;

   PROCEDURE upload_view
   AS
      l_real_file_name   VARCHAR2 (200);
      l_file             BLOB;
      l_clob             CLOB;
      l_error_template   CLOB;
      l_file_view_name   VARCHAR2 (256);
      l_file_appid       VARCHAR2 (256);
      l_view_rt          tapi_wdx_views.wdx_views_rt;
   BEGIN
      --Default return status
      dbax_core.g$status_line := 200;
      dbax_core.g$content_type := 'text/plain';

      --Post parameter name is file.
      IF dbax_utils.get (dbax_core.g$post, 'file') IS NOT NULL
      THEN
         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_file      := dbax_document.get_file_content (l_real_file_name);
         l_clob      := dbax_document.blob2clob (l_file);

         --Delete file
         dbax_document.del (l_real_file_name, dbax_core.g$appid);

         --Get parameters from file name
         l_file_appid := SUBSTR (l_real_file_name, 1, INSTR (l_real_file_name, '_') - 1);
         l_file_view_name :=
            SUBSTR (l_real_file_name
                  , INSTR (l_real_file_name, '_') + 1
                  , INSTR (l_real_file_name, '.') - 1 - INSTR (l_real_file_name, '_'));

         --Get appId parameter
         IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
         THEN
            dbax_core.g$status_line := 500;
            p ('Parameter APPID was not found');
            ROLLBACK;
            RETURN;
         ELSE
            l_view_rt.appid := dbax_core.g$parameter (1);
         END IF;

         IF l_view_rt.appid <> l_file_appid OR l_file_appid IS NULL
         THEN
            dbax_core.g$status_line := 500;
            p(   'Unable to load views of other application than '
              || l_view_rt.appid
              || ' your file APPID: '
              || NVL (l_file_appid, 'NULL')
              || '. Remember file pattern: '
              || l_view_rt.appid
              || '_[ViewName].html');
            ROLLBACK;
            RETURN;
         END IF;


         IF l_file_view_name IS NULL
         THEN
            dbax_core.g$status_line := 500;
            p ('View name can not be NULL. ' || '. Remember file pattern: ' || l_view_rt.appid || '_[ViewName].html');
            ROLLBACK;
            RETURN;
         END IF;


         --Upsert view
         BEGIN
            l_view_rt.appid := l_file_appid;
            l_view_rt.name := l_file_view_name;
            l_view_rt.source := l_clob;
            tapi_wdx_views.ins (l_view_rt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               tapi_wdx_views.upd (l_view_rt, TRUE);
         END;

         --If compile is true
         IF dbax_utils.get (dbax_core.g$post, 'compile') = 'true'
         THEN
            --Compile
            BEGIN
               dbax_teplsql.compile (l_view_rt.name, l_view_rt.appid, l_error_template);
            EXCEPTION
               WHEN OTHERS
               THEN
                  dbax_core.g$status_line := 500;
                  p ('Error compiling view ' || SQLERRM);
                  dbax_log.error(   'Error compiling view :'
                                 || l_error_template
                                 || SQLERRM
                                 || ' '
                                 || DBMS_UTILITY.format_error_backtrace ());
                  RETURN;
            END;

            --Compile dependencies
            BEGIN
               dbax_teplsql.compile_dependencies (l_view_rt.name, l_view_rt.appid, l_error_template);
            EXCEPTION
               WHEN OTHERS
               THEN
                  dbax_core.g$status_line := 500;
                  p ('Error compiling dependencies ' || SQLERRM);
                  dbax_log.error(   'Error compiling dependencies:'
                                 || l_error_template
                                 || SQLERRM
                                 || ' '
                                 || DBMS_UTILITY.format_error_backtrace ());
                  RETURN;
            END;

            p ('View: ' || l_file_view_name || ' successfully saved and compile.');
         ELSE
            p ('View: ' || l_file_view_name || ' successfully saved.');
         END IF;
      ELSE
         dbax_core.g$status_line := 500;
         p ('Any file has been sent');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         dbax_core.g$status_line := 500;
         p ('Something went wrong: ' || SQLCODE || ' ' || SQLERRM);
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END upload_view;

   PROCEDURE export_view
   AS
      l_appid          tapi_wdx_views.appid;
      l_view_name      tapi_wdx_views.name;
      l_view_rt        tapi_wdx_views.wdx_views_rt;
      l_data_values    DBMS_UTILITY.maxname_array;
      l_blob_content   BLOB;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));

      --Download selected views
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_view_name := utl_url.unescape (l_data_values (i));
         l_view_rt   := tapi_wdx_views.rt (l_appid, l_view_name);
         as_zip.add1file (l_blob_content
                        , l_view_rt.appid || '_' || l_view_rt.name || '.html'
                        , as_zip.clob_to_blob (l_view_rt.source));
      END LOOP;

      as_zip.finish_zip (l_blob_content);

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || l_appid || '_views.zip"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END export_view;


   PROCEDURE export_all_view
   AS
      l_appid          tapi_wdx_views.appid;
      l_blob_content   BLOB;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      FOR c1 IN (SELECT   *
                   FROM   wdx_views
                  WHERE   appid = l_appid)
      LOOP
         as_zip.add1file (l_blob_content, c1.appid || '_' || c1.name || '.html', as_zip.clob_to_blob (c1.source));
      END LOOP;

      as_zip.finish_zip (l_blob_content);

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || l_appid || '_views.zip"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
      RETURN;
   END export_all_view;

   /*
   * Request Validation Function controllers
   */
   PROCEDURE reqvalidation
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (dbax_core.g$parameter (1)) || '#RequestValidation');
         RETURN;
      ELSE
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      END IF;
   END reqvalidation;

   PROCEDURE edit_reqvalidation
   AS
      l_appid              tapi_wdx_reqvalidation.appid;

      l_procedure_name     tapi_wdx_reqvalidation.procedure_name;
      l_reqvalidation_rt   tapi_wdx_reqvalidation.wdx_request_valid_function_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications

      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get ProcedureName parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo

         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_procedure_name := LOWER (dbax_core.g$parameter (2));
      END IF;

      --Get propertie Info
      l_reqvalidation_rt := tapi_wdx_reqvalidation.rt (l_appid, l_procedure_name);

      --Load view variables
      dbax_core.g$view ('current_app_id') := l_reqvalidation_rt.appid;
      dbax_core.g$view ('procedure_name') := l_reqvalidation_rt.procedure_name;
      dbax_core.g$view ('created_by') := l_reqvalidation_rt.created_by;

      dbax_core.g$view ('created_date') := TO_CHAR (l_reqvalidation_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_reqvalidation_rt.modified_by;
      dbax_core.g$view ('modified_date') := TO_CHAR (l_reqvalidation_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_reqvalidation_rt.row_id;
      dbax_core.g$view ('hash') := l_reqvalidation_rt.hash;


      dbax_core.load_view ('editReqvalidation');
   END edit_reqvalidation;

   PROCEDURE new_reqvalidation
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo

         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('newReqvalidation');
   END new_reqvalidation;

   PROCEDURE upsert_reqvalidation
   AS
      l_reqvalidation_rt   tapi_wdx_reqvalidation.wdx_request_valid_function_rt;
      l_json               json := json ();

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'application/json';

      --Post parameters
      l_reqvalidation_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_reqvalidation_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');
      l_reqvalidation_rt.procedure_name := dbax_utils.get (dbax_core.g$post, 'procedure_name');

      --Request Validation Function Cant be updated
      IF l_reqvalidation_rt.appid IS NOT NULL AND l_reqvalidation_rt.procedure_name IS NOT NULL
      THEN
         --Insert
         tapi_wdx_reqvalidation.ins (p_wdx_reqvalidation_rec => l_reqvalidation_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_reqvalidation_rt := tapi_wdx_reqvalidation.rt (l_reqvalidation_rt.appid, l_reqvalidation_rt.procedure_name);

      --Return JSON
      l_json.put ('hash', l_reqvalidation_rt.hash);
      l_json.put ('created_by', l_reqvalidation_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_reqvalidation_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_reqvalidation_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_reqvalidation_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');


      --Return values
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and procedure_name are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);

         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_reqvalidation;

   PROCEDURE delete_reqvalidation
   AS
      l_out_json         json;
      l_appid            tapi_wdx_reqvalidation.appid;
      l_procedure_name   tapi_wdx_reqvalidation.procedure_name;
      l_data_values      DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      /**
      * Check APPID Parameter
      **/

      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));


      --Delete selected values
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_procedure_name := utl_url.unescape (l_data_values (i));
         tapi_wdx_reqvalidation.del (l_appid, l_procedure_name);
      END LOOP;

      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;

      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_reqvalidation;


   PROCEDURE export_reqvalidation (p_appid IN tapi_wdx_applications.appid)
   AS
      l_blob_content   BLOB;
      l_xml_data       CLOB;
   BEGIN
      l_xml_data  := tapi_wdx_reqvalidation.get_xml (UPPER (p_appid)).getclobval ();
      l_blob_content := as_zip.clob_to_blob (l_xml_data);

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || UPPER (p_appid) || '_reqValidationFunction.xml"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
   END export_reqvalidation;

   PROCEDURE import_reqvalidation (p_appid IN tapi_wdx_applications.appid)
   AS
      l_real_file_name     VARCHAR2 (256);
      l_tmp_blob           BLOB;
      l_reqvalidation_rt   tapi_wdx_reqvalidation.wdx_request_valid_function_rt;
      l_xml_data           XMLTYPE;
      e_different_application exception;
   BEGIN
      dbax_core.g$view ('module') := 'ReqValidation';
      dbax_core.g$view ('current_app_id') := p_appid;
      dbax_core.g$view ('module_icon') := 'fa fa-check';

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('importApplicationFile');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_tmp_blob  := dbax_document.get_file_content (l_real_file_name);

         l_xml_data  := xmltype (as_zip.blob_to_clob (l_tmp_blob));

         FOR c1 IN (SELECT   * FROM table (tapi_wdx_reqvalidation.get_tt (l_xml_data)))
         LOOP
            l_reqvalidation_rt := c1;

            IF l_reqvalidation_rt.appid <> p_appid
            THEN
               RAISE e_different_application;
            END IF;

            --Upsert Propertie
            BEGIN
               tapi_wdx_reqvalidation.ins (l_reqvalidation_rt);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  tapi_wdx_reqvalidation.upd (l_reqvalidation_rt);
            END;
         END LOOP;

         -- Everything well
         dbax_core.g$status_line := 303;
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (p_appid) || '#RequestValidation');
      END IF;
   EXCEPTION
      WHEN e_different_application
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing Request Validation Function. You can not import properties from other applications';
         dbax_core.load_view ('importApplicationFile');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing Request Validation Function: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('importApplicationFile');
   END import_reqvalidation;



   /*
   * Roles controllers
   */

   PROCEDURE new_role
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo

         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('newRole');
   END new_role;


   PROCEDURE upsert_role
   AS
      l_role_rt   tapi_wdx_roles.wdx_roles_rt;
      l_json      json := json ();

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      --Post parameters
      l_role_rt.appid := dbax_utils.get (dbax_core.g$post, 'current_app_id');
      l_role_rt.rolename := dbax_utils.get (dbax_core.g$post, 'rolename');
      l_role_rt.role_descr := dbax_utils.get (dbax_core.g$post, 'description');
      l_role_rt.modified_by := dbax_security.get_username (dbax_core.g$appid);
      l_role_rt.modified_date := SYSDATE;
      l_role_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');

      dbax_log.debug(   'Los datos que tengo son: appid:'
                     || l_role_rt.appid
                     || ' l_role_rt.rolename:'
                     || l_role_rt.rolename
                     || ' l_role_rt.role_descr:'
                     || l_role_rt.role_descr);

      IF l_role_rt.appid IS NOT NULL AND l_role_rt.hash IS NOT NULL AND l_role_rt.rolename IS NOT NULL
      THEN
         --Update
         dbax_log.debug ('Hago UPDATE');
         tapi_wdx_roles.web_upd (p_wdx_roles_rec => l_role_rt, p_ignore_nulls => TRUE);
      ELSIF l_role_rt.appid IS NOT NULL AND l_role_rt.rolename IS NOT NULL
      THEN
         --Insert
         dbax_log.debug ('Hago INSERT');
         tapi_wdx_roles.ins (p_wdx_roles_rec => l_role_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_role_rt   := tapi_wdx_roles.rt (l_role_rt.rolename, l_role_rt.appid);

      --Return JSON

      l_json.put ('hash', l_role_rt.hash);
      l_json.put ('created_by', l_role_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_role_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_role_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_role_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_role;

   PROCEDURE edit_role
   AS
      l_appid          tapi_wdx_roles.appid;
      l_rolename       tapi_wdx_roles.rolename;
      l_propertie_rt   tapi_wdx_roles.wdx_roles_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_rolename  := UPPER (dbax_core.g$parameter (2));
      END IF;

      --Get propertie Info
      l_propertie_rt := tapi_wdx_roles.rt (l_rolename, l_appid);

      --Load view variables
      dbax_core.g$view ('current_app_id') := l_propertie_rt.appid;
      dbax_core.g$view ('rolename') := l_propertie_rt.rolename;
      dbax_core.g$view ('description') := l_propertie_rt.role_descr;
      dbax_core.g$view ('created_by') := l_propertie_rt.created_by;

      dbax_core.g$view ('created_date') := TO_CHAR (l_propertie_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_propertie_rt.modified_by;
      dbax_core.g$view ('modified_date') := TO_CHAR (l_propertie_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_propertie_rt.row_id;
      dbax_core.g$view ('hash') := l_propertie_rt.hash;


      dbax_core.load_view ('editRole');
   END edit_role;

   PROCEDURE delete_role
   AS
      l_out_json      json;
      l_appid         tapi_wdx_roles.appid;
      l_rolename      tapi_wdx_roles.rolename;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));


      --Delete selected role
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_rolename  := utl_url.unescape (l_data_values (i));

         tapi_wdx_roles.del (l_rolename, l_appid);
      /*dbax_log.LOG ('DEBUG'
                  , 'DELETE_PROPERTIE L_DATA_VALUE'
                  , utl_url.unescape(l_data_values(i)));*/
      END LOOP;


      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_role;


   PROCEDURE upsert_roles_users
   AS
      l_users_roles_rt   tapi_wdx_users_roles.wdx_users_roles_rt;
      l_appid            tapi_wdx_users_roles.appid;
      l_rolename         tapi_wdx_users_roles.rolename;
      l_json             json := json ();

      l_users            DBMS_UTILITY.maxname_array;

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get rolename
      l_rolename  := dbax_utils.get (dbax_core.g$post, 'rolename');

      --Delete all users assigned to the role
      dbax_log.debug ('Deleting Users from role:' || l_rolename || ' and appid:' || l_appid);
      tapi_wdx_users_roles.del (p_username => NULL, p_rolename => l_rolename, p_appid => l_appid);

      l_users_roles_rt.rolename := l_rolename;
      l_users_roles_rt.appid := l_appid;

      --Get all users names from users_roles[]
      l_users     := dbax_utils.get_array (dbax_core.g$post, 'users_roles');

      FOR i IN 1 .. l_users.COUNT ()
      LOOP
         l_users_roles_rt.username := l_users (i);
         tapi_wdx_users_roles.ins (l_users_roles_rt);
      END LOOP;

      l_json.put ('text', 'Users assigned to the role ' || l_rolename || ' successfully');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_roles_users;


   PROCEDURE upsert_roles_permissions
   AS
      l_roles_pmsn_rt   tapi_wdx_roles_pmsn.wdx_roles_pmsn_rt;
      l_appid           tapi_wdx_roles_pmsn.appid;
      l_rolename        tapi_wdx_roles_pmsn.rolename;
      l_json            json := json ();

      l_pmsns           DBMS_UTILITY.maxname_array;

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get rolename
      l_rolename  := dbax_utils.get (dbax_core.g$post, 'rolename');

      --Delete all users assigned to the role
      dbax_log.debug ('Deleting Permissions from role:' || l_rolename || ' and appid:' || l_appid);
      tapi_wdx_roles_pmsn.del (p_rolename => l_rolename, p_appid => l_appid);

      l_roles_pmsn_rt.rolename := l_rolename;
      l_roles_pmsn_rt.appid := l_appid;

      --Get all users names from roles_permissions[]
      l_pmsns     := dbax_utils.get_array (dbax_core.g$post, 'roles_permissions');

      FOR i IN 1 .. l_pmsns.COUNT ()
      LOOP
         l_roles_pmsn_rt.pmsname := l_pmsns (i);
         tapi_wdx_roles_pmsn.ins (l_roles_pmsn_rt);
      END LOOP;

      l_json.put ('text', 'Permissions assigned to the role ' || l_rolename || ' successfully');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;
         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_roles_permissions;


   /*
    * Permissions controllers
    */

   PROCEDURE new_pmsn
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo

         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         dbax_core.g$view ('current_app_id') := UPPER (dbax_core.g$parameter (1));
      END IF;

      dbax_core.load_view ('newPermission');
   END new_pmsn;

   PROCEDURE upsert_pmsn
   AS
      l_pmsn_rt   tapi_wdx_permissions.wdx_permissions_rt;
      l_json      json := json ();

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      --Post parameters
      l_pmsn_rt.appid := UPPER (dbax_utils.get (dbax_core.g$post, 'current_app_id'));
      l_pmsn_rt.pmsname := UPPER (dbax_utils.get (dbax_core.g$post, 'pmsname'));
      l_pmsn_rt.pmsn_descr := dbax_utils.get (dbax_core.g$post, 'description');
      l_pmsn_rt.modified_by := dbax_security.get_username (dbax_core.g$appid);
      l_pmsn_rt.modified_date := SYSDATE;
      l_pmsn_rt.hash := dbax_utils.get (dbax_core.g$post, 'hash');

      IF l_pmsn_rt.appid IS NOT NULL AND l_pmsn_rt.hash IS NOT NULL AND l_pmsn_rt.pmsname IS NOT NULL
      THEN
         --Update
         tapi_wdx_permissions.web_upd (p_wdx_permissions_rec => l_pmsn_rt, p_ignore_nulls => TRUE);
      ELSIF l_pmsn_rt.appid IS NOT NULL AND l_pmsn_rt.pmsname IS NOT NULL
      THEN
         --Insert
         tapi_wdx_permissions.ins (p_wdx_permissions_rec => l_pmsn_rt);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_pmsn_rt   := tapi_wdx_permissions.rt (l_pmsn_rt.pmsname, l_pmsn_rt.appid);

      --Return JSON

      l_json.put ('hash', l_pmsn_rt.hash);
      l_json.put ('created_by', l_pmsn_rt.created_by);
      l_json.put ('created_date', TO_CHAR (l_pmsn_rt.created_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('modified_by', l_pmsn_rt.modified_by);
      l_json.put ('modified_date', TO_CHAR (l_pmsn_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END upsert_pmsn;

   PROCEDURE edit_pmsn
   AS
      l_appid     tapi_wdx_permissions.appid;
      l_pmsname   tapi_wdx_permissions.pmsname;
      l_pmsn_rt   tapi_wdx_permissions.wdx_permissions_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --Get appId parameter if not exists return to applications
      IF NOT dbax_core.g$parameter.EXISTS (2) OR dbax_core.g$parameter (2) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/applications');
         RETURN;
      ELSE
         l_pmsname   := UPPER (dbax_core.g$parameter (2));
      END IF;

      --Get permission record
      l_pmsn_rt   := tapi_wdx_permissions.rt (l_pmsname, l_appid);

      --Load view variables
      dbax_core.g$view ('current_app_id') := l_pmsn_rt.appid;
      dbax_core.g$view ('pmsname') := l_pmsn_rt.pmsname;
      dbax_core.g$view ('description') := l_pmsn_rt.pmsn_descr;
      dbax_core.g$view ('created_by') := l_pmsn_rt.created_by;

      dbax_core.g$view ('created_date') := TO_CHAR (l_pmsn_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('modified_by') := l_pmsn_rt.modified_by;
      dbax_core.g$view ('modified_date') := TO_CHAR (l_pmsn_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('row_id') := l_pmsn_rt.row_id;
      dbax_core.g$view ('hash') := l_pmsn_rt.hash;


      dbax_core.load_view ('editPermission');
   END edit_pmsn;


   PROCEDURE delete_pmsn
   AS
      l_out_json      json;
      l_appid         tapi_wdx_permissions.appid;
      l_pmsname       tapi_wdx_permissions.pmsname;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      /**
      * Check APPID Parameter
      **/
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$status_line := 500;
         dbax_core.p ('APPID Must be not null');
         RETURN;
      ELSE
         l_appid     := UPPER (dbax_core.g$parameter (1));
      END IF;

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));


      --Delete selected permission
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_pmsname   := utl_url.unescape (l_data_values (i));

         tapi_wdx_permissions.del (l_pmsname, l_appid);
      END LOOP;


      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_pmsn;

   PROCEDURE logs
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Unset session variables

      --This delete all session variables
      --dbax_session.reset_sesison_variable;
      --OR you can specify wich variables to unset
      dbax_session.g$session.delete ('log_id');
      dbax_session.g$session.delete ('dbax_session');
      dbax_session.g$session.delete ('user_name');
      dbax_session.g$session.delete ('appid');
      dbax_session.g$session.delete ('date_from');
      dbax_session.g$session.delete ('date_to');
      dbax_session.g$session.delete ('log_text');
      dbax_session.save_sesison_variable;
      --Load view
      dbax_core.load_view ('logs');
   END logs;



   PROCEDURE logs_get_list
   AS
      l_json_clob      CLOB := EMPTY_CLOB ();
      l_bind_json      json := json ();
      l_query          VARCHAR2 (32767);
      l_where          VARCHAR2 (32767);
      p_draw           PLS_INTEGER;
      p_start          PLS_INTEGER;
      p_length         PLS_INTEGER;
      p_order_column   VARCHAR2 (30);
      p_order_dir      VARCHAR2 (10);

      --Bind variables
      p_log_id         wdx_log.id%TYPE;
      p_dbax_session   wdx_log.dbax_session%TYPE;
      p_user_name      wdx_log.log_user%TYPE;
      p_appid          wdx_log.appid%TYPE;
      p_log_level      wdx_log.log_level%TYPE;
      p_date_from      VARCHAR2 (21);
      p_date_to        VARCHAR2 (21);
      p_log_text       VARCHAR2 (32000);
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Datatable POST parameters
      p_draw      := NVL (dbax_utils.get (dbax_core.g$post, 'draw'), 1);
      p_start     := NVL (dbax_utils.get (dbax_core.g$post, 'start'), 0);
      p_length    := NVL (dbax_utils.get (dbax_core.g$post, 'length'), 10);
      p_order_column := NVL (dbax_utils.get (dbax_core.g$post, 'order[0][column]'), 1);
      p_order_dir := NVL (dbax_utils.get (dbax_core.g$post, 'order[0][dir]'), 'desc');

      --Campos del filtrado que están en las variables de sesión
      p_log_id    := dbax_utils.get (dbax_session.g$session, 'log_id');
      p_dbax_session := dbax_utils.get (dbax_session.g$session, 'dbax_session');
      p_user_name := dbax_utils.get (dbax_session.g$session, 'user_name');
      p_appid     := dbax_utils.get (dbax_session.g$session, 'appid');
      p_date_from := dbax_utils.get (dbax_session.g$session, 'date_from');
      p_date_to   := dbax_utils.get (dbax_session.g$session, 'date_to');
      p_log_text  := dbax_utils.get (dbax_session.g$session, 'log_text');

      --Variable Json que se bindea en la query
      l_bind_json.put (':log_id', p_log_id);
      l_bind_json.put (':dbax_session', '%' || UPPER (p_dbax_session) || '%');
      l_bind_json.put (':user_name', '%' || UPPER (p_user_name) || '%');
      l_bind_json.put (':appid', p_appid);
      l_bind_json.put (':date_from', p_date_from);
      l_bind_json.put (':date_to', p_date_to);
      --l_bind_json.put (':log_text',  '%'||p_log_text||'%');
      l_bind_json.put (':log_text', p_log_text);

      --Dynamic query
      l_query     :=
         q'[SELECT /*+ first_rows(25) */
          id
         , appid
         , created_date
         , dbax_session
         , log_user
          FROM   wdx_log
          WHERE 1 = 1 ]';

      --Optional Filter bind variables
      IF p_log_id IS NOT NULL
      THEN
         l_where     := l_where || ' and id = :log_id ';
      ELSE
         l_where     := l_where || ' and (1=1 or :log_id is null) ';
      END IF;


      IF p_user_name IS NOT NULL
      THEN
         l_where     := l_where || ' and log_user like :user_name ';
      ELSE
         l_where     := l_where || ' and (1=1 or :user_name is null) ';
      END IF;

      IF p_dbax_session IS NOT NULL
      THEN
         l_where     := l_where || ' and dbax_session like :dbax_session ';
      ELSE
         l_where     := l_where || ' and (1=1 or :dbax_session is null) ';
      END IF;

      IF p_appid IS NOT NULL
      THEN
         l_where     := l_where || ' and appid = :appid ';
      ELSE
         l_where     := l_where || ' and (1=1 or :appid is null) ';
      END IF;

      IF p_date_from IS NOT NULL
      THEN
         l_where     := l_where || q'[ and created_date >= to_date(:date_from, 'YYYY/MM/DD hh24:mi:ss') ]';
      ELSE
         l_where     := l_where || ' and (1=1 or :date_from is null) ';
      END IF;

      IF p_date_to IS NOT NULL
      THEN
         l_where     := l_where || q'[ and created_date <= to_date(:date_to, 'YYYY/MM/DD hh24:mi:ss') ]';
      ELSE
         l_where     := l_where || ' and (1=1 or :date_to is null) ';
      END IF;

      IF p_date_to IS NOT NULL
      THEN
         l_where     := l_where || q'[ and created_date <= to_date(:date_to, 'YYYY/MM/DD hh24:mi:ss') ]';
      ELSE
         l_where     := l_where || ' and (1=1 or :date_to is null) ';
      END IF;

      IF p_log_text IS NOT NULL
      THEN
         --Sync Oracle Text Index
         --CTX_DDL.SYNC_INDEX('wdx_log_text_idx');

         l_where     := l_where || ' and CONTAINS(log_text,:log_text) > 0';
      ELSE
         l_where     := l_where || ' and (1=1 or :log_text is null) ';
      END IF;

      l_where     := l_where || ' ORDER BY ' || p_order_column || ' ' || p_order_dir;

      --File Download
      IF dbax_core.g$parameter.EXISTS (1) AND dbax_core.g$parameter (1) IS NOT NULL
      THEN
         l_query     :=
            q'[SELECT
              id
             , appid
             , created_date
             , dbax_session
             , log_user
          FROM   wdx_log
          WHERE 1 = 1 ]';

         l_query     := l_query || l_where;

         IF LOWER (dbax_core.g$parameter (1)) = 'xlsx'
         THEN
            dbax_document.download_xlsx (l_query, 'log_table.xlsx', l_bind_json);
         ELSIF LOWER (dbax_core.g$parameter (1)) = 'csv'
         THEN
            dbax_document.download_csv (l_query, 'log_table.csv', l_bind_json);
         END IF;

         --Stop process and return
         dbax_core.g_stop_process := TRUE;
         RETURN;
      ELSE
         l_query     := l_query || l_where;
      END IF;

      dbax_log.debug (l_query);

      --Get Datatable JSON in CLOB
      l_json_clob :=
         dbax_datatable.get_json_data (l_query
                                     , p_draw
                                     , p_start
                                     , p_length
                                     , l_bind_json);

      --The response is application/json
      dbax_core.g$content_type := 'application/json';
      dbax_core.g$status_line := 200;
      dbax_core.p (l_json_clob);
   END logs_get_list;



   PROCEDURE logs_search
   AS
      l_out_json   json;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Define session variables
      dbax_session.g$session ('log_id') := dbax_utils.get (dbax_core.g$post, 'log_id');
      dbax_session.g$session ('dbax_session') := dbax_utils.get (dbax_core.g$post, 'dbax_session');
      dbax_session.g$session ('user_name') := dbax_utils.get (dbax_core.g$post, 'user_name');
      dbax_session.g$session ('appid') := dbax_utils.get (dbax_core.g$post, 'appid');
      dbax_session.g$session ('date_from') := dbax_utils.get (dbax_core.g$post, 'date_from');
      dbax_session.g$session ('date_to') := dbax_utils.get (dbax_core.g$post, 'date_to');
      dbax_session.g$session ('log_text') := dbax_utils.get (dbax_core.g$post, 'log_text');
      dbax_session.save_sesison_variable;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      l_out_json  := json ();
      l_out_json.put ('text', 'Search filter Ok');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   END logs_search;

   PROCEDURE logs_delete
   AS
      l_data_values   DBMS_UTILITY.maxname_array;
      l_rowid         VARCHAR2 (64);
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));

      --Delete selected Logs
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         l_rowid     := l_data_values (i);
         tapi_wdx_log.del_rowid (l_rowid);
      END LOOP;
   END logs_delete;

   PROCEDURE logs_get_log
   AS
      l_out_json     json;
      l_log_id       tapi_wdx_log.id;
      l_wdx_log_rt   tapi_wdx_log.wdx_log_rt;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --Get logid paramter
      l_log_id    := dbax_core.g$parameter (1);

      IF l_log_id IS NOT NULL
      THEN
         l_wdx_log_rt := tapi_wdx_log.rt (l_log_id);

         dbax_core.g$content_type := 'text/plain';
         --Escape log text
         dbax_core.p (DBMS_XMLGEN.CONVERT (l_wdx_log_rt.log_text, 0));
      END IF;
   END logs_get_log;


   PROCEDURE users
   AS
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      dbax_core.load_view ('users');
   END users;

   PROCEDURE user_profile
   AS
      l_users_rt   tapi_wdx_users.wdx_users_rt;
   BEGIN
      /**
     * The user must be an Admin
     **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --If user parameter is null redirect to users
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/users');
         RETURN;
      END IF;

      --Get username from parameter
      l_users_rt.username := dbax_core.g$parameter (1);

      --Get user
      BEGIN
         l_users_rt  := tapi_wdx_users.rt (l_users_rt.username);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --User not exits redirect to users
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/users');
            RETURN;
      END;

      --View Data
      dbax_core.g$view ('profile_username') := l_users_rt.username;
      dbax_core.g$view ('profile_first_name') := l_users_rt.first_name;
      dbax_core.g$view ('profile_last_name') := l_users_rt.last_name;
      dbax_core.g$view ('profile_display_name') := l_users_rt.display_name;
      dbax_core.g$view ('profile_email') := l_users_rt.email;
      dbax_core.g$view ('profile_status') := l_users_rt.status;
      dbax_core.g$view ('profile_created_by') := l_users_rt.created_by;
      dbax_core.g$view ('profile_created_date') := TO_CHAR (l_users_rt.created_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('profile_modified_by') := l_users_rt.modified_by;
      dbax_core.g$view ('profile_modified_date') := TO_CHAR (l_users_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss');
      dbax_core.g$view ('profile_hash') := l_users_rt.hash;

      --If user has null password the form will be disabled
      IF l_users_rt.password IS NULL
      THEN
         dbax_core.g$view ('disabled') := 'disabled="disabled"';
         dbax_core.g$view ('alert_pwd') := '1';
      END IF;

      dbax_core.g$view ('profile_page_views') := tapi_wdx_log.count_user_page_views (l_users_rt.username);
      dbax_core.g$view ('profile_active_sessions') := tapi_wdx_sessions.count_user_sessions (l_users_rt.username);
      dbax_core.g$view ('profile_expired_sessions') :=
         tapi_wdx_sessions.count_user_sessions (l_users_rt.username, FALSE);

      DECLARE
         l_user_options_rt   tapi_wdx_user_options.wdx_user_options_rt;
      BEGIN
         --Toggle Sidebar Option
         l_user_options_rt := tapi_wdx_user_options.rt (l_users_rt.username, dbax_core.g$appid, 'togglesidebar');

         IF l_user_options_rt.VALUE = 'on'
         THEN
            dbax_core.g$view ('checkedToggleSidebar') := 'checked';
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      dbax_core.load_view ('user_profile');
   END user_profile;

   PROCEDURE update_user
   AS
      l_user_rt   tapi_wdx_users.wdx_users_rt;
      l_json      json := json ();

      e_null_param exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      --Post parameters
      l_user_rt.username := dbax_utils.get (dbax_core.g$post, 'profile_username');
      l_user_rt.first_name := dbax_utils.get (dbax_core.g$post, 'profile_first_name');
      l_user_rt.last_name := dbax_utils.get (dbax_core.g$post, 'profile_last_name');
      l_user_rt.display_name := dbax_utils.get (dbax_core.g$post, 'profile_display_name');
      l_user_rt.email := dbax_utils.get (dbax_core.g$post, 'profile_email');
      l_user_rt.status := dbax_utils.get (dbax_core.g$post, 'profile_status');
      l_user_rt.modified_by := dbax_core.g$username;
      l_user_rt.modified_date := SYSDATE;
      l_user_rt.hash := dbax_utils.get (dbax_core.g$post, 'profile_hash');

      --Update
      IF l_user_rt.username IS NOT NULL
      THEN
         tapi_wdx_users.web_upd (p_wdx_users_rec => l_user_rt, p_ignore_nulls => TRUE);
      ELSE
         RAISE e_null_param;
      END IF;

      --Return values
      l_user_rt   := tapi_wdx_users.rt (l_user_rt.username);

      --Return JSON
      l_json.put ('profile_hash', l_user_rt.hash);
      l_json.put ('profile_modified_by', l_user_rt.modified_by);
      l_json.put ('profile_modified_date', TO_CHAR (l_user_rt.modified_date, 'YYYY/MM/DD hh24:mi:ss'));
      l_json.put ('text', '');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END update_user;


   PROCEDURE change_user_password
   AS
      p_old_password       VARCHAR2 (256);
      p_new_password       VARCHAR2 (256);
      p_confirm_password   VARCHAR2 (256);
      p_username           VARCHAR2 (255);
      l_json               json := json ();

      e_null_param exception;
      e_confirm_pwd exception;
      e_changed exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is text/plain
      dbax_core.g$content_type := 'text/plain';

      --Post parameters
      p_old_password := dbax_utils.get (dbax_core.g$post, 'old_password');
      p_new_password := dbax_utils.get (dbax_core.g$post, 'new_password');
      p_confirm_password := dbax_utils.get (dbax_core.g$post, 'confirm_new_password');
      p_username  := dbax_core.g$parameter (1);

      --Check param
      IF p_username IS NULL OR p_confirm_password IS NULL OR p_new_password IS NULL
      THEN
         RAISE e_null_param;
      END IF;

      --chanbge password
      IF p_confirm_password = p_new_password
      THEN
         BEGIN
            dbax_security.change_password (p_username, p_old_password, p_new_password);
         EXCEPTION
            WHEN OTHERS
            THEN
               IF SQLCODE = -20000
               THEN
                  RAISE e_changed;
               ELSE
                  RAISE;
               END IF;
         END;
      ELSE
         RAISE e_confirm_pwd;
      END IF;

      --Return JSON
      l_json.put ('text', ' Password changed');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN e_changed
      THEN
         ROLLBACK;

         l_json.put ('cod_error', -2);
         l_json.put ('msg_error', ' Invalid username/password');
         dbax_core.p (l_json.TO_CHAR);
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', ' some parameters are null');
         dbax_core.p (l_json.TO_CHAR);
      WHEN e_confirm_pwd
      THEN
         ROLLBACK;

         l_json.put ('cod_error', -2);
         l_json.put ('msg_error', 'New Password and Confirm Password are not the same');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END change_user_password;


   PROCEDURE delete_users
   AS
      l_out_json      json;
      l_username      tapi_wdx_users.username;
      l_data_values   DBMS_UTILITY.maxname_array;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --The response is application/json
      dbax_core.g$content_type := 'application/json';

      --The data are a serialized array
      l_data_values := dbax_utils.tokenizer (utl_url.unescape (dbax_core.g$post ('data')));

      --Delete selected user
      FOR i IN 1 .. l_data_values.COUNT ()
      LOOP
         --Key is escaped
         l_username  := utl_url.unescape (l_data_values (i));

         --First delete user_roles
         FOR c1 IN (SELECT   * FROM table (tapi_wdx_users_roles.tt (l_username)))
         LOOP
            tapi_wdx_users_roles.del (l_username, c1.rolename, c1.appid);
         END LOOP;

         --Delete user
         tapi_wdx_users.del (l_username);
      END LOOP;


      l_out_json  := json ();
      l_out_json.put ('text', l_data_values.COUNT () || ' items deleted.');

      --Return values
      dbax_core.g$status_line := 200;
      dbax_core.p (l_out_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$status_line := 500;
         dbax_core.p (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
   END delete_users;

   PROCEDURE new_user
   AS
      l_user_rt   tapi_wdx_users.wdx_users_rt;
      l_json      json := json ();

      e_null_param exception;
      e_confirm_pwd exception;
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      -- IF METHOD is GET load view else create user
      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('newUser');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         --Post parameters
         l_user_rt.username := dbax_utils.get (dbax_core.g$post, 'new_username');
         l_user_rt.first_name := dbax_utils.get (dbax_core.g$post, 'new_first_name');
         l_user_rt.last_name := dbax_utils.get (dbax_core.g$post, 'new_last_name');
         l_user_rt.display_name := dbax_utils.get (dbax_core.g$post, 'new_display_name');
         l_user_rt.email := dbax_utils.get (dbax_core.g$post, 'new_email');
         l_user_rt.modified_by := dbax_core.g$username;
         l_user_rt.modified_date := SYSDATE;
         l_user_rt.password := dbax_utils.get (dbax_core.g$post, 'new_password');

         IF l_user_rt.password <> dbax_utils.get (dbax_core.g$post, 'new_confirm_password')
            OR dbax_utils.get (dbax_core.g$post, 'new_confirm_password') IS NULL
         THEN
            RAISE e_confirm_pwd;
         END IF;

         --Update
         IF l_user_rt.username IS NOT NULL
         THEN
            --Security password
            l_user_rt.password := dbax_security.pbkdf2 (l_user_rt.password);

            --Create user
            tapi_wdx_users.ins (l_user_rt);
         ELSE
            RAISE e_null_param;
         END IF;

         l_json.put ('text', '');

         --Return json
         dbax_core.p (l_json.TO_CHAR);
      ELSE
         NULL;
      END IF;
   EXCEPTION
      WHEN e_null_param
      THEN
         ROLLBACK;

         l_json.put ('cod_error', 100);
         l_json.put ('msg_error', 'current_app_id and key are mondatory');
         dbax_core.p (l_json.TO_CHAR);
      WHEN e_confirm_pwd
      THEN
         ROLLBACK;

         l_json.put ('cod_error', -2);
         l_json.put ('msg_error', 'New Password and Confirm Password are not the same');
         dbax_core.p (l_json.TO_CHAR);
      WHEN OTHERS
      THEN
         ROLLBACK;
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         dbax_core.p (l_json.TO_CHAR);
   END new_user;

   PROCEDURE user_layout_options
   AS
      l_user_options_rt   tapi_wdx_user_options.wdx_user_options_rt;
      l_json              json := json ();
      l_username          tapi_wdx_user_options.username;
      l_key               tapi_wdx_user_options.key;
      l_togglesidebar     VARCHAR2 (10);
   BEGIN
      /**
      * The user must be an Admin
      **/
      IF NOT f_admin_user
      THEN
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/401');
         RETURN;
      END IF;

      --If user parameter is null return
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         RETURN;
      END IF;

      --Get username from parameter
      l_username  := dbax_core.g$parameter (1);

      --Toggle Sidebar Option
      l_key       := 'togglesidebar';
      l_togglesidebar := dbax_utils.get (dbax_core.g$post, l_key);

      BEGIN
         --get option
         l_user_options_rt := tapi_wdx_user_options.rt (l_username, dbax_core.g$appid, l_key);

         --Update
         l_user_options_rt.VALUE := l_togglesidebar;
         l_user_options_rt.modified_by := dbax_core.g$username;

         tapi_wdx_user_options.upd (l_user_options_rt);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --Insert
            l_user_options_rt.username := l_username;
            l_user_options_rt.appid := dbax_core.g$appid;
            l_user_options_rt.key := l_key;
            l_user_options_rt.VALUE := l_togglesidebar;
            l_user_options_rt.created_by := dbax_core.g$username;
            l_user_options_rt.modified_by := dbax_core.g$username;
            tapi_wdx_user_options.ins (l_user_options_rt);
      END;

      l_json.put ('text', 'ok');

      --Return json
      dbax_core.p (l_json.TO_CHAR);
   EXCEPTION
      WHEN OTHERS
      THEN
         l_json.put ('cod_error', SQLCODE);
         l_json.put ('msg_error', SQLERRM);
         dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         RAISE;
   END user_layout_options;


   PROCEDURE export_security (p_appid IN tapi_wdx_applications.appid)
   AS
      l_blob_content   BLOB;
   BEGIN
      l_blob_content := pk_m_dbax_console.export_security (UPPER (p_appid));

      -- TODO dbax_document.download_this
      HTP.init;
      OWA_UTIL.mime_header ('application/zip', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="dbax_' || UPPER (p_appid) || '_security.zip"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);

      DBMS_LOB.freetemporary (l_blob_content);

      --Stop process and return
      dbax_core.g_stop_process := TRUE;
   END export_security;

   PROCEDURE import_security (p_appid IN tapi_wdx_applications.appid)
   AS
      l_real_file_name     VARCHAR2 (256);
      l_tmp_blob           BLOB;
      l_reqvalidation_rt   tapi_wdx_reqvalidation.wdx_request_valid_function_rt;
      l_xml_data           XMLTYPE;
      --
      e_different_application exception;
      PRAGMA EXCEPTION_INIT (e_different_application, -20001);
   BEGIN
      dbax_core.g$view ('module') := 'Security';
      dbax_core.g$view ('current_app_id') := p_appid;
      dbax_core.g$view ('module_icon') := 'fa fa-lock';

      IF dbax_core.g$server ('REQUEST_METHOD') = 'GET'
      THEN
         dbax_core.load_view ('importApplicationFile');
         RETURN;
      ELSIF dbax_core.g$server ('REQUEST_METHOD') = 'POST'
      THEN
         l_real_file_name :=
            dbax_document.upload (dbax_core.g$post ('file')
                                , dbax_core.g$appid
                                , dbax_security.get_username (dbax_core.g$appid));

         l_tmp_blob  := dbax_document.get_file_content (l_real_file_name);

         pk_m_dbax_console.import_security (l_tmp_blob, p_appid);

         -- Everything well
         dbax_core.g$status_line := 303;
         dbax_core.g$http_header ('Location') :=
            dbax_core.get_path ('/applications/edit/' || UPPER (p_appid) || '#Security');
      END IF;
   EXCEPTION
      WHEN e_different_application
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing Security. You can not import security metadata from other applications';
         dbax_core.load_view ('importApplicationFile');
      WHEN OTHERS
      THEN
         ROLLBACK;
         dbax_core.g$view ('errorMessage') :=
            'Error importing Security: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ();
         dbax_core.load_view ('importApplicationFile');
   END import_security;
END pk_c_dbax_console;
/