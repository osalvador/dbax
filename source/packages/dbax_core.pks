--
-- DBAX_CORE  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   DBMS_UTILITY (Synonym)
--   OWA_UTIL (Synonym)
--   WDX_PROPERTIES (Table)
--
CREATE OR REPLACE PACKAGE      dbax_core
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

   --G$VIEW View variables to be replaced
   g$view           g_assoc_array;

   --G$GET HTTP GET QUERY_STRING params for GET request
   g$get            g_assoc_array;

   --G$POST HTTP POST params for POST request
   g$post           g_assoc_array;

   --G$SERVER OWA CGI Environment
   g$server         g_assoc_array;

   --G$HEADERS HTTP Headers
   g$http_header    g_assoc_array;

   --G$STATUS_LINE HTTP CODE Header status line (200,404,500...)
   g$status_line    PLS_INTEGER := 200;

   --G_STOP_PROCESS Boolean that indicates stop dbax interpreter
   g_stop_process   BOOLEAN := FALSE;

   --MVC
   --G$CONTROLLER MVC controller to execute
   g$controller     VARCHAR2 (100);

   --G$VIEW_NAME page to loaded by view, not by controller
   g$view_name      VARCHAR2 (300);

   --g$method         VARCHAR2(50); ??
   --G$PARAMETER MVC URL parameters ../<pramamter1>/<pramamter2>/<pramamterN>
   g$parameter      DBMS_UTILITY.lname_array;

   --Application Variables
   --G$PATH --TODO lo uso en el get_bar
   g$path           VARCHAR2 (1000) := OWA_UTIL.get_cgi_env ('PATH_INFO');

   --G$APPID Current Application ID
   g$appid          VARCHAR2 (50);

   --G$APP_URL Current Application URL
   g$app_url        VARCHAR2 (500); --TODO is neccesary?

   --G$H_VIEW Loaded Views for HTTP buffer
   g$h_view         CLOB;

   --Empty array for dynamic parameter
   empty_vc_arr     OWA_UTIL.vc_arr;

   --Mime Type for response
   g$content_type   VARCHAR2 (100) := 'text/html';
  
   --Username if user is logged
   g$username VARCHAR2 (255);

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

   FUNCTION set_app (p_app_path IN VARCHAR)
      RETURN BOOLEAN;

   PROCEDURE set_app (p_appid IN VARCHAR2 DEFAULT NULL );

   PROCEDURE include (p_name IN VARCHAR2);

   FUNCTION load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
      RETURN CLOB;

   PROCEDURE load_view (p_name IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL );

   FUNCTION get_path (p_local_path IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;

   --Establece los parametros globales g$get y g$set en funcion de la request realizada
   PROCEDURE set_request (name_array    IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr
                        , value_array   IN OWA_UTIL.vc_arr DEFAULT empty_vc_arr );


   /**
   --## Function Name: INTERPRETER
   --### Description:
   --       It is the interpreter DBAX. It is responsible for amically processing pl/sql code embedded in the HTML code.
   --       It is also responsible for the bind variables by assigning value.
   --       Returns a CLOB with the HTML processed.
   --
   --### IN Paramters
   --    | Name | Type | Description
   --    | -- | -- | --
   --   | p_source | CLOB | HTML preprocessed with PL / SQL embedded
   --### Return
   --    | Name | Type | Description
   --    | -- | -- | --
   --   |   | CLOB | HTML processed
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|02/02/2015    | Oscar Salvador Magallanes | Creacion del procedimiento
   */
   FUNCTION interpreter (p_source IN CLOB, p_name IN VARCHAR2 DEFAULT NULL )
      RETURN CLOB;


   /**
   --## Procedure Name: FLUSH (overloaded)
   --### Description:
   --       Prints the HTML - CLOB passed
   --
   --### IN Paramters
   --   | Name | Type | Description
   --   | -- | -- | --
   --   | p_data | CLOB | HTML data to print
   --
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|02/02/2015    | Oscar Salvador Magallanes | Creation
   */
   PROCEDURE PRINT (p_data IN CLOB);
   
   /**
  --## Function Name: PARSE_URL
  --### Description:
  --       Parse URL QUERY_STRING to associative array g$param
  --
  --### IN Paramters
  --   | Name | Type | Description
  --   | -- | -- | --
  --   | p_url | VARCHAR2 | URL QUERY_STRING `owa_util.get_cgi_env('QUERY_STRING')`
  --
  --### Amendments
  --| When         | Who                      | What
  --|--------------|--------------------------|------------------
  --|12/02/2015    | Oscar Salvador Magallanes | Creation
  */
   --SIN USO porque las variables del query string ya van como variables g$get en el flexible parameters
   --PROCEDURE parse_query_string (p_url IN VARCHAR2);


   /**
   --## Function Name: COOKIE_SEND
   --### Description:
   --       Send cookie to the client. Can be sent anytime , no need to do it in the HTTP header , that makes DBAX
   --       It has the same parameters that the function OWA_COOKIE.SEND
   --
   --### IN Paramters
   --   | Name | Type | Description
   --   | -- | -- | --
   --   | name | VARCHAR2 | COOKIE Name
   --   | value | VARCHAR2 | COOKIE Value
   --   | expires | DATE | The date at which the cookie will expire.
   --   | path | VARCHAR2| The value for the path field.
   --   | domain | VARCHAR2| The value for the domain field.
   --   | secuere | VARCHAR2| If the value of this parameter is not NULL, the "secure" field is added to the line.
   --   | httponly  | VARCHAR2| If the value of this parameter is not NULL, the "HttpOnly" field is added to the line.
   --
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|16/02/2015    | Oscar Salvador Magallanes | Creation
   */
   --   PROCEDURE cookie_send (name       IN VARCHAR2
   --                        , VALUE      IN VARCHAR2
   --                        , expires    IN DATE DEFAULT NULL
   --                        , PATH       IN VARCHAR2 DEFAULT NULL
   --                        , domain     IN VARCHAR2 DEFAULT NULL
   --                        , secure     IN VARCHAR2 DEFAULT NULL
   --                        , httponly   IN VARCHAR2 DEFAULT NULL );

   /*MOD PLSQL validation function. Solo los procedimientos que esta funcion devuelva true pueden ser invocados*/
   FUNCTION request_validation_function (procedure_name IN VARCHAR2)
      RETURN BOOLEAN;


   /*
   *
   *  HTTP Header
   *
   */
   PROCEDURE print_http_header;
END dbax_core;
/


