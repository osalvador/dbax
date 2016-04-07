CREATE OR REPLACE PACKAGE DBAX.dbax_core
AS
   /**
   -- # DBAX_CORE
   -- Version: 0.1. <br/>
   -- Description: HTML interpreter for embedded PL/SQL
   */

   --Global Variables
   TYPE g_assoc_array
   IS
      TABLE OF VARCHAR2 (32767)
         INDEX BY VARCHAR2 (255);

   --G$VAR User session global variables
   g$var            g_assoc_array;

   --G$VIEW View variables (constants) to be replaced
   g$view           g_assoc_array;

   --G$GET HTTP GET QUERY_STRING params for GET request
   g$get            g_assoc_array;

   --G$POST HTTP POST params for POST request
   g$post           g_assoc_array;

   --G$SERVER OWA CGI Environment
   g$server         g_assoc_array;

   --G$HEADERS Response HTTP Headers
   g$http_header    g_assoc_array;

   --G$STATUS_LINE HTTP CODE Header status line (200,404,500...)
   g$status_line    PLS_INTEGER := 200;

   --G_STOP_PROCESS Boolean that indicates stop dbax ngine
   g_stop_process   BOOLEAN := FALSE;

   --MVC
   --G$CONTROLLER MVC controller to execute
   g$controller     VARCHAR2 (100);

   --G$VIEW_NAME page to loaded by view, not by controller
   g$view_name      VARCHAR2 (300);

   --G$PARAMETER MVC URL parameters ../<pramamter1>/<pramamter2>/<pramamterN>
   g$parameter      DBMS_UTILITY.lname_array;

   --Application Variables

   --G$APPID Current Application ID
   g$appid          VARCHAR2 (50);

   --G$H_VIEW Loaded Views for HTTP buffer
   --g$h_view         CLOB;

   --Empty array for dynamic parameter
   empty_vc_arr     OWA_UTIL.vc_arr;

   --Mime Type for response
   g$content_type   VARCHAR2 (100) := 'text/html';

   --Username if user is logged
   g$username       VARCHAR2 (255);

   /**
   --## Function Name: DISPATCHER
   --### Description:
   --       DBAX Dispatcher. All request will be dispatch by DBAX dispatcher.
   --
   --### IN Paramters
   --    | Name | Type | Description
   --    | -- | -- | --
   --   | p_path | VARCHAR2 | HTTP URL request
   --### Return
   --    | Name | Type | Description
   --    | -- | -- | --
   --   |  HTTP PAGE | BUFFER | HTML response
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|02/02/2015    | Oscar Salvador Magallanes | Creacion del procedimiento
   */
   PROCEDURE dispatcher (p_appid       IN VARCHAR2
                       , name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                       , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr );

   FUNCTION get_propertie (p_key IN wdx_properties.key%TYPE)
      RETURN VARCHAR2;

   PROCEDURE load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL );

   FUNCTION get_path (p_local_path IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;

   --Establece los parametros globales g$get y g$set en funcion de la request realizada
   PROCEDURE set_request (name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                        , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr );


   /*MOD PLSQL validation function. Solo los procedimientos que esta funcion devuelva true pueden ser invocados*/
   FUNCTION request_validation_function (procedure_name IN VARCHAR2)
      RETURN BOOLEAN;
      
   /**
   * Prints received data into the buffer
   *
   * @param  p_data     the data to print into buffer
   */
   PROCEDURE PRINT (p_data IN CLOB);

   PROCEDURE p (p_data IN CLOB);

   PROCEDURE PRINT (p_data IN VARCHAR2);

   PROCEDURE p (p_data IN VARCHAR2);

   PROCEDURE PRINT (p_data IN NUMBER);

   PROCEDURE p (p_data IN NUMBER);
   
/*
*
*  HTTP Header
*
*/
--PROCEDURE print_http_header;
END dbax_core; 
/

