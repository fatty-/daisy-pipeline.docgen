<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mynamespace="http://example.org"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">

    <xd:doc>
        <xd:short>xd:function</xd:short>
    </xd:doc>

    <xd:doc target="following">
        <xd:short>Test function</xd:short>
        <xd:detail>Contains one undocumented and one documented parameter, as well as a documented
            return value.</xd:detail>
        <xd:param name="myParam">This is a parameter.</xd:param>
        <xd:return>This function returns something.</xd:return>
    </xd:doc>
    <xsl:function name="mynamespace:myFunction">
        <xsl:param name="myParam" tunnel="no" as="xs:string"/>
        <xsl:param name="myOtherParam"/>
        <xsl:value-of select="'myValue'"/>
    </xsl:function>

</xsl:stylesheet>
