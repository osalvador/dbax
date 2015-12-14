--
-- WDX_REQUEST_VALID_FUNCTION  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_REQUEST_VALID_FUNCTION
(
  APPID           VARCHAR2(50 BYTE)             NOT NULL,
  PROCEDURE_NAME  VARCHAR2(255 CHAR)            NOT NULL,
  CREATED_BY      VARCHAR2(100 BYTE)            DEFAULT -1                    NOT NULL,
  CREATED_DATE    DATE                          DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY     VARCHAR2(100 BYTE)            DEFAULT -1                    NOT NULL,
  MODIFIED_DATE   DATE                          DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_REQUEST_VALID_FUNCTION IS 'DAD directive called PlsqlRequestValidationFunction which enables to allow or disallow further processing of a requested procedure';

COMMENT ON COLUMN WDX_REQUEST_VALID_FUNCTION.PROCEDURE_NAME IS 'Procedure Name: will contain the name of the procedure that the request is trying to run.';


--
-- WDX_REQUEST_VALID_FUNCTION_PK  (Index) 
--
--  Dependencies: 
--   WDX_REQUEST_VALID_FUNCTION (Table)
--
CREATE UNIQUE INDEX WDX_REQUEST_VALID_FUNCTION_PK ON WDX_REQUEST_VALID_FUNCTION
(APPID, PROCEDURE_NAME);


-- 
-- Non Foreign Key Constraints for Table WDX_REQUEST_VALID_FUNCTION 
-- 
ALTER TABLE WDX_REQUEST_VALID_FUNCTION ADD (
  CONSTRAINT WDX_REQUEST_VALID_FUNCTION_PK
 PRIMARY KEY
 (APPID, PROCEDURE_NAME));


-- 
-- Foreign Key Constraints for Table WDX_REQUEST_VALID_FUNCTION 
-- 
ALTER TABLE WDX_REQUEST_VALID_FUNCTION ADD (
  CONSTRAINT WDX_RVF_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


