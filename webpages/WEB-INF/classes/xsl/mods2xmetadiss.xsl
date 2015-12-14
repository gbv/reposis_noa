<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================== -->
<!-- $Revision: 1.8 $ $Date: 2007-04-20 15:18:23 $ -->
<!-- ============================================== -->
<xsl:stylesheet
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xmlns:exslt="http://exslt.org/common"
     xmlns:mods="http://www.loc.gov/mods/v3"
     xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"

     xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
     xmlns:cc="http://www.d-nb.de/standards/cc/"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:dcmitype="http://purl.org/dc/dcmitype/"
     xmlns:dcterms="http://purl.org/dc/terms/"
     xmlns:pc="http://www.d-nb.de/standards/pc/"
     xmlns:urn="http://www.d-nb.de/standards/urn/"
     xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
     xmlns:ddb="http://www.d-nb.de/standards/ddb/"
     xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
     xmlns="http://www.d-nb.de/standards/subject/"
     xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

  <xsl:include href="mods2dc.xsl" />
  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="JSessionID" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />
  <xsl:param name="MCR.URN.SubNamespace.Default.Prefix" select="''" />

  <xsl:template match="mycoreobject" mode="metadata">

    <xsl:text disable-output-escaping="yes">
    &#60;xMetaDiss:xMetaDiss xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xMetaDiss=&quot;http://www.d-nb.de/standards/xmetadissplus/&quot;
                              xsi:schemaLocation=&quot;http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd&quot;&#62;
    </xsl:text>

             <xsl:call-template name="title"/>
             <xsl:call-template name="alternative"/>
             <xsl:call-template name="creator"/>
             <xsl:call-template name="subject"/>
             <xsl:call-template name="abstract"/>
             <xsl:call-template name="publisher"/>
             <xsl:call-template name="contributor"/>
             <xsl:call-template name="date"/>
             <xsl:call-template name="type"/>
             <xsl:call-template name="identifier"/>
             <xsl:call-template name="format"/>
             <xsl:call-template name="language"/>
             <xsl:call-template name="degree"/>
             <xsl:call-template name="contact"/>
             <!-- xsl:call-template name="file"/ -->
             <xsl:call-template name="rights"/>
    <xsl:text disable-output-escaping="yes">
      &#60;/xMetaDiss:xMetaDiss&#62;
      </xsl:text>
    </xsl:template>

    <xsl:template name="linkQueryURL">
        <!-- <xsl:param name="type" select="'alldocs'"/>
        <xsl:param name="host" select="'local'"/> -->
        <xsl:param name="id"/>
        <!-- <xsl:value-of select="concat($ServletsBaseURL,'MCRQueryServlet',$JSessionID,'?XSL.Style=xml&amp;type=',$type,'&amp;hosts=',$host,'&amp;query=%2Fmycoreobject%5B%40ID%3D%27',$id,'%27%5D')" /> -->
        <!-- <xsl:value-of select="concat($WebApplicationBaseURL,'content/xmloutput.jsp?id=',$id,'&amp;type=object')" />   -->
           <xsl:value-of select="concat('mcrobject:',$id)" />
    </xsl:template>

    <xsl:template name="linkDerDetailsURL">
        <xsl:param name="host" select="'local'"/>
        <xsl:param name="id"/>
        <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$id,'/')" />
        <xsl:value-of select="concat($derivbase,'?MCRSessionID=',$JSessionID,'&amp;hosts=',$host,'&amp;XSL.Style=xml')" />
    </xsl:template>

<!--  <xsl:template name="linkClassQueryURL">
        <xsl:param name="type" select="'class'"/>
        <xsl:param name="host" select="'local'"/>
        <xsl:param name="classid" select="''" />
        <xsl:param name="categid" select="''" /> -->
        <!-- xsl:value-of select="concat($WebApplicationBaseURL,'content/xmloutput.jsp?id=',$classid,'&amp;categid=',$categid,'&amp;type=classification')" />  -->
 <!--      <xsl:value-of select="concat('mcrobject:',$classid)" />
     </xsl:template> -->

    <xsl:template name="lang">
        <xsl:choose>
            <xsl:when test="./@xml:lang='de'">ger</xsl:when>
            <xsl:when test="./@xml:lang='en'">eng</xsl:when>
            <xsl:when test="./@xml:lang='fr'">fre</xsl:when>
            <xsl:when test="./@xml:lang='es'">spa</xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="replaceSubSupTags">
        <xsl:param name="content" select="''" />
        <xsl:choose>
           <xsl:when test="contains($content,'&lt;sub&gt;')">
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-before($content,'&lt;sub&gt;')" />
              </xsl:call-template>
              <xsl:text>_</xsl:text>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-after($content,'&lt;sub&gt;')" />
              </xsl:call-template>
           </xsl:when>
           <xsl:when test="contains($content,'&lt;/sub&gt;')">
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-before($content,'&lt;/sub&gt;')" />
              </xsl:call-template>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-after($content,'&lt;/sub&gt;')" />
              </xsl:call-template>
           </xsl:when>
           <xsl:when test="contains($content,'&lt;sup&gt;')">
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-before($content,'&lt;sup&gt;')" />
              </xsl:call-template>
              <xsl:text>^</xsl:text>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-after($content,'&lt;sup&gt;')" />
              </xsl:call-template>
           </xsl:when>
           <xsl:when test="contains($content,'&lt;/sup&gt;')">
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-before($content,'&lt;/sup&gt;')" />
              </xsl:call-template>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="substring-after($content,'&lt;/sup&gt;')" />
              </xsl:call-template>
           </xsl:when>
           <xsl:otherwise>
               <xsl:value-of select="$content" />
           </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="title">
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[not(@type='uniform' or @type='abbreviated' or @type='alternative')]">
            <xsl:element name="dc:title">
               <xsl:attribute name="lang"><xsl:call-template name="lang" /></xsl:attribute>
               <xsl:attribute name="xsi:type">ddb:titleISO639-2</xsl:attribute>
               <xsl:if test="contains(./@type,'translated')">
                  <xsl:attribute name="ddb:type">translated</xsl:attribute>
               </xsl:if>
               <xsl:value-of select="." />
               <xsl:if test="../mods.subtitle">
                 <xsl:text> : </xsl:text>
                 <xsl:value-of select="../mods.subtitle" />
               </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="alternative">
       <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[@type='uniform' or @type='abbreviated' or @type='alternative']">
           <xsl:element name="dcterms:alternative">
               <xsl:attribute name="lang"><xsl:call-template name="lang" /></xsl:attribute>
               <xsl:attribute name="xsi:type">ddb:talternativeISO639-2</xsl:attribute>
               <xsl:value-of select="." />
               <xsl:if test="../mods.subtitle">
                 <xsl:text> : </xsl:text>
                 <xsl:value-of select="../mods.subtitle" />
               </xsl:if>
           </xsl:element>
       </xsl:for-each>
    </xsl:template>

    <xsl:template name="creator">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:element name="dc:creator">
          <xsl:attribute name="xsi:type">pc:MetaPers</xsl:attribute>
          <xsl:element name="pc:person">
            <xsl:if test="mods:nameIdentifier[@type='gnd']">
              <xsl:attribute name="PND-Nr">
                <xsl:value-of select="mods:nameIdentifier[@type='gnd']" />
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="pc:name">
              <xsl:attribute name="type">nameUsedByThePerson</xsl:attribute>
              <xsl:element name="pc:personEnteredUnderGivenName">
                <xsl:value-of select="mods:displayForm" />
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="subject">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='sdnb']">
        <xsl:element name="dc:subject">
          <xsl:attribute name="xsi:type">xMetaDiss:DDC-SG</xsl:attribute>
          <xsl:value-of select="." />
        </xsl:element>
      </xsl:for-each>

       <!-- xsl:for-each select="./metadata/keywords/keyword[@type='SWD']">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:SWD</xsl:attribute>
               <xsl:value-of select="." />
           </xsl:element>
       </xsl:for-each -->
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:subject">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:noScheme</xsl:attribute>
               <xsl:value-of select="mods:topic" />
           </xsl:element>
       </xsl:for-each>
    </xsl:template>



    <xsl:template name="abstract">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract">
          <xsl:element name="dcterms:abstract">
              <xsl:attribute name="lang"><xsl:call-template name="lang" /></xsl:attribute>
              <xsl:attribute name="xsi:type">ddb:contentISO639-2</xsl:attribute>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="." />
              </xsl:call-template>
          </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="publisher">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication'][mods:publisher]">
        <xsl:element name="dc:publisher">
          <xsl:attribute name="xsi:type">cc:Publisher</xsl:attribute>
          <xsl:attribute name="type">dcterms:ISO3166</xsl:attribute>
          <xsl:attribute name="countryCode">DE</xsl:attribute>
          <xsl:element name="cc:universityOrInstitution">
            <xsl:element name="cc:name">
                <xsl:value-of select="mods:publisher" />
            </xsl:element>
            <xsl:if test="mods:place">
              <xsl:element name="cc:place">
                <xsl:value-of select="mods:place/mods:placeTerm" />
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="contributor">
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='ctb']">
            <xsl:element name="dc:contributor">
                <xsl:attribute name="xsi:type">pc:Contributor</xsl:attribute>
                <!-- xsl:attribute name="thesis:role"><xsl:value-of select="./@type" /></xsl:attribute -->
                <xsl:element name="pc:person">
                  <xsl:element name="pc:name">
                    <xsl:attribute name="type">nameUsedByThePerson</xsl:attribute>
                    <xsl:element name="pc:personEnteredUnderGivenName">
                      <xsl:value-of select="mods:displayForm" />
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="date">
        <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
            <xsl:element name="dcterms:issued">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
            </xsl:element>
        </xsl:if>
         <xsl:for-each select="./service/servdates/servdate[@type='modifydate']">
            <xsl:element name="dcterms:modified">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="type">
      <xsl:element name="dc:type">
        <xsl:attribute name="xsi:type">dini:PublType</xsl:attribute>
        <xsl:choose>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'article')">
            <xsl:text>contributionToPeriodical</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'issue')">
            <xsl:text>Periodical</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'journal')">
            <xsl:text>PeriodicalPart</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'book')">
            <xsl:text>book</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Other</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="dc:type">
        <xsl:attribute name="xsi:type">dcterms:DCMIType</xsl:attribute>
        <xsl:text>Text</xsl:text>
      </xsl:element>
      <xsl:element name="dini:version_driver">
        <xsl:text>publishedVersion</xsl:text>
      </xsl:element>
    </xsl:template>

    <xsl:template name="identifier">
      <xsl:if test="./structure/derobjects/derobject or contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
        <xsl:variable name="deriv" select="./structure/derobjects/derobject/@xlink:href" />
        <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv)" />
        <xsl:variable name="derivate" select="document($derivlink)" />

        <xsl:element name="dc:identifier">
           <xsl:attribute name="xsi:type">urn:nbn</xsl:attribute>
           <xsl:choose>
             <xsl:when test="mcrurn:hasURNDefined($deriv)">
               <xsl:value-of select="$derivate/mycorederivate/derivate/fileset/@urn" />
             </xsl:when>
             <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'] and contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
               <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn']" />
             </xsl:when>
           </xsl:choose>
        </xsl:element>
      </xsl:if>
    </xsl:template>

    <xsl:template name="format">
        <xsl:for-each select="./structure/derobjects/derobject[1]">
            <xsl:variable name="detailsURL">
                 <xsl:call-template name="linkDerDetailsURL">
                     <xsl:with-param name="id" select="./@xlink:href" />
                 </xsl:call-template>
            </xsl:variable>

           <xsl:for-each select="document($detailsURL)/mcr_directory/children/child">
<!-- 				<xsl:for-each select="document($detailsURL)/mcr_results/mcr_result/mycorederivate/derivate"> -->
                    <xsl:choose>
                       <xsl:when test="./contentType='ps'">
<!--				 	<xsl:when test="contains(./internals/internal/@maindoc, '.ps')"> -->
                       <xsl:element name="dcterms:medium">
                            <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                              <xsl:text>application/postscript</xsl:text>
                       </xsl:element>
                        </xsl:when>
                       <xsl:when test="./contentType='pdf'">
                       <xsl:element name="dcterms:medium">
                            <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                            <xsl:text>application/pdf</xsl:text>
                       </xsl:element>
                        </xsl:when>
            <xsl:when test="./contentType='zip'">
             <xsl:element name="dcterms:medium">
                            <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                            <xsl:text>application/zip</xsl:text>
                       </xsl:element>
                        </xsl:when>
                    </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="language">
        <xsl:for-each select="./metadata/languages/language">
      <xsl:variable name="classid" select="./@classid" />
            <xsl:variable name="categid" select="./@categid" />
         <xsl:variable name="classification" select="concat('classification:metadata:-1:children:',$classid,':',$categid)" />

         <xsl:for-each select="document($classification)//category">

        <xsl:for-each select="./label[@xml:lang='en']">
                <xsl:element name="dc:language">
                   <xsl:attribute name="xsi:type">dcterms:ISO639-2</xsl:attribute>
                   <xsl:value-of select="substring-before(./@description,'#')" />
                </xsl:element>
            </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="degree">
      <xsl:for-each select="./metadata/types/type">
           <xsl:if test="contains(./@categid,'TYPE0003')">
               <xsl:element name="thesis:degree">
                   <xsl:element name="thesis:level">
                       <xsl:choose>
                           <xsl:when test="./@categid = 'TYPE0003.006'">
                               <xsl:text>thesis.doctoral</xsl:text>
                           </xsl:when>
                           <xsl:when test="./@categid = 'TYPE0003.003'">
                               <xsl:text>master</xsl:text>
                           </xsl:when>
                           <xsl:when test="./@categid = 'TYPE0003.007'">
                               <xsl:text>thesis.habilitation</xsl:text>
                           </xsl:when>
                           <xsl:when test="./@categid = 'TYPE0003.002'">
                               <xsl:text>bachelor</xsl:text>
                           </xsl:when>
                           <xsl:otherwise>
                               <xsl:text>other</xsl:text>
                           </xsl:otherwise>
                       </xsl:choose>
                   </xsl:element>

            <xsl:for-each select="./../../grantorlinks/grantorlink">
      <xsl:variable name="grantorlinkURL">
        <xsl:call-template name="linkQueryURL">
           <xsl:with-param name="id" select="@xlink:href" />
           <xsl:with-param name="type" select="'institution'" />
         </xsl:call-template>
           </xsl:variable>
            <xsl:for-each select="document($grantorlinkURL)/mycoreobject/metadata">
                <xsl:element name="thesis:grantor">
                    <xsl:attribute name="xsi:type">cc:Corporate</xsl:attribute>
                    <xsl:attribute name="type">dcterms:ISO3166</xsl:attribute>
                  <xsl:element name="cc:universityOrInstitution">
                      <xsl:element name="cc:name">
                          <xsl:value-of select="./names/name[@xml:lang='de']/fullname" />
                      </xsl:element>
                      <xsl:for-each select="./addresses/address[@xml:lang='de' and @inherited='0']/city">
                          <xsl:element name="cc:place">
                                  <xsl:value-of select="." />
                          </xsl:element>
                      </xsl:for-each>
                  </xsl:element>
              </xsl:element>
           </xsl:for-each>
        </xsl:for-each>

               </xsl:element>
           </xsl:if>
       </xsl:for-each>
    </xsl:template>

    <xsl:template name="contact">
        <xsl:element name="ddb:contact">
            <xsl:attribute name="ddb:contactID">
                <xsl:choose>
                    <xsl:when test="./metadata/contacts/contact">
                        <xsl:value-of select="./metadata/contacts/contact" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>F6001-3079</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="fileproperties">
      <xsl:param name="detailsURL" select="''" />
      <xsl:param name="derpath" select="''" />
      <xsl:param name="filenumber" select="1" />
      <xsl:variable name="filelink" select="concat($detailsURL,$derpath,
         '?hosts=local&amp;XSL.Style=xml')" />
      <xsl:variable name="details" select="document($filelink)" />
      <xsl:for-each select="$details/mcr_directory/children/child[@type='file']">
         <xsl:element name="ddb:fileProperties">
             <xsl:attribute name="ddb:fileName"><xsl:value-of select="./name" /></xsl:attribute>
             <xsl:attribute name="ddb:fileID"><xsl:value-of select="./@ID" /></xsl:attribute>
             <xsl:attribute name="ddb:fileSize"><xsl:value-of select="./size" /></xsl:attribute>
             <xsl:if test="$filenumber &gt; 1">
                <xsl:attribute name="ddb:fileDirectory"><xsl:value-of select="$details/mcr_results/path" /></xsl:attribute>
             </xsl:if>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="$details/mcr_directory/children/child[@type='directory']">
        <xsl:call-template name="fileproperties">
           <xsl:with-param name="detailsURL" select="$detailsURL" />
           <xsl:with-param name="derpath" select="concat($details/mcr_directory/path,'/',name)" />
           <xsl:with-param name="filenumber" select="$filenumber" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="file">
        <xsl:for-each select="./structure/derobjects/derobject[1]">
            <xsl:variable name="detailsURL" select="concat($ServletsBaseURL,'MCRFileNodeServlet/')" />
            <xsl:variable name="filelink" select="concat($detailsURL,./@xlink:href,'/',
               '?hosts=local&amp;XSL.Style=xml')" />
            <xsl:variable name="details" select="document($filelink)" />
            <xsl:variable name="isPdfDerivate">
              <xsl:for-each select="$details/mcr_directory/children/child[@type='file']">
                    <xsl:if test="./contentType='pdf'">
                       <xsl:value-of select="'true'" />
                    </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="contains($isPdfDerivate,'true')">
               <xsl:variable name="ddbfilenumber" select="$details/mcr_directory/numChildren/total/files" />
              <xsl:element name="ddb:fileNumber">
                  <xsl:value-of select="$ddbfilenumber" />
              </xsl:element>
               <xsl:call-template name="fileproperties">
                  <xsl:with-param name="detailsURL" select="$detailsURL" />
                  <xsl:with-param name="derpath" select="concat(./@xlink:href,'/')" />
                  <xsl:with-param name="filenumber" select="number($ddbfilenumber)" />
               </xsl:call-template>
               <xsl:if test="number($ddbfilenumber) &gt; 1">
                  <xsl:element name="ddb:transfer">
                     <xsl:attribute name="ddb:type">dcterms:URI</xsl:attribute>
                     <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet?id=',./@xlink:href)" />
                  </xsl:element>
               </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="rights">
      <xsl:element name="ddb:rights">
       <xsl:attribute name="ddb:kind">free</xsl:attribute>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*">
      <xsl:copy>
        <xsl:for-each select="@*">
          <xsl:copy/>
        </xsl:for-each>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
