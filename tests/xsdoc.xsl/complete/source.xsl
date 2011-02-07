<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mynamespace="http://example.org" version="2.0">

    <xd:doc target="parent">
        <xd:short>Complete test.</xd:short>
        <xd:detail>This example tests as much as possible at the same time.</xd:detail>
        <xd:author>
            <xd:name>First Author</xd:name>
            <xd:mailto>first.author@example.com</xd:mailto>
            <xd:organization>First Author Inc.</xd:organization>
        </xd:author>
        <xd:author>
            <xd:name>Second Author</xd:name>
            <xd:mailto>second.author@example.com</xd:mailto>
            <xd:organization>Second Author Inc.</xd:organization>
        </xd:author>
        <xd:contributor>
            <xd:name>First Contributor</xd:name>
            <xd:mailto>first.contributor@example.com</xd:mailto>
            <xd:organization>First Contributor Inc.</xd:organization>
        </xd:contributor>
        <xd:contributor>
            <xd:name>Second Contributor</xd:name>
            <xd:mailto>second.contributor@example.com</xd:mailto>
            <xd:organization>Second Contributor Inc.</xd:organization>
        </xd:contributor>
        <xd:maintainer>
            <xd:name>First Maintainer</xd:name>
            <xd:mailto>first.maintainer@example.com</xd:mailto>
            <xd:organization>First Maintainer Inc.</xd:organization>
        </xd:maintainer>
        <xd:maintainer>
            <xd:name>Second Maintainer</xd:name>
            <xd:mailto>second.maintainer@example.com</xd:mailto>
            <xd:organization>Second Maintainer Inc.</xd:organization>
        </xd:maintainer>
        <xd:copyright>
            <xd:year>2011</xd:year>
            <xd:name>Copyright Holder</xd:name>
            <xd:mailto>copyright.holder@example.com</xd:mailto>
            <xd:organization>Copyright Holder Inc.</xd:organization>
        </xd:copyright>
        <xd:copyright>
            <xd:year>2011</xd:year>
            <xd:holder>Copyright Holder</xd:holder>
        </xd:copyright>
        <xd:version>1.0</xd:version>
        <xd:since>0.5</xd:since>
        <xd:see>empty-in.xsl</xd:see>
        <xd:see>http://code.google.com/p/daisy-pipeline/wiki/HowTo_Documentation_Technical</xd:see>
        <xd:deprecated>0.9</xd:deprecated>
    </xd:doc>

    <xsl:template match="@*|node()">
        <xd:doc>
            <xd:short>Identity template</xd:short>
        </xd:doc>
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Test function</xd:short>
        <xd:detail>Contains one undocumented and one documented parameter, as well as a documented
            return value.</xd:detail>
        <xd:param name="myParam">This is a parameter.</xd:param>
        <xd:return>This function returns something.</xd:return>
    </xd:doc>
    <xsl:function name="mynamespace:myFunction">
        <xsl:param name="myParam"/>
        <xsl:param name="myOtherParam"/>
        <xsl:value-of select="'myValue'"/>
    </xsl:function>

</xsl:stylesheet>
