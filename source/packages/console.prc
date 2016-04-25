--
-- CONSOLE  (Procedure) 
--
--  Dependencies: 
--   STANDARD (Package)
--   DBMS_UTILITY (Synonym)
--   OWA_UTIL (Synonym)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--   DBAX_CORE (Package)
--   DBAX_LOG (Package)
--
CREATE OR REPLACE PROCEDURE CONSOLE (name_array  IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr
                                 , value_array   IN OWA_UTIL.vc_arr DEFAULT dbax_core.empty_vc_arr )
AS
   l_appid CONSTANT   VARCHAR2 (100) := 'CONSOLE';
BEGIN
   --Just call to Dispatcher
   dbax_core.dispatcher (l_appid, name_array, value_array);
EXCEPTION
   WHEN OTHERS
   THEN
      dbax_log.open_log ('error');
      dbax_core.g$appid                                  := l_appid;
      dbax_log.error (SQLCODE || ' ' || SQLERRM || ' '   || DBMS_UTILITY.format_error_backtrace ());
      dbax_log.close_log;
      RAISE;
END;
/


