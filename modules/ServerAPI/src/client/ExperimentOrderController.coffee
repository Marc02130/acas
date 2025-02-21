class ExperimentOrderController extends BaseEntityController
  template: _.template($("#ExperimentOrderView").html())
  
  events: ->
    _.extend super(),
      "change .bv_protocol": "handleProtocolChanged"
      "change .bv_projectCode": "handleProjectChanged"
      "change .bv_expectedCompletionDate": "handleCompletionDateChanged"
      "change .bv_priority": "handlePriorityChanged"

  initialize: ->
    console.log "ExperimentOrderController initializing"
    console.log "Template found:", $("#ExperimentOrderView").length > 0
    if not @model?
      @model = new ExperimentOrder()
    super()
    @render()
    @setupProtocolSelect()
    @setupProjectSelect()
    @setupStatusSelect()

  render: =>
    $(@el).empty()
    $(@el).html @template()
    @setupProtocolSelect()
    @setupProjectSelect()
    @setupStatusSelect()
    @

  setupProtocolSelect: ->
    @protocolList = new PickListList()
    @protocolList.url = "/api/protocols"
    @protocolListController = new PickListSelectController
      el: @$('.bv_protocol')
      collection: @protocolList
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Protocol"
      selectedCode: if @model.getProtocol()? then @model.getProtocol().get('codeName') else null

  handleProtocolChanged: ->
    protocolCode = @protocolListController.getSelectedCode()
    if protocolCode != "unassigned"
      $.ajax
        type: 'GET'
        url: "/api/protocols/codename/#{protocolCode}"
        success: (protocol) =>
          @model.set 'protocol', protocol
    else
      @model.set 'protocol', null

  setupStatusSelect: ->
    @statusList = new PickListList()
    @statusList.url = "/api/codetables/experiment order/status"
    @statusListController = new PickListSelectController
      el: @$('.bv_status')
      collection: @statusList
      selectedCode: @model.getStatus().get('codeValue')

  setupProjectSelect: ->
    @projectList = new PickListList()
    @projectList.url = "/api/projects"
    @projectListController = new PickListSelectController
      el: @$('.bv_projectCode')
      collection: @projectList
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Project"
      selectedCode: @model.getProjectCode().get('codeValue')

  # Similar handlers for project, completion date, priority 