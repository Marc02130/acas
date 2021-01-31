global.logger = require "./routes/Logger"
require './src/javascripts/Logging/ConsoleLogWinstonOverride'
csUtilities = require "./src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js"

startApp = ->
# Regular system startup
	config = require './conf/compiled/conf.js'
	express = require 'express'
	user = require './routes/user'
	http = require 'http'
	path = require 'path'

	favicon = require('serve-favicon')
	logger = require('morgan')
	methodOverride = require('method-override')
	session = require('express-session')
	bodyParser = require('body-parser')
	# multer = require('multer')
	errorHandler = require('errorhandler')
	cookieParser = require('cookie-parser')

	# Added for logging support
	global.deployMode = config.all.client.deployMode

	global.stubsMode = false
	testModeOverRide = process.argv[2]
	unless typeof testModeOverRide == "undefined"
		if testModeOverRide == "stubsMode"
			global.stubsMode = true
			global.specRunnerTestmode = true
			console.log "############ Starting API in stubs mode"

	global.app = express()
	app.set 'port', config.all.server.nodeapi.port
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	# app.use(favicon(path.join(__dirname, '/public/favicon.ico')))
	app.use(logger('dev'))
	app.use(methodOverride())

	app.use(bodyParser.json({limit: '100mb'}))
	app.use(bodyParser.urlencoded({limit: '100mb', extended: true, parameterLimit: 1000000}))
	# app.use(multer())
	app.use express.static path.join(__dirname, 'public')


	#We just need the get user service
	loginRoutes = require './routes/loginRoutes'
	loginRoutes.setupAPIRoutes(app)
	indexRoutes = require('./routes/index.js');
	indexRoutes.setupAPIRoutes(app);

	process.on 'uncaughtException', (err) ->
		console.error 'Caught api exception: ' + err.stack
		return

	#TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES

	http.createServer(app).listen(app.get('port'), ->
		console.log("ACAS API server listening on port " + app.get('port'))
		bootstrap = require "./src/javascripts/ServerAPI/Bootstrap.js"
		if bootstrap.main?
			bootstrap.main()
	)

	csUtilities.logUsage("ACAS API server started", "started", "")

startApp()
