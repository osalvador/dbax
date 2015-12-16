CREATE OR REPLACE PACKAGE BODY json_util_pkg
AS
   /*

   Purpose:    JSON utilities for PL/SQL

   Remarks:

   Who     Date        Description
   ------  ----------  -------------------------------------
   MBR     30.01.2010  Created

   */


   g_json_null_object CONSTANT   VARCHAR2 (20) := '{ }';


   FUNCTION get_xml_to_json_stylesheet
      RETURN VARCHAR2
   AS
   BEGIN
      /*

      Purpose:    return XSLT stylesheet for XML to JSON transformation

      Remarks:    see http://code.google.com/p/xml2json-xslt/

      Who     Date        Description
      ------  ----------  -------------------------------------
      MBR     30.01.2010  Created
      MBR     30.01.2010  Added fix for nulls

      */


      RETURN '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  Copyright (c) 2006, Doeke Zanstra
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer. Redistributions in binary 
  form must reproduce the above copyright notice, this list of conditions and the 
  following disclaimer in the documentation and/or other materials provided with 
  the distribution.

  Neither the name of the dzLib nor the names of its contributors may be used to 
  endorse or promote products derived from this software without specific prior 
  written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
  THE POSSIBILITY OF SUCH DAMAGE.
-->

  <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
  <xsl:strip-space elements="*"/>
  <!--contant-->
  <xsl:variable name="d">0123456789</xsl:variable>

  <!-- ignore document text -->
  <xsl:template match="text()[preceding-sibling::node() or following-sibling::node()]"/>

  <!-- string -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Main template for escaping strings; used by above template and for object-properties 
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
  <xsl:template name="escape-string">
    <xsl:param name="s"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <!-- Escape the backslash (\) before everything else. -->
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,''\'')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''\''),''\\'')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,''\'')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Escape the double quote ("). -->
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,''&quot;'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''&quot;''),''\&quot;'')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,''&quot;'')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Replace tab, line feed and/or carriage return by its matching escape code. Can''t escape backslash
       or double quote here, because they don''t replace characters (&#x0; becomes \t), but they prefix 
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be 
       processed first. This function can''t do that. -->
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,''&#x9;'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''&#x9;''),''\t'',substring-after($s,''&#x9;''))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,''&#xA;'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''&#xA;''),''\n'',substring-after($s,''&#xA;''))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,''&#xD;'')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,''&#xD;''),''\r'',substring-after($s,''&#xD;''))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- number (no support for javascript mantise) -->
  <xsl:template match="text()[not(string(number())=''NaN'')]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- boolean, case-insensitive -->
  <xsl:template match="text()[translate(.,''TRUE'',''true'')=''true'']">true</xsl:template>
  <xsl:template match="text()[translate(.,''FALSE'',''false'')=''false'']">false</xsl:template>

  <!-- item:null -->
  <xsl:template match="*[count(child::node())=0]">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="local-name()"/>
    </xsl:call-template>
    <xsl:text>:null</xsl:text>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">}</xsl:if> <!-- MBR 30.01.2010: added this line as it appeared to be missing from stylesheet --> 
  </xsl:template>

  <!-- object -->
  <xsl:template match="*" name="base">
    <xsl:if test="not(preceding-sibling::*)">{</xsl:if>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="name()"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <xsl:apply-templates select="child::node()"/>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">}</xsl:if>
  </xsl:template>

  <!-- array -->
  <xsl:template match="*[count(../*[name(../*)=name(.)])=count(../*) and count(../*)&gt;1]">
    <xsl:if test="not(preceding-sibling::*)">[</xsl:if>
    <xsl:choose>
      <xsl:when test="not(child::node())">
        <xsl:text>null</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="child::node()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">]</xsl:if>
  </xsl:template>
  
  <!-- convert root element to an anonymous container -->
  <xsl:template match="/">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
    
</xsl:stylesheet>';
   END get_xml_to_json_stylesheet;


   FUNCTION ref_cursor_to_json (p_ref_cursor   IN sys_refcursor
                              , p_max_rows     IN NUMBER:= NULL
                              , p_skip_rows    IN NUMBER:= NULL)
      RETURN CLOB
   AS
      l_ctx           DBMS_XMLGEN.ctxhandle;
      l_num_rows      PLS_INTEGER;
      l_xml           XMLTYPE;
      l_json          XMLTYPE;
      l_returnvalue   CLOB;
   BEGIN
      /*

      Purpose:    generate JSON from REF Cursor

      Remarks:

      Who     Date        Description
      ------  ----------  -------------------------------------
      MBR     30.01.2010  Created

      */

      l_ctx       := DBMS_XMLGEN.newcontext (p_ref_cursor);

      DBMS_XMLGEN.setnullhandling (l_ctx, DBMS_XMLGEN.empty_tag);

      -- for pagination

      IF p_max_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setmaxrows (l_ctx, p_max_rows);
      END IF;

      IF p_skip_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setskiprows (l_ctx, p_skip_rows);
      END IF;

      -- get the XML content
      l_xml       := DBMS_XMLGEN.getxmltype (l_ctx, DBMS_XMLGEN.none);

      l_num_rows  := DBMS_XMLGEN.getnumrowsprocessed (l_ctx);

      DBMS_XMLGEN.closecontext (l_ctx);

      CLOSE p_ref_cursor;

      IF l_num_rows > 0
      THEN
         -- perform the XSL transformation
         l_json      := l_xml.transform (xmltype (get_xml_to_json_stylesheet));
         l_returnvalue := l_json.getclobval ();
      ELSE
         l_returnvalue := g_json_null_object;
      END IF;

      l_returnvalue := DBMS_XMLGEN.CONVERT (l_returnvalue, DBMS_XMLGEN.entity_decode);

      RETURN l_returnvalue;
   END ref_cursor_to_json;


   FUNCTION sql_to_json (p_sql            IN VARCHAR2
                       , p_param_names    IN t_str_array:= NULL
                       , p_param_values   IN t_str_array:= NULL
                       , p_max_rows       IN NUMBER:= NULL
                       , p_skip_rows      IN NUMBER:= NULL)
      RETURN CLOB
   AS
      l_ctx           DBMS_XMLGEN.ctxhandle;
      l_num_rows      PLS_INTEGER;
      l_xml           XMLTYPE;
      l_json          XMLTYPE;
      l_returnvalue   CLOB;
   BEGIN
      /*

      Purpose:    generate JSON from SQL statement

      Remarks:

      Who     Date        Description
      ------  ----------  -------------------------------------
      MBR     30.01.2010  Created
      MBR     28.07.2010  Handle null value in bind variable value (issue and solution reported by Matt Nolan)

      */


      l_ctx       := DBMS_XMLGEN.newcontext (p_sql);

      DBMS_XMLGEN.setnullhandling (l_ctx, DBMS_XMLGEN.empty_tag);

      -- bind variables, if any
      IF p_param_names IS NOT NULL
      THEN
         FOR i IN 1 .. p_param_names.COUNT
         LOOP
            DBMS_XMLGEN.setbindvalue (l_ctx, p_param_names (i), NVL (p_param_values (i), ''));
         END LOOP;
      END IF;

      -- for pagination

      IF p_max_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setmaxrows (l_ctx, p_max_rows);
      END IF;

      IF p_skip_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setskiprows (l_ctx, p_skip_rows);
      END IF;

      -- get the XML content
      l_xml       := DBMS_XMLGEN.getxmltype (l_ctx, DBMS_XMLGEN.none);

      l_num_rows  := DBMS_XMLGEN.getnumrowsprocessed (l_ctx);

      DBMS_XMLGEN.closecontext (l_ctx);

      -- perform the XSL transformation
      IF l_num_rows > 0
      THEN
         l_json      := l_xml.transform (xmltype (get_xml_to_json_stylesheet));
         l_returnvalue := l_json.getclobval ();
         l_returnvalue := DBMS_XMLGEN.CONVERT (l_returnvalue, DBMS_XMLGEN.entity_decode);
      ELSE
         l_returnvalue := g_json_null_object;
      END IF;

      RETURN l_returnvalue;
   END sql_to_json;
   
 FUNCTION get_xml_to_json_stylesheet_2
      RETURN VARCHAR2
   AS
   BEGIN
      /*

      Purpose:    return XSLT stylesheet for XML to JSON transformation 2008 version

      Remarks:    see https://github.com/doekman/xml2json-xslt 

      Who     Date        Description
      ------  ----------  -------------------------------------
      OSM     16.12.2015  Created
      OSM     16.12.2015  Always consider array data

      */


      RETURN q'[<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  Copyright (c) 2006,2008 Doeke Zanstra
  All rights reserved.
  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:
  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer. Redistributions in binary
  form must reproduce the above copyright notice, this list of conditions and the
  following disclaimer in the documentation and/or other materials provided with
  the distribution.
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
  THE POSSIBILITY OF SUCH DAMAGE.
-->

  <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
    <xsl:strip-space elements="*"/>
  <!--contant-->
  <xsl:variable name="d">0123456789</xsl:variable>

  <!-- ignore document text -->
  <xsl:template match="text()[preceding-sibling::node() or following-sibling::node()]"/>

  <!-- string -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- Main template for escaping strings; used by above template and for object-properties
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
  <xsl:template name="escape-string">
    <xsl:param name="s"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- Escape the backslash (\) before everything else. -->
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'\')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,'\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Escape the double quote ("). -->
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'&quot;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Replace tab, line feed and/or carriage return by its matching escape code. Can't escape backslash
       or double quote here, because they don't replace characters (&#x0; becomes \t), but they prefix
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be
       processed first. This function can't do that. -->
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,'&#x9;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,'&#xA;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,'&#xD;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- number (no support for javascript mantissa) -->
  <xsl:template match="text()[not(string(number())='NaN' or
                       (starts-with(.,'0' ) and . != '0'))]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- boolean, case-insensitive -->
  <xsl:template match="text()[translate(.,'TRUE','true')='true']">true</xsl:template>
  <xsl:template match="text()[translate(.,'FALSE','false')='false']">false</xsl:template>

  <!-- object -->
  <xsl:template match="*" name="base">
    <xsl:if test="not(preceding-sibling::*)">{</xsl:if>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="name()"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <!-- check type of node -->
    <xsl:choose>
      <!-- null nodes -->
      <xsl:when test="count(child::node())=0">null</xsl:when>
      <!-- other nodes -->
      <xsl:otherwise>
          <xsl:apply-templates select="child::node()"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- end of type check -->
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">}</xsl:if>
  </xsl:template>

  <!-- array -->
  <!-- Original line Oscar Updated
      <xsl:template match="*[count(../*[name(../*)=name(.)])=count(../*) and count(../*)&gt;1]">-->  
   <xsl:template match="*[count(../*[name(../*)=name(.)])=count(../*) and count(../*)&gt;0]">
    <xsl:if test="not(preceding-sibling::*)">[</xsl:if>
    <xsl:choose>
      <xsl:when test="not(child::node())">
        <xsl:text>null</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="child::node()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::*">,</xsl:if>
    <xsl:if test="not(following-sibling::*)">]</xsl:if>
  </xsl:template>

  <!-- convert root element to an anonymous container -->
  <xsl:template match="/">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

</xsl:stylesheet>]';
   END get_xml_to_json_stylesheet_2;  
   
 
    FUNCTION ref_cursor_to_json_2 (p_ref_cursor    IN sys_refcursor
                                 , p_max_rows      IN NUMBER:= NULL
                                 , p_skip_rows     IN NUMBER:= NULL
                                 , p_format_type   IN VARCHAR2:= json_object
                                 , p_object_name   IN VARCHAR2:= 'data')
       RETURN CLOB
    AS
       l_ctx           DBMS_XMLGEN.ctxhandle;
       l_num_rows      PLS_INTEGER;
       l_xml           XMLTYPE;
       l_json          XMLTYPE;
       l_returnvalue   CLOB;
       --
       l_tmp_clob      CLOB;
    BEGIN
       /*
       Purpose:    generate JSON from REF Cursor as object data or JSON_LIST (array) data values
       Remarks:

       Who     Date        Description
       ------  ----------  -------------------------------------       
       MBR     30.01.2010  Created
       OSM     16.12.2015  Using new XSLT and root object name
       */

       l_ctx       := DBMS_XMLGEN.newcontext (p_ref_cursor);

       DBMS_XMLGEN.setnullhandling (l_ctx, DBMS_XMLGEN.empty_tag);

       -- for pagination

       IF p_max_rows IS NOT NULL
       THEN
          DBMS_XMLGEN.setmaxrows (l_ctx, p_max_rows);
       END IF;

       IF p_skip_rows IS NOT NULL
       THEN
          DBMS_XMLGEN.setskiprows (l_ctx, p_skip_rows);
       END IF;

       -- get the XML content
       l_xml       := DBMS_XMLGEN.getxmltype (l_ctx, DBMS_XMLGEN.none);

       l_num_rows  := DBMS_XMLGEN.getnumrowsprocessed (l_ctx);

       DBMS_XMLGEN.closecontext (l_ctx);

       CLOSE p_ref_cursor;

       IF l_num_rows > 0
       THEN
          -- perform the XSL transformation
          l_tmp_clob  := l_xml.transform (xmltype (get_xml_to_json_stylesheet_2)).getclobval ();

          --Delete exrta brackets from data
          DBMS_LOB.createtemporary (l_returnvalue, FALSE, DBMS_LOB.call);
          DBMS_LOB.COPY (l_returnvalue
                       , l_tmp_clob
                       , LENGTH (l_tmp_clob) - 2
                       , 1
                       , 2);

          IF p_format_type = JSON_OBJECT
          THEN
              --Add object name
             l_returnvalue := '{"' || p_object_name || '": ' || l_returnvalue || ' }';
          END IF;
       ELSE
          l_returnvalue := g_json_null_object;
       END IF;

       l_returnvalue := DBMS_XMLGEN.CONVERT (l_returnvalue, DBMS_XMLGEN.entity_decode);

       RETURN l_returnvalue;
    END ref_cursor_to_json_2;

   FUNCTION sql_to_json_2 (p_sql            IN VARCHAR2
                         , p_param_names    IN t_str_array:= NULL
                         , p_param_values   IN t_str_array:= NULL
                         , p_max_rows       IN NUMBER:= NULL
                         , p_skip_rows      IN NUMBER:= NULL
                         , p_format_type    IN VARCHAR2:= JSON_OBJECT
                         , p_object_name    IN VARCHAR2:= 'data')
      RETURN CLOB
   AS
      l_ctx           DBMS_XMLGEN.ctxhandle;
      l_num_rows      PLS_INTEGER;
      l_xml           XMLTYPE;      
      l_returnvalue   CLOB;
      --
       l_tmp_clob      CLOB;
   BEGIN
      /*
      Purpose:    generate JSON from SQL statement as object data or JSON_LIST (array) data values
      Remarks:
      Who     Date        Description
      ------  ----------  -------------------------------------
      MBR     30.01.2010  Created
      MBR     28.07.2010  Handle null value in bind variable value (issue and solution reported by Matt Nolan)
      OSM     16.12.2015  Using new XSLT and root object name
      */

      l_ctx       := DBMS_XMLGEN.newcontext (p_sql);

      DBMS_XMLGEN.setnullhandling (l_ctx, DBMS_XMLGEN.empty_tag);

      -- bind variables, if any
      IF p_param_names IS NOT NULL
      THEN
         FOR i IN 1 .. p_param_names.COUNT
         LOOP
            DBMS_XMLGEN.setbindvalue (l_ctx, p_param_names (i), NVL (p_param_values (i), ''));
         END LOOP;
      END IF;

      -- for pagination

      IF p_max_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setmaxrows (l_ctx, p_max_rows);
      END IF;

      IF p_skip_rows IS NOT NULL
      THEN
         DBMS_XMLGEN.setskiprows (l_ctx, p_skip_rows);
      END IF;

      -- get the XML content
      l_xml       := DBMS_XMLGEN.getxmltype (l_ctx, DBMS_XMLGEN.none);

      l_num_rows  := DBMS_XMLGEN.getnumrowsprocessed (l_ctx);

      DBMS_XMLGEN.closecontext (l_ctx);

      -- perform the XSL transformation
      IF l_num_rows > 0
      THEN
         l_tmp_clob      := l_xml.transform (xmltype (get_xml_to_json_stylesheet_2)).getclobval();
         
         --Delete exrta brackets from data
          DBMS_LOB.createtemporary (l_returnvalue, FALSE, DBMS_LOB.call);
          DBMS_LOB.COPY (l_returnvalue
                       , l_tmp_clob
                       , LENGTH (l_tmp_clob) - 2
                       , 1
                       , 2);

          IF p_format_type = JSON_OBJECT
          THEN
              --Add object name
             l_returnvalue := '{"' || p_object_name || '": ' || l_returnvalue || ' }';
          END IF;
         
         l_returnvalue := DBMS_XMLGEN.CONVERT (l_returnvalue, DBMS_XMLGEN.entity_decode);
      ELSE
         l_returnvalue := g_json_null_object;
      END IF;

      RETURN l_returnvalue;
   END sql_to_json_2;      

END json_util_pkg;
/