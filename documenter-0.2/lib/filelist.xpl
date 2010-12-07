<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:d="http://www.example.org/documenter"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" type="d:listFiles" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Lists all files in the module.</xd:short>
        <xd:detail>Uses recursive-directory-list.xpl to get a structure containing all files in the
            module, then flattens it and returns it.</xd:detail>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:copyright>
            <xd:year>2010</xd:year>
            <xd:holder>DAISY Consortium</xd:holder>
        </xd:copyright>
        <xd:option name="path">full path to the target folder</xd:option>
        <xd:option name="depth">Depth to search for files. Are simply passed on to the underlying
            cx:recursive-directory-list step.</xd:option>
        <xd:output port="result">Gives out a flat list of files on the form: &lt;c:directory&gt;
            &lt;c:file relative="relative from $path" name="filename"/&gt; &lt;c:file
            relative="relative from $path" name="filename"/&gt; &lt;c:file relative="relative from
            $path" name="filename"/&gt; &lt;/c:directory&gt;</xd:output>
    </p:documentation>

    <p:option name="path" required="true"/>
    <p:option name="depth" required="false" select="-1"/>

    <p:output port="result" primary="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="recursive-directory-list.xpl"/>

    <p:documentation xd:target="following">
        <xd:short>Get list of all files</xd:short>
        <xd:detail>Uses recursive-directory-list to retrieve a structure of all files in the
            module.</xd:detail>
        <xd:option name="path">Path to the directory in the module containing the source
            files.</xd:option>
        <xd:option name="depth">How deep to recurse. -1 is default, and means that there's no
            limit.</xd:option>
    </p:documentation>
    <cx:recursive-directory-list>
        <p:with-option name="path" select="$path"/>
        <p:with-option name="depth" select="$depth"/>
    </cx:recursive-directory-list>

    <p:documentation xd:target="following">
        <xd:short>Flatten list of files</xd:short>
    </p:documentation>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    exclude-result-prefixes="cx fn d xd">

                    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
                        omit-xml-declaration="yes"/>

                    <xsl:template match="/c:directory">
                        <xsl:copy>
                            <xsl:apply-templates>
                                <!--xsl:with-param name="path" select="@name"/-->
                                <xsl:with-param name="path" select="'.'"/>
                            </xsl:apply-templates>
                        </xsl:copy>
                    </xsl:template>

                    <xsl:template match="c:directory">
                        <xsl:param name="path" select="''"/>
                        <xsl:variable name="newPath" select="''"/>
                        <xsl:apply-templates>
                            <xsl:with-param name="path" select="concat($path,'/',@name)"/>
                        </xsl:apply-templates>
                    </xsl:template>

                    <xsl:template match="c:file">
                        <xsl:param name="path"/>
                        <xsl:variable name="newPath" select="concat($path,'/',@name)"/>
                        <xsl:copy>
                            <xsl:attribute name="relative">
                                <xsl:value-of select="replace($newPath,'^\./','')"/>
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                            </xsl:attribute>
                            <xsl:apply-templates>
                                <xsl:with-param name="path" select="$newPath"/>
                            </xsl:apply-templates>

                        </xsl:copy>
                    </xsl:template>

                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
</p:declare-step>
