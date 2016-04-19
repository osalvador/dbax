--
-- DBAX_EXCEPTION  (Package Body)
--

CREATE OR REPLACE PACKAGE BODY dbax_exception
AS
   FUNCTION call_stack2html_table (p_call_stack IN VARCHAR2 DEFAULT NULL , p_table_attr IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   AS
      l_call_stack   VARCHAR2 (4096) := p_call_stack;
      n              NUMBER;
      found_stack    BOOLEAN DEFAULT FALSE ;
      line           VARCHAR2 (255);

      handler        VARCHAR2 (1000);
      object_name    VARCHAR2 (1000);
      lineno         PLS_INTEGER;
      tbody          VARCHAR2 (32000);
   BEGIN
      IF l_call_stack IS NULL
      THEN
         l_call_stack := DBMS_UTILITY.format_call_stack;
      END IF;

      --
      LOOP
         n           := INSTR (l_call_stack, CHR (10));
         EXIT WHEN (n IS NULL OR n = 0);

         --
         IF n <> 0
         THEN
            line        := SUBSTR (l_call_stack, 1, n - 1);
            l_call_stack := SUBSTR (l_call_stack, n + 1);
         ELSE
            --last line
            line        := l_call_stack;
         END IF;

         --
         IF (NOT found_stack)
         THEN
            IF (line LIKE '%handle%number%name%')
            THEN
               found_stack := TRUE;
            END IF;
         ELSE
            handler     := SUBSTR (line, 1, INSTR (line, ' '));
            lineno      := TO_NUMBER (SUBSTR (line, INSTR (line, ' '), 10));
            object_name := SUBSTR (line, 22);

            tbody       :=
               tbody || '<tr><td>' || handler || '</td><td>' || lineno || '</td><td>' || object_name || '</td></tr>';
         END IF;
      END LOOP;

      RETURN '<table ' || p_table_attr
             || '>
                  <tdead>
                     <tr>
                        <td>object handle</td>
                        <td>line number</td>
                        <td>object name</td>
                     </tr>
                  </tdead>
                  <tbody> '
             || tbody
             || '                  
                  </tbody>
               </table>';
   END call_stack2html_table;

   PROCEDURE raise (p_error_code IN NUMBER, p_error_msg IN VARCHAR2)
   AS
      v_html    CLOB;
      v_dummy   INTEGER;
   BEGIN
      --TODO Error level Reporting like PHP
      dbax_core.g_stop_process := TRUE;

      dbax_core.g$view ('errorCode') := p_error_code;
      dbax_core.g$view ('errorMsg') := p_error_msg;

      dbax_core.g$view ('callStackTable') :=
         call_stack2html_table (p_call_stack => DBMS_UTILITY.format_call_stack ()
                              , p_table_attr => 'class="table table-striped table-condensed table-bordered"');

      dbax_core.g$view ('errorStack') := DBMS_UTILITY.format_error_stack ();
      dbax_core.g$view ('errorBacktrace') := DBMS_UTILITY.format_error_backtrace ();

      dbax_log.error ('raise: ' || g$error ('errorCode'));
      dbax_log.error ('raise: ' || g$error ('errorMsg'));
      dbax_log.error ('raise: ' || DBMS_UTILITY.format_call_stack ());
      dbax_log.error ('raise: ' || g$error ('errorStack'));
      dbax_log.error ('raise: ' || g$error ('errorBacktrace'));

      HTP.init;
      OWA_UTIL.mime_header ('text/html', FALSE, dbax_core.get_property ('ENCODING'));
      OWA_UTIL.status_line (500);
      OWA_UTIL.http_header_close;

      dbax_teplsql.execute (p_template_name => '500');
   END raise;
END dbax_exception;
/