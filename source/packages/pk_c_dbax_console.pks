CREATE OR REPLACE PACKAGE pk_c_dbax_console
AS
   /**
   * PK_C_DBAX_CONSOLE   
   * Controllers for DBAX Console application
   */

   TYPE appl_arr
   IS
      TABLE OF wdx_applications%ROWTYPE
         INDEX BY BINARY_INTEGER;

   PROCEDURE index_;

   /**
   * Controller for login user
   */
   PROCEDURE login;

   /**
   * Controller for logout user
   */
   PROCEDURE LOGOUT;

   /*
   * Example controllers
   */

   PROCEDURE get_log;

   PROCEDURE download;

   /*
   * Applpication Settings controllers
   */
   PROCEDURE applications;

   PROCEDURE new_app;

   PROCEDURE edit_app;

   PROCEDURE upsert_app;

   PROCEDURE delete_app;

   PROCEDURE import_app;

   PROCEDURE export_app;

   /*
   * Properties controllers
   */
   PROCEDURE properties;

   PROCEDURE new_propertie;

   PROCEDURE edit_propertie;

   PROCEDURE delete_propertie;

   PROCEDURE upsert_propertie;

   PROCEDURE export_properties (p_appid IN tapi_wdx_applications.appid);

   PROCEDURE import_properties (p_appid IN tapi_wdx_applications.appid);

   /*
   * Map Routes controllers
   */
   PROCEDURE routes;

   PROCEDURE new_route;

   PROCEDURE edit_route;

   PROCEDURE delete_route;

   PROCEDURE upsert_route;

   PROCEDURE save_routes_order;

   PROCEDURE test_route;

   PROCEDURE import_routes (p_appid IN tapi_wdx_applications.appid);

   PROCEDURE export_routes (p_appid IN tapi_wdx_applications.appid);

   /*
   * Views controllers
   */
   PROCEDURE views_;

   PROCEDURE new_view;

   PROCEDURE edit_view;

   PROCEDURE delete_view;

   PROCEDURE upsert_view;

   PROCEDURE get_source_view;

   PROCEDURE save_source_view;

   PROCEDURE import_view;

   PROCEDURE upload_view;

   --Export selected views
   PROCEDURE export_view;

   PROCEDURE export_all_view;

   /*
   * Request Validation Function controllers
   */
   PROCEDURE reqvalidation;

   PROCEDURE new_reqvalidation;

   PROCEDURE edit_reqvalidation;

   PROCEDURE delete_reqvalidation;

   PROCEDURE upsert_reqvalidation;
   
   PROCEDURE import_reqvalidation (p_appid IN tapi_wdx_applications.appid);

   PROCEDURE export_reqvalidation (p_appid IN tapi_wdx_applications.appid);

   /*
   * Logs controllers
   */
   PROCEDURE logs;

   PROCEDURE logs_get_list;

   PROCEDURE logs_get_log;

   PROCEDURE logs_search;

   PROCEDURE logs_delete;


   /*
   * Roles controllers
   */
   --PROCEDURE roles;

   PROCEDURE new_role;

   PROCEDURE edit_role;

   PROCEDURE delete_role;

   PROCEDURE upsert_role;

   PROCEDURE upsert_roles_users;

   PROCEDURE upsert_roles_permissions;

   /*
   * Permissions controllers
   */

   PROCEDURE new_pmsn;

   PROCEDURE edit_pmsn;

   PROCEDURE delete_pmsn;

   PROCEDURE upsert_pmsn;

   /*
   * Users controllers
   */
   PROCEDURE users;

   PROCEDURE new_user;

   PROCEDURE user_profile;

   PROCEDURE delete_users;

   PROCEDURE update_user;

   PROCEDURE change_user_password;

   PROCEDURE user_layout_options;
   
   /*
   * Security
   */
   PROCEDURE import_security (p_appid IN tapi_wdx_applications.appid);

   PROCEDURE export_security (p_appid IN tapi_wdx_applications.appid);
   
END pk_c_dbax_console;
/