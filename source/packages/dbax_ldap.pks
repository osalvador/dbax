--
-- DBAX_LDAP  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE dbax_ldap
AS
   /**
   -- # DBAX_LDAP
   -- Version: 0.1. <br/>
   -- Description: DBAX LDAP API
   */

   /** Recordar crear los ACLS para LDAP
   BEGIN
      dbms_network_acl_admin.create_acl (acl         => 'ldap_acl_file.xml'
                                       , description => 'ACL to grant access to LDAP server'
                                       , principal   => 'DBAX'
                                       , is_grant    => TRUE
                                       , privilege   => 'connect'
                                       , start_date  => NULL
                                       , end_date    => NULL);

      dbms_network_acl_admin.assign_acl (acl         => 'ldap_acl_file.xml'
                                       , HOST        => 'METALDAP'
                                       , lower_port  => 389
                                       , upper_port  => NULL);

      COMMIT;
   END;
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
   FUNCTION ldap_validation (p_ldap_name IN VARCHAR2, p_username IN VARCHAR2, p_password IN VARCHAR2)
      RETURN BOOLEAN;
END dbax_ldap;
/


