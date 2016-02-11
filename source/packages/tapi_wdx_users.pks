--
-- TAPI_WDX_USERS  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   WDX_USERS (Table)
--   WDX_USERS_ROLES (Table)
--
CREATE OR REPLACE PACKAGE      tapi_wdx_users
IS
   /**
   -- # TAPI_WDX_USERS
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 19-NOV-2015 16:08
   -- Created By: DBAX
   */

   --Scalar/Column types
   SUBTYPE hash_t IS varchar2 (40);
   SUBTYPE username IS wdx_users.username%TYPE;
   SUBTYPE password IS wdx_users.password%TYPE;
   SUBTYPE first_name IS wdx_users.first_name%TYPE;
   SUBTYPE last_name IS wdx_users.last_name%TYPE;
   SUBTYPE display_name IS wdx_users.display_name%TYPE;
   SUBTYPE email IS wdx_users.email%TYPE;
   SUBTYPE status IS wdx_users.status%TYPE;
   SUBTYPE created_by IS wdx_users.created_by%TYPE;
   SUBTYPE created_date IS wdx_users.created_date%TYPE;
   SUBTYPE modified_by IS wdx_users.modified_by%TYPE;
   SUBTYPE modified_date IS wdx_users.modified_date%TYPE;

   --Record type
   TYPE wdx_users_rt
   IS
      RECORD (
            username wdx_users.username%TYPE,
            password wdx_users.password%TYPE,
            first_name wdx_users.first_name%TYPE,
            last_name wdx_users.last_name%TYPE,
            display_name wdx_users.display_name%TYPE,
            email wdx_users.email%TYPE,
            status wdx_users.status%TYPE,
            created_by wdx_users.created_by%TYPE,
            created_date wdx_users.created_date%TYPE,
            modified_by wdx_users.modified_by%TYPE,
            modified_date wdx_users.modified_date%TYPE,
            hash               hash_t,
            row_id            varchar2(64)
      );
   --Collection types (record)
   TYPE wdx_users_tt IS TABLE OF wdx_users_rt;

   --Global exceptions
   e_ol_check_failed exception; --Optimistic lock check failed
   e_row_missing     exception; --The cursor failed to get a row
   e_upd_failed      exception; --The update operation failed
   e_del_failed      exception; --The delete operation failed

    /**
    --## Function Name: HASH
    --### Description:
    --       This function generates a SHA1 hash for optimistic locking purposes.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_username | wdx_users.username%TYPE | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   FUNCTION hash (
                  p_username IN wdx_users.username%TYPE
                 )
    RETURN varchar2;

    /**
    --## Function Name: HASH_ROWID
    --### Description:
    --       This function generates a SHA1 hash for optimistic locking purposes.
             Access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |P_ROWID | VARCHAR2(64)| must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   FUNCTION hash_rowid (p_rowid IN varchar2)
   RETURN varchar2;

    /**
    --## Function Name: RT
    --### Description:
    --       This is a table encapsulation function designed to retrieve information from the wdx_users table.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_username | wdx_users.username%TYPE | must be NOT NULL

    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |     | wdx_users_rt |  wdx_users Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   FUNCTION rt (
                p_username IN wdx_users.username%TYPE
               )
    RETURN wdx_users_rt RESULT_CACHE;

   /**
    --## Function Name: RT_FOR_UPDATE
    --### Description:
    --       This is a table encapsulation function designed to retrieve information
             from the wdx_users table while placing a lock on it for a potential
             update/delete. Do not use this for updates in web based apps, instead use the
             rt_for_web_update function to get a FOR_WEB_UPDATE_RT record which
             includes all of the tables columns along with an md5 checksum for use in the
             web_upd and web_del procedures.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_username | wdx_users.username%TYPE | must be NOT NULL
    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |     | wdx_users_rt |  wdx_users Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   FUNCTION rt_for_update (
                          p_username IN wdx_users.username%TYPE
                          )
    RETURN wdx_users_rt RESULT_CACHE;

    /**
    --## Function Name: TT
    --### Description:
    --       This is a table encapsulation function designed to retrieve information from the wdx_users table.
    --       This function return Record Table as PIPELINED Function
    --
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  |p_username | wdx_users.username%TYPE | must be NOT NULL
    --### Return
    --  | Name | Type | Description
    --  | -- | -- | --
    --  |     | wdx_users_tt |  wdx_users Table Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   FUNCTION tt (
                p_username IN wdx_users.username%TYPE DEFAULT NULL
               )
   RETURN wdx_users_tt
   PIPELINED;

     /**
    --## Function Name: INS
    --### Description:
    --      This is a table encapsulation function designed to insert a row into the wdx_users table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_users_rec | wdx_users_rt| wdx_users Record Type
    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    | p_wdx_users_rec | wdx_users_rt |  wdx_users Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE ins (p_wdx_users_rec IN OUT wdx_users_rt);

    /**
    --## Function Name: UPD
    --### Description:
    --     his is a table encapsulation function designed to update a row in the wdx_users table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_users_rec | wdx_users_rt| wdx_users Record Type
    --   | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE upd (p_wdx_users_rec IN wdx_users_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: UPD_ROWID
    --### Description:
    --     his is a table encapsulation function designed to update a row in the wdx_users table,
           access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_users_rec | wdx_users_rt| wdx_users Record Type
    --   | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE upd_rowid (p_wdx_users_rec IN wdx_users_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: WEB_UPD
    --### Description:
    --      This is a table encapsulation function designed to update a row
            in the wdx_users table whith optimistic lock validation
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  | p_wdx_users_rec | wdx_users_rt| wdx_users Record Type
    --  | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE web_upd (p_wdx_users_rec IN wdx_users_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: WEB_UPD_ROWID
    --### Description:
    --      This is a table encapsulation function designed to update a row
            in the wdx_users table whith optimistic lock validation
            access directly to the row by rowid
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  | p_wdx_users_rec | wdx_users_rt| wdx_users Record Type
    --  | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE web_upd_rowid (p_wdx_users_rec IN wdx_users_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: DEL
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_users table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   |p_username | wdx_users.username%TYPE | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
   PROCEDURE del (
                  p_username IN wdx_users.username%TYPE
                );

    /**
    --## Function Name: DEL_ROWID
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_users table.
             Access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |P_ROWID | VARCHAR2(64)| must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
    PROCEDURE del_rowid (p_rowid IN varchar2);

    /**
    --## Function Name: WEB_DEL
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_users table
    --       whith optimistic lock validation
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   |p_username | wdx_users.username%TYPE | must be NOT NULL
    --   | p_hash | HASH_T | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
    PROCEDURE web_del (
                      p_username IN wdx_users.username%TYPE,
                      p_hash IN varchar2
                      );

    /**
    --## Function Name: WEB_DEL_ROWID
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_users table
    --       whith optimistic lock validation, access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |P_ROWID | VARCHAR2(64)| must be NOT NULL
    --   | P_HASH | HASH_T | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|19-NOV-2015 16:08   | DBAX | Created
    */
    PROCEDURE web_del_rowid (p_rowid IN varchar2,p_hash IN varchar2);


    FUNCTION users_with_roles_tt (
                p_rolename IN wdx_users_roles.rolename%TYPE,
                p_appid IN wdx_users_roles.appid%TYPE 
               )
   RETURN wdx_users_tt
   PIPELINED;

   FUNCTION users_without_roles_tt (
                p_rolename IN wdx_users_roles.rolename%TYPE,
                p_appid IN wdx_users_roles.appid%TYPE
               )
   RETURN wdx_users_tt
   PIPELINED;


END tapi_wdx_users;
/

