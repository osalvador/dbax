Rem    NAME
Rem      dbax_install.sql
Rem
Rem    DESCRIPTION
Rem 	 DBAX installation script.
Rem
Rem    REQUIREMENTS
Rem      - Oracle Database 11g or later
Rem
Rem    Example:
Rem      sqlplus "user/userpasss" @dbax_install
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem    osalvador  11/12/2015 - Created

whenever sqlerror exit

PROMPT ------------------------------------------;
PROMPT -- Checking user grants --;
PROMPT ------------------------------------------;

-- User Grants. 
DECLARE
   l_count   PLS_INTEGER := 0;
BEGIN
   --DBMS_CRYPTO
   SELECT   COUNT ( * )
     INTO   l_count
     FROM   (SELECT   1
               FROM   user_tab_privs u
              WHERE   table_name = 'DBMS_CRYPTO' AND privilege = 'EXECUTE'
             UNION ALL
             SELECT   1
               FROM   all_tab_privs a
              WHERE   table_name = 'DBMS_CRYPTO' AND privilege = 'EXECUTE' AND grantee = 'PUBLIC');

   IF l_count = 0
   THEN
      raise_application_error (-20000, 'Execute on DBMS_CRYPTO grant is necessary.');
   END IF;

   --UTL_FILE
   SELECT   COUNT ( * )
     INTO   l_count
     FROM   (SELECT   1
               FROM   user_tab_privs u
              WHERE   table_name = 'UTL_FILE' AND privilege = 'EXECUTE'
             UNION ALL
             SELECT   1
               FROM   all_tab_privs a
              WHERE   table_name = 'UTL_FILE' AND privilege = 'EXECUTE' AND grantee = 'PUBLIC');

   IF l_count = 0
   THEN
      raise_application_error (-20000, 'Execute on UTL_FILE grant is necessary.');
   END IF;
END;
/


PROMPT -- Setting optimize level --
whenever sqlerror exit
SET SCAN OFF
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
ALTER SESSION SET plsql_code_type = 'NATIVE';

PROMPT ------------------------------------------;
PROMPT -- Installing PL/JSON --;
PROMPT ------------------------------------------;
@@../types/json_v1_0_4/install.sql;

PROMPT ------------------------------------------;
PROMPT -- Creating Tables --;
PROMPT ------------------------------------------;
@@../tables/wdx_log_seq.sql;
@@../tables/te_templates.sql;
@@../tables/wdx_applications.sql;
@@../tables/wdx_auth_schemes.sql;
@@../tables/wdx_controllers.sql;
@@../tables/wdx_documents.sql;
@@../tables/wdx_ldap.sql;
@@../tables/wdx_log.sql;
@@../tables/wdx_map_routes.sql;
@@../tables/wdx_permissions.sql;
@@../tables/wdx_properties.sql;
@@../tables/wdx_request_valid_function.sql;
@@../tables/wdx_users.sql;
@@../tables/wdx_roles.sql;
@@../tables/wdx_roles_pmsn.sql;
@@../tables/wdx_sessions.sql;
@@../tables/wdx_user_options.sql;
@@../tables/wdx_users_roles.sql;
@@../tables/wdx_views.sql;

PROMPT ------------------------------------------;
PROMPT -- Installing Packages Specs --;
PROMPT ------------------------------------------;

@@../packages/dbax_core.pks;
@@../packages/dbax_cookie.pks;
@@../packages/pk_c_dbax_console.pks;
@@../packages/dbax_datatable.pks;
@@../packages/teplsql.pks;
@@../packages/tapi_wdx_sessions.pks;
@@../packages/tapi_wdx_users.pks;
@@../packages/dbax_ldap.pks;
@@../packages/dbax_file_parser.pks;
@@../packages/dbax_exception.pks;
@@../packages/dbax_security.pks;
@@../packages/dbax_document.pks;
@@../packages/dbax_log.pks;
@@../packages/dbax_utils.pks;
@@../packages/dbax_session.pks;
@@../packages/tapi_wdx_views.pks;
@@../packages/tapi_wdx_user_options.pks;
@@../packages/tapi_wdx_users_roles.pks;
@@../packages/tapi_gen2.pks;
@@../packages/tapi_wdx_applications.pks;
@@../packages/tapi_wdx_ldap.pks;
@@../packages/tapi_wdx_log.pks;
@@../packages/tapi_wdx_map_routes.pks;
@@../packages/tapi_wdx_permissions.pks;
@@../packages/tapi_wdx_properties.pks;
@@../packages/tapi_wdx_roles_pmsn.pks;
@@../packages/tapi_wdx_roles.pks;
@@../packages/tapi_wdx_reqvalidation.pks;
@@../packages/pk_m_dbax_console.pks;
@@../packages/xlsx_builder_pkg.pks;
@@../packages/json_util_pkg.pks
@@../packages/dbax_htmltable.pks

PROMPT ------------------------------------------;
PROMPT -- Installing Packages Bodies --;
PROMPT ------------------------------------------;

@@../packages/p.prc;
@@../packages/dbax_cookie.pkb;
@@../packages/dbax_core.pkb;
@@../packages/pk_c_dbax_console.pkb;
@@../packages/tapi_gen2.pkb;
@@../packages/tapi_wdx_applications.pkb;
@@../packages/tapi_wdx_ldap.pkb;
@@../packages/tapi_wdx_log.pkb;
@@../packages/tapi_wdx_map_routes.pkb;
@@../packages/tapi_wdx_permissions.pkb;
@@../packages/tapi_wdx_properties.pkb;
@@../packages/tapi_wdx_roles_pmsn.pkb;
@@../packages/tapi_wdx_roles.pkb;
@@../packages/tapi_wdx_reqvalidation.pkb;
@@../packages/xlsx_builder_pkg.pkb;
@@../packages/teplsql.pkb;
@@../packages/tapi_wdx_views.pkb;
@@../packages/tapi_wdx_sessions.pkb;
@@../packages/tapi_wdx_users.pkb;
@@../packages/dbax_ldap.pkb;
@@../packages/dbax_file_parser.pkb;
@@../packages/dbax_exception.pkb;
@@../packages/dbax_security.pkb;
@@../packages/dbax_document.pkb;
@@../packages/dbax_datatable.pkb;
@@../packages/dbax_log.pkb;
@@../packages/dbax_utils.pkb;
@@../packages/dbax_session.pkb;
@@../packages/tapi_wdx_user_options.pkb;
@@../packages/tapi_wdx_users_roles.pkb;
@@../packages/pk_m_dbax_console.pkb;
@@../packages/console.prc;
@@../packages/json_util_pkg.pkb
@@../packages/dbax_htmltable.pkb

quit;
/