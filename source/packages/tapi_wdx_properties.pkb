--
-- TAPI_WDX_PROPERTIES  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      tapi_wdx_properties IS

   /**
   -- # TAPI_wdx_properties
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 16-SEP-2015 09:49
   -- Created By: DBAX
   */

   --GLOBAL_PRIVATE_CURSORS
   --By PK
   CURSOR wdx_properties_cur (
                       p_appid IN wdx_properties.appid%TYPE,
                       p_key IN wdx_properties.key%TYPE
                       )
   IS
      SELECT
            appid,
            key,
            value,
            description,
            created_by,
            created_date,
            modified_by,
            modified_date,
            tapi_wdx_properties.hash(appid,key),
            ROWID
      FROM wdx_properties
      WHERE
           appid = wdx_properties_cur.p_appid AND 
           key = wdx_properties_cur.p_key
      FOR UPDATE;

    --By Rowid
    CURSOR wdx_properties_rowid_cur (p_rowid IN VARCHAR2)
    IS
      SELECT
             appid,
             key,
             value,
             description,
             created_by,
             created_date,
             modified_by,
             modified_date,
             tapi_wdx_properties.hash(appid,key),
             ROWID
      FROM wdx_properties
      WHERE ROWID = p_rowid
      FOR UPDATE;


    FUNCTION hash (
                  p_appid IN wdx_properties.appid%TYPE,
                  p_key IN wdx_properties.key%TYPE
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
            appid||
            key||
            value||
            description||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_properties
      WHERE
           appid = hash.p_appid AND 
           key = hash.p_key
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
            appid||
            key||
            value||
            description||
            created_by||
            created_date||
            modified_by||
            modified_date
      INTO l_string
      FROM wdx_properties
      WHERE  ROWID = hash_rowid.p_rowid;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';
      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);
      RETURN l_retval;
   END hash_rowid;

   FUNCTION rt (
               p_appid IN wdx_properties.appid%TYPE,
               p_key IN wdx_properties.key%TYPE
               )
      RETURN wdx_properties_rt RESULT_CACHE
   IS
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      SELECT a.*,
             tapi_wdx_properties.hash(appid,key),
             rowid
      INTO l_wdx_properties_rec
      FROM wdx_properties a
      WHERE
           appid = rt.p_appid AND 
           key = LOWER(rt.p_key)
           ;

      RETURN l_wdx_properties_rec;
   END rt;

   FUNCTION rt_for_update (
                          p_appid IN wdx_properties.appid%TYPE,
                          p_key IN wdx_properties.key%TYPE
                          )
      RETURN wdx_properties_rt RESULT_CACHE
   IS
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      SELECT a.*,
             tapi_wdx_properties.hash(appid,key),
             rowid
      INTO l_wdx_properties_rec
      FROM wdx_properties a
      WHERE
           appid = rt_for_update.p_appid AND 
           key = rt_for_update.p_key
      FOR UPDATE;

      RETURN l_wdx_properties_rec;
   END rt_for_update;

    FUNCTION tt (
                p_appid IN wdx_properties.appid%TYPE DEFAULT NULL,
                p_key IN wdx_properties.key%TYPE DEFAULT NULL
                )
       RETURN wdx_properties_tt
       PIPELINED
    IS
       l_wdx_properties_rec   wdx_properties_rt;
    BEGIN

       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_properties a
                   WHERE
                        appid = NVL(tt.p_appid,appid) AND 
                        key = NVL(tt.p_key,key)
                        )
       LOOP
              l_wdx_properties_rec.appid := c1.appid;
              l_wdx_properties_rec.key := c1.key;
              l_wdx_properties_rec.value := c1.value;
              l_wdx_properties_rec.description := c1.description;
              l_wdx_properties_rec.created_by := c1.created_by;
              l_wdx_properties_rec.created_date := c1.created_date;
              l_wdx_properties_rec.modified_by := c1.modified_by;
              l_wdx_properties_rec.modified_date := c1.modified_date;
              l_wdx_properties_rec.hash := tapi_wdx_properties.hash( c1.appid, c1.key);
              l_wdx_properties_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_properties_rec);
       END LOOP;

       RETURN;
    END tt;


    PROCEDURE ins (p_wdx_properties_rec IN OUT wdx_properties_rt)
    IS
        l_rowtype     wdx_properties%ROWTYPE;
        l_user_name   wdx_properties.created_by%TYPE := NVL(dbax_security.get_username (dbax_core.g$appid),USER);
        l_date        wdx_properties.created_date%TYPE := SYSDATE;

    BEGIN

        p_wdx_properties_rec.created_by := l_user_name;
        p_wdx_properties_rec.created_date := l_date;
        p_wdx_properties_rec.modified_by := l_user_name;
        p_wdx_properties_rec.modified_date := l_date;

        l_rowtype.appid := ins.p_wdx_properties_rec.appid;
        l_rowtype.key := ins.p_wdx_properties_rec.key;
        l_rowtype.value := ins.p_wdx_properties_rec.value;
        l_rowtype.description := ins.p_wdx_properties_rec.description;
        l_rowtype.created_by := ins.p_wdx_properties_rec.created_by;
        l_rowtype.created_date := ins.p_wdx_properties_rec.created_date;
        l_rowtype.modified_by := ins.p_wdx_properties_rec.modified_by;
        l_rowtype.modified_date := ins.p_wdx_properties_rec.modified_date;

       INSERT INTO wdx_properties
         VALUES   l_rowtype;

    END ins;

    PROCEDURE upd (
                  p_wdx_properties_rec         IN wdx_properties_rt,
                  p_ignore_nulls         IN boolean := FALSE
                  )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_properties
             SET appid = NVL(p_wdx_properties_rec.appid,appid),
                key = NVL(p_wdx_properties_rec.key,key),
                value = NVL(p_wdx_properties_rec.value,value),
                description = NVL(p_wdx_properties_rec.description,description),
                modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                modified_date = SYSDATE
           WHERE
                appid = upd.p_wdx_properties_rec.appid AND 
                key = upd.p_wdx_properties_rec.key
                ;
       ELSE
          UPDATE   wdx_properties
             SET appid = p_wdx_properties_rec.appid,
                key = p_wdx_properties_rec.key,
                value = p_wdx_properties_rec.value,
                description = p_wdx_properties_rec.description,
                modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                modified_date = SYSDATE
           WHERE
                appid = upd.p_wdx_properties_rec.appid AND 
                key = upd.p_wdx_properties_rec.key
                ;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd;


    PROCEDURE upd_rowid (
                         p_wdx_properties_rec         IN wdx_properties_rt,
                         p_ignore_nulls         IN boolean := FALSE
                        )
    IS
    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_properties
             SET appid = NVL(p_wdx_properties_rec.appid,appid),
                key = NVL(p_wdx_properties_rec.key,key),
                value = NVL(p_wdx_properties_rec.value,value),
                description = NVL(p_wdx_properties_rec.description,description),
                modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_properties_rec.row_id;
       ELSE
          UPDATE   wdx_properties
             SET appid = p_wdx_properties_rec.appid,
                key = p_wdx_properties_rec.key,
                value = p_wdx_properties_rec.value,
                description = p_wdx_properties_rec.description,
                modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                modified_date = SYSDATE
           WHERE  ROWID = p_wdx_properties_rec.row_id;
       END IF;

       IF SQL%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;

    EXCEPTION
       WHEN e_upd_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');
    END upd_rowid;

   PROCEDURE web_upd (
                  p_wdx_properties_rec         IN wdx_properties_rt,
                  p_ignore_nulls         IN boolean := FALSE
                )
   IS
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      OPEN wdx_properties_cur(
                             web_upd.p_wdx_properties_rec.appid,
                             web_upd.p_wdx_properties_rec.key
                        );

      FETCH wdx_properties_cur INTO l_wdx_properties_rec;

      IF wdx_properties_cur%NOTFOUND THEN
         CLOSE wdx_properties_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_properties_rec.hash != l_wdx_properties_rec.hash THEN
            CLOSE wdx_properties_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN

                UPDATE   wdx_properties
                   SET appid = NVL(p_wdx_properties_rec.appid,appid),
                       key = NVL(p_wdx_properties_rec.key,key),
                       value = NVL(p_wdx_properties_rec.value,value),
                       description = NVL(p_wdx_properties_rec.description,description),
                       modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_properties_cur;
            ELSE
                UPDATE   wdx_properties
                   SET appid = p_wdx_properties_rec.appid,
                       key = p_wdx_properties_rec.key,
                       value = p_wdx_properties_rec.value,
                       description = p_wdx_properties_rec.description,
                       modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_properties_cur;
            END IF;

            CLOSE wdx_properties_cur;
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
                            p_wdx_properties_rec    IN wdx_properties_rt,
                            p_ignore_nulls         IN boolean := FALSE
                           )
   IS
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      OPEN wdx_properties_rowid_cur(web_upd_rowid.p_wdx_properties_rec.row_id);

      FETCH wdx_properties_rowid_cur INTO l_wdx_properties_rec;

      IF wdx_properties_rowid_cur%NOTFOUND THEN
         CLOSE wdx_properties_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_upd_rowid.p_wdx_properties_rec.hash != l_wdx_properties_rec.hash THEN
            CLOSE wdx_properties_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(web_upd_rowid.p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_properties
                   SET appid = NVL(p_wdx_properties_rec.appid,appid),
                       key = NVL(p_wdx_properties_rec.key,key),
                       value = NVL(p_wdx_properties_rec.value,value),
                       description = NVL(p_wdx_properties_rec.description,description),
                       modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_properties_rowid_cur;
            ELSE
                UPDATE   wdx_properties
                   SET appid = p_wdx_properties_rec.appid,
                       key = p_wdx_properties_rec.key,
                       value = p_wdx_properties_rec.value,
                       description = p_wdx_properties_rec.description,
                       modified_by = NVL(dbax_security.get_username (dbax_core.g$appid),USER),
                       modified_date = SYSDATE
               WHERE CURRENT OF wdx_properties_rowid_cur;
            END IF;

            CLOSE wdx_properties_rowid_cur;
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
                  p_appid IN wdx_properties.appid%TYPE,
                  p_key IN wdx_properties.key%TYPE
                  )
    IS
    BEGIN

       DELETE FROM   wdx_properties
             WHERE
                  appid = del.p_appid AND 
                  key = del.p_key
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

       DELETE FROM   wdx_properties
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
                      p_appid IN wdx_properties.appid%TYPE,
                      p_key IN wdx_properties.key%TYPE,
                      p_hash IN varchar2
                      )
   IS
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      OPEN wdx_properties_cur(
                            web_del.p_appid,
                            web_del.p_key
                            );

      FETCH wdx_properties_cur INTO l_wdx_properties_rec;

      IF wdx_properties_cur%NOTFOUND THEN
         CLOSE wdx_properties_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del.p_hash != l_wdx_properties_rec.hash THEN
            CLOSE wdx_properties_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_properties
            WHERE CURRENT OF wdx_properties_cur;

            CLOSE wdx_properties_cur;
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
      l_wdx_properties_rec wdx_properties_rt;
   BEGIN

      OPEN wdx_properties_rowid_cur(web_del_rowid.p_rowid);

      FETCH wdx_properties_rowid_cur INTO l_wdx_properties_rec;

      IF wdx_properties_rowid_cur%NOTFOUND THEN
         CLOSE wdx_properties_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del_rowid.p_hash != l_wdx_properties_rec.hash THEN
            CLOSE wdx_properties_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_properties
            WHERE CURRENT OF wdx_properties_rowid_cur;

            CLOSE wdx_properties_rowid_cur;
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

END tapi_wdx_properties;
/

