<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">
    
    <xd:doc>TODO</xd:doc>
    <xsl:template match="@*|node()" xml:id="identity">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
