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
	<xsl:strip-space  elements="*"/>
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
		<xsl:apply-templates />
	</xsl:template>

<!-- NODES -->
	<xsl:template match="dae:node">
		<xsl:element name="x3d:Group">
			<xsl:if test="@id">
				<xsl:attribute name="DEF">
					<xsl:value-of select="@id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="child::*[1]"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:instance_node">
		<xsl:variable name="url" select="substring-after(@url, '#')"/>
		<xsl:apply-templates select="//dae:node[@id=$url]"/>
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

	<xsl:template match="dae:matrix">
		<xsl:element name="x3d:Transform">
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
		<x3d:Shape>
			<xsl:apply-templates select=".//dae:instance_material"/>
			<xsl:variable name="url" select="substring-after(@url, '#')"/>
			<xsl:apply-templates select="//dae:geometry[@id=$url]"/>
		</x3d:Shape>
	</xsl:template>

	<xsl:template match="dae:mesh">
		<xsl:element name="x3d:IndexedFaceSet">
			<xsl:apply-templates select="dae:polylist|dae:polygons|dae:triangles"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="dae:vertices">
		<xsl:apply-templates />
	</xsl:template>

<!-- broken -->
	<xsl:template match="dae:polygons">
			<xsl:attribute name="solid">true</xsl:attribute>
		
		<xsl:for-each select="dae:input[@semantic='VERTEX']">
			<xsl:variable name="source" select="substring-after(@source, '#')"/>
			<xsl:attribute name="coordIndex">
				<xsl:variable name="list">
					<xsl:call-template name="SkipList">
		                <xsl:with-param name="list" select="str:tokenize(../dae:p)" />
		                <xsl:with-param name="stride" select="count(../dae:input)" />
		                <xsl:with-param name="offset" select="@offset" />
		            </xsl:call-template>
		        </xsl:variable>
				<xsl:call-template name="Join">
	                <xsl:with-param name="list" select="exsl:node-set($list)/*" />
	            </xsl:call-template>
			</xsl:attribute>
			<xsl:element name="x3d:Coordinate">
				<xsl:attribute name="point">
					<xsl:apply-templates select="../../dae:vertices[@id=$source]"/>
				</xsl:attribute>
			</xsl:element>
			
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

	<xsl:template match="dae:polylist|dae:triangles">
			<xsl:attribute name="solid">true</xsl:attribute>
			<xsl:apply-templates select="dae:input"/>
		
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
		<xsl:variable name="list">
			<xsl:call-template name="SkipList">
                <xsl:with-param name="list" select="str:tokenize(../dae:p)" />
                <xsl:with-param name="stride" select="count(../dae:input)" />
                <xsl:with-param name="offset" select="@offset" />
            </xsl:call-template>
        </xsl:variable>
		<xsl:attribute name="coordIndex">
			<xsl:call-template name="Join">
                <xsl:with-param name="list" select="exsl:node-set($list)/*" />
            </xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="dae:input[@semantic='NORMAL']">
		<xsl:variable name="list">
			<xsl:call-template name="SkipList">
                <xsl:with-param name="list" select="str:tokenize(../dae:p)" />
                <xsl:with-param name="stride" select="count(../dae:input)" />
                <xsl:with-param name="offset" select="@offset" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="delimitedlist">
			<xsl:call-template name="Append">
                <xsl:with-param name="list" select="exsl:node-set($list)/*" />
                <xsl:with-param name="element" select="-1" />
            </xsl:call-template>
        </xsl:variable>
		<xsl:attribute name="normalIndex">
			<xsl:call-template name="Join">
                <xsl:with-param name="list" select="exsl:node-set($delimitedlist)/*"/>
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
		<x3d:Appearance>
			<xsl:variable name="target" select="substring-after(@target, '#')"/>
			<xsl:apply-templates select="//dae:material[@id=$target]"/>
		</x3d:Appearance>
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
		<xsl:element name="x3d:Material">
			<xsl:attribute name="emissiveColor">
				<xsl:call-template name="Take">
					<xsl:with-param name="list" select="str:tokenize(.//dae:emission/dae:color)"/>
					<xsl:with-param name="count" select="3"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="diffuseColor">
				<xsl:call-template name="Take">
					<xsl:with-param name="list" select="str:tokenize(.//dae:diffuse/dae:color)"/>
					<xsl:with-param name="count" select="3"/>
				</xsl:call-template>
			</xsl:attribute>
			<!--<xsl:attribute name="ambientIntensity">
				<xsl:value-of select=".//dae:ambient/dae:color"/>
			</xsl:attribute>-->
			<xsl:attribute name="specularColor">
				<xsl:call-template name="Take">
					<xsl:with-param name="list" select="str:tokenize(.//dae:specular/dae:color)"/>
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

	<!--<xsl:template name="Join">
		<xsl:param name="list" />
		<xsl:param name="separator" select="''"/>
		<xsl:param name="prefix" select="''"/>
		<xsl:choose>
	        <xsl:when test="$list">
	        	<xsl:call-template name="Join">
					<xsl:with-param name="list" select="exsl:node-set($list)[position() &gt; 1]"/>
					<xsl:with-param name="separator" select="' '"/>
					<xsl:with-param name="prefix">
						<xsl:value-of select="concat($prefix, concat($separator, exsl:node-set($list)[position() = 1]))"/>
					</xsl:with-param>
				</xsl:call-template>
	        </xsl:when>
	        <xsl:otherwise>
	        	<xsl:value-of select="$prefix"/>
 			</xsl:otherwise>
	    </xsl:choose> 
	</xsl:template>-->

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


</xsl:stylesheet>
