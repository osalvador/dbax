--
-- TAPI_WDX_PERMISSIONS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      tapi_wdx_permissions IS

   /**
   -- # TAPI_wdx_permissions
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 23-NOV-2015 12:03
   -- Created By: DBAX
   */


   --GLOBAL_PRIVATE_CURSORS
   --By PK
   CURSOR wdx_permissions_cur (
                       p_pmsname IN wdx_permissions.pmsname%TYPE,
                       p_appid IN wdx_permissions.appid%TYPE
                       )
   IS
      SELECT
            pmsname,
            appid,
            pmsn_descr,
            created_by,
            created_date,
            modified_by,
            modified_date,
            tapi_wdx_permissions.hash(pmsname,appid),
            ROWID
      FROM wdx_permissions
      WHERE
           pmsname = wdx_permissions_cur.p_pmsname AND 
           appid = wdx_permissions_cur.p_appid
      FOR UPDATE;

    --By Rowid
    CURSOR wdx_permissions_rowid_cur (p_rowid IN VARCHAR2)
    IS
      SELECT
             pmsname,
             appid,
             pmsn_descr,
             created_by,
             created_date,
             modified_by,
             modified_date,
             tapi_wdx_permissions.hash(pmsname,appid),
             ROWID
      FROM wdx_permissions
      WHERE ROWID = p_rowid
      FOR UPDATE;


    FUNCTION hash (
                  p_pmsname IN wdx_permissions.pmsname%TYPE,
                  p_appid IN wdx_permissions.appid%TYPE
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
            pmsname||
            appid||
            pmsn_descr||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_permissions
      WHERE
           pmsname = UPPER(hash.p_pmsname) AND 
           appid = UPPER(hash.p_appid)
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
            pmsname||
            appid||
            pmsn_descr||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_permissions
      WHERE  ROWID = hash_rowid.p_rowid;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';

      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);

      RETURN l_retval;

   END hash_rowid;

   FUNCTION rt (
               p_pmsname IN wdx_permissions.pmsname%TYPE,
               p_appid IN wdx_permissions.appid%TYPE
               )
      RETURN wdx_permissions_rt RESULT_CACHE
   IS
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN

      SELECT a.*,
             tapi_wdx_permissions.hash(pmsname,appid),
             rowid
      INTO l_wdx_permissions_rec
      FROM wdx_permissions a
      WHERE
           pmsname = UPPER(rt.p_pmsname) AND 
           appid = UPPER(rt.p_appid)
           ;


      RETURN l_wdx_permissions_rec;

   END rt;

   FUNCTION rt_for_update (
                          p_pmsname IN wdx_permissions.pmsname%TYPE,
                          p_appid IN wdx_permissions.appid%TYPE
                          )
      RETURN wdx_permissions_rt RESULT_CACHE
   IS
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN


      SELECT a.*,
             tapi_wdx_permissions.hash(pmsname,appid),
             rowid
      INTO l_wdx_permissions_rec
      FROM wdx_permissions a
      WHERE
           pmsname = UPPER(rt_for_update.p_pmsname) AND 
           appid = UPPER(rt_for_update.p_appid)
      FOR UPDATE;


      RETURN l_wdx_permissions_rec;

   END rt_for_update;

    FUNCTION tt (
                p_pmsname IN wdx_permissions.pmsname%TYPE DEFAULT NULL,
                p_appid IN wdx_permissions.appid%TYPE DEFAULT NULL
                )
       RETURN wdx_permissions_tt
       PIPELINED
    IS
       l_wdx_permissions_rec   wdx_permissions_rt;
    BEGIN

       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_permissions a
                   WHERE
                        pmsname = NVL(UPPER(tt.p_pmsname),pmsname) AND 
                        appid = NVL(UPPER(tt.p_appid),appid)
                        )
       LOOP
              l_wdx_permissions_rec.pmsname := c1.pmsname;
              l_wdx_permissions_rec.appid := c1.appid;
              l_wdx_permissions_rec.pmsn_descr := c1.pmsn_descr;
              l_wdx_permissions_rec.created_by := c1.created_by;
              l_wdx_permissions_rec.created_date := c1.created_date;
              l_wdx_permissions_rec.modified_by := c1.modified_by;
              l_wdx_permissions_rec.modified_date := c1.modified_date;
              l_wdx_permissions_rec.hash := tapi_wdx_permissions.hash( c1.pmsname, c1.appid);
              l_wdx_permissions_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_permissions_rec);
       END LOOP;

       RETURN;

    END tt;


    PROCEDURE ins (p_wdx_permissions_rec IN OUT wdx_permissions_rt)
    IS
        l_rowtype     wdx_permissions%ROWTYPE;
        l_user_name   wdx_permissions.created_by%TYPE := USER;/*dbax_core.g$username or apex_application.g_user*/
        l_date        wdx_permissions.created_date%TYPE := SYSDATE;

    BEGIN

        p_wdx_permissions_rec.created_by := l_user_name;
        p_wdx_permissions_rec.created_date := l_date;
        p_wdx_permissions_rec.modified_by := l_user_name;
        p_wdx_permissions_rec.modified_date := l_date;

        l_rowtype.pmsname := UPPER(ins.p_wdx_permissions_rec.pmsname);
        l_rowtype.appid := UPPER(ins.p_wdx_permissions_rec.appid);
        l_rowtype.pmsn_descr := ins.p_wdx_permissions_rec.pmsn_descr;
        l_rowtype.created_by := ins.p_wdx_permissions_rec.created_by;
        l_rowtype.created_date := ins.p_wdx_permissions_rec.created_date;
        l_rowtype.modified_by := ins.p_wdx_permissions_rec.modified_by;
        l_rowtype.modified_date := ins.p_wdx_permissions_rec.modified_date;

       INSERT INTO wdx_permissions
         VALUES   l_rowtype;


    END ins;

    PROCEDURE upd (
                  p_wdx_permissions_rec         IN wdx_permissions_rt,
                  p_ignore_nulls         IN boolean := FALSE
                  )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_permissions
             SET pmsname = NVL(UPPER(p_wdx_permissions_rec.pmsname),pmsname),
                appid = NVL(UPPER(p_wdx_permissions_rec.appid),appid),
                pmsn_descr = NVL(p_wdx_permissions_rec.pmsn_descr,pmsn_descr),
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE
                pmsname = UPPER(upd.p_wdx_permissions_rec.pmsname) AND 
                appid = UPPER(upd.p_wdx_permissions_rec.appid)
                ;
       ELSE
          UPDATE   wdx_permissions
             SET pmsname = UPPER(p_wdx_permissions_rec.pmsname),
                appid = UPPER(p_wdx_permissions_rec.appid),
                pmsn_descr = p_wdx_permissions_rec.pmsn_descr,
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE
                pmsname = UPPER(upd.p_wdx_permissions_rec.pmsname) AND 
                appid = UPPER(upd.p_wdx_permissions_rec.appid)
                ;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd;


    PROCEDURE upd_rowid (
                         p_wdx_permissions_rec         IN wdx_permissions_rt,
                         p_ignore_nulls         IN boolean := FALSE
                        )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_permissions
             SET pmsname = NVL(UPPER(p_wdx_permissions_rec.pmsname),pmsname),
                appid = NVL(UPPER(p_wdx_permissions_rec.appid),appid),
                pmsn_descr = NVL(p_wdx_permissions_rec.pmsn_descr,pmsn_descr),
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_permissions_rec.row_id;
       ELSE
          UPDATE   wdx_permissions
             SET pmsname = UPPER(p_wdx_permissions_rec.pmsname),
                appid = UPPER(p_wdx_permissions_rec.appid),
                pmsn_descr = p_wdx_permissions_rec.pmsn_descr,
                modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_permissions_rec.row_id;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd_rowid;

   PROCEDURE web_upd (
                  p_wdx_permissions_rec         IN wdx_permissions_rt,
                  p_ignore_nulls         IN boolean := FALSE
                )
   IS
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN

      OPEN wdx_permissions_cur(
                             UPPER(web_upd.p_wdx_permissions_rec.pmsname),
                             UPPER(web_upd.p_wdx_permissions_rec.appid)
                        );

      FETCH wdx_permissions_cur INTO l_wdx_permissions_rec;

      IF wdx_permissions_cur%NOTFOUND THEN
         CLOSE wdx_permissions_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_permissions_rec.hash != l_wdx_permissions_rec.hash THEN
            CLOSE wdx_permissions_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN

                UPDATE   wdx_permissions
                   SET pmsname = NVL(UPPER(p_wdx_permissions_rec.pmsname),pmsname),
                       appid = NVL(UPPER(p_wdx_permissions_rec.appid),appid),
                       pmsn_descr = NVL(p_wdx_permissions_rec.pmsn_descr,pmsn_descr),
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_permissions_cur;
            ELSE
                UPDATE   wdx_permissions
                   SET pmsname = UPPER(p_wdx_permissions_rec.pmsname),
                       appid = UPPER(p_wdx_permissions_rec.appid),
                       pmsn_descr = p_wdx_permissions_rec.pmsn_descr,
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_permissions_cur;
            END IF;

            CLOSE wdx_permissions_cur;
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
                            p_wdx_permissions_rec    IN wdx_permissions_rt,
                            p_ignore_nulls         IN boolean := FALSE
                           )
   IS
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN

      OPEN wdx_permissions_rowid_cur(web_upd_rowid.p_wdx_permissions_rec.row_id);

      FETCH wdx_permissions_rowid_cur INTO l_wdx_permissions_rec;

      IF wdx_permissions_rowid_cur%NOTFOUND THEN
         CLOSE wdx_permissions_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_upd_rowid.p_wdx_permissions_rec.hash != l_wdx_permissions_rec.hash THEN
            CLOSE wdx_permissions_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(web_upd_rowid.p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_permissions
                   SET pmsname = NVL(UPPER(p_wdx_permissions_rec.pmsname),pmsname),
                       appid = NVL(UPPER(p_wdx_permissions_rec.appid),appid),
                       pmsn_descr = NVL(p_wdx_permissions_rec.pmsn_descr,pmsn_descr),
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_permissions_rowid_cur;
            ELSE
                UPDATE   wdx_permissions
                   SET pmsname = UPPER(p_wdx_permissions_rec.pmsname),
                       appid = UPPER(p_wdx_permissions_rec.appid),
                       pmsn_descr = p_wdx_permissions_rec.pmsn_descr,
                       modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_permissions_rowid_cur;
            END IF;

            CLOSE wdx_permissions_rowid_cur;
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
                  p_pmsname IN wdx_permissions.pmsname%TYPE,
                  p_appid IN wdx_permissions.appid%TYPE
                  )
    IS
    BEGIN

       DELETE FROM   wdx_permissions
             WHERE
                  pmsname = UPPER(del.p_pmsname) AND 
                  appid = UPPER(del.p_appid)
                   ;

       IF sql%ROWCOUNT != 1
       THEN
          RAISE e_del_failed;
       END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were deleted. The delete failed.');
    END del;

    PROCEDURE del_rowid (p_rowid IN varchar2)
    IS
    BEGIN

       DELETE FROM   wdx_permissions
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
                      p_pmsname IN wdx_permissions.pmsname%TYPE,
                      p_appid IN wdx_permissions.appid%TYPE,
                      p_hash IN varchar2
                      )
   IS
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN


      OPEN wdx_permissions_cur(
                            UPPER(web_del.p_pmsname),
                            UPPER(web_del.p_appid)
                            );

      FETCH wdx_permissions_cur INTO l_wdx_permissions_rec;

      IF wdx_permissions_cur%NOTFOUND THEN
         CLOSE wdx_permissions_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del.p_hash != l_wdx_permissions_rec.hash THEN
            CLOSE wdx_permissions_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_permissions
            WHERE CURRENT OF wdx_permissions_cur;

            CLOSE wdx_permissions_cur;
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
      l_wdx_permissions_rec wdx_permissions_rt;
   BEGIN


      OPEN wdx_permissions_rowid_cur(web_del_rowid.p_rowid);

      FETCH wdx_permissions_rowid_cur INTO l_wdx_permissions_rec;

      IF wdx_permissions_rowid_cur%NOTFOUND THEN
         CLOSE wdx_permissions_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del_rowid.p_hash != l_wdx_permissions_rec.hash THEN
            CLOSE wdx_permissions_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_permissions
            WHERE CURRENT OF wdx_permissions_rowid_cur;

            CLOSE wdx_permissions_rowid_cur;
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



   FUNCTION pmsn_with_roles_tt (
                p_rolename IN wdx_users_roles.rolename%TYPE,
                p_appid IN wdx_permissions.appid%TYPE
               )
   RETURN wdx_permissions_tt
       PIPELINED
    IS
       l_wdx_permissions_rec   wdx_permissions_rt;
    BEGIN

       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_permissions a
                   WHERE   EXISTS (SELECT   1
                                     FROM   wdx_roles_pmsn b
                                     WHERE  rolename = UPPER(pmsn_with_roles_tt.p_rolename) AND appid = UPPER(pmsn_with_roles_tt.p_appid)
                                     AND    a.pmsname = b.pmsname))
       LOOP
              l_wdx_permissions_rec.pmsname := c1.pmsname;
              l_wdx_permissions_rec.appid := c1.appid;
              l_wdx_permissions_rec.pmsn_descr := c1.pmsn_descr;
              l_wdx_permissions_rec.created_by := c1.created_by;
              l_wdx_permissions_rec.created_date := c1.created_date;
              l_wdx_permissions_rec.modified_by := c1.modified_by;
              l_wdx_permissions_rec.modified_date := c1.modified_date;
              l_wdx_permissions_rec.hash := tapi_wdx_permissions.hash( c1.pmsname, c1.appid);
              l_wdx_permissions_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_permissions_rec);
       END LOOP;

       RETURN;

    END pmsn_with_roles_tt;
   
   FUNCTION pmsn_without_roles_tt(
                p_rolename IN wdx_users_roles.rolename%TYPE,
                p_appid IN wdx_permissions.appid%TYPE
               )
   RETURN wdx_permissions_tt
       PIPELINED
    IS
       l_wdx_permissions_rec   wdx_permissions_rt;
    BEGIN

       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_permissions a
                   WHERE  NOT EXISTS (SELECT   1
                                     FROM   wdx_roles_pmsn b
                                     WHERE  rolename = UPPER(pmsn_without_roles_tt.p_rolename) AND appid = UPPER(pmsn_without_roles_tt.p_appid)
                                     AND    a.pmsname = b.pmsname)
                          AND a.appid = pmsn_without_roles_tt.p_appid)
       LOOP
              l_wdx_permissions_rec.pmsname := c1.pmsname;
              l_wdx_permissions_rec.appid := c1.appid;
              l_wdx_permissions_rec.pmsn_descr := c1.pmsn_descr;
              l_wdx_permissions_rec.created_by := c1.created_by;
              l_wdx_permissions_rec.created_date := c1.created_date;
              l_wdx_permissions_rec.modified_by := c1.modified_by;
              l_wdx_permissions_rec.modified_date := c1.modified_date;
              l_wdx_permissions_rec.hash := tapi_wdx_permissions.hash( c1.pmsname, c1.appid);
              l_wdx_permissions_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_permissions_rec);
       END LOOP;

       RETURN;

    END pmsn_without_roles_tt;


END tapi_wdx_permissions;
/

