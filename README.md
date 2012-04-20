dae2x3d
=======

An XSL-T script to convert COLLADA files to X3D.

This script is in a pre-alpha state, but it should be a good starting point for further refinement.

System Requirements 
-------------------
An exslt capable xslt processor, e.g. xsltproc.

usage
-----
xsltproc -o example.x3d DaeToX3d.xsl example.dae

You can then use Don Brutzman's X3dToX3dom stylesheet from http://www.web3d.org/x3d/stylesheets/ to display the model in a browser (change the xslt's version attribute from 2.0 to 1.0, it should still work).
