--
-- WDX_MAP_ROUTES  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_MAP_ROUTES
(
  APPID              VARCHAR2(50 BYTE)          NOT NULL,
  ROUTE_NAME         VARCHAR2(50 BYTE)          NOT NULL,
  PRIORITY           NUMBER(5)                  NOT NULL,
  URL_PATTERN        VARCHAR2(1000 BYTE)        NOT NULL,
  CONTROLLER_METHOD  VARCHAR2(100 BYTE)             NULL,
  VIEW_NAME          VARCHAR2(300 BYTE)             NULL,
  DESCRIPTION        VARCHAR2(4000 BYTE)            NULL,
  ACTIVE             VARCHAR2(1 BYTE)           DEFAULT 'Y'                   NOT NULL,
  CREATED_BY         VARCHAR2(100 BYTE)         DEFAULT -1                    NOT NULL,
  CREATED_DATE       DATE                       DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY        VARCHAR2(100 BYTE)         DEFAULT -1                    NOT NULL,
  MODIFIED_DATE      DATE                       DEFAULT SYSDATE               NOT NULL
);


--
-- WDX_MAP_ROUTES_PK  (Index) 
--
--  Dependencies: 
--   WDX_MAP_ROUTES (Table)
--
CREATE UNIQUE INDEX WDX_MAP_ROUTES_PK ON WDX_MAP_ROUTES
(APPID, ROUTE_NAME);


-- 
-- Non Foreign Key Constraints for Table WDX_MAP_ROUTES 
-- 
ALTER TABLE WDX_MAP_ROUTES ADD (
  CONSTRAINT WDX_MAP_ROUTES_PK
 PRIMARY KEY
 (APPID, ROUTE_NAME));


-- 
-- Foreign Key Constraints for Table WDX_MAP_ROUTES 
-- 
ALTER TABLE WDX_MAP_ROUTES ADD (
  CONSTRAINT WDX_MAP_ROUTES_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


