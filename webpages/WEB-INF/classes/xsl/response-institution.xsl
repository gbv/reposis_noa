<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:xalan="http://xml.apache.org/xalan" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xalan i18n encoder">
  &html-output;
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="response-utils.xsl" />
  <xsl:include href="xslInclude:solrResponse" />

  <xsl:param name="WebApplicationBaseURL" />

  <xsl:variable name="PageTitle">
    <xsl:value-of select="i18n:translate('component.solr.searchresult.resultList')" />
  </xsl:variable>

    <xsl:variable name="linkTo">
      <xsl:value-of select="concat($ServletsBaseURL,'solr/find?qry=')" />
    </xsl:variable>

  <xsl:template match="/response">

    <div class="row">
      <div id="main_content" class="col-md-12">

        <h2><xsl:value-of select="i18n:translate('noa.filter.organizations')" /></h2>

        <xsl:if test="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.nameByRole.corporate.pbl']/int">
          <ul class="cbList">
            <xsl:for-each select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.nameByRole.corporate.pbl']/int">
              <li>
                <span class="cbNum">[<xsl:value-of select="." />]</span>
                <a href="{$linkTo}+mods.nameByRole.corporate.pbl:%22{@name}%22"><xsl:value-of select="@name" /></a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>

        <xsl:if test="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='topic']/int">
          <ul class="cbList">
            <xsl:for-each select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='topic']/int">
              <li>
                <span class="cbNum">[<xsl:value-of select="." />]</span>
                <a href="{$linkTo}+topic:%22{@name}%22"><xsl:value-of select="@name" /></a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>

      </div>
    </div>

  </xsl:template>

</xsl:stylesheet>