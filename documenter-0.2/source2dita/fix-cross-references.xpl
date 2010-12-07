<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="d:fix-cross-references" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:d="http://www.example.org/documenter"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Iterates all resulting files and fixes cross references.</xd:short>
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
        <xd:option name="ditaPath">Resolved full path to the output directory where the DITA
            documentation are stored.</xd:option>
    </p:documentation>

    <p:option name="srcPath" required="true"/>
    <p:option name="ditaPath" required="true"/>

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:for-each>
        <p:iteration-source select="/c:result/c:result"/>
        <p:variable name="type" select="/c:result/@type"/>
        <p:variable name="name" select="/c:result/@name"/>
        <p:variable name="rel" select="/c:result/@rel"/>
        <p:variable name="abs" select="/c:result/@abs"/>
        <p:variable name="ext" select="/c:result/@ext"/>
        <p:variable name="mapAbs" select="/c:result/text()"/>

        <p:load>
            <p:with-option name="href" select="$mapAbs"/>
        </p:load>

        <p:for-each>
            <p:iteration-source select="/map/topicref"/>
            <p:variable name="href" select="resolve-uri(/topicref/@href,$mapAbs)"/>

            <p:load>
                <p:with-option name="href" select="$href"/>
            </p:load>

            <p:viewport match="//related-links/linklist/link">
                <p:variable name="linkHref" select="/link/@href"/>
                <p:variable name="isWebLink"
                    select="not(matches(resolve-uri(resolve-uri($linkHref)),'^file:'))"/>
                <p:variable name="isFileAbsolute"
                    select="not($isWebLink='false') and resolve-uri(resolve-uri($linkHref,concat($srcPath,'/',$rel)))=resolve-uri(resolve-uri($linkHref))"/>
                <p:choose>
                    <p:when test="$isWebLink='true'">
                        <!-- TODO when packaging system is up and running; look through all package descriptors
                        in the repository for a matching URL here; otherwise set format as html -->
                        <!--p:add-attribute match="/link" attribute-name="href"
                            attribute-value="weblink"/-->
                        <p:identity/>
                    </p:when>
                    <p:when test="$isFileAbsolute='false'">
                        <!--p:add-attribute match="/link" attribute-name="href"
                            attribute-value="notabsolute"/-->
                        <p:add-attribute match="/link" attribute-name="href">
                            <p:with-option name="attribute-value"
                                select="concat($linkHref,'.ditamap')"/>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:add-attribute match="/link" attribute-name="href"
                            attribute-value="absolute"/>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
            </p:viewport>

            <p:store name="map-store">
                <p:with-option name="href" select="$href"/>
            </p:store>

            <p:identity name="map-result">
                <p:input port="source">
                    <p:pipe port="result" step="map-store"/>
                </p:input>
            </p:identity>

        </p:for-each>
    </p:for-each>

    <p:wrap-sequence wrapper="c:result"/>

</p:declare-step>
