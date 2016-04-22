--
-- TAPI_WDX_ROLES_PMSN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      tapi_wdx_roles_pmsn IS

   /**
   -- # TAPI_wdx_roles_pmsn
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 23-NOV-2015 12:03
   -- Created By: DBAX
   */


   --GLOBAL_PRIVATE_CURSORS
   --By PK
   CURSOR wdx_roles_pmsn_cur (
                       p_rolename IN wdx_roles_pmsn.rolename%TYPE,
                       p_pmsname IN wdx_roles_pmsn.pmsname%TYPE,
                       p_appid IN wdx_roles_pmsn.appid%TYPE
                       )
   IS
      SELECT
            rolename,
            pmsname,
            appid,
            created_by,
            created_date,
            modified_by,
            modified_date,
            tapi_wdx_roles_pmsn.hash(rolename,pmsname,appid),
            ROWID
      FROM wdx_roles_pmsn
      WHERE
           rolename = wdx_roles_pmsn_cur.p_rolename AND 
           pmsname = wdx_roles_pmsn_cur.p_pmsname AND 
           appid = wdx_roles_pmsn_cur.p_appid
      FOR UPDATE;

    --By Rowid
    CURSOR wdx_roles_pmsn_rowid_cur (p_rowid IN VARCHAR2)
    IS
      SELECT
             rolename,
             pmsname,
             appid,
             created_by,
             created_date,
             modified_by,
             modified_date,
             tapi_wdx_roles_pmsn.hash(rolename,pmsname,appid),
             ROWID
      FROM wdx_roles_pmsn
      WHERE ROWID = p_rowid
      FOR UPDATE;


    FUNCTION hash (
                  p_rolename IN wdx_roles_pmsn.rolename%TYPE,
                  p_pmsname IN wdx_roles_pmsn.pmsname%TYPE,
                  p_appid IN wdx_roles_pmsn.appid%TYPE
                  )
      RETURN varchar2
   IS
      l_retval hash_t;
      l_string CLOB;
      l_date_format VARCHAR2(64);
   BEGIN


     --Get actual NLS_DATE_FORMAT
     SELECT   VALUE
       INTO   l_date_format
       FROM   v$nls_parameters
      WHERE   parameter = 'NLS_DATE_FORMAT';

      --Alter session for date columns
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY/MM/DD hh24:mi:ss''';

      SELECT
            rolename||
            pmsname||
            appid||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_roles_pmsn
      WHERE
           rolename = hash.p_rolename AND 
           pmsname = hash.p_pmsname AND 
           appid = hash.p_appid
           ;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';

      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);

      RETURN l_retval;

   END hash;

    FUNCTION hash_rowid (p_rowid IN varchar2)
      RETURN varchar2
   IS
      l_retval hash_t;
      l_string CLOB;
      l_date_format varchar2(64);
   BEGIN

      --Get actual NLS_DATE_FORMAT
      SELECT VALUE INTO l_date_format  FROM v$nls_parameters WHERE parameter ='NLS_DATE_FORMAT';

      --Alter session for date columns
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY/MM/DD hh24:mi:ss''';

      SELECT
            rolename||
            pmsname||
            appid||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_roles_pmsn
      WHERE  ROWID = hash_rowid.p_rowid;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';

      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);

      RETURN l_retval;

   END hash_rowid;

   FUNCTION rt (
               p_rolename IN wdx_roles_pmsn.rolename%TYPE,
               p_pmsname IN wdx_roles_pmsn.pmsname%TYPE,
               p_appid IN wdx_roles_pmsn.appid%TYPE
               )
      RETURN wdx_roles_pmsn_rt RESULT_CACHE
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN

      SELECT a.*,
             tapi_wdx_roles_pmsn.hash(rolename,pmsname,appid),
             rowid
      INTO l_wdx_roles_pmsn_rec
      FROM wdx_roles_pmsn a
      WHERE
           rolename = rt.p_rolename AND 
           pmsname = rt.p_pmsname AND 
           appid = rt.p_appid
           ;


      RETURN l_wdx_roles_pmsn_rec;

   END rt;

   FUNCTION rt_for_update (
                          p_rolename IN wdx_roles_pmsn.rolename%TYPE,
                          p_pmsname IN wdx_roles_pmsn.pmsname%TYPE,
                          p_appid IN wdx_roles_pmsn.appid%TYPE
                          )
      RETURN wdx_roles_pmsn_rt RESULT_CACHE
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN


      SELECT a.*,
             tapi_wdx_roles_pmsn.hash(rolename,pmsname,appid),
             rowid
      INTO l_wdx_roles_pmsn_rec
      FROM wdx_roles_pmsn a
      WHERE
           rolename = rt_for_update.p_rolename AND 
           pmsname = rt_for_update.p_pmsname AND 
           appid = rt_for_update.p_appid
      FOR UPDATE;


      RETURN l_wdx_roles_pmsn_rec;

   END rt_for_update;

    FUNCTION tt (
                p_rolename IN wdx_roles_pmsn.rolename%TYPE DEFAULT NULL,
                p_pmsname IN wdx_roles_pmsn.pmsname%TYPE DEFAULT NULL,
                p_appid IN wdx_roles_pmsn.appid%TYPE DEFAULT NULL
                )
       RETURN wdx_roles_pmsn_tt
       PIPELINED
    IS
       l_wdx_roles_pmsn_rec   wdx_roles_pmsn_rt;
    BEGIN

       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_roles_pmsn a
                   WHERE
                        rolename = NVL(tt.p_rolename,rolename) AND 
                        pmsname = NVL(tt.p_pmsname,pmsname) AND 
                        appid = NVL(tt.p_appid,appid)
                        )
       LOOP
              l_wdx_roles_pmsn_rec.rolename := c1.rolename;
              l_wdx_roles_pmsn_rec.pmsname := c1.pmsname;
              l_wdx_roles_pmsn_rec.appid := c1.appid;
              l_wdx_roles_pmsn_rec.created_by := c1.created_by;
              l_wdx_roles_pmsn_rec.created_date := c1.created_date;
              l_wdx_roles_pmsn_rec.modified_by := c1.modified_by;
              l_wdx_roles_pmsn_rec.modified_date := c1.modified_date;
              l_wdx_roles_pmsn_rec.hash := tapi_wdx_roles_pmsn.hash( c1.rolename, c1.pmsname, c1.appid);
              l_wdx_roles_pmsn_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_roles_pmsn_rec);
       END LOOP;

       RETURN;

    END tt;


    PROCEDURE ins (p_wdx_roles_pmsn_rec IN OUT wdx_roles_pmsn_rt)
    IS
        l_rowtype     wdx_roles_pmsn%ROWTYPE;
        l_user_name   wdx_roles_pmsn.created_by%TYPE := USER;/*dbax_core.g$username or apex_application.g_user*/
        l_date        wdx_roles_pmsn.created_date%TYPE := SYSDATE;

    BEGIN

        p_wdx_roles_pmsn_rec.created_by := l_user_name;
        p_wdx_roles_pmsn_rec.created_date := l_date;
        p_wdx_roles_pmsn_rec.modified_by := l_user_name;
        p_wdx_roles_pmsn_rec.modified_date := l_date;

        l_rowtype.rolename := ins.p_wdx_roles_pmsn_rec.rolename;
        l_rowtype.pmsname := ins.p_wdx_roles_pmsn_rec.pmsname;
        l_rowtype.appid := ins.p_wdx_roles_pmsn_rec.appid;
        l_rowtype.created_by := ins.p_wdx_roles_pmsn_rec.created_by;
        l_rowtype.created_date := ins.p_wdx_roles_pmsn_rec.created_date;
        l_rowtype.modified_by := ins.p_wdx_roles_pmsn_rec.modified_by;
        l_rowtype.modified_date := ins.p_wdx_roles_pmsn_rec.modified_date;

       INSERT INTO wdx_roles_pmsn
         VALUES   l_rowtype;


    END ins;

    PROCEDURE upd (
                  p_wdx_roles_pmsn_rec         IN wdx_roles_pmsn_rt,
                  p_ignore_nulls         IN boolean := FALSE
                  )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_roles_pmsn
             SET rolename = NVL(p_wdx_roles_pmsn_rec.rolename,rolename),
                pmsname = NVL(p_wdx_roles_pmsn_rec.pmsname,pmsname),
                appid = NVL(p_wdx_roles_pmsn_rec.appid,appid),
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE
                rolename = upd.p_wdx_roles_pmsn_rec.rolename AND 
                pmsname = upd.p_wdx_roles_pmsn_rec.pmsname AND 
                appid = upd.p_wdx_roles_pmsn_rec.appid
                ;
       ELSE
          UPDATE   wdx_roles_pmsn
             SET rolename = p_wdx_roles_pmsn_rec.rolename,
                pmsname = p_wdx_roles_pmsn_rec.pmsname,
                appid = p_wdx_roles_pmsn_rec.appid,
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE
                rolename = upd.p_wdx_roles_pmsn_rec.rolename AND 
                pmsname = upd.p_wdx_roles_pmsn_rec.pmsname AND 
                appid = upd.p_wdx_roles_pmsn_rec.appid
                ;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd;


    PROCEDURE upd_rowid (
                         p_wdx_roles_pmsn_rec         IN wdx_roles_pmsn_rt,
                         p_ignore_nulls         IN boolean := FALSE
                        )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_roles_pmsn
             SET rolename = NVL(p_wdx_roles_pmsn_rec.rolename,rolename),
                pmsname = NVL(p_wdx_roles_pmsn_rec.pmsname,pmsname),
                appid = NVL(p_wdx_roles_pmsn_rec.appid,appid),
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_roles_pmsn_rec.row_id;
       ELSE
          UPDATE   wdx_roles_pmsn
             SET rolename = p_wdx_roles_pmsn_rec.rolename,
                pmsname = p_wdx_roles_pmsn_rec.pmsname,
                appid = p_wdx_roles_pmsn_rec.appid,
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_roles_pmsn_rec.row_id;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd_rowid;

   PROCEDURE web_upd (
                  p_wdx_roles_pmsn_rec         IN wdx_roles_pmsn_rt,
                  p_ignore_nulls         IN boolean := FALSE
                )
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN

      OPEN wdx_roles_pmsn_cur(
                             web_upd.p_wdx_roles_pmsn_rec.rolename,
                             web_upd.p_wdx_roles_pmsn_rec.pmsname,
                             web_upd.p_wdx_roles_pmsn_rec.appid
                        );

      FETCH wdx_roles_pmsn_cur INTO l_wdx_roles_pmsn_rec;

      IF wdx_roles_pmsn_cur%NOTFOUND THEN
         CLOSE wdx_roles_pmsn_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_roles_pmsn_rec.hash != l_wdx_roles_pmsn_rec.hash THEN
            CLOSE wdx_roles_pmsn_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN

                UPDATE   wdx_roles_pmsn
                   SET rolename = NVL(p_wdx_roles_pmsn_rec.rolename,rolename),
                       pmsname = NVL(p_wdx_roles_pmsn_rec.pmsname,pmsname),
                       appid = NVL(p_wdx_roles_pmsn_rec.appid,appid),
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_roles_pmsn_cur;
            ELSE
                UPDATE   wdx_roles_pmsn
                   SET rolename = p_wdx_roles_pmsn_rec.rolename,
                       pmsname = p_wdx_roles_pmsn_rec.pmsname,
                       appid = p_wdx_roles_pmsn_rec.appid,
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_roles_pmsn_cur;
            END IF;

            CLOSE wdx_roles_pmsn_cur;
         END IF;
      END IF;


   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Update operation failed because the row is no longer in the database.');
   END web_upd;

   PROCEDURE web_upd_rowid (
                            p_wdx_roles_pmsn_rec    IN wdx_roles_pmsn_rt,
                            p_ignore_nulls         IN boolean := FALSE
                           )
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN

      OPEN wdx_roles_pmsn_rowid_cur(web_upd_rowid.p_wdx_roles_pmsn_rec.row_id);

      FETCH wdx_roles_pmsn_rowid_cur INTO l_wdx_roles_pmsn_rec;

      IF wdx_roles_pmsn_rowid_cur%NOTFOUND THEN
         CLOSE wdx_roles_pmsn_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_upd_rowid.p_wdx_roles_pmsn_rec.hash != l_wdx_roles_pmsn_rec.hash THEN
            CLOSE wdx_roles_pmsn_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(web_upd_rowid.p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_roles_pmsn
                   SET rolename = NVL(p_wdx_roles_pmsn_rec.rolename,rolename),
                       pmsname = NVL(p_wdx_roles_pmsn_rec.pmsname,pmsname),
                       appid = NVL(p_wdx_roles_pmsn_rec.appid,appid),
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_roles_pmsn_rowid_cur;
            ELSE
                UPDATE   wdx_roles_pmsn
                   SET rolename = p_wdx_roles_pmsn_rec.rolename,
                       pmsname = p_wdx_roles_pmsn_rec.pmsname,
                       appid = p_wdx_roles_pmsn_rec.appid,
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_roles_pmsn_rowid_cur;
            END IF;

            CLOSE wdx_roles_pmsn_rowid_cur;
         END IF;
      END IF;


   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Update operation failed because the row is no longer in the database.');
   END web_upd_rowid;

   PROCEDURE del (
                  p_pmsname IN wdx_roles_pmsn.pmsname%TYPE DEFAULT NULL,
                  p_rolename IN wdx_roles_pmsn.rolename%TYPE,                  
                  p_appid IN wdx_roles_pmsn.appid%TYPE
                )
    IS
    BEGIN
       IF del.p_pmsname IS NOT NULL
       THEN
          DELETE FROM   wdx_roles_pmsn
                WHERE   rolename = del.p_rolename AND
                        pmsname = del.p_pmsname AND 
                        appid = del.p_appid;

          IF sql%ROWCOUNT != 1
          THEN
             RAISE e_del_failed;
          END IF;
       ELSE
          DELETE FROM   wdx_roles_pmsn
                WHERE   rolename = del.p_rolename AND 
                        appid = del.p_appid;
       END IF;
    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were deleted. The delete failed.');
    END del;

    PROCEDURE del_rowid (p_rowid IN varchar2)
    IS
    BEGIN

       DELETE FROM   wdx_roles_pmsn
             WHERE   ROWID = del_rowid.p_rowid;

       IF sql%ROWCOUNT != 1
       THEN
          RAISE e_del_failed;
       END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were deleted. The delete failed.');
    END del_rowid;

    PROCEDURE web_del (
                      p_rolename IN wdx_roles_pmsn.rolename%TYPE,
                      p_pmsname IN wdx_roles_pmsn.pmsname%TYPE,
                      p_appid IN wdx_roles_pmsn.appid%TYPE,
                      p_hash IN varchar2
                      )
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN


      OPEN wdx_roles_pmsn_cur(
                            web_del.p_rolename,
                            web_del.p_pmsname,
                            web_del.p_appid
                            );

      FETCH wdx_roles_pmsn_cur INTO l_wdx_roles_pmsn_rec;

      IF wdx_roles_pmsn_cur%NOTFOUND THEN
         CLOSE wdx_roles_pmsn_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del.p_hash != l_wdx_roles_pmsn_rec.hash THEN
            CLOSE wdx_roles_pmsn_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_roles_pmsn
            WHERE CURRENT OF wdx_roles_pmsn_cur;

            CLOSE wdx_roles_pmsn_cur;
         END IF;
      END IF;



   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Delete operation failed because the row is no longer in the database.');
   END web_del;

   PROCEDURE web_del_rowid (p_rowid IN varchar2, p_hash IN varchar2)
   IS
      l_wdx_roles_pmsn_rec wdx_roles_pmsn_rt;
   BEGIN


      OPEN wdx_roles_pmsn_rowid_cur(web_del_rowid.p_rowid);

      FETCH wdx_roles_pmsn_rowid_cur INTO l_wdx_roles_pmsn_rec;

      IF wdx_roles_pmsn_rowid_cur%NOTFOUND THEN
         CLOSE wdx_roles_pmsn_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del_rowid.p_hash != l_wdx_roles_pmsn_rec.hash THEN
            CLOSE wdx_roles_pmsn_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_roles_pmsn
            WHERE CURRENT OF wdx_roles_pmsn_rowid_cur;

            CLOSE wdx_roles_pmsn_rowid_cur;
         END IF;
      END IF;

   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Delete operation failed because the row is no longer in the database.');
   END web_del_rowid;


   FUNCTION get_xml (p_appid IN wdx_roles_pmsn.appid%TYPE)
      RETURN XMLTYPE
   AS
      l_refcursor   sys_refcursor;
      l_dummy       VARCHAR2 (1);      
   BEGIN
      --If record not exists raise NO_DATA_FOUND
      SELECT   NULL
        INTO   l_dummy
        FROM   wdx_roles_pmsn
       WHERE   appid = UPPER (p_appid) AND ROWNUM = 1;
    
      OPEN l_refcursor FOR
         SELECT   *
           FROM   wdx_roles_pmsn
          WHERE   appid = UPPER (p_appid);

      RETURN xmltype (l_refcursor);
   END get_xml;
   
   FUNCTION get_tt (p_xml IN XMLTYPE)
      RETURN wdx_roles_pmsn_tt
      PIPELINED
   IS
      l_wdx_roles_pmsn_rec   wdx_roles_pmsn_rt;
   BEGIN
      FOR c1 IN (SELECT   xt.*
                   FROM   XMLTABLE ('/ROWSET/ROW'
                                    PASSING get_tt.p_xml
                                    COLUMNS 
                                      "ROLENAME"       VARCHAR2(255) PATH 'ROLENAME',
                                      "PMSNAME"        VARCHAR2(256) PATH   'PMSNAME',
                                      "APPID"          VARCHAR2(50)  PATH   'APPID',                                    
                                      "CREATED_BY"         VARCHAR2(100)  PATH 'CREATED_BY',
                                      "CREATED_DATE"       VARCHAR2(20)   PATH 'CREATED_DATE',
                                      "MODIFIED_BY"        VARCHAR2(100)  PATH 'MODIFIED_BY',
                                      "MODIFIED_DATE"      VARCHAR2(20)   PATH 'MODIFIED_DATE'
                                    ) xt)
      LOOP
          l_wdx_roles_pmsn_rec.rolename := c1.rolename;
          l_wdx_roles_pmsn_rec.pmsname := c1.pmsname;
          l_wdx_roles_pmsn_rec.appid := c1.appid;
          l_wdx_roles_pmsn_rec.created_by := c1.created_by;
          l_wdx_roles_pmsn_rec.created_date := c1.created_date;
          l_wdx_roles_pmsn_rec.modified_by := c1.modified_by;
          l_wdx_roles_pmsn_rec.modified_date := c1.modified_date;
          PIPE ROW (l_wdx_roles_pmsn_rec);
      END LOOP;

      RETURN;
   END get_tt;

END tapi_wdx_roles_pmsn;
/


