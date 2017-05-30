class window.DeviceCollection extends PickListList

deviceStubs = [
	{
		code: 'balanceIsIdle',
		name: 'Balance Is Idle'
		url: 'http://192.168.0.193:1337/'
	}, {
		code: 'balanceNotConnected',
		name: 'Balance Not Connected'
		url: 'http://192.168.0.193:1337/'
	}, {
		code: 'balanceNotAvailable',
		name: 'Balance Not Available'
		url: 'http://192.168.0.193:1337/'
	}

]


class window.RealtimeDeviceConnectionController extends Backbone.View
	template: _.template($("#RealtimeDeviceConnectionView").html())

	events:
		"click .bv_disconnect": "handleDisconnectClicked"
		"click .bv_bootCurrentUserOffDevice": "handleBootCurrentUserOffDevice"
		"click .bv_disconnectedByAnotherUserDismiss": "hideDisconnectedModal"
		"click .bv_kickUserOff": "displayInUseModal"
		"click .bv_deviceInUseDismiss": "dismissDeviceInUse"
		"change .bv_deviceSelectContainer": "handleDeviceSelectChange"
		"click .bv_dismissDisconnectMessage": "handleDismissDisconnectMessage"

	initialize: ->
		@isConnectedToDevice = false
		@testMode = @options.testMode
		@deviceCollection = new DeviceCollection(deviceStubs)
		unless @testMode
			@setupSocketEventHandlers()


	setupSocketEventHandlers: =>
		@socket = io('/deviceChannel')
		@socket.on('connect', @handleDeviceSelectChange)
		@socket.on('connect_error', @handleConnectError)
		@socket.on('youShouldTryConnecting', @connectToDevice)
		@socket.on('disconnectedFromDevice', @disconnectedFromDevice)
		@socket.on('alertAllDisconnectedFromDevice', @alertAllDisconnectedFromDevice)
		@socket.on('disconnectedByAnotherUser', @disconnectedByAnotherUser)

	connectToDevice: =>
		selectedDevice = @devicePickList.getSelectedModel()
		@$(".bv_connecting").removeClass "hide"
		@socket.emit('connectToDevice', {deviceName: selectedDevice.get('code'), deviceUrl: selectedDevice.get('url'), userName: AppLaunchParams.loginUserName}, @connectToDeviceCallback)

	connectToDeviceCallback: (err, data) =>
		console.log "err", err
		console.log "data", data
		if err
			@setStateToDisconnected()
			console.log "err.status", err.status
			switch err.status
				when "not_available"
					@clientIdOfConnectedUser = err.clientId
					@userNameOfConnectedUser = err.userName
					@displayInUseMessage()
				when "device_not_connected"
					@displayStatusMessage(".bv_deviceNotConnected")
				when "device_server_offline"
					@displayStatusMessage(".bv_deviceServerOffline")
				when "in_use"
					@displayStatusMessage(".bv_deviceServerInUse")

		else
			@setStateToConnected()

		@$(".bv_connectionStatusAlert").addClass "hide"

	displayStatusMessage: (messageSelector) =>
		@resetStatusMessages()

		@$(messageSelector).removeClass "hide"

	resetStatusMessages: =>
		@$(".bv_connecting").addClass "hide"
		@$(".bv_connected").addClass "hide"
		@$(".bv_disconnected").addClass "hide"
		@$(".bv_deviceNotConnected").addClass "hide"
		@$(".bv_deviceServerInUse").addClass "hide"
		@$(".bv_deviceServerOffline").addClass "hide"
		@$(".bv_deviceServerInUseButIdle").addClass "hide"
		@handleDismissDisconnectMessage()

	displayInUseMessage: =>
		@resetStatusMessages()
		@displayStatusMessage(".bv_deviceServerInUseButIdle")
		@$(".bv_deviceUsedBy").html @userNameOfConnectedUser


	handleDeviceSelectChange: =>
		deviceName = @devicePickList.getSelectedCode()
		unless deviceName is ""
			@connectToDevice()

	handleBootCurrentUserOffDevice: =>
		@socket.emit('bootUser', {userToBootClientId: @clientIdOfConnectedUser, userNameToAdd: AppLaunchParams.loginUserName}, (err, data) =>
			@setStateToConnected()
			@$(".bv_deviceInUse").modal "hide"
		)

	handleDismissDisconnectMessage: =>
		@$(".bv_disconnectedByAUserMessage").hide()

	displayInUseModal: =>
		@$(".bv_alreadyConnectedUserName").html @userNameOfConnectedUser
		@$(".bv_deviceInUse").modal "show"

	handleConnectError: =>
		@$(".bv_connectionStatusAlert").removeClass "hide"

	getDeviceName: =>
		return @$(".bv_deviceSelect").val()

	disableDisconnectButton: =>
		@$(".bv_disconnect").addClass "hide"
#@disableButton(".bv_disconnect")

	enableDisconnectButton: =>
#@enableButton(".bv_disconnect")
		@$(".bv_disconnect").removeClass "hide"

	disableButton: (cssSelector) =>
		@$(cssSelector).prop "disabled", true
		@$(cssSelector).addClass "disabled"

	enableButton: (cssSelector) =>
		@$(cssSelector).prop "disabled", false
		@$(cssSelector).removeClass "disabled"

	handleDisconnectClicked: (e) =>
		e.preventDefault()
		console.log "handleDisconnectClicked"
		@socket.emit('disconnected')

	setStateToDisconnected: =>
		@disableDisconnectButton()
		@isConnectedToDevice = false
		@$(".bv_connecting").addClass "hide"
		@$(".bv_connected").addClass "hide"
		@$(".bv_disconnected").removeClass "hide"

	setStateToConnected: =>
		@enableDisconnectButton()
		@isConnectedToDevice = true
		@displayStatusMessage ".bv_connected"

	disconnectedFromDevice: =>
		console.log "you've been successfully disconnected"
		@setStateToDisconnected()

	alertAllDisconnectedFromDevice: =>
		console.log "alertAllDisconnectedFromDevice"
		console.log "@isConnectedToDevice", @isConnectedToDevice
		unless @isConnectedToDevice
			@connectToDevice()

	disconnectedByAnotherUser: (disconnectingUserName) =>
		@displayDisconnectedModal(disconnectingUserName)
		@setStateToDisconnected()

	displayDisconnectedModal: (disconnectingUserName) =>
		@$(".bv_disconnectingUserName").html disconnectingUserName
		@$(".bv_disconnectedByAUserMessage").show "slide", {direction: "right"}
#@$(".bv_disconnectedByAnotherUser").modal "show"

	dismissDeviceInUse: =>
		@$(".bv_deviceInUse").modal "hide"

	hideDisconnectedModal: =>
		@$(".bv_disconnectedByAnotherUser").modal "hide"

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@devicePickList = new PickListSelectController({collection: @deviceCollection, autoFetch: false, el: @$(".bv_deviceSelectContainer")})
		@renderSubform()

		@

	renderSubform: =>

		@$(".bv_subformContainer").html @subFormTemplate()
		@completeInitialization()

		@