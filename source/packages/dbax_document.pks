--
-- DBAX_DOCUMENT  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   JSON (Type)
--
CREATE OR REPLACE PACKAGE dbax_document
AS
   FUNCTION upload (p_file_name IN VARCHAR2, p_appid IN VARCHAR2, p_username IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;


   PROCEDURE set_document (p_file IN BLOB, p_name IN VARCHAR2 DEFAULT NULL );


   PROCEDURE download (p_file_name IN VARCHAR2, p_appid IN VARCHAR2);

   PROCEDURE download (p_file IN BLOB);

   PROCEDURE download_xlsx (p_query IN VARCHAR2, p_filename IN VARCHAR2 DEFAULT NULL , p_bindvar IN json DEFAULT NULL );


   PROCEDURE download_csv (p_query IN VARCHAR2, p_filename IN VARCHAR2 DEFAULT NULL , p_bindvar IN json DEFAULT NULL );

   PROCEDURE generate_csv (p_query       IN     VARCHAR2
                         , p_separator   IN     VARCHAR2 DEFAULT ','
                         , p_csv            OUT CLOB
                         , p_bindvar     IN     json DEFAULT NULL );

   FUNCTION get_file_content (p_file IN VARCHAR2)
      RETURN BLOB;

   FUNCTION blob2clob (v_blob_in IN BLOB)
      RETURN CLOB;

   procedure del (p_file_name IN VARCHAR2, p_appid IN VARCHAR2);

--FUNCTION clob2blob (p_clob IN CLOB)
--   RETURN BLOB;
END dbax_document;
/


