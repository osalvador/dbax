/* Formatted on 27/05/2016 17:02:13 (QP5 v5.115.810.9015) */
CREATE OR REPLACE PACKAGE dbax.dbax_log
AS
   /**
   * DBAX_LOG
   * Inserting log statements into your code is a low-tech method for debugging it.
   * With dbax_log is possible to enable logging at runtime without modifying the log_level.
   *
   * dbax_log stores all the information received since the log is open until it closes,
   * that is, when it is stored in the WDX_LOG table.
   *
   * It aims to store in one row all information about a single HTTP request.
   *
   */

   --Constants
   k_log_level_none CONSTANT        NUMBER := 0;
   k_log_level_error CONSTANT       NUMBER := 1;
   k_log_level_warn CONSTANT        NUMBER := 2;
   k_log_level_info CONSTANT        NUMBER := 3;
   k_log_level_debug CONSTANT       NUMBER := 4;
   k_log_level_trace CONSTANT       NUMBER := 5;

   k_log_level_none_str CONSTANT    VARCHAR2 (10) := 'none';
   k_log_level_error_str CONSTANT   VARCHAR2 (10) := 'error';
   k_log_level_warn_str CONSTANT    VARCHAR2 (10) := 'warn';
   k_log_level_info_str CONSTANT    VARCHAR2 (10) := 'info';
   k_log_level_debug_str CONSTANT   VARCHAR2 (10) := 'debug';
   k_log_level_trace_str CONSTANT   VARCHAR2 (10) := 'trace';


   PROCEDURE open_log (p_log_level IN VARCHAR2);

   PROCEDURE close_log;

   FUNCTION close_log
      RETURN tapi_wdx_log.id;

   FUNCTION get_log_level_str (p_log_level IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_log_context
      RETURN VARCHAR2;

   PROCEDURE trace (p_log_text IN CLOB);

   PROCEDURE debug (p_log_text IN CLOB);

   PROCEDURE info (p_log_text IN CLOB);

   PROCEDURE warn (p_log_text IN CLOB);

   PROCEDURE error (p_log_text IN CLOB);
END dbax_log;
/