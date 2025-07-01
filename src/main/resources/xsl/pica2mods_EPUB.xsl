<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="p xalan fn">
  <xsl:import href="pica2mods_common.xsl" />
  <xsl:variable name="XSL_VERSION_EPUB" select="concat('pica2mods_EPUB.xsl from ',$XSL_VERSION_PICA2MODS)" />
  
  <xsl:template match="/p:record" mode="EPUB">
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <mods:recordInfo>
      <xsl:for-each select="./p:datafield[@tag='017C']/p:subfield[@code='u']"> <!-- 4950 (kein eigenes Feld) -->
        <xsl:if test="contains(., '//purl.')">
          <mods:recordIdentifier source="DE-28">
            <xsl:value-of select="substring-after(substring(.,9), '/')" />
          </mods:recordIdentifier>
        </xsl:if>
        
      </xsl:for-each>
      <xsl:if test="./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
        <mods:descriptionStandard>rda</mods:descriptionStandard>
      </xsl:if>
      <mods:recordOrigin>
        <xsl:value-of select="normalize-space(concat('Converted from PICA to MODS using ',$XSL_VERSION_EPUB))" />
      </mods:recordOrigin>
    </mods:recordInfo>

    <xsl:for-each select="./p:datafield[@tag='017C']/p:subfield[@code='u']"> <!-- 4950 (kein eigenes Feld) -->
      <xsl:if test="contains(., '//purl.')">
        <mods:identifier type="purl">
          <xsl:value-of select="./text()" />
        </mods:identifier>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='003@']">
      <mods:identifier type="PPN">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004U']">
      <mods:identifier type="urn">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004V']">
      <mods:identifier type="doi">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004A']/p:subfield[@code='0']">
      <mods:identifier type="isbn"> <!-- 2000, ISBN-10 -->
        <xsl:value-of select="." />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004A']/p:subfield[@code='A']"> <!-- vermutlich nur in Altdaten -->
      <mods:identifier type="isbn"> <!-- 2000, ISBN-13 -->
        <xsl:value-of select="." />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004P']/p:subfield[@code='0']"> <!-- ISBN einer anderen Ausgabe (z.B. printISBN) -->
      <mods:identifier type="isbn"> <!-- 2000, ISBN-13 -->
        <xsl:value-of select="." />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(., 'ROSDOK_MD:openaire:')]"> <!-- ISBN einer anderen Ausgabe (z.B. printISBN) -->
      <mods:identifier type="openaire"> <!-- 2000, ISBN-13 -->
        <xsl:value-of select="substring(., 20)" />
      </mods:identifier>
    </xsl:for-each>

    <xsl:call-template name="COMMON_PersonalName" />
    <xsl:call-template name="COMMON_CorporateName" />

    <xsl:choose>
      <!-- Add test for 021A. Inferred Title is only necessary if no main Title is present. -->
      <xsl:when test="($pica0500_2='f' or $pica0500_2='F') and not(./p:datafield[@tag='021A'])">
        <xsl:for-each select="./p:datafield[@tag='036C']">
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$pica0500_2='v' and ./p:datafield[@tag='027D']">
        <xsl:for-each select="./p:datafield[@tag='027D']">
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="./p:datafield[@tag='021A']">
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <!-- ToDo: Titel fingiert, wenn kein Titel in 4000 -->

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

    <xsl:for-each select="./p:datafield[@tag='039B']"> <!-- 4241 übergeordnetes Werk -->
      <xsl:call-template name="COMMON_ArticleParent" />
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='036D']"> <!-- 4160 übergeordnetes Werk -->
      <xsl:call-template name="COMMON_HostOrSeries">
        <xsl:with-param name="type" select="'host'" />
      </xsl:call-template>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='036F']"> <!-- 4180 Schriftenreihe -->
      <xsl:call-template name="COMMON_HostOrSeries">
        <xsl:with-param name="type" select="'series'" />
      </xsl:call-template>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='039P']"> <!-- 4261 RezensiertesWerk -->
      <xsl:call-template name="COMMON_Review" />
    </xsl:for-each>

    <mods:originInfo eventType="publication"> <!-- 4030 033A -->
      <xsl:if test="./p:datafield[@tag='033A']/p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
        <mods:publisher>
          <xsl:value-of select="./p:datafield[@tag='033A']/p:subfield[@code='n']" />
        </mods:publisher>
      </xsl:if>
      <xsl:if test="./p:datafield[@tag='033A']/p:subfield[@code='p']">  <!-- 4030 Ort, Verlag -->
        <mods:place>
          <mods:placeTerm type="text">
            <xsl:value-of select="./p:datafield[@tag='033A']/p:subfield[@code='p']" />
          </mods:placeTerm>
        </mods:place>
      </xsl:if>

      <xsl:for-each select="./p:datafield[@tag='032@']"> <!-- 4020 Ausgabe -->
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='c']">
            <mods:edition>
              <xsl:value-of select="./p:subfield[@code='a']" />
              /
              <xsl:value-of select="./p:subfield[@code='c']" />
            </mods:edition>
          </xsl:when>
          <xsl:otherwise>
            <mods:edition>
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:edition>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:call-template name="COMMON_dateIssued" />

      <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='f']">  <!-- 4204 Hochschulschriftenvermerk, Jahr der Verteidigung -->
        <mods:dateOther type="defence" encoding="iso8601">
          <xsl:value-of select="./p:datafield[@tag='037C']/p:subfield[@code='f']" />
        </mods:dateOther>
      </xsl:if>

      <xsl:for-each select="./p:datafield[@tag='002@']">
        <xsl:choose>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='a'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='b'">
            <mods:issuance>serial</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='c'">
            <mods:issuance>multipart monograph</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='d'">
            <mods:issuance>serial</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='f'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='F'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='j'">
            <mods:issuance>single unit</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='s'">
            <mods:issuance>single unit</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='v'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </mods:originInfo>
    <xsl:if test="./p:datafield[@tag='033E']">
      <mods:originInfo eventType="online_publication"> <!-- 4034 -->
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='n']">  <!-- 4034 $n Verlag -->
          <mods:publisher>
            <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='n']" />
          </mods:publisher>
        </xsl:if>
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='p']">  <!-- 4034 $p Ort -->
          <mods:place>
            <mods:placeTerm type="text">
              <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='p']" />
            </mods:placeTerm>
          </mods:place>
        </xsl:if>
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='h']">  <!-- 4034 $h Jahr -->
          <mods:dateCaptured encoding="iso8601">
            <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='h']" />
          </mods:dateCaptured>
        </xsl:if>
      </mods:originInfo>
    </xsl:if>

    <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], 'rosdok')][1]">
      <mods:location>
        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
        <mods:url usage="primary" access="object in context">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], 'digibib.hs-nb.de')][1]">
      <mods:location>
        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/21162078316">Hochschulbibliothek Neubrandenburg</mods:physicalLocation>
        <mods:url usage="primary" access="object in context">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a' and contains(., 'Seite')]">
      <mods:physicalDescription>
        <mods:extent unit="pages">
          <xsl:value-of select="normalize-space(substring-before(substring-after(.,'('),'Seite'))" />
        </mods:extent>
      </mods:physicalDescription>
    </xsl:for-each>

    <xsl:call-template name="EPUB_SDNB">
      <xsl:with-param name="pica" select="." />
    </xsl:call-template>
    <xsl:call-template name="COMMON_CLASS" />
    <xsl:call-template name="COMMON_ABSTRACT" />
    <xsl:call-template name="COMMON_Location" />
    
    <xsl:for-each select="./p:datafield[@tag='030F']">
      <xsl:call-template name="COMMON_Conference" />
    </xsl:for-each>
    
    <xsl:for-each select="./p:datafield[@tag='037A']"><!-- Gutachter in Anmerkungen -->
      <xsl:choose>
        <xsl:when test="starts-with(./p:subfield[@code='a'], 'GutachterInnen:')">
          <mods:note type="referee">
            <xsl:value-of select="substring-after(./p:subfield[@code='a'], 'GutachterInnen: ')" />
          </mods:note>
        </xsl:when>
        <xsl:otherwise>
          <mods:note type="other">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:note>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4226 (einfach den ganzen Anmerkungskrams mitnehmen" -->
      <mods:note type="other">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='047C' or @tag='022A']">
      <!-- 4200 (047C, abweichende Sucheinstiege, RDA zusätzlich:3210 (022A, Werktitel) und 3260 (027A, abweichender Titel) -->
      <mods:note type="titlewordindex">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

  </xsl:template>

  <xsl:template name="EPUB_SDNB">
    <xsl:param name="pica" />
    <xsl:for-each select="document(concat($mycoreRestAPIBaseURL ,'classifications/SDNB'))//category">
      <xsl:if test="$pica/p:datafield[@tag='045F']/p:subfield[@code='a'] = ./@ID">
        <xsl:element name="mods:classification">
          <xsl:attribute name="authorityURI"><xsl:value-of select="concat($WebApplicationBaseURL,'classifications/SDNB')" /></xsl:attribute>
          <xsl:attribute name="valueURI"><xsl:value-of select="concat($WebApplicationBaseURL,'classifications/SDNB#', ./@ID)" /></xsl:attribute>
          <xsl:attribute name="displayLabel">sdnb</xsl:attribute>
          <xsl:value-of select="./label[@xml:lang='de']/@text" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet> 