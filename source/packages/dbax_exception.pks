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
   * Raise an HTTP 500 error to the user with their description. 
   * If enabled, shows to the user all the error trace, as well as the line of code that caused the exception.
   *
   * @param     p_error_code        the user error code number
   * @param     p_error_msg         the user error message text 
   */
   PROCEDURE raise (p_error_code IN NUMBER, p_error_msg IN VARCHAR2);

   
END dbax_exception;
/


