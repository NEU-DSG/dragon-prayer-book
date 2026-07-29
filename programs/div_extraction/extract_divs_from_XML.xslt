<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  version="3.0">

  <!--
      *********************************************
      extract_divs_from_XML.xslt:
      
      Read in an XML document, and write out a separate file for each
      highest-level <div> thereof that contains copies of the
      root-level PIs & comments and said <div>.
      
      By “highest-level” <div> I mean a <div> that has no ancestor
      <div> from the same namespace.
      
      Output files are written to /tmp/. If you do not have a read-
      write /tmp/ directory available, this routine will fail. Either
      create such a directory or change the path on the @href.

      Written 2022-02-01/02 by Syd Bauman.
      Copyleft 2022 by Syd Bauman and the Northeastern University
      Digital Scholarship Group.
      *********************************************
  -->

  <!--
      Get the component pieces of the input filename for later use in
      the output filename
  -->
  <xsl:variable name="inputFileName" select="fn:tokenize( fn:base-uri(/),'/')[last()]"/>
  <xsl:variable name="name_sans_extension"
                select="fn:replace( $inputFileName, '\.[^.]+$', '')"/>
  <xsl:variable name="name_extension_only"
                select="fn:replace( $inputFileName, '^.*\.([^.]+)$', '$1')"/>
  
  <!--
      HIGHEST_DIVs = The set of all <div> elements that do *not* have an
      ancestor <div> in the same namespace.
  -->
  <xsl:key name="HIGHEST_DIVs"
           use="true()"
           match="//*
                     [ local-name(.) eq 'div']
                     [ not(
                            ancestor::*
                             [ 
                               namespace-uri( . ) eq namespace-uri( current() )
                               and
                               local-name( . ) eq 'div'
                             ]
                          ) ]" />
  <!-- Calculate number of digits needed to display the number of highest <div>s … -->
  <xsl:variable name="numDivs" select="count( key('HIGHEST_DIVs',true()) )"/>
  <xsl:variable name="numDigs" select="fn:floor( math:log10( $numDivs ) ) +1"/>
  <!-- … and create the proper argument to format-number() to use that # of digits -->
  <xsl:variable name="picture" select="fn:substring('99999999999999', 1, $numDigs )"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="key('HIGHEST_DIVs', true() )"/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="thisDiv" select="."/>
    <xsl:variable name="mySeq" select="count( key('HIGHEST_DIVs', true() )[ $thisDiv >> . ] ) + 1"/>
    <xsl:variable name="myFormattedSeq" select="format-number( $mySeq, $picture )"/>
    <xsl:result-document indent="yes" href="/tmp/{$name_sans_extension}_div_{$myFormattedSeq}.{$name_extension_only}">
      <xsl:apply-templates select="/processing-instruction()[following-sibling::*]
                                  |/comment()[following-sibling::*] "/>
      <xsl:copy-of select="$thisDiv"/>
      <xsl:apply-templates select="/processing-instruction()[preceding-sibling::*]
                                  |/comment()[preceding-sibling::*] "/>
      <!-- Add a colophon: -->
      <xsl:comment select="' '
        ||'&lt;div> #'||$mySeq
        ||' extracted from '||fn:base-uri(/)
        ||' at '||fn:current-dateTime()
        ||' by '||fn:static-base-uri()
        ||' '"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="/processing-instruction()|/comment()">
    <xsl:copy/>
    <!--
      No rule of XML nor any moral imperative requires that we put a
      newline (U+0A) in between the PIs and comments. But there is an
      aesthetic imperative: the output sure looks a lot better this
      way! (Note: Saxon 10 or Saxon 11 will do this for you iff
      indent=yes|true|1.)
    -->
    <xsl:sequence select="'&#x0A;'"/>
  </xsl:template>

</xsl:stylesheet>
