<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="3.0">

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:output method="xml" indent="no"/>
  
  <xsl:template match="/processing-instruction()">
    <xsl:copy/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>
  
  <!--
    Fix the attrs on every <ab> based on its @type.
    (I checked: *all* 577 that are 1st child of parent <div> are type=transcription;
    and *all* 577 that re 2nd child of parent <div> are type=translation.)
  -->
  <xsl:template match="ab">
    <xsl:variable name="type" select="if ( @type eq 'transcription') then 'translation' else 'transcription'"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:id" select="../@xml:id||'_'||@type"/>
      <xsl:attribute name="corresp" select="'#'||../@xml:id||'_'||$type"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
