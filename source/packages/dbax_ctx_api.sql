-- Create the context.
CREATE OR REPLACE CONTEXT dbax_ctx USING dbax_ctx_api ACCESSED GLOBALLY;

-- Create the package to manage the context.

CREATE OR REPLACE PACKAGE dbax_ctx_api
AS
   PROCEDURE set_parameter (p_name IN VARCHAR2, p_value IN VARCHAR2);

   FUNCTION get_parameter (p_name IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE clear_context (p_name IN VARCHAR2);

   PROCEDURE clear_all_context;
END dbax_ctx_api;
/

CREATE OR REPLACE PACKAGE BODY dbax_ctx_api
IS
   PROCEDURE set_parameter (p_name IN VARCHAR2, p_value IN VARCHAR2)
   IS
   BEGIN
      DBMS_SESSION.set_context ('DBAX_CTX'
                              , UPPER (p_name)
                              , '[' || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh24:mi:ss') || ']' || p_value );
   END set_parameter;

   FUNCTION get_parameter (p_name IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_date   VARCHAR2 (31);
      l_value varchar2(4000);
   BEGIN
      l_value := SYS_CONTEXT ('DBAX_CTX', UPPER (p_name));
      
      l_date      :=
         REGEXP_SUBSTR (l_value
                      , '\[([^,].*?)\]'
                      , 1
                      , 1
                      , 'n'
                      , 1);

      IF (sysdate - TO_DATE (l_date, 'yyyy-mm-dd hh24:mi:ss')) > (10 / (24 * 60)) /*max cache age*/
      THEN
         RETURN NULL;
      ELSE
         RETURN substr(l_value, instr(l_value, ']')+1);
      END IF;
   END;

   PROCEDURE clear_context (p_name IN VARCHAR2)
   IS
   BEGIN
      DBMS_SESSION.clear_context ('DBAX_CTX', NULL, UPPER (p_name));
   END clear_context;

   PROCEDURE clear_all_context
   IS
   BEGIN
      DBMS_SESSION.clear_all_context ('DBAX_CTX');
   END clear_all_context;
END dbax_ctx_api;
/