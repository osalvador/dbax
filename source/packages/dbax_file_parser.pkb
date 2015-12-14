--
-- DBAX_FILE_PARSER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dbax_file_parser


AS
   FUNCTION parse_csv (p_data               IN CLOB
                     , p_delimiter          IN VARCHAR2 DEFAULT ';'
                     , p_string_delimiter   IN VARCHAR2 DEFAULT '"' )
      RETURN lines_tt
      PIPELINED
   IS
      l_row       cols_rt;
      l_buffer    VARCHAR2 (32767);
      l_eol       VARCHAR2 (2) := CHR (10);
      l_rownr     NUMBER := 1;
      l_offset    NUMBER := 1;

      l_rec_len   NUMBER;
      l_pos1      NUMBER := 0;
      l_pos2      NUMBER := 0;
      l_crpos1    NUMBER := 0;
      l_crpos2    NUMBER;
      l_data      CLOB;

      FUNCTION lf_getcol
         RETURN VARCHAR2
      IS
      BEGIN
         l_pos1      := l_pos2;
         l_pos2      := COALESCE (NULLIF (INSTR (l_buffer, p_delimiter, l_pos1 + 1), 0), LENGTH (l_buffer) + 1);

         RETURN (SUBSTR (l_buffer, l_pos1 + 1, l_pos2 - l_pos1 - 1));
      END;
   BEGIN
      --dos2unix
      l_data      :=
         REGEXP_REPLACE (p_data
                       , CHR (13) || CHR (10)
                       , CHR (10)
                       , 1
                       , 0
                       , 'nm');
      
      --Delete string delimiter, but persist delimiter inside data
      l_data      :=
         REGEXP_REPLACE (l_data
                       ,    '^'
                         || p_string_delimiter
                         || '|'
                         || p_string_delimiter
                         || '(;)'
                         || p_string_delimiter
                         || '|'
                         || p_string_delimiter
                         || '$'
                       , '\1'
                       , 1
                       , 0
                       , 'nm');

        l_data := l_data || CHR(10);

      LOOP
         l_crpos2    := DBMS_LOB.INSTR (l_data, l_eol, l_crpos1 + 1);
         l_buffer    := DBMS_LOB.SUBSTR (l_data, l_crpos2 - l_crpos1 - 1, l_crpos1 + 1);
         EXIT WHEN l_buffer IS NULL;

         l_row.rownr := l_rownr;

         l_pos1      := 0;

         l_pos2      := 0;

         l_row.col1  := lf_getcol;
         l_row.col2  := lf_getcol;
         l_row.col3  := lf_getcol;
         l_row.col4  := lf_getcol;
         l_row.col5  := lf_getcol;
         l_row.col6  := lf_getcol;
         l_row.col7  := lf_getcol;
         l_row.col8  := lf_getcol;
         l_row.col9  := lf_getcol;
         l_row.col10 := lf_getcol;
         l_row.col11 := lf_getcol;

         l_row.col12 := lf_getcol;
         l_row.col13 := lf_getcol;
         l_row.col14 := lf_getcol;
         l_row.col15 := lf_getcol;
         l_row.col16 := lf_getcol;
         l_row.col17 := lf_getcol;
         l_row.col18 := lf_getcol;
         l_row.col19 := lf_getcol;
         l_row.col20 := lf_getcol;

         PIPE ROW (l_row);

         l_crpos1    := l_crpos2;

         l_rownr     := l_rownr + 1;
      END LOOP;

      RETURN;
   EXCEPTION
      WHEN no_data_needed
      THEN
         NULL;
   END parse_csv;
END dbax_file_parser;
/


