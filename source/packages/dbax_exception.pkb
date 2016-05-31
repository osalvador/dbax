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

   FUNCTION get_error_source_code (p_errorbacktrace IN VARCHAR2, p_errorstack IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_code_line   PLS_INTEGER;
      l_owner       VARCHAR2 (31);
      l_name        VARCHAR2 (31);
      l_code        VARCHAR2 (32767);
      l_new_type    VARCHAR2 (31);
      l_old_type    VARCHAR2 (31);
   BEGIN
      -- Get Line of code
      l_code_line :=
         REGEXP_SUBSTR (p_errorbacktrace
                      , ', line (.*?)' || CHR (10)
                      , 1
                      , 1
                      , 'n'
                      , 1);
      l_owner     :=
         REGEXP_SUBSTR (p_errorbacktrace
                      , ' at "(.*?)\.'
                      , 1
                      , 1
                      , 'n'
                      , 1);
      l_name      :=
         REGEXP_SUBSTR (p_errorbacktrace
                      , ' at "' || l_owner || '\.(.*?)"'
                      , 1
                      , 1
                      , 'n'
                      , 1);


      --If the name is DBAX_TEPLSQL get view's compiled source
      IF l_name = 'DBAX_TEPLSQL'
      THEN
         l_code_line :=
            REGEXP_SUBSTR (p_errorstack
                         , 'line (\d*),'
                         , 1
                         , 1
                         , 'n'
                         , 1);

         l_code      := '<h3>View ' || dbax_core.g$view_name || '<small> compiled source code</small></h3>';
         l_code      :=
               l_code
            || '<pre class="prettyprint linenums:'
            || (l_code_line - 9)
            || '"><code class="language-sql">...'
            || CHR (10);

         FOR c1
         IN (SELECT   x.rn, x.compiled_source
               FROM   wdx_views t
                    , XMLTABLE ('/x/y' PASSING xmltype(REPLACE (   '<x><y>'
                                || DBMS_XMLGEN.CONVERT (t.compiled_source, 0)
                                || '</y></x>'
                                                              ,CHR (10)
                                                              ,'</y><y>')) COLUMNS rn FOR ORDINALITY, compiled_source
                                VARCHAR2 (4000) PATH '/y') x
              WHERE   t.name = dbax_core.g$view_name AND rn BETWEEN l_code_line - 8 AND l_code_line + 8)
         LOOP
            IF c1.rn = l_code_line
            THEN
               l_code      :=
                     l_code
                  || '<span class="operative">'
                  || DBMS_XMLGEN.CONVERT (c1.compiled_source, 0)
                  || ' </span>'
                  || CHR (10);
            ELSE
               l_code      := l_code || DBMS_XMLGEN.CONVERT (c1.compiled_source, 0) || CHR (10);
            END IF;
         END LOOP;

         l_code      := l_code || '...</code></pre>';
      ELSE
         FOR c1
         IN (  SELECT   *
                 FROM   all_source
                WHERE       name = l_name
                        AND owner = l_owner
                        AND line BETWEEN l_code_line - 8 AND l_code_line + 8
                        AND name <> 'DBAX_CORE'
             ORDER BY   TYPE, line)
         LOOP
            l_new_type  := c1.TYPE;

            IF l_new_type <> l_old_type OR l_old_type IS NULL
            THEN
               IF l_code IS NOT NULL
               THEN
                  l_code      := l_code || '...</code></pre>';
               END IF;

               l_code      := l_code || '<h3>' || c1.TYPE || ' <small> ' || l_owner || '.' || l_name || '</small></h3>';
               l_code      :=
                     l_code
                  || '<pre class="prettyprint linenums:'
                  || (l_code_line - 9)
                  || '"><code class="language-sql">...'
                  || CHR (10);
            END IF;

            IF c1.line = l_code_line
            THEN
               l_code      :=
                  l_code || '<span class="operative">' || REPLACE (c1.text, CHR (10)) || ' </span>' || CHR (10);
            ELSE
               l_code      := l_code || c1.text;
            END IF;

            l_old_type  := l_new_type;
         END LOOP;

         IF l_code IS NOT NULL
         THEN
            l_code      := l_code || '...</code></pre>';
         END IF;
      END IF;

      RETURN l_code;
   END get_error_source_code;


   PROCEDURE raise (p_error_code IN NUMBER, p_error_msg IN VARCHAR2)
   AS
      l_html_error     VARCHAR2 (32767);
      --
      l_wdx_views_rt   tapi_wdx_views.wdx_views_rt;
      l_log_id         PLS_INTEGER;
   BEGIN
      --TODO Error level Reporting like PHP
      dbax_log.open_log ('debug');
      dbax_core.g_stop_process := TRUE;

      dbax_core.g$view ('errorCode') := p_error_code;
      dbax_core.g$view ('errorMsg') := p_error_msg;

      dbax_core.g$view ('errorStack') :=
         '----- PL/SQL Error Stack -----' || CHR (10) || DBMS_UTILITY.format_error_stack ();
      dbax_core.g$view ('errorBacktrace') :=
         '----- PL/SQL Error Backtrace -----' || CHR (10) || DBMS_UTILITY.format_error_backtrace ();
      dbax_core.g$view ('callStack') := DBMS_UTILITY.format_call_stack ();

      dbax_log.error ('p_cod_error:' || p_error_code || ' p_msg_error:' || p_error_msg);
      dbax_log.error (dbax_core.g$view ('errorStack'));
      dbax_log.error (dbax_core.g$view ('errorBacktrace'));
      dbax_log.error (dbax_core.g$view ('callStack'));

      l_log_id    := dbax_log.close_log;

      dbax_core.g$view ('logId') := l_log_id;
      dbax_core.g$view ('code') :=
         get_error_source_code (dbax_core.g$view ('errorBacktrace'), dbax_core.g$view ('errorStack'));

      HTP.init;
      OWA_UTIL.mime_header ('text/html', FALSE, dbax_core.get_property ('ENCODING'));
      OWA_UTIL.status_line (500);
      OWA_UTIL.http_header_close;

      BEGIN
         l_wdx_views_rt := tapi_wdx_views.rt (dbax_core.g$appid, '5000');
         dbax_teplsql.execute (p_template_name => '500');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_html_error :=
               q'[<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="content-type" content="text/html; charset=UTF-8">
      <meta charset="utf-8">
      <title>dbax Exception</title>
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
      <!-- Latest compiled and minified CSS -->
      <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
      <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
      <![endif]-->    
       <style>.operative { font-weight: bold; border:1px solid red }</style>
   </head>
   <body>
      <header class="navbar navbar-default navbar-static-top" role="banner">
         <div class="container">
            <div class="navbar-header">
               <a href="http://dbax.io" class="navbar-brand">dbax exception: 500 Internal Server Error</a>
            </div>
         </div>
      </header>
      <!-- Begin Body -->
      <div class="container">
         <div class="row">
            <div class="col-md-12">
               <h1 class="text-danger text-center"><b>Error 500. Internal Server Error (${logId})</b></h1>
                <br>
               <h4 class="text-center">There is a problem with the resource you are looking for, and it cannot be displayed. <code id="http_referer"></code></h4>
               <h4 class="text-center">Contact your administrator with details of the action you performed before error occured with this log id: ${logId}</h4>
               <% if '${500_error_style}' = 'DebugStyle' then %> 
               <hr>
               <h2 id="userError">User Error</h2>
               <pre class="prettyprint"><code class="language-sql">Error Code: ${errorCode}</code></pre>
               <pre class="prettyprint"><code class="language-sql">${errorMsg}</code></pre>
               <hr>
               <h2 id="errorStack">Error Stack</h2>               
               <pre class="prettyprint"><code class="language-sql">${errorStack}</code></pre>
               <hr>
               <h2 id="errorBacktrace">Error Backtrace</h2>
               <pre class="prettyprint"><code class="language-sql">${errorBacktrace}</code></pre>              
               <hr>
               <h2 id="callStack">Call Stack</h2>
               <pre class="prettyprint"><code class="language-sql">${callStack}</code></pre>
               <hr>              
               <h2 id="code">Code</h2>               
               ${code}
              <hr>
              <% end if; %>
            </div>
         </div>
      </div>
      <!-- script references -->
      <script src="http://code.jquery.com/jquery-1.11.2.min.js"></script>
      <!-- Latest compiled and minified JavaScript -->
      <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
      <script type="text/javascript">
          document.getElementById("http_referer").innerHTML = window.location.pathname;       
       </script>      
      <script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js?lang=sql&amp;skin=sons-of-obsidian"></script>
   </body>
</html>]';
            dbax_teplsql.execute (p_template => l_html_error);
      END;
   END raise;
END dbax_exception;
/