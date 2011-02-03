<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">

    <xd:doc>
        <xd:short>xsl:param</xd:short>
        <xd:param name="myDocumentedParam">A parameter with documentation.</xd:param>
    </xd:doc>
    
    <xsl:param name="myDocumentedParam" select="'myDocumentedValue'" required="no" tunnel="no"/>
    <xsl:param name="myUndocumentedParam" required="yes" tunnel="no" exclude-result-prefixes="#all"/>

</xsl:stylesheet>
