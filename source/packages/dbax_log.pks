--
-- DBAX_LOG  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE      dbax_log
AS
   /**
     -- DBAX_LOG <br/>
    -- Nombre del Paquete: DBAX_LOG <br/>
     -- Versión: 0.1. <br/>
     -- Descripcion:
   -- @headcom
    */

   --Konstants
   k_pk_name CONSTANT               VARCHAR2 (20) := 'DBAX_LOG.';

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



   FUNCTION get_log_level_str (p_log_level IN NUMBER)
      RETURN VARCHAR2;

   -- set log context
   PROCEDURE set_log_context (p_log_level IN VARCHAR2);

   FUNCTION get_log_context
      RETURN VARCHAR2;

   PROCEDURE trace (p_log_text IN CLOB);

   PROCEDURE debug (p_log_text IN CLOB);

   PROCEDURE info (p_log_text IN CLOB);

   PROCEDURE warn (p_log_text IN CLOB);

   PROCEDURE error (p_log_text IN CLOB);

   PROCEDURE close_log;

END dbax_log;
/


