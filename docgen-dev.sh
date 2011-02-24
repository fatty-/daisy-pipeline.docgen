#!/bin/bash

MODULE_DIR=`dirname "$0"`
#COMMON_DIR=$MODULE_DIR/../common
#LIB_DIR=$COMMON_DIR/lib
#CONF_DIR=$COMMON_DIR/conf

usageExit ()
{
	if [ "$2" ]; then echo $2; fi
	echo "Usage: `basename "$0"` [options] DIR"
	echo "    Generates the documentation of the DIR module."
	echo ""
	echo "Options:"
	echo "    -o DIR  : the directory where to generate the documentation"
	echo "              default is 'output' "
	echo "    -h      : print this help"
	echo "    -v      : verbose"
	echo ""
	echo "Example:"
	echo "    `basename "$0"` documenter-0.3"
	echo "    `basename "$0"` -o documentation documenter-0.3"
	exit ${1:-1}
}

#calabash()
#{
#	# Build the classpath
#	for lib in `ls -1 "$LIB_DIR"`; do
#		CP=$CP:$LIB_DIR/$lib
#	done
#	if [ $VERBOSE ]; then
#		LOGGING=-Djava.util.logging.config.file=$CONF_DIR/logging-info.properties
#	else
#		LOGGING=-Djava.util.logging.config.file=$CONF_DIR/logging-severe.properties
#	fi
#	java  "$LOGGING" -classpath "$CP" -Dcom.xmlcalabash.phonehome=false com.xmlcalabash.drivers.Main -c ${CONF_DIR// /%20}/calabash-config.xml $@
#}

# Parse the Options
while getopts "o:hv" OPTION
do
  case $OPTION in
	o) OUT_DIR="$OPTARG";;
	h) usageExit 0 "";;
	v) VERBOSE="true";;
  esac
done
shift $(($OPTIND - 1))

#Check the input file has been set
SRC_DIR=$1
if [ -z "$SRC_DIR" ]
then	
	usageExit 1 "The input directory must be set\n"
fi

if [ -z "$OUT_DIR" ]
then
	OUT_DIR="output"
fi


$HOME/xmlcalabash-0.9.30/calabash ${MODULE_DIR// /%20}/documenter-0.3/document.xpl src=${SRC_DIR// /%20} doc=${OUT_DIR// /%20}
