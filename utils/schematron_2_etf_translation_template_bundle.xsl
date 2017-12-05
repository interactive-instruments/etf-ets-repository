<?xml version="1.0" encoding="UTF-8"?>
<!-- ########################################################################################## -->
<!--
    This stylesheet can be used to transform a Schematron file to an ETF version 2.0.x
    Translation Template Bundle.
    
    Please note that manual modifications may be required.

    Created by Jon Herrmann, (c) 2017 interactive instruments GmbH. This file is licensed
    under the European Union Public Licence 1.2
-->
<!-- ########################################################################################## -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uuid="http://www.uuid.org"
    xmlns:etf="http://www.interactive-instruments.de/etf/2.0"
    xmlns:ii="http://www.interactive-instruments.de"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    exclude-result-prefixes="uuid xs sch"
    version="2.0">
    <xsl:param name="translationTemplateId">
        <xsl:message terminate="yes">Set the Translation Template Bundle EID from the generated ETS file (look for the 'ref' attribute in the 'etf:translationTemplateBundle' element)</xsl:message>
        <xsl:value-of select="''"/>
    </xsl:param>
    <xsl:template match="/sch:schema">
        <TranslationTemplateBundle xmlns="http://www.interactive-instruments.de/etf/2.0" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            id="EID{replace($translationTemplateId, 'EID', '')}"
            xsi:schemaLocation="http://www.interactive-instruments.de/etf/2.0 http://resources.etf-validator.net/schema/v2/service/service.xsd">
            <xsl:variable name="etsLabel">
                <xsl:choose>
                    <xsl:when test="sch:title"><xsl:value-of select="sch:title"/></xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('Schematron ', substring-before(tokenize(base-uri(), '/')[last()], '.') )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:comment>Generated from '<xsl:value-of select="$etsLabel"/>' on <xsl:value-of select="current-dateTime()"/></xsl:comment>
            <xsl:comment>This Translation Template Bundle extends the standard error messages from Translation Template Bundle EID27117afb-11aa-4e45-aa3d-0e1e65bdccb8</xsl:comment>
            <xsl:comment>Translation Template Bundle EID27117afb-11aa-4e45-aa3d-0e1e65bdccb8 can be downloaded from:</xsl:comment>
            <xsl:comment>https://raw.githubusercontent.com/interactive-instruments/etf-ets-repository/master/generic/include-metadata/TranslationTemplateBundle-EID27117afb-11aa-4e45-aa3d-0e1e65bdccb8.xml</xsl:comment>
            <etf:parent ref="EID27117afb-11aa-4e45-aa3d-0e1e65bdccb8" xsi:type="loc"/>
            <translationTemplateCollections>   
            <xsl:for-each select="sch:pattern[not(@abstract = 'true')]">
                <xsl:variable name="testModulePos" select="position()"/>
                <xsl:for-each select="sch:rule[not(@abstract = 'true')]">
                    <xsl:variable name="testCasePos" select="position()"/>
                    <xsl:for-each select="sch:assert">
                        <xsl:variable name="errorTR" select="concat('TR.schtron.', 
                            translate($etsLabel,' ','.'), '.err.', $testModulePos, '.', $testCasePos, '.', position())"/>
                        <xsl:variable name="errorTextWithTokens">
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="@select">
                                        <xsl:value-of select="concat('{', translate(@select, '$()= ', ''), '}')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(translate(string(),'''', '&quot;'))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="lang" select="if (@xml:lang) then @xml:lang else 'en'"/>
                        <LangTranslationTemplateCollection name="{$errorTR}">
                            <translationTemplates>
                                <TranslationTemplate language="{$lang}" name="{$errorTR}">XML document '{filename}': <xsl:value-of select="string-join($errorTextWithTokens, '')"/></TranslationTemplate>
                            </translationTemplates>
                        </LangTranslationTemplateCollection>      
                      </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
            </translationTemplateCollections>
        </TranslationTemplateBundle>
    </xsl:template>
</xsl:stylesheet>
