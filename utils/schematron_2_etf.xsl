<?xml version="1.0" encoding="UTF-8"?>
<!-- ########################################################################################## -->
<!--
    This stylesheet can be used to transform a Schematron file to an ETF version 2.0.x
    Executable Test Suite. Please note that test expressions may be adjusted manually.

    Created by Jon Herrmann, (c) 2017 interactive instruments GmbH. This file is licensed
    under the European Union Public Licence 1.2
-->
<!-- ########################################################################################## -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uuid="http://www.uuid.org"
    xmlns:etf="http://www.interactive-instruments.de/etf/2.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    exclude-result-prefixes="uuid xs sch"
    version="2.0">

    <xsl:include href="uuid.xsl"/>
    <!-- xmlns:uuid="java.util.UUID" -->
    <xsl:param name="translationTemplateId" select="uuid:randomUUID()"/>
    <xsl:param name="tagId" select="uuid:randomUUID()"/>

    <xsl:template match="/sch:schema">

        <xsl:variable name="etsEid" select="uuid:randomUUID()"/>

        <etf:ExecutableTestSuite xmlns="http://www.interactive-instruments.de/etf/2.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            id="EID{$etsEid}"
            xsi:schemaLocation="http://www.interactive-instruments.de/etf/2.0 http://resources.etf-validator.net/schema/v2/service/service.xsd">
            <itemHash>bQ==</itemHash>
            <remoteResource>https://github.com/interactive-instruments/etf-ets-repository</remoteResource>
            <localPath>/auto</localPath>
            <label><xsl:value-of select="if(sch:title) then sch:title else 'Schematron'"/></label>
            <description><xsl:value-of select="if(sch:p) then sch:p else '...'"/></description>
            <reference>../example-bsxets.xq</reference>
            <version>2.0.0</version>
            <author>See original schematron file</author>
            <creationDate><xsl:value-of select="current-dateTime()"/></creationDate>
            <lastEditor>ETF Schematron to ETF Executable Test Suite Transformer</lastEditor>
            <lastUpdateDate><xsl:value-of select="current-dateTime()"/></lastUpdateDate>
            <!-- See Example Tag in the include-metadata directory -->
            <tags>
                <tag ref="EID{$tagId}"/>
            </tags>
            <!-- Test driver for BaseX -->
            <testDriver ref="EID4dddc9e2-1b21-40b7-af70-6a2d156ad130"/>
            <!-- See Translation Template in include-metadata directory -->
            <translationTemplateBundle ref="EID{$translationTemplateId}"/>
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
                    <xsl:variable name="testModuleEid" select="uuid:randomUUID()"/>
                    <TestModule id="EID{$testModuleEid}">
                        <label><xsl:value-of select="if(sch:title) then sch:title else if (@fpi) then @fpi else concat('Schematron pattern ', position())"/></label>
                        <description><xsl:value-of select="if(sch:p) then sch:p else '...'"/></description>
                        <!-- ID of the Executable Test Suite -->
                        <parent ref="EID{$etsEid}"/>
                        <testCases>
                            <xsl:for-each select="sch:rule[not(@abstract = 'true')]">
                                <xsl:variable name="schContext" select="@context"/>
                                <xsl:variable name="testCaseEid" select="uuid:randomUUID()"/>
                                <TestCase id="EID{$testCaseEid}">
                                    <label><xsl:value-of select="if(@id) then @id else if(sch:fpi) then sch:fpi else concat('Test Case ', position())"/></label>
                                    <description>...</description>
                                    <parent ref="EID{$testModuleEid}"/>
                                    <testSteps>
                                        <xsl:variable name="testStepEid" select="uuid:randomUUID()"/>
                                        <TestStep id="EID{$testStepEid}">
                                            <label>IGNORE</label>
                                            <description>IGNORE</description>
                                            <parent ref="EID{$testModuleEid}"/>
                                            <statementForExecution>not applicable</statementForExecution>
                                            <testItemType ref="EIDf483e8e8-06b9-4900-ab36-adad0d7f22f0"/>
                                            <testAssertions>
                                                <xsl:for-each select="sch:assert">
                                                    <xsl:variable name="testAssertionEid" select="uuid:randomUUID()"/>
                                                    <TestAssertion id="EID{$testAssertionEid}">
                                                        <label><xsl:value-of select="if(@id) then @id else concat('Assertion ', position())"/></label>
                                                        <description><xsl:value-of select="./text()"/></description>
                                                        <parent ref="EID{$testStepEid}"/>
                                                        <expectedResult>NOT_APPLICABLE</expectedResult>
                                                        <expression>
                                                            let $filesWithErrors := $db[<xsl:value-of select="$schContext"/>[not(<xsl:value-of select="@test"/>)]]
                                                            return
                                                            (if ($filesWithErrors) then 'FAILED' else 'PASSED',
                                                            local:error-statistics('TR.filesWithErrors', count($filesWithErrors)),
                                                            for $file in $filesWithErrors
                                                            order by local:filename($file)
                                                            let $root := $file/element()
                                                            return
                                                            local:addMessage('TR.schematronError', map { 'filename': local:filename($root), 'error': '<xsl:value-of select="./text()"/>' }))
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
