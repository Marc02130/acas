exports.setupAPIRoutes = (app) ->
	app.get '/cmpdReg/scientists', exports.getScientists
	app.get '/cmpdReg/metalots/corpName/:lotCorpName', exports.getMetaLot
	app.delete '/cmpdReg/metalots/corpName/:lotCorpName', exports.deleteMetaLot
	app.get '/cmpdReg/metalots/checkDependencies/corpName/:lotCorpName', exports.getMetaLotDepedencies
	app.post '/cmpdReg/metalots', exports.metaLots
	app.get '/cmpdReg/parentLot/getAllAuthorizedLots', exports.getAllAuthorizedLots

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdReg', loginRoutes.ensureAuthenticated, exports.cmpdRegIndex
	app.get '/marvin4js-license.cxl', loginRoutes.ensureAuthenticated, exports.getMarvinJSLicense
	app.get '/cmpdReg/scientists', loginRoutes.ensureAuthenticated, exports.getScientists
	app.get '/cmpdReg/aliases/parentAliasKinds', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/units', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/solutionUnits', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/stereoCategories', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/compoundTypes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/parentAnnotations', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/fileTypes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/projects', loginRoutes.ensureAuthenticated, exports.getAuthorizedCmpdRegProjects
	app.get '/cmpdReg/vendors', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/physicalStates', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/operators', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/purityMeasuredBys', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/structureimage/:type/[\\S]*', loginRoutes.ensureAuthenticated, exports.getStructureImage
	app.get '/cmpdReg/metalots/corpName/:lotCorpName', loginRoutes.ensureAuthenticated, exports.getMetaLot
	app.get '/cmpdReg/MultipleFilePicker/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMultipleFilePicker
	app.post '/cmpdReg/search/cmpds', loginRoutes.ensureAuthenticated, exports.searchCmpds
	app.post '/cmpdReg/regsearches/parent', loginRoutes.ensureAuthenticated, exports.regSearch
	app.post '/cmpdReg/structuresearch', loginRoutes.ensureAuthenticated, exports.structureSearch
	app.post '/cmpdReg/filesave', loginRoutes.ensureAuthenticated, exports.fileSave
	app.post '/cmpdReg/metalots', loginRoutes.ensureAuthenticated, exports.metaLots
	app.delete '/cmpdReg/metalots/corpName/:lotCorpName', loginRoutes.ensureAuthenticated, exports.deleteMetaLot
	app.get '/cmpdReg/metalots/checkDependencies/corpName/:lotCorpName',  loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.getMetaLotDepedencies
	app.post '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.saveSalts
	app.post '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.saveIsotopes
	app.post '/cmpdReg/api/v1/structureServices/molconvert', loginRoutes.ensureAuthenticated, exports.molConvert
	app.post '/cmpdReg/api/v1/structureServices/clean', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/hydrogenizer', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/cipStereoInfo', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/export/searchResults', loginRoutes.ensureAuthenticated, exports.exportSearchResults
	app.post '/cmpdReg/validateParent', loginRoutes.ensureAuthenticated, exports.validateParent
	app.post '/cmpdReg/updateParent', loginRoutes.ensureAuthenticated, exports.updateParent
	app.post '/cmpdReg/api/v1/lotServices/update/lot/metadata', loginRoutes.ensureAuthenticated, exports.updateLotMetadata
	app.post '/cmpdReg/api/v1/lotServices/update/lot/metadata/jsonArray', loginRoutes.ensureAuthenticated, exports.updateLotsMetadata
	app.post '/cmpdReg/api/v1/parentServices/update/parent/metadata', loginRoutes.ensureAuthenticated, exports.updateParentMetadata
	app.post '/cmpdReg/api/v1/parentServices/update/parent/metadata/jsonArray', loginRoutes.ensureAuthenticated, exports.updateParentsMetadata
	app.post '/cmpdReg/api/v1/lotServices/reparent/lot', loginRoutes.ensureAuthenticated, exports.reparentLot
	app.post '/cmpdReg/api/v1/lotServices/reparent/lot/jsonArray', loginRoutes.ensureAuthenticated, exports.reparentLots
	app.get '/api/cmpdReg/ketcher/knocknock', loginRoutes.ensureAuthenticated, exports.ketcherKnocknock
	app.get '/api/cmpdReg/ketcher/layout', loginRoutes.ensureAuthenticated, exports.ketcherConvertSmiles
	app.post '/api/cmpdReg/ketcher/layout', loginRoutes.ensureAuthenticated, exports.ketcherLayout
	app.post '/api/cmpdReg/ketcher/calculate_cip', loginRoutes.ensureAuthenticated, exports.ketcherCalculateCip
	app.get '/cmpdReg/labelPrefixes', loginRoutes.ensureAuthenticated, exports.getAuthorizedPrefixes
	app.get '/cmpdReg/parentLot/getLotsByParent', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/parentLot/getAllAuthorizedLots', loginRoutes.ensureAuthenticated, exports.getAllAuthorizedLots
	app.get '/cmpdReg/allowCmpdRegistration', loginRoutes.ensureAuthenticated, exports.allowCmpdRegistration

_ = require 'underscore'
request = require 'request'
config = require '../conf/compiled/conf.js'
# node-fetch is ES5 modules only so need to import it like this async
fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
serverUtilityFunctions = require './ServerUtilityFunctions.js'
loginRoutes = require './loginRoutes.js'
authorRoutes = require './AuthorRoutes.js'

exports.cmpdRegIndex = (req, res) ->
	scriptPaths = require './RequiredClientScripts.js'
	grantedRoles = _.map req.user.roles, (role) ->
		role.roleEntry.roleName
	console.log grantedRoles
	isChemist = !config.all.client.roles.cmpdreg?.chemistRole? || (config.all.client.roles.cmpdreg?.chemistRole? && config.all.client.roles.cmpdreg.chemistRole in grantedRoles)
	isAdmin = !config.all.client.roles.cmpdreg?.adminRole? || (config.all.client.roles.cmpdreg?.adminRole? && config.all.client.roles.cmpdreg.adminRole in grantedRoles)
	global.specRunnerTestmode = if global.stubsMode then true else false
	scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts)
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
		cmpdRegUser =
			id: req.user.id
			code: req.user.username
			name: req.user.firstName + " " + req.user.lastName
			isChemist: isChemist
			isAdmin: isAdmin
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"
		cmpdRegUser =
			id: 0
			code: "nouser"
			name: "no user"
			isChemist: true
			isAdmin : true

	return res.render 'CmpdReg',
		title: "Compound Registration"
		scripts: scriptsToLoad
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			cmpdRegUser: cmpdRegUser
			testMode: false
			moduleLaunchParams: if moduleLaunchParams? then moduleLaunchParams else null
			deployMode: global.deployMode
			cmpdRegConfig: config.all.client.cmpdreg

exports.getAPICmpdReg = (req, resp) ->
	console.log 'in getAPICmpdReg'
	console.log req.originalUrl
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "/" +endOfUrl
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.getAuthorizedCmpdRegProjects = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		resp.status "200"
		resp.end JSON.stringify allowedUserProjects

exports.getScientists = (req, resp) =>
	exports.getScientistsInternal (authors) ->
		resp.json authors 

exports.getScientistsInternal = (callback) ->
	config = require '../conf/compiled/conf.js'
	roleName = null
	if config.all.client.roles.cmpdreg.chemistRole? && config.all.client.roles.cmpdreg.chemistRole != ""
		roleName = config.all.client.roles.cmpdreg.chemistRole
	loginRoutes.getAuthorsInternal {additionalCodeType: 'compound', additionalCodeKind: 'scientist', roleName: roleName}, (statusCode, authors) =>
		callback authors

exports.structureSearch = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		req.body.projects = allowedProjectCodes
		console.log req.body
		cmpdRegCall = config.all.client.service.persistence.fullpath + '/structuresearch/'
		req.pipe(request[req.method.toLowerCase()](
			url: cmpdRegCall
			json: req.body)).pipe resp

exports.searchCmpds = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		req.body.projects = allowedProjectCodes
		console.log req.body
		cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/search/cmpds'
		request(
			method: 'POST'
			url: cmpdRegCall
			body: JSON.stringify req.body
			json: true
			timeout: 6000000
		, (error, response, json) =>
			if !error
				console.log JSON.stringify json
				resp.statusCode = response.statusCode
				resp.setHeader('Content-Type', 'application/json')
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to search for compounds'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify {error: "something went wrong :("}
		)


exports.getAllAuthorizedLots = (req, resp) ->
	req.setTimeout 86400000
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		requestJSON = allowedProjectCodes
		console.log requestJSON
		cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/getLotsByProjectsList'
		request(
			method: 'POST'
			url: cmpdRegCall
			body: requestJSON
			json: true
			timeout: 6000000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.setHeader('Content-Type', 'application/json')
				resp.end JSON.stringify json
			else
				console.log resp.stat
				console.log 'got ajax error trying to get all lots'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				console.log response.statusCode
				resp.end JSON.stringify {error: "something went wrong :("}
		)

exports.getStructureImage = (req, resp) ->
	imagePath = (req.originalUrl).replace /\/cmpdreg\/structureimage/, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/structureimage' + imagePath
	req.pipe(request(cmpdRegCall)).pipe(resp)

class HTTPResponseError extends Error
	constructor: (response, ...args) ->
		super("HTTP Error Response: #{response.status} #{response.statusText}", ...args)
		this.response = response

class InternalServerError extends Error
	# Throw an internal server error
	constructor: (text, ...args) ->
		super("Internal server error: #{text}", ...args)

checkStatus = (response) ->
	# check for http error
	if response.ok
		return response
	else
		throw new HTTPResponseError response

exports.getMetaLotDepedencies = (req, resp, next) ->
	# We aren't checking acls because the route requires cmpdreg admin already
	response = await exports.fetchMetaLotDependencies(req.params.lotCorpName)
	try
		checkStatus response
		resp.status = 200
		resp.json await response.json()
	catch error
		console.log error
		err =  "Error getting lot"
		resp.statusCode = response.status
		resp.json {error: err}
	

exports.fetchMetaLotDependencies = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/checkDependencies/corpName/' + lotCorpName
	response = await fetch(url, method: 'GET')
	return response


exports.getMetaLotInternal = (lotCorpName, user) ->
	# Get the metalot and check acls
	response = await exports.fetchMetaLot(lotCorpName)
	err = null
	metaLot = null
	statusCode = 200
	try
		checkStatus response
		metaLot = await response.json()
		if Object.keys(metaLot).length == 0 || !metaLot.lot?
			statusCode = 500
			err =  "Could not find lot"
		else
			acls = await exports.getLotAcls(metaLot.lot, user)
			metaLot.lot.acls = acls
			if !acls.getRead()
				statusCode = 403
				err = "You do not have permission to view this lot"
	catch error
		console.log error
		statusCode = 500
		err =  "Error getting lot"
	return [err, metaLot, statusCode]

exports.getMetaLot = (req, resp, next) ->
	[err, metaLot, statusCode] = await exports.getMetaLotInternal req.params.lotCorpName, req.user
	resp.statusCode = statusCode
	if err?
		resp.statusCode = statusCode
		resp.json err
	else
		resp.json metaLot

exports.deleteMetaLot = (req, resp, next) ->
	if !req.user?
		req.user = {
			username: "bob"
			roles: []
		}
	[err, metaLot, statusCode] = await exports.getMetaLotInternal req.params.lotCorpName, req.user
	if err?
		resp.statusCode = statusCode
		resp.json err
	else
		if metaLot.lot.acls.getWrite()
			console.log "Calling delete lot"
			response = await exports.deleteLotByCorpName(metaLot.lot.corpName)
			console.log "Got response from delete lot"
			if response.status == 200
				resp.statusCode = 200
				resp.json {success: true}
			else
				resp.statusCode = 500
				jsonResponse = await response.json()
				resp.json jsonResponse
		else
			resp.statusCode = 403
			resp.json "You do not have permission to delete this lot"

exports.checkMetaLotDepedencies = (req, resp, next) ->
	[err, metaLot, statusCode] = await exports.getMetaLotInternal req.params.lotCorpName, req.user
	if err?
		resp.statusCode = statusCode
		resp.json err
	else
		[err, depdencies, statusCode] = await exports.checkLotDepedencies(metaLot.lot.corpName)
		if err?
			resp.statusCode = statusCode
			resp.json err
		else
			resp.json depdencies
	

exports.fetchMetaLot = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, headers: {'Content-Type': 'application/json'})
	return response;

exports.deleteLotByCorpName = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, method: 'DELETE')
	return response

# Simple class to store acls
class Acls
	constructor: (read, write) ->
		this.read = read
		this.write = write

	getRead: ->
		return this.read

	getWrite: ->
		return this.write

	setRead: (read) ->
		this.read = read

	setWrite: (write) ->
		this.write = write

exports.getLotAcls = (lot, user, allowedProjects) ->
	# Get the acls for the lot
	lotAcls = new Acls(false, false)

	# Check if user is cmpdreg admin
	isCmpdRegAdmin = loginRoutes.checkHasRole(user, config.all.client.roles.cmpdreg.adminRole)
	if isCmpdRegAdmin
		# If the user is a cmpd reg admin, then regardless of the lot's project or other configs they can read and write the lot
		lotAcls.setRead(true)
		lotAcls.setWrite(true)
	else
		# If the user is not a cmpd reg admin, then check if we are restricting the lot by project acls
		if lot.project? && config.all.client.cmpdreg.metaLot.useProjectRolesToRestrictLotDetails
			projectCode = lot.project
			# There are some cases where we want to call this function where we want to pass allowed projects in rather than call out to the service.
			# If the allowedProjects parameter is passed in, then we use that instead of calling the service.
			if !allowedProjects?
				# Get the allowed projects for the user
				[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [user])
				if err?
					throw new InternalServerError "Could not get user's projects" 

			# Check if the lot's project is in the allowed projects
			if _.where(allowedProjects, {code: projectCode}).length > 0
				lotAcls.setRead(true)
			else
				# Default to not allowing read access so no need to set false here, just log it
				console.warn "User #{user.username} does not have access to project #{projectCode} for lot #{lot.corpName}"
		else
			# If we are not restricting the lot by project acls then anyone can read the lot 
			lotAcls.setRead(true)
		
		# If the user is not a cmpd reg admin, then they can only write the lot if they are allowed to read the lot
		if !lotAcls.getRead()
			lotAcls.setWrite(false)
		else
			# If the user is not a cmpd reg admin, then they can only write the lot if disableEditMyLots is false
			# and they are either the chemist or the lot recordedBy
			if config.all.client.cmpdreg.metaLot.disableEditMyLots == false
				canWrite = (lot.chemist? && lot.chemist == user.username) || (lot.recordedBy? && lot.recordedBy == user.username)
				if canWrite
					lotAcls.setWrite(true)
				else
					console.log "User #{user.username} does not have permission to edit lot #{lot.corpName} which is not their lot (recordedBy: #{lot.recordedBy}, chemist: #{lot.chemist})"
					lotAcls.setWrite(false)

	console.log "User #{user.username} lot #{lot.corpName} lot acls #{JSON.stringify(lotAcls)}"
	return lotAcls

exports.fetchMetaLot = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, headers: {'Content-Type': 'application/json'})
	return response;

exports.regSearch = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/regsearches/parent'
	console.log cmpdRegCall
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do registration search'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getMarvinJSLicense = (req, resp) ->
	cmpdRegCall = (config.all.client.service.cmpdReg.persistence.basepath).replace '\/acas', "/"
	licensePath = cmpdRegCall + 'marvin4js-license.cxl'
	console.log licensePath
	req.pipe(request(licensePath)).pipe(resp)

exports.getMultipleFilePicker = (req, resp) ->
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "/" +endOfUrl
	cmpdRegCall = cmpdRegCall.replace /\\/g, "%5C"
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.fileSave = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/filesave'
	req.pipe(request[req.method.toLowerCase()](cmpdRegCall)).pipe(resp)

exports.metaLots = (req, resp) ->
	metaLot = req.body;

	# Verify that lot is included as a metalot with no lot is not allowed
	if metaLot.lot?
		# If the user is in the request then update the lot's modifiedBy field as the persistence service does not
		if req.user?
			metaLot.lot.modifiedBy = req.user.username
		# If this is a saved lot then we need to check the user has permission to edit the lot
		# By checking the saved lots project, the users allowed projects
		if metaLot.lot.id? && metaLot.lot.corpName?
			# Get the saved meta lot as it returns the saved metalot and includes the acls
			[err, savedMetaLot, statusCode] = await exports.getMetaLotInternal metaLot.lot.corpName, req.user
			if err?
				resp.statusCode = statusCode
				resp.end err
				return
			if savedMetaLot.lot.acls.getWrite() == false
				resp.statusCode = 403
				resp.json JSON.stringify {error: "You are not allowed to update to this lot"}
				return
	else
		resp.statusCode = 400
		resp.json JSON.stringify {error: "No lot specified"}
		return
	
	# We got here then then we can save the lot
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			if JSON.stringify(json).indexOf("Duplicate") != -1
				resp.statusCode = 409
			else
				resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			# Need to add acls here if the user just created the lot or updated it we can assume they have both read and write access checked above
			if json.metalot?.lot?
				json.metalot.lot.acls = new Acls(true, true)
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do metalot save'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveSalts = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/salts'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do save salts'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveIsotopes = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/isotopes'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do save isotopes'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.molConvert = (req, resp) ->
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	#	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/api/v1/structureServices/molconvert'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do generic structure service'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.genericStructureService = (req, resp) ->
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'plain/text')
			resp.end json
		else
			console.log 'got ajax error trying to do generic structure service'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.exportSearchResults = (req, resp) ->
	path = require 'path'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/export/searchResults'

	uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	exportedSearchResults = uploadsPath + "exportedSearchResults/"

	serverUtilityFunctions.ensureExists exportedSearchResults, 0o0744, (err) ->
		if err?
			console.log "Can't find or create exportedSearchResults folder: " + exportedSearchResults
			resp.statusCode = 500
			resp.end "Error trying to export search results to sdf: Can't find or create exportedSearchResults folder " + exportedSearchResults
		else
			date = new Date();
			monthNum = date.getMonth()+1;
			currentDate = (date.getFullYear()+'_'+("0" + monthNum).slice(-2)+'_'+("0" + date.getDate()).slice(-2));
			fileName = currentDate+"_"+date.getTime()+"_searchResults.sdf";
			dataToPost = {
				filePath: exportedSearchResults + fileName,
				searchFormResultsDTO: req.body
			}
			request(
				method: 'POST'
				url: cmpdRegCall
				body: dataToPost
				json: true
				timeout: 6000000
			, (error, response, json) =>
				if !error
					resp.setHeader('Content-Type', 'plain/text')
					absFilePath = json.reportFilePath
					console.log absFilePath
					relPath = config.all.server.datafiles.relative_path
					if relPath.substr(-1) is '/'
						relPath = relPath.substring(0, relPath.length-1)
					relFilePath = absFilePath.split(relPath+path.sep)[1]
					console.log relFilePath
					downloadFilePath = config.all.client.datafiles.downloadurl.prefix + relFilePath
					json.reportFilePath = downloadFilePath
					resp.json json
				else
					console.log 'got ajax error trying to export search results to sdf'
					console.log error
					console.log json
					console.log response
					resp.statusCode = 500
					resp.end "Error trying to export search results to sdf: " + error;

			)

exports.validateParent = (req, resp) ->
	console.log "exports.validateParent"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/validateParent'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to validate parent'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to validate parent: " + error;
	)

exports.updateParent = (req, resp) ->
	console.log "exports.updateParent"
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username	
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update parent'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)
	
	
exports.updateLotMetadata = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in update lot metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/updateLot/metadata'
	console.log cmpdRegCall
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update Lot metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update lot: " + error;
	)
		
exports.updateLotsMetadata = (req, resp) ->
	console.log 'in update lot array metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/updateLot/metadata/jsonArray'
	console.log cmpdRegCall
	if req.user?
		req.body.map((lot) ->
			if !lot.modifiedBy?
				lot.modifiedBy = req.user.username
		)
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update Lot array metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update lot: " + error;
	)

exports.updateParentMetadata = (req, resp) ->
	console.log 'in update parent metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent/metadata'
	console.log cmpdRegCall
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update parent metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)
	
exports.updateParentsMetadata = (req, resp) ->
	console.log 'in update parent array metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent/metadata/jsonArray'
	console.log cmpdRegCall

	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update parent array metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)

exports.reparentLot = (req, resp) ->
	console.log 'in reparent lot'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/reparentLot'
	console.log cmpdRegCall

	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to reparent lot'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to reparent lot: " + error;
	)

exports.reparentLots = (req, resp) ->
	console.log 'in reparent lot'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/reparentLot/jsonArray'
	console.log cmpdRegCall

	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to reparent lot array'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to reparent lot array: " + error;
	)

exports.ketcherKnocknock = (req, resp) ->
	resp.end "You are welcome!"

exports.ketcherConvertSmiles = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/molconvert"
		request = require 'request'
		data =
			structure: req.query.smiles
			inputFormat: 'smiles'
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json.structure
			else
				console.log 'got ajax error trying to convert smiles to MOL'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "Smiles to MOL conversion failed"
		)

exports.ketcherLayout = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/clean"
		request = require 'request'
		data =
			structure: req.body.moldata
			parameters:
				dim: 2
				opts: ""
		console.log data
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json
			else
				console.log 'got ajax error trying to clean MOL'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "Cleaning MOL conversion failed"
		)

exports.ketcherCalculateCip = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/cipStereoInfo"
		request = require 'request'
		data =
			structure: req.body.moldata
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			console.log response
			console.log json
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json
			else
				console.log 'got ajax error trying to calculate CIP stereo descriptors'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "CIP stereo descriptor calculation failed"
		)

exports.getAuthorizedPrefixes = (req, resp) ->
	labelSeqRoutes = require './ACASLabelSequencesRoutes.js'
	req.query =
		labelTypeAndKind: 'id_corpName'
		thingTypeAndKind: 'parent_compound'
	labelSeqRoutes.getAuthorizedLabelSequencesInternal req, (statusCode, json) ->
		codeTables = []
		_.each json, (labelSeq) ->
			codeTable =
				id: labelSeq.id
				name: labelSeq.labelPrefix
				code: "#{labelSeq.labelPrefix}_#{labelSeq.labelTypeAndKind}_#{labelSeq.thingTypeAndKind}"
				labelTypeAndKind: labelSeq.labelTypeAndKind
				thingTypeAndKind: labelSeq.thingTypeAndKind
			codeTables.push codeTable
		resp.json codeTables

exports.allowCmpdRegistration = (req, resp) ->
	#for checking if standardization needed or if user wants to enable/disable cmpd registration
	if req.query.userOverride?
		#if req.query.userOverride = true, then always allow cmpd reg
		#if req.query.userOverride = false, then always disable cmpd reg
		allowCmpdRegistration = req.query.userOverride == "true"
		if allowCmpdRegistration
			message = "Compounds can be registerd"
		else
			message = "Compounds can not be registered at this time. Please contact an administrator for help."
		response =
			allowCmpdRegistration: allowCmpdRegistration
			message: message
		resp.json response
	else
		#check if needs standardization
		standardizationRoutes = require './StandardizationRoutes.js'
		standardizationRoutes.getStandardizationSettingsInternal (getStandardizationSettingsResp, statusCode) =>
			if statusCode is 500
				console.log "error getting current standardization settings"
				resp.statusCode = statusCode
				response =
					allowCmpdRegistration: false
					message: "Compounds can not be registered at this time due to an error getting current standardization settings. Please contact an administrator for help."
				resp.json response
			else
				allowCmpdRegistration = !getStandardizationSettingsResp.needsStandardization
				if allowCmpdRegistration
					message = "Compounds can be registered"
				else
					message = "Compounds can not be registered at this time because the registered compounds require standardization."
				response =
					allowCmpdRegistration: allowCmpdRegistration
					message: message
				resp.json response