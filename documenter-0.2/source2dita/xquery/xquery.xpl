<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:d="http://www.example.org/documenter"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Steps for documenting XQuery documents in DITA.</xd:short>
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
    </p:documentation>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:documentation xd:target="following">
        <xd:short>Generates DITA-documentation from all XQuery files in $path / $resolvedPath and
            saves it in $resolvedOut.</xd:short>
        <xd:option name="srcPath">the path to the source code</xd:option>
        <xd:option name="tempPath">path to temporary storage area</xd:option>
        <xd:option name="ditaPath">path pointing to the DITA output directory</xd:option>
        <xd:option name="selfPath">path to the documentation module</xd:option>
        <xd:output port="result">Gives out a list of the resulting DITA-files on the form:<xd:code><![CDATA[
        <c:result>
            <c:file ext="lower case file extension, typically xq, xquery or xqy"
                    rel="relative path to input file"
                    name="filename of input file"
                    abs="full path to input file">
                <c:result rel="relative path to output file"
                          name="filename of output file"
                          abs="absolute path to output file"/>
                <c:result rel="relative path to output file"
                          name="filename of output file"
                          abs="absolute path to output file"/>
            </c:file>
            <c:file ext="lower case file extension, typically xq, xquery or xqy"
                    rel="relative path to input file"
                    name="filename of input file"
                    abs="full path to input file">
                <c:result rel="relative path to output file"
                          name="filename of output file"
                          abs="absolute path to output file"/>
                <c:result rel="relative path to output file"
                          name="filename of output file"
                          abs="absolute path to output file"/>
            </c:file>
        </c:result>
        ]]></xd:code>
        </xd:output></p:documentation>
    <p:declare-step type="d:document-xquery-dita">
        <p:option name="path" required="true"/>
        <p:option name="self-path" required="true"/>
        <p:option name="resolvedPath" required="true"/>
        <p:option name="resolvedOut" required="true"/>
        <p:option name="resolvedTemp" required="true"/>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true"/>

        <p:for-each>
            <p:output port="result" primary="true" sequence="true">
                <p:pipe port="result" step="document-xquery-dita-done"/>
            </p:output>

            <p:iteration-source select="/c:directory/c:file"/>

            <p:variable name="fileName" select="/c:file/@name"/>
            <p:variable name="fileRel" select="/c:file/@relative"/>
            <p:variable name="fileAbs" select="resolve-uri($fileRel,$resolvedPath)"/>
            <p:variable name="ext" select="fn:lower-case(fn:tokenize(/c:file/@name, '\.')[last()])"/>

            <p:choose>
                <p:when test="$ext = 'xq' or $ext = 'xquery' or $ext = 'xqy'">
                    <cx:message>
                        <p:with-option name="message" select="concat('XQuery: ',$fileRel)"/>
                    </cx:message>
                    <p:exec>
                        <p:with-option name="command" select="'mkdir'"/>
                        <p:with-option name="args" select="$resolvedTemp"/>
                        <p:with-option name="source-is-xml" select="false()"/>
                        <p:with-option name="result-is-xml" select="false()"/>
                    </p:exec>
                    <p:sink/>
                    <p:exec>
                        <p:with-option name="command" select="'xqDoc/xqdoc.sh'"/>
                        <p:with-option name="args"
                            select="concat($fileAbs,' ',$ext,' NOV2005 default none ',$resolvedTemp))"/>
                        <p:with-option name="source-is-xml" select="false()"/>
                        <p:with-option name="result-is-xml" select="false()"/>
                    </p:exec>
                    <p:load>
                        <p:with-option name="href" select="concat($fileName,'.html')"/>
                    </p:load>
                    <p:try>
                        <p:group>
                            <p:unescape-markup content-type="text/html"/>
                            <p:unwrap match="/c:result"/>
                        </p:group>
                        <p:catch>
                            <p:identity/>
                        </p:catch>
                    </p:try>
                    <p:xslt>
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="xqDoc/xqdoc.xsl"/>
                        </p:input>
                    </p:xslt>

                    <p:choose>
                        <p:when test="count(/dita/reference) > 0">
                            <p:for-each>
                                <p:iteration-source select="/dita/reference"/>

                                <p:variable name="newExt"
                                    select="concat('.',/reference/@id,'.dita')"/>

                                <p:store name="apiFragmentStored">
                                    <p:with-option name="href"
                                        select="concat($resolvedOut,'/',$fileRel,$newExt)"/>
                                    <p:with-option name="indent" select="'true'"/>
                                    <!--p:with-option name="doctype-public"
                                        select="'-//OASIS//DTD DITA Reference//EN'"/>
                                    <p:with-option name="doctype-system" select="concat($self-path,'/documenter/tools/ditaot/dtd/technicalContent/dtd/reference.dtd')"/-->
                                </p:store>

                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="result" step="apiFragmentStored"/>
                                    </p:input>
                                </p:identity>

                                <p:add-attribute attribute-name="name" match="/c:result">
                                    <p:with-option name="attribute-value"
                                        select="concat($fileName,$newExt)"/>
                                </p:add-attribute>
                                <p:add-attribute attribute-name="rel" match="/c:result">
                                    <p:with-option name="attribute-value"
                                        select="concat($fileRel,$newExt)"/>
                                </p:add-attribute>
                                <p:add-attribute attribute-name="abs" match="/c:result">
                                    <p:with-option name="attribute-value"
                                        select="concat($resolvedOut,'/',$fileRel,$newExt)"/>
                                </p:add-attribute>

                                <cx:message>
                                    <p:with-option name="message" select="concat('saved: ',node())"
                                    />
                                </cx:message>
                            </p:for-each>

                            <p:wrap-sequence wrapper="c:file"/>
                            <p:add-attribute attribute-name="name" match="/c:file">
                                <p:with-option name="attribute-value" select="$fileName"/>
                            </p:add-attribute>
                            <p:add-attribute attribute-name="rel" match="/c:file">
                                <p:with-option name="attribute-value" select="$fileRel"/>
                            </p:add-attribute>
                            <p:add-attribute attribute-name="abs" match="/c:file">
                                <p:with-option name="attribute-value" select="$fileAbs"/>
                            </p:add-attribute>
                            <p:add-attribute attribute-name="ext" match="/c:file">
                                <p:with-option name="attribute-value" select="$ext"/>
                            </p:add-attribute>
                        </p:when>
                        <p:otherwise>
                            <p:sink/>
                            <p:identity>
                                <p:input port="source">
                                    <p:empty/>
                                </p:input>
                            </p:identity>
                        </p:otherwise>
                    </p:choose>

                </p:when>
                <p:otherwise>
                    <p:sink/>
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:otherwise>
            </p:choose>

            <p:identity name="document-xquery-dita-done"/>
        </p:for-each>

        <p:wrap-sequence wrapper="c:result"/>
    </p:declare-step>

    <p:documentation xd:target="following">
        <xd:short>Generates DITA-documentation and corresponding DITA-maps from all XQuery files in
            $path / $resolvedPath and saves it in $resolvedOut.</xd:short>
        <xd:option name="srcPath">the path to the source code</xd:option>
        <xd:option name="tempPath">path to temporary storage area</xd:option>
        <xd:option name="ditaPath">path pointing to the DITA output directory</xd:option>
        <xd:option name="selfPath">path to the documentation module</xd:option>
        <xd:output port="result">Gives out a list of the resulting DITA-maps on the form:<xd:code><![CDATA[
            <c:result>
                <c:result type="xquery">relative path to output file</c:result>
                <c:result type="xquery">relative path to output file</c:result>
            </c:result>
            ]]></xd:code>
        </xd:output></p:documentation>
    <p:declare-step type="d:document-xquery-ditamap">
        <p:option name="path" required="true"/>
        <p:option name="self-path" required="true"/>
        <p:option name="resolvedPath" required="true"/>
        <p:option name="resolvedOut" required="true"/>

        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true"/>

        <d:document-xquery-dita>
            <p:with-option name="path" select="$path"/>
            <p:with-option name="self-path" select="$self-path"/>
            <p:with-option name="resolvedPath" select="$resolvedPath"/>
            <p:with-option name="resolvedOut" select="$resolvedOut"/>
        </d:document-xquery-dita>

        <p:for-each>
            <p:output port="result" primary="true">
                <p:pipe port="result" step="document-xquery-ditamap-done"/>
            </p:output>

            <p:iteration-source select="/c:result/c:file"/>

            <p:variable name="name" select="/c:file/@name"/>
            <p:variable name="rel" select="/c:file/@rel"/>
            <p:variable name="abs" select="/c:file/@abs"/>
            <p:variable name="ext" select="/c:file/@ext"/>

            <p:variable name="mapFile"
                select="resolve-uri(concat(/c:file/@name,'.ditamap'),/c:file/c:result[1]/@abs)"/>
            <cx:message>
                <p:with-option name="message" select="$mapFile"/>
            </cx:message>

            <p:xslt>
                <p:with-param name="rel" select="$rel"/>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet version="1.0"
                            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

                            <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
                                omit-xml-declaration="yes"/>

                            <xsl:param name="rel" required="yes"/>

                            <xsl:template match="/c:file">
                                <xsl:element name="map">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="$rel"/>
                                    </xsl:attribute>
                                    <xsl:if test="count(./c:result)>0">
                                        <xsl:element name="topicref">
                                            <xsl:attribute name="format">
                                                <xsl:value-of select="'dita'"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="./c:result[1]/@name"/>
                                            </xsl:attribute>
                                            <xsl:for-each select="./c:result[position()>1]">
                                                <xsl:element name="topicref">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="@name"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="format">
                                                  <xsl:value-of select="'dita'"/>
                                                  </xsl:attribute>
                                                </xsl:element>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:template>

                            <xsl:template match="@*|text()|comment()|processing-instruction()">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*|node()"/>
                                </xsl:copy>
                            </xsl:template>

                            <!--xsl:template match="c:result">
                                <xsl:element name="topicref">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="@name"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:template-->
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
            </p:xslt>

            <p:store name="apiStored">
                <p:with-option name="href" select="$mapFile"/>
                <p:with-option name="indent" select="'true'"/>
                <!--p:with-option name="doctype-public" select="'-//OASIS//DTD DITA Map//EN'"/>
                <p:with-option name="doctype-system" select="concat($self-path,'/documenter/tools/ditaot/dtd/technicalContent/dtd/map.dtd')"/-->
            </p:store>

            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="apiStored"/>
                </p:input>
            </p:identity>

            <p:add-attribute match="/c:result" attribute-name="type" attribute-value="xquery"/>
            <p:add-attribute match="/c:result" attribute-name="name">
                <p:with-option name="attribute-value" select="$name"/>
            </p:add-attribute>
            <p:add-attribute match="/c:result" attribute-name="rel">
                <p:with-option name="attribute-value" select="$rel"/>
            </p:add-attribute>
            <p:add-attribute match="/c:result" attribute-name="abs">
                <p:with-option name="attribute-value" select="$abs"/>
            </p:add-attribute>
            <p:add-attribute match="/c:result" attribute-name="ext">
                <p:with-option name="attribute-value" select="$ext"/>
            </p:add-attribute>

            <p:identity name="document-xquery-ditamap-done"/>
        </p:for-each>

        <p:wrap-sequence wrapper="c:result"/>

    </p:declare-step>

</p:library>
