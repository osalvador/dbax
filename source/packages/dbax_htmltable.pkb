CREATE OR REPLACE PACKAGE BODY dbax_htmltable
AS
   FUNCTION refcursor2html (p_cursor        IN sys_refcursor
                          , p_table_id      IN VARCHAR2 DEFAULT NULL
                          , p_table_class   IN VARCHAR2 DEFAULT NULL
                          , p_thead         IN BOOLEAN DEFAULT TRUE )
      RETURN CLOB
   IS
      lretval       CLOB;
      lhtmloutput   XMLTYPE;
      lxsl          CLOB;
      lxmldata      XMLTYPE;

      lcontext      DBMS_XMLGEN.ctxhandle;
   BEGIN
      -- get a handle on the ref cursor --
      lcontext    := DBMS_XMLGEN.newcontext (refcursor2html.p_cursor);
      -- setNullHandling to 2 to allow null columns to be displayed --
      DBMS_XMLGEN.setnullhandling (lcontext, 2);
      -- create XML from ref cursor --
      lxmldata    := DBMS_XMLGEN.getxmltype (lcontext, DBMS_XMLGEN.none);

      -- this is a generic XSL for Oracle's default XML row and rowset tags --
      -- " " is a non-breaking space --
      lxsl        := lxsl || q'[<?xml version="1.0" encoding="UTF-8"?>]';
      lxsl        := lxsl || q'[<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">]';
      lxsl        := lxsl || q'[ <xsl:output method="html"/>]';
      lxsl        := lxsl || q'[ <xsl:template match="@*|node()">]';

      IF refcursor2html.p_thead
      THEN
         lxsl        :=
               lxsl
            || '    <table class="'
            || refcursor2html.p_table_class
            || '" id="'
            || refcursor2html.p_table_id
            || '">';
         lxsl        := lxsl || q'[     <thead>]';
         lxsl        := lxsl || q'[      <tr >]';
         lxsl        := lxsl || q'[       <xsl:for-each select="/ROWSET/ROW[1]/*">]';
         lxsl        := lxsl || q'[        <th><xsl:value-of select="name()"/></th>]';
         lxsl        := lxsl || q'[       </xsl:for-each>]';
         lxsl        := lxsl || q'[      </tr>]';
         lxsl        := lxsl || q'[     </thead> ]';
      END IF;

      lxsl        := lxsl || q'[     <tbody>]';
      lxsl        := lxsl || q'[     <xsl:for-each select="/ROWSET/*">]';
      lxsl        := lxsl || q'[      <tr>]';
      lxsl        := lxsl || q'[       <xsl:for-each select="./*">]';
      lxsl        := lxsl || q'[        <td> <xsl:copy-of select="@* |node()"/> </td>]';
      lxsl        := lxsl || q'[       </xsl:for-each>]';
      lxsl        := lxsl || q'[      </tr>]';
      lxsl        := lxsl || q'[     </xsl:for-each>]';
      lxsl        := lxsl || q'[     </tbody> ]';

      IF refcursor2html.p_thead
      THEN
         lxsl        := lxsl || q'[   </table>]';
      END IF;

      lxsl        := lxsl || q'[ </xsl:template>]';
      lxsl        := lxsl || q'[</xsl:stylesheet>]';


      --Escape html content
      lxmldata    := xmltype (DBMS_XMLGEN.CONVERT (lxmldata.getclobval (), 1));

      -- XSL transformation to convert XML to HTML --
      lhtmloutput := lxmldata.transform (xmltype (lxsl));
      -- convert XMLType to Clob --
      lretval     := lhtmloutput.getclobval ();
      --lretval       := lxmldata.getclobval();

      RETURN lretval;
   EXCEPTION
      WHEN OTHERS
      THEN
         dbax_log.error (SQLERRM || DBMS_UTILITY.format_error_backtrace ());
         RETURN NULL;
   END refcursor2html;
END dbax_htmltable;
/