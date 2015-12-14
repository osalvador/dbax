--
-- WDX_PERMISSIONS  (Table) 
--
--  Dependencies: 
--   WDX_APPLICATIONS (Table)
--
CREATE TABLE WDX_PERMISSIONS
(
  PMSNAME        VARCHAR2(256 CHAR)             NOT NULL,
  APPID          VARCHAR2(50 BYTE)              NOT NULL,
  PMSN_DESCR     VARCHAR2(200 CHAR)                 NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_PERMISSIONS IS 'Permission (SP): List of permissions to actions or objects that can be assigned to roles.';

COMMENT ON COLUMN WDX_PERMISSIONS.PMSNAME IS 'Permission Name: A permission is simply a string that controls authorization to do things within an application. The string can be the name of a page, object, component, control, action on said items, or a combination. The application protects access to code paths and application resources using this permission string. So it is not important what goes in the permission name, ony that the application layers agree on its value and format.';

COMMENT ON COLUMN WDX_PERMISSIONS.APPID IS 'Application ID: Foreign key to WDX_APPLICATIONS. The application to which the permission applies.';

COMMENT ON COLUMN WDX_PERMISSIONS.PMSN_DESCR IS 'Permission Description: Optional notes about the intended purpose of the permission.';


--
-- WDX_PERMISSIONS_PK  (Index) 
--
--  Dependencies: 
--   WDX_PERMISSIONS (Table)
--
CREATE UNIQUE INDEX WDX_PERMISSIONS_PK ON WDX_PERMISSIONS
(PMSNAME, APPID);


-- 
-- Non Foreign Key Constraints for Table WDX_PERMISSIONS 
-- 
ALTER TABLE WDX_PERMISSIONS ADD (
  CONSTRAINT WDX_PERMISSIONS_PK
 PRIMARY KEY
 (PMSNAME, APPID));


-- 
-- Foreign Key Constraints for Table WDX_PERMISSIONS 
-- 
ALTER TABLE WDX_PERMISSIONS ADD (
  CONSTRAINT WDX_PERMISSIONS_APPID_FK 
 FOREIGN KEY (APPID) 
 REFERENCES WDX_APPLICATIONS (APPID));


