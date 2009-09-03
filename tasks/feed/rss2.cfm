<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. �See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. �If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes
the preparation of a derivative work based on Mura CMS. Thus, the terms and 	
conditions of the GNU General Public License version 2 (�GPL�) cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with programs or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, �the copyright holders of Mura CMS grant you permission
to combine Mura CMS �with independent software modules that communicate with Mura CMS solely
through modules packaged as Mura CMS plugins and deployed through the Mura CMS plugin installation API,
provided that these modules (a) may only modify the �/trunk/www/plugins/ directory through the Mura CMS
plugin installation API, (b) must not alter any default objects in the Mura CMS database
and (c) must not alter any files in the following directories except in cases where the code contains
a separately distributed license.

/trunk/www/admin/
/trunk/www/tasks/
/trunk/www/config/
/trunk/www/requirements/mura/

You may copy and distribute such a combined work under the terms of GPL for Mura CMS, provided that you include
the source code of that other code when and as the GNU GPL requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception
for your modified version; it is your choice whether to do so, or to make such modified version available under
the GNU General Public License version 2 �without this exception. �You may, if you choose, apply this exception
to your own modified versions of Mura CMS.
--->
<cfset tz=GetTimeZoneInfo()>

<cfif not find("-", tz.utcHourOffset)>
	<cfset utc = " -" & numberFormat(tz.utcHourOffset,"00") & "00">
<cfelse>
	<cfset tz.utcHourOffset = right(tz.utcHourOffset, len(tz.utcHourOffset) -1 )>
	<cfset utc = " +" & numberFormat(tz.utcHourOffset,"00") & "00">
</cfif>
<cfset pubDate=dateFormat(now(),"ddd, dd mmm yyyy") & " " & timeFormat(now(),"HH:mm:ss") & utc>
<cfheader name="content-type" value="text/xml;charset=UTF-8"><cfcontent reset="yes"><cfoutput><?xml version="1.0" ?>
<rss version="2.0">
	<channel>
		<title>#XMLFormat(feedBean.getName())#</title> 
		<link>http://#application.settingsManager.getSite(feedBean.getSiteID()).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()#</link> 
		<description>#XMLFormat(feedBean.getDescription())#</description> 
		<webMaster>#application.settingsManager.getSite(feedBean.getSiteID()).getContact()#</webMaster>
		<generator>http://www.getmura.com</generator>
		<pubDate>#XMLformat(pubDate)#</pubDate> 
		<language>#XMLFormat(feedBean.getLang())#</language>
<cfloop query="rs"><cfsilent>
<cfif feedBean.getallowhtml() eq 0>
	<cfset itemdescription = renderer.stripHTML(renderer.setDynamicContent(rs.summary))>
<cfelse>
	<cfset itemdescription = renderer.addCompletePath(renderer.setDynamicContent(rs.summary),feedBean.getSiteID())>
	<!---
	<cfif rs.type neq 'File' and rs.type neq 'Link'>
		<cfset itemBody = renderer.addCompletePath(rs.body,feedBean.getSiteID())>
	</cfif>
	--->
</cfif>
<cfif isDate(rs.releaseDate)>
	<cfset thePubDate=dateFormat(rs.releaseDate,"ddd, dd mmm yyyy") & " " & timeFormat(rs.releaseDate,"HH:mm:ss") & utc>
<cfelse>
	<cfset thePubDate=dateFormat(rs.lastUpdate,"ddd, dd mmm yyyy") & " " & timeFormat(rs.lastUpdate,"HH:mm:ss") & utc>
</cfif>

<cfset rsCats=application.contentManager.getCategoriesByHistID(rs.contentHistID)>

<cfset theLink=XMLFormat(renderer.createHREFforRss(rs.type,rs.filename,rs.siteid,rs.contentid,rs.target,rs.targetparams,application.configBean.getContext(),application.configBean.getStub(),application.configBean.getIndexFile(),0,rs.fileExt)) />
</cfsilent>
		<item>
			<title>#XMLFormat(rs.menutitle)#</title>	
			<link>#theLink#</link><cfif rs.type neq 'File' and rs.type neq 'Link'>
			<comments>#theLink###comments</comments></cfif>
			<guid isPermaLink="false">#rs.contentid#</guid>
			<pubDate>#XMLFormat(thePubDate)#</pubDate>
			<description><![CDATA[#itemdescription# ]]></description>
			<cfloop query="rsCats">
			<category><![CDATA[#rsCats.name#]]></category>	
			</cfloop>
			<cfif rs.type eq "File"><cfset fileMeta=application.serviceFactory.getBean("fileManager").readMeta(rs.fileID)><enclosure url="#XMLFormat('http://#application.settingsManager.getSite(rs.siteID).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()#/tasks/render/file/?fileID=#rs.fileID#&fileEXT=.#rs.fileEXT#')#" length="#rs.filesize#" type="#fileMeta.ContentType#/#fileMeta.ContentSubType#" /></cfif>
		</item></cfloop>
	</channel>
</rss></cfoutput>
