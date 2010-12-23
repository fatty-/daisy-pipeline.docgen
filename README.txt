###############################################################################
###             DAISY Pipeline 2 - Documentation Generator                  ###
###############################################################################



About the DocGen tool
-------------------------------------------------------------------------------

DocGen is a tool used to generate developer-friendly documentation out of
inline documentation markup in the Pipeline 2 source files.

DocGen uses DITA as an intermediary format for the documentation. The generated
DITA content can then be converted to HTML, and other output formats (e.g. PDF,
Micsoft CHM, Eclipse Help, etc) can be added in the future.

For more information on the ongoing development, see the framework
documentation wiki page:
   http://code.google.com/p/daisy-pipeline/wiki/Framework_Documentation



Demo
-------------------------------------------------------------------------------

Generate the documentation of the docgen module itself:

On Linux/Mac:

$ docgen.sh -o docgen-doc documenter-0.2

On Windows:

> docgen.bat -o docgen-doc documenter-0.2



Known limitations
-------------------------------------------------------------------------------

Only supports documenting XSLT and XProc at the moment.