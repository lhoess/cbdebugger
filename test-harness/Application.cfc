/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component {

	// UPDATE THE NAME OF THE MODULE IN TESTING BELOW
	request.MODULE_NAME = "cbdebugger";

	// Application properties
	this.name              = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout    = createTimespan( 0, 0, 15, 0 );
	this.setClientCookies  = true;

	/**************************************
	LUCEE Specific Settings
	**************************************/
	// buffer the output of a tag/function body to output in case of a exception
	this.bufferOutput                   = true;
	// Activate Gzip Compression
	this.compression                    = false;
	// Turn on/off white space managemetn
	this.whiteSpaceManagement           = "smart";
	// Turn on/off remote cfc content whitespace
	this.suppressRemoteComponentContent = false;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = "";

	// Mappings
	this.mappings[ "/root" ] = COLDBOX_APP_ROOT_PATH;

	// Map back to its root
	moduleRootPath = reReplaceNoCase(
		this.mappings[ "/root" ],
		"#request.MODULE_NAME#(\\|/)test-harness(\\|/)",
		""
	);
	modulePath = reReplaceNoCase(
		this.mappings[ "/root" ],
		"test-harness(\\|/)",
		""
	);

	// Module Root + Path Mappings
	this.mappings[ "/moduleroot" ]            = moduleRootPath;
	this.mappings[ "/#request.MODULE_NAME#" ] = modulePath;
	this.mappings[ "/cborm" ] = COLDBOX_APP_ROOT_PATH & "modules/cborm";
	this.mappings[ "/quick" ] = COLDBOX_APP_ROOT_PATH & "modules/quick";

	// ORM definitions
	this.datasource = "coolblog";
	this.ormEnabled = "true";

	this.ormSettings = {
		cfclocation           : [ "models" ],
		logSQL                : true,
		dbcreate              : "none",
		secondarycacheenabled : false,
		cacheProvider         : "ehcache",
		automanageSession     : false,
		flushAtRequestEnd     : false,
		eventhandling         : true,
		eventHandler          : "cborm.models.EventHandler",
		skipcfcWithError      : false
	};

	// application start
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap(
			COLDBOX_CONFIG_FILE,
			COLDBOX_APP_ROOT_PATH,
			COLDBOX_APP_KEY,
			COLDBOX_APP_MAPPING
		);
		application.cbBootstrap.loadColdbox();
		return true;
	}

	// request start
	public boolean function onRequestStart( String targetPage ){
		if ( !structKeyExists( application, "cbBootstrap" ) ){
			onApplicationStart();
		}
		if ( url.keyExists( "fwreinit" ) ) {
			if ( server.keyExists( "lucee" ) ) {
				pagePoolClear();
			}
			ormReload();
		}
		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}

	public void function onSessionStart(){
		if( !isNull( application.cbBootstrap ) ){
			application.cbBootStrap.onSessionStart();
		}
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection = arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection = arguments );
	}

}
