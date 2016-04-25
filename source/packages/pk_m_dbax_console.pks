CREATE OR REPLACE PACKAGE pk_m_dbax_console
AS
   /**
   -- # PK_M_DBAX_CONSOLE
   -- Version: 0.1. <br/>
   -- Description: Models for DBAX Console
   */

   --Record type for "Latest Modifications" report
   TYPE latest_mod_rt
   IS
      RECORD (
         description     VARCHAR2 (100)
       , name            VARCHAR2 (100)
       , appid           tapi_wdx_applications.appid
       , modified_by     VARCHAR2 (100)
       , modified_date   DATE
      );

   --Collection types (record)
   TYPE latest_mod_tt IS TABLE OF latest_mod_rt;


   PROCEDURE new_application (p_application_rt   IN tapi_wdx_applications.wdx_applications_rt
                            , p_appid_template   IN tapi_wdx_applications.appid DEFAULT 'DEFAULT' );

   PROCEDURE del_application (p_appid IN tapi_wdx_applications.appid);

   FUNCTION latest_modifications
      RETURN latest_mod_tt
      PIPELINED;


   FUNCTION get_activity_chart_time (p_minutes_since     IN PLS_INTEGER DEFAULT 480
                                   , p_minutes_section   IN PLS_INTEGER DEFAULT 15 )
      RETURN sys_refcursor;

   FUNCTION get_activity_chart_data (p_minutes_since     IN PLS_INTEGER DEFAULT 480
                                   , p_minutes_section   IN PLS_INTEGER DEFAULT 15 )
      RETURN sys_refcursor;

   FUNCTION get_browser_usage_chart_data (p_minutes_since IN PLS_INTEGER DEFAULT 480 )
      RETURN sys_refcursor;

   /**
   * Returns a zipped blob with all metadata files from one application
   *
   * @param  p_appid    the application id to be extracted
   */
   FUNCTION export_app (p_appid IN tapi_wdx_applications.appid)
      RETURN BLOB;

   /**
   * Import metadata files from one application
   *
   * @param  p_zipped_blob  the zipped blob with metadata files
   */
   PROCEDURE import_app (p_zipped_blob IN BLOB, p_new_appid IN tapi_wdx_applications.appid DEFAULT NULL );
      
END pk_m_dbax_console;
/