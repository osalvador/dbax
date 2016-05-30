CREATE OR REPLACE PACKAGE      dbax_exception
AS
   /**
   -- # DBAX_EXCEPTION
   -- Version: 0.1. <br/>
   -- Description: DBAX Exception Handler
   */

   --##Global Variables
   TYPE g_assoc_array
   IS
      TABLE OF VARCHAR2 (32000)
         INDEX BY VARCHAR2 (255);

   --G$ERROR User error array
   g$error   g_assoc_array;

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
   PROCEDURE raise (p_error_code IN NUMBER, p_error_msg IN VARCHAR2);

   
END dbax_exception;
/


