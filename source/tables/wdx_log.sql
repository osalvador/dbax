--
-- WDX_LOG  (Table) 
--
CREATE TABLE WDX_LOG
(
  ID            NUMBER(30)                      NOT NULL,
  APPID         VARCHAR2(50 BYTE)               NOT NULL,
  DBAX_SESSION  VARCHAR2(50 BYTE)                   NULL,
  CREATED_DATE  TIMESTAMP(6)                    DEFAULT SYSTIMESTAMP              NULL,
  LOG_USER      VARCHAR2(30 BYTE)                   NULL,
  LOG_LEVEL     VARCHAR2(10 BYTE)                   NULL,
  LOG_TEXT      CLOB                                NULL
);

COMMENT ON TABLE WDX_LOG IS 'Log table for DBAX';


--
-- WDX_LOG_I1  (Index) 
--
--  Dependencies: 
--   WDX_LOG (Table)
--
CREATE INDEX WDX_LOG_I1 ON WDX_LOG
(DBAX_SESSION, CREATED_DATE);


--
-- WDX_LOG_PK  (Index) 
--
--  Dependencies: 
--   WDX_LOG (Table)
--
CREATE UNIQUE INDEX WDX_LOG_PK ON WDX_LOG
(ID);


--
-- WDX_LOG_TEXT_IDX  (Index) 
--
--  Dependencies: 
--   WDX_LOG (Table)
--
--CREATE INDEX WDX_LOG_TEXT_IDX ON WDX_LOG
--(LOG_TEXT)
--INDEXTYPE IS CTXSYS.CONTEXT;


-- 
-- Non Foreign Key Constraints for Table WDX_LOG 
-- 
ALTER TABLE WDX_LOG ADD (
  CONSTRAINT WDX_LOG_PK
 PRIMARY KEY
 (ID));


