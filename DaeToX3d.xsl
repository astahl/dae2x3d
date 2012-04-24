<?xml version="1.0" encoding="UTF-8"?>
	<!-- QTImeets3D stylesheet to transform COLLADA to X3D -->
<xsl:stylesheet 
	version="1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl str"
	xmlns:str="http://exslt.org/strings"
	xmlns:dae="http://www.collada.org/2005/11/COLLADASchema"
	xmlns="http://www.web3d.org/specifications/x3d-namespace">
	<xsl:strip-space  elements="*"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:template match="/"> 
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:COLLADA">
		<X3D profile="Full" version="3.0">
			<xsl:apply-templates select="./dae:asset"/>
			<xsl:apply-templates select="./dae:scene"/>
		</X3D>
	</xsl:template>

<!-- META DATA -->
	<xsl:template match="dae:asset">
		<Head>
			<xsl:apply-templates />
		</Head>
	</xsl:template>

	<xsl:template match="dae:contributor">
		<Meta name="creator"><xsl:value-of select=".//dae:author"/></Meta>
		<Meta name="tool"><xsl:value-of select=".//dae:authoring_tool"/></Meta>
	</xsl:template>

	<xsl:template match="dae:asset//*" priority="-9">
		<Meta name="{name()}"><xsl:value-of select="."/></Meta>
	</xsl:template>

<!-- SCENE -->
	
	<xsl:template match="dae:scene">
		<Scene>
			<xsl:apply-templates />
		</Scene>
	</xsl:template>

	<xsl:template match="dae:instance_visual_scene">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:visual_scene[@id=$url]"/>
	</xsl:template>

	<xsl:template match="dae:visual_scene">
		<xsl:apply-templates />
	</xsl:template>

<!-- NODES -->
	<xsl:template match="dae:node">
		<xsl:element name="Group">
			<xsl:if test="@id">
				<xsl:attribute name="DEF">
					<xsl:value-of select="@id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="child::*[1]"/>
		</xsl:element>
			<!--<xsl:apply-templates select="following-sibling::*[1]"/>-->
	</xsl:template>

	<xsl:template match="dae:instance_node">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:node[@id=$url]"/>
	</xsl:template>

	<xsl:template match="dae:translate">
		<xsl:element name="Transform">
			<xsl:attribute name="translation">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:scale">
		<xsl:element name="Transform">
			<xsl:attribute name="scale">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:rotate">
		<xsl:element name="Transform">
			<xsl:attribute name="rotation">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:matrix">
		<xsl:element name="Transform">
			<xsl:attribute name="translation">
				<xsl:call-template name="Select">
					<xsl:with-param name="list" select="str:tokenize(.)"/>
					<xsl:with-param name="indices" select="str:tokenize('3 7 11')"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:element>
	</xsl:template>

<!-- GEOMETRY -->
	<xsl:template match="dae:geometry">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:instance_geometry">
		<Shape>
			<xsl:apply-templates select=".//dae:instance_material"/>
			<xsl:variable name="url" select="substring-after(@url, '#')"/>
			<xsl:apply-templates select="//dae:geometry[@id=$url]"/>
		</Shape>
	</xsl:template>

	<xsl:template match="dae:mesh">
			<xsl:apply-templates select="dae:polylist|dae:polygons|dae:triangles"/>
	</xsl:template>

	<xsl:template match="dae:polygons">
		<xsl:element name="IndexedFaceSet">
			<xsl:attribute name="solid">true</xsl:attribute>
			<xsl:apply-templates select="dae:input" mode="attributes"/>
			<xsl:apply-templates select="dae:input" mode="elements"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:triangles">
		<xsl:element name="IndexedFaceSet">
			<xsl:attribute name="solid">true</xsl:attribute>
			<xsl:apply-templates select="dae:input" mode="attributes"/>
			<xsl:apply-templates select="dae:input" mode="elements"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:polylist">
		<xsl:element name="IndexedFaceSet">
			<xsl:attribute name="solid">true</xsl:attribute>
			<xsl:apply-templates select="dae:input" mode="attributes"/>
			<xsl:apply-templates select="dae:input" mode="elements"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='VERTEX']" mode="attributes">
		<xsl:attribute name="coordIndex">
			<xsl:call-template select="../dae:p" name="SliceIndices">
				<xsl:with-param name="stride" select="count(../dae:input)" />
                <xsl:with-param name="offset" select="@offset" />
            </xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="dae:vertices">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:input[@semantic='VERTEX']" mode="elements">
		<xsl:variable name="source" select="substring-after(@source, '#')"/>
		<xsl:element name="Coordinate">
			<xsl:attribute name="point">
				<xsl:apply-templates select="../../dae:vertices[@id=$source]"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='NORMAL']" mode="attributes">
		<xsl:attribute name="normalIndex">
			<xsl:call-template select="../dae:p" name="SliceIndices">
				<xsl:with-param name="stride" select="count(../dae:input)" />
                <xsl:with-param name="offset" select="@offset" />
            </xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='NORMAL']" mode="elements">
		<xsl:variable name="source" select="substring-after(@source, '#')"/>
		<xsl:element name="Normal">
			<xsl:attribute name="vector">
				<xsl:apply-templates select="../../dae:source[@id=$source]"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:p" name="SliceIndices">
		<xsl:param name="stride" select="0"/>
		<xsl:param name="offset" select="0"/>
		<xsl:variable name="slist">
			<xsl:call-template name="SkipList">
                <xsl:with-param name="list" select="str:tokenize(..)" />
                <xsl:with-param name="stride" select="$stride" />
                <xsl:with-param name="offset" select="$offset" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vcount">
        	<xsl:choose>
        		<xsl:when test="name(..)='triangles'">3</xsl:when>
        		<xsl:when test="name(..)='polygons'"><xsl:value-of select="count(exsl:node-set($slist)/*)"/></xsl:when>
        	</xsl:choose>
        </xsl:variable>
        <xsl:variable name="dlist">
			<xsl:call-template name="DelimitList">
                <xsl:with-param name="list" select="exsl:node-set($slist)/*" />
                <xsl:with-param name="stride" select="$vcount" />
            </xsl:call-template>
        </xsl:variable>
		<xsl:call-template name="Join">
            <xsl:with-param name="list" select="exsl:node-set($dlist)/*" />
        </xsl:call-template>
	</xsl:template>

	<xsl:template match="dae:input">
		<xsl:variable name="source" select="substring-after(@source, '#')"/>
		<xsl:apply-templates select="../../dae:source[@id=$source]"/>
	</xsl:template>

	<xsl:template match="dae:source">
		<xsl:apply-templates select="dae:float_array"/>
	</xsl:template>

	<xsl:template match="dae:float_array">
		<xsl:value-of select="normalize-space(.)" disable-output-escaping="yes"/>
	</xsl:template>

<!-- MATERIAL -->
	<xsl:template match="dae:material">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="dae:instance_material">
		<Appearance>
			<xsl:variable name="target" select="substring-after(@target, '#')"/>
			<xsl:apply-templates select="//dae:material[@id=$target]"/>
		</Appearance>
	</xsl:template>

<!-- EFFECT -->
	<xsl:template match="dae:effect">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="dae:instance_effect">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:effect[@id=$url]"/>
	</xsl:template>

	<xsl:template match="dae:phong">
		<xsl:element name="Material">
			<xsl:attribute name="emissiveColor">
				<xsl:apply-templates select=".//dae:emission/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="diffuseColor">
				<xsl:apply-templates select=".//dae:diffuse/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="ambientIntensity">
				<xsl:apply-templates select=".//dae:ambient/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="specularColor">
				<xsl:apply-templates select=".//dae:specular/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="shininess">
				<xsl:value-of select=".//dae:shininess/dae:float"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:lambert">
		<xsl:element name="Material">
			<xsl:attribute name="emissiveColor">
				<xsl:apply-templates select=".//dae:emission/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="diffuseColor">
				<xsl:apply-templates select=".//dae:diffuse/dae:color"/>
			</xsl:attribute>
			<xsl:attribute name="ambientIntensity">
				<xsl:apply-templates select=".//dae:ambient/dae:color"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:extra"></xsl:template>

	<xsl:template match="dae:color">
		<xsl:variable name="list">
			<xsl:call-template name="Take">
				<xsl:with-param name="list" select="str:tokenize(..)"/>
				<xsl:with-param name="count" select="3"/>
			</xsl:call-template>
        </xsl:variable>
		<xsl:call-template name="Join">
            <xsl:with-param name="list" select="exsl:node-set($list)/*" />
        </xsl:call-template>
	</xsl:template>

	<!-- helper templates -->
<!-- takes the first $count elements from the space-separated vector $string -->
	<xsl:template name="Take">
		<xsl:param name="list" />
		<xsl:param name="count" />
	    <xsl:copy-of select="$list[position()-1 &lt; $count]"/>
	</xsl:template>

	<xsl:template name="Skip">
		<xsl:param name="list" />
		<xsl:param name="count" />
	    <xsl:copy-of select="$list[position() &gt; $count]"/>
	</xsl:template>

	<xsl:template name="Join">
		<xsl:param name="list" />
		<xsl:param name="separator" select="' '"/>
		<xsl:value-of select="$list[position() = 1]"/>
		<xsl:for-each select="$list[position() &gt; 1]">
			<xsl:value-of select="$separator"/>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Append">
		<xsl:param name="list"/>
		<xsl:param name="element"/>
		<xsl:for-each select="$list">
			<xsl:copy-of select="."/>
		</xsl:for-each>
		<xsl:copy-of select="str:tokenize($element)"/>
	</xsl:template>

	<xsl:template name="Concatenate">
		<xsl:param name="firstlist"/>
		<xsl:param name="secondlist"/>
		<xsl:for-each select="$firstlist">
			<xsl:copy-of select="."/>
		</xsl:for-each>
		<xsl:for-each select="$secondlist">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Select">
	    <xsl:param name="list" />
	    <xsl:param name="indices" select="0"/>
	    <xsl:for-each select="str:tokenize($indices)">
	    	<xsl:variable name="index" select="."/>
	    	<xsl:copy-of select="$list[position()-1 = $index]"/>
	    </xsl:for-each>
	</xsl:template>

	<xsl:template name="SkipList">
	    <xsl:param name="list" />
	    <xsl:param name="stride" select="0"/>
	    <xsl:param name="offset" select="0"/>
	    <xsl:copy-of select="$list[((position()-1) mod $stride) = $offset]"/>
	</xsl:template>

	<xsl:template name="DelimitList">
	    <xsl:param name="list" />
	    <xsl:param name="stride" select="count($list)"/>
	    <xsl:for-each select="$list">
	    	<xsl:copy-of select="."/>
	    	<xsl:choose>
	    		<xsl:when test="position() mod $stride = 0">
	    			<xsl:copy-of select="str:tokenize('-1')"/>
	    		</xsl:when>
	    	</xsl:choose>
	    </xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
