--
-- DBAX_LDAP  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_ldap
AS
   FUNCTION ldap_validation (p_ldap_name IN VARCHAR2, p_username IN VARCHAR2, p_password IN VARCHAR2)
      RETURN BOOLEAN
   AS
      l_retval       PLS_INTEGER;
      l_session      DBMS_LDAP.session;
      my_attr_name   VARCHAR2 (256);
      l_attrs        DBMS_LDAP.string_collection;
      my_message     DBMS_LDAP.MESSAGE;
      my_entry       DBMS_LDAP.MESSAGE;
      my_ber_elmt    DBMS_LDAP.ber_element;
      my_vals        DBMS_LDAP.string_collection;
      --
      l_wdx_ldap     wdx_ldap%ROWTYPE;
      --
      l_first_name   VARCHAR2 (255);
      l_last_name    VARCHAR2 (255);
      l_email        VARCHAR2 (255);
      --
      l_user_rt      tapi_wdx_users.wdx_users_rt;
      l_new_user     BOOLEAN := FALSE;
   BEGIN
      IF p_username IS NULL OR p_password IS NULL
      THEN
         RETURN FALSE;
      END IF;

      --Fetch LDAP Config
      SELECT   *
        INTO   l_wdx_ldap
        FROM   wdx_ldap
       WHERE   ldap_name = p_ldap_name;

      l_wdx_ldap.dn := REPLACE (l_wdx_ldap.dn, '%LDAP_USER%', p_username);
      l_wdx_ldap.filter := REPLACE (l_wdx_ldap.filter, '%LDAP_USER%', p_username);

      /* EXCEPCIONES LDAP */
      DBMS_LDAP.use_exception := TRUE;
      --Obtenemos sesion LDAP
      l_session   := DBMS_LDAP.init (l_wdx_ldap.HOST, l_wdx_ldap.port);

      IF l_session IS NULL
      THEN
         DBMS_OUTPUT.put_line ('No se puede conectar con el LDAP ');
      ELSE
         BEGIN
            -- Autenticacion del usuario
            l_retval    :=
               DBMS_LDAP.simple_bind_s (ld => l_session, dn => l_wdx_ldap.dn, passwd => CONVERT (p_password, 'UTF8'));

            --Usuario validado correctamente, adelante
            IF l_wdx_ldap.base IS NOT NULL AND l_wdx_ldap.filter IS NOT NULL
               AND (   l_wdx_ldap.attr_first_name IS NOT NULL
                    OR l_wdx_ldap.attr_last_name IS NOT NULL
                    OR l_wdx_ldap.attr_email IS NOT NULL)
            THEN
               -- Atributos del usuario que se quieren obtener
               --Check null values 
               l_wdx_ldap.attr_first_name := NVL(l_wdx_ldap.attr_first_name, 'NULL');
               l_wdx_ldap.attr_last_name := NVL(l_wdx_ldap.attr_last_name, 'NULL');
               l_wdx_ldap.attr_email := NVL(l_wdx_ldap.attr_email, 'NULL');
                                             
               l_attrs (0) := l_wdx_ldap.attr_first_name;
               l_attrs (1) := l_wdx_ldap.attr_last_name;
               l_attrs (2) := l_wdx_ldap.attr_email;

               --Búsqueda de todos los usuarios
               l_retval    :=
                  DBMS_LDAP.search_s (ld          => l_session
                                    , base        => l_wdx_ldap.base
                                    , scope       => DBMS_LDAP.scope_onelevel
                                    , filter      => l_wdx_ldap.filter
                                    , attrs       => l_attrs
                                    , attronly    => 0
                                    , res         => my_message);

               -- Se obtiene la 1ª entrada de la búsqueda
               my_entry    := DBMS_LDAP.first_entry (l_session, my_message);

               WHILE my_entry IS NOT NULL
               LOOP
                  -- Se obtiene el primer atributo
                  my_attr_name := DBMS_LDAP.first_attribute (l_session, my_entry, my_ber_elmt);

                  WHILE my_attr_name IS NOT NULL
                  LOOP
                     --Se obtiene el valor que tiene el atributo en curso de la entrada en curso
                     my_vals     := DBMS_LDAP.get_values (l_session, my_entry, my_attr_name);

                     IF my_vals.COUNT > 0
                     THEN
                        IF my_attr_name = l_wdx_ldap.attr_first_name
                        THEN
                           l_first_name := my_vals (0);
                        ELSIF my_attr_name = l_wdx_ldap.attr_last_name
                        THEN
                           l_last_name := my_vals (0);
                        ELSIF my_attr_name = l_wdx_ldap.attr_email
                        THEN
                           l_email     := my_vals (0);
                        END IF;
                     END IF;

                     --Se obtiene el siguiente atributo de la entrada en curso
                     my_attr_name := DBMS_LDAP.next_attribute (l_session, my_entry, my_ber_elmt);
                  END LOOP;

                  --Get user
                  BEGIN
                     l_user_rt   := tapi_wdx_users.rt (UPPER (p_username));
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_new_user  := TRUE;
                  END;
                
                  l_user_rt.username := UPPER (p_username);      
                  l_user_rt.first_name := l_first_name;      
                  l_user_rt.last_name := l_last_name;
                  l_user_rt.display_name := UPPER (p_username);
                  l_user_rt.email := l_email;          
                  l_user_rt.modified_by := dbax_core.g$username;
                  l_user_rt.modified_date := SYSDATE;                  
                  
                  --Update      
                  IF l_new_user
                  THEN
                    --Create user
                    tapi_wdx_users.ins (l_user_rt);
                    
                  ELSE
                    tapi_wdx_users.upd (l_user_rt);
                  END IF;    

                  --Se obtiene la siguiente entrada de la búsqueda
                  my_entry    := DBMS_LDAP.next_entry (l_session, my_entry);
               END LOOP;
            END IF;

            RETURN TRUE;
         EXCEPTION
            WHEN OTHERS
            THEN
               --el usuario o password erroneos. No tiene acceso a la aplicacion
               /* UNBIND */
               l_retval    := DBMS_LDAP.unbind_s (l_session);
               raise_application_error (-20000, SQLERRM);
               RETURN FALSE;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20000, SQLERRM);
         RETURN FALSE;
   END ldap_validation;
END dbax_ldap;
/


