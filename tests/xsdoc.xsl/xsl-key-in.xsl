<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0">

    <xd:doc>
        <xd:short>xsl:key</xd:short>
        <xd:detail>xsl:keys should be documented automatically.</xd:detail>
    </xd:doc>
    
    <xsl:key name="preg" match="person" use="@id"/>
    
</xsl:stylesheet>