--
-- TAPI_WDX_MAP_ROUTES  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      tapi_wdx_map_routes IS

   /**
   -- # TAPI_wdx_map_routes
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 03-AGO-2015 09:41
   -- Created By: DBAX
   */



   --GLOBAL_PRIVATE_CURSORS
   --By PK
   CURSOR wdx_map_routes_cur (
        p_appid     IN      wdx_map_routes.appid%TYPE,
  p_route_name     IN      wdx_map_routes.route_name%TYPE
   )
   IS
      SELECT appid
           , route_name
           , priority
           , url_pattern
           , controller_method
           , view_name
           , description
           , active
           , created_by
           , created_date
           , modified_by
           , modified_date
           , tapi_wdx_map_routes.hash(appid, route_name)
           , ROWID
      FROM wdx_map_routes
      WHERE appid = UPPER(wdx_map_routes_cur.p_appid) AND
            route_name = LOWER(wdx_map_routes_cur.p_route_name)
      FOR UPDATE;

    --By Rowid
    CURSOR wdx_map_routes_rowid_cur (p_rowid     IN      varchar2)
    IS
      SELECT appid
           , route_name
           , priority
           , url_pattern
           , controller_method
           , view_name
           , description
           , active
           , created_by
           , created_date
           , modified_by
           , modified_date
           , tapi_wdx_map_routes.hash(appid, route_name)
           , ROWID
      FROM wdx_map_routes
      WHERE ROWID = p_rowid
      FOR UPDATE;


    FUNCTION hash (
        p_appid     IN      wdx_map_routes.appid%TYPE,
  p_route_name     IN      wdx_map_routes.route_name%TYPE
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

      SELECT  appid ||
               route_name ||
               priority ||
               url_pattern ||
               controller_method ||
               view_name ||
               description ||
               active ||
               created_by ||
               created_date ||
               modified_by ||
               modified_date
      INTO l_string
      FROM wdx_map_routes
      WHERE  appid =  UPPER(hash.p_appid) AND
             route_name =  LOWER(hash.p_route_name);

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

      SELECT  appid ||
               route_name ||
               priority ||
               url_pattern ||
               controller_method ||
               view_name ||
               description ||
               active ||
               created_by ||
               created_date ||
               modified_by ||
               modified_date
      INTO l_string
      FROM wdx_map_routes
      WHERE  ROWID = p_rowid;

      --Restore NLS_DATE_FORMAT to default
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''' || l_date_format|| '''';


      l_retval := DBMS_CRYPTO.hash(l_string, DBMS_CRYPTO.hash_sh1);


      RETURN l_retval;


   END hash_rowid;

    PROCEDURE reorder_routes (p_appid        IN wdx_map_routes.appid%TYPE
                            , p_route_name   IN wdx_map_routes.route_name%TYPE
                            , p_priority     IN wdx_map_routes.priority%TYPE
                            , p_action       IN varchar2)
    AS
        l_max_priority pls_integer;
    BEGIN
       select max(priority) into l_max_priority from wdx_map_routes where appid = reorder_routes.p_appid;
       
       --Move the priority of routes
       IF p_action = 'INS'
       THEN
          FOR c1 IN (  SELECT   *
                         FROM   table (tapi_wdx_map_routes.tt (reorder_routes.p_appid))
                        WHERE   priority >= reorder_routes.p_priority AND route_name <> LOWER(reorder_routes.p_route_name)
                     ORDER BY   priority DESC)
          LOOP
             if c1.priority <> l_max_priority
             then
                c1.priority := c1.priority + 1;
                tapi_wdx_map_routes.upd_rowid (c1, TRUE);
             end if;
          END LOOP;
       ELSIF p_action = 'DEL'
       THEN
          FOR c1 IN (  SELECT   *
                         FROM   table (tapi_wdx_map_routes.tt (reorder_routes.p_appid))
                        WHERE   priority >= reorder_routes.p_priority AND route_name <> LOWER(reorder_routes.p_route_name)
                     ORDER BY   priority ASC)
          LOOP
             c1.priority := c1.priority -1;
             tapi_wdx_map_routes.upd_rowid (c1, TRUE);
          END LOOP;
       END IF;
    END reorder_routes;


   FUNCTION rt (
        p_appid     IN      wdx_map_routes.appid%TYPE,
  p_route_name     IN      wdx_map_routes.route_name%TYPE
          )
      RETURN wdx_map_routes_rt RESULT_CACHE
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN


      SELECT a.*, tapi_wdx_map_routes.hash(appid, route_name), ROWID
      INTO l_wdx_map_routes_rec
      FROM wdx_map_routes a
      WHERE appid= UPPER(rt.p_appid) AND
            route_name= LOWER(rt.p_route_name);


      RETURN l_wdx_map_routes_rec;


   END rt;

   FUNCTION rt_rowid (p_rowid IN varchar2)
      RETURN wdx_map_routes_rt RESULT_CACHE
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN


      SELECT a.*, tapi_wdx_map_routes.hash(appid, route_name), ROWID
      INTO l_wdx_map_routes_rec
      FROM wdx_map_routes a
      WHERE ROWID = rt_rowid.p_rowid;


      RETURN l_wdx_map_routes_rec;


   END rt_rowid;

   FUNCTION rt_for_update (
        p_appid     IN      wdx_map_routes.appid%TYPE,
  p_route_name     IN      wdx_map_routes.route_name%TYPE
          )
      RETURN wdx_map_routes_rt RESULT_CACHE
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN



      SELECT a.*, tapi_wdx_map_routes.hash(appid, route_name), ROWID
      INTO l_wdx_map_routes_rec
      FROM wdx_map_routes a
      WHERE appid= UPPER(rt_for_update.p_appid) AND
            route_name= LOWER(rt_for_update.p_route_name)
      FOR UPDATE;


      RETURN l_wdx_map_routes_rec;


   END rt_for_update;

    FUNCTION tt (
        p_appid IN wdx_map_routes.appid%TYPE DEFAULT NULL,
  p_route_name IN wdx_map_routes.route_name%TYPE DEFAULT NULL
              )
       RETURN wdx_map_routes_tt
       PIPELINED
    IS

       l_wdx_map_routes_rec   wdx_map_routes_rt;
    BEGIN



       FOR c1 IN (SELECT   a.*, ROWID
                    FROM   wdx_map_routes a
                   WHERE appid= NVL(UPPER(p_appid),appid) AND
                         route_name= NVL(LOWER(p_route_name),route_name))
       LOOP
              l_wdx_map_routes_rec.appid := c1.appid;
              l_wdx_map_routes_rec.route_name := c1.route_name;
              l_wdx_map_routes_rec.priority := c1.priority;
              l_wdx_map_routes_rec.url_pattern := c1.url_pattern;
              l_wdx_map_routes_rec.controller_method := c1.controller_method;
              l_wdx_map_routes_rec.view_name := c1.view_name;
              l_wdx_map_routes_rec.description := c1.description;
              l_wdx_map_routes_rec.active := c1.active;
              l_wdx_map_routes_rec.created_by := c1.created_by;
              l_wdx_map_routes_rec.created_date := c1.created_date;
              l_wdx_map_routes_rec.modified_by := c1.modified_by;
              l_wdx_map_routes_rec.modified_date := c1.modified_date;

              l_wdx_map_routes_rec.hash := tapi_wdx_map_routes.hash(c1.appid, c1.route_name);
              l_wdx_map_routes_rec.row_id := c1.ROWID;
              PIPE ROW (l_wdx_map_routes_rec);
       END LOOP;


       RETURN;


    END tt;


    PROCEDURE ins (p_wdx_map_routes_rec IN OUT wdx_map_routes_rt)
    IS


       l_rowtype     wdx_map_routes%ROWTYPE;
       l_user_name   wdx_map_routes.created_by%TYPE := USER;
       l_date        wdx_map_routes.created_date%TYPE := SYSDATE;

    BEGIN

       p_wdx_map_routes_rec.created_by := l_user_name;
       p_wdx_map_routes_rec.created_date := l_date;
       p_wdx_map_routes_rec.modified_by := l_user_name;
       p_wdx_map_routes_rec.modified_date := l_date;

       l_rowtype.appid := UPPER(p_wdx_map_routes_rec.appid);
       l_rowtype.route_name := LOWER(p_wdx_map_routes_rec.route_name);
       l_rowtype.priority := p_wdx_map_routes_rec.priority;
       l_rowtype.url_pattern := p_wdx_map_routes_rec.url_pattern;
       l_rowtype.controller_method := p_wdx_map_routes_rec.controller_method;
       l_rowtype.view_name := p_wdx_map_routes_rec.view_name;
       l_rowtype.description := p_wdx_map_routes_rec.description;
       l_rowtype.active := p_wdx_map_routes_rec.active;
       l_rowtype.created_by := p_wdx_map_routes_rec.created_by;
       l_rowtype.created_date := p_wdx_map_routes_rec.created_date;
       l_rowtype.modified_by := p_wdx_map_routes_rec.modified_by;
       l_rowtype.modified_date := p_wdx_map_routes_rec.modified_date;

       reorder_routes(l_rowtype.appid, l_rowtype.route_name,l_rowtype.priority, 'INS');

       INSERT INTO wdx_map_routes
         VALUES   l_rowtype;


    END ins;

    PROCEDURE upd (p_wdx_map_routes_rec IN wdx_map_routes_rt, p_ignore_nulls IN boolean := FALSE)
    IS

    BEGIN


       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_map_routes
             SET   appid = NVL(p_wdx_map_routes_rec.appid,appid) ,
                   route_name = NVL(p_wdx_map_routes_rec.route_name,route_name) ,
                   priority = NVL(p_wdx_map_routes_rec.priority,priority) ,
                   url_pattern = NVL(p_wdx_map_routes_rec.url_pattern,url_pattern) ,
                   controller_method = NVL(p_wdx_map_routes_rec.controller_method,controller_method) ,
                   view_name = NVL(p_wdx_map_routes_rec.view_name,view_name) ,
                   description = NVL(p_wdx_map_routes_rec.description,description) ,
                   active = NVL(p_wdx_map_routes_rec.active,active) ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
           WHERE  appid = p_wdx_map_routes_rec.appid AND
                  route_name = p_wdx_map_routes_rec.route_name;
       ELSE
          UPDATE   wdx_map_routes
             SET   appid = p_wdx_map_routes_rec.appid ,
                   route_name = p_wdx_map_routes_rec.route_name ,
                   priority = p_wdx_map_routes_rec.priority ,
                   url_pattern = p_wdx_map_routes_rec.url_pattern ,
                   controller_method = p_wdx_map_routes_rec.controller_method ,
                   view_name = p_wdx_map_routes_rec.view_name ,
                   description = p_wdx_map_routes_rec.description ,
                   active = p_wdx_map_routes_rec.active ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
           WHERE appid = p_wdx_map_routes_rec.appid AND
                 route_name = p_wdx_map_routes_rec.route_name;
       END IF;

       IF sql%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');

    END upd;


    PROCEDURE upd_rowid (p_wdx_map_routes_rec IN wdx_map_routes_rt, p_ignore_nulls IN boolean := FALSE)
    IS

    BEGIN


       IF NVL (p_ignore_nulls, FALSE)
       THEN
          UPDATE   wdx_map_routes
             SET   appid = NVL(p_wdx_map_routes_rec.appid,appid) ,
                   route_name = NVL(p_wdx_map_routes_rec.route_name,route_name) ,
                   priority = NVL(p_wdx_map_routes_rec.priority,priority) ,
                   url_pattern = NVL(p_wdx_map_routes_rec.url_pattern,url_pattern) ,
                   controller_method = NVL(p_wdx_map_routes_rec.controller_method,controller_method) ,
                   view_name = NVL(p_wdx_map_routes_rec.view_name,view_name) ,
                   description = NVL(p_wdx_map_routes_rec.description,description) ,
                   active = NVL(p_wdx_map_routes_rec.active,active) ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
           WHERE  ROWID = p_wdx_map_routes_rec.row_id;
       ELSE
          UPDATE   wdx_map_routes
             SET   appid = p_wdx_map_routes_rec.appid ,
                   route_name = p_wdx_map_routes_rec.route_name ,
                   priority = p_wdx_map_routes_rec.priority ,
                   url_pattern = p_wdx_map_routes_rec.url_pattern ,
                   controller_method = p_wdx_map_routes_rec.controller_method ,
                   view_name = p_wdx_map_routes_rec.view_name ,
                   description = p_wdx_map_routes_rec.description ,
                   active = p_wdx_map_routes_rec.active ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
           WHERE  ROWID = p_wdx_map_routes_rec.row_id;
       END IF;

       IF sql%ROWCOUNT != 1 THEN RAISE e_upd_failed; END IF;


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were updated. The update failed.');

    END upd_rowid;

   PROCEDURE web_upd (
      p_wdx_map_routes_rec    IN wdx_map_routes_rt
    , p_ignore_nulls         IN boolean := FALSE
   )
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN


      OPEN wdx_map_routes_cur(p_wdx_map_routes_rec.appid , p_wdx_map_routes_rec.route_name);

      FETCH wdx_map_routes_cur INTO l_wdx_map_routes_rec;

      IF wdx_map_routes_cur%NOTFOUND THEN
         CLOSE wdx_map_routes_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_map_routes_rec.hash != l_wdx_map_routes_rec.hash THEN
            CLOSE wdx_map_routes_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_map_routes
                   SET   appid = NVL(p_wdx_map_routes_rec.appid,appid) ,
                   route_name = NVL(p_wdx_map_routes_rec.route_name,route_name) ,
                   priority = NVL(p_wdx_map_routes_rec.priority,priority) ,
                   url_pattern = NVL(p_wdx_map_routes_rec.url_pattern,url_pattern) ,
                   controller_method = NVL(p_wdx_map_routes_rec.controller_method,controller_method) ,
                   view_name = NVL(p_wdx_map_routes_rec.view_name,view_name) ,
                   description = NVL(p_wdx_map_routes_rec.description,description) ,
                   active = NVL(p_wdx_map_routes_rec.active,active) ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
               WHERE CURRENT OF wdx_map_routes_cur;
            ELSE
                UPDATE   wdx_map_routes
                   SET   appid = p_wdx_map_routes_rec.appid ,
                   route_name = p_wdx_map_routes_rec.route_name ,
                   priority = p_wdx_map_routes_rec.priority ,
                   url_pattern = p_wdx_map_routes_rec.url_pattern ,
                   controller_method = p_wdx_map_routes_rec.controller_method ,
                   view_name = p_wdx_map_routes_rec.view_name ,
                   description = p_wdx_map_routes_rec.description ,
                   active = p_wdx_map_routes_rec.active ,
                   modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                   modified_date = SYSDATE
               WHERE CURRENT OF wdx_map_routes_cur;
            END IF;

            CLOSE wdx_map_routes_cur;
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
      p_wdx_map_routes_rec    IN wdx_map_routes_rt
    , p_ignore_nulls         IN boolean := FALSE
   )
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN


      OPEN wdx_map_routes_rowid_cur(p_wdx_map_routes_rec.row_id);

      FETCH wdx_map_routes_rowid_cur INTO l_wdx_map_routes_rec;

      IF wdx_map_routes_rowid_cur%NOTFOUND THEN
         CLOSE wdx_map_routes_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF p_wdx_map_routes_rec.hash != l_wdx_map_routes_rec.hash THEN
            CLOSE wdx_map_routes_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            IF NVL(p_ignore_nulls, FALSE)
            THEN
                UPDATE   wdx_map_routes
                     SET  appid = NVL(p_wdx_map_routes_rec.appid,appid) ,
                          route_name = NVL(p_wdx_map_routes_rec.route_name,route_name) ,
                          priority = NVL(p_wdx_map_routes_rec.priority,priority) ,
                          url_pattern = NVL(p_wdx_map_routes_rec.url_pattern,url_pattern) ,
                          controller_method = NVL(p_wdx_map_routes_rec.controller_method,controller_method) ,
                          view_name = NVL(p_wdx_map_routes_rec.view_name,view_name) ,
                          description = NVL(p_wdx_map_routes_rec.description,description) ,
                          active = NVL(p_wdx_map_routes_rec.active,active) ,
                          modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                          modified_date = SYSDATE
               WHERE CURRENT OF wdx_map_routes_rowid_cur;
            ELSE
                UPDATE   wdx_map_routes
                 SET  appid = p_wdx_map_routes_rec.appid ,
                      route_name = p_wdx_map_routes_rec.route_name ,
                      priority = p_wdx_map_routes_rec.priority ,
                      url_pattern = p_wdx_map_routes_rec.url_pattern ,
                      controller_method = p_wdx_map_routes_rec.controller_method ,
                      view_name = p_wdx_map_routes_rec.view_name ,
                      description = p_wdx_map_routes_rec.description ,
                      active = p_wdx_map_routes_rec.active ,
                      modified_by = USER /*dbax_core.g$username or apex_application.g_user*/,
                      modified_date = SYSDATE
               WHERE CURRENT OF wdx_map_routes_rowid_cur;
            END IF;

            CLOSE wdx_map_routes_rowid_cur;
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
        p_appid IN wdx_map_routes.appid%TYPE,
        p_route_name IN wdx_map_routes.route_name%TYPE
              )
    IS
      l_wdx_map_routes_rec wdx_map_routes_rt;
    BEGIN

       --Get deleted route
       l_wdx_map_routes_rec := tapi_wdx_map_routes.rt(del.p_appid,del.p_route_name);

       DELETE FROM   wdx_map_routes
             WHERE   appid = UPPER(del.p_appid) AND
                     route_name = LOWER(del.p_route_name);

       IF sql%ROWCOUNT != 1
       THEN
          RAISE e_del_failed;
       END IF;

      reorder_routes(l_wdx_map_routes_rec.appid, l_wdx_map_routes_rec.route_name, l_wdx_map_routes_rec.priority, 'DEL');


    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were deleted. The delete failed.');

    END del;

    PROCEDURE del_rowid (p_rowid IN varchar2)
    IS
      l_wdx_map_routes_rec wdx_map_routes_rt;
    BEGIN

       --Get deleted route
       l_wdx_map_routes_rec := tapi_wdx_map_routes.rt_rowid(del_rowid.p_rowid);

       DELETE FROM   wdx_map_routes
             WHERE   ROWID = del_rowid.p_rowid;

       IF sql%ROWCOUNT != 1
       THEN
          RAISE e_del_failed;
       END IF;

      reorder_routes(l_wdx_map_routes_rec.appid, l_wdx_map_routes_rec.route_name, l_wdx_map_routes_rec.priority, 'DEL');

    EXCEPTION
       WHEN e_del_failed
       THEN
          raise_application_error (-20000, 'No rows were deleted. The delete failed.');

    END del_rowid;

    PROCEDURE web_del (
        p_appid IN wdx_map_routes.appid%TYPE,
  p_route_name IN wdx_map_routes.route_name%TYPE
      , p_hash IN varchar2
   )
   IS

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN



      OPEN wdx_map_routes_cur(web_del.p_appid, web_del.p_route_name);

      FETCH wdx_map_routes_cur INTO l_wdx_map_routes_rec;

      IF wdx_map_routes_cur%NOTFOUND THEN
         CLOSE wdx_map_routes_cur;
         RAISE e_row_missing;
      ELSE
         IF p_hash != l_wdx_map_routes_rec.hash THEN
            CLOSE wdx_map_routes_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_map_routes
            WHERE CURRENT OF wdx_map_routes_cur;

            CLOSE wdx_map_routes_cur;
         END IF;
      END IF;


      reorder_routes(l_wdx_map_routes_rec.appid, l_wdx_map_routes_rec.route_name, l_wdx_map_routes_rec.priority, 'DEL');

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

      l_wdx_map_routes_rec wdx_map_routes_rt;
   BEGIN



      OPEN wdx_map_routes_rowid_cur(web_del_rowid.p_rowid);

      FETCH wdx_map_routes_rowid_cur INTO l_wdx_map_routes_rec;

      IF wdx_map_routes_rowid_cur%NOTFOUND THEN
         CLOSE wdx_map_routes_rowid_cur;
         RAISE e_row_missing;
      ELSE
         IF web_del_rowid.p_hash != l_wdx_map_routes_rec.hash THEN
            CLOSE wdx_map_routes_rowid_cur;
            RAISE e_ol_check_failed;
         ELSE
            DELETE FROM wdx_map_routes
            WHERE CURRENT OF wdx_map_routes_rowid_cur;

            CLOSE wdx_map_routes_rowid_cur;
         END IF;
      END IF;

      reorder_routes(l_wdx_map_routes_rec.appid, l_wdx_map_routes_rec.route_name, l_wdx_map_routes_rec.priority, 'DEL');

   EXCEPTION
     WHEN e_ol_check_failed
     THEN
        raise_application_error (-20000 , 'Current version of data in database has changed since last page refresh.');
     WHEN e_row_missing
     THEN
        raise_application_error (-20000 , 'Delete operation failed because the row is no longer in the database.');

   END web_del_rowid;

    FUNCTION max_priority(p_appid  IN      wdx_map_routes.appid%TYPE )
    RETURN number
    AS
        l_max_priority number;
    BEGIN
        SELECT max(priority) INTO l_max_priority FROM wdx_map_routes WHERE appid = UPPER(max_priority.p_appid);
        
        RETURN NVL(l_max_priority,0);
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        return 0;
    END max_priority;

END tapi_wdx_map_routes;
/


