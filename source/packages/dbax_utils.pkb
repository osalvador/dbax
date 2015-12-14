--
-- DBAX_UTILS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY      dbax_utils
AS
   FUNCTION get (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN VARCHAR2
   AS
   BEGIN
      IF p_array.EXISTS (p_name)
      THEN
         RETURN p_array (p_name);
      ELSE
         RETURN NULL;
      END IF;
   END get;

   FUNCTION get_clob (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN CLOB
   AS
      l_clob       CLOB;
      l_tmp_clob   CLOB;
   BEGIN
      FOR i IN 0 .. 10000 --Max number of parameters
      LOOP
         IF p_array.EXISTS (p_name || i)
         THEN
            l_tmp_clob  := p_array (p_name || i);
            l_clob      := l_clob || l_tmp_clob;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      RETURN l_clob;
   END get_clob;

   FUNCTION get_array (p_array dbax_core.g_assoc_array, p_name IN VARCHAR2)
      RETURN DBMS_UTILITY.maxname_array
   AS
      l_result   DBMS_UTILITY.maxname_array;

      i          PLS_INTEGER := 1;
   BEGIN
      WHILE TRUE
      LOOP
         IF p_array.EXISTS (p_name || '[' || i || ']')
         THEN
            l_result (i) := p_array (p_name || '[' || i || ']');
            i           := i + 1;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      RETURN l_result;
   END get_array;


   FUNCTION query_string_to_array (p_url             IN VARCHAR2
                                 , p_delimiter       IN VARCHAR2 DEFAULT NULL
                                 , p_key_delimiter   IN VARCHAR2 DEFAULT NULL )
      RETURN dbax_core.g_assoc_array
   AS
      l_string             VARCHAR2 (4000) := p_url;
      l_delimiter          VARCHAR2 (5) := NVL (p_delimiter, '&');
      l_keydelimiter       VARCHAR2 (5) := NVL (p_key_delimiter, '=');
      l_delimiter_length   NUMBER (5) := LENGTH (l_delimiter);
      l_start              NUMBER (5) := 1;
      l_end                NUMBER (5) := 0;
      --
      l_new                VARCHAR2 (4000);
      l_keyvalue           VARCHAR2 (4000);
      l_key                VARCHAR2 (4000);
      l_value              VARCHAR2 (4000);
      --
      l_assoc_array        dbax_core.g_assoc_array;
   BEGIN
      IF SUBSTR (l_string, -1, 1) <> l_delimiter
      THEN
         l_string    := l_string || l_delimiter;
      END IF;

      l_new       := l_string;

      LOOP
         l_end       := INSTR (l_new, l_delimiter, 1);
         l_keyvalue  := SUBSTR (l_new, 1, l_end - 1);
         l_key       := SUBSTR (l_keyvalue, 1, INSTR (l_keyvalue, l_keydelimiter) - 1);
         l_value     := SUBSTR (l_keyvalue, INSTR (l_keyvalue, l_keydelimiter) + 1);
         EXIT WHEN l_keyvalue IS NULL;

         IF l_key IS NOT NULL
         THEN
            l_assoc_array (l_key) := utl_url.unescape (l_value);
         ELSE
            l_assoc_array (l_value) := NULL;
         END IF;

         l_start     := l_start + (l_end + (l_delimiter_length - 1));
         l_new       := SUBSTR (l_string, l_start);
      END LOOP;

      RETURN l_assoc_array;
   --Print Associative array
   /*l_key       := l_table.FIRST;

   LOOP
      EXIT WHEN l_key IS NULL;
      DBMS_OUTPUT.put_line (l_key || '=' || l_table (l_key));
      l_key       := l_table.NEXT (l_key);
   END LOOP;*/
   END query_string_to_array;

   FUNCTION array_to_query_string (p_array           IN dbax_core.g_assoc_array
                                 , p_delimiter       IN VARCHAR2 DEFAULT NULL
                                 , p_key_delimiter   IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
      l_key            VARCHAR2 (4000);
      l_string         VARCHAR2 (4000);
      l_delimiter      VARCHAR2 (5) := NVL (p_delimiter, '&');
      l_keydelimiter   VARCHAR2 (5) := NVL (p_key_delimiter, '=');
   BEGIN
      l_key       := p_array.FIRST;

      LOOP
         EXIT WHEN l_key IS NULL;

         l_string    := l_string || l_key || l_keydelimiter || utl_url.escape (p_array (l_key), TRUE) || l_delimiter;
         l_key       := p_array.NEXT (l_key);
      END LOOP;

      RETURN l_string;
   END array_to_query_string;

   FUNCTION tokenizer (p_string IN VARCHAR2, p_delimiter IN VARCHAR2 DEFAULT ',' )
      RETURN DBMS_UTILITY.maxname_array
   AS
      l_array   DBMS_UTILITY.maxname_array;
   BEGIN
          SELECT   REGEXP_SUBSTR (p_string
                                , '[^' || p_delimiter || ']+'
                                , 1
                                , LEVEL)
            BULK   COLLECT
            INTO   l_array
            FROM   DUAL
      CONNECT BY   REGEXP_SUBSTR (p_string
                                , '[^' || p_delimiter || ']+'
                                , 1
                                , LEVEL) IS NOT NULL;

      RETURN l_array;
   END tokenizer;
END dbax_utils;
/


