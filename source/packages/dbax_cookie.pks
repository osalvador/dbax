--
-- DBAX_COOKIE  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   DBAX_CORE (Package)
--
CREATE OR REPLACE PACKAGE dbax_cookie
AS
   /**
   -- # dbax_cookie
   -- Version: 0.1. <br/>
   -- Description: This package provides an interface for sending and retrieving HTTP cookies from the client's browser.
   */

   --##Global Variables ssss
   TYPE cookie_type
   IS
      RECORD (
         VALUE      VARCHAR2 (4096)
       , expires    DATE
       , PATH       VARCHAR2 (255)
       , domain     VARCHAR2 (255)
       , secure     BOOLEAN DEFAULT FALSE
       , httponly   BOOLEAN DEFAULT FALSE
      );

   TYPE g_cookie_array
   IS
      TABLE OF cookie_type
         INDEX BY VARCHAR2 (255);

   --###Request Cookies
   g$req_cookies   dbax_core.g_assoc_array;

   --###Response Cookies
   g$res_cookies   g_cookie_array;

   /**
   --## Function Name: SEND
   --### Description:
   --       Send cookie to the client's browser. Save cookies in an array until dbax_core.dispatcher generates the response.
   --
   --### IN Paramters
   --    | Name | Type | Description
   --    | -- | -- | --
   --  | P_name  | VARCHAR2 | The name of the cookie
   --  | P_VALUE  | VARCHAR2 | The value of the cookie
   --  | P_expires  | DATE | The date at which the cookie will expire
   --  | P_PATH  | VARCHAR2 | The value for the path field.
   --  | P_domain  | VARCHAR2 | The value for the domain field.
   --  | P_secure  | BOOLEAN | TRUE if the secuere field is added to the line
   --  | P_httponly  | BOOLEAN | TRUE if the HttpOnly field is added to the line
   --### Return
   --    | Name | Type | Description
   --    | -- | -- | --
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|16/04/2015    | Oscar Salvador Magallanes | Creacion del procedimiento
   */
--   PROCEDURE send (p_name       IN VARCHAR2
--                 , p_value      IN VARCHAR2
--                 , p_expires    IN DATE DEFAULT NULL
--                 , p_path       IN VARCHAR2 DEFAULT NULL
--                 , p_domain     IN VARCHAR2 DEFAULT NULL
--                 , p_secure     IN BOOLEAN DEFAULT FALSE
--                 , p_httponly   IN BOOLEAN DEFAULT FALSE );

   /**
    --## Function Name: LOAD_COOKIES
    --### Description:
    --       Load client cookies in g$req_cookie variable.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16/04/2015    | Oscar Salvador Magallanes | Creacion del procedimiento
    */
   PROCEDURE load_cookies (p_cookies IN VARCHAR2 DEFAULT NULL );

   /**
   --## Function Name: GENERATE_COOKIE_HEADER
   --### Description:
   --       Generates the HTTP header with the cookies sent to client
   --
   --### IN Paramters
   --    | Name | Type | Description
   --    | -- | -- | --
   --### Return
   --    | Name | Type | Description
   --    | -- | -- | --
   --### Amendments
   --| When         | Who                      | What
   --|--------------|--------------------------|------------------
   --|16/04/2015    | Oscar Salvador Magallanes | Creacion del procedimiento
   */
   FUNCTION generate_cookie_header
      RETURN VARCHAR2;
END dbax_cookie;
/


