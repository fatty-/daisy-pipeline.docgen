#!/bin/bash
#out=`echo $file | sed 's/source.xsl$/test.xml/'`
out='test.xml'
echo '<?xml version="1.0" encoding="UTF-8"?>' > $out
echo '<!DOCTYPE utfx:tests PUBLIC "-//UTF-X//DTD utfx-tests 1.0//EN" "utfx_tests.dtd">' >> $out
echo '<utfx:tests xmlns:utfx="http://utfx.org/test-definition"' >>  $out
echo '  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' >> $out
echo '  <utfx:stylesheet src="../../documenter-0.2/source2dita/xslt/xsdoc.xsl"/>' >> $out
for file in `find | grep source.xsl`
do
	expected=`echo $file | sed 's/source.xsl$/expected.dita/'`
	name=`echo $file | sed 's/\/source.xsl//' | sed 's/^.\///'`
	echo $name;
	echo '  <utfx:test>' >> $out
	echo "    <utfx:name>$name</utfx:name>" >> $out
	echo '    <utfx:assert-equal>' >> $out
	echo '      <utfx:source>' >> $out
	cat $file >> $out
	echo '      </utfx:source>' >> $out
	echo '      <utfx:expected>' >> $out
	cat $expected >> $out
	echo '      </utfx:expected>' >> $out
	echo '    </utfx:assert-equal>' >> $out
	echo '  </utfx:test>' >> $out
done
echo '</utfx:tests>' >> $out
