<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="p xalan fn">
  <xsl:import href="pica2mods_common.xsl" />

  <xsl:variable name="XSL_VERSION_RDA" select="concat('pica2mods_RDA.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="RDA">
    <xsl:variable name="ppnA" select="./p:datafield[@tag='039I']/p:subfield[@code='9'][1]/text()" />
    <xsl:variable name="zdbA" select="./p:datafield[@tag='039I']/p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]/text()" />
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:if test="$ppnA">
      <mods:note type="PPN-A">
        <xsl:value-of select="$ppnA" />
      </mods:note>
    </xsl:if>
    <mods:recordInfo>
      <mods:recordIdentifier source="DE-28">
        <xsl:value-of select="concat('rosdok/ppn',./p:datafield[@tag='003@']/p:subfield[@code='0'])" />
      </mods:recordIdentifier>
      <mods:recordIdentifier source="DE-601">
        <xsl:value-of select="./p:datafield[@tag='003@']/p:subfield[@code='0']" />
      </mods:recordIdentifier>
      <mods:descriptionStandard>rda</mods:descriptionStandard>
      <mods:recordOrigin>
        <xsl:value-of select="normalize-space(concat('Converted from PICA to MODS using ',$XSL_VERSION_RDA))" />
      </mods:recordOrigin>
    </mods:recordInfo>

    <xsl:call-template name="COMMON_Identifier" />
    <xsl:call-template name="COMMON_PersonalName" />
    <xsl:call-template name="COMMON_CorporateName" />

    <!-- Titel fingiert, wenn kein Titel in 4000 -->
    <xsl:choose>
      <!-- Add test for 021A. Inferred Title is only nesessary if no main Title is present. -->
      <xsl:when test="($pica0500_2='f' or $pica0500_2='F') and not(./p:datafield[@tag='021A'])">
        <xsl:for-each select="./p:datafield[@tag='036C']"><!-- 4150 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$pica0500_2='v' and ./p:datafield[@tag='036F']">
        <xsl:for-each select="./p:datafield[@tag='0036F']"><!-- 4180 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="./p:datafield[@tag='021A']"> <!-- 4000 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="COMMON_Alt_Uniform_Title" />
    <xsl:call-template name="COMMON_Language" />

    <xsl:for-each select="./p:datafield[@tag='039B']"> <!-- 4241 übergeordnetes Werk -->
      <xsl:call-template name="COMMON_ArticleParent" />
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='036D']"> <!-- 4160 übergeordnetes Werk -->
      <xsl:call-template name="COMMON_HostOrSeries">
        <xsl:with-param name="type" select="'host'" />
      </xsl:call-template>
    </xsl:for-each>

    <!--Unterscheidung nach 0500 2. Pos: wenn 'v' dann type->host, sonst type->series -->
    <xsl:for-each select="./p:datafield[@tag='036F']"> <!-- 4180 Schriftenreihe + Zeitschrift -->
      <xsl:choose>
        <xsl:when test="$pica0500_2='v'">
          <xsl:call-template name="COMMON_HostOrSeries">
            <xsl:with-param name="type">
              host
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="COMMON_HostOrSeries">
            <xsl:with-param name="type">
              series
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='039P']"> <!-- 4261 RezensiertesWerk -->
      <xsl:call-template name="COMMON_Review" />
    </xsl:for-each>

    <!-- ToDo: 2. If für Ob-Stufen: Wenn keine ppnA und 0500 2. Pos ='b', dann originInfo[@eventtype='creation'] aus O-Aufnahmen-Feldern: bei RDA-Aufnahmen keine A-PPN im Pica vorhanden -> Daten aus Expansion 
      nehmen ggf. per ZDB-ID die SRU-Schnittstelle anfragen - publisher aus 039I $e - placeTerm aus 039I $d - datesissued aus 039I $f - issuance -> Konstante "serial" - physicalDescription -> wie unten (variable 
      nicht vergessen!) -->

    <xsl:if test="not($pica0500_2='v')">

      <xsl:variable name="query">
        <xsl:choose>
          <xsl:when test="$ppnA">
            <xsl:value-of select="concat('sru-gvk:pica.ppn=', $ppnA)" />
          </xsl:when>
          <xsl:when test="$zdbA">
            <xsl:value-of select="concat('sru-gvk:pica.zdb=', $zdbA)" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="picaA" select="document($query)" />

      <xsl:if test="$picaA">

        <!-- check use of eventtype attribute -->
        <!-- RDA: from A-Aufnahme -->
        <mods:originInfo eventType="creation">
          <xsl:for-each select="$picaA/p:record/p:datafield[@tag='033A']">
            <xsl:if test="./p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
              <mods:publisher>
                <xsl:value-of select="./p:subfield[@code='n']" />
              </mods:publisher>
            </xsl:if>
            <xsl:for-each select="./p:subfield[@code='p']">
              <mods:place>
                <mods:placeTerm type="text">
                  <xsl:value-of select="." />
                </mods:placeTerm>
              </mods:place>
            </xsl:for-each>
          </xsl:for-each>

          <!-- normierte Orte -->
          <xsl:for-each select="$picaA/p:record/p:datafield[@tag='033D']">
            <mods:place supplied="yes">
              <mods:placeTerm lang="ger" type="text">
                <xsl:choose>
                  <xsl:when test="./p:subfield[@code='8']">
                    <xsl:value-of select="./p:subfield[@code='8']" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="./p:subfield[@code='p']" />
                  </xsl:otherwise>
                </xsl:choose>
              </mods:placeTerm>
            </mods:place>
          </xsl:for-each>

          <xsl:for-each select="$picaA/p:record/p:datafield[@tag='011@']">
            <xsl:choose>
              <xsl:when test="./p:subfield[@code='b']">
                <mods:dateIssued keyDate="yes" encoding="iso8601" point="start">
                  <xsl:value-of select="./p:subfield[@code='a']" />
                </mods:dateIssued>
                <mods:dateIssued encoding="iso8601" point="end">
                  <xsl:value-of select="./p:subfield[@code='b']" />
                </mods:dateIssued>
                <xsl:if test="./p:subfield[@code='n']">
                  <mods:dateIssued qualifier="approximate">
                    <xsl:value-of select="./p:subfield[@code='n']" />
                  </mods:dateIssued>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="contains(./p:subfield[@code='a'], 'X')">
                    <mods:dateIssued keyDate="yes" encoding="iso8601" point="start">
                      <xsl:value-of select="translate(./p:subfield[@code='a'], 'X','0')" />
                    </mods:dateIssued>
                    <mods:dateIssued encoding="iso8601" point="end">
                      <xsl:value-of select="translate(./p:subfield[@code='a'], 'X', '9')" />
                    </mods:dateIssued>
                    <xsl:if test="./p:subfield[@code='n']">
                      <mods:dateIssued qualifier="approximate">
                        <xsl:value-of select="./p:subfield[@code='n']" />
                      </mods:dateIssued>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <mods:dateIssued keyDate="yes" encoding="iso8601">
                      <xsl:value-of select="./p:subfield[@code='a']" />
                    </mods:dateIssued>
                    <xsl:if test="./p:subfield[@code='n']">
                      <mods:dateIssued qualifier="approximate">
                        <xsl:value-of select="./p:subfield[@code='n']" />
                      </mods:dateIssued>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>

          <xsl:for-each select="$picaA/p:record/p:datafield[@tag='032@']"> <!-- 4020 Ausgabe -->
            <xsl:choose>
              <xsl:when test="./p:subfield[@code='h']">
                <mods:edition>
                  <xsl:value-of select="./p:subfield[@code='a']" />
                  /
                  <xsl:value-of select="./p:subfield[@code='h']" />
                </mods:edition>
              </xsl:when>
              <xsl:otherwise>
                <mods:edition>
                  <xsl:value-of select="./p:subfield[@code='a']" />
                </mods:edition>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>

          <xsl:for-each select="$picaA/p:record/p:datafield[@tag='002@']">
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
                <mods:issuance>serial</mods:issuance>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </mods:originInfo>

        <!--033J = 4033 Druckernormadaten, aber kein Ort angegeben (müsste aus GND gelesen werden) MODS unterstützt keine authorityURIs für Verlage deshalb 033A verwenden , RDA: Drucker-/Verlegernormdaten 
          oben erledigt in 3010/3110 mit entspr. Rollenbezeichnung -->

        <xsl:for-each select="./p:datafield[@tag='009A']"> <!-- 4065 Besitznachweis der Vorlage, RDA ok -->
          <mods:location>
            <xsl:if test="./p:subfield[@code='c']">
              <xsl:choose>
                <xsl:when test="./p:subfield[@code='c']='UB Rostock'">
                  <mods:physicalLocation type="current" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
                </xsl:when>
                <xsl:otherwise>
                  <mods:physicalLocation type="current">
                    <xsl:value-of select="./p:subfield[@code='c']" />
                  </mods:physicalLocation>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='a']">
              <mods:shelfLocator>
                <xsl:value-of select="./p:subfield[@code='a']" />
              </mods:shelfLocator>
            </xsl:if>
          </mods:location>
        </xsl:for-each>


        <xsl:variable name="digitalOrigin">
          <xsl:for-each select="./p:datafield[@tag='037H']/p:subfield[@code='a']">   <!-- 4238 Technische Angaben zum elektr. Dokument, RDA ok -->
            <xsl:if test="contains(., 'Digitalisierungsvorlage: Original')"> <!-- alt -->
              <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </xsl:if>
            <xsl:if test="contains(., 'Digitalisierungsvorlage: Primärausgabe')">
              <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </xsl:if>
            <xsl:if test="contains(., 'Digitalisierungsvorlage: Mikrofilm')">
              <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <!-- pysicalDescription RDA vorangig aus A-Aufnahme -->
        <xsl:choose>
          <xsl:when test="$picaA/p:record/p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
            <mods:physicalDescription>
              <xsl:for-each select="$picaA/p:record/p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten -->
                <mods:extent>
                  <xsl:value-of select="." />
                </mods:extent>
              </xsl:for-each>
              <xsl:for-each select="$picaA/p:record/p:datafield[@tag='034M']/p:subfield[@code='a']">   <!-- 4061 Illustrationen -->
                <mods:extent>
                  <xsl:value-of select="." />
                </mods:extent>
              </xsl:for-each>
              <xsl:for-each select="$picaA/p:record/p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe -->
                <mods:extent>
                  <xsl:value-of select="." />
                </mods:extent>
              </xsl:for-each>
              <xsl:for-each select="$picaA/p:record/p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial -->
                <mods:extent>
                  <xsl:value-of select="." />
                </mods:extent>
              </xsl:for-each>
              <xsl:copy-of select="$digitalOrigin" />
            </mods:physicalDescription>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="./p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
              <mods:physicalDescription>
                <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten -->
                  <mods:extent>
                    <xsl:value-of select="." />
                  </mods:extent>
                </xsl:for-each>
                <xsl:for-each select="./p:datafield[@tag='034M']/p:subfield[@code='a']">   <!-- 4061 Illustrationen -->
                  <mods:extent>
                    <xsl:value-of select="." />
                  </mods:extent>
                </xsl:for-each>
                <xsl:for-each select="./p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe -->
                  <mods:extent>
                    <xsl:value-of select="." />
                  </mods:extent>
                </xsl:for-each>
                <xsl:for-each select="./p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial -->
                  <mods:extent>
                    <xsl:value-of select="." />
                  </mods:extent>
                </xsl:for-each>
                <xsl:copy-of select="$digitalOrigin" />
              </mods:physicalDescription>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="$picaA/p:record/p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD, RDA aus A-Aufnahme -->
          <mods:genre type="aadgenre">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
        </xsl:for-each>
      </xsl:if> <!-- ENDE A-record -->
    </xsl:if>
    <!-- Wenn 0500 2. Pos ='v', dann originInfo[@eventtype='creation'] aus O-Aufnahmen-Feldern: - publisher und placeTerm nicht vorhanden (keine Av-Stufe vorhanden) - datesissued aus 011@ $r - issuance 
      -> Konstante "serial" - physicalDescription -->
    <xsl:if test="($pica0500_2='v')">
      <mods:originInfo eventType="creation">
        <xsl:if test="./p:datafield[@tag='011@']/p:subfield[@code='r']">
          <mods:dateIssued encoding="iso8601" keyDate="yes">
            <xsl:value-of select="./p:datafield[@tag='011@']/p:subfield[@code='r']" />
          </mods:dateIssued>
        </xsl:if>
        <xsl:for-each select="./p:datafield[@tag='032@']">
          <mods:edition>
            <xsl:value-of select="./p:subfield[@code='a']" />
            <xsl:if test="./p:subfield[@code='c']">
              /
              <xsl:value-of select="./p:subfield[@code='c']" />
            </xsl:if>
          </mods:edition>
        </xsl:for-each>
        <mods:issuance>serial</mods:issuance>
      </mods:originInfo>

      <mods:physicalDescription>
        <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten aus O-Aufnahme, Problem: "1 Online-Ressource (...)" -->
          <mods:extent>
            <xsl:value-of select="." />
          </mods:extent>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='037H']/p:subfield[@code='a']">   <!-- 4238 Technische Angaben zum elektr. Dokument, RDA ok -->
          <xsl:if test="contains(., 'Digitalisierungsvorlage: Original')"> <!-- alt -->
            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
          </xsl:if>
          <xsl:if test="contains(., 'Digitalisierungsvorlage: Primärausgabe')">
            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
          </xsl:if>
          <xsl:if test="contains(., 'Digitalisierungsvorlage: Mikrofilm')">
            <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
          </xsl:if>
        </xsl:for-each>
      </mods:physicalDescription>
    </xsl:if>


    <!-- mehrere digitalisierende Einrichtungen -->
    <!-- RS: mods:originInfo wiederholen oder wie jetzt mehrere Publisher/Orte aufsammeln? - Wir verlieren so die Beziehung publisher-ort -->
    <!-- Wechsel von eventType online_publication zu publication, da an diese Stelle noch keine Prüfung stattfand, ob es eine online Resource ist
         Gegebeispiel PPN:875796303 (Buch,rda)-->
    <!-- <mods:originInfo eventType="online_publication">  --><!-- 4030 -->
    <mods:originInfo eventType="publication">
      <xsl:for-each select="./p:datafield[@tag='033A']">
        <xsl:if test="./p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
          <mods:publisher>
            <xsl:value-of select="./p:subfield[@code='n']" />
          </mods:publisher>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='p']">  <!-- 4030 Ort, Verlag -->
          <mods:place>
            <mods:placeTerm type="text">
              <xsl:value-of select="./p:subfield[@code='p']" />
            </mods:placeTerm>
          </mods:place>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="//p:datafield[@tag='032@']/p:subfield[@code='a']">
        <mods:edition>
          <xsl:value-of select="//p:datafield[@tag='032@']/p:subfield[@code='a']" />
        </mods:edition>
      </xsl:if>
      
      <xsl:call-template name="COMMON_dateIssued"/>
      
      <!--  Uncommenting following code excpect DataCaptured in 011B not in 011@-->
      <!-- 1109, RDA 1100 011@ -->
      <!--  <xsl:for-each select="./p:datafield[@tag='011@']">   
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='b']">
            <mods:dateCaptured encoding="iso8601" keyDate="yes" point="start">
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:dateCaptured>
            <mods:dateCaptured encoding="iso8601" point="end">
              <xsl:value-of select="./p:subfield[@code='b']" />
            </mods:dateCaptured>
          </xsl:when>
          <xsl:otherwise>
            <mods:dateCaptured encoding="iso8601" keyDate="yes">
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:dateCaptured>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      -->
    </mods:originInfo>

    <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')][1]">
      <mods:location>
        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
        <mods:url usage="primary" access="object in context">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>

    <xsl:call-template name="COMMON_UBR_Class_Collection" />
    <xsl:call-template name="COMMON_Class_Doctype" />
    <xsl:call-template name="COMMON_CLASS" />
    <xsl:call-template name="COMMON_ABSTRACT" />
    <xsl:call-template name="COMMON_Location" />
    
    <xsl:for-each select="./p:datafield[@tag='030F']">
      <xsl:call-template name="COMMON_Conference" />
    </xsl:for-each>
    
    <xsl:for-each select="./p:datafield[@tag='037C']">
      <xsl:call-template name="COMMON_Thesis" />
    </xsl:for-each>
    
    <xsl:for-each select="./p:datafield[@tag='017H']"> <!-- 4961 URL für sonstige Angaben zur Resource -->
      <mods:note type="source note">
        <xsl:attribute name="xlink:href"><xsl:value-of select="./p:subfield[@code='u']" /></xsl:attribute>
        <xsl:value-of select="./p:subfield[@code='y']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='037G']">
      <mods:note type="reproduction">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='037A' or @tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I' or @tag='046P']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4225, 4226 (einfach den ganzen Anmerkungskrams mitnehmen" -->
      <mods:note type="source note">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='047C']">
      <!-- 4200 (047C, abweichende Sucheinstiege, RDA zusätzlich:3210 (022A, Werktitel) und 3260 (027A, abweichender Titel) -->
      <mods:note type="titlewordindex">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <!-- Vorgänger, Nachfolger Verknüpfung ZDB -->
    <xsl:if test="$pica0500_2='b'">
      <xsl:for-each select="./p:datafield[@tag='039E' and (./p:subfield[@code='b' and text()='f'] or ./p:subfield[@code='b'and text()='s'])]"><!-- 4244 -->
        <mods:relatedItem>
          <xsl:if test="./p:subfield[@code='b' and text()='f']">
            <xsl:attribute name="type">preceding</xsl:attribute>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='b' and text()='s']">
            <xsl:attribute name="type">succeeding</xsl:attribute>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='t']">
            <mods:titleInfo>
              <mods:title>
                <xsl:value-of select="./p:subfield[@code='t']" />
              </mods:title>
            </mods:titleInfo>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='C' and text()='ZDB']">
            <mods:identifier type="zdb">
              <xsl:value-of select="./p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
            </mods:identifier>
          </xsl:if>
        </mods:relatedItem>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet> 