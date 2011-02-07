<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    version="2.0">

    <xsl:import-schema>
        <xs:schema targetNamespace="http://example.org">
            <xs:simpleType name="yes-no">
                <xs:restriction base="xs:string">
                    <xs:enumeration value="yes"/>
                    <xs:enumeration value="no"/>
                </xs:restriction>
            </xs:simpleType>
        </xs:schema>
    </xsl:import-schema>

    <xd:doc xd:target="parent">
        <xd:short>xsl:import-schema</xd:short>
        <xd:detail>Imported Schemas should probably be automatically documented...?</xd:detail>
    </xd:doc>

</xsl:stylesheet>
