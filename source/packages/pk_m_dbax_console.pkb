CREATE OR REPLACE PACKAGE BODY pk_m_dbax_console
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
         l_route_rt.route_name := REPLACE(c1.route_name,'${appid}',l_application_rt.appid);
         l_route_rt.priority := c1.priority;
         l_route_rt.url_pattern := REPLACE(c1.url_pattern,'${appid}',l_application_rt.appid);
         l_route_rt.controller_method := REPLACE(c1.controller_method,'${appid}',l_application_rt.appid);
         l_route_rt.view_name := REPLACE(c1.view_name,'${appid}',l_application_rt.appid);
         l_route_rt.description := REPLACE(c1.description,'${appid}',l_application_rt.appid);
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

      l_source := q'[CREATE OR REPLACE PACKAGE BODY pk_c_dbax_${appid}
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
        dbax_log.warn ('Error dropping '|| p_appid ||'procedure:' || SQLCODE ||' ' || SQLERRM);
      END;
   END del_application;
END pk_m_dbax_console; 
/

