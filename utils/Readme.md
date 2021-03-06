# Utilities

This directory contains 3 stylesheets that can be used to:
- transform a Schematron file to an ETF version 2 Executable Test Suite and an
 ETF version 2 Translation Template Bundle
- transform the structure of an old ETF version 1 BaseX based test project file
 to an ETF version 2 Executable Test Suite
 Executable Test Suite (manual modification are required afterwards!)

All stylesheets were tested with Saxon HE 9.7.

## Schematron
### Transform a Schematron 1.0 file to an ETF version 2 Executable Test Suite
Use a XSL Transformer  with the [schematron_2_etf_ets.xsl](schematron_2_etf_ets.xsl)
Stylesheet and set the Schematron file as input file.
The generated Executable Test Suite must be inserted into a new file with the
name pattern `<Name of ETS without whitespaces>-bsxets.xml`. Take the
ID from the Executable Test Suite and pass it as parameter
`translationTemplateId` to the Stylesheet
[schematron_2_etf_translation_template_bundle.xsl](schematron_2_etf_translation_template_bundle.xsl).
The generated Translation Template Bundle must be inserted into a new file with
the name pattern
`TranslationTemplateBundle-<EID of TranslationTemplateBundle>.xml`.

#### Generating multiple TranslationTemplateBundles (!)
If multiple TranslationTemplateBundles are generated, they must be merged into
one. The names of the TranslationTemplates must be unique. This can be verified
by validating the resulting files with a XSD validator.

#### Restrictions of the Schematron to XQuery transformation
* XPath 3.1, used by XQuery 3.1, is not fully backwards compatible with XPath 1.0 and 2.0 (used by the xslt and xslt2 query bindings of Schematron).  Annex H of the XPath 3.1 standard documents the incompatibilities.
  * See https://www.w3.org/TR/xpath-31/#id-incompatibilities
  * The book "XQuery - Search Across a Variety of XML Data", 2nd ed, has a chapter on "XQuery for XSLT Users" that also discusses XQuery backward compatibility with XPath 1.0.
* The following language constructs supported by Schematron and the Schematron xslt and xslt2 query bindings are not translated:
  * xsl:key
  * abstract rules
  * inclusions
  * abstract patterns and parameters
  * phases
  * reports
  * diagnostics
* The XSLT function current() is always translated to '.'. No explicit reference is made to a particular document or rule context.

### Update an existing  ETF version 2 Executable Test Suite from a Schematron file
If a Schematron file changed and the changes have to be reflected in an already
generated and deployed Executable Test Suite, the ETS can be regenerated.
In order to provide consistent IDs in the framework, the parameter `etsId`
of the [schematron_2_etf_ets.xsl](schematron_2_etf_ets.xsl) Stylesheet has to
be set to the ID of the existing ETS and the parameter `etsVersion` has
to be set to a new Version number (for instance if the version was 1.0.0 before
the version number should be increased to 1.0.1 or even 1.1.0). The parameter
`translationTemplateId` has to be set to the ID of the previous generated
Translation Template Bundle. The `translationTemplateId` must be provided
for both Stylesheets; [schematron_2_etf_ets.xsl](schematron_2_etf_ets.xsl) and
[schematron_2_etf_translation_template_bundle.xsl](schematron_2_etf_translation_template_bundle.xsl). Afterwards the generated ETS file and the Translation Template Bundle can be copied into the project folder of the ETF instance, to override the two existing files.


## Transform ETF version 1 test project to ETF version 2 Executable Test Suite
Use a XSL Transformer with the [etf_v1_2_v2.xsl](etf_v1_2_v2.xsl)
Stylesheet and set the old ETF v1 test project as input file.
For each Assertion Group an etf:ExecutableTestSuite will be generated.
Each ExecutableTestSuite must be inserted into a new file and the dependencies
must be set manually, as well as all test expressions. The Stylesheet cannot
be used to transform SoapUI based ETF version 1 test projects.
