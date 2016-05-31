CREATE TABLE WDX_LDAP
(
  NAME             VARCHAR2(255 BYTE)           NOT NULL,
  HOST             VARCHAR2(2000 BYTE)          NOT NULL,
  PORT             NUMBER                       NOT NULL,
  DN               VARCHAR2(2000 BYTE)          NOT NULL,
  BASE             VARCHAR2(2000 BYTE)              NULL,
  FILTER           VARCHAR2(2000 BYTE)              NULL,
  ATTR_FIRST_NAME  VARCHAR2(2000 BYTE)              NULL,
  ATTR_LAST_NAME   VARCHAR2(2000 BYTE)              NULL,
  ATTR_EMAIL       VARCHAR2(2000 BYTE)              NULL,
  DESCRIPTION      VARCHAR2(300 BYTE)               NULL,
  CREATED_BY       VARCHAR2(100 BYTE)           DEFAULT -1                    NOT NULL,
  CREATED_DATE     DATE                         DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY      VARCHAR2(100 BYTE)           DEFAULT -1                    NOT NULL,
  MODIFIED_DATE    DATE                         DEFAULT SYSDATE               NOT NULL
);


CREATE UNIQUE INDEX WDX_LDAP_PK ON WDX_LDAP
(NAME);


ALTER TABLE WDX_LDAP ADD (
  CONSTRAINT WDX_LDAP_PK
 PRIMARY KEY
 (NAME));

