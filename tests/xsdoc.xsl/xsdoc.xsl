<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://pipeline.daisy.org/ns/sample/doc"
  xmlns:xsltdoc="http://www.pnp-software.com/XSLTdoc" exclude-result-prefixes="#all" version="2.0">

  <xsl:import href="xml-to-string.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xd:doc target="parent">
    <xd:short>Transforms the input XSLT document to a DITA Reference Topic.</xd:short>
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
  </xd:doc>

  <xd:doc target="following">
    <xd:short>Override the "/" template in <xd:code>xml-to-string.xsl</xd:code>.</xd:short>
  </xd:doc>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xd:doc target="following">
    <xd:short>Identity template.</xd:short>
  </xd:doc>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xd:doc target="following">
    <xd:short>Main template</xd:short>
    <xd:detail>Creates the top element &lt;dita&gt;, determines how to document the XSLT stylesheet
      itself, and recurses throught the code looking for xd:doc elements.</xd:detail>
  </xd:doc>
  <xsl:template match="/*">
    <dita>
      <xsl:choose>

        <!-- When the root element contains a xd:doc child targeting it, use it -->
        <xsl:when test="./xsltdoc:doc[@target='parent']">
          <xsl:variable name="parentdoc" select="./xsltdoc:doc[@target='parent'][1]"/>
          <xsl:call-template name="doc">
            <xsl:with-param name="doc" select="$parentdoc"/>
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
          <xsl:call-template name="subdoc">
            <xsl:with-param name="code" select="."/>
            <xsl:with-param name="parentdoc" select="$parentdoc"/>
          </xsl:call-template>
        </xsl:when>

        <!-- Same as above, but in the XSLTdoc namespace -->
        <xsl:when test="./xd:doc[@target='parent']">
          <xsl:variable name="parentdoc" select="./xd:doc[@target='parent'][1]"/>
          <xsl:call-template name="doc">
            <xsl:with-param name="doc" select="$parentdoc"/>
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
          <xsl:call-template name="subdoc">
            <xsl:with-param name="code" select="."/>
            <xsl:with-param name="parentdoc" select="$parentdoc"/>
          </xsl:call-template>
        </xsl:when>

        <!-- When the first child of the root element is a xd:doc and is not targeting another element, use it -->
        <xsl:when
          test="(name(./*[1])='xsltdoc:doc' or name(./*[1])='xd:doc') and not(./*[1]/@target='following')">
          <xsl:variable name="parentdoc" select="./*[1]"/>
          <xsl:call-template name="doc">
            <xsl:with-param name="doc" select="$parentdoc"/>
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
          <xsl:call-template name="subdoc">
            <xsl:with-param name="code" select="."/>
            <xsl:with-param name="parentdoc" select="$parentdoc"/>
          </xsl:call-template>
        </xsl:when>

        <!-- The root element is not documented. Create some empty documentation for it. -->
        <xsl:otherwise>
          <xsl:call-template name="doc">
            <xsl:with-param name="doc">
              <xsl:element name="xd:doc"/>
            </xsl:with-param>
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
          <xsl:call-template name="subdoc">
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
        </xsl:otherwise>

      </xsl:choose>
    </dita>
  </xsl:template>

  <xd:doc target="following">
    <xd:short>Recursive template that looks for xd:doc elements.</xd:short>
    <xd:detail>If there is a xd:doc belonging to the current element; document the current element
      using it. At the same time; recurse further through the script looking for more elements to be
      documented.</xd:detail>
    <xd:param name="code">Contains the element to be evaluted for documentation.</xd:param>
    <xd:param name="parentdoc">The xd:doc used to document the closest documented ancestor (used to
      make sure it isn't used twice).</xd:param>
  </xd:doc>
  <xsl:template name="subdoc">
    <xsl:param name="code" required="yes"/>
    <xsl:param name="parentdoc">
      <xsl:element name="xd:doc"/>
    </xsl:param>

    <xsl:if test="not(name($code) = 'xd:doc' or name($code) = 'xsltdoc:doc')">
      <xsl:for-each select="$code/*">
        <xsl:choose>
          <!-- Don't document the documentation ;) -->
          <xsl:when test="name(.) = 'xd:doc' or name(.) = 'xsltdoc:doc'"/>

          <!-- When the current element contains a xd:doc child targeting it, use it -->
          <xsl:when
            test="./xd:doc[@target='parent'][1] and not(generate-id(./xd:doc[@target='parent'][1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="./xd:doc[@target='parent'][1]"/>
            <xsl:call-template name="doc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- When the current element contains a xs:doc child targeting it, use it -->
          <xsl:when
            test="(./xsltdoc:doc[@target='parent'][1]) and not(generate-id(./xsltdoc:doc[@target='parent'][1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="./xsltdoc:doc[@target='parent'][1]"/>
            <xsl:call-template name="doc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- When the first child of the current element is a xd:doc and is not targeting another element, use it -->
          <xsl:when
            test="(name(./*[1]) = 'xd:doc' or name(./*[1]) = 'xsltdoc:doc') and not(./*[1]/@target = 'following') and not(generate-id(./*[1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="./*[1]"/>
            <xsl:call-template name="doc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- When the first preceding sibling is a xs:doc and is not targeting another element, use it -->
          <xsl:when
            test="(name(preceding-sibling::*[1]) = 'xd:doc' or name(preceding-sibling::*[1]) = 'xsltdoc:doc') and not(preceding-sibling::*[1]/@target = 'parent') and not(generate-id(preceding-sibling::*[1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="preceding-sibling::*[1]"/>
            <xsl:call-template name="doc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- The element has no documentation, and it's not the root element so don't document it -->
          <xsl:otherwise>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$parentdoc"/>
            </xsl:call-template>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xd:doc target="following">
    <xd:short>Documents an element using its corresponding xd:doc element.</xd:short>
    <xd:detail>This is where the main action happens. Relevant bits of information are retrieved and
      structured as DITA-XML.</xd:detail>
    <xd:param name="code">Contains the XSLT code to be documentated.</xd:param>
    <xd:param name="doc">Contains the xd:doc used as documentation.</xd:param>
  </xd:doc>
  <xsl:template name="doc">
    <xsl:param name="code" required="yes"/>
    <xsl:param name="doc" required="yes"/>

    <reference id="{generate-id($code)}">
      <title>
        <xsl:value-of select="name($code)"/>
        <xsl:if test="$code/@name"> - <xsl:value-of select="$code/@name"/>
        </xsl:if>
      </title>

      <abstract>
        <shortdesc>
          <xsl:apply-templates select="$doc/*[local-name()='short']/node()"/>
        </shortdesc>
        <xsl:apply-templates select="$doc/*[local-name()='detail']/node()"/>
      </abstract>

      <prolog>
        <xsl:for-each
          select="$doc/*[local-name()='author'] | $doc/*[local-name()='contributor'] | $doc/*[local-name()='maintainer']">
          <author>
            <xsl:choose>
              <xsl:when test="local-name() = 'author'">
                <xsl:attribute name="type">creator</xsl:attribute>
              </xsl:when>
              <xsl:when test="local-name() = 'contributor'">
                <xsl:attribute name="type">contributor</xsl:attribute>
              </xsl:when>
              <xsl:when test="local-name() = 'maintainer'">
                <xsl:attribute name="type">maintainer</xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="./*[local-name()='name']/node()"/>
            <xsl:if
              test="./*[local-name()='name'] and (./*[local-name()='organization'] or ./*[local-name()='mailto'])"
              ><![CDATA[, ]]></xsl:if>
            <xsl:apply-templates select="./*[local-name()='organization']/node()"/>
            <xsl:if test="./*[local-name()='organization'] and ./*[local-name()='mailto']"
              ><![CDATA[, ]]></xsl:if>
            <xsl:apply-templates select="./*[local-name()='mailto']/node()"/>
          </author>
        </xsl:for-each>
        <xsl:for-each select="$doc/*[local-name()='copyright']">

          <xsl:choose>
            <xsl:when test="count($doc/xd:copyright)>0">
              <copyright>
                <copyryear>
                  <xsl:attribute name="year">
                    <xsl:apply-templates select="$doc/xd:copyright/*[local-name()='year']/node()"/>
                  </xsl:attribute>
                </copyryear>
                <copyrholder>
                  <xsl:choose>
                    <xsl:when test="$doc/xd:copyright/*[local-name()='holder']">
                      <xsl:apply-templates
                        select="$doc/xd:copyright/*[local-name()='holder']/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:if test="$doc/xd:copyright/*[local-name()='name']">
                        <xsl:apply-templates
                          select="$doc/xd:copyright/*[local-name()='name']/node()"/>
                        <xsl:if
                          test="$doc/xd:copyright/*[local-name()='organization' or local-name()='mailto']"
                          ><![CDATA[, ]]></xsl:if>
                      </xsl:if><![CDATA[]]><xsl:if
                        test="$doc/xd:copyright/*[local-name()='organization']">
                        <xsl:apply-templates
                          select="$doc/xd:copyright/*[local-name()='organization']/node()"/>
                        <xsl:if test="$doc/xd:copyright/*[local-name()='mailto']"
                          ><![CDATA[, ]]></xsl:if>
                      </xsl:if><![CDATA[]]><xsl:if test="$doc/xd:copyright/*[local-name()='mailto']">
                        <xsl:apply-templates
                          select="$doc/xd:copyright/*[local-name()='mailto']/node()"/>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </copyrholder>
              </copyright>
            </xsl:when>
            <xsl:when test="count($doc/xsltdoc:copyright)>0">
              <copyright>
                <copyrholder>
                  <xsl:apply-templates select="$doc/xsltdoc:copyright/node()"/>
                </copyrholder>
              </copyright>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        <metadata>
          <audience type="programmer" job="programming" experiencelevel="expert"/>
          <othermeta name="programming-language" content="XSLT"/>
          <xsl:for-each select="$doc/*[local-name()='version']">
            <othermeta name="version">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>
          <xsl:for-each select="$doc/*[local-name()='since']">
            <othermeta name="since">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>
          <!--xsl:for-each select="$doc/*[local-name()='see']">
            <othermeta name="see">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each-->
          <xsl:for-each select="$doc/*[local-name()='deprecated']">
            <othermeta name="deprecated">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>

          <!-- XSLT and XPath version -->
          <xsl:if test="name($code)='xsl:stylesheet' or name($code)='xsl:transform'">
            <xsl:variable name="xslt-version" select="$code/@version | $code/@xsl:version"/>
            <othermeta name="xslt-version">
              <xsl:attribute name="content">
                <xsl:value-of select="$xslt-version"/>
              </xsl:attribute>
            </othermeta>
            <xsl:if test="$xslt-version='1.0' or $xslt-version='2.0'">
              <othermeta name="xpath-version">
                <xsl:attribute name="content">
                  <xsl:value-of select="$xslt-version"/>
                </xsl:attribute>
              </othermeta>
            </xsl:if>
          </xsl:if>

        </metadata>
      </prolog>

      <refbody>
        <section>
          <apiname>
            <xsl:value-of select="name($code)"/>
            <xsl:if test="$code/@name"> - <xsl:value-of select="$code/@name"/>
            </xsl:if>
          </apiname>
        </section>

        <xsl:if test="$code/xsl:param | $code/xsl:with-param">
          <section outputclass="parameters xslt-params">
            <title outputclass="io-header">Parameters (xsl:param / xsl:with-param)</title>
            <parml outputclass="xslt-params">
              <xsl:choose>
                <xsl:when test="count($code/xsl:with-param) > 0">
                  <xsl:attribute name="outputclass" select="'xslt-params xslt-with-params'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="outputclass" select="'xslt-params'"/>
                </xsl:otherwise>
              </xsl:choose>
              <!--plentry>
                <pt>Name</pt>
                <pd>As</pd>
                <xsl:if test="count($code/xsl:with-param) > 0">
                  <pd>Required</pd>
                </xsl:if>
                <pd>Tunnel</pd>
                <pd>Description</pd>
              </plentry-->
              <xsl:for-each select="$code/xsl:param | $code/xsl:with-param">
                <xsl:variable name="name" select="@name"/>
                <plentry>
                  <pt>
                    <xsl:value-of select="$name"/>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="@as">
                        <xsl:value-of select="@as"/>
                      </xsl:when>
                      <xsl:otherwise>undefined</xsl:otherwise>
                    </xsl:choose>
                  </pt>
                  <xsl:if test="name(.) = 'xsl:param'">
                    <pt>
                      <xsl:choose>
                        <xsl:when test="name(./parent::*) = 'xsl:function' or @required = 'true'"
                          >true</xsl:when>
                        <xsl:otherwise>false</xsl:otherwise>
                      </xsl:choose>
                    </pt>
                  </xsl:if>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="@tunnel='yes'">yes</xsl:when>
                      <xsl:otherwise>no</xsl:otherwise>
                    </xsl:choose>
                  </pt>
                  <xsl:choose>
                    <xsl:when test="name(.)='xsl:param'">
                      <pd>
                        <xsl:variable name="name" select="@name"/>
                        <xsl:apply-templates
                          select="$doc/*[local-name()='param'][@name=$name]/node()"/>
                      </pd>
                    </xsl:when>
                    <xsl:when test="name(.)='xsl:with-param'">
                      <pd>
                        <xsl:variable name="name" select="@name"/>
                        <xsl:apply-templates
                          select="$doc/*[local-name()='with-param'][@name=$name]/node()"/>
                      </pd>
                    </xsl:when>
                  </xsl:choose>
                </plentry>
              </xsl:for-each>
            </parml>
          </section>
        </xsl:if>

        <xsl:if test="name($code) = 'xsl:stylesheet' or name($code) = 'xsl:transform'">
          <section outputclass="parameters xslt-outputs">
            <title outputclass="io-header">Outputs (xsl:output)</title>
            <parml outputclass="xslt-outputs">
              <xsl:attribute name="outputclass" select="'xslt-outputs'"/>
              <!--
              name
              method
              indent
              doctype-system
              doctype-public
              include-content-type
              encoding
              media-type
              omit-xml-declaration
              standalone
              version
              comments
              -->
              <pt/>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@method">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@method[last()]"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@indent">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@indent[last()]"/>
                  </xsl:when>
                  <xsl:when test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xml'"
                    >no</xsl:when>
                  <xsl:when
                    test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'html' or lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xhtml'"
                    >yes</xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@doctype-system">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@doctype-system[last()]"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@doctype-public">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@doctype-public[last()]"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>

              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@include-content-type">
                    <xsl:value-of
                      select="$code/xsl:output[not(@name)]/@include-content-type[last()]"/>
                  </xsl:when>
                  <xsl:otherwise>yes</xsl:otherwise>
                </xsl:choose>

              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@encoding">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@encoding[last()]"/>
                  </xsl:when>
                  <xsl:when
                    test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xml' or lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xhtml'"
                    >UTF-8/UTF-16</xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@media-type">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@media-type[last()]"/>
                  </xsl:when>
                  <xsl:when test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xml'"
                    >text/xml</xsl:when>
                  <xsl:when
                    test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'html' or lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'xhtml'"
                    >text/html</xsl:when>
                  <xsl:when test="lower-case($code/xsl:output[not(@name)]/@method[last()]) = 'text'"
                    >text/plain</xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@omit-xml-declaration">
                    <xsl:value-of
                      select="$code/xsl:output[not(@name)]/@omit-xml-declaration[last()]"/>
                  </xsl:when>
                  <xsl:otherwise>no</xsl:otherwise>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@standalone">
                    <xsl:value-of
                      select="$code/xsl:output[not(@name)]/@standalone[last()] or 'omit'"/>
                  </xsl:when>
                  <xsl:otherwise>omit</xsl:otherwise>
                </xsl:choose>
              </pt>
              <pt>
                <xsl:choose>
                  <xsl:when test="$code/xsl:output[not(@name)]/@version">
                    <xsl:value-of select="$code/xsl:output[not(@name)]/@version[last()]"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </pt>
              <pd>
                <xsl:apply-templates select="$doc/*[local-name()='output' and not(@name)]/node()"/>
              </pd>
              <xsl:for-each select="$code/xsl:output[@name]">
                <xsl:if test="not(@name=preceding::xsl:output/@name)">
                  <xsl:variable name="name" select="@name"/>
                  <pt>
                    <xsl:value-of select="$name"/>
                  </pt>
                  <pt>
                    <xsl:value-of
                      select="$code/xsl:output[@name=$name]/@method[last()] or 'undefined'"/>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@indent">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@indent[last()]"/>
                      </xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xml'"
                        >no</xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'html' or lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xhtml'"
                        >yes</xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@doctype-system">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@doctype-system[last()]"
                        />
                      </xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@doctype-public">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@doctype-public[last()]"
                        />
                      </xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@include-content-type">
                        <xsl:value-of
                          select="$code/xsl:output[@name=$name]/@include-content-type[last()] or 'yes'"
                        />
                      </xsl:when>
                      <xsl:otherwise>yes</xsl:otherwise>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@encoding">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@encoding[last()]"/>
                      </xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xml' or lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xhtml'"
                        >UTF</xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@media-type">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@media-type[last()]"/>
                      </xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xml'"
                        >text/xml</xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'html' or lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'xhtml'"
                        >text/html</xsl:when>
                      <xsl:when
                        test="lower-case($code/xsl:output[@name=$name]/@method[last()]) = 'text'"
                        >text/plain</xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@omit-xml-declaration">
                        <xsl:value-of
                          select="$code/xsl:output[@name=$name]/@omit-xml-declaration[last()]"/>
                      </xsl:when>
                      <xsl:otherwise>no</xsl:otherwise>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@standalone">
                        <xsl:value-of select="$code/xsl:output[@name=$name]/@standalone[last()]"/>
                      </xsl:when>
                      <xsl:otherwise>omit</xsl:otherwise>
                    </xsl:choose>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="$code/xsl:output[@name=$name]/@version">
                        <xsl:value-of
                          select="$code/xsl:output[@name=$name]/@version[last()] or 'undefined'"/>
                      </xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <pd>
                    <xsl:apply-templates
                      select="$doc/*[local-name()='output' and @name=$name]/node()"/>
                  </pd>
                </xsl:if>
              </xsl:for-each>

            </parml>
          </section>
        </xsl:if>
      </refbody>

      <xsl:if
        test="(name($code) = 'xsl:stylesheet' or name($code) = 'xsl:transform') and (count($code//xsl:include) > 0 or count($code//xsl:import) > 0 or count($doc/*[local-name()='see']) > 0)">
        <related-links>
          <xsl:if test="count($code//xsl:include) > 0">
            <linklist>
              <title>Dependencies (xsl:include)</title>
              <xsl:for-each select="$code//xsl:include">
                <link href="{@href}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These dependencies are derived from the xsl:include statements.</linkinfo>
            </linklist>
          </xsl:if>
          <xsl:if test="count($code//xsl:import) > 0">
            <linklist>
              <title>Dependencies (xsl:import)</title>
              <xsl:for-each select="$code//xsl:import">
                <link href="{@href}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These dependencies are derived from the xsl:import statements.</linkinfo>
            </linklist>
          </xsl:if>
          <xsl:if test="count($doc/*[local-name()='see']) > 0">
            <linklist>
              <title>See also</title>
              <xsl:for-each select="$doc/*[local-name()='see']">
                <link href="{./text()}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These are related readings suggested by the author of the XSLT
                stylesheet.</linkinfo>
            </linklist>
          </xsl:if>
        </related-links>
      </xsl:if>

      <section outputclass="sourcecode">
        <title outputclass="sourcecode-header">Source Code</title>
        <codeblock>
          <xsl:for-each select="$code">
            <xsl:if test="not(self::xd:doc) and not(self::xsltdoc:doc)">
              <xsl:call-template name="xml-to-string"/>
            </xsl:if>
          </xsl:for-each>
        </codeblock>
      </section>
    </reference>

  </xsl:template>

  <xd:doc target="following">
    <xd:short>&lt;xd:code/&gt; becomes &lt;codeblock outputclass="language-xslt"/&gt;</xd:short>
  </xd:doc>
  <xsl:template match="xd:code">
    <codeblock outputclass="language-xslt"><xsl:apply-templates/></codeblock>
  </xsl:template>

</xsl:stylesheet>
