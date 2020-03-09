<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="p xalan fn">
  <xsl:import href="pica2mods_common_include.xsl" />

  <xsl:variable name="MyCoRe_intern" select="'false'" />

  <xsl:template name="COMMON_Title">
    <mods:titleInfo>
      <xsl:attribute name="usage">primary</xsl:attribute>
      <xsl:if test="./p:subfield[@code='a']">
        <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
        <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort>
                  <xsl:value-of select="$nonSort" />
                </mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')" />
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title>
                  <xsl:value-of select="$mainTitle" />
                </mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title>
              <xsl:value-of select="$mainTitle" />
            </mods:title>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="./p:subfield[@code='d']">
        <mods:subTitle>
          <xsl:value-of select="./p:subfield[@code='d']" />
        </mods:subTitle>
      </xsl:if>

      <!-- nur in fingierten Titel 036C / 4150 -->
      <xsl:if test="./p:subfield[@code='y']">
        <mods:subTitle>
          <xsl:value-of select="./p:subfield[@code='y']" />
        </mods:subTitle>
      </xsl:if>

      <xsl:if test="./p:subfield[@code='l']">
        <mods:partNumber>
          <xsl:value-of select="./p:subfield[@code='l']" />
        </mods:partNumber>
      </xsl:if>

      <xsl:if test="@tag='036C' and ./../p:datafield[@tag='021A']">
        <xsl:if test="./../p:datafield[@tag='021A']/p:subfield[@code='a'] != '@'">
          <mods:partName>
            <xsl:value-of select="translate(./../p:datafield[@tag='021A']/p:subfield[@code='a'], '@', '')" />
          </mods:partName>
        </xsl:if>
      </xsl:if>
    </mods:titleInfo>

    <xsl:if test="./../p:datafield[@tag='021A' or @tag='036F']/p:subfield[@code='h']">
      <mods:note type="statement of responsibility">
        <xsl:value-of select="./../p:datafield[@tag='021A' or @tag='036F']/p:subfield[@code='h']" />
      </mods:note>
    </xsl:if>
  </xsl:template>

  <xsl:template name="COMMON_Alt_Uniform_Title">
    <!-- 3260/027A$a abweichender Titel, 4212/046C abweichender Titel, 4213/046D früherere Hauptitel 4002/021F Paralleltitel, 4000/021A$f Paralleltitel (RAK), 3210/022A Werktitel, 3232/026C Zeitschriftenkurztitel -->
    <xsl:for-each select="./p:datafield[@tag='027A' or @tag='021F' or @tag='046C' or @tag='046D']/p:subfield[@code='a'] | ./p:datafield[@tag='021A']/p:subfield[@code='f'] ">
      <mods:titleInfo type="alternative">
        <mods:title>
          <xsl:value-of select="translate(., '@', '')" />
        </mods:title>
      </mods:titleInfo>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='022A']">
      <mods:titleInfo type="uniform">
        <mods:title>
          <xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" />
        </mods:title>
      </mods:titleInfo>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='026C']">
      <mods:titleInfo type="abbreviated">
        <mods:title>
          <xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" />
        </mods:title>
      </mods:titleInfo>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_Parent_Identifier">

    <xsl:variable name="ppn" select="./p:subfield[@code='9']" />
    <xsl:if test="$ppn">
      <mods:identifier type="local">
        <xsl:value-of select="concat('(DE-601)',$ppn)" />
      </mods:identifier>
    </xsl:if>

    <!-- processing Identifier need an example with subfield C -->

    <!-- try to get ISSN ; to do multiple ISSN -->
    <xsl:for-each select="./p:subfield[@code='6' or @code='1']">
      <xsl:if test="translate(.,'0123456789X','_') = '____-____' ">
        <mods:identifier type="issn">
          <xsl:value-of select="." />
        </mods:identifier>
      </xsl:if>
    </xsl:for-each>

    <!-- try to get ZDBD-ID -->
    <xsl:for-each select="./p:subfield[@code='6' or @code='7']">
      <xsl:if test="starts-with(.,'zdb/')">
        <mods:identifier type="zdbd-id">
          <xsl:value-of select="." />
        </mods:identifier>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_HostOrSeries">
    <xsl:param name="type" />
    <mods:relatedItem>
      <!-- ToDo teilweise redundant mit title template -->
      <xsl:attribute name="type"><xsl:value-of select="normalize-space($type)" /></xsl:attribute>
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>

      <xsl:call-template name="COMMON_Parent_Identifier" />

      <xsl:if test="./p:subfield[@code='9']">
        <xsl:if test="not(normalize-space($type) = 'series')">
          <mods:recordInfo>
            <mods:recordIdentifier source="DE-28">
              <xsl:value-of select="concat('rosdok/ppn',./p:subfield[@code='9'])" />
            </mods:recordIdentifier>
            <mods:recordIdentifier source="DE-601">
              <xsl:value-of select="./p:subfield[@code='9']" />
            </mods:recordIdentifier>
          </mods:recordInfo>
          <mods:identifier type="purl">
            <xsl:value-of select="concat('http://purl.uni-rostock.de/rosdok/ppn', ./p:subfield[@code='9'])" />
          </mods:identifier>
          <xsl:if test="./../p:datafield[@tag='027D']/p:subfield[@code='z']">
            <mods:identifier type="zdb">
              <xsl:value-of select="./../p:datafield[@tag='027D']/p:subfield[@code='z']" />
            </mods:identifier>
          </xsl:if>
        </xsl:if>
        <xsl:if test="normalize-space($type) = 'series'">
          <mods:identifier type="PPN">
            <xsl:value-of select="./p:subfield[@code='9']" />
          </mods:identifier>
        </xsl:if>
      </xsl:if>

      <mods:part>
        <!-- set order attribute only if value of subfield $X is a number -->
        <xsl:if test="./p:subfield[@code='X']">
          <xsl:choose>
            <xsl:when test="contains(./p:subfield[@code='X'], ',')">
              <xsl:if test="number(substring-before(substring-before(./p:subfield[@code='X'], '.'), ','))">
                <xsl:attribute name="order">    
                  <xsl:value-of select="substring-before(substring-before(./p:subfield[@code='X'], '.'), ',')" />
				</xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="number(substring-before(./p:subfield[@code='X'], '.'))">
                <xsl:attribute name="order">
				  <xsl:value-of select="substring-before(./p:subfield[@code='X'], '.')" />
				</xsl:attribute>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>

        <!-- ToDo: type attribute: issue, volume, chapter, .... -->
        <xsl:if test="./p:subfield[@code='l']">
          <mods:detail type="volume">
            <mods:number>
              <!-- Switch from subfied l to X cause l is the textual representation. -->
              <xsl:value-of select="./p:subfield[@code='X']" />
            </mods:number>
          </mods:detail>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='x']">
          <mods:text type="sortstring">
            <xsl:value-of select="./p:subfield[@code='x']" />
          </mods:text>
        </xsl:if>
      </mods:part>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_ArticleParent">
    <!-- . is 039B in every case. ToDo transform to template match -->
    <mods:relatedItem>
      <!-- ToDo teilweise redundant mit title template -->
      <xsl:attribute name="type">host</xsl:attribute>
      <xsl:variable name="displayLabel" select="./p:subfield[@code='i']" />
      <xsl:if test="$displayLabel">
        <xsl:attribute name="displayLabel"><xsl:value-of select="$displayLabel" /></xsl:attribute>
      </xsl:if>
      <mods:titleInfo>
        <xsl:variable name="mainTitle" select="./p:subfield[@code='t']" />
        <!-- Switch from subfieldcode a to t -->
        <xsl:if test="$mainTitle">
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <!-- removed subfield d , d is place of publish -->
      </mods:titleInfo>

      <xsl:call-template name="COMMON_Parent_Identifier" />

      <xsl:variable name="publisher" select="./p:subfield[@code='e']" />
      <xsl:variable name="place" select="./p:subfield[@code='d']" />
      <xsl:if test="$publisher">
        <mods:originInfo type="publication">
          <mods:publisher>
            <xsl:value-of select="$publisher" />
          </mods:publisher>
          <mods:place>
            <xsl:value-of select="$place" />
          </mods:place>
        </mods:originInfo>
      </xsl:if>

      <xsl:variable name="dfield" select="." />
      <xsl:choose>
        <xsl:when test="./../p:datafield[@tag='031C']">
          <xsl:for-each select="./../p:datafield[@tag='031C']">
            <mods:part>
              <xsl:if test="$dfield/p:subfield[@code='x']">
                <xsl:attribute name="order">
                  <xsl:value-of select="substring($dfield/p:subfield[@code='x'],1,4)" />   
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="$dfield/p:subfield[@code='x']">
                <mods:text type="sortstring">
                  <xsl:value-of select="$dfield/p:subfield[@code='x']" />
                </mods:text>
              </xsl:if>
              <xsl:apply-templates select="./../p:datafield[@tag='031A']" /> <!-- 4070 -->
              <mods:text type="article series">
                <xsl:value-of select="concat(./p:subfield[@code='a'],' - ',./p:subfield[@code='y'])" />
              </mods:text>
            </mods:part>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <mods:part>
            <!-- ToDo make decision: Should we use Sortstring from subfield x. X is generated from 031A.   -->
            <xsl:if test="$dfield/p:subfield[@code='x']">
              <xsl:attribute name="order">
                <xsl:value-of select="substring($dfield/p:subfield[@code='x'],1,4)" />   
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="$dfield/p:subfield[@code='x']">
              <mods:text type="sortstring">
                <xsl:value-of select="$dfield/p:subfield[@code='x']" />
              </mods:text>
            </xsl:if>
            <xsl:apply-templates select="./../p:datafield[@tag='031A']" /> <!-- 4070 -->
          </mods:part>
        </xsl:otherwise>
      </xsl:choose>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_Review">
    <mods:relatedItem type="reviewOf">
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>
      <mods:identifier type="PPN">
        <xsl:value-of select="./p:subfield[@code='9']" />
      </mods:identifier>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_PersonalName">
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '028')]">
      <mods:name type="personal">
        <xsl:choose>
          <xsl:when test="$MyCoRe_intern='true' and ./p:subfield[@code='9']">
            <xsl:variable name="query" select="concat('unapi-gvk:gvk:ppn:', ./p:subfield[@code='9'])" />
            <xsl:variable name="tp" select="document($query)" />
            <mods:nameIdentifier type="gnd">
              <xsl:value-of select="$tp/p:record/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" />
            </mods:nameIdentifier>
            <xsl:if test="$tp/p:record/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']">
              <mods:nameIdentifier type="orcid">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']/p:subfield[@code='0']" />
              </mods:nameIdentifier>
            </xsl:if>

            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='d']">
              <mods:namePart type="given">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='d']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='a']">
              <mods:namePart type="family">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='a']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='P']">
              <mods:namePart type="family">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='P']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='c']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='c']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='n']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='n']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='l']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='l']" />
              </mods:namePart>
            </xsl:if>
            <xsl:for-each select="$tp/p:record/p:datafield[@tag='060R' and ./p:subfield[@code='4']='datl']">
              <xsl:if test="./p:subfield[@code='a']">
                <xsl:variable name="out_date">
                  <xsl:value-of select="./p:subfield[@code='a']" />
                  -
                  <xsl:value-of select="./p:subfield[@code='b']" />
                </xsl:variable>
                <mods:namePart type="date">
                  <xsl:value-of select="normalize-space($out_date)"></xsl:value-of>
                </mods:namePart>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='d']">
                <mods:namePart type="date">
                  <xsl:value-of select="./p:subfield[@code='d']"></xsl:value-of>
                </mods:namePart>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="./p:subfield[@code='d' or @code='D']">
              <mods:namePart type="given">
                <xsl:value-of select="./p:subfield[@code='d' or @code='D']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='a' or @code='A']">
              <mods:namePart type="family">
                <xsl:value-of select="./p:subfield[@code='a' or @code='A']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='c']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="./p:subfield[@code='c']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='9']">
              <mods:nameIdentifier type="local">
                <xsl:value-of select="concat('(DE-627)',./p:subfield[@code='9'])" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='7']">
              <mods:nameIdentifier type="gnd">
                <xsl:value-of select="substring-after(./p:subfield[@code='7'],'gnd/')" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='3']">
              <mods:nameIdentifier type="local">
                <xsl:value-of select="concat('(DE-576)',./p:subfield[@code='3'])" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='P']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='P']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='n']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="./p:subfield[@code='n']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='l']">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="./p:subfield[@code='l']" />
              </mods:namePart>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="./p:subfield[@code='4']">
            <xsl:for-each select="./p:subfield[@code='4']">
              <mods:role>
                <mods:roleTerm type="code" authority="marcrelator">
                  <xsl:value-of select="." />
                </mods:roleTerm>
                <xsl:if test="preceding-sibling::p:subfield[@code='B']">
                  <mods:roleTerm type="text" authority="GBV">
                    <xsl:value-of select="preceding-sibling::p:subfield[@code='B']" />
                  </mods:roleTerm>
                </xsl:if>
              </mods:role>
            </xsl:for-each>
          </xsl:when>

          <!-- Alt: Heuristiken für RAK-Aufnahmen -->
          <xsl:when test="./p:subfield[@code='B']">
            <mods:role>
              <mods:roleTerm type="code" authority="marcrelator">
                <xsl:choose>
                  <!-- RAK WB §185, 2 -->
                  <xsl:when test="./p:subfield[@code='B']='Bearb.'">
                    ctb
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Begr.'">
                    org
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Hrsg.'">
                    edt
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Ill.'">
                    ill
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Komp.'">
                    cmp
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Mitarb.'">
                    ctb
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Red.'">
                    red
                  </xsl:when>
                  <!-- GBV Katalogisierungsrichtlinie -->
                  <xsl:when test="./p:subfield[@code='B']='Adressat'">
                    rcp
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='angebl. Hrsg.'">
                    edt
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='mutmaßl. Hrsg.'">
                    edt
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Komm.'">
                    ann
                  </xsl:when><!-- Kommentator = annotator -->
                  <xsl:when test="./p:subfield[@code='B']='Stecher'">
                    egr
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='angebl. Übers.'">
                    trl
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='mutmaßl. Übers.'">
                    trl
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='angebl. Verf.'">
                    dub
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='mutmaßl. Verf.'">
                    dub
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Verstorb.'">
                    oth
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Zeichner'">
                    drm
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Präses'">
                    pra
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Resp.'">
                    rsp
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Widmungsempfänger'">
                    dto
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Zensor'">
                    cns
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Beiträger'">
                    ctb
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Beiträger k.'">
                    ctb
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Beiträger m.'">
                    ctb
                  </xsl:when>
                  <xsl:when test="./p:subfield[@code='B']='Interpr.'">
                    prf
                  </xsl:when> <!-- Interpret = Performer -->
                  <xsl:otherwise>
                    oth
                  </xsl:otherwise>
                </xsl:choose>
              </mods:roleTerm>
              <mods:roleTerm type="text" authority="GBV">
                [
                <xsl:value-of select="./p:subfield[@code='B']" />
                ]
              </mods:roleTerm>
            </mods:role>
          </xsl:when>
          <xsl:when test="@tag='028A' or @tag='028B'">
            <mods:role>
              <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
              <mods:roleTerm type="text" authority="GBV">[Verfasser]</mods:roleTerm>
            </mods:role>
          </xsl:when>
          <xsl:otherwise>
            <mods:role>
              <mods:roleTerm type="code" authority="marcrelator">oth</mods:roleTerm>
            </mods:role>
          </xsl:otherwise>
        </xsl:choose>
      </mods:name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_CorporateName">
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <!-- zusätzlich geprüft 033J = 4043 Druckernormadaten (alt) -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '029') or @tag='033J']">
      <mods:name type="corporate">
        <xsl:choose>
          <xsl:when test="$MyCoRe_intern='true' and ./p:subfield[@code='9']">
            <xsl:variable name="query" select="concat('unapi-gvk:gvk:ppn:', ./p:subfield[@code='9'])" />
            <xsl:variable name="tb" select="document($query)" />
            <mods:nameIdentifier type="gnd">
              <xsl:value-of select="$tb/p:record/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" />
            </mods:nameIdentifier>
            <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='a']">
              <mods:namePart>
                <xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='a']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='b']">
              <mods:namePart>
                <xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='b']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='g']">
              <mods:namePart>
                <xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='g']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='a']">
              <mods:namePart>
                <xsl:value-of select="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='a']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='g']">
              <mods:namePart>
                <xsl:value-of select="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='g']" />
              </mods:namePart>
            </xsl:if>

            <xsl:for-each select="$tb/p:record/p:datafield[@tag='060R' and (./p:subfield[@code='4']='datb' or ./p:subfield[@code='4']='datv')]">
              <xsl:if test="./p:subfield[@code='a']">
                <xsl:variable name="out_date">
                  <xsl:value-of select="./p:subfield[@code='a']" />
                  -
                  <xsl:value-of select="./p:subfield[@code='b']" />
                </xsl:variable>
                <mods:namePart type="date">
                  <xsl:value-of select="normalize-space($out_date)" />
                </mods:namePart>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='d']">
                <mods:namePart type="date">
                  <xsl:value-of select="./p:subfield[@code='d']" />
                </mods:namePart>
              </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="$tb/p:record/p:datafield[@tag='065R' and ./p:subfield[@code='4']='orta']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='A']" />
              </mods:namePart>
            </xsl:for-each>

          </xsl:when>

          <xsl:otherwise>
            <xsl:if test="./p:subfield[@code='a' or @code='A']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='a' or @code='A']" />
              </mods:namePart>
            </xsl:if>
            <!-- remove test and select for code 'B' -->
            <xsl:if test="./p:subfield[@code='b']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='b']" />
              </mods:namePart>
            </xsl:if>
            <!-- Undocumented transistion from $b to $F see 1663758263 (gnd/2027483-X) -->
            <xsl:if test="./p:subfield[@code='F']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='F']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='9']">
              <mods:nameIdentifier type="local">
                <xsl:value-of select="concat('(DE-627)',./p:subfield[@code='9'])" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='7']">
              <mods:nameIdentifier type="gnd">
                <xsl:value-of select="substring-after(./p:subfield[@code='7'],'gnd/')" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='3']">
              <mods:nameIdentifier type="local">
                <xsl:value-of select="concat('(DE-576)',./p:subfield[@code='3'])" />
              </mods:nameIdentifier>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='d']">
              <mods:namePart type="date">
                <xsl:value-of select="./p:subfield[@code='d']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='g']"> <!-- Zusatz -->
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='g']" />
              </mods:namePart>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='c']"> <!-- non-normative type "place" -->
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='c']" />
              </mods:namePart>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='4']">
            <mods:role>
              <xsl:if test="./p:subfield[@code='4']">
                <mods:roleTerm type="code" authority="marcrelator">
                  <xsl:value-of select="./p:subfield[@code='4']" />
                </mods:roleTerm>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='B']">
                <mods:roleTerm type="text" authority="GBV">
                  <xsl:value-of select="./p:subfield[@code='B']" />
                </mods:roleTerm>
              </xsl:if>
            </mods:role>
          </xsl:when>
          <xsl:when test="./p:subfield[@code='B']">
            <mods:roleTerm type="text" authority="GBV">
              <xsl:value-of select="./p:subfield[@code='B']" />
            </mods:roleTerm>
          </xsl:when>
          <xsl:when test="@tag='033J'">
            <mods:role>
              <mods:roleTerm type="code" authority="marcrelator">pbl</mods:roleTerm>
              <mods:roleTerm type="text" authority="GBV">Verlag</mods:roleTerm>
            </mods:role>
          </xsl:when>
        </xsl:choose>
      </mods:name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_ABSTRACT">
    <!--mods:abstract aus 047I mappen und lang-Attribut aus spitzen Klammern am Ende -->
    <xsl:for-each select="./p:datafield[@tag='047I']/p:subfield[@code='a']">
      <mods:abstract type="summary">
        <xsl:choose>
          <xsl:when test="contains(.,'&lt;ger&gt;')">
            <xsl:attribute name="lang">ger</xsl:attribute>
            <xsl:attribute name="xml:lang">de</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;ger&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;eng&gt;')">
            <xsl:attribute name="lang">eng</xsl:attribute>
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;eng&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;spa&gt;')">
            <xsl:attribute name="lang">spa</xsl:attribute>
            <xsl:attribute name="xml:lang">es</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;spa&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;fra&gt;')">
            <xsl:attribute name="lang">fra</xsl:attribute>
            <xsl:attribute name="xml:lang">fr</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;fra&gt;'))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:abstract>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Collection">
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document(concat($mycoreRestAPIBaseURL, 'classifications/collection'))//category/label[@xml:lang='de']">
        <xsl:if test="$pica4110 = translate(./@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/collection</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/collection#', ./../@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">collection</xsl:attribute>
            <xsl:value-of select="./../label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_AADGenres">
    <xsl:for-each select="./p:subfield[@code='9']/text()">
      <xsl:variable name="ppn" select="." />
      <xsl:for-each select="document(concat($mycoreRestAPIBaseURL,'classifications/aadgenre'))//category/label[@xml:lang='x-ppn']">
        <xsl:if test="$ppn = ./@text">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/aadgenre</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/aadgenre#', ./../@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">aadgenre</xsl:attribute>
            <xsl:value-of select="./../label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_Identifier">
    <xsl:for-each select="./p:datafield[@tag='017C']"> <!-- 4950 (kein eigenes Feld) -->
      <xsl:if test="contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')">
        <mods:identifier type="purl">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:identifier>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='003@']"> <!-- 0100 -->
      <mods:identifier type="PPN">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
      <mods:identifier type="uri" invalid="yes">
        <xsl:value-of select="concat('//gso.gbv.de/DB=2.1/PPNSET?PPN=',p:subfield[@code='0'])" />
      </mods:identifier>
      <mods:identifier type="local" invalid="yes">
        <xsl:value-of select="concat('(DE-601)',p:subfield[@code='0'])" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004U']"> <!-- 2050 -->
      <mods:identifier type="urn">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004V']"> <!-- 2051 -->
      <mods:identifier type="doi">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='004P' or @tag='004A' or @tag='004J']/p:subfield[@code='0']"> <!-- ISBN, ISBN einer anderen phys. Form (z.B. printISBN), ISBN der Reproduktion -->
      <mods:identifier type="isbn"> <!-- 200x, ISBN-13 -->
        <xsl:choose>
          <xsl:when test="translate(., '1234567890', '----------') = '----------'">
            <xsl:call-template name="number2isbn">
              <xsl:with-param name="isbn" select="." />
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="translate(., '1234567890', '----------') = '-------------'">
            <xsl:value-of select="concat(substring(.,1,3),'-')" />
            <xsl:call-template name="number2isbn">
              <xsl:with-param name="isbn" select="substring(.,4)" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:identifier>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='006V']"> <!-- 2190 -->
      <mods:identifier type="vd16">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='006W']"> <!-- 2191 -->
      <mods:identifier type="vd17">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='006M']"> <!-- 2192 -->
      <mods:identifier type="vd18">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='006Z']"> <!-- 2110 -->
      <mods:identifier type="zdb">
        <xsl:value-of select="./p:subfield[@code='0']" />
      </mods:identifier>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='007S']"><!-- 2277 -->
      <xsl:choose>
        <!-- VD16 nicht nur in 2190, sondern als bibliogr. Zitat in 2277 -->
        <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD 16') or starts-with(./p:subfield[@code='0'], 'VD16')">
          <xsl:if test="not(./../p:datafield[@tag='006V'])">
            <mods:identifier type="vd16">
              <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '16'))" />
            </mods:identifier>
          </xsl:if>
        </xsl:when>
        <!-- VD17 nicht nur in 2191, sondern als bibliogr. Zitat in 2277 -->
        <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD17')">
          <xsl:if test="not(./../p:datafield[@tag='006W'])">
            <mods:identifier type="vd17">
              <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'VD17'))" />
            </mods:identifier>
          </xsl:if>
        </xsl:when>
        <!--VD18 nicht nur in 2192, sondern als bibliogr. Zitat in 2277 -->
        <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD18')">
          <xsl:if test="not(./../p:datafield[@tag='006M'])">
            <mods:identifier type="vd18">
              <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'VD18'))" />
            </mods:identifier>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with(./p:subfield[@code='0'], 'RISM')">
          <mods:identifier type="rism">
            <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'RISM'))" />
          </mods:identifier>
        </xsl:when>
        <xsl:when test="starts-with(./p:subfield[@code='0'], 'Kalliope')">
          <mods:identifier type="kalliope">
            <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'Kalliope'))" />
          </mods:identifier>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not(./p:subfield[@code='S']='e')">
            <mods:note type="bibliographic_reference">
              <xsl:value-of select="./p:subfield[@code='0']" />
            </mods:note>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="number2isbn_registrant">
    <xsl:param name="rest_isbn" />
    <xsl:variable name="testsegment_registrant" select="substring($rest_isbn,1,5)" />
    <xsl:variable name="isbn_length" select="string-length($rest_isbn)" />
    <xsl:variable name="registrant_length">
      <xsl:choose>
        <xsl:when test="00000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 19999">
          <xsl:value-of select="2" />
        </xsl:when>
        <xsl:when test="20000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 69999">
          <xsl:value-of select="3" />
        </xsl:when>
        <xsl:when test="70000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 84999">
          <xsl:value-of select="4" />
        </xsl:when>
        <xsl:when test="85000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 89999">
          <xsl:value-of select="5" />
        </xsl:when>
        <xsl:when test="90000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 94999">
          <xsl:value-of select="6" />
        </xsl:when>
        <xsl:when test="95000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 99999">
          <xsl:value-of select="7" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of
      select="concat(substring($rest_isbn,1,$registrant_length),'-',substring($rest_isbn,$registrant_length + 1,$isbn_length - $registrant_length - 1),'-',substring($rest_isbn,$isbn_length,1))" />
  </xsl:template>

  <xsl:template name="number2isbn">
    <xsl:param name="isbn" />
    <xsl:variable name="testsegment_reggroup" select="substring($isbn,1,5)" />
    <xsl:choose>
      <xsl:when test="00000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 59999">
        <xsl:value-of select="concat(substring($isbn,1,1),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="60000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 69999">
        <xsl:value-of select="$isbn" />
      </xsl:when>
      <xsl:when test="70000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 79999">
        <xsl:value-of select="concat(substring($isbn,1,1),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="80000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 94999">
        <xsl:value-of select="concat(substring($isbn,1,2),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,3)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="95000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 98999">
        <xsl:value-of select="concat(substring($isbn,1,3),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,4)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="99000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 99899">
        <xsl:value-of select="concat(substring($isbn,1,4),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,5)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="99900 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 99999">
        <xsl:value-of select="concat(substring($isbn,1,5),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,6)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$isbn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Date_allFormats">
    <xsl:param name="date" />
    <xsl:param name="keyDate" />
    <xsl:param name="point" />
    <xsl:variable name="date_iso">
      <xsl:choose>
        <xsl:when test="translate($date,'1234567890','_') = '____'">
          <xsl:value-of select="$date" />
        </xsl:when>
        <xsl:when test="translate($date,'1234567890','_') = '__.__.____'">
          <xsl:value-of select="concat(substring($date,7),'-',substring($date,4,5),'-',substring($date,1,2))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'Error - Dateconversion'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <mods:dateIssued encoding="iso8601">
      <xsl:if test="$keyDate">
        <xsl:attribute name="keyDate"><xsl:value-of select="$keyDate" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$point">
        <xsl:attribute name="point"><xsl:value-of select="$point" /></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$date" />
    </mods:dateIssued>
    <mods:dateIssued encoding="w3cdtf">
      <xsl:if test="$keyDate">
        <xsl:attribute name="keyDate"><xsl:value-of select="$keyDate" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$point">
        <xsl:attribute name="point"><xsl:value-of select="$point" /></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$date" />
    </mods:dateIssued>
  </xsl:template>

  <xsl:template name="COMMON_dateIssued">
    <xsl:for-each select="./p:datafield[@tag='011@']">
      <xsl:choose>
        <xsl:when test="./p:subfield[@code='d'] and ./p:subfield[@code='c'] != ./p:subfield[@code='d']">
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='c']" />
            <xsl:with-param name="keyDate" select="'yes'" />
            <xsl:with-param name="point" select="'start'" />
          </xsl:call-template>
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='d']" />
            <xsl:with-param name="point" select="'end'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="./p:subfield[@code='c']">
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='c']" />
            <xsl:with-param name="keyDate" select="'yes'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="./p:subfield[@code='b']">
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='a']" />
            <xsl:with-param name="keyDate" select="'yes'" />
            <xsl:with-param name="point" select="'start'" />
          </xsl:call-template>
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='b']" />
            <xsl:with-param name="point" select="'end'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains(./p:subfield[@code='a'], 'X')">
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="translate(./p:subfield[@code='a'], 'X','0')" />
            <xsl:with-param name="keyDate" select="'yes'" />
            <xsl:with-param name="point" select="'start'" />
          </xsl:call-template>
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="translate(./p:subfield[@code='a'], 'X', '9')" />
            <xsl:with-param name="point" select="'end'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="Date_allFormats">
            <xsl:with-param name="date" select="./p:subfield[@code='a']" />
            <xsl:with-param name="keyDate" select="'yes'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="./p:subfield[@code='n']">
        <xsl:variable name="date_vorlage" select="./p:subfield[@code='n']" />
        <mods:dateIssued>
          <xsl:if test="contains($date_vorlage,'?')">
            <xsl:attribute name="qualifier"><xsl:value-of select="'questionable'" /></xsl:attribute>
          </xsl:if>
          <xsl:value-of select="$date_vorlage" />
        </mods:dateIssued>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:key use="generate-id(preceding-sibling::p:datafield[@tag='201B'][1])" name="key-id-pre2018" match="p:datafield"/>

  <xsl:template name="COMMON_Location">
    <!-- for each exemplar -->
    <!-- didn't use 201A, because some times the 201A didn't occur (see 119103680) -->
    <xsl:for-each select="./p:datafield[@tag='201B']">
      <xsl:variable name="current201B" select="." />
      <mods:location>
        <xsl:for-each select="key('key-id-pre2018' , generate-id() )">
          <xsl:choose>
            <xsl:when test="@tag='202D'">
              <xsl:variable name="eln" >
                <xsl:choose>
                  <xsl:when test="contains(p:subfield[@code='a'],'/')">
                    <xsl:value-of select="substring-before(p:subfield[@code='a'],'/')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="p:subfield[@code='a']"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:if test="string-length($eln) &gt; 0">
                <mods:physicalLocation authority="ELN">
                  <xsl:value-of select="$eln" />
                </mods:physicalLocation>
              </xsl:if>
            </xsl:when>
            <xsl:when test="@tag='209A'">
              <xsl:variable name="shelfmark" select="p:subfield[@code='a']" />
              <xsl:if test=" string-length($shelfmark) &gt; 0 and not($shelfmark='Einzelsignatur')">
                <mods:shelfLocator>
                  <xsl:value-of select="$shelfmark" />
                </mods:shelfLocator>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </mods:location>
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template match="p:datafield[@tag='031A']">
    <!-- Volume -->
    <xsl:if test="./p:subfield[@code='d']">
      <mods:detail type="volume">
        <mods:number>
          <xsl:value-of select="./p:subfield[@code='d']" />
        </mods:number>
      </mods:detail>
    </xsl:if>
    <!-- Issue -->
    <xsl:if test="./p:subfield[@code='e']">
      <mods:detail type="issue">
        <mods:number>
          <xsl:value-of select="./p:subfield[@code='e']" />
        </mods:number>
      </mods:detail>
    </xsl:if>

    <!-- Seitenzahlen zu Pica to MODS -->
    <xsl:if test="./p:subfield[@code='h' or @code='g']">
      <mods:extent unit="pages">
        <xsl:if test="./p:subfield[@code='g']">
          <mods:total>
            <xsl:value-of select="./p:subfield[@code='g']" />
          </mods:total>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='h']">
          <xsl:if test="not (contains(./p:subfield[@code='h'], ','))">
            <xsl:if test="not (contains(./p:subfield[@code='h'], '-'))">
              <mods:start>
                <xsl:value-of select="./p:subfield[@code='h']" />
              </mods:start>
            </xsl:if>
            <xsl:if test="contains(./p:subfield[@code='h'], '-')">
              <mods:start>
                <xsl:value-of select="substring-before(./p:subfield[@code='h'], '-')" />
              </mods:start>
              <mods:end>
                <xsl:value-of select="substring-after(./p:subfield[@code='h'], '-')" />
              </mods:end>
            </xsl:if>
          </xsl:if>
          <xsl:if test="contains(./p:subfield[@code='h'], ',')">
            <mods:list>
              <xsl:value-of select="./p:subfield[@code='h']" />
            </mods:list>
          </xsl:if>
        </xsl:if>
      </mods:extent>
    </xsl:if>

    <!-- Date -->
    <xsl:if test="./p:subfield[@code='j']">
      <mods:date encoding="iso8601">
        <xsl:value-of select="substring(./p:subfield[@code='j'],1,4)" />
      </mods:date>
    </xsl:if>
    <xsl:if test="./p:subfield[@code='y']">
      <mods:text type="display">
        <xsl:value-of select="./p:subfield[@code='y']" />
      </mods:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="COMMON_Conference">
  <!-- 030F Conference only for GBV titles -->
    <xsl:variable name="conferenceName" select="./p:subfield[@code='a']"/>
    <xsl:variable name="subUnit" select="./p:subfield[@code='b']"/>
    <xsl:variable name="confCount" select="./p:subfield[@code='j']"/>
    <xsl:variable name="confPlace" select="./p:subfield[@code='k']"/>
    <xsl:variable name="confDate" select="./p:subfield[@code='p']"/>
    <xsl:variable name="confStr">
      <xsl:value-of select="concat($conferenceName,' ; ',$confCount,'(',$confPlace,') ',':',$confDate)" />
    </xsl:variable>
    <mods:name type="conference">
      <mods:namePart>
        <xsl:value-of select="$confStr"/>
      </mods:namePart>
    </mods:name>
  </xsl:template>
  
  
  <xsl:template name="COMMON_Thesis">
  <!-- 037C Thesis -->
    <xsl:variable name="thesisNote" select="./p:subfield[@code='a']"/> <!-- not RDA -->
    <xsl:variable name="type" select="./p:subfield[@code='d']"/>
    <xsl:variable name="institut" select="./p:subfield[@code='e']"/>
    <xsl:variable name="year" select="./p:subfield[@code='f']"/>
    <xsl:variable name="thesisStr">
      <xsl:choose>
        <xsl:when test="$thesisNote">
          <xsl:value-of select="$thesisNote" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($type,',',$institut,',',$year)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <mods:note type="thesis">
        <xsl:value-of select="$thesisStr"/>
    </mods:note>
  </xsl:template>
  
</xsl:stylesheet> 