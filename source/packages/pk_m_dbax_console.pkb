CREATE OR REPLACE PACKAGE BODY DBAX.pk_m_dbax_console
AS
   PROCEDURE properties_ins (p_wdx_properties_rec IN OUT tapi_wdx_properties.wdx_properties_rt)
   AS
   BEGIN
      tapi_wdx_properties.ins (p_wdx_properties_rec);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;
   END properties_ins;

   PROCEDURE new_application (p_application_rt   IN tapi_wdx_applications.wdx_applications_rt
                            , p_appid_template   IN tapi_wdx_applications.appid DEFAULT 'DEFAULT' )
   AS
      l_application_rt   tapi_wdx_applications.wdx_applications_rt;
      l_properties_rt    tapi_wdx_properties.wdx_properties_rt;
      l_req_valid        tapi_wdx_reqvalidation.wdx_request_valid_function_rt;
      l_view_rt          tapi_wdx_views.wdx_views_rt;
      l_route_rt         tapi_wdx_map_routes.wdx_map_routes_rt;
      l_roles_rt         tapi_wdx_roles.wdx_roles_rt;
      l_permissions_rt   tapi_wdx_permissions.wdx_permissions_rt;
      l_roles_pmsn_rt    tapi_wdx_roles_pmsn.wdx_roles_pmsn_rt;
      --
      l_vars             teplsql.t_assoc_array;
      l_source           VARCHAR2 (32767);
   BEGIN
      --Application data
      l_application_rt := p_application_rt;
      l_application_rt.appid := UPPER (l_application_rt.appid);

      /*
      * Create aplication
      */
      tapi_wdx_applications.ins (l_application_rt);

      /*
      * Create properties
      */
      --Insert application properties
      l_properties_rt.appid := l_application_rt.appid;
      l_properties_rt.created_by := dbax_core.g$username;
      l_properties_rt.created_date := SYSDATE;
      l_properties_rt.modified_by := dbax_core.g$username;
      l_properties_rt.modified_date := SYSDATE;

      --Create template properties
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_properties.tt (p_appid_template)))
      LOOP
         l_properties_rt.key := c1.key;
         l_properties_rt.VALUE := c1.VALUE;
         l_properties_rt.description := c1.description;
         tapi_wdx_properties.ins (l_properties_rt);
      END LOOP;

      --Create mondatory properties
      l_properties_rt.key := 'base_path';
      l_properties_rt.VALUE := '/dbax/!' || LOWER (l_application_rt.appid) || '?p=';
      l_properties_rt.description := 'The base URL path of the Application.';
      properties_ins (l_properties_rt);
      --
      l_properties_rt.key := 'content-encoding';
      l_properties_rt.VALUE := 'gzip';
      l_properties_rt.description := 'Default HTTP content-encoding: text/html, gzip...';
      properties_ins (l_properties_rt);
      --
      l_properties_rt.key := 'encoding';
      l_properties_rt.VALUE := 'UTF8';
      l_properties_rt.description := 'Database Encoding. Indicates the charset encoding HTTP header.';
      properties_ins (l_properties_rt);
      --
      l_properties_rt.key := 'log_level';
      l_properties_rt.VALUE := 'debug';
      l_properties_rt.description := 'Aplication log level.none, error, warn, info, debug, trace';
      properties_ins (l_properties_rt);
      --
      l_properties_rt.key := 'resources_url';
      l_properties_rt.VALUE := '/resources';
      l_properties_rt.description := 'Resources location (images, js, css etc...)';
      properties_ins (l_properties_rt);
      --
      l_properties_rt.key := 'session_cookie_name';
      l_properties_rt.VALUE := 'dbax_' || LOWER (l_application_rt.appid);
      l_properties_rt.description := 'Session cookie name.';
      properties_ins (l_properties_rt);

      /*
      * Create Request validation function
      */
      l_req_valid.procedure_name := LOWER (l_application_rt.appid);
      l_req_valid.appid := l_application_rt.appid;
      l_req_valid.created_by := dbax_core.g$username;
      l_req_valid.created_date := SYSDATE;
      l_req_valid.modified_by := dbax_core.g$username;
      l_req_valid.modified_date := SYSDATE;
      tapi_wdx_reqvalidation.ins (l_req_valid);

      /*
      * Create Views
      */
      l_view_rt.appid := l_application_rt.appid;
      l_view_rt.created_by := dbax_core.g$username;
      l_view_rt.created_date := SYSDATE;
      l_view_rt.modified_by := dbax_core.g$username;
      l_view_rt.modified_date := SYSDATE;

      --Create template views
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_views.tt (p_appid_template)))
      LOOP
         l_view_rt.name := c1.name;
         l_view_rt.title := c1.title;
         l_view_rt.source := c1.source;
         l_view_rt.description := c1.description;
         l_view_rt.visible := c1.visible;
         tapi_wdx_views.ins (l_view_rt);
      END LOOP;

      /*
      * Create Routes
      */
      l_route_rt.appid := l_application_rt.appid;
      l_route_rt.created_by := dbax_core.g$username;
      l_route_rt.created_date := SYSDATE;
      l_route_rt.modified_by := dbax_core.g$username;
      l_route_rt.modified_date := SYSDATE;

      FOR c1 IN (  SELECT   *
                     FROM   table (tapi_wdx_map_routes.tt (p_appid_template))
                 ORDER BY   priority)
      LOOP
         l_route_rt.route_name := REPLACE (c1.route_name, '${appid}', l_application_rt.appid);
         l_route_rt.priority := c1.priority;
         l_route_rt.url_pattern := REPLACE (c1.url_pattern, '${appid}', l_application_rt.appid);
         l_route_rt.controller_method := REPLACE (c1.controller_method, '${appid}', l_application_rt.appid);
         l_route_rt.view_name := REPLACE (c1.view_name, '${appid}', l_application_rt.appid);
         l_route_rt.description := REPLACE (c1.description, '${appid}', l_application_rt.appid);
         l_route_rt.active := c1.active;
         tapi_wdx_map_routes.ins (l_route_rt);
      END LOOP;

      /*
      * Create roles
      */
      l_roles_rt.appid := l_application_rt.appid;
      l_roles_rt.created_by := dbax_core.g$username;
      l_roles_rt.created_date := SYSDATE;
      l_roles_rt.modified_by := dbax_core.g$username;
      l_roles_rt.modified_date := SYSDATE;

      FOR c1 IN (SELECT   * FROM table (tapi_wdx_roles.tt (p_appid => p_appid_template)))
      LOOP
         l_roles_rt.rolename := c1.rolename;
         l_roles_rt.role_descr := c1.role_descr;
         tapi_wdx_roles.ins (l_roles_rt);
      END LOOP;

      /*
      * Create Permissions
      */
      l_permissions_rt.appid := l_application_rt.appid;
      l_permissions_rt.created_by := dbax_core.g$username;
      l_permissions_rt.created_date := SYSDATE;
      l_permissions_rt.modified_by := dbax_core.g$username;
      l_permissions_rt.modified_date := SYSDATE;

      FOR c1 IN (SELECT   * FROM table (tapi_wdx_permissions.tt (p_appid => p_appid_template)))
      LOOP
         l_permissions_rt.pmsname := c1.pmsname;
         l_permissions_rt.pmsn_descr := c1.pmsn_descr;
         tapi_wdx_permissions.ins (l_permissions_rt);
      END LOOP;

      /*
      * Create roles permissions
      */
      l_roles_pmsn_rt.appid := l_application_rt.appid;
      l_roles_pmsn_rt.created_by := dbax_core.g$username;
      l_roles_pmsn_rt.created_date := SYSDATE;
      l_roles_pmsn_rt.modified_by := dbax_core.g$username;
      l_roles_pmsn_rt.modified_date := SYSDATE;

      FOR c1 IN (SELECT   * FROM table (tapi_wdx_roles_pmsn.tt (p_appid => p_appid_template)))
      LOOP
         l_roles_pmsn_rt.rolename := c1.rolename;
         l_roles_pmsn_rt.pmsname := c1.pmsname;
         tapi_wdx_roles_pmsn.ins (l_roles_pmsn_rt);
      END LOOP;

      /*
      * Create application procedure
      */
      l_source    :=
         q'[CREATE OR REPLACE PROCEDURE ${appid} (name_array    IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr
                                  , value_array   IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr )
AS
   l_appid CONSTANT   VARCHAR2 (100) := '${appid}';
BEGIN
   --Just call to Dispatcher
   dbax_core.dispatcher (l_appid, name_array, value_array);
EXCEPTION
   WHEN OTHERS
   THEN
      dbax_log.set_log_context ('error');
      dbax_core.g$appid := l_appid;
      dbax_log.error (SQLCODE || ' ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
      dbax_log.close_log;
      RAISE;
END;]';
      --Render source code
      l_vars ('appid') := l_application_rt.appid;
      l_source    := teplsql.render (l_vars, l_source);

      --Compile procedure
      EXECUTE IMMEDIATE l_source;

      /*
      * Create application controller
      */
      l_source    :=
         q'[
CREATE OR REPLACE PACKAGE pk_c_dbax_${appid}
AS
   /**
   * PK_C_DBAX_${appid}
   * DBAX Controller for ${appid} application
   */

   /**
   * Index or home page
   */
   PROCEDURE index_;

   <% if '${access_control}' <> 'PUBLIC' then %>
   /**
   * Controller for login user
   */
   PROCEDURE login;

   /**
   * Controller for logout user
   */
   PROCEDURE logout;
   <%end if;%>
END pk_c_dbax_${appid};]';

      --Render source code
      l_vars ('appid') := l_application_rt.appid;
      l_vars ('access_control') := l_application_rt.access_control;
      l_source    := teplsql.render (l_vars, l_source);

      --Compile package spec
      EXECUTE IMMEDIATE l_source;

      l_source    :=
         q'[CREATE OR REPLACE PACKAGE BODY pk_c_dbax_${appid}
AS

   PROCEDURE index_
   AS
   BEGIN
      dbax_core.load_view ('index');
   END index_;

   <% if '${access_control}' <> 'PUBLIC' then %>
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

   PROCEDURE logout
   AS
   BEGIN
      --End session
      dbax_session.session_end;
      --Redirect to home
      dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
   END logout;
   <%end if;%>
END pk_c_dbax_${appid};]';

      --Render source code
      l_source    := teplsql.render (l_vars, l_source);

      --Compile package body
      EXECUTE IMMEDIATE l_source;
   END new_application;

   PROCEDURE del_application (p_appid IN tapi_wdx_applications.appid)
   AS
   BEGIN
      --Delete properties
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_properties.tt (p_appid)))
      LOOP
         tapi_wdx_properties.del (p_appid, c1.key);
      END LOOP;

      --Delete request validation functions
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_reqvalidation.tt (p_appid)))
      LOOP
         tapi_wdx_reqvalidation.del (p_appid, c1.procedure_name);
      END LOOP;

      --Delete views
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_views.tt (p_appid)))
      LOOP
         tapi_wdx_views.del (p_appid, c1.name);
      END LOOP;

      --delete routes
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_map_routes.tt (p_appid)))
      LOOP
         tapi_wdx_map_routes.del (p_appid, c1.route_name);
      END LOOP;

      --Delete Users Roles
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_users_roles.tt (p_appid => p_appid)))
      LOOP
         tapi_wdx_users_roles.del (c1.username, c1.rolename, p_appid);
      END LOOP;

      --Delete Roles Permissions
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_roles_pmsn.tt (p_appid => p_appid)))
      LOOP
         tapi_wdx_roles_pmsn.del (c1.pmsname, c1.rolename, p_appid);
      END LOOP;

      --Delete Roles
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_roles.tt (p_appid => p_appid)))
      LOOP
         tapi_wdx_roles.del (c1.rolename, p_appid);
      END LOOP;

      --Delete permissions
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_permissions.tt (p_appid => p_appid)))
      LOOP
         tapi_wdx_permissions.del (c1.pmsname, p_appid);
      END LOOP;

      --Delete sessions
      FOR c1 IN (SELECT   * FROM table (tapi_wdx_sessions.tt (p_appid => p_appid)))
      LOOP
         tapi_wdx_sessions.del (p_appid, c1.session_id);
      END LOOP;

      --Delete application
      tapi_wdx_applications.del (p_appid);

      --Drop procedure
      BEGIN
         EXECUTE IMMEDIATE 'DROP PROCEDURE ' || p_appid;
      EXCEPTION
         WHEN OTHERS
         THEN
            dbax_log.warn ('Error dropping ' || p_appid || 'procedure:' || SQLCODE || ' ' || SQLERRM);
      END;
   END del_application;


   FUNCTION latest_modifications
      RETURN latest_mod_tt
      PIPELINED
   IS
      l_latest_mod_rt   latest_mod_rt;
   BEGIN
      FOR c1 IN (SELECT   *
                   FROM   (SELECT   'Application' description
                                  , 'Settings' name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_applications
                           UNION ALL
                           SELECT   'Auth Scheme'
                                  , scheme_name name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_auth_schemes a
                           UNION ALL
                           SELECT   'Document'
                                  , name
                                  , appid
                                  , NULL
                                  , last_updated
                             FROM   wdx_documents a
                           UNION ALL
                           SELECT   'LDAP Settings'
                                  , ldap_name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_ldap aa
                           UNION ALL
                           SELECT   'Route'
                                  , route_name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_map_routes a
                           UNION ALL
                           SELECT   'Permission'
                                  , pmsname
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_permissions a
                           UNION ALL
                           SELECT   'Propertie'
                                  , key
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_properties a
                           UNION ALL
                           SELECT   'Request Validation Function'
                                  , procedure_name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_request_valid_function a
                           UNION ALL
                           SELECT   'Role'
                                  , rolename
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_roles a
                           UNION ALL
                           SELECT   'Role-Permission'
                                  , rolename || '-' || pmsname
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_roles_pmsn a
                           UNION ALL
                           SELECT   'User-Role'
                                  , username || '-' || rolename
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_users_roles a
                           UNION ALL
                           SELECT   'User'
                                  , username
                                  , ''
                                  , modified_by
                                  , modified_date
                             FROM   wdx_users a
                           UNION ALL
                           SELECT   'View'
                                  , name
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_views a
                           UNION ALL
                           SELECT   'User Option'
                                  , username || '-' || key
                                  , appid
                                  , modified_by
                                  , modified_date
                             FROM   wdx_user_options a
                           ORDER BY   modified_date DESC)
                  WHERE   ROWNUM <= 10)
      LOOP
         l_latest_mod_rt.description := c1.description;
         l_latest_mod_rt.name := c1.name;
         l_latest_mod_rt.appid := c1.appid;
         l_latest_mod_rt.modified_by := c1.modified_by;
         l_latest_mod_rt.modified_date := c1.modified_date;

         PIPE ROW (l_latest_mod_rt);
      END LOOP;

      RETURN;
   END latest_modifications;

   FUNCTION get_activity_chart_time (p_minutes_since     IN PLS_INTEGER DEFAULT 480
                                   , p_minutes_section   IN PLS_INTEGER DEFAULT 15 )
      RETURN sys_refcursor
   AS
      l_return_cursor   sys_refcursor;
   BEGIN
      OPEN l_return_cursor FOR
           SELECT   TO_CHAR (TRUNC (created_date, 'hh24')
                             + ( (TRUNC (TO_CHAR (created_date, 'mi') / p_minutes_section) * p_minutes_section) / 24 / 60)
                           , 'dd,hh24:mi')
                       fec
             FROM   wdx_log
            WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)
         GROUP BY   TRUNC (created_date, 'hh24')
                    + ( (TRUNC (TO_CHAR (created_date, 'mi') / p_minutes_section) * p_minutes_section) / 24 / 60)
         ORDER BY   TRUNC (created_date, 'hh24')
                    + ( (TRUNC (TO_CHAR (created_date, 'mi') / p_minutes_section) * p_minutes_section) / 24 / 60);

      RETURN l_return_cursor;
   END get_activity_chart_time;

   FUNCTION get_activity_chart_data (p_minutes_since     IN PLS_INTEGER DEFAULT 480
                                   , p_minutes_section   IN PLS_INTEGER DEFAULT 15 )
      RETURN sys_refcursor
   AS
      l_return_cursor   sys_refcursor;
   BEGIN
      OPEN l_return_cursor FOR
           SELECT   COUNT ( * )
             FROM   wdx_log
            WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)
         GROUP BY   TRUNC (created_date, 'hh24')
                    + ( (TRUNC (TO_CHAR (created_date, 'mi') / p_minutes_section) * p_minutes_section) / 24 / 60)
         ORDER BY   TRUNC (created_date, 'hh24')
                    + ( (TRUNC (TO_CHAR (created_date, 'mi') / p_minutes_section) * p_minutes_section) / 24 / 60);

      RETURN l_return_cursor;
   END get_activity_chart_data;


   FUNCTION get_browser_usage_chart_data (p_minutes_since IN PLS_INTEGER DEFAULT 480 )
      RETURN sys_refcursor
   AS
      l_return_cursor   sys_refcursor;
   BEGIN
      OPEN l_return_cursor FOR
         SELECT   SUM (regexp_count (log_text, 'Chrome/[0-9]')) chrome
           FROM   wdx_log a
          WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)
          UNION ALL
         SELECT   SUM (regexp_count (log_text, 'MSIE\+[0-9]|rv:11|IE\+11')) ie
           FROM   wdx_log a
          WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)
         UNION ALL          
         SELECT   SUM (regexp_count (log_text, 'Firefox/[0-9]')) firefox
           FROM   wdx_log a
          WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)         
         UNION ALL
         SELECT   SUM (regexp_count (log_text, 'Version/[0-9].*Safari/[0-9]')) safari
           FROM   wdx_log a
          WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60)
         UNION ALL
         SELECT   COUNT ( * ) total
           FROM   wdx_log a
          WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60);

/*
           SELECT   SUM (regexp_count (log_text, 'Firefox/[0-9]')) firefox
                         , SUM (regexp_count (log_text, 'Chrome/[0-9]')) chrome
                         , SUM (regexp_count (log_text, 'Version/[0-9].*Safari/[0-9]')) safari
                         , SUM (regexp_count (log_text, 'MSIE\+[0-9]|rv:11|IE\+11')) ie
                         , COUNT ( * ) total
                    FROM   wdx_log a
                   WHERE   created_date >= SYSDATE - (p_minutes_since / 24 / 60);
*/

      RETURN l_return_cursor;
   END get_browser_usage_chart_data;
END pk_m_dbax_console; 
/

