--
-- DBAX_SECURITY  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_security
AS
   g_salt CONSTANT   VARCHAR2 (100) := 'salt';

   /*Password-Based Key Derivation Function 2*/
   FUNCTION pbkdf2 (p_password     IN VARCHAR2
                  , p_salt         IN VARCHAR2 DEFAULT NULL
                  , p_iterations   IN NUMBER DEFAULT 10000
                  , p_key_length   IN NUMBER DEFAULT 256
                                            )
      RETURN VARCHAR2
   IS
      l_salt VARCHAR2 (100);
      --
      l_block_count   NUMBER;
      l_last          RAW (32767);
      l_xorsum        RAW (32767);
      l_result        RAW (32767);
   BEGIN
      IF p_salt is null
      then
        l_salt := g_salt;
      else
        l_salt := p_salt;
      end if;
      
      l_block_count := CEIL (p_key_length / 20); -- 20 bytes for SHA1.

      FOR i IN 1 .. l_block_count
      LOOP
         l_last      :=
            UTL_RAW.CONCAT (UTL_RAW.cast_to_raw (l_salt), UTL_RAW.cast_from_binary_integer (i, UTL_RAW.big_endian));

         l_xorsum    := NULL;

         FOR j IN 1 .. p_iterations
         LOOP
            l_last      := DBMS_CRYPTO.mac (l_last, DBMS_CRYPTO.hmac_sh1, UTL_RAW.cast_to_raw (p_password));

            IF l_xorsum IS NULL
            THEN
               l_xorsum    := l_last;
            ELSE
               l_xorsum    := UTL_RAW.bit_xor (l_xorsum, l_last);
            END IF;
         END LOOP;

         l_result    := UTL_RAW.CONCAT (l_result, l_xorsum);
      END LOOP;

      RETURN RAWTOHEX (UTL_RAW.SUBSTR (l_result, 1, p_key_length));
   END pbkdf2;

   /*Comprueba los permisos del usuario*/
  /* FUNCTION check_user_access (p_appid IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      --App is private
      --Check user_app
      FOR c1
      IN (SELECT   1
            FROM   wdx_users_app ua, wdx_applications a
           WHERE       ua.username = get_username (p_appid)
                   AND ua.appid = p_appid
                   AND ua.appid = a.appid
                   AND a.access_control = 'PRIVATE')
      LOOP
         RETURN TRUE;
      END LOOP;

      --Chek Role User APP
      FOR c1
      IN (SELECT   1
            FROM   wdx_roles_app ra, wdx_users_roles ur, wdx_applications a
           WHERE       ra.appid = p_appid
                   AND ra.appid = a.appid
                   AND ra.rolename = ur.rolename
                   AND ur.username = get_username (p_appid)
                   AND a.access_control = 'PRIVATE')
      LOOP
         RETURN TRUE;
      END LOOP;

      --Or app is protected
      --get the user name to validate that the user is logged in
      IF get_username (p_appid) IS NOT NULL
      THEN
         FOR c1 IN (SELECT   1
                      FROM   wdx_applications a
                     WHERE   a.appid = p_appid AND a.access_control = 'PROTECTED')
         LOOP
            RETURN TRUE;
         END LOOP;
      END IF;

      RETURN FALSE;
   END;*/

   /*Checks if a user has a specific permission on the application*/
--   FUNCTION check_user_pmsn_app (p_pmsname IN VARCHAR2, p_appid IN VARCHAR2, p_username IN VARCHAR2 DEFAULT NULL )
--      RETURN BOOLEAN
--   AS
--   BEGIN
--      FOR c1
--      IN (SELECT   1
--            FROM   wdx_users_roles ur, wdx_permissions p, wdx_roles_pmsn rp
--           WHERE       p.pmsname = p_pmsname
--                   AND p.appid = p_appid
--                   AND ur.username = NVL (p_username, get_username (p_appid))
--                   AND ur.rolename = rp.rolename
--                   AND rp.pmsname = p.pmsname)
--      LOOP
--         RETURN TRUE;
--      END LOOP;

--      RETURN FALSE;
--   END check_user_pmsn_app;
   
   FUNCTION user_hash_pmsn (p_pmsname IN VARCHAR2,p_appid IN VARCHAR2 DEFAULT NULL, p_username in VARCHAR2 DEFAULT NULL)
      RETURN NUMBER      
   AS
   BEGIN
      FOR c1
      IN (SELECT   1
            FROM   wdx_users_roles ur, wdx_permissions p, wdx_roles_pmsn rp
           WHERE       p.pmsname = p_pmsname
                   AND p.appid = NVL(p_appid, dbax_core.g$appid)
                   AND ur.username = NVL (p_username, get_username (NVL(p_appid,dbax_core.g$appid)))
                   AND ur.rolename = rp.rolename
                   AND rp.pmsname = p.pmsname)
      LOOP
         RETURN 1;
      END LOOP;

      RETURN 0;
   END user_hash_pmsn;   

   /*Checks if a user has a specific role on the application*/
   FUNCTION user_hash_role (p_rolename IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL, p_username IN VARCHAR2 DEFAULT NULL )
      RETURN NUMBER
   AS
   BEGIN
      FOR c1
      IN (SELECT   1
            FROM   wdx_users_roles ur, wdx_roles r
           WHERE    r.appid = NVL(p_appid, dbax_core.g$appid)
                   AND ur.username = NVL (p_username, get_username (NVL(p_appid,dbax_core.g$appid)))
                   AND r.rolename = p_rolename
                   and r.rolename = ur.rolename)
      LOOP
         RETURN 1;
      END LOOP;

      RETURN 0;
   END user_hash_role;
   
   /*Checks if a user is logged or has a valid session*/
   FUNCTION check_auth
      RETURN VARCHAR2   
   AS
      l_access_control   wdx_applications.access_control%TYPE;

   BEGIN
      --Check authentication, if the application is not PUBLIC
      SELECT   access_control
        INTO   l_access_control
        FROM   wdx_applications
       WHERE   appid = dbax_core.g$appid;

      IF l_access_control <> 'PUBLIC'
      THEN
         --User is logged in?
         IF dbax_session.get_session IS NULL
         THEN
            dbax_log.debug('CHECK_AUTH Session is null');

            RETURN '0';
         END IF;
      END IF;

      --Update variable g$username
      dbax_core.g$username := get_username(dbax_core.g$appid);
      RETURN '1';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         dbax_log.error('NO_DATA_FOUND ' || SQLCODE || ' ' || SQLERRM);
         RETURN '0';
   END check_auth;   
   
   /*Añade un usuario*/
   PROCEDURE add_user (p_username       IN VARCHAR2
                     , p_password       IN VARCHAR2 DEFAULT NULL
                     , p_first_name     IN VARCHAR2
                     , p_last_name      IN VARCHAR2 DEFAULT NULL
                     , p_display_name   IN VARCHAR2 DEFAULT NULL
                     , p_email          IN VARCHAR2 DEFAULT NULL
                     , p_status         IN NUMBER DEFAULT NULL
                     , p_created_by     IN VARCHAR2 DEFAULT NULL )
   AS
      l_password   wdx_users.password%TYPE := NULL;
   BEGIN
      IF p_password IS NOT NULL
      THEN
         l_password  :=
            pbkdf2 (p_password
                  , g_salt
                  , 10000
                  , 256);
      END IF;

      INSERT INTO wdx_users (username
                           , password
                           , first_name
                           , last_name
                           , display_name
                           , email
                           , status
                           , created_by
                           , modified_by)
        VALUES   (UPPER (p_username)
                , l_password
                , p_first_name
                , p_last_name
                , p_display_name
                , p_email
                , p_status
                , p_created_by
                , p_created_by);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE   wdx_users
            SET   password     = l_password
                , first_name   = p_first_name
                , last_name    = p_last_name
                , display_name = p_display_name
                , email        = p_email
                , status       = p_status
                , modified_by = p_created_by
                , modified_date = SYSDATE
          WHERE   username = UPPER (p_username);
   END add_user;

   /*Cambia la contraseña de un usuario*/

   PROCEDURE change_password (p_username IN VARCHAR2, p_old_password IN VARCHAR2, p_new_password IN VARCHAR2)
   AS
      v_rowid   ROWID;
   BEGIN
          SELECT   ROWID
            INTO   v_rowid
            FROM   wdx_users
           WHERE   username = UPPER (p_username)
                   AND password = pbkdf2 (p_old_password
                                        , g_salt
                                        , 10000
                                        , 256)
      FOR UPDATE   NOWAIT;



      UPDATE   wdx_users
         SET   password     =
                  pbkdf2 (p_new_password
                        , g_salt
                        , 10000
                        , 256)
       WHERE   ROWID = v_rowid;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         raise_application_error (-20000, 'Invalid username/password.');
   END change_password;

   /* Valida la contraseña de un suaurio*/

   PROCEDURE valid_user (p_username IN VARCHAR2, p_password IN VARCHAR2)
   AS
      v_dummy   VARCHAR2 (1);
   BEGIN
      SELECT   '1'
        INTO   v_dummy
        FROM   wdx_users
       WHERE   username = UPPER (p_username)
               AND password = pbkdf2 (p_password
                                    , g_salt
                                    , 10000
                                    , 256);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         raise_application_error (-20000, 'Invalid username/password.');
   END valid_user;

   /* Valida la contraseña de un suaurio sobrecargada*/

   FUNCTION valid_user (p_username IN VARCHAR2, p_password IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      valid_user (p_username, p_password);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END valid_user;

   /* Recupera el nombre del usuario logeado*/
   FUNCTION get_username (p_appid IN VARCHAR2, p_session_id IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
      l_username     VARCHAR2 (255);
      l_session_id   VARCHAR2 (255);
   BEGIN
      l_session_id := NVL (p_session_id, dbax_utils.get (dbax_session.g$session, 'session_id'));

      IF l_session_id IS NOT NULL
      THEN
         SELECT   username
           INTO   l_username
           FROM   wdx_sessions
          WHERE   session_id = l_session_id AND appid = p_appid;

         RETURN l_username;
      ELSE
         RETURN NULL;
      END IF;
   END get_username;

   /*Contiene el proceso de login*/
   FUNCTION login (p_username IN VARCHAR2, p_password IN VARCHAR2, p_appid IN VARCHAR2 DEFAULT NULL )
      RETURN BOOLEAN
   AS
      l_custom_auth_result   PLS_INTEGER := 0;
      l_return               BOOLEAN;
   BEGIN
      --dbax_log.set_log_context (dbax_core.get_varchar_propertie ('LOG_LEVEL'));
      
      dbax_log.debug('LOGIN p_username='||p_username||' p_appid='||p_appid);      
      --Validate user      
      --against DBAX Accounts
      IF valid_user (p_username, p_password)
      THEN
         --Login valid
         RETURN TRUE;
      ELSE
         --Check Auth Scheme
         FOR c1 IN (SELECT   was.scheme
                      FROM   wdx_applications wap, wdx_auth_schemes was
                     WHERE   wap.appid = p_appid AND was.scheme_name = wap.auth_scheme)
         LOOP
            BEGIN
               dbax_log.debug('Validating user against ' || c1.scheme);
               c1.scheme   :=
                  '    DECLARE   
                       l_custom_auth_result   pls_integer := 0;
                    BEGIN
                       IF '
                  || c1.scheme
                  || '
                       THEN
                          :l_custom_auth_result := 1;
                        ELSE
                          :l_custom_auth_result := 0;
                       END IF;
                    END;';

               EXECUTE IMMEDIATE c1.scheme USING IN p_username, IN p_password, OUT l_custom_auth_result;

               IF l_custom_auth_result = 1
               THEN
                  -- Session Valid
                  dbax_log.debug('User and Password are valid');
                  RETURN TRUE;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  dbax_log.error('Error validating user ' || SQLCODE || ' ' || SQLERRM);
                  RETURN FALSE;
            END;
         END LOOP;
      END IF;

      --Invalid user/password
      RETURN FALSE;
   EXCEPTION
      WHEN OTHERS
      THEN
         dbax_exception.raise (SQLCODE, SQLERRM);
   END login;
END dbax_security;
/


