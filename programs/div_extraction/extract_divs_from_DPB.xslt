<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">

  <!--
      *********************************************
      extract_divs_from_DPB.xslt:
      
      Read in a TEI document (intended for the Dragon Prayer Book, but
      should work on any similarly-structured TEI document), and write
      out a separate file for each highest-level <div> thereof that
      contains a copy of the root-level PIs and said <div>.
      
      By “highest-level” <div> I mean a <div> that is a child of a
      <front>, <body>, or <back> that is itself a grandchild of the
      outermost <TEI>. So a <div> that is nested within another <div>,
      or is inside a <group>, or a nested <TEI> or a <teiCorpus>, or
      in a <floatingText> itself a child of <body> (<floatingText> is
      not allowed as a direct child of <front> or <back> — I wonder
      why not?) will not be copied into a file of its own.
      
      Output files are written to /tmp/. If you do not have a read-
      write /tmp/ directory available, this routine will fail. Either
      create such a directory or change the path on the @href.
      
      Written 2022-02-01 by Syd Bauman.
      Copyleft 2022 by Syd Bauman and the Northeastern University
      Digital Scholarship Group.
      *********************************************
  -->

  <xsl:template match="/">
    <xsl:apply-templates select="/TEI/text/*/div"/>
  </xsl:template>

  <xsl:template match="div">
    <xsl:result-document indent="yes" href="./generated_files/{@xml:id}.xml">
      <xsl:apply-templates select="/processing-instruction()"/>
      <!--
        Note: The above instruction puts ALL root-level PIs in front
        of the root element, even if they occurred after the root
        element in the input source document. Since we never use a PI
        after the outermost element at the WWP, and since it is very
        rare in general, this probably won’t be a problem. For an
        example of how to do this with PIs in the “right” places see
        extract_div_elements_generic.xslt.
      -->
      <xsl:copy-of select="."/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="/processing-instruction()">
    <xsl:copy/>
    <!--
      We could be clever about inserting pretty newline (U+0A)
      characters between the output PIs (just to make output more
      readable), here. But the processor I am using (Saxon 10) will do
      that on its own when indent="yes".

      (Updated 2022-02-02: Just switched to Saxon 11, but it does the
      same thing.)
    -->
  </xsl:template>

</xsl:stylesheet>
