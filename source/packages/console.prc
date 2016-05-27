CREATE OR REPLACE PROCEDURE console (name_array    IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr
                                  , value_array   IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr )
AS
   c_appid CONSTANT   VARCHAR2 (100) := 'CONSOLE';
BEGIN
   /**
   * YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
   * OVERWRITTEN WHEN YOU DELETE,IMPORT OR RE-CRATE THE APPLICATION.
   */   
   dbax_core.dispatcher (c_appid, name_array, value_array);
EXCEPTION
   WHEN OTHERS
   THEN
      dbax_log.open_log ('error');
      dbax_core.g$appid := c_appid;
      dbax_exception.raise (SQLCODE, SQLERRM);
      dbax_log.close_log;
END;
/