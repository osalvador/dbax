--
-- WDX_APPLICATIONS  (Table) 
--
CREATE TABLE WDX_APPLICATIONS
(
  APPID           VARCHAR2(50 BYTE)                 NULL,
  NAME            VARCHAR2(50 BYTE)                 NULL,
  DESCRIPTION     VARCHAR2(300 BYTE)                NULL,
  ACTIVE          VARCHAR2(1 BYTE)              DEFAULT 'Y'                   NOT NULL,
  ACCESS_CONTROL  VARCHAR2(50 BYTE)             DEFAULT 'PUBLIC'              NOT NULL,
  AUTH_SCHEME     VARCHAR2(255 BYTE)                NULL,
  CREATED_BY      VARCHAR2(100 BYTE)            DEFAULT -1                    NOT NULL,
  CREATED_DATE    DATE                          DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY     VARCHAR2(100 BYTE)            DEFAULT -1                    NOT NULL,
  MODIFIED_DATE   DATE                          DEFAULT SYSDATE               NOT NULL
);


--
-- WDX_APPLICATIONS_PK  (Index) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE UNIQUE INDEX WDX_APPLICATIONS_PK ON WDX_APPLICATIONS
(APPID);


-- 
-- Non Foreign Key Constraints for Table WDX_APPLICATIONS 
-- 
ALTER TABLE WDX_APPLICATIONS ADD (
  CONSTRAINT WDX_APPLICATIONS_PK
 PRIMARY KEY
 (APPID));


