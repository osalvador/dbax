--
-- WDX_ROLES  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_ROLES
(
  ROLENAME       VARCHAR2(255 CHAR)             NOT NULL,
  APPID          VARCHAR2(50 BYTE)              NOT NULL,
  ROLE_DESCR     VARCHAR2(4000 CHAR)                NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_ROLES IS 'Role: Stores the list of valid roles for all applications.';

COMMENT ON COLUMN WDX_ROLES.ROLENAME IS 'Role Name: The name for a given role, unique within an application.';

COMMENT ON COLUMN WDX_ROLES.ROLE_DESCR IS 'Role Description: Optional notes about the intended purpose and use of the role.';


--
-- WDX_ROLES_PK  (Index) 
--
--  Dependencies: 
--   WDX_ROLES (Table)
--
CREATE UNIQUE INDEX WDX_ROLES_PK ON WDX_ROLES
(ROLENAME, APPID);


-- 
-- Non Foreign Key Constraints for Table WDX_ROLES 
-- 
ALTER TABLE WDX_ROLES ADD (
  CONSTRAINT WDX_ROLES_PK
 PRIMARY KEY
 (ROLENAME, APPID));


-- 
-- Foreign Key Constraints for Table WDX_ROLES 
-- 
ALTER TABLE WDX_ROLES ADD (
  CONSTRAINT WDX_ROLES_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


