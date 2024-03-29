<cfcomponent output="false">

<cfproperty name="hashTest" inject="id:hashTest" scope="instance">

<!------------------------------------------- GLOBAL IMPLICIT EVENTS ONLY ------------------------------------------>
<!--- In order for these events to fire, you must declare them in the coldbox.xml.cfm --->
	
	<cffunction name="index" returntype="void" output="false">
		<cfargument name="event" required="true">
        <cfset event.setLayout("Layout.Main")>
        
        <cfif isDefined("session.User")>
	        <cfset event.setLayout("Layout.Home")>
        <cfelse>
	        <cfset event.setLayout("Layout.Main")>
        </cfif>
        
	</cffunction> 
    
	<cffunction name="onAppInit" returntype="void" output="false">
		<cfargument name="event" required="true">
	</cffunction>

	<cffunction name="onRequestStart" returntype="void" output="false">
		<cfargument name="event" required="true">
	</cffunction>

	<cffunction name="onRequestEnd" returntype="void" output="false">
		<cfargument name="event" required="true">
	</cffunction>
	
	<cffunction name="onSessionStart" returntype="void" output="false">
		<cfargument name="event" required="true">
	</cffunction>
	
	<cffunction name="onSessionEnd" returntype="void" output="false">
		<cfargument name="event" required="true">
		<cfset var sessionScope = event.getValue("sessionReference")>
		<cfset var applicationScope = event.getValue("applicationReference")>
		
	</cffunction>

	<cffunction name="onException" returntype="void" output="false">
		<cfargument name="event" required="true">
		<cfscript>
			//Grab Exception From request collection, placed by ColdBox
			var exceptionBean = event.getValue("ExceptionBean");
			//Place exception handler below:

		</cfscript>
	</cffunction>
	
	<cffunction name="onMissingTemplate" returntype="void" output="false">
		<cfargument name="event" required="true">
		<cfscript>
			//Grab missingTemplate From request collection, placed by ColdBox
			var missingTemplate = event.getValue("missingTemplate");
			
		</cfscript>
	</cffunction>

</cfcomponent>