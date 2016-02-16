CREATE OR REPLACE PACKAGE json_util_pkg authid current_user
AS
   /*
   Purpose:    JSON utilities for PL/SQL
   Remarks:
   Who     Date        Description
   ------  ----------  -------------------------------------
   MBR     30.01.2010  Created
   OSM     16.12.2015  Add new transformation xsl and functions
   */

   --Constats for format Type
   json_object CONSTANT   PLS_INTEGER := 0;
   json_list CONSTANT     PLS_INTEGER := 1;

   TYPE t_str_array IS TABLE OF VARCHAR2 (4000);

   -- generate JSON from REF Cursor
   FUNCTION ref_cursor_to_json (p_ref_cursor   IN sys_refcursor
                              , p_max_rows     IN NUMBER:= NULL
                              , p_skip_rows    IN NUMBER:= NULL)
      RETURN CLOB;

   -- generate JSON from SQL statement
   FUNCTION sql_to_json (p_sql            IN VARCHAR2
                       , p_param_names    IN t_str_array:= NULL
                       , p_param_values   IN t_str_array:= NULL
                       , p_max_rows       IN NUMBER:= NULL
                       , p_skip_rows      IN NUMBER:= NULL)
      RETURN CLOB;

   /**
   * Oscar Salvador Magallanes New Functions
   */
   FUNCTION ref_cursor_to_json_2 (p_ref_cursor    IN sys_refcursor
                                , p_max_rows      IN NUMBER:= NULL
                                , p_skip_rows     IN NUMBER:= NULL
                                , p_format_type   IN VARCHAR2:= JSON_OBJECT
                                , p_object_name   IN VARCHAR2:= 'data')
      RETURN CLOB;

   FUNCTION sql_to_json_2 (p_sql            IN VARCHAR2
                         , p_param_names    IN t_str_array:= NULL
                         , p_param_values   IN t_str_array:= NULL
                         , p_max_rows       IN NUMBER:= NULL
                         , p_skip_rows      IN NUMBER:= NULL
                         , p_format_type    IN VARCHAR2:= JSON_OBJECT
                         , p_object_name    IN VARCHAR2:= 'data')
      RETURN CLOB;
END json_util_pkg;
/