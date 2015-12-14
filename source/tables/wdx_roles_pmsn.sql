--
-- WDX_ROLES_PMSN  (Table) 
--
--  Dependencies: 
--   WDX_PERMISSIONS (Table)
--   WDX_ROLES (Table)
--
CREATE TABLE WDX_ROLES_PMSN
(
  ROLENAME       VARCHAR2(255 CHAR)             NOT NULL,
  PMSNAME        VARCHAR2(256 CHAR)             NOT NULL,
  APPID          VARCHAR2(50 BYTE)              NOT NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_ROLES_PMSN IS 'Roles Permission: Map of the permissions that apply to a given role. A role may be given more than one permission.';

COMMENT ON COLUMN WDX_ROLES_PMSN.ROLENAME IS 'Role Name: Foreign key to WDX_ROLES. The role being granted a permission.';

COMMENT ON COLUMN WDX_ROLES_PMSN.PMSNAME IS 'Permission Name: Foreign key to WDX_PERMISSIONS. The permission being granted to a role.';


--
-- WDX_ROLES_PMSN_PK  (Index) 
--
--  Dependencies: 
--   WDX_ROLES_PMSN (Table)
--
CREATE UNIQUE INDEX WDX_ROLES_PMSN_PK ON WDX_ROLES_PMSN
(ROLENAME, PMSNAME, APPID);


-- 
-- Non Foreign Key Constraints for Table WDX_ROLES_PMSN 
-- 
ALTER TABLE WDX_ROLES_PMSN ADD (
  CONSTRAINT WDX_ROLES_PMSN_PK
 PRIMARY KEY
 (ROLENAME, PMSNAME, APPID));


-- 
-- Foreign Key Constraints for Table WDX_ROLES_PMSN 
-- 
ALTER TABLE WDX_ROLES_PMSN ADD (
  CONSTRAINT WDX_ROLES_PMSN_ROLENAME_FK 
 FOREIGN KEY (ROLENAME, APPID) 
 REFERENCES WDX_ROLES (ROLENAME,APPID));

ALTER TABLE WDX_ROLES_PMSN ADD (
  CONSTRAINT WDX_ROLES_PMSN_PMSNAME_FK 
 FOREIGN KEY (PMSNAME, APPID) 
 REFERENCES WDX_PERMISSIONS (PMSNAME,APPID));


