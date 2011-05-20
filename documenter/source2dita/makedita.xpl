<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:d="http://www.example.org/documenter"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" type="d:makeDita" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Makes DITA files based on the source files.</xd:short>
        <xd:detail>Retrieves a list of all source files and determines what kind of language they're
            written in. All the files that are written in a supported language are parsed into DITA
            documentation. A list of all files that were parsed are returned.</xd:detail>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:copyright>
            <xd:year>2010</xd:year>
            <xd:holder>DAISY Consortium</xd:holder>
        </xd:copyright>
        <xd:option name="inPath">Path to the module to be documented.</xd:option>
        <xd:option name="tempPath">Resolved full path to a directory that can be used to store
            temporary files.</xd:option>
        <xd:option name="ditaPath">Resolved full path to the output directory where the DITA files
            should be stored.</xd:option>
        <xd:option name="selfPath">Path to the documentation module itself.</xd:option>
    </p:documentation>

    <p:option name="srcPath" required="true"/>
    <p:option name="tempPath" required="true"/>
    <p:option name="ditaPath" required="true"/>
    <p:option name="selfPath" required="true"/>

    <p:output port="result" primary="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="xproc/xproc.xpl"/>
    <p:import href="xslt/xslt.xpl"/>
    <p:import href="fix-cross-references.xpl"/>
    <p:import href="../lib/filelist.xpl"/>
    <p:import href="../lib/recursive-directory-list.xpl"/>

    <p:documentation xd:target="following">
        <xd:short>Retrieves a list of all files.</xd:short>
    </p:documentation>
    <d:listFiles name="file-list">
        <p:with-option name="path" select="$srcPath"/>
    </d:listFiles>
    <p:sink/>

    <p:documentation xd:target="following">
        <xd:short>Iterates and compiles a list of all supported and parsed source files.</xd:short>
    </p:documentation>
    <p:group name="result-ditamap">
        <p:output port="result" primary="true">
            <p:pipe port="result" step="result-map-done"/>
        </p:output>

        <p:documentation xd:target="following">
            <xd:short>Documents all XProc scripts.</xd:short>
            <xd:output><xd:code><![CDATA[<c:result><c:file .../><c:file .../>...</c:result>]]></xd:code></xd:output>
        </p:documentation>
        <d:document-xproc-ditamap name="xproc-ditamap">
            <p:input port="source">
                <p:pipe port="result" step="file-list"/>
            </p:input>
            <p:with-option name="srcPath" select="$srcPath"/>
            <p:with-option name="tempPath" select="$tempPath"/>
            <p:with-option name="ditaPath" select="$ditaPath"/>
            <p:with-option name="selfPath" select="$selfPath"/>
        </d:document-xproc-ditamap>

        <p:documentation xd:target="following">
            <xd:short>Documents all XSLT stylesheets.</xd:short>
            <xd:output><xd:code><![CDATA[<c:result><c:file .../><c:file .../>...</c:result>]]></xd:code></xd:output>
        </p:documentation>
        <d:document-xslt-ditamap name="xslt-ditamap">
            <p:input port="source">
                <p:pipe port="result" step="file-list"/>
            </p:input>
            <p:with-option name="srcPath" select="$srcPath"/>
            <p:with-option name="tempPath" select="$tempPath"/>
            <p:with-option name="ditaPath" select="$ditaPath"/>
            <p:with-option name="selfPath" select="$selfPath"/>
        </d:document-xslt-ditamap>

        <p:identity>
            <p:input port="source">
                <p:inline>
                    <c:result/>
                </p:inline>
            </p:input>
        </p:identity>
        <p:insert>
            <p:input port="insertion" select="/c:result/c:result">
                <p:pipe port="result" step="xproc-ditamap"/>
            </p:input>
            <p:with-option name="position" select="'last-child'"/>
        </p:insert>
        <p:insert>
            <p:input port="insertion" select="/c:result/c:result">
                <p:pipe port="result" step="xslt-ditamap"/>
            </p:input>
            <p:with-option name="position" select="'last-child'"/>
        </p:insert>
        
        <p:identity name="result-map-done"/>
    </p:group>

    <p:documentation xd:target="following">
        <xd:short>Makes a DITA-map which references all the other DITA-maps in a
            sequence.</xd:short>
    </p:documentation>
    <p:group name="make-sequence-map">
        <p:output port="result" primary="true"/>
        
        
        <p:documentation>
            <xd:short>Resolves relative map paths.</xd:short>
            <xd:input><xd:code><![CDATA[<c:result><c:result type name ...>filename</c:result> ... </c:result>]]></xd:code></xd:input>
        </p:documentation>
        <p:group name="relative-map-paths">
            <p:output port="result">
                <p:pipe port="result" step="resolve-relative-map-paths"/>
            </p:output>
            
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="result-ditamap"/>
                </p:input>
            </p:identity>
            <p:viewport name="resolve-relative-map-paths" match="/c:result/c:result">
                <p:output port="result" primary="true" sequence="true">
                    <p:pipe port="result" step="resolve-relative-map-paths-done"/>
                </p:output>
                
                <p:add-attribute match="/*">
                    <p:with-option name="attribute-name" select="'rel'"/>
                    <p:with-option name="attribute-value"
                        select="substring-after(p:resolve-uri(.), concat($ditaPath,'/'))"/>
                </p:add-attribute>
                
                <p:identity name="resolve-relative-map-paths-done"/>
            </p:viewport>
            
            <p:identity><p:input port="source"><p:pipe port="result" step="result-ditamap"/></p:input></p:identity>
            <p:wrap wrapper="wrapper" match="/*"/>
            <p:escape-markup/>
            <cx:message><p:with-option name="message" select="'result-ditamap:'"></p:with-option></cx:message>
            <cx:message><p:with-option name="message" select="."/></cx:message>
            <p:sink/>
        </p:group>
        
        <p:group>
            <p:variable name="title" select="replace($srcPath,'^.*/','')"/>

            <p:xslt>
                <p:with-param name="title" select="title"/>
                <p:input port="source">
                    <p:pipe port="result" step="relative-map-paths"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet version="2.0"
                            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            exclude-result-prefixes="cx fn d xd">

                            <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
                                omit-xml-declaration="yes"/>

                            <xsl:param name="title" required="yes"/>

                            <xsl:template match="/c:result">
                                <xsl:element name="map">
                                    <xsl:attribute name="title" select="title"/>
                                    <xsl:for-each select="./c:result">
                                        <xsl:element name="topicref">
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="@rel"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="format">
                                                <xsl:value-of select="'ditamap'"/>
                                            </xsl:attribute>
                                            <!--xsl:apply-templates select="*|node()"/-->
                                        </xsl:element>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:template>

                            <xsl:template match="@*|text()|comment()|processing-instruction()">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
            </p:xslt>
        </p:group>
        
        <p:store name="store-sequence-map">
            <p:with-option name="href"
                select="p:resolve-uri('sequence.ditamap',concat($ditaPath,'/'))"/>
            <!--p:with-option name="href"
                select="concat($ditaPath,'/sequence.ditamap')"/-->
            <p:with-option name="indent" select="'true'"/>
        </p:store>

        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="store-sequence-map"/>
            </p:input>
        </p:identity>
    </p:group>

    <p:documentation xd:target="following">
        <xd:short>Iterates all resulting files and fixes cross references.</xd:short>
        <xd:option name="ditaPath">Resolved full path to the output directory where the
            documentation should be stored.</xd:option>
    </p:documentation>
    <d:fix-cross-references name="fix-cross-references">
        <p:input port="source">
            <p:pipe port="result" step="result-ditamap"/>
        </p:input>
        <p:with-option name="srcPath" select="$srcPath"/>
        <p:with-option name="ditaPath" select="$ditaPath"/>
    </d:fix-cross-references>
    <p:sink/>

    <p:documentation xd:target="following">
        <xd:short>Prepares the primary output (the list of files), suitable for further
            processing.</xd:short>
    </p:documentation>
    <p:group>
        <p:variable name="title" select="replace($srcPath,'^.*/','')">
            <!-- Should introduce a dependency on the fix-cross-references step: -->
            <p:pipe port="result" step="fix-cross-references"/>
        </p:variable>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="result-ditamap"/>
            </p:input>
        </p:identity>
        <p:add-attribute match="/c:result" attribute-name="sequencemap">
            <p:with-option name="attribute-value" select="/c:result/text()">
                <p:pipe port="result" step="make-sequence-map"/>
            </p:with-option>
        </p:add-attribute>
        <p:add-attribute match="/c:result" attribute-name="title">
            <p:with-option name="attribute-value" select="$title"/>
        </p:add-attribute>
    </p:group>

</p:declare-step>
