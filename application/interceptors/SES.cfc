<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This is an interceptor for ses support. This code is based almost totally on
	Adam Fortuna's ColdCourse cfc, which is an AMAZING SES component
	All credits go to him: http://coldcourse.riaforge.com
----------------------------------------------------------------------->
<cfcomponent hint="This interceptor provides complete SES and URL mappings support to ColdBox Applications"
			 output="false"
			 extends="coldbox.system.interceptors.SES">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="configure" access="public" returntype="void" hint="This is where the ses plugin configures itself." output="false" >
		<cfscript>
			// STATIC Reserved Keys as needed for cleanups
			instance.RESERVED_KEYS 			  	= "handler,action,view,viewNoLayout,module,moduleRouting";
			instance.RESERVED_ROUTE_ARGUMENTS 	= "constraints,pattern,regexpattern,matchVariables,packageresolverexempt,patternParams,valuePairTranslation,ssl,append";
			// STATIC Valid Extensions
			instance.VALID_EXTENSIONS 			= "json,jsont,xml,html,htm,rss";

			// Routes Array
			instance.routes = ArrayNew(1);
			// Module Routing Table
			instance.moduleRoutingTable = structnew();
			// Loose matching flag for regex matches
			instance.looseMatching = false;
			// Flag to enable unique or not URLs
			instance.uniqueURLs = true;
			// Enable the interceptor by default
			instance.enabled = true;
			// Auto reload configuration file flag
			instance.autoReload = false;
			// Detect extensions flag, so it can place a 'format' variable on the rc
			instance.extensionDetection = true;
			// Throw an exception when extension detection is invalid or not
			instance.throwOnInvalidExtension = false;
			// Initialize the valid extensions to detect
			instance.validExtensions = instance.VALID_EXTENSIONS;

			// Setting Dependencies
			instance.handlersPath 					= getSetting("HandlersPath");
			instance.handlersExternalLocationPath 	= getSetting("HandlersExternalLocationPath");
			instance.modules						= getSetting("Modules");
			instance.eventName						= getSetting("EventName");
			instance.defaultEvent					= getSetting("DefaultEvent");

			// Dependencies
			instance.requestService					= getController().getRequestService();

			//Import Configuration
			importConfiguration();
			
			// Save the base URL in the application settings
			setSetting('sesBaseURL', getBaseURL() );
			setSetting('htmlBaseURL', replacenocase(getBaseURL(),"index.cfm",""));
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="This is the route dispatch" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" hint="The event object.">
		<cfargument name="interceptData" required="true" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
        
<cfif #isDefined("url.path_info")#>

<cfset MYPATH_INFO = "#replaceNoCase(url.path_info, 'index.cfm', '')#">

<cfelse>

<cfset MYPATH_INFO = "#cgi.PATH_INFO#">

</cfif>

        <cfset var prc = event.getCollection(private=true)>

		<cfif isDefined("MYPATH_INFO") and left(MYPATH_INFO, 5) is '/ajax'>
		<cfset prc.ajax = true>
		<cfset MYPATH_INFO = #replaceNoCase(MYPATH_INFO, '/ajax', '')#>
		<cfelseif isDefined("MYPATH_INFO") and left(MYPATH_INFO, 5) is 'ajax/'>
		<cfset prc.ajax = true>
		<cfset MYPATH_INFO = #replaceNoCase(MYPATH_INFO, 'ajax/', '/')#>
		</cfif>

<cfset temp = structDelete(url, 'PATH_INFO')>
<cfset temp = Event.removeValue('PATH_INFO')>
        
		<cfscript>
			// Find which route this URL matches
			var aRoute 		 = "";
			var key 		 = "";
			var routedStruct = structnew();
			var rc 			 = arguments.event.getCollection();
			var cleanedPaths = getCleanedPaths(rc,arguments.Event);
			var HTTPMethod	 = arguments.event.getHTTPMethod();

			// Check if disabled or in proxy mode, if it is, then exit out.
			if ( NOT instance.enabled OR arguments.event.isProxyRequest() ){ return; }

			//Auto Reload, usually in dev? then reconfigure the interceptor.
			if( instance.autoReload ){ configure(); }

			// Set that we are in ses mode
			arguments.event.setIsSES(true);

			// Check for invalid URLs if in strict mode via unique URLs
			if( instance.uniqueURLs ){
				checkForInvalidURL( cleanedPaths["pathInfo"] , cleanedPaths["scriptName"], arguments.event );
			}

			// Extension detection if enabled, so we can do cool extension formats
			if( instance.extensionDetection ){
				cleanedPaths["pathInfo"] = detectExtension(cleanedPaths["pathInfo"],arguments.event);
			}

			// Find a route to dispatch
			aRoute = findRoute(action=cleanedPaths["pathInfo"],event=arguments.event);

			// Now route should have all the key/pairs from the URL we need to pass to our event object for processing
			for( key in aRoute ){
				// Reserved Keys Check, only translate NON reserved keys
				if( not listFindNoCase(instance.RESERVED_KEYS,key) ){
					rc[key] = aRoute[key];
					routedStruct[key] = aRoute[key];
				}
			}

			// Create Event To Dispatch if handler key exists
			if( structKeyExists(aRoute,"handler") ){
				// If no action found, default to the convention of the framework, must likely 'index'
				if( NOT structKeyExists(aRoute,"action") ){
					aRoute.action = getDefaultFrameworkAction();
				}
				// else check if using HTTP method actions via struct
				else if( isStruct(aRoute.action) ){
					// Verify HTTP method used is valid, else throw exception and 403 error
					if( structKeyExists(aRoute.action,HTTPMethod) ){
						aRoute.action = aRoute.action[HTTPMethod];
						// Send for logging in debug mode
						if( log.canDebug() ){
							log.debug("Matched HTTP Method (#HTTPMethod#) to routed action: #aRoute.action#");
						}
					}
					else{
						getUtil().throwInvalidHTTP(className="SES",
												   detail="The HTTP method used: #HTTPMethod# is not valid for the current executing resource. Valid methods are: #aRoute.action.toString()#",
										 		   statusText="Invalid HTTP method: #HTTPMethod#",
										 		   statusCode="405");
					}
				}
				// Create routed event
				rc[instance.eventName] = aRoute.handler & "." & aRoute.action;

				// Do we have a module?If so, create routed module event.
				if( len(aRoute.module) ){
					rc[instance.eventName] = aRoute.module & ":" & rc[instance.eventName];
				}

			}// end if handler exists

			// See if View is Dispatched
			if( structKeyExists(aRoute,"view") ){
				// Dispatch the View
				arguments.event.setView(name=aRoute.view,noLayout=aRoute.viewNoLayout);
				arguments.event.noExecution();
			}

			// Save the Routed Variables so event caching can verify them
			arguments.event.setRoutedStruct(routedStruct);

			// Execute Cache Test now that routing has been done. We override, because events are determined until now.
			instance.requestService.eventCachingTest(context=arguments.event);
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- addModuleRoutes --->
	<cffunction name="addModuleRoutes" output="false" access="public" returntype="void" hint="Add modules routes in the specified position">
		<cfargument name="pattern" type="string"  required="true"  hint="The pattern to match against the URL." />
		<cfargument name="module"  type="string"  required="true"  hint="The module to load routes for"/>
		<cfargument name="append"  type="boolean" required="false" default="true" hint="Whether the module entry point route should be appended or pre-pended to the array. By default we append to the end of the array"/>
		<cfscript>
			var mConfig 	 = instance.modules;
			var routingTable = getModulesRoutingTable();
			var x 			 = 1;
			var args		 = structnew();

			// Verify module exists and loaded
			if( NOT structKeyExists(mConfig,arguments.module) ){
				$throw(message="Error loading module routes as the module requested '#arguments.module#' is not loaded.",
					   detail="The loaded modules are: #structKeyList(mConfig)#",
					   type="SES.InvalidModuleName");
			}

			// Create the module routes container if it does not exist already
			if( NOT structKeyExists(routingTable, arguments.module) ){
				routingTable[arguments.module] = arraynew(1);
			}

			// Store the entry point for the module routes.
			addRoute(pattern=arguments.pattern,moduleRouting=arguments.module,append=arguments.append);

			// Iterate through module routes and process them
			for(x=1; x lte ArrayLen(mConfig[arguments.module].routes); x=x+1){
				args = mConfig[arguments.module].routes[x];
				args.module = arguments.module;
				addRoute(argumentCollection=args);
			}

		</cfscript>
	</cffunction>

	<!--- Add a new Route --->
	<cffunction name="addRoute" access="public" returntype="void" hint="Adds a route to dispatch" output="false">
		<!--- ************************************************************* --->
		<cfargument name="action"  				 type="any" 	required="false" hint="The action in a handler to execute if a pattern is matched.  This can also be a structure or JSON structured based on the HTTP method(GET,POST,PUT,DELETE). ex: {GET:'show', PUT:'update', DELETE:'delete', POST:'save'}">
		<cfargument name="handler" 				 type="string" 	required="false" hint="The handler to execute if pattern matched.">
		<cfargument name="module" 				 type="string"  required="true" default="" hint="The module to add this route to"/>
		<cfargument name="orderby" 				 type="string" 	required="false"  hint="The pattern to match against the URL." />
		<cfargument name="pattern" 				 type="string" 	required="true"  hint="The pattern to match against the URL." />
		<cfargument name="packageResolverExempt" type="boolean" required="false" default="false" hint="If this is set to true, then the interceptor will not try to do handler package resolving. Else a package will always be resolved. Only works if :handler is in a pattern">
		<cfargument name="matchVariables" 		 type="string" 	required="false" hint="A string of name-value pair variables to add to the request collection when this pattern matches. This is a comma delimmitted list. Ex: spaceFound=true,missingAction=onTest">
		<cfargument name="view"  				 type="string"  required="false" hint="The view to dispatch if pattern matches.  No event will be fired, so handler,action will be ignored.">
		<cfargument name="viewNoLayout"  		 type="boolean" required="false" default="false" hint="If view is choosen, then you can choose to override and not display a layout with the view. Else the view renders in the assigned layout.">
		<cfargument name="valuePairTranslation"  type="boolean" required="false" default="true"  hint="Activate convention name value pair translations or not. Turned on by default">
		<cfargument name="constraints" 			 type="any"  	required="false" default="" hint="A structure or JSON structure of regex constraint overrides for variable placeholders. The key is the name of the variable, the value is the regex to try to match."/>
		<cfargument name="moduleRouting" 		 type="string"  required="false" default="" hint="Called internally by addModuleRoutes to add a module routing route."/>
		<cfargument name="ssl" 					 type="boolean" required="true"  default="false" hint="Makes the route an SSL only route if true, else it can be anything. If an ssl only route is hit without ssl, the interceptor will redirect to it via ssl"/>
		<cfargument name="append"  				 type="boolean" required="false" default="true" hint="Whether the module route should be appended or pre-pended to the array. By default we append to the end of the array"/>
		<!--- ************************************************************* --->
		<cfscript>
		var thisRoute = structNew();
		var thisPattern = "";
		var thisPatternParam = "";
		var arg = 0;
		var x =1;
		var thisRegex = 0;
		var oJSON = getPlugin("JSON");
		var jsonRegex = "^(\{|\[)(.)+(\}|\])$";
		var patternType = "";
			
		// Process all incoming arguments into the route to store
		for(arg in arguments){
			if( structKeyExists(arguments,arg) ){ thisRoute[arg] = arguments[arg]; }
		}

		// Process actions as a JSON structure?
		if( structKeyExists(arguments,"action") AND isSimpleValue(arguments.action) AND reFindnocase(jsonRegex,arguments.action) ){
			try{
				// Inflate action to structure
				thisRoute.action = oJSON.decode(arguments.action);
			}
			catch(Any e){
				$throw("Invalid JSON action","The action #arguments.action# is not valid JSON","SES.InvalidJSONAction");
			}
		}

		// Cleanup Route: Add trailing / to make it easier to parse
		if( right(thisRoute.pattern,1) IS NOT "/" ){
			thisRoute.pattern = thisRoute.pattern & "/";
		}
		// Cleanup initial /, not needed if found.
		if( left(thisRoute.pattern,1) IS "/" ){
			if( thisRoute.pattern neq "/" ){
				thisRoute.pattern = right(thisRoute.pattern,len(thisRoute.pattern)-1);
			}
		}

		// Check if we have optional args by looking for a ?
		if( findnocase("?",thisRoute.pattern) AND NOT findNoCase("regex:",thisRoute.pattern) ){
			processRouteOptionals(thisRoute);
			return;
		}

		// Process json constraints?
		thisRoute.constraints = structnew();
		// Check if implicit struct first, else try to do JSON conversion.
		if( isStruct(arguments.constraints) ){ thisRoute.constraints = arguments.constraints; }
		else if( reFindnocase(jsonRegex,arguments.constraints) ){
			try{
				// Inflate constratints to structure
				thisRoute.constraints = oJSON.decode(arguments.constraints);
			}
			catch(Any e){
				$throw("Invalid JSON constraints","The constraints #arguments.constraints# is not valid JSON","SES.InvalidJSONConstraint");
			}
		}

		// Init the matching variables
		thisRoute.regexPattern = "";
		thisRoute.patternParams = arrayNew(1);

		// Check for / pattern
		if( len(thisRoute.pattern) eq 1){
			thisRoute.regexPattern = "/";
		}

		// Process the route as a regex pattern
		for(x=1; x lte listLen(thisRoute.pattern,"/");x=x+1){

			// Pattern and Pattern Param
			thisPattern = listGetAt(thisRoute.pattern,x,"/");
			thisPatternParam = replace(listFirst(thisPattern,"-"),":","");

			// Detect Optional Types
			patternType = "alphanumeric";
			if( findnoCase("-numeric",thisPattern) ){ patternType = "numeric"; }
			if( findnoCase("-alpha",thisPattern) ){ patternType = "alpha"; }
			if( findNoCase("regex:",thisPattern) ){ patternType = "regex"; }

			// Pattern Type Regex
			switch(patternType){
				// CUSTOM REGEX
				case "regex" : {
					thisRegex = replacenocase(thisPattern,"regex:","");
					break;
				}

				// ALPHANUMERICAL OPTIONAL
				case "alphanumeric" : {
					if( find(":",thisPattern) ){
						thisRegex = "(" & REReplace(thisPattern,":(.[^-]*)","[^/]");
						// Check Digits Repetions
						if( find("{",thisPattern) ){
							thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
							arrayAppend(thisRoute.patternParams,replace(listFirst(thisPattern,"{"),":",""));
						}
						else{
							thisRegex = thisRegex & "+?)";
							arrayAppend(thisRoute.patternParams,thisPatternParam);
						}
						// Override Constraints with your own REGEX
						if( structKeyExists(thisRoute.constraints,thisPatternParam) ){
							thisRegex = thisRoute.constraints[thisPatternParam];
						}
					}
					else{
						thisRegex = thisPattern;
					}
					break;
				}
				// NUMERICAL OPTIONAL
				case "numeric" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-numeric", "[0-9]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
				// ALPHA OPTIONAL
				case "alpha" : {
					// Convert to Regex Pattern
					thisRegex = "(" & REReplace(thisPattern, ":.*?-alpha", "[a-zA-Z]");
					// Check Digits
					if( find("{",thisPattern) ){
						thisRegex = listFirst(thisRegex,"{") & "{#listLast(thisPattern,"{")#)";
					}
					else{
						thisRegex = thisRegex & "+?)";
					}
					// Add Route Param
					arrayAppend(thisRoute.patternParams,thisPatternParam);
					break;
				}
			} //end pattern type detection switch

			// Add Regex Created To Pattern
			thisRoute.regexPattern = thisRoute.regexPattern & thisRegex & "/";

		} // end looping of pattern optionals
		
		// Add it to the routing map table
		if( len(arguments.module) ){
			// Append or PrePend
			if( arguments.append ){	ArrayAppend(getModuleRoutes(arguments.module), thisRoute); }
			else{ arrayPrePend(getModuleRoutes(arguments.module), thisRoute); }
		}
		else{
			// Append or PrePend
			if( arguments.append ){	ArrayAppend(getRoutes(), thisRoute); }
			else{ arrayPrePend(getRoutes(), thisRoute); }
		}
				
		</cfscript>
	</cffunction>

	<!--- Get AutoReload --->
	<cffunction name="getAutoReload" access="public" returntype="any" output="false" hint="Set to auto reload the rules in each request" colddoc:generic="boolean">
		<cfreturn instance.autoReload>
	</cffunction>
	<cffunction name="setAutoReload" access="public" returntype="void" output="false" hint="Get the auto reload flag.">
		<cfargument name="autoReload" required="true" colddoc:generic="boolean">
		<cfset instance.autoReload = arguments.autoReload>
	</cffunction>

	<!--- Getter/Setter for uniqueURLs --->
	<cffunction name="setUniqueURLs" access="public" output="false" returntype="void" hint="Set the uniqueURLs property">
		<cfargument name="uniqueURLs" required="true" colddoc:generic="boolean"/>
		<cfset instance.uniqueURLs = arguments.uniqueURLs />
	</cffunction>
	<cffunction name="getUniqueURLs" access="public" output="false" returntype="any" hint="Get uniqueURLs" colddoc:generic="boolean">
		<cfreturn instance.uniqueURLs/>
	</cffunction>

	<!--- Setter/Getter for Base URL --->
	<cffunction name="setBaseURL" access="public" output="false" returntype="void" hint="Set the base URL for the application.">
		<cfargument name="baseURL" type="string" required="true" />
		<cfset instance.baseURL = arguments.baseURL />
	</cffunction>
	<cffunction name="getBaseURL" access="public" output="false" returntype="string" hint="Get BaseURL">
		<cfreturn instance.BaseURL/>
	</cffunction>

	<!--- Get/set Loose Matching --->
	<cffunction name="getLooseMatching" access="public" returntype="any" output="false" hint="Get the current loose matching property" colddoc:generic="boolean">
    	<cfreturn instance.looseMatching>
    </cffunction>
    <cffunction name="setLooseMatching" access="public" returntype="void" output="false" hint="Set the loose matching property of the interceptor">
    	<cfargument name="looseMatching" required="true" colddoc:generic="boolean">
    	<cfset instance.looseMatching = arguments.looseMatching>
    </cffunction>

	<!--- get/set Extension Detection --->
	<cffunction name="getExtensionDetection" access="public" returntype="any" output="false" hint="Get the flag if extension detection is enabled" colddoc:generic="boolean">
    	<cfreturn instance.extensionDetection>
    </cffunction>
    <cffunction name="setExtensionDetection" access="public" returntype="void" output="false" hint="Call it to activate/deactivate automatic extension detection">
    	<cfargument name="extensionDetection" required="true" colddoc:generic="boolean">
    	<cfset instance.extensionDetection = arguments.extensionDetection>
    </cffunction>

	<!--- get/set on Invalid Extension --->
	<cffunction name="getThrowOnInvalidExtension" access="public" returntype="any" output="false" hint="Get if we are throwing or not on invalid extension detection" colddoc:generic="boolean">
    	<cfreturn instance.throwOnInvalidExtension>
    </cffunction>
    <cffunction name="setThrowOnInvalidExtension" access="public" returntype="void" output="false" hint="Configure the interceptor to throw an exception or not when invalid extensions are detected">
    	<cfargument name="throwOnInvalidExtension" required="true" colddoc:generic="boolean">
    	<cfset instance.throwOnInvalidExtension = arguments.throwOnInvalidExtension>
    </cffunction>

	<!--- setValidExtensions --->
    <cffunction name="setValidExtensions" output="false" access="public" returntype="void" hint="Setup the list of valid extensions to detect automatically for you.: e.g.: json,xml,rss">
    	<cfargument name="validExtensions" required="true" hint="A list of valid extensions to allow in a request"/>
    	<cfset instance.validExtensions = arguments.validExtensions>
    </cffunction>

	<!--- getValidExtensions --->
    <cffunction name="getValidExtensions" output="false" access="public" returntype="any" hint="Get the list of valid extensions this interceptor allows">
    	<cfreturn instance.validExtensions>
    </cffunction>

	<!--- Getter/Setter Enabled --->
	<cffunction name="setEnabled" access="public" output="false" returntype="void" hint="Set whether the interceptor is enabled or not.">
		<cfargument name="enabled" required="true" colddoc:generic="boolean"/>
		<cfset instance.enabled = arguments.enabled />
	</cffunction>
	<cffunction name="getEnabled" access="public" output="false" returntype="any" hint="Get enabled" colddoc:generic="boolean">
		<cfreturn instance.enabled/>
	</cffunction>

	<!--- Getter routes --->
	<cffunction name="getRoutes" access="public" output="false" returntype="any" hint="Get the array containing all the routes" colddoc:generic="array">
		<cfreturn instance.Routes/>
	</cffunction>

	<!--- getModulesRoutingTable --->
	<cffunction name="getModulesRoutingTable" output="false" access="public" returntype="any" hint="Get the entire modules routing table" colddoc:generic="struct">
		<cfreturn instance.moduleRoutingTable>
	</cffunction>
	
	<!--- removeModuleRoutes --->
    <cffunction name="removeModuleRoutes" output="false" access="public" returntype="void" hint="Remove a module's routing table and registration points">
    	<cfargument name="module" required="true" default="" hint="The name of the module to remove"/>
		<cfscript>
			var routeLen = arrayLen( instance.routes );
			var x 		 = 1;
			var toDelete = arrayNew(1);
			
			// remove all module routes
    		structDelete(instance.moduleRoutingTable, arguments.module);
			// remove module routing entry point
			for(x=1; x lte routeLen; x=x+1){
				if( instance.routes[x].moduleRouting eq arguments.module ){
					// store position to delete
					arrayAppend(toDelete, x);
				}
			}
			// Remove positions from routing.
			for(x=1; x lte arrayLen(toDelete); x=x+1){
				arrayDeleteAt(instance.routes, toDelete[x]);
			}
		</cfscript>
    </cffunction>

	<!--- getModuleRoutes --->
	<cffunction name="getModuleRoutes" output="false" access="public" returntype="any" hint="Get a modules routes array" colddoc:generic="array">
		<cfargument name="module" required="true" default="" hint="The name of the module"/>
		<cfscript>
			var table = getModulesRoutingTable();
			if( structKeyExists(table, arguments.module) ){
				return table[arguments.module];
			}
			$throw(message="Module routes for #arguments.module# do not exists", detail="Loaded module routes are #structKeyList(table)#",type="SES.InvalidModuleException");
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- detectExtension --->
    <cffunction name="detectExtension" output="false" access="private" returntype="any" hint="Detect extensions from the incoming request">
    	<cfargument name="requestString" 	required="true"  hint="The requested URL string">
		<cfargument name="event"  			required="true"  hint="The event object.">
		<cfscript>
    		var extension 			= listLast(arguments.requestString,".");
			var extensionLen		= len(extension);

			// cleanup of extension, just in case rewrites add garbage.
			extension = reReplace(extension, "/$","","all" );

			// check if extension found
			if( listLen(arguments.requestString,".") GT 1 AND len(extension) AND NOT find("/",extension)){
				// Check if extension is valid?
				if( listFindNoCase(instance.validExtensions, extension) ){
					// set the format request collection variable
					event.setValue("format", lcase(extension));
					// debug logging
					if( log.canDebug() ){
						log.debug("Extension: #lcase(extension)# detected and set in rc.format");
					}
					// remove it from the string and return string for continued parsing.
					return left(requestString, len(arguments.requestString) - extensionLen - 1 );
				}
				else{
					// log invalid extension
					if( log.canWarn() ){
						log.warn("Invalid Extension Detected: #lcase(extension)# detected but it is not in the valid extension list: #instance.validExtensions#");
					}
					// throw exception if enabled, else just continue
					if( instance.throwOnInvalidExtension ){
					getUtil().throwInvalidHTTP(className="SES",
											   detail="Invalid Request Format Extension Detected: #lcase(extension)#. Valid extensions are: #instance.validExtensions#",
									  		   statusText="Invalid Requested Format Extension: #lcase(extension)#",
									 		   statusCode="406");
					}
				}
			}

			// return the same request string, extension not found
			return requestString;
		</cfscript>
    </cffunction>

	<!--- setmoduleRoutingTable --->
	<cffunction name="setModuleRoutingTable" output="false" access="private" returntype="void" hint="Set the module routing table">
		<cfargument name="routes" required="true" colddoc:generic="struct"/>
		<cfset instance.moduleRoutingTable = arguments.routes>
	</cffunction>

	<!--- Set Routes --->
	<cffunction name="setRoutes" access="private" output="false" returntype="void" hint="Internal override of the routes array">
		<cfargument name="routes" required="true" colddoc:generic="array"/>
		<cfset instance.routes = arguments.routes/>
	</cffunction>

	<!--- Get Default Framework Action --->
	<cffunction name="getDefaultFrameworkAction" access="private" returntype="string" hint="Get the default framework action" output="false" >
		<cfreturn getController().getSetting("eventAction",1)>
	</cffunction>

	<!--- CGI Element Facade. --->
	<cffunction name="getCGIElement" access="private" returntype="any" hint="The cgi element facade method" output="true" >
		<cfargument name="cgielement" required="true" hint="The cgi element to retrieve">
		<cfargument name="Event"  required="true" hint="The event object.">
		<cfscript>
			// Allow a UDF to manipulate the CGI.PATH_INFO value
			// in advance of route detection.
			if (arguments.cgielement is 'path_info') {
				return MYPATH_INFO;
			} else {
				return cgi[arguments.cgielement];
			}		
			return CGI[arguments.CGIElement];
		</cfscript>
	</cffunction>

	<!--- Package Resolver --->
	<cffunction name="packageResolver" access="private" returntype="any" hint="Resolve handler/module packages" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="routingString" 	required="true" hint="The routing string">
		<cfargument name="routeParams" 		required="true" hint="The routed params array">
		<cfargument name="isModule" 		required="false" default="false" hint="Tells package resolver this is an explicit module package resolving call"/>
		<!--- ************************************************************* --->
		<cfscript>
			var root 			= instance.handlersPath;
			var extRoot 		= instance.handlersExternalLocationPath;
			var x 				= 1;
			var newEvent 		= "";
			var thisFolder 		= "";
			var foundPaths 		= "";
			var routeParamsLen 	= arrayLen(arguments.routeParams);
			var rString 		= arguments.routingString;
			var returnString 	= arguments.routingString;
			
			// Verify if we have a handler on the route params
			if( findnocase("handler", arrayToList(arguments.routeParams)) ){

				// Cleanup routing string to position of :handler
				for(x=1; x lte routeParamsLen; x=x+1){
					if( arguments.routeParams[x] neq "handler" ){
						rString = replace(rString,listFirst(rString,"/") & "/","");
					}
					else{
						break;
					}
				}

				// Now Find Packaging in our stripped rString
				for(x=1; x lte listLen(rString,"/"); x=x+1){

					// Get Folder from first part of string
					thisFolder = listgetAt(rString,x,"/");

					// Check if package exists in convention OR external location
					if( NOT isModule AND
						(
							directoryExists(root & "/" & foundPaths & thisFolder)
							OR
					    	( len(extRoot) AND directoryExists(extRoot & "/" & foundPaths & thisFolder) )
						)
					    ){
						// Save Found Paths
						foundPaths = foundPaths & thisFolder & "/";
						// Save new Event
						if(len(newEvent) eq 0){
							newEvent = thisFolder & ".";
						}
						else{
							newEvent = newEvent & thisFolder & ".";
						}
					}//end if folder found
					// Module check second
					else if( structKeyExists(instance.modules, thisFolder) ){
						// Setup the module entry point
						newEvent = thisFolder & ":";
						// Change Physical Path to module now, module detected
						root = instance.modules[thisFolder].handlerPhysicalPath;
					}
					else{
						//newEvent = newEvent & "." & thisFolder;
						break;
					}//end not a folder or module

				}//end for loop

				// Replace Return String if new event packaged found
				if( len(newEvent) ){
					// module/event replacement
					returnString = replacenocase(returnString, replace( replace(newEvent,":","/","all") ,".","/","all"), newEvent);
				}
			}//end if handler found

			return returnString;
		</cfscript>
	</cffunction>

	<cffunction name="serializeURL" access="private" output="false" returntype="any" hint="Serialize a URL when invalid">
		<!--- ************************************************************* --->
		<cfargument name="formVars" required="false" default="">
		<cfargument name="event" 	required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var vars = arguments.formVars;
			var key = 0;
			var rc = arguments.event.getCollection();
			var resolvedAction = rc.action;

			for(key in rc){
				
				if (isStruct(action)) {
					
					for( key in action ){
						if( not listFindNoCase(instance.RESERVED_KEYS,key) ){
							resolvedAction = key;
							}
					}
					
				}
				
				if( NOT ListFindNoCase("route,handler,resolvedAction,#instance.eventName#",key) ){
					vars = ListAppend(vars, "#lcase(key)#=#rc[key]#", "&");
				}
			}
			if( len(vars) eq 0 ){
				return "";
			}
			return "?" & vars;
		</cfscript>
	</cffunction>

	<!--- Check for Invalid URL --->
	<cffunction name="checkForInvalidURL" access="private" output="false" returntype="void" hint="Check for invalid URL's">
		<!--- ************************************************************* --->
		<cfargument name="route" 		required="true" />
		<cfargument name="script_name" 	required="true" />
		<cfargument name="event" 		required="true" />
		<!--- ************************************************************* --->
		<cfset var handler = "" />
		<cfset var action = "" />
		<cfset var newpath = "" />
		<cfset var httpRequestData = getHttpRequestData()>
		<cfset var rc = event.getCollection()>

		<!---
		Verify we have uniqueURLs ON, the event var exists, route is empty or index.cfm
		AND
		if the incoming event is not the default OR it is the default via the URL.
		--->
		<cfif StructKeyExists(rc, instance.eventName)
			  AND (arguments.route EQ "/index.cfm" or arguments.route eq "")
			  AND (
			  		rc[instance.eventName] NEQ instance.defaultEvent
			  		OR
			  		( structKeyExists(url,instance.eventName) AND rc[instance.eventName] EQ instance.defaultEvent )
			  )>

			<!--- New Pathing Calculations if not the default event. If default, relocate to the domain. --->
			<cfif rc[instance.eventName] neq instance.defaultEvent>
				<!--- Clean for handler & Action --->
				<cfif StructKeyExists(rc, instance.eventName)>
					<cfset handler = reReplace(rc[instance.eventName],"\.[^.]*$","") />
					<cfset action = ListLast( rc[instance.eventName], "." ) />
				</cfif>
				<!--- route a handler --->
				<cfif len(handler)>
					<cfset newpath = "/" & handler />
				</cfif>
				<!--- route path with handler + action if not the default event action --->
				<cfif len(handler)
					  AND len(action)
					  AND action NEQ getDefaultFrameworkAction()>
					<cfset newpath = newpath & "/" & action />
				</cfif>
			</cfif>

			<!--- Debug Logging --->
			<cfif log.canDebug()>
				<cfset log.debug("SES Invalid URL detected. Route: #arguments.route#, script_name: #arguments.script_name#")>
			</cfif>

			<!--- Relocation headers --->
			<cfif httpRequestData.method EQ "GET">
				<cfheader statuscode="301" statustext="Moved permanently" />
			<cfelse>
				<cfheader statuscode="303" statustext="See Other" />
			</cfif>

			<!--- Relocate --->
			<cfheader name="Location" value="#arguments.event.getSESbaseURL()##newpath##serializeURL(httpRequestData.content,arguments.event)#" />
			<cfabort />
		</cfif>
	</cffunction>

	<!--- Fix Ending IIS funkyness --->
	<cffunction name="fixIISURLVars" access="private" returntype="any" hint="Clean up some IIS funkyness" output="false" >
		<cfargument name="requestString"  required="true" hint="The request string">
		<cfargument name="rc"  			  required="true" hint="The request collection">
		<cfscript>
			var varMatch = 0;
			var qsValues = 0;
			var qsVal = 0;
			var x = 1;

			// Find a Matching position of IIS ?
			varMatch = REFind("\?.*=",arguments.requestString,1,"TRUE");
			if( varMatch.pos[1] ){
				// Copy values to the RC
				qsValues = REreplacenocase(arguments.requestString,"^.*\?","","all");
				// loop and create
				for(x=1; x lte listLen(qsValues,"&"); x=x+1){
					qsVal = listGetAt(qsValues,x,"&");
					arguments.rc[listFirst(qsVal,"=")] = listLast(qsVal,"=");
				}
				// Clean the request string
				arguments.requestString = Mid(arguments.requestString, 1, (varMatch.pos[1]-1));
			}

			return arguments.requestString;
		</cfscript>
	</cffunction>

	<!--- Find a route --->
	<cffunction name="findRoute" access="private" output="false" returntype="any" hint="Figures out which route matches this request and returns a routed structure">
		<!--- ************************************************************* --->
		<cfargument name="action" required="true"  hint="The action evaluated by the path_info">
		<cfargument name="event"  required="true"  hint="The event object.">
		<cfargument name="module" required="false" default="" hint="Find a route on a module"/>
		<!--- ************************************************************* --->
		<cfset var requestString 		 = arguments.action />
		<cfset var packagedRequestString = "">
		<cfset var match 				 = structNew() />
		<cfset var foundRoute 			 = structNew() />
		<cfset var params 				 = structNew() />
		<cfset var key					 = "" />
		<cfset var i 					 = 1 />
		<cfset var x 					 = 1 >
		<cfset var rc 					 = event.getCollection()>
		<cfset var _routes 				 = getRoutes()>
		<cfset var _routesLength 		 = ArrayLen(_routes)>

		<cfscript>

			// Module call? Switch routes
			if( len(arguments.module) ){
				_routes = getModuleRoutes(arguments.module);
				_routesLength = arrayLen(_routes);
			}
			
			//Remove the leading slash
			if( len(requestString) GT 1 AND left(requestString,1) eq "/" ){
				requestString = right(requestString,len(requestString)-1);
			}
			// Add ending slash
			if( right(requestString,1) IS NOT "/" ){
				requestString = requestString & "/";
			}

			// Let's Find a Route, Loop over all the routes array
			for(i=1; i lte _routesLength; i=i+1){

				// Match The route to request String
				match = reFindNoCase(_routes[i].regexPattern,requestString,1,true);
				if( (match.len[1] IS NOT 0 AND getLooseMatching())
				     OR
				    (NOT getLooseMatching() AND match.len[1] IS NOT 0 AND match.pos[1] EQ 1) ){
					// Setup the found Route
					foundRoute = _routes[i];
					// Debug logging
					if( log.canDebug() ){
						log.debug("SES Route matched: #foundRoute.toString()# on routed string: #requestString#");
					}
					break;
				}

			}//end finding routes
			
			// Check if we found a route, else just return empty params struct
			if( structIsEmpty(foundRoute) ){
				if( log.canDebug() ){
					log.debug("No SES routes matched on routed string: #requestString#");
				}
				return params;
			}

			// SSL Checks
			if( foundRoute.ssl AND NOT event.isSSL()){
				setNextEvent(uri=cgi.script_name & cgi.path_info,ssl=true,statusCode=302,queryString=cgi.query_string);
			}

			// Check if the match is a module Routing entry point or not?
			if( len( foundRoute.moduleRouting ) ){

				// Try to Populate the params from the module pattern if any
				for(x=1; x lte arrayLen(foundRoute.patternParams); x=x+1){
					params[foundRoute.patternParams[x]] = mid(requestString, match.pos[x+1], match.len[x+1]);
				}

				// Save Found URL
				arguments.event.setValue(name="currentRoutedURL",value=requestString,private=true);
				
				// Try to discover the route via the module routing calls
				structAppend(params, findRoute(reReplaceNoCase(requestString,foundRoute.regexpattern,""),arguments.event,foundRoute.moduleRouting), true);

				// Return if parameters found.
				if( NOT structIsEmpty(params) ){
					return params;
				}
			}
			
			// Save Found Route
			arguments.event.setValue(name="currentRoute",value=foundRoute.pattern,private=true);
			// Save Found URL if NOT Found already
			if( NOT arguments.event.valueExists(name="currentRoutedURL",private=true) ){
				arguments.event.setValue(name="currentRoutedURL",value=requestString,private=true);
			}

			// Do we need to do package resolving
			if( NOT foundRoute.packageResolverExempt ){
				// Resolve the packages
				packagedRequestString = packageResolver(requestString,foundRoute.patternParams, len(arguments.module) GT 0);
				// reset pattern matching, if packages found.
				if( compare(packagedRequestString,requestString) NEQ 0 ){

					// Log package resolved
					if( log.canDebug() ){
						log.debug("SES Package Resolved: #packagedRequestString#");
					}

					// Return found Route recursively.
					return findRoute(action=packagedRequestString,event=arguments.event);
				}
			}

			// Populate the params, with variables found in the request string
			for(x=1; x lte arrayLen(foundRoute.patternParams); x=x+1){
				params[foundRoute.patternParams[x]] = mid(requestString, match.pos[x+1], match.len[x+1]);
			}

			// Process Convention Name-Value Pairs
			if( foundRoute.valuePairTranslation ){
				findConventionNameValuePairs(requestString,match,params);
			}

			// Now setup all found variables in the param struct, so we can return
			for(key in foundRoute){
				// Check that the key is not a reserved route argument and NOT already routed
				if( NOT listFindNoCase(instance.RESERVED_ROUTE_ARGUMENTS,key)
					AND NOT structKeyExists(params, key) ){
					params[key] = foundRoute[key];
				}
				else if (key eq "matchVariables"){
					for(i=1; i lte listLen(foundRoute.matchVariables); i = i+1){
						// Check if the key does not exist in the routed params yet.
						if( NOT structKeyExists(params, listFirst(listGetAt(foundRoute.matchVariables,i),"=") ) ){
							params[listFirst(listGetAt(foundRoute.matchVariables,i),"=")] = listLast(listGetAt(foundRoute.matchVariables,i),"=");
						}
					}
				}
			}

			return params;
		</cfscript>
	</cffunction>

	<!--- findConventionNameValuePairs --->
	<cffunction name="findConventionNameValuePairs" access="private" returntype="void" hint="Find the convention name value pairs" output="false" >
		<cfargument name="requestString"  	type="string" 	required="true" hint="The request string">
		<cfargument name="match"  			type="any" 		required="true" hint="The regex matcher">
		<cfargument name="params"  		 	type="struct" 	required="true" hint="The parameter structure">
		<cfscript>
		//var leftOverLen = len(arguments.requestString)-(arguments.match.pos[arraylen(arguments.match.pos)]+arguments.match.len[arrayLen(arguments.match.len)]-1);
		var leftOverLen = len(arguments.requestString) - arguments.match.len[1];
		var conventionString = 0;
		var conventionStringLen = 0;
		var tmpVar = 0;
		var i = 1;

		if( leftOverLen gt 0 ){
			// Cleanup remaining string
			conventionString 	= right(arguments.requestString,leftOverLen).split("/");
			conventionStringLen = arrayLen(conventionString);

			// If conventions found, continue parsing
			for(i=1; i lte conventionStringLen; i=i+1){
				if( i mod 2 eq 0 ){
					// Even: Means Variable Value
					arguments.params[tmpVar] = conventionString[i];
				}
				else{
					// ODD: Means variable name
					tmpVar = trim(conventionString[i]);
					// Verify it is a valid variable Name
					if ( NOT isValid("variableName",tmpVar) ){
						tmpVar = "_INVALID_VARIABLE_NAME_POS_#i#_";
					}
					else{
						// Default Value of empty
						arguments.params[tmpVar] = "";
					}
				}
			}//end loop over pairs
		}//end if convention name value pairs
		</cfscript>
	</cffunction>

	<!--- getCleanedPaths --->
	<cffunction name="getCleanedPaths" access="private" returntype="any" hint="Get and Clean the path_info and script names structure" output="false" >
		<cfargument name="rc" required="true" hint="The request collection to incorporate items into"/>
		<cfargument name="event" required="true" hint="The event object.">
		<cfscript>
			var items = structnew();

			// Get path_info & script name
			items["pathInfo"] 	= getCGIElement('path_info',arguments.event);
			items["scriptName"] = trim(reReplacenocase(getCGIElement('script_name',arguments.event),"[/\\]index\.cfm",""));

			// Clean ContextRoots
			if( len(getContextRoot()) ){
				items["pathInfo"] 	= replacenocase(items["pathInfo"],getContextRoot(),"");
				items["scriptName"] = replacenocase(items["scriptName"],getContextRoot(),"");
			}

			// Clean up the path_info from index.cfm and nested pathing
			items["pathInfo"] = trim(reReplacenocase(items["pathInfo"],"[/\\]index\.cfm",""));
			if( len(items["scriptName"]) ){
				items["pathInfo"] = replaceNocase(items["pathInfo"],items["scriptName"],'');
			}

			// clean 1 or > / in front of route in some cases, scope = one by default
			items["pathInfo"] = reReplaceNoCase(items["pathInfo"], "^/+", "/");

			// fix URL vars after ?
			items["pathInfo"] = fixIISURLVars(items["pathInfo"],arguments.rc);

			return items;
		</cfscript>
	</cffunction>

	<!--- processRouteOptionals --->
	<cffunction name="processRouteOptionals" access="private" returntype="void" hint="Process route optionals" output="false" >
		<cfargument name="thisRoute"  type="struct" required="true" hint="The route struct">
		<cfscript>
			var x=1;
			var thisPattern = 0;
			var base = "";
			var optionals = "";
			var routeList = "";

			// Parse our base & optionals
			for(x=1; x lte listLen(arguments.thisRoute.pattern,"/"); x=x+1){
				thisPattern = listgetAt(arguments.thisRoute.pattern,x,"/");
				// Check for ?
				if( not findnocase("?",thisPattern) ){
					base = base & thisPattern & "/";
				}
				else{
					optionals = optionals & replacenocase(thisPattern,"?","","all") & "/";
				}
			}
			// Register our routeList
			routeList = base & optionals;
			// Recurse and register in reverse order
			for(x=1; x lte listLen(optionals,"/"); x=x+1){
				// Create new route
				arguments.thisRoute.pattern = routeList;
				// Register route
				addRoute(argumentCollection=arguments.thisRoute);
				// Remove last bit
				routeList = listDeleteat(routeList,listlen(routeList,"/"),"/");
			}
			// Setup the base route again
			arguments.thisRoute.pattern = base;
			// Register the final route
			addRoute(argumentCollection=arguments.thisRoute);
		</cfscript>
	</cffunction>

	<!--- importConfiguration --->
	<cffunction name="importConfiguration" output="false" access="private" returntype="void" hint="Import the routing configuration file">
		<cfscript>
			var appLocPrefix 	= "/";
			var configFilePath 	= "";
			var refLocal 		= structnew();
			var appMapping 		= getSetting('AppMapping');

			// Verify the config file, else set it to our convention in the config/Routes.cfm
			if( not propertyExists('configFile') ){
				setProperty('configFile','config/Routes.cfm');
			}

			//App location prefix
			if( len(appMapping) ){
				appLocPrefix = appLocPrefix & appMapping & "/";
			}

			// Setup the config Path for relative location first.
			configFilePath = appLocPrefix & reReplace(getProperty('ConfigFile'),"^/","");
			if( NOT fileExists(expandPath(configFilePath)) ){
				//Check absolute location as not found inside our app
				configFilePath = getProperty('ConfigFile');
				if( NOT fileExists(expandPath(configFilePath)) ){
					$throw(message="Error locating routes file: #configFilePath#",type="SES.ConfigFileNotFound");
				}
			}

			// We are ready to roll. Import config to setup the routes.
			try{
				// Try to remove pathInfoProvider, just in case
				structdelete(variables,"pathInfoProvider");
				structdelete(this,"pathInfoProvider");
				// Include configuration
				$include(configFilePath);
			}
			catch(Any e){
				$throw("Error including config file: #e.message# #e.detail#",e.tagContext.toString(),"SES.executingConfigException");
			}

			// Validate the base URL
			if ( len(getBaseURL()) eq 0 ){
				$throw('The baseURL property has not been defined. Please define it using the setBaseURL() method.','','interceptors.SES.invalidPropertyException');
			}
		</cfscript>
	</cffunction>

	<!--- getUtil --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>