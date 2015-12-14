--
-- WDX_USERS  (Table) 
--
CREATE TABLE WDX_USERS
(
  USERNAME       VARCHAR2(255 CHAR)             NOT NULL,
  PASSWORD       VARCHAR2(1024 CHAR)                NULL,
  FIRST_NAME     VARCHAR2(128 CHAR)             NOT NULL,
  LAST_NAME      VARCHAR2(128 CHAR)                 NULL,
  DISPLAY_NAME   VARCHAR2(128 CHAR)                 NULL,
  EMAIL          VARCHAR2(80 CHAR)                  NULL,
  STATUS         NUMBER(11)                         NULL,
  CREATED_BY     VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  CREATED_DATE   DATE                           DEFAULT SYSDATE               NOT NULL,
  MODIFIED_BY    VARCHAR2(100 BYTE)             DEFAULT -1                    NOT NULL,
  MODIFIED_DATE  DATE                           DEFAULT SYSDATE               NOT NULL
);

COMMENT ON TABLE WDX_USERS IS 'WDX_USERS: DBAX Users table, their identifiers and primary contact methods.';

COMMENT ON COLUMN WDX_USERS.USERNAME IS 'User Name: The user name, often called the User ID, which the user enters in a login page to identify themselves.';

COMMENT ON COLUMN WDX_USERS.PASSWORD IS 'User Password: The encrypted password for the user.';

COMMENT ON COLUMN WDX_USERS.FIRST_NAME IS 'First Name: First name of the user.';

COMMENT ON COLUMN WDX_USERS.LAST_NAME IS 'Last Name: Last name of the user.';

COMMENT ON COLUMN WDX_USERS.DISPLAY_NAME IS 'Display Name: The displayed user''s nickname or preferred name.';

COMMENT ON COLUMN WDX_USERS.EMAIL IS 'Email Address: The email address to use when contacting the user.';

COMMENT ON COLUMN WDX_USERS.STATUS IS 'Status: The status of the user.';


--
-- WDX_USERS_EMAIL_UK  (Index) 
--
--  Dependencies: 
--   WDX_USERS (Table)
--
CREATE UNIQUE INDEX WDX_USERS_EMAIL_UK ON WDX_USERS
(EMAIL);


--
-- WDX_USERS_PK  (Index) 
--
--  Dependencies: 
--   WDX_USERS (Table)
--
CREATE UNIQUE INDEX WDX_USERS_PK ON WDX_USERS
(USERNAME);


-- 
-- Non Foreign Key Constraints for Table WDX_USERS 
-- 
ALTER TABLE WDX_USERS ADD (
  CONSTRAINT WDX_USERS_PK
 PRIMARY KEY
 (USERNAME));


