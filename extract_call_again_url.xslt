<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="text()"/>

  <xsl:template match="HOST_LIST_VM_DETECTION_OUTPUT/RESPONSE/WARNING">

    <xsl:value-of select="URL"/>
  </xsl:template>

</xsl:stylesheet>
