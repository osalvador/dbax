--
-- TAPI_WDX_LOG  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      tapi_wdx_log IS

   /**
   -- # TAPI_wdx_log
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 13-AGO-2015 17:02
   -- Created By: DBAX
   */



   --GLOBAL_PRIVATE_CURSORS
   --By PK
   CURSOR wdx_log_cur (
        p_id     IN      wdx_log.id%TYPE
   )
   IS
      SELECT id
           , appid
           , dbax_session
           , created_date
           , log_user
           , log_level           
           , log_text
           , tapi_wdx_log.hash(id)
           , ROWID
      FROM wdx_log
      WHERE id = wdx_log_cur.p_id
      FOR UPDATE;

    --By Rowid
    CURSOR wdx_log_rowid_cur (p_rowid     IN      varchar2)
    IS
      SELECT id
           , appid
           , dbax_session
           , created_date
           , log_user
           , log_level           
           , log_text
           , tapi_wdx_log.hash(id)
           , ROWID
      FROM wdx_log
      WHERE ROWID = p_rowid
      FOR UPDATE;


    FUNCTION num_rows RETURN PLS_INTEGER
    AS
       l_count pls_integer;
    BEGIN
       SELECT   COUNT (id) into l_count FROM wdx_log;
       return l_count; 
    END num_rows;
    

    FUNCTION hash (
        p_id     IN      wdx_log.id%TYPE
          )
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

      SELECT  id ||
               appid ||
               dbax_session ||
               created_date ||
               log_user ||
               log_level ||               
               log_text
      INTO l_string
      FROM wdx_log
      WHERE  id =  hash.p_id;

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

      SELECT  id ||
               appid ||
               dbax_session ||
               created_date ||
               log_user ||
               log_level ||               
               log_text
      INTO l_string
      FROM wdx_log
      WHERE  ROWID = p_rowid;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';


      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);


      RETURN l_retval;


   END hash_rowid;

   FUNCTION rt (
        p_id     IN      wdx_log.id%TYPE
          )
      RETURN wdx_log_rt
   IS

      l_wdx_log_rec wdx_log_rt;
   BEGIN


      SELECT a.*, tapi_wdx_log.hash(id), ROWID
      INTO l_wdx_log_rec
      FROM wdx_log a
      WHERE id= rt.p_id;


      RETURN l_wdx_log_rec;


   END rt;

   FUNCTION rt_for_update (
        p_id     IN      wdx_log.id%TYPE
          )
      RETURN wdx_log_rt
   IS

      l_wdx_log_rec wdx_log_rt;
   BEGIN



      SELECT a.*, tapi_wdx_log.hash(id), ROWID
      INTO l_wdx_log_rec
      FROM wdx_log a
      WHERE id= rt_for_update.p_id
      FOR UPDATE;


      RETURN l_wdx_log_rec;


   END rt_for_update;

    FUNCTION tt (
        p_id IN wdx_log.id%TYPE DEFAULT NULL
              )
       RETURN wdx_log_tt
       PIPELINED
    IS

       l_wdx_log_rec   wdx_log_rt;
    BEGIN



       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_log a
                   WHERE id= NVL(p_id,id))
       LOOP
              l_wdx_log_rec.id := c1.id;
              l_wdx_log_rec.appid := c1.appid;
              l_wdx_log_rec.dbax_session := c1.dbax_session;
              l_wdx_log_rec.created_date := c1.created_date;
              l_wdx_log_rec.log_user := c1.log_user;
              l_wdx_log_rec.log_level := c1.log_level;              
              l_wdx_log_rec.log_text := c1.log_text;

              l_wdx_log_rec.hash := tapi_wdx_log.hash(c1.id);
              l_wdx_log_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_log_rec);
       END LOOP;


       RETURN;


    END tt;


    PROCEDURE ins (p_wdx_log_rec IN OUT wdx_log_rt)
    IS
       l_rowtype     wdx_log%ROWTYPE;
       l_date        wdx_log.created_date%TYPE := SYSTIMESTAMP;
    BEGIN
       p_wdx_log_rec.created_date := l_date;

       l_rowtype.id  := wdx_log_seq.NEXTVAL;
       l_rowtype.appid := p_wdx_log_rec.appid;
       l_rowtype.dbax_session := p_wdx_log_rec.dbax_session;
       l_rowtype.created_date := p_wdx_log_rec.created_date;
       l_rowtype.log_user := p_wdx_log_rec.log_user;
       l_rowtype.log_level := p_wdx_log_rec.log_level;       
       l_rowtype.log_text := p_wdx_log_rec.log_text;

       INSERT INTO wdx_log
         VALUES   l_rowtype;

    END ins;

    PROCEDURE upd (p_wdx_log_rec IN wdx_log_rt, p_ignore_nulls IN boolean := FALSE)
    IS

    BEGIN

       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_log
             SET   id = NVL(p_wdx_log_rec.id,id) ,
                   appid = NVL(p_wdx_log_rec.appid,appid) ,
                   dbax_session = NVL(p_wdx_log_rec.dbax_session,dbax_session) ,
                   log_user = NVL(p_wdx_log_rec.log_user,log_user) ,
                   log_level = NVL(p_wdx_log_rec.log_level,log_level) ,                   
                   log_text = NVL(p_wdx_log_rec.log_text,log_text)
           WHERE  id = p_wdx_log_rec.id;
       ELSE
          UPDATE   wdx_log
             SET   id = p_wdx_log_rec.id ,
                   appid = p_wdx_log_rec.appid ,
                   dbax_session = p_wdx_log_rec.dbax_session ,
                   log_user = p_wdx_log_rec.log_user ,
                   log_level = p_wdx_log_rec.log_level ,                   
                   log_text = p_wdx_log_rec.log_text
           WHERE id = p_wdx_log_rec.id;
       END IF;

       IF sql%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');

    END upd;


    PROCEDURE upd_rowid (p_wdx_log_rec IN wdx_log_rt, p_ignore_nulls IN boolean := FALSE)
    IS

    BEGIN


       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_log
             SET   id = NVL(p_wdx_log_rec.id,id) ,
                   appid = NVL(p_wdx_log_rec.appid,appid) ,
                   dbax_session = NVL(p_wdx_log_rec.dbax_session,dbax_session) ,
                   log_user = NVL(p_wdx_log_rec.log_user,log_user) ,
                   log_level = NVL(p_wdx_log_rec.log_level,log_level) ,                   
                   log_text = NVL(p_wdx_log_rec.log_text,log_text)
           WHERE  ROWID = p_wdx_log_rec.row_id;
       ELSE
          UPDATE   wdx_log
             SET   id = p_wdx_log_rec.id ,
                   appid = p_wdx_log_rec.appid ,
                   dbax_session = p_wdx_log_rec.dbax_session ,
                   log_user = p_wdx_log_rec.log_user ,
                   log_level = p_wdx_log_rec.log_level ,                   
                   log_text = p_wdx_log_rec.log_text
           WHERE  ROWID = p_wdx_log_rec.row_id;
       END IF;

       IF sql%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');

    END upd_rowid;

   PROCEDURE web_upd (
      p_wdx_log_rec    IN wdx_log_rt
    , p_ignore_nulls         IN boolean := FALSE
   )
   IS

      l_wdx_log_rec wdx_log_rt;
   BEGIN


      OPEN wdx_log_cur(p_wdx_log_rec.id);

      FETCH wdx_log_cur INTO l_wdx_log_rec;

      IF wdx_log_cur%NOTFOUND THEN
         CLOSE wdx_log_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_log_rec.hash != l_wdx_log_rec.hash THEN
            CLOSE wdx_log_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_log
                   SET   id = NVL(p_wdx_log_rec.id,id) ,
                   appid = NVL(p_wdx_log_rec.appid,appid) ,
                   dbax_session = NVL(p_wdx_log_rec.dbax_session,dbax_session) ,
                   log_user = NVL(p_wdx_log_rec.log_user,log_user) ,
                   log_level = NVL(p_wdx_log_rec.log_level,log_level) ,                   
                   log_text = NVL(p_wdx_log_rec.log_text,log_text)
               WHERE CURRENT OF wdx_log_cur;
            ELSE
                UPDATE   wdx_log
                   SET   id = p_wdx_log_rec.id ,
                   appid = p_wdx_log_rec.appid ,
                   dbax_session = p_wdx_log_rec.dbax_session ,
                   log_user = p_wdx_log_rec.log_user ,
                   log_level = p_wdx_log_rec.log_level ,                   
                   log_text = p_wdx_log_rec.log_text
               WHERE CURRENT OF wdx_log_cur;
            END IF;

            CLOSE wdx_log_cur;
         END IF;
      END IF;



   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Delete operation failed because the row is no longer in the database.');

   END web_upd;

   PROCEDURE web_upd_rowid (
      p_wdx_log_rec    IN wdx_log_rt
    , p_ignore_nulls         IN boolean := FALSE
   )
   IS

      l_wdx_log_rec wdx_log_rt;
   BEGIN


      OPEN wdx_log_rowid_cur(p_wdx_log_rec.row_id);

      FETCH wdx_log_rowid_cur INTO l_wdx_log_rec;

      IF wdx_log_rowid_cur%NOTFOUND THEN
         CLOSE wdx_log_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_log_rec.hash != l_wdx_log_rec.hash THEN
            CLOSE wdx_log_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_log
                     SET  id = NVL(p_wdx_log_rec.id,id) ,
                          appid = NVL(p_wdx_log_rec.appid,appid) ,
                          dbax_session = NVL(p_wdx_log_rec.dbax_session,dbax_session) ,
                          log_user = NVL(p_wdx_log_rec.log_user,log_user) ,
                          log_level = NVL(p_wdx_log_rec.log_level,log_level) ,                          
                          log_text = NVL(p_wdx_log_rec.log_text,log_text)
               WHERE CURRENT OF wdx_log_rowid_cur;
            ELSE
                UPDATE   wdx_log
                 SET  id = p_wdx_log_rec.id ,
                      appid = p_wdx_log_rec.appid ,
                      dbax_session = p_wdx_log_rec.dbax_session ,
                      log_user = p_wdx_log_rec.log_user ,
                      log_level = p_wdx_log_rec.log_level ,                      
                      log_text = p_wdx_log_rec.log_text
               WHERE CURRENT OF wdx_log_rowid_cur;
            END IF;

            CLOSE wdx_log_rowid_cur;
         END IF;
      END IF;




   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Delete operation failed because the row is no longer in the database.');

   END web_upd_rowid;

    PROCEDURE del (
        p_id IN wdx_log.id%TYPE
              )
    IS

    BEGIN


       DELETE FROM   wdx_log
             WHERE   id = del.p_id;
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


       DELETE FROM   wdx_log
             WHERE   ROWID = p_rowid;

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
        p_id IN wdx_log.id%TYPE
      , p_hash IN varchar2
   )
   IS

      l_wdx_log_rec wdx_log_rt;
   BEGIN



      OPEN wdx_log_cur(web_del.p_id);

      FETCH wdx_log_cur INTO l_wdx_log_rec;

      IF wdx_log_cur%NOTFOUND THEN
         CLOSE wdx_log_cur;
         RAISE e_row_missing;
      ELSE
         IF p_hash != l_wdx_log_rec.hash THEN
            CLOSE wdx_log_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_log
            WHERE CURRENT OF wdx_log_cur;

            CLOSE wdx_log_cur;
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

      l_wdx_log_rec wdx_log_rt;
   BEGIN



      OPEN wdx_log_rowid_cur(web_del_rowid.p_rowid);

      FETCH wdx_log_rowid_cur INTO l_wdx_log_rec;

      IF wdx_log_rowid_cur%NOTFOUND THEN
         CLOSE wdx_log_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del_rowid.p_hash != l_wdx_log_rec.hash THEN
            CLOSE wdx_log_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_log
            WHERE CURRENT OF wdx_log_rowid_cur;

            CLOSE wdx_log_rowid_cur;
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

   FUNCTION count_user_page_views (p_username IN wdx_log.log_user%TYPE)
      RETURN PLS_INTEGER
   AS
    l_count pls_integer;
   BEGIN
      SELECT   COUNT ( * )
        INTO   l_count
        FROM   wdx_log
       WHERE   log_user = count_user_page_views.p_username;     
     
     RETURN l_count;
   END count_user_page_views;

END tapi_wdx_log;
/


