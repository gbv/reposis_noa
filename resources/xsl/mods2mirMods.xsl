<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" 
  xmlns:pica="info:srw/schema/5/picaXML-v1.0"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="i18n xsl str pica" >
  <xsl:param name="parentId" />
  <xsl:param name="WebApplicationBaseURL" />
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:include href="xslInclude:PPN-mods-simple"/> 
  <xsl:include href="copynodes.xsl" />  
  
   
  <!--<xsl:template match="/">
    <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd" version="3.6">
      <mods:titleInfo>
        <mods:title>Grenzfälle_mods2mir</mods:title>
        <mods:subTitle>als Test für ...2</mods:subTitle>
      </mods:titleInfo>
      <mods:typeOfResource>text</mods:typeOfResource>
    </mods:mods>
  </xsl:template>  -->
  
  <!-- Set the prefix mods to all mods nodes. -->
  <xsl:template match="*[contains(namespace-uri(),'www.loc.gov/mods')]">  
    <xsl:element name="mods:{local-name()}"> 
      <xsl:copy-of select="namespace::*" />
      <xsl:apply-templates select="node()|@*" />
    </xsl:element>
  </xsl:template>
  
  <!-- Remove originInfo without eventType. Copy if not originInfo without @eventType='publication' is present.-->
  <xsl:template match="mods:originInfo[not(@eventType)]">
    <xsl:if test="not(//mods:mods/mods:originInfo/@eventType='publication')">
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="node()|@*" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <!-- Special Case for old unapi mods. Copy edition.-->
  <xsl:template match="mods:originInfo[@eventType='publication']">
    <mods:originInfo>
      <xsl:apply-templates select="node()|@*" />
      <xsl:if test="not(mods:edition) and ../mods:originInfo[not(@eventType)]/mods:edition">
        <xsl:apply-templates select="../mods:originInfo[not(@eventType)]/mods:edition" />
      </xsl:if>
    </mods:originInfo>
  </xsl:template> 

  <xsl:template name="yearRAK2w3cdtf">
    <xsl:param name="date"/>
    <xsl:value-of select="translate($date,'[]?ca','')"/>
  </xsl:template>
  
  <xsl:template match="mods:dateIssued[@encoding='marc'][not(../mods:dateIssued[not(@encoding)])]">
    <mods:dateIssued encoding="marc">
      <xsl:value-of select="."/>
    </mods:dateIssued>
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="."/>
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="mods:dateIssued[not(@encoding)][not(../mods:dateIssued[@encoding = 'w3cdtf'])]">
    <!-- TODO: check date format first! -->
    <mods:dateIssued>
      <xsl:value-of select="."/>
    </mods:dateIssued>
    <xsl:choose>
      <xsl:when test="starts-with(.,'Januar')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Februar')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'März')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'April')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Mai')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Juni')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Juli')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'August')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'September')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Oktober')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'November')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Dezember')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="datevalue">
          <xsl:call-template  name="yearRAK2w3cdtf">
            <xsl:with-param name="date" select="node()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($datevalue,'-')">
            <mods:dateIssued encoding="w3cdtf" point="start">
              <xsl:value-of select="substring-before($datevalue,'-')"/>
            </mods:dateIssued>
            <xsl:variable name="datevalueAfter" select="substring-after($datevalue,'-')" />
            <xsl:if test="string-length($datevalueAfter)">
              <mods:dateIssued encoding="w3cdtf" point="end">
                <xsl:value-of select="$datevalueAfter"/>
              </mods:dateIssued>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <mods:dateIssued encoding="w3cdtf">
              <xsl:value-of select="$datevalue"/>
              <xsl:apply-templates select="@*" />
            </mods:dateIssued>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:languageTerm[@authority='iso639-2b' and not(../mods:languageTerm[@authority='rfc4646'])]">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc4646')" />
    <xsl:variable name="biblCode" select="." />
    <xsl:variable name="rfcCode">
      <xsl:value-of select="$languages//category[label[@xml:lang='x-bibl']/@text = $biblCode]/@ID" />
    </xsl:variable>
    <mods:languageTerm authority="rfc4646" type="code">
      <xsl:value-of select="$rfcCode"/>    
    </mods:languageTerm>
  </xsl:template>
  
  <xsl:template match="mods:number">
    <mods:number>
      <xsl:variable name="number">
        <xsl:for-each select="str:tokenize(.,';')">
          <xsl:choose>
            <xsl:when test="contains(.,'Band')">
              <xsl:value-of select="substring-after(.,'Band')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Bd.')">
              <xsl:value-of select="substring-after(.,'Bd.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Teil')">
              <xsl:value-of select="substring-after(.,'Teil')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Vol.')">
              <xsl:value-of select="substring-after(.,'Vol.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Vol')">
              <xsl:value-of select="substring-after(.,'Vol')"/>
            </xsl:when>
            <xsl:when test="contains(.,'vol.')">
              <xsl:value-of select="substring-after(.,'Vol.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'vol')">
              <xsl:value-of select="substring-after(.,'Vol')"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="string-length($number) &gt; 0">
          <xsl:value-of select="$number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </mods:number>
  </xsl:template>  
    
  <xsl:template match="mods:start[contains(.,'-')]">
    <mods:start><xsl:value-of select="substring-before(.,'-')"/></mods:start>
    <mods:end><xsl:value-of select="substring-after(.,'-')"/></mods:end>
  </xsl:template>
  
  <xsl:template match="mods:roleTerm[@authority='marcrelator'][@type='code'][text()='edit']">
    <roleTerm authority="marcrelator" type="code">edt</roleTerm>
  </xsl:template>
    
</xsl:stylesheet>