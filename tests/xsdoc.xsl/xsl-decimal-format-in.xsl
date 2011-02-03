<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">

    <xd:doc>
        <xd:short>xsl:decimal-format</xd:short>
    </xd:doc>

    <xd:doc xd:target="following">
        <xd:short>Decimal format for the "Euro"-currency (€).</xd:short>
    </xd:doc>
    <xsl:decimal-format name="euro" decimal-separator="," grouping-separator="."/>

</xsl:stylesheet>
