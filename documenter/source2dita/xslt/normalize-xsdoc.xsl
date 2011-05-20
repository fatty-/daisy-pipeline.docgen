<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" version="2.0">

    <xd:doc target="following">Identity template.</xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:short>Matches each xd:doc element.</xd:short>
        <xd:detail>Determines what code is being documented and calls appropriate templates for: <ul>
                <li>short description (xd:short)</li>
                <li>detailed description (xd:detail)</li>
                <li>authors (xd:author)</li>
                <li>contributors (xd:contributor)</li>
                <li>maintainers (xd:maintainer)</li>
                <li>copyright (xd:copyright)</li>
                <li>version (xd:version)</li>
                <li>code existed since version (xd:since)</li>
                <li>see also (xd:see)</li>
                <li>deprecated since version (xd:deprecated)</li>
                <li>import statements (xd:import and xsl:import)</li>
                <li>include statements (xd:include and xsl:include)</li>
                <li>parameters (xd:param and xsl:param)</li>
                <li>return values / output (xd:return)</li>
            </ul>
        </xd:detail>
        <xd:return>The normalized xd:doc.</xd:return>
    </xd:doc>
    <xsl:template match="xd:doc">
        <xsl:copy>
            <xsl:variable name="target">
                <xsl:choose>
                    <xsl:when test="@target">
                        <xsl:value-of select="@target"/>
                    </xsl:when>
                    <xsl:when test="count(preceding-sibling::*)=0">
                        <xsl:value-of select="'parent'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'following'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="code"
                select="if ($target='parent') then parent::* else following-sibling::*[1]"/>

            <xsl:attribute name="target" select="$target"/>

            <xsl:call-template name="short"/>
            <xsl:call-template name="detail"/>
            <xsl:call-template name="authors"/>
            <xsl:call-template name="contributors"/>
            <xsl:call-template name="maintainers"/>
            <xsl:call-template name="copyright"/>
            <xsl:call-template name="version"/>
            <xsl:call-template name="since"/>
            <xsl:call-template name="see"/>
            <xsl:call-template name="deprecated"/>
            <xsl:call-template name="import">
                <xsl:with-param name="code" select="$code"/>
            </xsl:call-template>
            <xsl:call-template name="include">
                <xsl:with-param name="code" select="$code"/>
            </xsl:call-template>
            <xsl:call-template name="param">
                <xsl:with-param name="code" select="$code"/>
            </xsl:call-template>
            <xsl:call-template name="return"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:short>Determines the short description.</xd:short>
        <xd:detail>
            <ul>
                <li>If there is no &lt;xd:short/&gt;-element present, but plain text is present as a
                    child of the &lt;xd:doc/&gt;element, then the first sentence from that text (up
                    until the first period (".") will be used as a short description.</li>
                <li>Else; if there are multiple &lt;xd:short/&gt;-elements, each one of their
                    contents will be wrapped in separate &lt;section/&gt;s.</li>
                <li>Else; use the one &lt;xd:short/&gt;-element that is present for the short
                    description.</li>
            </ul>
        </xd:detail>
    </xd:doc>
    <xsl:template name="short">
        <xsl:choose>
            <xsl:when test="count(child::*[local-name()='short'])>1">
                <xd:short>
                    <xsl:for-each select="child::*[local-name()='short']">
                        <xd:section>
                            <xsl:apply-templates mode="section"/>
                        </xd:section>
                    </xsl:for-each>
                </xd:short>
            </xsl:when>
            <xsl:when test="count(child::*[local-name()='short'])=1">
                <xd:short>
                    <xsl:apply-templates select="child::*[local-name()='short']/node()"
                        mode="section"/>
                </xd:short>
            </xsl:when>
            <xsl:when test="child::text()[string-length(normalize-space())>0]">
                <xsl:variable name="short"
                    select="replace(normalize-space(child::text()[1]),'^(.+?\.)\s.*$','$1')"/>
                <xd:short>
                    <xsl:value-of select="$short"/>
                </xd:short>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Determines the detailed description.</xd:short>
        <xd:detail>The detailed description will be put together based on any number of
            &lt;xd:detail/&gt;-elements, as well as any number of text nodes that are direct
            children of the &lt;xd:doc/&gt;-element. If the xd:short was extracted from the first
            text node, then the first sentence from that text node will be ignored. If there are
            multiple &lt;xd:detail/&gt; and text nodes, then each of them will be wrapped in
            &lt;xd:section/&gt;s.</xd:detail>
    </xd:doc>
    <xsl:template name="detail">
        <xsl:variable name="shortInFirstText" select="count(./*[local-name()='short'])=0"/>
        <xsl:variable name="detailCount"
            select="(if (matches(normalize-space(./text()[1]),'\.\s[^\s]')) then 1 else 0) + count(*[local-name()='detail' and (descendant-or-self::node()[self::text() and string-length(normalize-space())>0 or local-name()='pre' and not(ancestor::*[local-name()='pre'])])]) + count(./text()[not(position()=1) and string-length(normalize-space())>0])"/>
        <xsl:if test="$detailCount>0">
            <xd:detail>
                <xsl:for-each select="*|text()">
                    <xsl:choose>
                        <xsl:when
                            test="self::text() and count(preceding-sibling::text()[string-length(normalize-space())>0])=0">
                            <!-- first text -->
                            <xsl:choose>
                                <xsl:when test="$shortInFirstText">
                                    <xsl:variable name="detail"
                                        select="replace(normalize-space(),'^.+?\.\s(.+)$','$1')"/>
                                    <xsl:choose>
                                        <xsl:when test="$detailCount>1">
                                            <xd:section>
                                                <xsl:value-of select="$detail"/>
                                            </xd:section>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$detail"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$detailCount>1">
                                            <xd:section>
                                                <xsl:value-of select="."/>
                                            </xd:section>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="self::text()">
                            <!-- non-first text -->
                            <xsl:choose>
                                <xsl:when test="$detailCount>1">
                                    <xd:section>
                                        <xsl:value-of select="."/>
                                    </xd:section>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="local-name()='detail'">
                            <!-- detail element -->
                            <xsl:choose>
                                <xsl:when test="$detailCount>1">
                                    <xd:section>
                                        <xsl:apply-templates select="child::node()" mode="section"/>
                                    </xd:section>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="child::node()" mode="section"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xd:detail>
        </xsl:if>
    </xsl:template>

    <xd:doc>Normalizes the xd:author-elements. &gt;xd:author/&lt;s with no text are removed.
        &lt;xd:author/&gt;s with no child elements will have their text content wrapped in a
        &lt;xd:name/&gt; element. Children other than xd:name, xd:mailto and xd:organization are
        ignored.</xd:doc>
    <xsl:template name="authors" xml:id="authors">
        <xsl:for-each select="*[local-name()='author']">
            <xsl:variable name="is-empty"
                select="count(descendant-or-self::text()[string-length(normalize-space())>0])=0"/>
            <xsl:if test="not($is-empty)">
                <xd:author>
                    <xsl:choose>
                        <xsl:when test="count(child::*)=0">
                            <xd:name>
                                <xsl:value-of select="."/>
                            </xd:name>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="child::*[local-name()='name']">
                                <xd:name>
                                    <xsl:value-of select="child::*[local-name()='name']"/>
                                </xd:name>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='mailto']">
                                <xd:mailto>
                                    <xsl:value-of select="child::*[local-name()='mailto']"/>
                                </xd:mailto>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='organization']">
                                <xd:organization>
                                    <xsl:value-of select="child::*[local-name()='organization']"/>
                                </xd:organization>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xd:author>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>&lt;xd:contributor/&gt;s are normalized in the same way as &lt;xd:author/&gt;s
            <xd:see>#authors</xd:see></xd:doc>
    <xsl:template name="contributors">
        <xsl:for-each select="*[local-name()='contributor']">
            <xsl:variable name="is-empty"
                select="count(descendant-or-self::text()[string-length(normalize-space())>0])=0"/>
            <xsl:if test="not($is-empty)">
                <xd:contributor>
                    <xsl:choose>
                        <xsl:when test="count(child::*)=0">
                            <xd:name>
                                <xsl:value-of select="."/>
                            </xd:name>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="child::*[local-name()='name']">
                                <xd:name>
                                    <xsl:value-of select="child::*[local-name()='name']"/>
                                </xd:name>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='mailto']">
                                <xd:mailto>
                                    <xsl:value-of select="child::*[local-name()='mailto']"/>
                                </xd:mailto>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='organization']">
                                <xd:organization>
                                    <xsl:value-of select="child::*[local-name()='organization']"/>
                                </xd:organization>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xd:contributor>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>&lt;xd:maintainer/&gt;s are normalized in the same way as &lt;xd:author/&gt;s
            <xd:see>#authors</xd:see></xd:doc>
    <xsl:template name="maintainers">
        <xsl:for-each select="*[local-name()='maintainer']">
            <xsl:variable name="is-empty"
                select="count(descendant-or-self::text()[string-length(normalize-space())>0])=0"/>
            <xsl:if test="not($is-empty)">
                <xd:maintainer>
                    <xsl:choose>
                        <xsl:when test="count(child::*)=0">
                            <xd:name>
                                <xsl:value-of select="."/>
                            </xd:name>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="child::*[local-name()='name']">
                                <xd:name>
                                    <xsl:value-of select="child::*[local-name()='name']"/>
                                </xd:name>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='mailto']">
                                <xd:mailto>
                                    <xsl:value-of select="child::*[local-name()='mailto']"/>
                                </xd:mailto>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='organization']">
                                <xd:organization>
                                    <xsl:value-of select="child::*[local-name()='organization']"/>
                                </xd:organization>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xd:maintainer>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>Normalizes the xd:copyright-element. &gt;xd:copyright/&lt;s with no text are removed.
        &lt;xd:copyright/&gt;s with no child elements will have their text content wrapped in a
        &lt;xd:name/&gt; element. Children other than xd:year, xd:name, xd:mailto and
        xd:organization are ignored.</xd:doc>
    <xsl:template name="copyright">
        <xsl:for-each select="*[local-name()='copyright']">
            <xsl:variable name="is-empty"
                select="count(descendant-or-self::text()[string-length(normalize-space())>0])=0"/>
            <xsl:if test="not($is-empty)">
                <xd:copyright>
                    <xsl:choose>
                        <xsl:when test="count(child::*)=0">
                            <xd:name>
                                <xsl:value-of select="."/>
                            </xd:name>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="child::*[local-name()='year']">
                                <xd:year>
                                    <xsl:value-of select="child::*[local-name()='year']"/>
                                </xd:year>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='name']">
                                <xd:name>
                                    <xsl:value-of select="child::*[local-name()='name']"/>
                                </xd:name>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='mailto']">
                                <xd:mailto>
                                    <xsl:value-of select="child::*[local-name()='mailto']"/>
                                </xd:mailto>
                            </xsl:if>
                            <xsl:if test="child::*[local-name()='organization']">
                                <xd:organization>
                                    <xsl:value-of select="child::*[local-name()='organization']"/>
                                </xd:organization>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xd:copyright>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>Normalizes xd:version elements.</xd:doc>
    <xsl:template name="version">
        <xsl:if
            test="child::*[local-name()='version' and string-length(normalize-space(./text()))>0]">
            <xd:version>
                <xsl:value-of
                    select="child::*[local-name()='version' and string-length(normalize-space(./text()))>0]"
                />
            </xd:version>
        </xsl:if>
    </xsl:template>

    <xd:doc>Normalizes xd:since elements.</xd:doc>
    <xsl:template name="since">
        <xsl:if test="child::*[local-name()='since' and string-length(normalize-space(./text()))>0]">
            <xd:since>
                <xsl:value-of
                    select="child::*[local-name()='since' and string-length(normalize-space(./text()))>0]"
                />
            </xd:since>
        </xsl:if>
    </xsl:template>

    <xd:doc>Normalizes xd:see elements.</xd:doc>
    <xsl:template name="see">
        <xsl:if test="child::*[local-name()='see' and string-length(normalize-space(./text()))>0]">
            <xd:see>
                <xsl:value-of
                    select="child::*[local-name()='see' and string-length(normalize-space(./text()))>0]"
                />
            </xd:see>
        </xsl:if>
    </xsl:template>

    <xd:doc>Normalizes xd:deprecated elements.</xd:doc>
    <xsl:template name="deprecated">
        <xsl:if
            test="child::*[local-name()='deprecated' and string-length(normalize-space(./text()))>0]">
            <xd:deprecated>
                <xsl:value-of
                    select="child::*[local-name()='deprecated' and string-length(normalize-space(./text()))>0]"
                />
            </xd:deprecated>
        </xsl:if>
    </xsl:template>

    <xd:doc>Normalizes xd:import elements. Will create empty documentation for imports that are not
        documented, and removes documentation of imports that does not exist in the code.</xd:doc>
    <xsl:template name="import">
        <xsl:param name="code" required="yes"/>
        <xsl:variable name="doc" select="."/>
        <xsl:for-each select="$code/xsl:import">
            <xsl:variable name="href" select="@href"/>
            <xd:import href="{@href}">
                <xsl:if test="$doc/*[local-name()='import' and @href=$href]">
                    <xsl:value-of select="$doc/*[local-name()='import' and @href=$href]"/>
                </xsl:if>
            </xd:import>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>Normalizes xd:include elements. Will create empty documentation for includes that are
        not documented, and removes documentation of includes that does not exist in the
        code.</xd:doc>
    <xsl:template name="include">
        <xsl:param name="code" required="yes"/>
        <xsl:variable name="doc" select="."/>
        <xsl:for-each select="$code/xsl:include">
            <xsl:variable name="href" select="@href"/>
            <xd:include href="{@href}">
                <xsl:if test="$doc/*[local-name()='include' and @href=$href]">
                    <xsl:value-of select="$doc/*[local-name()='include' and @href=$href]"/>
                </xsl:if>
            </xd:include>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>Normalizes xd:import elements. Will create empty documentation for imports that are not
        documented, and removes documentation of imports that does not exist in the code.</xd:doc>
    <xsl:template name="param">
        <xsl:param name="code" required="yes"/>
        <xsl:variable name="doc" select="."/>
        <xsl:for-each select="*[local-name()='param']">
            <xd:param>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates mode="section" select="node()"/>
            </xd:param>
        </xsl:for-each>
        <xsl:for-each select="$code/xsl:param">
            <xsl:variable name="name" select="@name"/>
            <xsl:if test="not($doc/*[local-name()='param' and @name=$name])">
                <xd:param name="{@name}"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>Describes the result of the code.</xd:doc>
    <xsl:template name="return">
        <xsl:variable name="is-empty"
            select="count(*[local-name()='return']/descendant-or-self::node()[self::text() and string-length(normalize-space())>0 or local-name()='pre'])=0"/>
        <xsl:if test="not($is-empty)">
            <xd:return>
                <xsl:apply-templates mode="section" select="*[local-name()='return']/node()"/>
            </xd:return>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Matches all elements when in "section"-mode.</xd:short>
        <xd:detail>Checks all child elements and their descendants and wraps and handles as is
            appropriate. If a child or descendant is placed in a problematic position, then one of
            the unwrap*-templates are called to solve the problem. Otherwise, just make sure that
            the element is in the correct namespace and copy it.</xd:detail>
    </xd:doc>
    <xsl:template mode="section" match="@*|node()">
        <xsl:param name="wrapin-p" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-ul" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-li" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:variable name="is-empty"
            select="count(descendant-or-self::node()[self::text() and string-length(normalize-space())>0 or local-name()='pre'])=0"/>
        <xsl:variable name="contains-section"
            select="count(descendant::*[local-name()='section'])>0"/>
        <xsl:variable name="contains-block"
            select="count(descendant::*[local-name()='ul' or local-name()='li' or local-name()='pre' or local-name()='p'])>0"/>
        <xsl:variable name="contains-block-non-li"
            select="count(descendant::*[local-name()='ul' or local-name()='pre' or local-name()='p'])>0"/>
        <xsl:choose>
            <xsl:when test="local-name()='section'">
                <xd:section>
                    <xsl:apply-templates mode="section" select="@*|node()"/>
                </xd:section>
            </xsl:when>
            <xsl:when test="local-name()='p'">
                <xsl:choose>
                    <xsl:when test="$contains-section or $contains-block">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-p" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:p>
                            <xsl:apply-templates mode="phrase" select="@*|node()">
                                <xsl:with-param name="wrapin-p" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='pre'">
                <xd:pre>
                    <xsl:copy-of select="@*|node()"/>
                </xd:pre>
            </xsl:when>
            <xsl:when test="local-name()='ul'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-section">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$contains-block-non-li">
                        <xd:section>
                            <xsl:call-template name="unwrap-to-blocks">
                                <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                            </xsl:call-template>
                        </xd:section>
                    </xsl:when>
                    <xsl:when test="count(descendant::*[local-name()='li'])=0">
                        <xsl:choose>
                            <xsl:when
                                test="count(child::node()[self::* or self::text() and string-length(normalize-space())>0])>1">
                                <xd:section>
                                    <xsl:apply-templates mode="section" select="@*|node()">
                                        <xsl:with-param name="wrapin-ul" select="true()"
                                            tunnel="yes"/>
                                        <xsl:with-param name="wrapin-li" select="true()"
                                            tunnel="yes"/>
                                    </xsl:apply-templates>
                                </xd:section>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="section" select="@*|node()">
                                    <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-li" select="true()" tunnel="yes"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:ul>
                            <xsl:apply-templates mode="list" select="@*|node()">
                                <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='li'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-section">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-li" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-li" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:ul>
                            <xd:li>
                                <xsl:apply-templates mode="phrase" select="@*|node()"/>
                            </xd:li>
                        </xd:ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='b'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-section">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-b" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-b" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:b>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:b>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='i'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-section">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-i" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-i" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:i>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:i>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='a'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-section">
                        <xsl:call-template name="unwrap-to-sections">
                            <xsl:with-param name="wrapin-a" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-a-elem" select="." tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-a" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-a-elem" select="." tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:a>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates mode="phrase" select="node()"/>
                        </xd:a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="self::*">
                        <xsl:choose>
                            <xsl:when test="not(preceding-sibling::*) and not(following-sibling::*)">
                                <xsl:apply-templates mode="section" select="@*|node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xd:section>
                                    <xsl:apply-templates mode="section" select="@*|node()"/>
                                </xd:section>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="self::text()">
                        <xsl:copy/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="section" select="@*|node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>Handles non-problematic lists.</xd:doc>
    <xsl:template mode="list" match="@*|node()">
        <xsl:param name="wrapin-p" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-ul" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-li" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:variable name="is-empty"
            select="count(descendant-or-self::node()[self::text() and string-length(normalize-space())>0 or local-name()='pre'])=0"/>
        <xsl:variable name="contains-block"
            select="count(descendant::*[local-name()='ul' or local-name()='li' or local-name()='pre' or local-name()='p'])>0"/>
        <xsl:choose>
            <xsl:when test="local-name()='li'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-li" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$wrapin-ul">
                        <xd:ul>
                            <xd:li>
                                <xsl:apply-templates mode="phrase" select="@*|node()"/>
                            </xd:li>
                        </xd:ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:li>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:li>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:copy/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="list" select="@*|node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>Handles all elements when in "block" mode and applies fixes where needed.</xd:doc>
    <xsl:template mode="block" match="@*|node()">
        <xsl:param name="wrapin-p" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-ul" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-li" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:variable name="element" select="."/>
        <xsl:variable name="is-empty"
            select="count(descendant-or-self::node()[self::* or self::text() and string-length(normalize-space())>0])=0"/>
        <xsl:variable name="contains-block"
            select="count(descendant::*[local-name()='ul' or local-name()='li' or local-name()='pre' or local-name()='p'])>0"/>
        <xsl:variable name="contains-block-non-li"
            select="count(descendant::*[local-name()='ul' or local-name()='pre' or local-name()='p'])>0"/>
        <xsl:choose>
            <xsl:when test="local-name()='p'">
                <xsl:choose>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:p>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='pre'">
                <xd:pre>
                    <xsl:copy-of select="@*|node()"/>
                </xd:pre>
            </xsl:when>
            <xsl:when test="local-name()='ul'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block-non-li">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when
                        test="count(descendant::*[local-name()='li' and string-length(normalize-space(descendant-or-self::text()))>0])=0">
                        <xsl:apply-templates mode="block" select="@*|node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:ul>
                            <xsl:apply-templates mode="list" select="@*|node()">
                                <xsl:with-param name="wrapin-ul" select="false()"/>
                            </xsl:apply-templates>
                        </xd:ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='li'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-ul" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-li" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:ul>
                            <xd:li>
                                <xsl:apply-templates mode="phrase" select="@*|node()">
                                    <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-li" select="false()" tunnel="yes"/>
                                </xsl:apply-templates>
                            </xd:li>
                        </xd:ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="not($contains-block) and $wrapin-p">
                <xd:p>
                    <xsl:apply-templates mode="phrase" select="@*|node()">
                        <xsl:with-param name="wrapin-p" select="false()" tunnel="yes"/>
                        <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                        <xsl:with-param name="wrapin-li" select="false()" tunnel="yes"/>
                    </xsl:apply-templates>
                </xd:p>
            </xsl:when>
            <xsl:when test="not($contains-block) and $wrapin-li">
                <xd:ul>
                    <xd:li>
                        <xsl:apply-templates mode="phrase" select="@*|node()">
                            <xsl:with-param name="wrapin-p" select="false()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-li" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xd:li>
                </xd:ul>
            </xsl:when>
            <xsl:when test="local-name()='b'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-b" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:b>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:b>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='i'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-i" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:i>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:i>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='a'">
                <xsl:choose>
                    <xsl:when test="$is-empty"/>
                    <xsl:when test="$contains-block">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-a" select="true()" tunnel="yes"/>
                            <xsl:with-param name="wrapin-a-elem" select="$element" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xd:a>
                            <xsl:apply-templates mode="phrase" select="$element/@*"/>
                            <xsl:apply-templates mode="phrase" select="@*|node()"/>
                        </xd:a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:copy/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="block" select="@*|node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>Phrases are matched with this template (mode="phrase") and handled
        appropriately.</xd:doc>
    <xsl:template mode="phrase" match="@*|node()">
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:choose>
            <xsl:when test="local-name()='b'">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='b'])">
                        <xd:b>
                            <xsl:apply-templates mode="phrase" select="@*|node()">
                                <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:b>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select="@*|node()">
                            <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$wrapin-b">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='b'])">
                        <xd:b>
                            <xsl:apply-templates mode="phrase" select=".">
                                <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:b>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select=".">
                            <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='i'">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='i'])">
                        <xd:i>
                            <xsl:apply-templates mode="phrase" select="@*|node()">
                                <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select="@*|node()">
                            <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$wrapin-i">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='i'])">
                        <xd:i>
                            <xsl:apply-templates mode="phrase" select=".">
                                <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select=".">
                            <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name()='a'">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='a'])">
                        <xd:a>
                            <xsl:apply-templates mode="phrase" select="$wrapin-a-elem/@*"/>
                            <xsl:apply-templates mode="phrase" select="node()">
                                <xsl:with-param name="wrapin-a" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select="@*|node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$wrapin-a">
                <xsl:choose>
                    <xsl:when test="not(ancestor::*[local-name()='a'])">
                        <xd:a>
                            <xsl:apply-templates mode="phrase" select="$wrapin-a-elem/@*"/>
                            <xsl:apply-templates mode="phrase" select=".">
                                <xsl:with-param name="wrapin-a" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xd:a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select=".">
                            <xsl:with-param name="wrapin-a" select="false()" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:copy/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="phrase" select="@*|node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>This template unwraps problematic elements into sections.</xd:doc>
    <xsl:template name="unwrap-to-sections">
        <xsl:param name="wasWrapped" select="false()"/>
        <xsl:param name="wrapin-p" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-ul" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-li" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:variable name="element" select="."/>
        <xsl:choose>
            <xsl:when
                test="not($wasWrapped) and count(child::node()[self::* or self::text() and string-length(normalize-space())>0])>1">
                <xd:section>
                    <xsl:call-template name="unwrap-to-sections">
                        <xsl:with-param name="wasWrapped" select="true()"/>
                    </xsl:call-template>
                </xd:section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group
                    select="child::node()[self::* or self::text() and string-length(normalize-space())>0]"
                    group-adjacent="self::* and not(ancestor::*[local-name()='pre']) and (local-name()='section' or local-name()='ul' or local-name()='li' or local-name()='pre' or local-name()='p')">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:choose>
                                <xsl:when test="count(current-group())>1 and last()>1">
                                    <xd:section>
                                        <xsl:apply-templates mode="section" select="current-group()">
                                            <xsl:with-param name="wrapin-p" tunnel="yes"
                                                select="if ($wrapin-p or local-name($element)='p') then true() else false()"/>
                                            <xsl:with-param name="wrapin-ul" tunnel="yes"
                                                select="if ($wrapin-ul or local-name($element)='ul') then true() else false()"/>
                                            <xsl:with-param name="wrapin-li" tunnel="yes"
                                                select="if ($wrapin-li or local-name($element)='li') then true() else false()"/>
                                            <xsl:with-param name="wrapin-b" tunnel="yes"
                                                select="if ($wrapin-b or local-name($element)='b') then true() else false()"/>
                                            <xsl:with-param name="wrapin-i" tunnel="yes"
                                                select="if ($wrapin-i or local-name($element)='i') then true() else false()"/>
                                            <xsl:with-param name="wrapin-a" tunnel="yes"
                                                select="if ($wrapin-a or local-name($element)='a') then true() else false()"/>
                                            <xsl:with-param name="wrapin-a-elem" tunnel="yes"
                                                select="if (not($wrapin-a) and local-name($element)='a') then $element else false()"
                                            />
                                        </xsl:apply-templates>
                                    </xd:section>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates mode="section" select="current-group()">
                                        <xsl:with-param name="wrapin-p" tunnel="yes"
                                            select="if ($wrapin-p or local-name($element)='p') then true() else false()"/>
                                        <xsl:with-param name="wrapin-ul" tunnel="yes"
                                            select="if ($wrapin-ul or local-name($element)='ul') then true() else false()"/>
                                        <xsl:with-param name="wrapin-li" tunnel="yes"
                                            select="if ($wrapin-li or local-name($element)='li') then true() else false()"/>
                                        <xsl:with-param name="wrapin-b" tunnel="yes"
                                            select="if ($wrapin-b or local-name($element)='b') then true() else false()"/>
                                        <xsl:with-param name="wrapin-i" tunnel="yes"
                                            select="if ($wrapin-i or local-name($element)='i') then true() else false()"/>
                                        <xsl:with-param name="wrapin-a" tunnel="yes"
                                            select="if ($wrapin-a or local-name($element)='a') then true() else false()"/>
                                        <xsl:with-param name="wrapin-a-elem" tunnel="yes"
                                            select="if (not($wrapin-a) and local-name($element)='a') then $element else false()"
                                        />
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="xd:{local-name($element)}">
                                <xsl:for-each select="$element/@*">
                                    <xsl:attribute name="xd:{local-name()}" select="."/>
                                </xsl:for-each>
                                <xsl:apply-templates mode="phrase" select="current-group()">
                                    <xsl:with-param name="wrapin-p" tunnel="yes"
                                        select="if ($wrapin-p or local-name($element)='p') then false() else $wrapin-p"/>
                                    <xsl:with-param name="wrapin-ul" tunnel="yes"
                                        select="if ($wrapin-ul or local-name($element)='ul') then false() else $wrapin-ul"/>
                                    <xsl:with-param name="wrapin-li" tunnel="yes"
                                        select="if ($wrapin-li or local-name($element)='li') then false() else $wrapin-li"/>
                                    <xsl:with-param name="wrapin-b" tunnel="yes"
                                        select="if ($wrapin-b or local-name($element)='b') then false() else $wrapin-b"/>
                                    <xsl:with-param name="wrapin-i" tunnel="yes"
                                        select="if ($wrapin-i or local-name($element)='i') then false() else $wrapin-i"/>
                                    <xsl:with-param name="wrapin-a" tunnel="yes"
                                        select="if ($wrapin-a or local-name($element)='a') then false() else $wrapin-a"
                                    />
                                </xsl:apply-templates>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>This template unwraps problematic elements into blocks.</xd:doc>
    <xsl:template name="unwrap-to-blocks">
        <xsl:param name="wrapin-p" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-ul" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-li" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-b" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-i" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a" tunnel="yes" select="false()"/>
        <xsl:param name="wrapin-a-elem" tunnel="yes" select="false()"/>
        <xsl:variable name="element" select="."/>
        <xsl:for-each-group
            select="child::node()[self::* or self::text() and string-length(normalize-space())>0]"
            group-adjacent="count(descendant-or-self::*[local-name()='ul' or local-name()='li' or local-name()='pre' or local-name()='p'])>0">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:for-each select="current-group()">
                        <xsl:call-template name="unwrap-to-blocks">
                            <xsl:with-param name="wrapin-p"
                                select="$wrapin-p or local-name()='p' or local-name($element)='p'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-ul"
                                select="$wrapin-ul or local-name()='ul' or local-name($element)='ul'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-li"
                                select="$wrapin-li or local-name()='li' or local-name($element)='li'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-b"
                                select="$wrapin-b or local-name()='b' or local-name($element)='b'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-i"
                                select="$wrapin-i or local-name()='i' or local-name($element)='i'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-a"
                                select="$wrapin-a or local-name()='a' or local-name($element)='a'"
                                tunnel="yes"/>
                            <xsl:with-param name="wrapin-a-elem"
                                select="if (local-name()='a') then . else (if (local-name($element)='a') then $element else $wrapin-a-elem)"
                                tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$wrapin-p">
                            <xd:p>
                                <xsl:choose>
                                    <xsl:when test="$wrapin-b">
                                        <xd:b>
                                            <xsl:choose>
                                                <xsl:when test="$wrapin-i">
                                                  <xd:i>
                                                  <xsl:choose>
                                                  <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xd:i>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xd:b>
                                    </xsl:when>
                                    <xsl:when test="$wrapin-i">
                                        <xd:i>
                                            <xsl:choose>
                                                <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xd:i>
                                    </xsl:when>
                                    <xsl:when test="$wrapin-a">
                                        <xd:a>
                                            <xsl:apply-templates mode="phrase"
                                                select="$wrapin-a-elem/@*"/>
                                            <xsl:apply-templates mode="phrase"
                                                select="current-group()">
                                                <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xd:a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates mode="phrase" select="current-group()">
                                            <xsl:with-param name="wrapin-p" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-ul" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-li" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-b" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-i" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-a" select="false()"
                                                tunnel="yes"/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xd:p>
                        </xsl:when>
                        <xsl:when test="$wrapin-li">
                            <xd:ul>
                                <xd:li>
                                    <xsl:choose>
                                        <xsl:when test="$wrapin-b">
                                            <xd:b>
                                                <xsl:choose>
                                                  <xsl:when test="$wrapin-i">
                                                  <xd:i>
                                                  <xsl:choose>
                                                  <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xd:i>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xd:b>
                                        </xsl:when>
                                        <xsl:when test="$wrapin-i">
                                            <xd:i>
                                                <xsl:choose>
                                                  <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xd:i>
                                        </xsl:when>
                                        <xsl:when test="$wrapin-a">
                                            <xd:a>
                                                <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                </xsl:apply-templates>
                                            </xd:a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates mode="phrase"
                                                select="current-group()">
                                                <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xd:li>
                            </xd:ul>
                        </xsl:when>
                        <xsl:when test="$wrapin-ul">
                            <xd:p>
                                <xsl:choose>
                                    <xsl:when test="$wrapin-b">
                                        <xd:b>
                                            <xsl:choose>
                                                <xsl:when test="$wrapin-i">
                                                  <xd:i>
                                                  <xsl:choose>
                                                  <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xd:i>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xd:b>
                                    </xsl:when>
                                    <xsl:when test="$wrapin-i">
                                        <xd:i>
                                            <xsl:choose>
                                                <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xd:i>
                                    </xsl:when>
                                    <xsl:when test="$wrapin-a">
                                        <xd:a>
                                            <xsl:apply-templates mode="phrase"
                                                select="$wrapin-a-elem/@*"/>
                                            <xsl:apply-templates mode="phrase"
                                                select="current-group()">
                                                <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xd:a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates mode="phrase" select="current-group()">
                                            <xsl:with-param name="wrapin-p" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-ul" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-li" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-b" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-i" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-a" select="false()"
                                                tunnel="yes"/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xd:p>
                        </xsl:when>
                        <xsl:when test="$wrapin-b">
                            <xd:b>
                                <xsl:choose>
                                    <xsl:when test="$wrapin-i">
                                        <xd:i>
                                            <xsl:choose>
                                                <xsl:when test="$wrapin-a">
                                                  <xd:a>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="$wrapin-a-elem/@*"/>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                  </xd:a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:apply-templates mode="phrase"
                                                  select="current-group()">
                                                  <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                  <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                                  </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xd:i>
                                    </xsl:when>
                                    <xsl:when test="$wrapin-a">
                                        <xd:a>
                                            <xsl:apply-templates mode="phrase"
                                                select="$wrapin-a-elem/@*"/>
                                            <xsl:apply-templates mode="phrase"
                                                select="current-group()">
                                                <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xd:a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates mode="phrase" select="current-group()">
                                            <xsl:with-param name="wrapin-p" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-ul" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-li" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-b" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-i" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-a" select="false()"
                                                tunnel="yes"/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xd:b>
                        </xsl:when>
                        <xsl:when test="$wrapin-i">
                            <xd:i>
                                <xsl:choose>
                                    <xsl:when test="$wrapin-a">
                                        <xd:a>
                                            <xsl:apply-templates mode="phrase"
                                                select="$wrapin-a-elem/@*"/>
                                            <xsl:apply-templates mode="phrase"
                                                select="current-group()">
                                                <xsl:with-param name="wrapin-p" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-ul" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-li" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-b" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-i" select="false()"
                                                  tunnel="yes"/>
                                                <xsl:with-param name="wrapin-a" select="false()"
                                                  tunnel="yes"/>
                                            </xsl:apply-templates>
                                        </xd:a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates mode="phrase" select="current-group()">
                                            <xsl:with-param name="wrapin-p" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-ul" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-li" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-b" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-i" select="false()"
                                                tunnel="yes"/>
                                            <xsl:with-param name="wrapin-a" select="false()"
                                                tunnel="yes"/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xd:i>
                        </xsl:when>
                        <xsl:when test="$wrapin-a">
                            <xd:a>
                                <xsl:apply-templates mode="phrase" select="$wrapin-a-elem/@*"/>
                                <xsl:apply-templates mode="phrase" select="current-group()">
                                    <xsl:with-param name="wrapin-p" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-li" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                                    <xsl:with-param name="wrapin-a" select="false()" tunnel="yes"/>
                                </xsl:apply-templates>
                            </xd:a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="phrase" select="current-group()">
                                <xsl:with-param name="wrapin-p" select="false()" tunnel="yes"/>
                                <xsl:with-param name="wrapin-ul" select="false()" tunnel="yes"/>
                                <xsl:with-param name="wrapin-li" select="false()" tunnel="yes"/>
                                <xsl:with-param name="wrapin-b" select="false()" tunnel="yes"/>
                                <xsl:with-param name="wrapin-i" select="false()" tunnel="yes"/>
                                <xsl:with-param name="wrapin-a" select="false()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>

</xsl:stylesheet>
