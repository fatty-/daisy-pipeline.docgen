<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0">

    <xd:doc>
        <xd:short>xd:character-map</xd:short>
    </xd:doc>
    
    <xd:doc xd:target="following">
        <xd:short>Character map</xd:short>
    </xd:doc>
    <xsl:character-map name="jsp">
        <xsl:output-character character="«" string="&lt;%"/>   
        <xsl:output-character character="»" string="%&gt;"/>
        <xsl:output-character character="§" string='"'/>
    </xsl:character-map>
    
</xsl:stylesheet>
