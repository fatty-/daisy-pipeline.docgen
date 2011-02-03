<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mynamespace="http://example.org" version="2.0">

    <xd:doc target="following">
         <xd:return>This function returns something.</xd:return>
    </xd:doc>
    
    <xsl:function name="mynamespace:myFunction">
        <xsl:value-of select="'myValue'"/>
    </xsl:function>

</xsl:stylesheet>
