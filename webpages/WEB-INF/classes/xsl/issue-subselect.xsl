<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to search for related objects -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:encoder="xalan://java.net.URLEncoder" exclude-result-prefixes="xsl xalan i18n encoder"
>
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:param name="RequestURL" />

  <xsl:variable name="PageID" select="'select-relatedItem'" />

  <xsl:variable name="PageTitle" select="'Bitte wählen Sie eine Zeitschrift aus.'" />

  <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="20">

    <p>
      Bitte wählen Sie nachstehend die Zeitschrift aus, zu der Sie ein Zeitschriftenheft anlegen wollen:
    </p>
    <ul>
      <xsl:apply-templates select="arr[@name='groups']/lst[str/@name='groupValue']" mode="subselect" />
    </ul>
  </xsl:template>

  <xsl:template match="lst" mode="subselect">
    <xsl:variable name="id" select="str[@name='groupValue']" />
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($WebApplicationBaseURL,'editor/editor-dynamic.xed?genre=issue')" />
          <xsl:value-of select="concat('&amp;parentId=',encoder:encode($id,'UTF-8'))" />
        </xsl:attribute>
        <xsl:value-of select="result/doc/arr[@name='mods.title']/str" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
