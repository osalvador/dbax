--
-- TE_TEMPLATES  (Table) 
--
CREATE TABLE TE_TEMPLATES
(
  NAME           VARCHAR2(300 BYTE)                 NULL,
  TEMPLATE       CLOB                               NULL,
  DESCRIPTION    VARCHAR2(300 BYTE)                 NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT user                  NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT user                  NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);


--
-- TE_TEMPLATES_PK  (Index) 
--
--  Dependencies: 
--   TE_TEMPLATES (Table)
--
CREATE UNIQUE INDEX TE_TEMPLATES_PK ON TE_TEMPLATES
(NAME);


-- 
-- Non Foreign Key Constraints for Table TE_TEMPLATES 
-- 
ALTER TABLE TE_TEMPLATES ADD (
  CONSTRAINT TE_TEMPLATES_PK
 PRIMARY KEY
 (NAME));


