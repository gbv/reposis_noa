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

     xmlns:xMetaDiss="http://www.d-nb.de/standards/xMetaDiss/"
     xmlns:cc="http://www.d-nb.de/standards/cc/"
     xmlns:ddb="http://www.d-nb.de/standards/ddb/"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:dcmitype="http://purl.org/dc/dcmitype/"
     xmlns:dcterms="http://purl.org/dc/terms/"
     xmlns:pc="http://www.d-nb.de/standards/pc/"
     xmlns:urn="http://www.d-nb.de/standards/urn/"
     xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
     xmlns="http://www.d-nb.de/standards/subject/"

     xsi:schemaLocation="http://www.d-nb.de/standards/xMetaDiss/  http://www.d-nb.de/standards/xmetadiss/xmetadiss.xsd">

  <xsl:include href="mods2dc.xsl" />
  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />



    <xsl:param name="ServletsBaseURL" select="''" />
    <xsl:param name="JSessionID" select="''" />
    <xsl:param name="WebApplicationBaseURL" select="''" />

    <xsl:template match="mycoreobject" mode="metadata">
        <xsl:element name="metadata" namespace="http://www.openarchives.org/OAI/2.0/">
    <!-- DNB needs the the attribute "xmlns:xsi" definied here in the xMetaDiss-Element
         XSLT puts definition into the root element and won't repeat it here
         WORKAROUND: Write the elements open and closing tags as text
    <xMetaDiss:xMetaDiss>
                  <xsl:attribute name="xsi:schemaLocation">http://www.d-nb.de/standards/xMetaDiss/ http://atlibri.uni-rostock.de:8080/test/dnb-schemas/xmetadiss.xsd</xsl:attribute>
     -->

    <xsl:text disable-output-escaping="yes">
    &#60;xMetaDiss:xMetaDiss xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xMetaDiss=&quot;http://www.d-nb.de/standards/xMetaDiss/&quot;
                              xsi:schemaLocation=&quot;http://www.d-nb.de/standards/xMetaDiss/  http://www.d-nb.de/standards/xmetadiss/xmetadiss.xsd&quot;&#62;
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
    </xsl:element> <!--  </metadata>  -->
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
            <xsl:if test="mods:nameIdentifier/@type = 'gnd'">
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
<!--      <xsl:for-each select="./metadata/subjects/subject[@classid='docportal_class_000000000000013']">
           <xsl:element name="dc:subject">
              <xsl:attribute name="xsi:type">xMetaDiss:DDC-SG</xsl:attribute>
              <xsl:value-of select="@categid" />
           </xsl:element>   -->
    <xsl:variable name="x">
       <xsl:for-each select="./metadata/subjects/subject">
        <xsl:variable name="classid" select="./@classid" />
              <xsl:variable name="categid" select="./@categid" />

              <!-- MyCoRe Classification URI Resolver: classification:{editor['['formatAlias']']|metadata}:{Levels}:{parents|children}:{ClassID}[:CategID]

                             classification:metadata:-1:children:{ClassID} -->

        <!-- <xsl:variable name="classification" select="concat('classification:metadata:-1:children:',$classid)" />
           <xsl:variable name="subject-nodes" select="document($classification)/mycoreclass//category[@ID=$categid]" /> -->
           <xsl:variable name="classification" select="concat('classification:metadata:0:children:',$classid,':',$categid)" />

           <xsl:for-each select="document($classification)//category">
          <xsl:element name="dc:subject">
            <xsl:attribute name="xsi:type">dcterms:DDC</xsl:attribute>
            <xsl:value-of select="@ID" />
          </xsl:element>
                 <xsl:element name="dc:subject">
                  <xsl:attribute name="xsi:type">xMetaDiss:DDC-SG</xsl:attribute>
                    <xsl:value-of select="substring-after(./label[@xml:lang='x-dini']/@text,':')" />
               </xsl:element>
        </xsl:for-each>
         </xsl:for-each>
       </xsl:variable>
       <!-- remove duplicate entries -->
       <xsl:for-each select="exslt:node-set($x)">
      <xsl:copy-of select="dc:subject[not(.=following::dc:subject)]" />
       </xsl:for-each>

       <xsl:for-each select="./metadata/keywords/keyword[@type='SWD']">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:SWD</xsl:attribute>
               <xsl:value-of select="." />
           </xsl:element>
       </xsl:for-each>
        <xsl:for-each select="./metadata/keywords/keyword[@type='freetext']">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:noScheme</xsl:attribute>
               <xsl:value-of select="." />
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
    <xsl:for-each select="./metadata/publishlinks/publishlink">
      <xsl:variable name="publishlinkURL">
        <xsl:call-template name="linkQueryURL">
           <xsl:with-param name="id" select="./@xlink:href" />
           <xsl:with-param name="type" select="'institution'" />
         </xsl:call-template>
           </xsl:variable>
           <xsl:for-each select="document($publishlinkURL)/mycoreobject/metadata">
               <xsl:element name="dc:publisher">
                  <xsl:attribute name="xsi:type">cc:Publisher</xsl:attribute>
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
                  <xsl:element name="cc:address">
                       <xsl:value-of select="./addresses/address[@xml:lang='de']/street" />
                      <xsl:if test="./addresses/address[@xml:lang='de']/street" >
                        <xsl:text> </xsl:text>
                      </xsl:if>
                      <xsl:value-of select="./addresses/address[@xml:lang='de']/number" />
                      <xsl:if test="./addresses/address[@xml:lang='de']/street or ./addresses/address[@xml:lang='de']/number">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                      <xsl:value-of select="./addresses/address[@xml:lang='de']/zipcode" />
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="./addresses/address[@xml:lang='de']/city" />
                  </xsl:element>
              </xsl:element>
           </xsl:for-each>
        </xsl:for-each>


        <!-- WORKAROUND -->
       <!--  <xsl:element name="dc:publisher">
          <xsl:attribute name="xsi:type">cc:Publisher</xsl:attribute>
          <xsl:element name="cc:universityOrInstitution">
            <xsl:element name="cc:name">
              <xsl:value-of select="'Universität Rostock'" />
            </xsl:element>
            <xsl:element name="cc:place">
              <xsl:value-of select="'18051 Rostock'" />
            </xsl:element>
          </xsl:element>
          <xsl:element name="cc:address">
            <xsl:value-of select="'Postfach, 18051 Rostock'" />
          </xsl:element>
        </xsl:element> -->
        <!-- WORKAROUND ENDE -->
    </xsl:template>

    <xsl:template name="contributor">
        <xsl:for-each select="./metadata/contributors/contributor[@type='advisor' or @type='referee']">
            <xsl:element name="dc:contributor">
                <xsl:attribute name="xsi:type">pc:Contributor</xsl:attribute>
                <xsl:attribute name="thesis:role"><xsl:value-of select="./@type" /></xsl:attribute>
                <xsl:element name="pc:person">
                  <xsl:element name="pc:name">
                    <xsl:attribute name="type">nameUsedByThePerson</xsl:attribute>
                    <xsl:element name="pc:foreName"><xsl:value-of select="./firstname" /></xsl:element>
                    <xsl:element name="pc:surName"><xsl:value-of select="./surname" /></xsl:element>
                  </xsl:element>
                  <xsl:element name="pc:academicTitle"><xsl:value-of select="./academic" /></xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="date">
        <xsl:if test="./metadata/dates/date[@type='accepted']">
            <xsl:element name="dcterms:dateAccepted">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="substring(./metadata/dates/date[@type='accepted'],1,4)" />
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
    <!--
        <xsl:for-each select="./metadata/types/type">
            <xsl:choose>
                <xsl:when test="contains(./@categid,'TYPE0005')">
                    <xsl:element name="dc:type">
                        <xsl:attribute name="xsi:type">ddb:PublType</xsl:attribute>
                        <xsl:text>ElectronicThesisandDissertation</xsl:text>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>  -->

        <xsl:for-each select="./metadata/types/type">
      <xsl:variable name="classid" select="./@classid" />
            <xsl:variable name="categid" select="./@categid" />
         <xsl:variable name="classification" select="concat('classification:metadata:-1:children:',$classid,':',$categid)" />

         <xsl:for-each select="document($classification)//category">
        <xsl:for-each select="./label[@xml:lang='x-dini']">
        <xsl:if test="contains(./@text,'dissertation')" >
                    <xsl:element name="dc:type">
                        <xsl:attribute name="xsi:type">ddb:PublType</xsl:attribute>
                        <xsl:text>ElectronicThesisandDissertation</xsl:text>
                    </xsl:element>
            </xsl:if>
      </xsl:for-each>
       </xsl:for-each>
  </xsl:for-each>
    </xsl:template>

    <xsl:template name="identifier">
        <xsl:for-each select="./metadata/urns/urn">
           <xsl:if test="@type='url_update_general' or @type='urn_new' or @type='urn_new_version'">
              <xsl:element name="dc:identifier">
                 <xsl:attribute name="xsi:type">urn:nbn</xsl:attribute>
                 <xsl:value-of select="." />
              </xsl:element>
           </xsl:if>
        </xsl:for-each>
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









              <!--        <xsl:element name="thesis:grantor">
                      <xsl:attribute name="xsi:type">cc:Corporate</xsl:attribute>
                      <xsl:attribute name="type">dcterms:ISO3166</xsl:attribute>

                   <xsl:variable name="institutionClasslinkURL">
                          <xsl:call-template name="linkClassQueryURL">
                              <xsl:with-param name="classid" select="$institutionClassid" />
                              <xsl:with-param name="categid" select="$institutionCategid" />
                          </xsl:call-template>
                      </xsl:variable>
                      <xsl:for-each select="document($institutionClasslinkURL)/mcr_results/mcr_result/mycoreclass/categories/category/url"> ->


      <xsl:variable name="classid" select="./@classid" />
            <xsl:variable name="categid" select="./@categid" />
                  <xsl:variable name="classification" select="concat('classification:metadata:-1:children:',$classid,':',$categid)" />

         <xsl:for-each select="document($classification)//category[@ID=$institutionCategid]/url">

            <!- TODO Check again after integration of institutions
                          <xsl:variable name="institutionlinkURL">
                              <xsl:call-template name="linkQueryURL">
                                  <xsl:with-param name="id" select="./@xlink:href" />
                                 <xsl:with-param name="type" select="'institution'" />
                              </xsl:call-template>
                          </xsl:variable>
                          <xsl:for-each select="document($institutionlinkURL)/mcr_results/mcr_result/mycoreobject">
                              <xsl:element name="cc:universityOrInstitution">
                                  <xsl:element name="cc:name">
                                      <xsl:value-of select="./metadata/names/name[@xml:lang='de' and @inherited='1']/fullname" />
                                  </xsl:element>
                                  <xsl:element name="cc:place">
                                      <xsl:value-of select="./metadata/addresses/address[@xml:lang='de' and @inherited='1']/city" />
                                  </xsl:element>
                                  <xsl:element name="cc:department">
                                    <xsl:element name="cc:name">
                                        <xsl:value-of select="./metadata/names/name[@xml:lang='de' and @inherited='0']/fullname" />
                                    </xsl:element>
                                    <xsl:element name="cc:place">
                                        <xsl:value-of select="./metadata/addresses/address[@xml:lang='de' and @inherited='0']/city" />
                                    </xsl:element>
                                    </xsl:element>
                              </xsl:element>
                          </xsl:for-each>
        <!- WORKAROUND ->

          <xsl:element name="cc:universityOrInstitution">
            <xsl:element name="cc:name">
              <xsl:value-of select="'Universität Rostock'" />
            </xsl:element>
            <xsl:element name="cc:place">
              <xsl:value-of select="'18051 Rostock'" />
            </xsl:element>
          </xsl:element>


        <!- WORKAROUND ENDE    ->

                      </xsl:for-each>
                   </xsl:element> -->
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
                        <xsl:text>FXXXX-XXXX</xsl:text>
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
