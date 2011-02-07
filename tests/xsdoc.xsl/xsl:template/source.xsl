<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">
    
    <xd:doc>
        <xd:short>xsl:template</xd:short>
    </xd:doc>
    
    <xd:doc xd:target="following">
        <xd:short>Identity template</xd:short>
        <xd:param name="myParam">My parameter</xd:param>
    </xd:doc>
    <xsl:template match="@*|node()" mode="myMode" name="myName" priority="2">
        <xsl:param name="myParam" required="yes" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
