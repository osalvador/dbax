--
-- DBAX_UTILS  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   DBMS_UTILITY (Synonym)
--   DBAX_CORE (Package)
--
CREATE OR REPLACE PACKAGE      dbax_utils
AS
   FUNCTION get (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_clob (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN CLOB;

   /**
   * Get indexed array from associative array paramter 
   * Example:
   *    From: p_array('colors[1]') = 'red'
   *          p_array('colors[2]') = 'blue'
   *          p_array('colors[3]') = 'black'
   *    To:
   *          r_array(1) = 'red'
   *          r_array(2) = 'blue'
   *          r_array(3) = 'black'
   *
   * @param  p_arra      the associative array with values with index [1], [2]...
   * @param  p_name      the name of the parameter
   * @return             the indexed array 
   */   
   FUNCTION get_array (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN DBMS_UTILITY.maxname_array;

   FUNCTION query_string_to_array (p_url             IN VARCHAR2
                                 , p_delimiter       IN VARCHAR2 DEFAULT NULL
                                 , p_key_delimiter   IN VARCHAR2 DEFAULT NULL )
      RETURN dbax_core.g_assoc_array;

   FUNCTION array_to_query_string (p_array           IN dbax_core.g_assoc_array
                                 , p_delimiter       IN VARCHAR2 DEFAULT NULL
                                 , p_key_delimiter   IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2;

   /**
     --## Function Name: TOKENIZER
     --### Description:
     --        Breaking up a string into tokens which are seperated by delimiters. The returned value is an array
     --
     --### IN Paramters
     --   | Name | Type | Description
     --   | -- | -- | --
     --   | p_string | VARCHAR2 | String to tokenizer
     --   | p_delimiter | VARCHAR2 | Optional delimiter token, default is comma ','
     --
     --### Amendments
     --| When         | Who                      | What
     --|--------------|--------------------------|------------------
     --|13/03/2015    | Oscar Salvador Magallanes | Creation
     */
   FUNCTION tokenizer (p_string IN VARCHAR2, p_delimiter IN VARCHAR2 DEFAULT ',' )
      RETURN DBMS_UTILITY.maxname_array;
END dbax_utils;
/


