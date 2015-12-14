--
-- DBAX_FILE_PARSER  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE dbax_file_parser
AS
   TYPE cols_rt
   IS
      RECORD (
         rownr   INTEGER
       , col1    VARCHAR2 (100)
       , col2    VARCHAR2 (100)
       , col3    VARCHAR2 (100)
       , col4    VARCHAR2 (100)
       , col5    VARCHAR2 (100)
       , col6    VARCHAR2 (100)
       , col7    VARCHAR2 (100)
       , col8    VARCHAR2 (100)
       , col9    VARCHAR2 (100)
       , col10   VARCHAR2 (100)
       , col11   VARCHAR2 (100)
       , col12   VARCHAR2 (100)
       , col13   VARCHAR2 (100)
       , col14   VARCHAR2 (100)
       , col15   VARCHAR2 (100)
       , col16   VARCHAR2 (100)
       , col17   VARCHAR2 (100)
       , col18   VARCHAR2 (100)
       , col19   VARCHAR2 (100)
       , col20   VARCHAR2 (100)
      );

   TYPE lines_tt IS TABLE OF cols_rt;


   FUNCTION parse_csv (p_data               IN CLOB
                         , p_delimiter          IN VARCHAR2 DEFAULT ';'
                         , p_string_delimiter   IN VARCHAR2 DEFAULT '"' )
      RETURN lines_tt
      PIPELINED;
END dbax_file_parser;
/


