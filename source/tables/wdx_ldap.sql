--
-- WDX_LDAP  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_LDAP
(
  APPID            VARCHAR2(50 BYTE)            NOT NULL,
  LDAP_NAME        VARCHAR2(255 BYTE)           NOT NULL,
  HOST             VARCHAR2(2000 BYTE)          NOT NULL,
  PORT             NUMBER                       NOT NULL,
  DN               VARCHAR2(2000 BYTE)          NOT NULL,
  BASE             VARCHAR2(2000 BYTE)              NULL,
  FILTER           VARCHAR2(2000 BYTE)              NULL,
  ATTR_FIRST_NAME  VARCHAR2(2000 BYTE)              NULL,
  ATTR_LAST_NAME   VARCHAR2(2000 BYTE)              NULL,
  ATTR_EMAIL       VARCHAR2(2000 BYTE)              NULL,
  CREATED_BY       VARCHAR2(100 BYTE)           DEFAULT -1                    NOT NULL,
  CREATED_DATE     DATE                         DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY      VARCHAR2(100 BYTE)           DEFAULT -1                    NOT NULL,
  MODIFIED_DATE    DATE                         DEFAULT SYSDATE               NOT NULL
);


--
-- WDX_LDAP_PK  (Index) 
--
--  Dependencies: 
--   WDX_LDAP (Table)
--
CREATE UNIQUE INDEX WDX_LDAP_PK ON WDX_LDAP
(APPID, LDAP_NAME);


-- 
-- Non Foreign Key Constraints for Table WDX_LDAP 
-- 
ALTER TABLE WDX_LDAP ADD (
  CONSTRAINT WDX_LDAP_PK
 PRIMARY KEY
 (APPID, LDAP_NAME));


-- 
-- Foreign Key Constraints for Table WDX_LDAP 
-- 
ALTER TABLE WDX_LDAP ADD (
  CONSTRAINT WDX_LDAP_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


