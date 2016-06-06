CREATE OR REPLACE PACKAGE dbax_ldap
AS
   /**
   * DBAX_LDAP
   * dbax LDAP API
   */

   /** Remember create ACLs
   BEGIN
      dbms_network_acl_admin.create_acl (acl         => 'ldap_acl_file.xml'
                                       , description => 'ACL to grant access to LDAP server'
                                       , principal   => 'DBAX'
                                       , is_grant    => TRUE
                                       , privilege   => 'connect'
                                       , start_date  => NULL
                                       , end_date    => NULL);

      dbms_network_acl_admin.assign_acl (acl         => 'ldap_acl_file.xml'
                                       , HOST        => ':HOST'
                                       , lower_port  => ':389'
                                       , upper_port  => NULL);

      COMMIT;
   END;
   */

   /**
   * Validates a user against LDAP settings in the table WDX_LDAP
   *
   * @param      p_ldap_name    the ldap name that is primary key in the table WDX_LDAP
   * @param      p_username     the user name
   * @param      p_password     the user password
   */
   FUNCTION ldap_validation (p_ldap_name IN VARCHAR2, p_username IN VARCHAR2, p_password IN VARCHAR2)
      RETURN BOOLEAN;


   /**
   * Validates a user against LDAP settings in the table WDX_LDAP
   *
   * @param      p_host         the ldap server hostname
   * @param      p_port         the ldap server port numer
   * @param      p_dn           the distinguished name of the user that we are trying to login as
   * @param      p_username     the user name
   * @param      p_password     the user password
   * @return     p_cod_error    the error code. 0 is no error
   * @return     p_msg_error    the error message.
   */
   PROCEDURE test_ldap_connection (p_host        IN     VARCHAR2
                                 , p_port        IN     PLS_INTEGER
                                 , p_dn          IN     VARCHAR2
                                 , p_username    IN     VARCHAR2
                                 , p_password    IN     VARCHAR2
                                 , p_cod_error      OUT PLS_INTEGER
                                 , p_msg_error      OUT VARCHAR2);
END dbax_ldap;
/