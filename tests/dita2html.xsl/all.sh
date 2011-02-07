#!/bin/bash
for testpath in `ls -d */`
do
	IN="$testpath""source"
	OUT="$testpath""result/result.html"
	mkdir "$testpath""result"
	java -jar ../saxon9he.jar $IN/source.xsl.ditamap ../../documenter-0.2/dita2output/html/dita2html.xsl pathToRoot=".." > $OUT
done

#TEMP_IN=temp-in
#TEMP_OUT=temp-out
#for testpath in `ls -d ../xsdoc.xsl/*`
#do
#	IN=`echo $testpath/source.dita | sed 's/.dita$/.xsl/'`
#	TESTNAME=`echo $testpath | sed 's/^.*\/\([^\/]*\)$/\1/'`
#	mv $TESTNAME/expected/source.xsl.html $TESTNAME/expected/expected.html
#	cp $IN $TEMP_IN
#	../../docgen-dev.sh -o $TEMP_OUT $TEMP_IN
#	mkdir $TESTNAME
#	mv $TEMP_OUT/dita/doc $TESTNAME/source
#	mv $TEMP_OUT/html/doc $TESTNAME/expected
#done
