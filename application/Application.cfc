<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the bootstrapper Application.cfc for ColdBox Applications.
	It uses inheritance on the CFC, so if you do not want inheritance
	then use the Application_noinheritance.cfc instead.
	
	
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.Coldbox" output="false">
	<cfsetting enablecfoutputonly="yes">
	<!--- APPLICATION CFC PROPERTIES --->
	<cfset this.name = hash(getCurrentTemplatePath())> 
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
	<cfset this.setClientCookies = true>
	
    <cfscript>
	
    // orm settings 
    this.datasource = "hydra"; 
    this.ormEnabled = true; 
    this.ormsettings = { 
        dbcreate = "update", // This value drops the table if it exists and then creates it 
        logSQL = true, // SQL queries are logged to the console 
        cfclocation = "models",
		dialect = "MySQL"
    }; 
	
	</cfscript>
	
	<!--- COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP --->
	<cfset COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath())>
	<!--- The web server mapping to this application. Used for remote purposes or static purposes --->
	<cfset COLDBOX_APP_MAPPING   = "">
	<!--- COLDBOX PROPERTIES --->
	<cfset COLDBOX_CONFIG_FILE   = "">	
	<!--- COLDBOX APPLICATION KEY OVERRIDE --->
	<cfset COLDBOX_APP_KEY       = "">
	
	<!--- on Application Start --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfscript>
			//Load ColdBox
			loadColdBox();
			return true;
		</cfscript>
	</cffunction>
	
	<!--- on Request Start --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<!--- ************************************************************* --->
		<cfargument name="targetPage" type="string" required="true" />
		<!--- ************************************************************* --->
		<!--- Reload Checks --->              

        <cfsetting showdebugoutput="no">
        
		<cfset reloadChecks()>
		
		<!--- Process A ColdBox Request Only --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset processColdBoxRequest()>
		</cfif>
			
		<!--- WHATEVER YOU WANT BELOW --->
		<cfreturn true>
	</cffunction>

	
</cfcomponent>