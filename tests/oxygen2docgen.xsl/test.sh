#!/bin/bash
SCRIPTPATH=`dirname $0 | xargs readlink -f`
$HOME/utf-x-framework-svn-trunk/utfx.sh -Dutfx.test.file=$SCRIPTPATH/test/oxygen2docgen_test.xml
