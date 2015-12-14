--
-- DBAX_SESSION  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   DBAX_CORE (Package)
--
CREATE OR REPLACE PACKAGE      dbax_session
AS
   /**
   -- # DBAX_SESSION
   -- Version: 0.1. <br/>
   -- Description: DBAX Session management

     When a page is loaded, the session_start will check to see if valid session cookie is sent by the user’s browser.

    If a sessions cookie does not exist (or if it doesn’t match one stored on the server or has expired) a new session will be created and saved.

    If a valid session does exist, its information will be updated.

    It’s important for you to understand that once initialized, the Session runs automatically.

    There is nothing you need to do to cause the above behavior to happen. You can, work with session data, but the process of reading, writing, and updating a session is automatic.

    Note:
    Under CLI, the Session library will automatically halt itself, as this is a concept based entirely on the HTTP protocol.
   */

   --##Global Variables
   --G$session User Session Asocciative Array
   g$session   dbax_core.g_assoc_array;


   /*Obtiene la sesion del usuario*/
   FUNCTION get_session (p_cookies IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;

   /* Inicia una nueva session, se genera el ticket en al tabla de sesiones. Se define la caducidad de la misma*/
   PROCEDURE session_start (p_username IN VARCHAR2 DEFAULT NULL , p_session_expires IN DATE DEFAULT NULL );

   /*Finaliza una sesion. Borra las cookies del usaurio y borra las variables globales*/
   PROCEDURE session_end;

   /*Carga las variables de sesion desde el string pasado por parametro en formato queryString*/
   PROCEDURE load_session_variable (p_session_variable IN VARCHAR2);

   /*Guarda en la tabla WDX_SESSIONS las variables de sesion del usuario*/
   PROCEDURE save_sesison_variable;
   
   /*Elimina las variables de sesion*/
   procedure reset_sesison_variable;
   
END dbax_session;
/


