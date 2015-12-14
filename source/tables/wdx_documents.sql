--
-- WDX_DOCUMENTS  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_DOCUMENTS
(
  APPID         VARCHAR2(50 BYTE)                   NULL,
  USERNAME      VARCHAR2(255 BYTE)                  NULL,
  NAME          VARCHAR2(256 BYTE)              NOT NULL,
  MIME_TYPE     VARCHAR2(128 BYTE)                  NULL,
  DOC_SIZE      NUMBER                              NULL,
  DAD_CHARSET   VARCHAR2(128 BYTE)                  NULL,
  LAST_UPDATED  DATE                                NULL,
  CONTENT_TYPE  VARCHAR2(128 BYTE)                  NULL,
  BLOB_CONTENT  BLOB                                NULL
);


-- 
-- Non Foreign Key Constraints for Table WDX_DOCUMENTS 
-- 
ALTER TABLE WDX_DOCUMENTS ADD (
  UNIQUE (APPID, NAME));


-- 
-- Foreign Key Constraints for Table WDX_DOCUMENTS 
-- 
ALTER TABLE WDX_DOCUMENTS ADD (
  CONSTRAINT WDX_DOCUMENTS_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


