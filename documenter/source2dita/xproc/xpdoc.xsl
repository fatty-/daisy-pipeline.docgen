<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://pipeline.daisy.org/ns/sample/doc" exclude-result-prefixes="#all" version="2.0">

  <xsl:import href="../../lib/xml-to-string.xsl"/>

  <xd:doc target="parent">
    <xd:short>Transforms the input XProc document to a DITA Reference Topic.</xd:short>
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

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

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
    <!--xsl:choose>
      <xsl:when test="self::*">
        <xsl:element name="{local-name()}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise-->
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      <!--/xsl:otherwise>
    </xsl:choose-->
  </xsl:template>

  <xd:doc target="following">
    <xd:short>Main template</xd:short>
    <xd:detail>Creates the top element &lt;dita&gt;, determines how to document the XProc script
      itself, and recurses throught the code looking for p:documentation elements.</xd:detail>
  </xd:doc>
  <xsl:template match="/*">
    <dita>
      <xsl:choose>

        <!-- When the root element contains a p:documentation child targeting it, use it -->
        <xsl:when test="./p:documentation[@xd:target='parent']">
          <xsl:variable name="parentdoc" select="./p:documentation[@xd:target='parent'][1]"/>
          <xsl:call-template name="pipedoc">
            <xsl:with-param name="doc" select="$parentdoc"/>
            <xsl:with-param name="code" select="."/>
          </xsl:call-template>
          <xsl:call-template name="subdoc">
            <xsl:with-param name="code" select="."/>
            <xsl:with-param name="parentdoc" select="$parentdoc"/>
          </xsl:call-template>
        </xsl:when>

        <!-- When the first child of the root element is a p:documentation and is not targeting another element, use it -->
        <xsl:when test="name(./*[1]) = 'p:documentation' and not(./*[1]/@xd:target = 'following')">
          <xsl:variable name="parentdoc" select="./*[1]"/>
          <xsl:call-template name="pipedoc">
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
          <xsl:call-template name="pipedoc">
            <xsl:with-param name="doc">
              <p:documentation/>
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
    <xd:short>Recursive template that looks for p:documentation elements.</xd:short>
    <xd:detail>If there is a p:documentation belonging to the current element; document the current
      element using it. At the same time; recurse further through the script looking for more
      elements to be documented.</xd:detail>
    <xd:param name="code">Contains the element to be evaluted for documentation.</xd:param>
    <xd:param name="parentdoc">The p:documentation used to document the closest documented ancestor
      (used to make sure it isn't used twice).</xd:param>
  </xd:doc>
  <xsl:template name="subdoc">
    <xsl:param name="code" required="yes"/>
    <xsl:param name="parentdoc"/>

    <xsl:if test="not(name($code) = 'p:documentation')">
      <xsl:for-each select="$code/*">
        <xsl:choose>
          <!-- Don't document the documentation ;) -->
          <xsl:when test="name(.) = 'p:documentation'"/>

          <!-- When the current element contains a p:documentation child targeting it, use it -->
          <xsl:when
            test="./p:documentation[@xd:target='parent'][1] and not($parentdoc and generate-id(./p:documentation[@xd:target='parent'][1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="./p:documentation[@xd:target='parent'][1]"/>
            <xsl:call-template name="pipedoc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- When the first child of the current element is a p:documentation and is not targeting another element, use it -->
          <xsl:when
            test="name(./*[1]) = 'p:documentation' and not(./*[1]/@xd:target = 'following') and not(not($parentdoc instance of xs:string) and generate-id(./*[1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="./*[1]"/>
            <xsl:call-template name="pipedoc">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="code" select="."/>
            </xsl:call-template>
            <xsl:call-template name="subdoc">
              <xsl:with-param name="code" select="."/>
              <xsl:with-param name="parentdoc" select="$doc"/>
            </xsl:call-template>
          </xsl:when>

          <!-- When the first preceding sibling is a p:documentation and is not targeting another element, use it -->
          <xsl:when
            test="name(preceding-sibling::*[1]) = 'p:documentation' and not(preceding-sibling::*[1]/@xd:target = 'parent') and not(not($parentdoc instance of xs:string) and generate-id(preceding-sibling::*[1]) = generate-id($parentdoc))">
            <xsl:variable name="doc" select="preceding-sibling::*[1]"/>
            <xsl:call-template name="pipedoc">
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
    <xd:short>Documents an element using its corresponding p:documentation element.</xd:short>
    <xd:detail>This is where the main action happens. Relevant bits of information are retrieved and
      structured as DITA-XML.</xd:detail>
    <xd:param name="code">Contains the XProc code to be documentated.</xd:param>
    <xd:param name="doc">Contains the p:documentation used as documentation.</xd:param>
  </xd:doc>
  <xsl:template name="pipedoc">
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
          <xsl:apply-templates select="$doc/xd:short"/>
        </shortdesc>
        <xsl:apply-templates select="$doc/xd:detail"/>
      </abstract>

      <prolog>
        <xsl:for-each select="$doc/xd:author | $doc/xd:contributor | $doc/xd:maintainer">
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
            <xsl:apply-templates select="./xd:name"/>
            <xsl:if test="./xd:name and ./xd:mailto"> (</xsl:if>
            <xsl:apply-templates select="./xd:mailto"/>
            <xsl:if test="./xd:name and ./xd:mailto">)</xsl:if>
            <xsl:if test="(./xd:name or ./xd:mailto) and ./xd:organization">, </xsl:if>
            <xsl:apply-templates select="./xd:organization"/>
          </author>
        </xsl:for-each>
        <xsl:for-each select="$doc/xd:copyright">
          <copyright>
            <copyryear>
              <xsl:attribute name="year">
                <xsl:apply-templates select="./xd:year"/>
              </xsl:attribute>
            </copyryear>
            <copyrholder>
              <xsl:apply-templates select="./xd:holder"/>
            </copyrholder>
          </copyright>
        </xsl:for-each>
        <metadata>
          <audience type="programmer" job="programming" experiencelevel="expert"/>
          <othermeta name="programming-language" content="XProc"/>
          <xsl:for-each select="$doc/xd:version">
            <othermeta name="version">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>
          <xsl:for-each select="$doc/xd:since">
            <othermeta name="since">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>
          <!--xsl:for-each select="$doc/xd:see">
            <othermeta name="see">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each-->
          <xsl:for-each select="$doc/xd:deprecated">
            <othermeta name="deprecated">
              <xsl:attribute name="content">
                <xsl:value-of select="./text()"/>
              </xsl:attribute>
            </othermeta>
          </xsl:for-each>

          <!-- XProc version -->
          <xsl:if test="$code/@version or $code/@p:version">
            <othermeta name="xproc-version">
              <xsl:attribute name="content">
                <xsl:value-of select="$code/@version | $code/@p:version"/>
              </xsl:attribute>
            </othermeta>
          </xsl:if>

          <!-- XPath version -->
          <xsl:if test="$code/@xpath-version or $code/@p:xpath-version">
            <othermeta name="xpath-version">
              <xsl:attribute name="content">
                <xsl:value-of select="$code/@xpath-version | $code/@p:xpath-version"/>
              </xsl:attribute>
            </othermeta>
          </xsl:if>
        </metadata>
      </prolog>

      <refbody>
        <section>
          <apiname>
            <xsl:choose>
              <xsl:when test="$code/@name">
                <xsl:value-of select="$code/@name"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="name($code)"/>
              </xsl:otherwise>
            </xsl:choose>
          </apiname>
        </section>
        <xsl:if test="count($code/p:input)>0">
          <section outputclass="parameters xproc-inputs">
            <title outputclass="io-header">Inputs</title>
            <parml outputclass="xproc-inputs">
              <xsl:choose>
                <xsl:when test="$code/p:input">
                  <!--plentry>
                  <pt>Name</pt>
                  <pt>Primary</pt>
                  <pt>Sequence</pt>
                  <pt>Connection</pt>
                  <pd>Description</pd>
                </plentry-->
                  <xsl:for-each select="$code/p:input">
                    <plentry>
                      <pt>
                        <xsl:value-of select="@port"/>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when test="count($code/p:input) = 1 or @primary = 'true'"
                            >true</xsl:when>
                          <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when test="@sequence = 'true'">true</xsl:when>
                          <xsl:when test="@sequence = 'false'">false</xsl:when>
                          <xsl:otherwise/>
                        </xsl:choose>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when
                            test="not(count(p:empty | p:inline | p:data | p:document | p:pipe) = 1)"/>
                          <xsl:when test="p:empty">empty</xsl:when>
                          <xsl:when test="p:inline">inline</xsl:when>
                          <xsl:when test="p:data">
                            <xsl:value-of select="p:data/@href"/>
                          </xsl:when>
                          <xsl:when test="p:document">
                            <xsl:value-of select="p:document/@href"/>
                          </xsl:when>
                          <xsl:when test="p:pipe">
                            <xsl:value-of select="concat(p:pipe/@port,'@',p:pipe/@step)"/>
                          </xsl:when>
                        </xsl:choose>
                      </pt>
                      <pd>
                        <xsl:variable name="port" select="@port"/>
                        <xsl:apply-templates select="$doc/xd:input[@port=$port]"/>
                      </pd>
                    </plentry>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <plentry>
                    <pt/>
                    <pt/>
                    <pt/>
                    <pt>Implicit</pt>
                    <pd>
                      <xsl:value-of select="$doc/xd:input"/>
                    </pd>
                  </plentry>
                </xsl:otherwise>
              </xsl:choose>
            </parml>
          </section>
        </xsl:if>

        <xsl:if test="count($code/p:output)>0">
          <section outputclass="parameters xproc-outputs">
            <title outputclass="io-header">Outputs</title>
            <parml outputclass="xproc-outputs">
              <xsl:choose>
                <xsl:when test="$code/p:output">
                  <!--plentry>
                  <pt>Name</pt>
                  <pt>Primary</pt>
                  <pt>Sequence</pt>
                  <pt>Connection</pt>
                  <pd>Description</pd>
                </plentry-->
                  <xsl:for-each select="$code/p:output">
                    <plentry>
                      <pt>
                        <xsl:value-of select="@port"/>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when test="count($code/p:output) = 1 or @primary = 'true'"
                            >true</xsl:when>
                          <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when test="@sequence = 'true'">true</xsl:when>
                          <xsl:when test="@sequence = 'false'">false</xsl:when>
                          <xsl:otherwise/>
                        </xsl:choose>
                      </pt>
                      <pt>
                        <xsl:choose>
                          <xsl:when
                            test="not(count(p:empty | p:inline | p:data | p:document | p:pipe) = 1)"/>
                          <xsl:when test="p:empty">empty</xsl:when>
                          <xsl:when test="p:inline">inline</xsl:when>
                          <xsl:when test="p:data">
                            <xsl:value-of select="p:data/@href"/>
                          </xsl:when>
                          <xsl:when test="p:document">
                            <xsl:value-of select="p:document/@href"/>
                          </xsl:when>
                          <xsl:when test="p:pipe">
                            <xsl:value-of select="concat(p:pipe/@port,'@',p:pipe/@step)"/>
                          </xsl:when>
                        </xsl:choose>
                      </pt>
                      <pd>
                        <xsl:variable name="port" select="@port"/>
                        <xsl:apply-templates select="$doc/xd:output[@port=$port]"/>
                      </pd>
                    </plentry>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <plentry>
                    <pt/>
                    <pt/>
                    <pt/>
                    <pt>Implicit</pt>
                    <pd>
                      <xsl:value-of select="$doc/xd:output"/>
                    </pd>
                  </plentry>
                </xsl:otherwise>
              </xsl:choose>
            </parml>
          </section>
        </xsl:if>

        <xsl:if test="$code/p:option | $code/p:with-option">
          <section outputclass="parameters xproc-options">
            <title outputclass="io-header">Options</title>
            <parml outputclass="xproc-options">
              <xsl:choose>
                <xsl:when test="count($code/p:with-option) > 0">
                  <xsl:attribute name="outputclass" select="'xproc-options xproc-with-options'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="outputclass" select="'xproc-options'"/>
                </xsl:otherwise>
              </xsl:choose>
              <!--plentry>
                <pt>Name</pt>
                <pd>Required</pd>
                <xsl:if test="count($code/p:with-option) > 0">
                <pd>Connection</pd>
                </xsl:if>
                <pd>Description</pd>
                </plentry-->
              <xsl:for-each select="$code/p:option | $code/p:with-option">
                <plentry>
                  <pt>
                    <xsl:value-of select="@name"/>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when test="name(.) = 'p:with-option' and not(@required)"/>
                      <xsl:when test="@required = 'false'">false</xsl:when>
                      <xsl:when test="@required = 'true'">true</xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </pt>
                  <xsl:if test="name(.) = 'p:with-option'">
                    <pt>
                      <xsl:choose>
                        <xsl:when
                          test="not(count(p:empty | p:inline | p:data | p:document | p:pipe) = 1)"/>
                        <xsl:when test="p:empty">empty</xsl:when>
                        <xsl:when test="p:inline">inline</xsl:when>
                        <xsl:when test="p:data">
                          <xsl:value-of select="p:data/@href"/>
                        </xsl:when>
                        <xsl:when test="p:document">
                          <xsl:value-of select="p:document/@href"/>
                        </xsl:when>
                        <xsl:when test="p:pipe">
                          <xsl:value-of select="concat(p:pipe/@port,'@',p:pipe/@step)"/>
                        </xsl:when>
                      </xsl:choose>
                    </pt>
                  </xsl:if>
                  <pd>
                    <xsl:variable name="port" select="@port"/>
                    <xsl:apply-templates select="$doc/xd:option[@port=$port]"/>
                  </pd>
                </plentry>
              </xsl:for-each>
            </parml>
          </section>
        </xsl:if>

        <xsl:if test="$code/p:with-param">
          <section outputclass="parameters xproc-with-params">
            <title outputclass="io-header">Parameters</title>
            <parml outputclass="xproc-with-params">
              <xsl:attribute name="outputclass" select="'xproc-with-params'"/>
              <!--plentry>
                <pt>Name</pt>
                <pd>Required</pd>
                <xsl:if test="count($code/p:with-param) > 0">
                <pd>Connection</pd>
                </xsl:if>
                <pd>Description</pd>
                </plentry-->
              <xsl:for-each select="$code/p:with-param">
                <plentry>
                  <pt>
                    <xsl:value-of select="@port"/>
                  </pt>
                  <pt>
                    <xsl:choose>
                      <xsl:when
                        test="not(count(p:empty | p:inline | p:data | p:document | p:pipe) = 1)"/>
                      <xsl:when test="p:empty">empty</xsl:when>
                      <xsl:when test="p:inline">inline</xsl:when>
                      <xsl:when test="p:data">
                        <xsl:value-of select="p:data/@href"/>
                      </xsl:when>
                      <xsl:when test="p:document">
                        <xsl:value-of select="p:document/@href"/>
                      </xsl:when>
                      <xsl:when test="p:pipe">
                        <xsl:value-of select="concat(p:pipe/@port,'@',p:pipe/@step)"/>
                      </xsl:when>
                    </xsl:choose>
                  </pt>
                  <pd>
                    <xsl:variable name="name" select="@name"/>
                    <xsl:apply-templates select="$doc/xd:param[@name=$name]"/>
                  </pd>
                </plentry>
              </xsl:for-each>
            </parml>
          </section>
        </xsl:if>

      </refbody>

      <xsl:if
        test="count($code//p:import) > 0 or count($code//p:document) > 0 or count($doc/xd:see) > 0">
        <related-links>
          <xsl:if test="count($code//p:import) > 0">
            <linklist>
              <title>Dependencies (p:import)</title>
              <xsl:for-each select="$code//p:import">
                <link href="{@href}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These dependencies are derived from the p:import statements from the XProc
                script.</linkinfo>
            </linklist>
          </xsl:if>
          <xsl:if test="count($code//p:document) > 0">
            <linklist>
              <title>Dependencies (p:document)</title>
              <xsl:for-each select="$code//p:document">
                <link href="{@href}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These dependencies are derived from documents loaded with the p:document
                step in the XProc script.</linkinfo>
            </linklist>
          </xsl:if>
          <xsl:if test="count($doc/xd:see) > 0">
            <linklist>
              <title>See also</title>
              <xsl:for-each select="$doc/xd:see">
                <link href="{./text()}" format="ditamap"/>
              </xsl:for-each>
              <linkinfo>These are related readings suggested by the author of the XProc
                script.</linkinfo>
            </linklist>
          </xsl:if>
        </related-links>
      </xsl:if>

      <section outputclass="sourcecode">
        <title outputclass="sourcecode-header">Source Code</title>
        <codeblock>
          <xsl:for-each select="$code">
            <xsl:call-template name="xml-to-string"/>
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
