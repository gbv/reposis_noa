<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs fn">
    
    <xsl:output method="xml"
                version="1.0"
                encoding="UTF-8"
                indent="yes" />

    <xsl:strip-space elements="*" />

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:variable name="lang" select="'en'" />

    <xsl:template match="mods:mods">
        <mods:mods version="3.6">
            <xsl:apply-templates />
            <mods:classification displayLabel="publication type" authorityURI="http://www.noa-gwlb.de/classifications/noa_pubtype" valueURI="http://www.noa-gwlb.de/classifications/noa_pubtype#pflichtexemplar" />
            <xsl:if test="count(mods:typeOfResource) = 0">
                <mods:typeOfResource>text</mods:typeOfResource>
            </xsl:if>
        </mods:mods>
    </xsl:template>

    <xsl:template match="mods:relatedItem">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
            <mods:classification displayLabel="publication type"
                                 authorityURI="http://www.noa-gwlb.de/classifications/noa_pubtype"
                                 valueURI="http://www.noa-gwlb.de/classifications/noa_pubtype#pflichtexemplar"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mods:detail/mods:caption">
    </xsl:template>

    <xsl:template match="mods:titleInfo">
        <mods:titleInfo xml:lang="{$lang}">
            <mods:title><xsl:value-of select="mods:title"/></mods:title>
        </mods:titleInfo>
    </xsl:template>

    <xsl:template match="mods:roleTerm[@authority='marcrelator'][@type='text']">
        <mods:roleTerm authority="marcrelator" type="code">
            <xsl:choose>
                <xsl:when test="text()='author'">aut</xsl:when>
            </xsl:choose>
        </mods:roleTerm>
    </xsl:template>
    
    <xsl:template match="mods:genre">
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres">
            <xsl:attribute name="valueURI">
                <xsl:choose>
                    <xsl:when test="text()='article'">http://www.mycore.org/classifications/mir_genres#article</xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </mods:genre>

    </xsl:template>
    
    <xsl:template match="mods:mods/mods:originInfo">
        <mods:originInfo eventType="publication">
            <xsl:choose>
                <xsl:when test="mods:publisher">
                    <mods:publisher><xsl:value-of select="mods:publisher"/></mods:publisher>
                </xsl:when>
                <xsl:when test="../mods:relatedItem/mods:originInfo/mods:publisher">
                    <mods:publisher><xsl:value-of select="../mods:relatedItem/mods:originInfo/mods:publisher"/></mods:publisher>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="string-length(mods:dateIssued[@encoding='w3cdtf'])&gt;4">
                    <mods:dateIssued encoding="w3cdtf"><xsl:value-of select="mods:dateIssued[@encoding='w3cdtf']"/></mods:dateIssued>
                </xsl:when>
                <xsl:when test="../mods:relatedItem/mods:part/mods:text[@type='year'] and ../mods:relatedItem/mods:part/mods:text[@type='month']">
                    <mods:dateIssued encoding="w3cdtf"><xsl:value-of select="concat(../mods:relatedItem/mods:part/mods:text[@type='year'],'-',../mods:relatedItem/mods:part/mods:text[@type='month'])" /></mods:dateIssued>
                </xsl:when>
                <xsl:when test="mods:dateIssued[@encoding='w3cdtf']">
                    <mods:dateIssued encoding="w3cdtf"><xsl:value-of select="mods:dateIssued[@encoding='w3cdtf']"/></mods:dateIssued>
                </xsl:when>
                <xsl:when test="../mods:relatedItem/mods:part/mods:text[@type='year']">
                    <mods:dateIssued encoding="w3cdtf"><xsl:value-of select="../mods:relatedItem/mods:part/mods:text[@type='year']" /></mods:dateIssued>
                </xsl:when>
            </xsl:choose>
        </mods:originInfo>
    </xsl:template>
    
    <xsl:template match="mods:language">
        <mods:language>
            <mods:languageTerm authority="rfc5646" type="code"><xsl:value-of select="$lang"/></mods:languageTerm>
        </mods:language>
    </xsl:template>
    
    <xsl:template match="mods:abstract">
        <mods:abstract xml:lang="{$lang}"><xsl:value-of select="."/></mods:abstract>
    </xsl:template>


    <xsl:template match="mods:accessCondition[@type='use and reproduction']">
        <xsl:choose>
            <xsl:when test="contains(@xlink:href, 'licenses/by/3.0/')">
                <mods:accessCondition type="use and reproduction" xlink:href="http://www.mycore.org/classifications/mir_licenses#cc_by_3.0" />
            </xsl:when>
            <xsl:when test="contains(@xlink:href, 'licenses/by/4.0/')">
                <mods:accessCondition type="use and reproduction" xlink:href="http://www.mycore.org/classifications/mir_licenses#cc_by_4.0" />
            </xsl:when>
            <xsl:otherwise>
                <mods:accessCondition type="use and reproduction" xlink:href="http://www.mycore.org/classifications/mir_licenses#oa" >
                    <xsl:value-of select="@xlink:href" />
                </mods:accessCondition>
            </xsl:otherwise>
        </xsl:choose>
        <mods:accessCondition type="restriction on access" xlink:href="http://www.mycore.org/classifications/mir_access#unlimited" xlink:type="simple" />
    </xsl:template>
    
    <xsl:template match="mods:identifier[@type='issn']">
        <mods:identifier type="issn"><xsl:value-of select="."/></mods:identifier>
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#journal" />
    </xsl:template>
    
    <xsl:template match="mods:text">
        <!-- do nothing -->
    </xsl:template>

</xsl:stylesheet>