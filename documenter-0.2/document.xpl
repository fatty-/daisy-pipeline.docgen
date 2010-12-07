<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:d="http://www.example.org/documenter"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Main entry point for the documentation module.</xd:short>
        <xd:detail>Use this script to document a module. The script will first instruct makedita.xpl
            to generate documentation for the module, which will be in the DITA format. Then the
            script instructs dita2html.xpl to use the resulting DITA files to generate documentation
            in HTML. The documentation will be generated in the 'doc'-directory in the
            module.</xd:detail>
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
        <xd:option name="src">Path to the module you want to document.</xd:option>
        <xd:option name="doc">Path to where you want to store the documentation.</xd:option>
    </p:documentation>

    <p:option name="src" required="true"/>
    <p:option name="doc" required="true"/>

    <p:input port="source" primary="true">
        <p:empty/>
    </p:input>
    <p:output port="result" primary="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="source2dita/makedita.xpl"/>
    <p:import href="dita2output/dita2html.xpl"/>

    <p:variable name="srcPath"
        select="replace(replace(resolve-uri(resolve-uri('.',concat($src,'/'))),'^file:',''),'[^/]+$','')"/>
    <p:variable name="docPath"
        select="replace(replace(resolve-uri(resolve-uri('.',concat($doc,'/'))),'^file:',''),'[^/]+$','')"/>
    <p:variable name="selfPath"
        select="replace(replace(resolve-uri(resolve-uri('.',base-uri())),'^file:',''),'[^/]+$','')">
        <p:document href="document.xpl"/>
    </p:variable>

    <p:documentation xd:target="following">
        <xd:short>Make DITA files.</xd:short>
        <xd:detail>Iterates through all files in the module and makes DITA documents of
            them.</xd:detail>
        <xd:option name="inPath">Path to the module to be documented.</xd:option>
        <xd:option name="tempPath">Resolved full path to a directory that can be used to store
            temporary files.</xd:option>
        <xd:option name="ditaPath">Resolved full path to the output directory where the DITA files
            should be stored.</xd:option>
        <xd:option name="selfPath">Path to the documentation module itself.</xd:option>
    </p:documentation>
    <d:makeDita name="dita">
        <p:with-option name="srcPath" select="$srcPath"/>
        <p:with-option name="tempPath" select="concat($docPath,'temp')"/>
        <p:with-option name="ditaPath" select="concat($docPath,'dita')"/>
        <p:with-option name="selfPath" select="$selfPath"/>
    </d:makeDita>

    <p:documentation xd:target="following">
        <xd:short>Make XHTML5-documentation.</xd:short>
        <xd:input port="source">List of files.</xd:input>
        <xd:option name="ditaPath">Resolved full path to the directory where the DITA files are
            stored.</xd:option>
        <xd:option name="tempPath">Resolved full path to a directory that can be used to store
            temporary files.</xd:option>
        <xd:option name="htmlPath">Where to store the XHTML-documentation.</xd:option>
        <xd:option name="selfPath">Path to the documentation module itself.</xd:option>
    </p:documentation>
    <d:dita2html>
        <p:input port="source">
            <p:pipe port="result" step="dita"/>
        </p:input>
        <p:with-option name="title" select="replace($srcPath,'^.*/','')"/>
        <p:with-option name="ditaPath" select="concat($docPath,'dita')"/>
        <p:with-option name="tempPath" select="concat($docPath,'temp')"/>
        <p:with-option name="htmlPath" select="concat($docPath,'html')"/>
        <p:with-option name="selfPath" select="$selfPath"/>
    </d:dita2html>
</p:declare-step>
