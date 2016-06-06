CREATE OR REPLACE PACKAGE BODY dbax_ldap
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
       WHERE   name = p_ldap_name;

      l_wdx_ldap.dn := REPLACE (l_wdx_ldap.dn, '%LDAP_USER%', p_username);
      l_wdx_ldap.filter := REPLACE (l_wdx_ldap.filter, '%LDAP_USER%', p_username);

      --LDAP Exceptions
      DBMS_LDAP.use_exception := TRUE;

      --Get LDAP session
      l_session   := DBMS_LDAP.init (l_wdx_ldap.HOST, l_wdx_ldap.port);

      IF l_session IS NULL
      THEN
         dbax_log.error ('Could not connect to LDAP ' || p_ldap_name || ' and the user' || p_username);
         RETURN FALSE;
      ELSE
         BEGIN
            -- User Auth
            l_retval    :=
               DBMS_LDAP.simple_bind_s (ld => l_session, dn => l_wdx_ldap.dn, passwd => CONVERT (p_password, 'UTF8'));

            --The user has been authenticated
            IF l_wdx_ldap.base IS NOT NULL AND l_wdx_ldap.filter IS NOT NULL
               AND (   l_wdx_ldap.attr_first_name IS NOT NULL
                    OR l_wdx_ldap.attr_last_name IS NOT NULL
                    OR l_wdx_ldap.attr_email IS NOT NULL)
            THEN
               --Check null values
               l_attrs (0) := NVL (l_wdx_ldap.attr_first_name, 'NULL');
               l_attrs (1) := NVL (l_wdx_ldap.attr_last_name, 'NULL');
               l_attrs (2) := NVL (l_wdx_ldap.attr_email, 'NULL');

               --Search users
               l_retval    :=
                  DBMS_LDAP.search_s (ld          => l_session
                                    , base        => l_wdx_ldap.base
                                    , scope       => DBMS_LDAP.scope_onelevel
                                    , filter      => l_wdx_ldap.filter
                                    , attrs       => l_attrs
                                    , attronly    => 0
                                    , res         => my_message);

               -- first entry
               my_entry    := DBMS_LDAP.first_entry (l_session, my_message);

               WHILE my_entry IS NOT NULL
               LOOP
                  -- first attribute
                  my_attr_name := DBMS_LDAP.first_attribute (l_session, my_entry, my_ber_elmt);

                  WHILE my_attr_name IS NOT NULL
                  LOOP
                     -- Get attribute values
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

                     -- next attribute
                     my_attr_name := DBMS_LDAP.next_attribute (l_session, my_entry, my_ber_elmt);
                  END LOOP;

                  --UPSERT user
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

                  -- next entry
                  my_entry    := DBMS_LDAP.next_entry (l_session, my_entry);
               END LOOP;
            END IF;

            RETURN TRUE;
         EXCEPTION
            WHEN OTHERS
            THEN
               /* UNBIND */
               l_retval    := DBMS_LDAP.unbind_s (l_session);
               dbax_log.error (SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
               RETURN FALSE;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         dbax_log.error ('OTHERS: ' || SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace ());
         RETURN FALSE;
   END ldap_validation;


   PROCEDURE test_ldap_connection (p_host        IN     VARCHAR2
                                 , p_port        IN     PLS_INTEGER
                                 , p_dn          IN     VARCHAR2
                                 , p_username    IN     VARCHAR2
                                 , p_password    IN     VARCHAR2
                                 , p_cod_error      OUT PLS_INTEGER
                                 , p_msg_error      OUT VARCHAR2)
   AS
      l_retval    PLS_INTEGER;
      l_session   DBMS_LDAP.session;
      --
      l_dn        VARCHAR2 (2000);
      --
      e_null_param exception;
      e_some_exception exception;
   BEGIN
      IF p_host IS NULL OR p_port IS NULL OR p_dn IS NULL OR p_username IS NULL OR p_password IS NULL
      THEN
         RAISE e_null_param;
      END IF;

      l_dn        := REPLACE (p_dn, '%LDAP_USER%', p_username);

      --LDAP Exceptions
      DBMS_LDAP.use_exception := TRUE;

      --Get LDAP session
      l_session   := DBMS_LDAP.init (p_host, p_port);

      IF l_session IS NULL
      THEN
         RAISE e_some_exception;
      ELSE
         BEGIN
            -- User Auth
            l_retval    := DBMS_LDAP.simple_bind_s (ld => l_session, dn => l_dn, passwd => CONVERT (p_password, 'UTF8'));

            p_cod_error := 0;
            p_msg_error := 'The user has been successfully authenticated';
         EXCEPTION
            WHEN OTHERS
            THEN
               /* UNBIND */
               l_retval    := DBMS_LDAP.unbind_s (l_session);
               RAISE;
         END;
      END IF;
   EXCEPTION
      WHEN e_null_param
      THEN
         p_cod_error := 1;
         p_msg_error := 'some input parameter is null';
      WHEN e_some_exception
      THEN
         p_cod_error := 2;
         p_msg_error := 'Could not connect to LDAP';
      WHEN OTHERS
      THEN
         p_cod_error := SQLCODE;
         p_msg_error :=
               SQLERRM
            || CHR (10)
            || 'HOST:'
            || p_host
            || CHR (10)
            || 'PORT:'
            || p_port
            || CHR (10)
            || 'DN:'
            || l_dn
            || CHR (10)
            || 'USERNAME:'
            || p_username;
   END;
END dbax_ldap;
/