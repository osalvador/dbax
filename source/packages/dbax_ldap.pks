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
END dbax_ldap;
/


