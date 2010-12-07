<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
    exclude-result-prefixes="xd" version="2.0">
    <xd:doc target="parent">
        <xd:short>Transforms the input list of DITA files to a table of contents listing all
            files.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:copyright>
            <xd:year>2010</xd:year>
            <xd:holder>DAISY Consortium</xd:holder>
        </xd:copyright>
        <xd:version>0.1</xd:version>
        <xd:see>http://code.google.com/p/daisy-pipeline/</xd:see>
    </xd:doc>

    <xsl:output encoding="UTF-8" method="html" omit-xml-declaration="yes" indent="yes"/>

    <xsl:param name="title" required="yes"/>

    <xd:doc target="following">
        <xd:short>Identity template</xd:short>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Create main HTML structure.</xd:short>
    </xd:doc>
    <xsl:template match="/c:result">
        <html>
            <head>
                <style type="text/css">
                    body {
                        font-family: futura, helvetica, arial, sans-serif;
                    }
                    section, article, header, footer, nav, aside, hgroup {
                        display: block;
                    }
                    ul.toc li {
                        background-position: 0% 50%;
                        background-repeat: no-repeat;
                        font-size: 85%;
                        list-style-type: none;
                        margin: 1px 0px 1px 1px;
                        padding: 1px 0px 1px 11px;
                    }
                    ul.toc li a {
                        text-decoration: none;
                    }
                    a, a:visited, a:hover {
                        color: #009;
                    }</style>
            </head>
            <body>
                <header class="filelist-header">
                    <h1>
                        <xsl:value-of select="$title"/>
                    </h1>
                </header>
                <ul class="toc">
                    <xsl:for-each select="c:result">
                        <!-- for each source file alphabetically -->
                        <xsl:sort select="@rel"/>
                        <!-- split into parent directories ($parts[1..last()-1]) and filename ($parts[last()]) -->
                        <xsl:variable name="parts" select="tokenize(@rel,'/')"/>
                        <xsl:variable name="element" select="."/>
                        <xsl:for-each select="$parts">
                            <!-- path to current parent directory -->
                            <xsl:variable name="dir"
                                select="string-join(subsequence($parts,1,position()),'/')"/>
                            <!-- check if this is the last file in the parent folder -->
                            <!--xsl:variable name="isLastSubFile"
                                select="if (position()=1) then false() else count($element/following-sibling::*[matches(@rel,concat('^',string-join(subsequence($parts,1,position()-1),'/')))])=0"/>
                            <xsl:variable name="isLastSuperDir" select="false()"/-->
                            <xsl:choose>
                                <xsl:when test="position()=last()">
                                    <!-- $parts[last()] is the filename -->
                                    <xsl:apply-templates select="$element">
                                        <xsl:with-param name="indent" select="position()"/>
                                        <!--xsl:with-param name="isLastSubFile" select="$isLastSubFile"/>
                                        <xsl:with-param name="isLastSuperDir"
                                            select="$isLastSuperDir"/-->
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:when
                                    test="count($element/preceding-sibling::*[matches(@rel,concat('^',$dir))])=0">
                                    <xsl:apply-templates select="$element">
                                        <xsl:with-param name="indent" select="position()"/>
                                        <xsl:with-param name="directory" select="."/>
                                        <!--xsl:with-param name="isLastSubFile" select="$isLastSubFile"/>
                                        <xsl:with-param name="isLastSuperDir"
                                            select="$isLastSuperDir"/-->
                                    </xsl:apply-templates>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:for-each>
                </ul>
            </body>
        </html>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Makes link to the documentaion for each file.</xd:short>
    </xd:doc>
    <xsl:template match="c:result">
        <xsl:param name="indent" select="1"/>
        <xsl:param name="directory" select="''"/>
        <li>
            <xsl:choose>
                <xsl:when test="$directory">
                    <xsl:attribute name="style" select="concat('background-image: url(img/directory.png); text-indent: ',(20*$indent),'px;')"/>
                    <!--xsl:variable name="parts" select="tokenize(@rel,'/')"/>
                    <xsl:variable name="element" select="."/>
                    <xsl:for-each select="$parts">
                        <xsl:choose>
                            <xsl:when test="$indent = 1 or position() = 1"/>
                            <xsl:when test="position() = 1"/>
                            <xsl:when test="position() &lt; $indent">
                                <xsl:variable name="superPart"
                                    select="string-join(subsequence($parts,1,position()-1),'/')"/>
                                <xsl:variable name="subPart"
                                    select="string-join(subsequence($parts,1,position()),'/')"/>
                                <xsl:variable name="isLastPart"
                                    select="count($element/following-sibling::*[starts-with(@rel,$superPart) and not(starts-with(@rel,$subPart))])=0"/>
                                <xsl:choose>
                                    <xsl:when test="$isLastPart">
                                        <img src="img/lastsuperdirs.png"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <img src="img/superdir.png"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each-->
                    <!--xsl:if test="$indent>1">
                        <xsl:choose>
                            <xsl:when
                                test="count($element/following-sibling::*[starts-with(@rel,string-join(subsequence($parts,1,$indent -1),'/')) and not(starts-with(@rel,string-join(subsequence($parts,1,$indent),'/')))])=0">
                                <img src="img/lastsubfile.png"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="img/subfile.png"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        </xsl:if-->
                    <xsl:value-of select="$directory"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="style" select="concat('background-image: url(img/',@type,'.png); text-indent: ',(20*$indent),'px;')"/>
                    <!--xsl:for-each select="1 to $indent">
                        <img src="img/superdir.png"/>
                    </xsl:for-each>
                    <xsl:if test="$indent>0">
                        <img>
                            rel="<xsl:value-of select="@rel"/>"
                        </img>
                    </xsl:if-->
                    <a href="doc/{@rel}.html" target="content">
                        <xsl:value-of select="@name"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
</xsl:stylesheet>
