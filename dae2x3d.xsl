<?xml version="1.0" encoding="UTF-8"?>
	<!-- QTImeets3D stylesheet to transform COLLADA to X3D -->
<xsl:stylesheet 
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl str"
	xmlns:str="http://exslt.org/strings"
	xmlns:dae="http://www.collada.org/2005/11/COLLADASchema"
	xmlns:x3d="http://www.web3d.org/specifications/x3d-namespace">

	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:COLLADA">
		<x3d:X3D profile="Full" version="3.0">
			<xsl:apply-templates select="./dae:asset"/>
			<xsl:apply-templates select="./dae:scene"/>
		</x3d:X3D>
	</xsl:template>

<!-- META DATA -->
	<xsl:template match="dae:asset">
		<x3d:Head>
			<xsl:apply-templates />
		</x3d:Head>
	</xsl:template>

	<xsl:template match="dae:contributor">
		<x3d:Meta name="creator"><xsl:value-of select=".//dae:author"/></x3d:Meta>
		<x3d:Meta name="tool"><xsl:value-of select=".//dae:authoring_tool"/></x3d:Meta>
	</xsl:template>

	<xsl:template match="dae:asset//*" priority="-9">
		<x3d:Meta name="{name()}"><xsl:value-of select="."/></x3d:Meta>
	</xsl:template>

<!-- SCENE -->
	
	<xsl:template match="dae:scene">
		<x3d:Scene>
			<xsl:apply-templates />
		</x3d:Scene>
	</xsl:template>

	<xsl:template match="dae:instance_visual_scene">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:visual_scene[@id=$url]"/>
	</xsl:template>

	<xsl:template match="dae:visual_scene">
		<xsl:apply-templates/>
	</xsl:template>

<!-- NODES -->
	<xsl:template match="dae:node">
		<xsl:apply-templates select="*[1]"/>

	</xsl:template>

	<xsl:template match="dae:translate">
		<xsl:element name="x3d:Transform">
			<xsl:attribute name="translation">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:scale">
		<xsl:element name="x3d:Transform">
			<xsl:attribute name="scale">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:rotate">
		<xsl:element name="x3d:Transform">
			<xsl:attribute name="rotation">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:instance_geometry">
		<x3d:Shape>
			<xsl:apply-templates select="//dae:instance_material"/>
			<xsl:variable name="url" select="substring-after(@url, '#')"/>
			<xsl:apply-templates select="//dae:geometry[@id=$url]"/>
		</x3d:Shape>
	</xsl:template>

	<xsl:template match="dae:instance_material">
		<x3d:Appearance>
			<xsl:variable name="target" select="substring-after(@target, '#')"/>
			<xsl:apply-templates select="//dae:material[@id=$target]"/>
		</x3d:Appearance>
	</xsl:template>

<!-- GEOMETRY -->
	<xsl:template match="dae:geometry">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="dae:mesh">
		<xsl:apply-templates select="dae:polylist"/>
	</xsl:template>

	<xsl:template match="dae:vertices">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:polylist">
		<xsl:element name="x3d:IndexedFaceSet">
			<xsl:attribute name="solid">true</xsl:attribute>
			<xsl:apply-templates select="dae:input"/>
		</xsl:element>
		<xsl:for-each select="dae:input[@semantic='VERTEX']">
			<xsl:variable name="source" select="substring-after(@source, '#')"/>
			
				<xsl:apply-templates select="../../dae:vertices[@id=$source]"/>

		</xsl:for-each>
		<xsl:for-each select="dae:input[@semantic='NORMAL']">
			<xsl:variable name="source" select="substring-after(@source, '#')"/>
			<xsl:element name="x3d:Normal">
				<xsl:attribute name="vector">
					<xsl:apply-templates select="../../dae:source[@id=$source]"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='VERTEX']">
		<xsl:attribute name="coordIndex">
			<xsl:call-template name="skipList">
                <xsl:with-param name="s" select="../dae:p" />
                <xsl:with-param name="stride" select="count(../dae:input)" />
                <xsl:with-param name="offset" select="@offset" />
            </xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='NORMAL']">
		<xsl:attribute name="normalIndex">
				<xsl:call-template name="skipList">
	                <xsl:with-param name="s" select="../dae:p" />
	                <xsl:with-param name="stride" select="count(../dae:input)" />
	                <xsl:with-param name="offset" select="@offset" />
	            </xsl:call-template>
			</xsl:attribute>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='POSITION']">
		<xsl:variable name="source" select="substring-after(@source, '#')"/>
		<xsl:element name="x3d:Coordinate">
		<xsl:attribute name="point">
			<xsl:apply-templates select="../../dae:source[@id=$source]"/>
		</xsl:attribute>
			</xsl:element>
	</xsl:template>

	<xsl:template match="dae:source">
		<xsl:value-of select=".//dae:float_array" />
	</xsl:template>

<!-- MATERIAL -->
	<xsl:template match="dae:material">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:instance_effect">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:effect[@id=$url]"/>
	</xsl:template>

<!-- EFFECT -->
	<xsl:template match="dae:effect">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:phong">
		<xsl:element name="x3d:Material">
			<xsl:attribute name="emissiveColor">
				<xsl:call-template name="clip">
					<xsl:with-param name="string" select=".//dae:emission/dae:color"/>
					<xsl:with-param name="count" select="3"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="diffuseColor">
				<xsl:call-template name="clip">
					<xsl:with-param name="string" select=".//dae:diffuse/dae:color"/>
					<xsl:with-param name="count" select="3"/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<xsl:attribute name="ambientIntensity">
				<xsl:value-of select=".//dae:ambient/dae:color"/>
			</xsl:attribute>-->
			<xsl:attribute name="specularColor">
				<xsl:call-template name="clip">
					<xsl:with-param name="string" select=".//dae:specular/dae:color"/>
					<xsl:with-param name="count" select="3"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="shininess">
				<xsl:value-of select=".//dae:shininess/dae:float"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<xsl:template match="dae:extra"></xsl:template>

	<!-- helper templates -->

	<xsl:template name="tokenize">
		<xsl:param name="string" />
		<xsl:if test="string-length($string)>1">
			<xsl:value-of select="substring-before($string, ' ')"/>
			<xsl:call-template name="tokenize">
            	<xsl:with-param name="string" select="substring-after($string, ' ')" />
    		</xsl:call-template>
    	</xsl:if>
	</xsl:template>

	<xsl:template name="clip">
		<xsl:param name="string" />
		<xsl:param name="count" />
		 <xsl:call-template name="join">
	    	<xsl:with-param name="nodes" select="str:tokenize(string($string))[(position()-1) &lt; $count]"/>
		</xsl:call-template>  
	</xsl:template>

	<xsl:template name="join">
		<xsl:param name="nodes" />
		<xsl:for-each select="$nodes">
			<xsl:choose>
	        <xsl:when test="position() = 1">
	            <xsl:value-of select="string(.)"/>
	        </xsl:when>
	        <xsl:otherwise>
	            <xsl:value-of select="concat(' ', string(.))"/>
	        </xsl:otherwise>
	    </xsl:choose>
		</xsl:for-each>   
	</xsl:template>

	<xsl:template name="skipList">
	    <xsl:param name="s" />
	    <xsl:param name="stride" />
	    <xsl:param name="offset" />
	    <xsl:call-template name="join">
	    	<xsl:with-param name="nodes" select="str:tokenize(string($s))[((position()-1) mod $stride) = $offset]"/>
		</xsl:call-template>  
	</xsl:template>


</xsl:stylesheet>
