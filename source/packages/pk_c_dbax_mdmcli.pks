--
-- PK_C_DBAX_MDMCLI  (Package) 
--
CREATE OR REPLACE PACKAGE      pk_c_dbax_MDMCLI
AS
   /**
   * PK_C_DBAX_MDMCLI   
   * DBAX Controller for MDMCLI application
   */

   /**
   * Index or home page
   */
   PROCEDURE index_;

   /**
   * Controller for login user
   */
   PROCEDURE login;
   
   /**
   * Controller for logout user
   */   
   PROCEDURE logout;
   
   /**
   * Controller for consulta de clientes
   */   
   PROCEDURE clientes;
   
   /**
   * Controller for cliente, descripción o perfil completo del cliente
   * @param id_cliente_hub  Se recibe como parámetro de url el id_cliente_hub 
   */   
   PROCEDURE cliente;
END pk_c_dbax_MDMCLI;
/


