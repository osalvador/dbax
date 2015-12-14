--
-- PK_M_DBAX_CONSOLE  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   TAPI_WDX_APPLICATIONS (Package)
--
CREATE OR REPLACE PACKAGE      pk_m_dbax_console
AS
   /**
   -- # PK_M_DBAX_CONSOLE
   -- Version: 0.1. <br/>
   -- Description: Models for DBAX Console
   */

   PROCEDURE new_application (p_application_rt   IN tapi_wdx_applications.wdx_applications_rt
                            , p_appid_template   IN tapi_wdx_applications.appid DEFAULT 'DEFAULT');

   PROCEDURE del_application (p_appid IN tapi_wdx_applications.appid);
END pk_m_dbax_console;
/


