<?xml version="1.0" encoding="UTF-8"?>
<!-- ########################################################################################## -->
<!--
    This stylesheet can be used to transform a Schematron file to an ETF version 2.0.x
    Executable Test Suite.
    
    Please note that test expressions may be adjusted manually.

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

    <xsl:include href="uuid.xsl"/>
    <xsl:param name="etsId">
        <xsl:message terminate="no">Optional $etsId parameter not set. The parameter has to be set if an existing ETS is updated, in order to provide consistent IDs in ETF</xsl:message>
        <xsl:value-of select="uuid:randomUUID(.)"/>
    </xsl:param>
    <!-- Mandatory if etsId is set otherwise version 1.0.0 is set -->
    <xsl:param name="etsVersion">
        <xsl:if test="not($etsId)">
            <xsl:message terminate="yes">$etsId parameter set but not $etsVersion parameter: Set the new version of this ETS (1.0.0 -> 1.1.0)</xsl:message>
        </xsl:if>
        <xsl:value-of select="'1.0.0'"/>
    </xsl:param>
    <!-- Mandatory if etsId is set otherwise a random EID is generated -->
    <xsl:param name="translationTemplateId">
        <xsl:if test="not($etsId)">
            <xsl:message terminate="yes">$etsId parameter set but not $translationTemplateId parameter: Reference an exisiting Translation Template Bundle</xsl:message>
        </xsl:if>
        <xsl:value-of select="uuid:randomUUID(.)"/>
    </xsl:param>
    <!-- Optional -->
    <xsl:param name="tagId"/>
    
    
    <xsl:function name="ii:schVars">
        <xsl:param name="node" as="node()"/>
        <!-- &#10; is the new line character -->
        <xsl:for-each select="$node/sch:let">
            <xsl:value-of select="concat('let $', @name, ' := ', @value, '&#10;')"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:template match="/sch:schema">
        
        <xsl:variable name="schemaLevelVars" select="ii:schVars(.)" />

        <etf:ExecutableTestSuite xmlns="http://www.interactive-instruments.de/etf/2.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            id="EID{replace($etsId, 'EID', '')}"
            xsi:schemaLocation="http://www.interactive-instruments.de/etf/2.0 http://resources.etf-validator.net/schema/v2/service/service.xsd">
            <itemHash>bQ==</itemHash>
            <remoteResource>https://github.com/interactive-instruments/etf-ets-repository</remoteResource>
            <localPath>/auto</localPath>
            <xsl:variable name="etsLabel">
                <xsl:choose>
                    <xsl:when test="sch:title"><xsl:value-of select="sch:title"/></xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('Schematron ', substring-before(tokenize(base-uri(), '/')[last()], '.') )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <label><xsl:value-of select="$etsLabel"/></label>
            <description><xsl:value-of select="if(sch:p) then sch:p else '...'"/></description>
            <reference>../example-bsxets.xq</reference>
            <version><xsl:value-of select="$etsVersion"/></version>
            <author>See original schematron file</author>
            <creationDate><xsl:value-of select="current-dateTime()"/></creationDate>
            <lastEditor>ETF Schematron to ETF Executable Test Suite Transformer</lastEditor>
            <lastUpdateDate><xsl:value-of select="current-dateTime()"/></lastUpdateDate>
            <!-- See Example Tag in the include-metadata directory -->
            <xsl:choose>
                <xsl:when test="$tagId">
                    <tags><tag ref="EID{replace($tagId, 'EID', '')}"/></tags>
                </xsl:when>
                <xsl:otherwise><xsl:message terminate="no">tagId not set</xsl:message></xsl:otherwise>
            </xsl:choose>
            <!-- Test driver for BaseX -->
            <testDriver ref="EID4dddc9e2-1b21-40b7-af70-6a2d156ad130"/>
            <!-- See Translation Template in include-metadata directory -->
            <translationTemplateBundle ref="EID{replace($translationTemplateId, 'EID', '')}"/>
            <ParameterList name="ETF Standard Parameters for XML test objects">
                <parameter name="files_to_test" required="true">
                    <defaultValue>.*</defaultValue>
                    <description ref="TR.filesToTest"/>
                    <allowedValues>.*</allowedValues>
                    <type>string</type>
                </parameter>
                <parameter name="tests_to_execute" required="false">
                    <defaultValue>.*</defaultValue>
                    <description ref="TR.testsToExecute"/>
                    <allowedValues>.*</allowedValues>
                    <type>string</type>
                </parameter>
            </ParameterList>
            <supportedTestObjectTypes>
                <!-- Type GML feature collections, see http://docs.etf-validator.net/Developer_manuals/Developing_Executable_Test_Suites.html#basex-test-object-types -->
                <testObjectType ref="EIDe1d4a306-7a78-4a3b-ae2d-cf5f0810853e"/>
            </supportedTestObjectTypes>
            <testModules>
                <xsl:for-each select="sch:pattern[not(@abstract = 'true')]">
                    <xsl:variable name="testModuleEid" select="concat('EID', uuid:randomUUID(.))"/>
                    <xsl:variable name="patternLevelVars" select="string-join(($schemaLevelVars, ii:schVars(.)), '')" />
                    <xsl:variable name="testModulePos" select="position()"/>
                    <TestModule id="{$testModuleEid}">
                        <label><xsl:value-of select="if(sch:title) then sch:title else if (@fpi) then @fpi else concat('Schematron pattern ', position())"/></label>
                        <description><xsl:value-of select="if(sch:p) then sch:p else '...'"/></description>
                        <!-- ID of the Executable Test Suite -->
                        <parent ref="EID{$etsId}"/>
                        <testCases>
                            <xsl:for-each select="sch:rule[not(@abstract = 'true')]">
                                <xsl:variable name="schContext" select="@context"/>
                                <xsl:variable name="testCaseEid" select="concat('EID', uuid:randomUUID(.))"/>
                                <xsl:variable name="ruleLevelVars" select="string-join(($patternLevelVars, ii:schVars(.)), '')" />
                                <xsl:variable name="testCasePos" select="position()"/>
                                <TestCase id="{$testCaseEid}">
                                    <label><xsl:value-of select="if(@id) then @id else if(sch:fpi) then sch:fpi else concat('Test Case ', $testCasePos)"/></label>
                                    <description>...</description>
                                    <parent ref="{$testModuleEid}"/>
                                    <testSteps>
                                        <xsl:variable name="wrappedNode"><w><xsl:value-of select="uuid:randomUUID(.)"/></w></xsl:variable>
                                        <xsl:variable name="testStepEid" select="concat('EID', uuid:randomUUID($wrappedNode))"/>
                                        <TestStep id="{$testStepEid}">
                                            <label>IGNORE</label>
                                            <description>IGNORE</description>
                                            <parent ref="{$testCaseEid}"/>
                                            <statementForExecution>not applicable</statementForExecution>
                                            <testItemType ref="EIDf483e8e8-06b9-4900-ab36-adad0d7f22f0"/>
                                            <testAssertions>
                                                <xsl:for-each select="sch:assert">
                                                    <xsl:variable name="testAssertionEid" select="uuid:randomUUID(.)"/>
                                                    <xsl:variable name="errorTR" select="concat('TR.schtron.', 
                                                        translate($etsLabel,' ','.'), '.err.', $testModulePos, '.', $testCasePos, '.', position())"/>
                                                    <TestAssertion id="EID{$testAssertionEid}">
                                                        <label><xsl:value-of select="if(@id) then @id else concat('Assertion ', position())"/></label>
                                                        <!-- Known restriction: variables are no replaced -->
                                                        <description><xsl:value-of select="./text()"/></description>
                                                        <parent ref="{$testStepEid}"/>
                                                        <expectedResult>NOT_APPLICABLE</expectedResult>
                                                        
                                                        <xsl:variable name="errorTokens">
                                                            <xsl:for-each select="sch:value-of">
                                                                <xsl:value-of select="if (position() = 1) then ', ' else ''"/>
                                                                <xsl:value-of select="concat('''', translate(@select, '$()=-+ ', ''), ''': ', @select)" />
                                                                <xsl:value-of select="if (position() != last()) then ', ' else ''"/>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        
                                                        <expression>
                                                            <xsl:value-of select="$ruleLevelVars"/>
                                                            
                                                            let $filesWithErrors := $db[<xsl:value-of select="$schContext"/>[not(<xsl:value-of select="@test"/>)]]
                                                            return
                                                            (if ($filesWithErrors) then 'FAILED' else 'PASSED',
                                                            local:error-statistics('TR.filesWithErrors', count($filesWithErrors)),
                                                            for $file in $filesWithErrors
                                                            order by local:filename($file)
                                                            let $root := $file/element()
                                                            return
                                                            local:addMessage('<xsl:value-of select="$errorTR"/>', map { 'filename': local:filename($root) <xsl:value-of select="$errorTokens"/> }))
                                                        </expression>
                                                        <testItemType ref="EIDf0edc596-49d2-48d6-a1a1-1ac581dcde0a"/>
                                                    </TestAssertion>
                                                </xsl:for-each>
                                            </testAssertions>
                                        </TestStep>
                                    </testSteps>
                                </TestCase>
                            </xsl:for-each>
                        </testCases>
                    </TestModule>
                </xsl:for-each>
            </testModules>
        </etf:ExecutableTestSuite>



    </xsl:template>


</xsl:stylesheet>
