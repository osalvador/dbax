CREATE OR REPLACE PACKAGE BODY DBAX.dbax_document
AS
   FUNCTION clob2blob (p_clob IN CLOB)
      RETURN BLOB
   IS
      v_blob            BLOB;
      l_dest_offset     INTEGER := 1;
      l_source_offset   INTEGER := 1;
      l_lang_context    INTEGER := DBMS_LOB.default_lang_ctx;
      l_warning         INTEGER := DBMS_LOB.warn_inconvertible_char;
   BEGIN
      --Paso el CLOB a BLOB
      DBMS_LOB.createtemporary (v_blob, TRUE);


      DBMS_LOB.converttoblob (dest_lob    => v_blob
                            , src_clob    => p_clob
                            , amount      => DBMS_LOB.getlength (p_clob)
                            , dest_offset => l_dest_offset
                            , src_offset  => l_source_offset
                            , blob_csid   => DBMS_LOB.default_csid
                            , lang_context => l_lang_context
                            , warning     => l_warning);

      -- Free temporary BLOBs.
      --DBMS_LOB.freetemporary (v_blob);
      RETURN v_blob;
   END;


   FUNCTION upload (p_file_name IN VARCHAR2, p_appid IN VARCHAR2, p_username IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
      l_real_name   VARCHAR2 (1000);
   BEGIN
      l_real_name := SUBSTR (p_file_name, INSTR (p_file_name, '/') + 1);

      -- Update any existing document to allow new one.
      UPDATE   wdx_documents
         SET   name         = TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS') || '_' || l_real_name
       WHERE   name = l_real_name AND appid = p_appid;


      UPDATE   wdx_documents
         SET   appid = p_appid, name = l_real_name, username = NVL (p_username, username)
       WHERE   name = p_file_name;

      RETURN l_real_name;
   END upload;

   --Bind variables from cursor passing Json
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

   -- ----------------------------------------------------------------------------

   PROCEDURE set_document (p_file IN BLOB, p_name IN VARCHAR2 DEFAULT NULL )
   AS
      l_file_name   VARCHAR2 (256);
   BEGIN
      IF p_name IS NULL
      THEN
         l_file_name := 'Document_' || TO_CHAR (SYSDATE, 'yyyymmddhh24miss') || '.dat';
      ELSE
         l_file_name := p_name;
      END IF;

      INSERT INTO wdx_documents (name
                               , mime_type
                               , doc_size
                               , dad_charset
                               , last_updated
                               , content_type
                               , blob_content)
        VALUES   (l_file_name
                , NULL
                , DBMS_LOB.getlength (p_file)
                , NULL
                , SYSDATE
                , 'BLOB'
                , p_file);
   END set_document;

   -- ----------------------------------------------------------------------------

   PROCEDURE download (p_file_name IN VARCHAR2, p_appid IN VARCHAR2)
   AS
      -- ----------------------------------------------------------------------------
      l_blob_content   wdx_documents.blob_content%TYPE;
      l_mime_type      wdx_documents.mime_type%TYPE;
   BEGIN
      SELECT   blob_content, mime_type
        INTO   l_blob_content, l_mime_type
        FROM   wdx_documents
       WHERE   name = p_file_name AND appid = p_appid;

      IF l_mime_type IS NULL
      THEN
         l_mime_type := 'text/csv';
      END IF;

      OWA_UTIL.mime_header (l_mime_type, FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));

      HTP.p ('Content-Disposition: attachment; filename="' || p_file_name || '"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('File Download');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Download Status');

         HTP.PRINT (SQLERRM);
         HTP.bodyclose;
         HTP.htmlclose;
   END download;

   -- ----------------------------------------------------------------------------

   PROCEDURE download (p_file IN BLOB)
   AS
      l_mime_type      VARCHAR2 (128);
      l_blob_content   BLOB := p_file;
   BEGIN
      l_mime_type := 'text/csv';

      OWA_UTIL.mime_header (l_mime_type, FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      HTP.p ('Content-Disposition: attachment; filename="Download.xlsx"');
      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('File Download');
         HTP.headclose;

         HTP.bodyopen;
         HTP.header (1, 'Download Status');
         HTP.PRINT (SQLERRM);
         HTP.bodyclose;
         HTP.htmlclose;
   END download;

   PROCEDURE download_xlsx (p_query IN VARCHAR2, p_filename IN VARCHAR2 DEFAULT NULL , p_bindvar IN json DEFAULT NULL )
   AS
      l_blob_content   BLOB;
      l_mime_type      VARCHAR2 (128);
      l_filename       VARCHAR2 (256);
      l_cursor         NUMBER := DBMS_SQL.open_cursor;
   BEGIN
      --Open Cursor
      DBMS_SQL.parse (l_cursor, p_query, DBMS_SQL.native);

      --Bind Varabiales
      IF (p_bindvar IS NOT NULL)
      THEN
         bind_json (l_cursor, p_bindvar);
      END IF;

      --Generate XLSX
      xlsx_builder_pkg.query2sheet (p_cursor => l_cursor, p_column_headers => TRUE);


      l_blob_content := xlsx_builder_pkg.finish;


      --Send to download
      --Microsoft Mime Type
      l_mime_type := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      IF p_filename IS NULL
      THEN
         l_filename  := 'Download.xlsx';
      ELSE
         l_filename  := p_filename;
      END IF;


      HTP.init;
      OWA_UTIL.mime_header (l_mime_type, FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      -- The filename will be used by the browser if the users does a "Save as"
      HTP.p ('Content-Disposition: attachment; filename="' || l_filename || '"');

      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;

         HTP.headopen;
         HTP.title ('File Downloaded');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Download Status');
         HTP.PRINT (SQLERRM || DBMS_UTILITY.format_error_backtrace ());
         HTP.bodyclose;
         HTP.htmlclose;
   END download_xlsx;

   PROCEDURE download_csv (p_query IN VARCHAR2, p_filename IN VARCHAR2 DEFAULT NULL , p_bindvar IN json DEFAULT NULL )
   AS
      l_blob_content   BLOB;

      l_mime_type      VARCHAR2 (128);
      p_separator      VARCHAR2 (10) := ';';
      p_csv            CLOB;
      l_filename       VARCHAR2 (256);
   BEGIN
      --Generamos el CSV a partir de la query
      generate_csv (p_query
                  , p_separator
                  , p_csv
                  , p_bindvar);

      --Pasamos el CLOB a BLOB
      l_blob_content := clob2blob (p_csv);


      l_mime_type := 'text/csv';

      IF p_filename IS NULL
      THEN
         l_filename  := 'Download.csv';
      ELSE
         l_filename  := p_filename;
      END IF;

      HTP.init;
      OWA_UTIL.mime_header (l_mime_type, FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_blob_content));
      -- The filename will be used by the browser if the users does a "Save as"

      HTP.p ('Content-Disposition: attachment; filename="' || l_filename || '"');

      OWA_UTIL.http_header_close;

      WPG_DOCLOAD.download_file (l_blob_content);
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('File Downloaded');
         HTP.headclose;
         HTP.bodyopen;

         HTP.header (1, 'Download Status');
         HTP.PRINT (SQLERRM);
         HTP.bodyclose;
         HTP.htmlclose;
   END download_csv;

   PROCEDURE generate_csv (p_query       IN     VARCHAR2
                         , p_separator   IN     VARCHAR2 DEFAULT ','
                         , p_csv            OUT CLOB
                         , p_bindvar     IN     json DEFAULT NULL )
   AS
      l_cursor             PLS_INTEGER;
      l_rows               PLS_INTEGER;

      l_col_cnt            PLS_INTEGER;
      l_desc_tab           DBMS_SQL.desc_tab;
      l_buffer             VARCHAR2 (32767);
      l_char_columnvalue   VARCHAR2 (32767);
      l_columnvalue        CLOB; --VARCHAR2 (32767);
      g_sep                VARCHAR2 (5) := p_separator;

      l_out_csv            CLOB := EMPTY_CLOB;
   BEGIN
      --Iinicializamos variables
      l_cursor    := DBMS_SQL.open_cursor;
      DBMS_LOB.createtemporary (l_out_csv, TRUE);


      DBMS_SQL.parse (l_cursor, p_query, DBMS_SQL.native);

      --Bind Varabiales
      IF (p_bindvar IS NOT NULL)
      THEN
         bind_json (l_cursor, p_bindvar);
      END IF;

      DBMS_SQL.describe_columns (l_cursor, l_col_cnt, l_desc_tab);

      FOR i IN 1 .. l_col_cnt
      LOOP
         IF l_desc_tab (i).col_type = 112 --Si la columna es CLOB
         THEN
            DBMS_SQL.define_column (l_cursor, i, l_columnvalue);
         ELSE
            DBMS_SQL.define_column (l_cursor
                                  , i
                                  , l_desc_tab (i).col_type
                                  , 32767);
         END IF;
      END LOOP;

      l_rows      := DBMS_SQL.execute (l_cursor);

      -- Output the column names.

      FOR i IN 1 .. l_col_cnt
      LOOP
         IF i > 1
         THEN
            l_buffer    := g_sep;
         END IF;

         l_buffer    := l_buffer || l_desc_tab (i).col_name;
         -- write it to the new clob
         DBMS_LOB.writeappend (l_out_csv, LENGTH (l_buffer), l_buffer);
      END LOOP;



      --Salto de linea por cada registro
      l_buffer    := CHR (10);

      -- write it to the new clob
      DBMS_LOB.writeappend (l_out_csv, LENGTH (l_buffer), l_buffer);

      -- Output the data.
      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows (l_cursor) = 0;

         l_buffer    := NULL;

         FOR i IN 1 .. l_col_cnt
         LOOP
            IF i > 1
            THEN
               l_buffer    := g_sep;
            END IF;

            l_columnvalue := EMPTY_CLOB ();

            IF l_desc_tab (i).col_type = 112 --Si la columna es un CLOB
            THEN
               DBMS_SQL.COLUMN_VALUE (l_cursor, i, l_columnvalue);

               DBMS_LOB.append (l_out_csv, l_buffer || '"' || REPLACE (l_columnvalue, '"', '') || '"');
            ELSE
               DBMS_SQL.COLUMN_VALUE (l_cursor, i, l_char_columnvalue);


               l_buffer    := l_buffer || '"' || l_char_columnvalue || '"';

               -- write it to the clob
               DBMS_LOB.writeappend (l_out_csv, LENGTH (l_buffer), l_buffer);
            END IF;
         END LOOP;


         --Salto de linea por cada registro

         l_buffer    := CHR (10);

         -- write it to the new clob
         DBMS_LOB.writeappend (l_out_csv, LENGTH (l_buffer), l_buffer);
      END LOOP;

      DBMS_SQL.close_cursor (l_cursor);
      p_csv       := l_out_csv;

      DBMS_LOB.freetemporary (l_out_csv);
   END generate_csv;

   FUNCTION get_file_content (p_file IN VARCHAR2)
      RETURN BLOB
   AS
      l_blob_content   BLOB;
   BEGIN
      SELECT   blob_content
        INTO   l_blob_content
        FROM   wdx_documents
       WHERE   name = p_file;

      RETURN l_blob_content;
   END get_file_content;

   FUNCTION blob2clob (v_blob_in IN BLOB)
      RETURN CLOB
   IS
      v_clob      CLOB;
      v_varchar   VARCHAR2 (32767);
      v_start     PLS_INTEGER := 1;
      v_buffer    PLS_INTEGER := 32767;
   BEGIN
      DBMS_LOB.createtemporary (v_clob, TRUE);

      FOR i IN 1 .. CEIL (DBMS_LOB.getlength (v_blob_in) / v_buffer)
      LOOP
         --v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start));
         v_varchar   := UTL_I18N.raw_to_char (DBMS_LOB.SUBSTR (v_blob_in, v_buffer, v_start), 'AL32UTF8');

         DBMS_LOB.writeappend (v_clob, LENGTH (v_varchar), v_varchar);
         v_start     := v_start + v_buffer;
      END LOOP;

      RETURN v_clob;
   END blob2clob;

   PROCEDURE del (p_file_name IN VARCHAR2, p_appid IN VARCHAR2)
   AS
      e_del_failed exception;
   BEGIN
      DELETE FROM   wdx_documents
            WHERE   name = del.p_file_name AND appid = del.p_appid;


      IF sql%ROWCOUNT != 1
      THEN
         RAISE e_del_failed;
      END IF;
   EXCEPTION
      WHEN e_del_failed
      THEN
         raise_application_error (-20000, 'No rows were deleted. The delete failed.');
   END del;
END dbax_document;
/
