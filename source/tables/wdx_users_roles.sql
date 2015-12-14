--
-- WDX_USERS_ROLES  (Table) 
--
--  Dependencies: 
--   WDX_ROLES (Table)
--   WDX_USERS (Table)
--
CREATE TABLE WDX_USERS_ROLES
(
  USERNAME       VARCHAR2(255 BYTE)             NOT NULL,
  ROLENAME       VARCHAR2(255 CHAR)             NOT NULL,
  APPID          VARCHAR2(50 BYTE)              NOT NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_USERS_ROLES IS 'Users Role : Map of roles granted to users. Users may be granted one or more roles.';

COMMENT ON COLUMN WDX_USERS_ROLES.USERNAME IS 'User Name: Foreign key to WDX_USERS. The user being granted a role.';

COMMENT ON COLUMN WDX_USERS_ROLES.ROLENAME IS 'Role Name: Foreign key to WDX_ROLES. The role being assigned to a user.';


--
-- WDX_USERS_ROLES_PK  (Index) 
--
--  Dependencies: 
--   WDX_USERS_ROLES (Table)
--
CREATE UNIQUE INDEX WDX_USERS_ROLES_PK ON WDX_USERS_ROLES
(USERNAME, ROLENAME, APPID);


-- 
-- Non Foreign Key Constraints for Table WDX_USERS_ROLES 
-- 
ALTER TABLE WDX_USERS_ROLES ADD (
  CONSTRAINT WDX_USERS_ROLES_PK
 PRIMARY KEY
 (USERNAME, ROLENAME, APPID));


-- 
-- Foreign Key Constraints for Table WDX_USERS_ROLES 
-- 
ALTER TABLE WDX_USERS_ROLES ADD (
  CONSTRAINT WDX_USERS_ROLES_USERNAME_FK 
 FOREIGN KEY (USERNAME) 
 REFERENCES WDX_USERS (USERNAME));

ALTER TABLE WDX_USERS_ROLES ADD (
  CONSTRAINT WDX_USERS_ROLES_ROLENAME_FK 
 FOREIGN KEY (ROLENAME, APPID) 
 REFERENCES WDX_ROLES (ROLENAME,APPID));


