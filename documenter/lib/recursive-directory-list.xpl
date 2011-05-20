<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" type="cx:recursive-directory-list"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Performs p:directory-list recursively.</xd:short>
        <xd:detail>The cx:recursive-directory-list step lists the contents of the specified
            directory on the filesystem. Unlike the standard p:directory-list step,
            cx:recursive-directory-list expands all subdirectories recursively.</xd:detail>
        <xd:option name="path">Same as for p:directory-list; the directory to list all files and
            directories in.</xd:option>
        <xd:option name="include-filter">Same as for p:directory-list; if the include-filter pattern
            matches a directory entry's name, the entry is included in the output.</xd:option>
        <xd:option name="exclude-filter">Same as for p:directory-list; if the exclude-filter pattern
            matches a directory entry's name, the entry is excluded in the output.</xd:option>
        <xd:option name="depth">The depth option limits the recursive depth of the process. A value
            of “-1” specifies an unbounded depth.</xd:option>
        <xd:output>Pretty much the same as for p:directory-list, but with directories nested
            recursively.</xd:output>
        <xd:author>
            <xd:name>Norman Walsh</xd:name>
        </xd:author>
        <xd:contributor>
            <xd:name>Richard Hamilton</xd:name>
        </xd:contributor>
        <xd:copyright>
            <xd:year>2010</xd:year>
            <xd:holder>Norman Walsh</xd:holder>
        </xd:copyright>
        <xd:see>http://xprocbook.com/book/refentry-61.html</xd:see>
    </p:documentation>

    <p:output port="result"/>
    <p:option name="path" required="true"/>
    <p:option name="include-filter"/>
    <p:option name="exclude-filter"/>
    <p:option name="depth" select="-1"/>

    <p:choose>
        <p:when
            test="p:value-available('include-filter')
            and p:value-available('exclude-filter')">
            <p:directory-list>
                <p:with-option name="path" select="$path"/>
                <p:with-option name="include-filter" select="$include-filter"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
            </p:directory-list>
        </p:when>

        <p:when test="p:value-available('include-filter')">
            <p:directory-list>
                <p:with-option name="path" select="$path"/>
                <p:with-option name="include-filter" select="$include-filter"/>
            </p:directory-list>
        </p:when>

        <p:when test="p:value-available('exclude-filter')">
            <p:directory-list>
                <p:with-option name="path" select="$path"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
            </p:directory-list>
        </p:when>

        <p:otherwise>
            <p:directory-list>
                <p:with-option name="path" select="$path"/>
            </p:directory-list>
        </p:otherwise>
    </p:choose>

    <p:viewport match="/c:directory/c:directory">
        <p:variable name="name" select="/*/@name"/>

        <p:choose>
            <p:when test="$depth != 0">
                <p:choose>
                    <p:when
                        test="p:value-available('include-filter')
                                                 and p:value-available('exclude-filter')">
                        <cx:recursive-directory-list>
                            <p:with-option name="path" select="concat($path,'/',$name)"/>
                            <p:with-option name="include-filter" select="$include-filter"/>
                            <p:with-option name="exclude-filter" select="$exclude-filter"/>
                            <p:with-option name="depth" select="$depth - 1"/>
                        </cx:recursive-directory-list>
                    </p:when>

                    <p:when test="p:value-available('include-filter')">
                        <cx:recursive-directory-list>
                            <p:with-option name="path" select="concat($path,'/',$name)"/>
                            <p:with-option name="include-filter" select="$include-filter"/>
                            <p:with-option name="depth" select="$depth - 1"/>
                        </cx:recursive-directory-list>
                    </p:when>

                    <p:when test="p:value-available('exclude-filter')">
                        <cx:recursive-directory-list>
                            <p:with-option name="path" select="concat($path,'/',$name)"/>
                            <p:with-option name="exclude-filter" select="$exclude-filter"/>
                            <p:with-option name="depth" select="$depth - 1"/>
                        </cx:recursive-directory-list>
                    </p:when>

                    <p:otherwise>
                        <cx:recursive-directory-list>
                            <p:with-option name="path" select="concat($path,'/',$name)"/>
                            <p:with-option name="depth" select="$depth - 1"/>
                        </cx:recursive-directory-list>
                    </p:otherwise>
                </p:choose>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:viewport>

</p:declare-step>
