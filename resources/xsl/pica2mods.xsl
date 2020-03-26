<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">
  <xsl:import href="pica2mods_EPUB.xsl" />
  <xsl:import href="pica2mods_KXP.xsl" />
  <xsl:import href="pica2mods_RDA.xsl" /> 
  <xsl:variable name="XSL_VERSION_PICA2MODS">pica2mods-xslt v1.4.0</xsl:variable>
  <!-- <xsl:output method="xml" encoding="UTF-8" indent="yes" />  -->
  <xsl:param name="WebApplicationBaseURL">http://rosdok.uni-rostock.de/</xsl:param>
  <xsl:param name="parentId" /> <!-- to do editor, could be obsolete -->
  <xsl:variable name="pica2mods_version">Pica2MODS 20190122</xsl:variable>
  <xsl:variable name="mycoreRestAPIBaseURL" select="concat($WebApplicationBaseURL,'api/v1/')" />
  <xsl:template match="/p:record">
    
    <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" version="3.6"
      xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
      <xsl:choose>
        <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(.,':doctype:epub')]">
          <xsl:apply-templates mode="EPUB" select="." />
        </xsl:when>
        <xsl:when test="./p:datafield[@tag='007G']/p:subfield[@code='i']/text()='KXP'">
          <xsl:apply-templates mode="KXP" select="." />
        </xsl:when>
        <xsl:when test="not(./p:datafield[@tag='011B']) and ./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
          <xsl:apply-templates mode="RDA" select="." />
        </xsl:when>
        <xsl:otherwise>
      
          <!-- früher: RAK -->
       
          <xsl:apply-templates mode="KXP" select="." />
        </xsl:otherwise>
      </xsl:choose>
    </mods:mods> 
  </xsl:template>
  
</xsl:stylesheet>