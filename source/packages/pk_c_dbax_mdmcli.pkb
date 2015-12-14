--
-- PK_C_DBAX_MDMCLI  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      pk_c_dbax_mdmcli
AS
   PROCEDURE index_
   AS
   BEGIN
      dbax_core.load_view ('index');
   END index_;

   PROCEDURE login
   IS
      l_retval        BOOLEAN;
      l_remember_me   DATE;
   BEGIN
      IF dbax_core.g$post.EXISTS ('username')
      THEN
         dbax_log.debug ('LOGIN username: ' || dbax_core.g$post ('username'));

         IF dbax_core.g$post.EXISTS ('remember_me')
         THEN
            --Remember the user and active session during 2 days
            l_remember_me := SYSDATE + 2;
         END IF;

         l_retval    :=
            dbax_security.login (p_username  => dbax_core.g$post ('username')
                               , p_password  => dbax_core.g$post ('password')
                               , p_appid     => dbax_core.g$appid);

         -- Redirect the user
         IF l_retval
         THEN
            --Set User Session
            dbax_log.debug ('Starting session');
            dbax_session.session_start (p_username => dbax_core.g$post ('username'), p_session_expires => l_remember_me);
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
         ELSE
            --Login failed
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/login/loginError');
         END IF;
      ELSE
         --Is user logged?
         dbax_log.debug ('LOGIN GET_SESSION=' || dbax_session.get_session);

         IF dbax_session.get_session IS NULL
         THEN
            dbax_core.load_view ('login');
         ELSE
            --Redirect to home
            dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
         END IF;
      END IF;
   END login;

   PROCEDURE LOGOUT
   AS
   BEGIN
      --End session
      dbax_session.session_end;
      --Redirect to home
      dbax_core.g$http_header ('Location') := dbax_core.get_path ('/index');
   END LOGOUT;

   PROCEDURE clientes
   AS
   BEGIN
      dbax_core.load_view ('clientes');
   END clientes;

   PROCEDURE cliente
   AS
      p_id_cliente_hub   NUMBER;
   BEGIN
      --Recuperamos el id_cliente_hub que viene por parametro de url
      IF NOT dbax_core.g$parameter.EXISTS (1) OR dbax_core.g$parameter (1) IS NULL
      THEN
         --TODO Redireccionar a Aplicaciones? mejor indicar en la vista que Propiedad no encontrada y listo
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/clientes');
         RETURN;
      ELSE
         p_id_cliente_hub := dbax_core.g$parameter (1);
      END IF;

      --Load view variables
      dbax_core.g$view ('id_cliente_hub') := p_id_cliente_hub;

      IF p_id_cliente_hub = 197448
      THEN
         dbax_core.g$view ('nombre') := 'Oscar';
         dbax_core.g$view ('apellido_1') := 'Salvador';
         dbax_core.g$view ('apellido_2') := 'Magallanes';
         dbax_core.g$view ('cod_documento') := '78901071P';
         dbax_core.g$view ('sexo') := 'H';
         dbax_core.g$view ('idioma') := 'ES';
         dbax_core.g$view ('last_update_date') := '09/12/2015';
         
      ELSIF p_id_cliente_hub = 1720859
      THEN
         dbax_core.g$view ('nombre') := 'Jose Ramón';
         dbax_core.g$view ('apellido_1') := initcap('FERNANDEZ DE VILLARAN');
         dbax_core.g$view ('apellido_2') := initcap('GUERRICA ECHEVARRIA');
         dbax_core.g$view ('cod_documento') := '30593501M';
         dbax_core.g$view ('sexo') := 'Mucho';
         dbax_core.g$view ('idioma') := 'ES';
         dbax_core.g$view ('last_update_date') := '09/12/2015';         
      ELSE
         dbax_core.g$http_header ('Location') := dbax_core.get_path ('/clientes');
         RETURN;
      END IF;


      dbax_core.load_view ('cliente');
   END;
END pk_c_dbax_mdmcli;
/


