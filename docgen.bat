@echo off
rem This is the path to Java. Edit this variable to suite your needs.
set JAVA=java

SETLOCAL ENABLEDELAYEDEXPANSION  

set CMD=%~n0
set MODULE_DIR=%~dp0
set COMMON_DIR=%MODULE_DIR%..\common
set LIB_DIR=%COMMON_DIR%\lib
set CONF_DIR=%COMMON_DIR%\conf
set OUT_DIR=

:Loop
IF "%~1"=="-h" (
	GOTO Usage
)
IF "%~1"=="-o" (
	SHIFT
	GOTO param-o
)
GOTO Continue

:param-o
set OUT_DIR=%1
SHIFT
GOTO Loop

:Usage
ECHO Usage: %CMD% [options] FILE
ECHO     Generates the documentation of the DIR module.
ECHO.
ECHO Options:
ECHO     -o FILE : the directory where to generate the documentation
ECHO               default is 'output'
ECHO     -h      : print this help
ECHO     -v      : verbose
ECHO.
ECHO Example:
ECHO     %CMD% documenter-0.2
ECHO     %CMD% -o documentation documenter-0.2
GOTO:EOF

:Continue

set SRC_DIR=%1
IF "%SRC_DIR%"=="" (
	ECHO The source directory must be set
	ECHO.
	GOTO Usage
)

set URI_SPACE=%%20

set CONF_CALABASH="file:///%CONF_DIR:\=/%/calabash-config.xml"
set CONF_CALABASH=%CONF_CALABASH: =!URI_SPACE!%

set SRC_DIR="%SRC_DIR:\=/%"
set SRC_DIR=%SRC_DIR: =!URI_SPACE!%

IF "%OUT_DIR%"=="" (
	set OUT_FILE=output
) ELSE (
	set OUT_DIR="%OUT_DIR:\=/%"
	set OUT_DIR=%OUT_DIR: =!URI_SPACE!%
)

set CP=
for %%f IN ("%LIB_DIR%\*.jar") do set CP=!CP!;"%%f"

%JAVA% -classpath %CP%  -Dcom.xmlcalabash.phonehome=false com.xmlcalabash.drivers.Main -c %CONF_CALABASH% "%MODULE_DIR%\documenter-0.2\document.xpl" src=%SRC_DIR% doc=%OUT_DIR%