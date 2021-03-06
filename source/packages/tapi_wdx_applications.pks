--
-- TAPI_WDX_APPLICATIONS  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   WDX_APPLICATIONS (Table)
--
CREATE OR REPLACE PACKAGE tapi_wdx_applications
IS
   /**
   -- # TAPI_wdx_applications
   -- Generated by: tapiGen2 - DO NOT MODIFY!
   -- Website: github.com/osalvador/tapiGen2
   -- Created On: 16-SEP-2015 09:43
   -- Created By: DBAX
   */

   --Scalar/Column types
   SUBTYPE hash_t IS varchar2 (40);
   SUBTYPE appid IS wdx_applications.appid%TYPE;
   SUBTYPE name IS wdx_applications.name%TYPE;
   SUBTYPE description IS wdx_applications.description%TYPE;
   SUBTYPE active IS wdx_applications.active%TYPE;
   SUBTYPE access_control IS wdx_applications.access_control%TYPE;
   SUBTYPE auth_scheme IS wdx_applications.auth_scheme%TYPE;
   SUBTYPE created_by IS wdx_applications.created_by%TYPE;
   SUBTYPE created_date IS wdx_applications.created_date%TYPE;
   SUBTYPE modified_by IS wdx_applications.modified_by%TYPE;
   SUBTYPE modified_date IS wdx_applications.modified_date%TYPE;

   --Record type
   TYPE wdx_applications_rt
   IS
      RECORD (
            appid wdx_applications.appid%TYPE,
            name wdx_applications.name%TYPE,
            description wdx_applications.description%TYPE,
            active wdx_applications.active%TYPE,
            access_control wdx_applications.access_control%TYPE,
            auth_scheme wdx_applications.auth_scheme%TYPE,
            created_by wdx_applications.created_by%TYPE,
            created_date wdx_applications.created_date%TYPE,
            modified_by wdx_applications.modified_by%TYPE,
            modified_date wdx_applications.modified_date%TYPE,
            hash               hash_t,
            row_id            VARCHAR2(64)
      );
   --Collection types (record)
   TYPE wdx_applications_tt IS TABLE OF wdx_applications_rt;

   --Global exceptions
   e_ol_check_failed EXCEPTION; --Optimistic lock check failed
   e_row_missing     EXCEPTION; --The cursor failed to get a row
   e_upd_failed      EXCEPTION; --The update operation failed
   e_del_failed      EXCEPTION; --The delete operation failed

    /**
    --## Function Name: HASH
    --### Description:
    --       This function generates a SHA1 hash for optimistic locking purposes.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_appid | wdx_applications.appid%TYPE | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   FUNCTION hash (
                  p_appid IN wdx_applications.appid%TYPE
                 )
    RETURN VARCHAR2;

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
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   FUNCTION hash_rowid (p_rowid IN varchar2)
   RETURN varchar2;

    /**
    --## Function Name: RT
    --### Description:
    --       This is a table encapsulation function designed to retrieve information from the wdx_applications table.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_appid | wdx_applications.appid%TYPE | must be NOT NULL

    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |     | wdx_applications_rt |  wdx_applications Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   FUNCTION rt (
                p_appid IN wdx_applications.appid%TYPE 
               )
    RETURN wdx_applications_rt RESULT_CACHE;

   /**
    --## Function Name: RT_FOR_UPDATE
    --### Description:
    --       This is a table encapsulation function designed to retrieve information
             from the wdx_applications table while placing a lock on it for a potential
             update/delete. Do not use this for updates in web based apps, instead use the
             rt_for_web_update function to get a FOR_WEB_UPDATE_RT record which
             includes all of the tables columns along with an md5 checksum for use in the
             web_upd and web_del procedures.
    --
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |p_appid | wdx_applications.appid%TYPE | must be NOT NULL
    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |     | wdx_applications_rt |  wdx_applications Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   FUNCTION rt_for_update (
                          p_appid IN wdx_applications.appid%TYPE 
                          )
    RETURN wdx_applications_rt RESULT_CACHE;

    /**
    --## Function Name: TT
    --### Description:
    --       This is a table encapsulation function designed to retrieve information from the wdx_applications table.
    --       This function return Record Table as PIPELINED Function
    --
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  |p_appid | wdx_applications.appid%TYPE | must be NOT NULL
    --### Return
    --  | Name | Type | Description
    --  | -- | -- | --
    --  |     | wdx_applications_tt |  wdx_applications Table Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   FUNCTION tt (
                p_appid IN wdx_applications.appid%TYPE DEFAULT NULL
               )
   RETURN wdx_applications_tt
   PIPELINED;

     /**
    --## Function Name: INS
    --### Description:
    --      This is a table encapsulation function designed to insert a row into the wdx_applications table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_applications_rec | wdx_applications_rt| wdx_applications Record Type
    --### Return
    --    | Name | Type | Description
    --    | -- | -- | --
    --    | p_wdx_applications_rec | wdx_applications_rt |  wdx_applications Record Type
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE ins (p_wdx_applications_rec IN OUT wdx_applications_rt);

    /**
    --## Function Name: UPD
    --### Description:
    --     his is a table encapsulation function designed to update a row in the wdx_applications table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_applications_rec | wdx_applications_rt| wdx_applications Record Type
    --   | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE upd (p_wdx_applications_rec IN wdx_applications_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: UPD_ROWID
    --### Description:
    --     his is a table encapsulation function designed to update a row in the wdx_applications table,
           access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   | p_wdx_applications_rec | wdx_applications_rt| wdx_applications Record Type
    --   | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE upd_rowid (p_wdx_applications_rec IN wdx_applications_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: WEB_UPD
    --### Description:
    --      This is a table encapsulation function designed to update a row
            in the wdx_applications table whith optimistic lock validation
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  | p_wdx_applications_rec | wdx_applications_rt| wdx_applications Record Type
    --  | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE web_upd (p_wdx_applications_rec IN wdx_applications_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: WEB_UPD_ROWID
    --### Description:
    --      This is a table encapsulation function designed to update a row
            in the wdx_applications table whith optimistic lock validation
            access directly to the row by rowid
    --### IN Paramters
    --  | Name | Type | Description
    --  | -- | -- | --
    --  | p_wdx_applications_rec | wdx_applications_rt| wdx_applications Record Type
    --  | p_ignore_nulls | BOOLEAN | IF TRUE then null values are ignored in the update
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE web_upd_rowid (p_wdx_applications_rec IN wdx_applications_rt, p_ignore_nulls IN boolean := FALSE);

    /**
    --## Function Name: DEL
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_applications table.
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
--   |p_appid | wdx_applications.appid%TYPE | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
   PROCEDURE del (
                  p_appid IN wdx_applications.appid%TYPE
                );

    /**
    --## Function Name: DEL_ROWID
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_applications table.
             Access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |P_ROWID | VARCHAR2(64)| must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
    PROCEDURE del_rowid (p_rowid IN VARCHAR2);

    /**
    --## Function Name: WEB_DEL
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_applications table
    --       whith optimistic lock validation
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --   |p_appid | wdx_applications.appid%TYPE | must be NOT NULL
    --   | p_hash | HASH_T | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
    PROCEDURE web_del (
                      p_appid IN wdx_applications.appid%TYPE,
                      p_hash IN varchar2
                      );

    /**
    --## Function Name: WEB_DEL_ROWID
    --### Description:
    --       This is a table encapsulation function designed to delete a row from the wdx_applications table
    --       whith optimistic lock validation, access directly to the row by rowid
    --### IN Paramters
    --    | Name | Type | Description
    --    | -- | -- | --
    --    |P_ROWID | VARCHAR2(64)| must be NOT NULL
    --   | P_HASH | HASH_T | must be NOT NULL
    --### Amendments
    --| When         | Who                      | What
    --|--------------|--------------------------|------------------
    --|16-SEP-2015 09:43   | DBAX | Created
    */
    PROCEDURE web_del_rowid (p_rowid IN varchar2,p_hash IN varchar2);

END tapi_wdx_applications;
/


