<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" exclude-result-prefixes="xd" version="2.0">
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

    <!--xsl:param name="title" required="yes"/-->
    <xsl:param name="pathToRoot" required="yes"/>

    <xd:doc target="following">
        <xd:short>Identity template.</xd:short>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Matches the top element and creates the main HTML structure.</xd:short>
    </xd:doc>
    <xsl:template match="/map">
        <html>
            <head>
                <style type="text/css">
                    body {
                        font-family : futura, helvetica, arial, sans-serif;
                    }
                    section,
                    article,
                    header,
                    footer,
                    nav,
                    aside,
                    hgroup {
                        display : block;
                    }
                    section.reference {
                        border-style : solid;
                        border-width : 1px;
                        border-radius : 10px;
                        -moz-border-radius : 10px;
                        margin : 5px;
                        padding : 20px;
                        border-color : #CCC;
                        background-color : #F9F9F9;
                    }
                    .child-topics section.reference {
                        border-style : solid;
                        border-width : 2px;
                        border-radius : 10px;
                        -moz-border-radius : 10px;
                        margin : 20px;
                        padding : 20px;
                        border-color : #CCC;
                        background-color : #EEF;
                    }
                    section.child-topics {
                        margin-left : 25px;
                    }
                    .main-header h1 {
                        width : 100%;
                        border-style : solid;
                        border-width : 0px 0px 1px 0px;
                        font-size : 26px;
                    }
                    table {
                        margin : 10px;
                    }
                    table.parml {
                        border-style : solid;
                        border-width : 1px;
                        border-color : white;
                        background-color : #EEF;
                    }
                    tr.plentry {
                        border-style : dotted;
                        border-width : 1px;
                    }
                    td.pt td.pd {
                        padding : 5px;
                        border-style : solid;
                        border-width : 1px;
                        border-radius : 4px;
                    }
                    .reference h1 {
                        font-size : 22px;
                        color : #006;
                    }
                    section.abstract,
                    section.prolog,
                    section.parameters,
                    section.linklist,
                    section.sourcecode {
                        border-style : dotted;
                        border-width : 1px;
                        border-radius : 0px;
                        margin : 10px;
                        padding : 10px 10px 50px 10px;
                        background-color : #F5F5FF;
                    }
                    section.sourcecode {
                        /*display: none;*/
                    }
                    header.abstract-header,
                    header.prolog-header,
                    header.io-header,
                    .linklist header,
                    header.sourcecode-header {
                        position : relative;
                        top : -30px;
                        float : left;
                    }
                    .abstract-header h1,
                    .prolog-header h1,
                    .io-header h1,
                    .linklist h1,
                    .sourcecode-header h1 {
                        position : absolute;
                        color : #006;
                        background-color : #EEF;
                        font-size : 18px;
                        white-space : nowrap;
                    }
                    header.subheader {
                        position : static;
                        top : 0px;
                        float : none;
                    }
                    .subheader h1 {
                        color : #006;
                        background-color : transparent;
                        font-size : 16px;
                    }</style>
            </head>
            <header class="main-header">
                <xsl:if test="count(//*[@name='programming-language'])>0">
                    <xsl:attribute name="class">
                        <xsl:value-of
                            select="concat('main-header ',//*[@name='programming-language'][1]/@content)"
                        />
                    </xsl:attribute>
                </xsl:if>
                <h1>
                    <xsl:value-of select="@title"/>
                </h1>
            </header>

            <xsl:apply-templates/>
        </html>
    </xsl:template>

    <xsl:template match="topicref[@format='ditamap']">
        <a href="{@href}.html">
            <xsl:value-of select="concat(@href,'.html')"/>
        </a>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Load DITA reference and apply-templates to it.</xd:short>
        <xd:detail>Wraps any child elements of the reference to the DITA reference document in their
            own &lt;section class="child-topics"&gt; following the processed reference.</xd:detail>
    </xd:doc>
    <xsl:template match="topicref[@format='dita']">
        <xsl:apply-templates select="document(@href)">
            <xsl:with-param name="isTopDocument" select="not(parent::topicref)" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:if test="count(./*) > 0">
            <section class="child-topics">
                <xsl:apply-templates/>
            </section>
        </xsl:if>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>Matches top element of a reference document.</xd:short>
        <xd:detail>Wraps the reference in a &lt;section&gt;, creates a headline, a short
            description, and apply-templates to the rest of the document.</xd:detail>
    </xd:doc>
    <xsl:template match="/reference">
        <section>
            <xsl:attribute name="class">
                <xsl:value-of
                    select="concat('reference ',//*[@name='programming-language'][1]/@content,' ',@outputclass)"
                />
            </xsl:attribute>
            <xsl:apply-templates select="./title"/>
            <p class="shortdesc {@outputclass}">
                <xsl:value-of select="./abstract[1]/shortdesc[1]"/>
            </p>
            <xsl:apply-templates select="./*[not(local-name(.)='title')]"/>
        </section>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;title&gt; becomes &lt;header
            class="title"&gt;&lt;h1/&gt;&lt;/header&gt;</xd:short>
    </xd:doc>
    <xsl:template match="title">
        <header class="title {@outputclass}">
            <h1>
                <xsl:apply-templates/>
            </h1>
        </header>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;abstract&gt; becomes &lt;section class="abstract"&gt;&lt;header
            class="abstract-header"&gt;&lt;h1&gt;Description&lt;/h1&gt;&lt;/header&gt;&lt;p&gt;...&lt;/p&gt;&lt;/section&gt;</xd:short>
    </xd:doc>
    <xsl:template match="abstract">
        <xsl:variable name="nodetext">
            <xsl:value-of
                select="descendant-or-self::text()[not(ancestor::*[local-name()='shortdesc'])]"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($nodetext))>0">
            <section class="abstract {@outputclass}">
                <header class="abstract-header">
                    <h1>Description</h1>
                </header>
                <p>
                    <xsl:apply-templates/>
                </p>
            </section>
        </xsl:if>
    </xsl:template>

    <xsl:template match="shortdesc"/>

    <xd:doc target="following">
        <xd:short>&lt;prolog&gt; becomes &lt;section class="prolog"&gt;&lt;header
            class="prolog-header"&gt;&lt;h1&gt;About&lt;/h1&gt;&lt;/header&gt;...&lt;/section&gt;</xd:short>
    </xd:doc>
    <xsl:template match="prolog">
        <xsl:variable name="nodetext">
            <xsl:value-of select="descendant-or-self::text()"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($nodetext))>0">
            <section class="prolog {@outputclass}">
                <header class="prolog-header">
                    <h1>About</h1>
                </header>
                <xsl:apply-templates/>
            </section>
        </xsl:if>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;author type="creator|contributor|maintainer"/&gt; becomes
            &lt;p&gt;Author/Contributor/Maintainer: ...&lt;/p&gt;</xd:short>
    </xd:doc>
    <xsl:template match="author">
        <p class="{@outputclass}">
            <xsl:choose>
                <xsl:when test="@type='creator'">Author: </xsl:when>
                <xsl:when test="@type='contributor'">Contributor: </xsl:when>
                <xsl:when test="@type='maintainer'">Maintainer: </xsl:when>
                <xsl:otherwise>Other contributors: </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;copyright&gt;&lt;copyryear
            year="..."/&gt;&lt;copyrholder&gt;...&lt;/copyrholder&gt;&lt;/copyright&gt; becomes
            &lt;p class="copyright"&gt;&#169; [holder], [year]&lt;/p&gt;</xd:short>
    </xd:doc>
    <xsl:template match="copyright">
        <p class="copyright {@outputclass}"> &#169; <xsl:apply-templates select="copyrholder"/>
            <xsl:if test="count(./copyrholder)>0 and count(./copyryear)>0">, </xsl:if>
            <xsl:apply-templates select="copyryear"/>
        </p>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;copyrholder/&gt; becomes &lt;span class="copyrholder"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="copyrholder">
        <span class="copyrholder {@outputclass}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;copyryear year="..."/&gt; becomes &lt;span
            class="copyryear"&gt;...&lt;/span&gt;</xd:short>
    </xd:doc>
    <xsl:template match="copyryear">
        <span class="copyryear {@outputclass}">
            <xsl:value-of select="@year"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;metadata/&gt; becomes &lt;table class="metadata"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="metadata">
        <table class="metadata {@outputclass}">
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;audience/&gt; are ignored.</xd:short>
    </xd:doc>
    <xsl:template match="audience"/>

    <xd:doc target="following">
        <xd:short>&lt;othermeta name="..." value="..."/&gt; becomes &lt;tr
            class="othermeta"&gt;&lt;td&gt;...&lt;/td&gt;&lt;td&gt;...&lt;/td&gt;&lt;/tr&gt;</xd:short>
    </xd:doc>
    <xsl:template match="othermeta">
        <tr class="othermeta {@outputclass}">
            <xsl:choose>
                <xsl:when test="@name='programming-language'">
                    <td>Programming language</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='version'">
                    <td>Version</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='since'">
                    <td>Since</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='see'">
                    <td>See</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='deprecated'">
                    <td>Deprecated</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='xslt-version'">
                    <td>XSLT version</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='xproc-version'">
                    <td>XProc version</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:when test="@name='xpath-version'">
                    <td>XPath version</td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td>
                        <xsl:value-of select="@name"/>
                    </td>
                    <td>
                        <xsl:value-of select="@content"/>
                    </td>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;refbody&gt; becomes &lt;section class="refbody"&gt;&lt;header
            class="refbody-header"&gt;&lt;h1&gt;Parameters&lt;/h1&gt;&lt;/header&gt;...&lt;/section&gt;</xd:short>
    </xd:doc>
    <xsl:template match="refbody">
        <xsl:variable name="nodetext">
            <xsl:value-of
                select="descendant-or-self::text()[not(ancestor::*[local-name()='apiname'])]"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($nodetext))>0">
            <!--section class="refbody {@outputclass}">
                <header class="refbody-header">
                    <h1>Parameters</h1-->
            <!--h1>Input / Output<xsl:if test=".//apiname"> for <xsl:value-of select=".//apiname"/></xsl:if></h1-->
            <!--/header-->
            <xsl:apply-templates/>
            <!--/section-->
        </xsl:if>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;section/&gt; becomes &lt;section class="section"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="section">
        <xsl:param name="isTopDocument" select="false()" tunnel="yes"/>
        <xsl:if test="not($isTopDocument and contains(@outputclass,'sourcecode'))">
            <section class="section {@outputclass}">
                <xsl:apply-templates/>
            </section>
        </xsl:if>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;apiname/&gt; are ignored.</xd:short>
    </xd:doc>
    <xsl:template match="apiname"/>

    <xd:doc target="following">
        <xd:short>&lt;parml/&gt; becomes &lt;table
            class="parml"&gt;&lt;tr&gt;&lt;th/&gt;&lt;th/&gt;[headlines based on
            parml/@outputclass]&lt;/tr&gt;&lt;/table&gt;</xd:short>
    </xd:doc>
    <xsl:template match="parml">
        <table class="parml {@outputclass}">
            <xsl:choose>
                <xsl:when test="contains(@outputclass,'xproc-inputs')">
                    <tr>
                        <th>name</th>
                        <th>primary</th>
                        <th>sequence</th>
                        <th>connection</th>
                        <th>description</th>
                    </tr>
                </xsl:when>
                <xsl:when test="contains(@outputclass,'xproc-outputs')">
                    <tr>
                        <th>name</th>
                        <th>primary</th>
                        <th>sequence</th>
                        <th>connection</th>
                        <th>description</th>
                    </tr>
                </xsl:when>
                <xsl:when test="contains(@outputclass,'xproc-options')">
                    <tr>
                        <th>name</th>
                        <th>required</th>
                        <xsl:if test="contains(@outputclass,'xproc-with-options')">
                            <th>connection</th>
                        </xsl:if>
                        <th>description</th>
                    </tr>
                </xsl:when>
                <xsl:when test="contains(@outputclass,'xslt-params')">
                    <tr>
                        <th>name</th>
                        <th>as</th>
                        <xsl:if test="not(contains(@outputclass,'xslt-with-params'))">
                            <th>required</th>
                        </xsl:if>
                        <th>tunnel</th>
                        <th>description</th>
                    </tr>
                </xsl:when>
                <xsl:when test="contains(@outputclass,'xslt-outputs')">
                    <tr>
                        <th>name</th>
                        <th>method</th>
                        <th>indent</th>
                        <th>doctype-system</th>
                        <th>doctype-public</th>
                        <th>include-content-type</th>
                        <th>encoding</th>
                        <th>media-type</th>
                        <th>omit-xml-declaration</th>
                        <th>standalone</th>
                        <th>version</th>
                        <th>description</th>
                    </tr>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;plentry/&gt; becomes &lt;tr class="plentry"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="plentry">
        <tr class="plentry {@outputclass}">
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;pt/&gt; becomes &lt;td class="pt"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="pt">
        <td class="pt {@outputclass}">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;pd/&gt; becomes &lt;td class="pd"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="pd">
        <td class="pd {@outputclass}">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;related-links/&gt; becomes &lt;span class="related-links"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="related-links">
        <span class="related-links {@outputclass}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;linklist/&gt; becomes &lt;section class="linklist"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="linklist">
        <section class="linklist {@outputclass}">
            <xsl:apply-templates select="./title"/>
            <xsl:apply-templates select="./linkinfo"/>
            <xsl:apply-templates select="./link"/>
        </section>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;link href="..."/&gt; becomes &lt;p class="link"&gt;&lt;a
            href="..."/&gt;&lt;/link&gt;</xd:short>
    </xd:doc>
    <xsl:template match="link">
        <p class="link {@outputclass}">
            <xsl:variable name="href" select="@href"/>
            <xsl:choose>
                <xsl:when test="matches($href,'.ditamap$')">
                    <a>
                        <xsl:attribute name="href"
                            select="concat(substring-before($href,'.ditamap'),'.html')"/>
                        <xsl:choose>
                            <xsl:when
                                test="matches($href,'.xsl.ditamap') or matches($href,'.xslt.ditamap')">
                                <xsl:attribute name="style"
                                    select="concat('padding-left: 20px; background: transparent url(',$pathToRoot,'/img/xslt.png) no-repeat center left;')"
                                />
                            </xsl:when>
                            <xsl:when
                                test="matches($href,'.xpl.ditamap') or matches($href,'.xproc.ditamap')">
                                <xsl:attribute name="style"
                                    select="concat('padding-left: 20px; background: transparent url(',$pathToRoot,'/img/xproc.png) no-repeat center left;')"
                                />
                            </xsl:when>
                            <xsl:when
                                test="matches($href,'.xq.ditamap') or matches($href,'.xquery.ditamap')">
                                <xsl:attribute name="style"
                                    select="concat('padding-left: 20px; background: transparent url(',$pathToRoot,'/img/xquery.png) no-repeat center left;')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="style" select="'padding-left: 20px;'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="substring-before($href,'.ditamap')"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$href}" target="_blank" class="external-link"
                        style="padding-left: 20px; background: transparent url({$pathToRoot}/img/external_link.png) no-repeat center left;">
                        <xsl:value-of select="$href"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;linkinfo/&gt; becomes &lt;p class="linkinfo"/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="linkinfo">
        <p class="linkinfo {@outputclass}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xd:doc target="following">
        <xd:short>&lt;codeblock/&gt; becomes &lt;code class="language-..."/&gt;</xd:short>
    </xd:doc>
    <xsl:template match="codeblock">
        <pre class="codeblock"><code class="{@outputclass}">
            <xsl:apply-templates/>
        </code></pre>
    </xsl:template>
</xsl:stylesheet>
