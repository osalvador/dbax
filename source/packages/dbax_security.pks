--
-- DBAX_SECURITY  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE      dbax_security
AS
   /**
   -- # DBAX_SECURITY
   -- Version: 0.1. <br/>
   -- Description: Security management in DBAX
   */


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


   --   /*Obtiene la sesion del usuario*/
   --   FUNCTION get_session (p_cookies IN VARCHAR2 DEFAULT NULL )
   --      RETURN VARCHAR2;

   --   /* Inicia una nueva session, se genera el ticket en al tabla de sesiones. Se define la caducidad de la misma*/
   --   PROCEDURE session_start (p_username      IN VARCHAR2 DEFAULT NULL
   --                          , p_remember_me   IN VARCHAR2 DEFAULT NULL
   --                          , bclose_header   IN BOOLEAN DEFAULT TRUE );

   --   /*Finaliza una sesion. Borra las cookies del usaurio y borra las variables globales*/
   --   PROCEDURE session_end;

   /*Comprueba los permisos del usuario*/
   /*Check whether the user has access to the application*/
   /*FUNCTION check_user_access (p_appid IN VARCHAR2 )
      RETURN BOOLEAN;*/

   /*Checks if a user has a specific permission for the application*/
   FUNCTION user_hash_pmsn (p_pmsname IN VARCHAR2,p_appid IN VARCHAR2 DEFAULT NULL, p_username in VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;      

   /*Checks if a user has a specific role on the application*/
   FUNCTION user_hash_role (p_rolename IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL, p_username IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER;
   
   /*Checks if a user is logged or has a valid session for not public application*/
   FUNCTION check_auth
      RETURN VARCHAR2;
      
   /*Password-Based Key Derivation Function 2*/
   FUNCTION pbkdf2 (p_password     IN VARCHAR2
                  , p_salt         IN VARCHAR2 DEFAULT NULL
                  , p_iterations   IN NUMBER DEFAULT 10000
                  , p_key_length   IN NUMBER DEFAULT 256
                                            )
      RETURN VARCHAR2;

   /*Añade un usuario*/
 /*  PROCEDURE add_user (p_username       IN VARCHAR2
                     , p_password       IN VARCHAR2 DEFAULT NULL
                     , p_first_name     IN VARCHAR2
                     , p_last_name      IN VARCHAR2 DEFAULT NULL
                     , p_display_name   IN VARCHAR2 DEFAULT NULL
                     , p_email          IN VARCHAR2 DEFAULT NULL
                     , p_status         IN NUMBER DEFAULT NULL
                     , p_created_by     IN VARCHAR2 DEFAULT NULL );*/

   /*Cambia la contraseña de un usuario*/
   PROCEDURE change_password (p_username IN VARCHAR2, p_old_password IN VARCHAR2, p_new_password IN VARCHAR2);

   /* Valida la contraseña de un suaurio*/
   --PROCEDURE valid_user (p_username IN VARCHAR2, p_password IN VARCHAR2);

   /* Valida la contraseña de un suaurio sobrecargada*/
   --FUNCTION valid_user (p_username IN VARCHAR2, p_password IN VARCHAR2)
   --   RETURN BOOLEAN;

   /* Recupera el nombre del usuario logeado*/
   FUNCTION get_username(p_appid IN VARCHAR2, p_session_id IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;

   /*Contiene el proceso de login*/
   FUNCTION login (p_username IN VARCHAR2, p_password IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
      RETURN BOOLEAN;
END dbax_security;
/


