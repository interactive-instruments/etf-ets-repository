<?xml version="1.0" encoding="UTF-8"?>
<!-- ########################################################################################## -->
<!--
    This stylesheet can be used to transform an ETF version 1.0.x assertion file to an ETF 
    version 2.0.x Executable Test Suite. 
    
    Please note that only the model structure is mapped, XQuery test expressions must be adjusted
    manually.
    
    Created by Jon Herrmann, (c) 2017 interactive instruments GmbH. This file is licensed 
    under the European Union Public Licence 1.2 
-->
<!-- ########################################################################################## -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uuid="http://www.uuid.org"
    xmlns:etf="http://www.interactive-instruments.de/etf/2.0"
    exclude-result-prefixes="uuid xs"
    version="2.0">
   
    <xsl:include href="uuid.xsl"/>
    <xsl:param name="translationTemplateId" select="uuid:randomUUID()"/>
    <xsl:param name="tagId" select="uuid:randomUUID()"/>
    
    <xsl:template match="/Assertions">
        
        <xsl:for-each select="Group">
            <xsl:variable name="etsEid" select="uuid:randomUUID()"/>
            
            <etf:ExecutableTestSuite xmlns="http://www.interactive-instruments.de/etf/2.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                id="EID{$etsEid}"
                xsi:schemaLocation="http://www.interactive-instruments.de/etf/2.0 http://resources.etf-validator.net/schema/v2/service/service.xsd">
                <itemHash>bQ==</itemHash>
                <remoteResource>https://github.com/interactive-instruments/etf-ets-repository</remoteResource>
                <localPath>/auto</localPath>
                <label><xsl:value-of select="Group/name"/></label>
                <description>...</description>
                <reference>../example-bsxets.xq</reference>
                <version>2.0.0</version>
                <author><xsl:value-of select="Group/author"/></author>
                <creationDate><xsl:value-of select="Group/creationDate"/></creationDate>
                <lastEditor>ETF v1 project to ETF v2 Executable Test Suite Transformer</lastEditor>
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
                    <xsl:variable name="testModuleEid" select="uuid:randomUUID()"/>
                    <TestModule id="EID{$testModuleEid}">
                        <!-- If a TestModule is labeled with IGNORE, it is not shown in the Report -but the children Test Cases  -->
                        <label>IGNORE</label>
                        <description>IGNORE</description>
                        <!-- ID of the Executable Test Suite -->
                        <parent ref="EID{$etsEid}"/>
                        <testCases>
                            <xsl:for-each select="Subgroup">
                                <xsl:variable name="testCaseEid" select="uuid:randomUUID()"/>
                                <xsl:variable name="subGroupId" select="./@id"/>
                                <TestCase id="EID{$testCaseEid}">
                                    <label><xsl:value-of select="name"/></label>
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
                                                <xsl:for-each select="../Assertion[starts-with(@id, $subGroupId)]">
                                                    <xsl:variable name="testAssertionEid" select="uuid:randomUUID()"/>
                                                    <TestAssertion id="EID{$testAssertionEid}">
                                                        <xsl:comment><xsl:value-of select="@id"/></xsl:comment>
                                                        <label><xsl:value-of select="name"/></label>
                                                        <description><xsl:value-of select="description"/></description>
                                                        <parent ref="EID{$testStepEid}"/>
                                                        <expectedResult>NOT_APPLICABLE</expectedResult>
                                                        <expression><xsl:value-of select="expression"/></expression>
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
                </testModules>
            </etf:ExecutableTestSuite>
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>