#!/bin/bash
cp /home/jostein/daisy-pipeline-docgen/documenter-0.2/source2dita/xslt/xsdoc.xsl .
sed -i 's/..\/..\/lib\/xml-to-string.xsl/xml-to-string.xsl/g' xsdoc.xsl
SCRIPTPATH=`dirname $0 | xargs readlink -f`
$HOME/utf-x-framework-svn-trunk/utfx.sh -Dutfx.test.file=$SCRIPTPATH/test/xsdoc_test.xml
