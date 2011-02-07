#!/bin/bash
for file in `find | grep source.xsl`
do
	OUT=`echo $file | sed 's/source.xsl$/result.dita/'`
	echo "$file --> $OUT"
	java -jar ../saxon9he.jar $file ../../documenter-0.2/source2dita/xslt/xsdoc.xsl > $OUT
done
