/* Formatted on 15/02/2016 15:07:27 (QP5 v5.115.810.9015) */
CREATE OR REPLACE PACKAGE dbax_htmltable
   AUTHID CURRENT_USER
AS
   /**
   * # DBAX_HTMLTABLE
   * Version: 0.1.
   * Description: HTML table generator from SYS_REFCursor
   */

   /**
   * Generate HTML table from received cursor.
   * To invoke the function with a query varchar instead of a sys_refcursor, you can do
   * "OPEN l_cursor FOR l_query USING parameter"
   *
   * @param  p_cursor           the ref cursor to transform to HTML Table.
   * @param  p_table_id         the HTML table ID.
   * @param  p_table_class      the HTML table class.
   * @return                    the generated html table
   */
   FUNCTION refcursor2html (p_cursor        IN sys_refcursor
                          , p_table_id      IN VARCHAR2 DEFAULT NULL
                          , p_table_class   IN VARCHAR2 DEFAULT NULL
                          , p_thead         IN BOOLEAN DEFAULT TRUE)
      RETURN CLOB;
END dbax_htmltable;
/