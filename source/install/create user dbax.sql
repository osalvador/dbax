CREATE TABLESPACE TS_DBAX DATAFILE 'dbax.dat' size 10M autoextend on;

CREATE TEMPORARY TABLESPACE TS_DBAX_TEMP tempfile 'dbax_temp.dat' size 5M autoextend on;

CREATE USER dbax IDENTIFIED BY password DEFAULT TABLESPACE TS_DBAX
   TEMPORARY TABLESPACE TS_DBAX_TEMP ACCOUNT UNLOCK  PROFILE DEFAULT;

  GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE,
  CREATE SEQUENCE TO dbax;

  GRANT Execute on DBMS_CRYPTO to dbax;

  GRANT CREATE TYPE TO dbax;

  grant create public synonym, drop public synonym to dbax;


  ALTER USER dbax QUOTA UNLIMITED ON TS_DBAX;

  ALTER USER dbax account unlock;