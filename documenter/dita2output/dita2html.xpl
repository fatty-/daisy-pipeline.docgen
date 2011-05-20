<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0"
    xmlns:d="http://www.example.org/documenter" type="d:dita2html">

    <p:documentation xd:target="parent">
        <xd:short>Make XHTML-documentation from DITA files.</xd:short>
        <xd:detail>This step receives a list of DITA files, loads them, transforms them into XHTML
            using an XSLT stylesheet (dita2html.xsl), and stores them to the output directory. The
            list of DITA files is also used to produce a table of contents of all files so that the
            documentation is easier to navigate.</xd:detail>
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
        <xd:input port="source">A list of DITA files on the form:<xd:code><![CDATA[
        <c:result xmlns:c="http://www.w3.org/ns/xproc-step">
            <c:result
                type="xproc|xslt|xquery|..."
                rel="doc/(*.xpl|*.xsl|*.xq|*...).ditamap"
                name="*.xpl|*.xsl|*.xq|*..."
                ext="xpl|xproc|xsl|xslt|xq|xquery|..."
                abs="/absolute/path/to/src/(*.xpl|*.xsl|*.xq|*...)">/absolute/path/to/dita/doc/*.ditamap</c:result>
            <c:result .../>
            ...
        </c:result>
        ]]></xd:code></xd:input>
        <xd:option name="selfPath">Resolved full path to documentation module (the directory
            containing this documentation generator).</xd:option>
        <xd:option name="htmlPath">Where to store the XHTML-documentation.</xd:option>
        <xd:option name="title">Name of the target module.</xd:option>
    </p:documentation>

    <p:option name="ditaPath" required="true"/>
    <p:option name="tempPath" required="true"/>
    <p:option name="htmlPath" required="true"/>
    <p:option name="selfPath" required="true"/>
    <p:option name="title" required="true"/>

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>

    <p:identity name="ditamaps"/>

    <p:for-each>
        <p:iteration-source select="/c:result/c:result"/>

        <p:variable name="type" select="/c:result/@type"/>
        <p:variable name="ext" select="/c:result/@ext"/>
        <p:variable name="rel" select="/c:result/@rel"/>
        <p:variable name="name" select="/c:result/@name"/>
        <p:variable name="abs" select="/c:result/@abs"/>
        <p:variable name="mapabs" select="/c:result/text()"/>

        <p:load>
            <p:with-option name="href" select="$mapabs"/>
        </p:load>

        <p:documentation xd:target="following">
            <xd:short>Transform the loaded DITA document to XHTML.</xd:short>
        </p:documentation>
        <p:xslt>
            <p:with-param name="title" select="$title"/>
            <p:with-param name="pathToRoot"
                select="replace(replace($rel,'/[^/]*$',''),'[^/]+','..')"/>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="html/dita2html.xsl"/>
            </p:input>
        </p:xslt>

        <p:store name="store">
            <p:documentation xd:target="parent">
                <xd:short>Stores the documentation for a file in the output directory.</xd:short>
            </p:documentation>
            <p:with-option name="href" select="concat($htmlPath,'/doc/',$rel,'.html')"/>
        </p:store>

        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="store"/>
            </p:input>
        </p:identity>
    </p:for-each>
    <p:wrap-sequence wrapper="c:result"/>
    <p:sink/>

    <p:documentation xd:target="following">
        <xd:short>Transforms the input list of DITA files to a table of contents listing all
            files.</xd:short>
        <xd:input port="source">The list of DITA files.</xd:input>
        <xd:output port="result">The XHTML code.</xd:output>
    </p:documentation>
    <p:group>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="source">
                <p:pipe port="result" step="ditamaps"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="/c:result">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:for-each select="c:result">
                                    <xsl:sort select="@rel"/>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
        <p:xslt name="filelist">
            <p:with-param name="title" select="$title"/>
            <p:input port="stylesheet">
                <p:document href="html/dita2htmltoc.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:store>
        <p:documentation xd:target="parent">
            <xd:short>Stores the table of contents as filelist.html to the output
                directory.</xd:short>
        </p:documentation>
        <p:with-option name="href" select="concat($htmlPath,'/filelist.html')"/>
    </p:store>

    <p:documentation xd:target="following">
        <xd:short>Creates a basic index.html frameset.</xd:short>
        <xd:output name="result">The XHTML code.</xd:output>
    </p:documentation>
    <p:identity name="index">
        <p:input port="source">
            <p:inline>
                <html>
                    <frameset cols="25%,75%">
                        <frame src="filelist.html" name="files"/>
                        <frame src="main.html" name="content"/>
                    </frameset>
                </html>
            </p:inline>
        </p:input>
    </p:identity>
    <p:store>
        <p:documentation xd:target="parent">
            <xd:short>Stores the index.html in the output directory.</xd:short>
        </p:documentation>
        <p:with-option name="href" select="concat($htmlPath,'/index.html')"/>
    </p:store>

    <p:documentation xd:target="following">
        <xd:short>Creates a basic main.html front page.</xd:short>
        <xd:output name="result">The XHTML code.</xd:output>
    </p:documentation>
    <p:identity name="main">
        <p:input port="source">
            <p:inline>
                <html>
                    <head>
                        <style type="text/css">
                            <![CDATA[
                            #outer {height: 100%; overflow: hidden; position: relative; width: 100%;}
                            #outer[id] {display: table; position: static;}
                            
                            #middle {position: absolute; top: 50%; width: 100%; text-align: center;} /* for explorer only*/
                            #middle[id] {display: table-cell; vertical-align: middle; position: static;}
                            
                            #inner {position: relative; top: -50%; text-align: left;} /* for explorer only */
                            #inner {width: 200px; margin-left: auto; margin-right: auto;} /* for all browsers*/
                            ]]>
                        </style>
                    </head>
                    <body>
                        <div id="outer">
                            <div id="middle">
                                <div id="inner">
                                    <img class="center" src="img/generated-using-pipeline2.png"
                                        alt="Generated using Pipeline 2"/>
                                </div>
                            </div>
                        </div>
                    </body>
                </html>
            </p:inline>
        </p:input>
    </p:identity>
    <p:store>
        <p:documentation xd:target="parent">
            <xd:short>Stores a main.html to the output directory.</xd:short>
        </p:documentation>
        <p:with-option name="href" select="concat($htmlPath,'/main.html')"/>
    </p:store>

    <p:documentation xd:target="following">
        <xd:short>Copy images to output.</xd:short>
    </p:documentation>
    <p:group>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="index"/>
            </p:input>
        </p:identity>
        <p:sink/>

        <p:identity name="requestTemplate">
            <p:input port="source">
                <p:inline>
                    <c:request method="GET" detailed="true"/>
                </p:inline>
            </p:input>
        </p:identity>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/directory.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/directory.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/subfile.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/subfile.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/superdir.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/superdir.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/lastsubfile.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/lastsubfile.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/lastsuperdirs.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/lastsuperdirs.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/xproc.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/xproc.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/xslt.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/xslt.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/xquery.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/xquery.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/external_link.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href" select="concat($htmlPath,'/img/external_link.png')"/>
        </p:store>

        <p:add-attribute match="c:request" attribute-name="href">
            <p:input port="source">
                <p:pipe port="result" step="requestTemplate"/>
            </p:input>
            <p:with-option name="attribute-value"
                select="concat($selfPath,'/resources/images/generated-using-pipeline2.png')"/>
        </p:add-attribute>
        <p:http-request/>
        <p:store cx:decode="true">
            <p:input port="source" select="/c:body"/>
            <p:with-option name="href"
                select="concat($htmlPath,'/img/generated-using-pipeline2.png')"/>
        </p:store>
    </p:group>

    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="ditamaps"/>
        </p:input>
    </p:identity>

    <!--p:variable name="relativeout" select="replace(p:resolve-uri(p:resolve-uri('.',concat($path,'/'))),'^file:','')"-->
    <!--rel getRelativePath(fra,til)-->
    <!--p:variable name="relativeout" select="//@result[1]">
        <p:pipe port="result" step="resolveout"/>
    </p:variable>
    <p:group name="resolveout">
        <p:output port="result" primary="true"/>
        <p:identity>
            <p:input port="source">
                <p:inline>
                    <c:result/>
                </p:inline>
            </p:input>
        </p:identity>
        <p:add-attribute match="/c:result" attribute-name="fn" attribute-value="getRelativePath"/>
        <p:add-attribute match="/c:result" attribute-name="source">
            <p:with-option name="attribute-value" select="$map"/>
        </p:add-attribute>
        <p:add-attribute match="/c:result" attribute-name="target">
            <p:with-option name="attribute-value" select="$supermap"/>
        </p:add-attribute>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="relpath_util.xsl"/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:group>
        <p:variable name="relativeout" select="//@result[1]">
            <p:pipe port="result" step="resolveout"/>
        </p:variable>
        
        <p:load name="map">
            <p:with-option name="href" select="$map"/>
        </p:load>

        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="ditamap2html.xsl"/>
            </p:input>
        </p:xslt>

        <p:store>
            <p:with-option name="href" select="concat($outdir,"/>
        </p:store>

        <p:viewport match="//topicref[@format='ditamap']">
            <p:viewport-source>
                <p:pipe port="result" step="map"/>
            </p:viewport-source>
            <d:dita2html>
                <p:with-option name="map" select="p:resolve-uri(/topicref/@href,$map)"/>
                <p:with-option name="outdir" select="$outdir"/>
                <p:with-option name="supermap" select="$supermap"/>
            </d:dita2html>
        </p:viewport>
    </p:group-->

</p:declare-step>
