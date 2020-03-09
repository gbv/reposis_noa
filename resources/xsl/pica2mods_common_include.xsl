<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">  
  
  <xsl:template name="COMMON_UBR_Class_Doctype">
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document(concat($mycoreRestAPIBaseURL, 'classifications/doctype'))//category[./label[@xml:lang='x-pica-0500-2']]">
        <xsl:if
          test="$pica4110 = translate(./label[@xml:lang='x-pica-4110']/@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ') and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/doctype</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/doctype#', ./@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">doctype</xsl:attribute>
            <xsl:value-of select="./label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_SHBIB_Class_Doctype">
    <xsl:variable name="pica0500_1" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:choose>
      <xsl:when test="contains('a',$pica0500_2) and $pica0500_1='A'">
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#book"/>
      </xsl:when>
      <xsl:otherwise>
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#{$pica0500_2}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COMMON_MIR_Class_Collection">
    <!-- to Do -->
  </xsl:template>
  
  <xsl:template name="COMMON_Class_Doctype">
    <xsl:call-template name="COMMON_SHBIB_Class_Doctype" />
  </xsl:template>
  
  <xsl:template name="COMMON_ROSTOCK_CLASS">
      <!-- ToDoKlassifikationen aus 209O/01 $a mappen -->
    <xsl:for-each select="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:'))]">
      <xsl:variable name="class_url" select="concat($mycoreRestAPIBaseURL, 'classifications/', substring-before(substring-after(current(),':'),':'))" />
      <xsl:variable name="class_doc" select="document($class_url)" />
      <xsl:variable name="categid" select="substring-after(substring-after(current(),':'),':')" />
      <xsl:if test="$class_doc//category[@ID=$categid]">
        <xsl:element name="mods:classification">
          <xsl:attribute name="authorityURI"><xsl:value-of select="$class_doc/mycoreclass/label[@xml:lang='x-uri']/@text" /></xsl:attribute>
          <xsl:attribute name="valueURI"><xsl:value-of select="concat($class_doc/mycoreclass/label[@xml:lang='x-uri']/@text,'#', $categid)" /></xsl:attribute>
          <xsl:attribute name="displayLabel"><xsl:value-of select="$class_doc/mycoreclass/@ID" /></xsl:attribute>
          <xsl:value-of select="$class_doc//category[@ID=$categid]/label[@xml:lang='de']/@text" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
    <xsl:choose>
    <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:doctype:epub')]">
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
        <mods:classification displayLabel="accesscondition" authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition" valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
      </xsl:if>
    </xsl:when>
    <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:doctype:epub')]">
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:metadata')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:deposit')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:work')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:accesscondition:openaccess')])">
        <mods:classification displayLabel="accesscondition" authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition" valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!-- default:  'ROSDOK:doctype:histbest' -->
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:digitisedimages')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#digitisedimages.cclicense.cc-by-sa.v40">Lizenz Digitalisate: CC BY SA 4.0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.publicdomain">gemeinfrei</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.publicdomain">gemeinfrei</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
        <mods:classification displayLabel="accesscondition" authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition" valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
      </xsl:if>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COMMON_MIR_CLASS">
    <!-- Doesn't know general Information from 209O -->
  </xsl:template>
  
  <xsl:template name="COMMON_CLASS">
    <xsl:call-template name="COMMON_MIR_CLASS" />
  </xsl:template>
  
  <xsl:template name="COMMON_ROSTOCK_Language">
    <xsl:for-each select="./p:datafield[@tag='010@']"> <!-- 1500 Language -->
      <!-- weiter Unterfelder für Orginaltext / Zwischenübersetzung nicht abbildbar -->
      <xsl:for-each select="./p:subfield[@code='a']">
        <mods:language>
          <mods:languageTerm type="code" authority="iso639-2b">
            <xsl:value-of select="." />
          </mods:languageTerm>
        </mods:language>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_MIR_Language">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc4646')" />
    <xsl:for-each select="./p:datafield[@tag='010@']"> <!-- 1500 Language -->
      <!-- weiter Unterfelder für Orginaltext / Zwischenübersetzung nicht abbildbar -->
      <xsl:for-each select="./p:subfield[@code='a']">
        <xsl:variable name="biblCode" select="." />
        <xsl:variable name="rfcCode">
          <xsl:value-of select="$languages//category[label[@xml:lang='x-bibl']/@text = $biblCode]/@ID" />
        </xsl:variable>
        <mods:language>
          <mods:languageTerm authority="rfc4646" type="code">
            <xsl:value-of select="$rfcCode"/>
          </mods:languageTerm>
          <mods:languageTerm type="code" authority="iso639-2b">
            <xsl:value-of select="$biblCode" />
          </mods:languageTerm>
        </mods:language>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_Language">
    <xsl:call-template name="COMMON_MIR_Language" />
  </xsl:template>
  
  <!-- Nicht gewünschte URNs und DOI sollten in einer zweiten Stufe entfernt werden.
  <xsl:for-each select="./p:datafield[@tag='004U' and contains(./p:subfield[@code='0'], 'urn:nbn:de:gbv:28')]"> --><!-- 2050 -->
  <!--     <mods:identifier type="urn"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
    </xsl:for-each> 
    <xsl:for-each select="./p:datafield[@tag='004V' and contains(./p:subfield[@code='0'], '/10.18453/')]"> --> <!-- 2051 -->
  <!--     <mods:identifier type="doi"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
    </xsl:for-each> -->
   
</xsl:stylesheet>