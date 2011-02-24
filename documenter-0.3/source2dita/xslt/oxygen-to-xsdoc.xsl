<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">

    <xsl:template match="@*|node()" xml:id="identity">
        <xsl:choose>
            <xsl:when test="ancestor::doc:doc and not(ancestor::*[local-name()='pre']) and self::*">
                <!-- Remove unknown elements from documentation -->
                <xsl:apply-templates select="@*|node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="doc:doc">
        <xsl:element name="xd:doc">
            <xsl:choose>
                <xsl:when test="@scope='stylesheet'">
                    <xsl:attribute name="target" select="'parent'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="target" select="'following'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='desc' and ancestor::doc:doc]">
        <xsl:element name="xd:detail">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='p' and ancestor::doc:doc]">
        <xsl:element name="xd:p">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='pre' and ancestor::doc:doc]">
        <xsl:element name="xd:pre">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='ul' and ancestor::doc:doc]">
        <xsl:element name="xd:ul">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='li' and ancestor::doc:doc]">
        <xsl:element name="xd:li">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='ref' and ancestor::doc:doc]">
        <xsl:variable name="name" select="@name"/>
        <!-- required -->
        <xsl:choose>
            <xsl:when test="@type='variable'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='parameter'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='template'">
                <xsl:choose>
                    <xsl:when test="//xsl:template[@match=$name]">
                        <xsl:element name="xd:a">
                            <xsl:choose>
                                <xsl:when test="//xsl:template[@match=$name][1]/@xml:id">
                                    <xsl:attribute name="href"
                                        select="concat('#',//xsl:template[@match=$name][1]/@xml:id)"
                                    />
                                </xsl:when>
                                <xsl:when test="//xsl:template[@match=$name]/@id">
                                    <xsl:attribute name="href"
                                        select="concat('#',//xsl:template[@match=$name][1]/@id)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href"
                                        select="concat('#',generate-id(//xsl:template[@match=$name][1]))"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='function'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='output'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='decimal-format'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='character-map'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:when test="@type='attributes-set'">
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href" select="'TODO'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='a' and ancestor::doc:doc]">
        <xsl:choose>
            <xsl:when test="@docid">
                <xsl:variable name="docid" select="@docid"/>
                <xsl:choose>
                    <xsl:when test="not(@href)">
                        <xsl:choose>
                            <xsl:when test="//*[@xml:id=$docid or @id=$docid]">
                                <xsl:element name="xd:a">
                                    <xsl:attribute name="href" select="concat('#',$docid)"/>
                                    <xsl:apply-templates/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="xd:a">
                            <xsl:attribute name="href" select="concat(@href,'#',$docid)"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="xd:a">
                    <xsl:attribute name="href" select="@href"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[local-name()='inline' and ancestor::doc:doc]">
        <xsl:element name="xd:section">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='b' and ancestor::doc:doc]">
        <xsl:element name="xd:b">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='i' and ancestor::doc:doc]">
        <xsl:element name="xd:i">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='param' and ancestor::doc:doc]">
        <xsl:element name="xd:param">
            <xsl:apply-templates select="@name"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='return' and ancestor::doc:doc]">
        <xsl:element name="xd:return">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
