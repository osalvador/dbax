--
-- DBAX_DATATABLE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_datatable
AS
   PROCEDURE bind_json (l_cur NUMBER, bindvar json)
   AS
      keylist   json_list := bindvar.get_keys ();
   BEGIN
      FOR i IN 1 .. keylist.COUNT
      LOOP
         IF (bindvar.get (i).get_type = 'number')
         THEN
            DBMS_SQL.bind_variable (l_cur, ':' || keylist.get (i).get_string, bindvar.get (i).get_number);
         ELSIF (bindvar.get (i).get_type = 'array')
         THEN
            DECLARE
               v_bind   DBMS_SQL.varchar2_table;
               v_arr    json_list := json_list (bindvar.get (i));
            BEGIN
               FOR j IN 1 .. v_arr.COUNT
               LOOP
                  v_bind (j)  := v_arr.get (j).value_of;
               END LOOP;

               DBMS_SQL.bind_array (l_cur, ':' || keylist.get (i).get_string, v_bind);
            END;
         ELSE
            DBMS_SQL.bind_variable (l_cur, ':' || keylist.get (i).get_string, bindvar.get (i).value_of ());
         END IF;
      END LOOP;
   END bind_json;

   FUNCTION executelist (stmt IN CLOB, bindvar IN json, total_rows OUT NUMBER)
      RETURN CLOB
   AS
      l_cursor       NUMBER;
      l_return       NUMBER;

      l_ref_cursor   sys_refcursor;

      l_out_clob     CLOB;
      l_tmp_clob     CLOB;
      l_ctx          DBMS_XMLGEN.ctxhandle;
      l_xml          XMLTYPE;
      l_xsl          XMLTYPE;
   BEGIN
      l_cursor    := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_cursor, stmt, DBMS_SQL.native);

      IF (bindvar IS NOT NULL)
      THEN
         bind_json (l_cursor, bindvar);
      END IF;

      l_return    := DBMS_SQL.execute (l_cursor);

      -- Connvert from DBMS_SQL to a REF CURSOR.
      l_ref_cursor := DBMS_SQL.to_refcursor (l_cursor);

      l_ctx       := DBMS_XMLGEN.newcontext (l_ref_cursor);
      dbms_xmlgen.setNullHandling(l_ctx, dbms_xmlgen.EMPTY_TAG);
      l_xml       := DBMS_XMLGEN.getxmltype (l_ctx);

      --Close cursors
      DBMS_XMLGEN.closecontext (l_ctx);

      CLOSE l_ref_cursor;

      --xml2json
      SELECT   XMLTRANSFORM (l_xml, g_xml2json).getclobval () INTO l_tmp_clob FROM DUAL;

      --Return Json list
      IF LENGTH (l_tmp_clob) > 0
      THEN
         DBMS_LOB.createtemporary (l_out_clob, FALSE, DBMS_LOB.call);
         DBMS_LOB.COPY (l_out_clob
                      , l_tmp_clob
                      , LENGTH (l_tmp_clob) - 2
                      , 1
                      , 2);

         --Extract Total Rows
         SELECT   EXTRACTVALUE (l_xml, '/ROWSET/ROW[1]/DT_TotalRows') INTO total_rows FROM DUAL;

         RETURN l_out_clob;

         DBMS_LOB.freetemporary (l_out_clob);
      ELSE
         total_rows  := 0;
         l_out_clob  := '[]';
         RETURN l_out_clob;
      END IF;
   END executelist;

   FUNCTION get_json_data (p_query           IN CLOB
                          , p_draw            IN PLS_INTEGER DEFAULT 1
                          , p_start           IN PLS_INTEGER DEFAULT 0
                          , p_length          IN PLS_INTEGER DEFAULT 1
                          , p_bindvar         IN json DEFAULT NULL)
      RETURN CLOB
   AS
      l_query         CLOB;
      l_bind_json     json;
      l_json_list     json_list;
      l_total_rows    PLS_INTEGER;
      l_return_data   CLOB;
   BEGIN
      l_query     :=
         'SELECT * FROM  (SELECT   user_query.*
                                 , ROWIDTOCHAR(rowid) "DT_RowId"
                                 , ROW_NUMBER () OVER (ORDER BY 0 ASC) "DT_RowNum"
                                 , count(*) over() "DT_TotalRows"                                  
                                  FROM     ('
         || p_query
         || ') user_query
                          ) result
          WHERE      "DT_RowNum" BETWEEN :dbax_datatable_start + 1 AND :dbax_datatable_start + :dbax_datatable_length
          ORDER BY   "DT_RowNum"';

      --Variables to bind
      IF p_bindvar IS NOT NULL
      THEN
         l_bind_json := p_bindvar;
      ELSE
         l_bind_json := json ();
      END IF;

      IF p_start IS NOT NULL
      THEN
         l_bind_json.put (':dbax_datatable_start', p_start);
      END IF;

      IF p_length IS NOT NULL
      THEN
         l_bind_json.put (':dbax_datatable_length', p_length);
      END IF;

      l_return_data := executelist (l_query, l_bind_json, l_total_rows);

      l_return_data :=
            '{"draw":'
         || p_draw
         || ',"recordsTotal":'
         || l_total_rows
         || ',"recordsFiltered":'
         || l_total_rows
         || ',"data":'
         || l_return_data
         || '}';

      RETURN l_return_data;
   END get_json_data;
END dbax_datatable;
/


