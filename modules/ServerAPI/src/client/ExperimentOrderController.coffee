class ExperimentOrderController extends BaseEntityController
  template: _.template($("#ExperimentOrderView").html())
  
  events: ->
    _.extend super(),
      "change .bv_protocol": "handleProtocolChanged"
      "change .bv_projectCode": "handleProjectChanged"
      "change .bv_expectedCompletionDate": "handleCompletionDateChanged"
      "change .bv_priority": "handlePriorityChanged"
      "keyup .bv_entityName": "handleNameChanged"
      "change .bv_sampleCheckbox": "handleSampleSelectionChanged"

  initialize: (options) ->
    console.log "ExperimentOrderController initializing"
    console.log "Template found:", $("#ExperimentOrderView").length > 0
    
    options = options || {}
    options.readOnly = false
    options.moduleName = "ExperimentOrder" 
    options.modelClass = ExperimentOrder
    
    super(options)
    
    if not @model?
      @model = new ExperimentOrder()
    
    @errorOwnerName = 'ExperimentOrderController'
    @setBindings()
    
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
    @protocolList.url = "/api/protocolCodes/default"
    @protocolListController = new PickListSelectController
      el: @$('.bv_protocol')
      collection: @protocolList
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Protocol"
      selectedCode: if @model.getProtocol()? then @model.getProtocol().get('codeName') else null
    @protocolList.fetch()

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

  handleNameChanged: =>
    labelList = @model.get('lsLabels')
    if not labelList?
      labelList = new LabelList()
      @model.set 'lsLabels', labelList
    
    # Find existing name label or create new one
    nameLabel = labelList.findWhere(labelKind: "name") || new Label
      labelKind: "name" 
      preferred: true
      recordedBy: @model.get('recordedBy')
      recordedDate: new Date().getTime()

    # Update label text
    nameLabel.set
      labelText: @$('.bv_entityName').val()
      recordedBy: @model.get('recordedBy')
      recordedDate: new Date().getTime()

    # Add to list if new
    if not labelList.findWhere(labelKind: "name")
      labelList.add nameLabel

  # Similar handlers for project, completion date, priority 

  completeInitialization: =>
    if not @model?
      @model = new ExperimentOrder()
    
    @errorOwnerName = 'ExperimentOrderController'
    @setBindings()
    
    @render()
    @setupProtocolSelect()
    @setupProjectSelect()
    @setupStatusSelect()

  handleConfirmClearClicked: =>
    @$('.bv_confirmClearEntity').modal('hide')
    @model = new ExperimentOrder()
    @render()
    @trigger 'amClean'

  handleCancelClicked: =>
    if @model?.isNew()
      @trigger 'clear'
    else
      @trigger 'reinitialize'
    @trigger 'amClean'

  prepareToSaveAttachedFiles: =>
    if @attachFileListController?
      @attachFileListController.collection.each (file) =>
        unless file.get('fileValue')?
          @trigger 'saveFailed'
          return false
      true
    else
      true

  setupAttachFileListController: ->
    if @attachFileListController?
      @attachFileListController.render()
    else
      @attachFileListController = new AttachFileListController
        el: @$('.bv_attachFileList')
        collection: new AttachFileList()
        firstOptionName: "Select Method"
        allowedFileTypes: ['xls', 'xlsx', 'csv', 'sdf', 'mol', 'cdxml', 'cdx']

  handleProjectChanged: ->
    projectCode = @projectListController.getSelectedCode()
    if projectCode != "unassigned"
      # Load samples for selected project
      $.ajax
        type: 'GET'
        url: "/api/projects/#{projectCode}/samples"
        success: (samples) =>
          @renderSampleList(samples)
    else
      @$('.bv_sampleListBody').empty()

  renderSampleList: (samples) ->
    @$('.bv_sampleListBody').empty()
    for sample in samples
      row = $("<tr>")
      row.append $("<td>").append $("<input>")
        .addClass("bv_sampleCheckbox")
        .attr("type", "checkbox")
        .attr("data-sampleid", sample.id)
      row.append $("<td>").text(sample.id)
      row.append $("<td>").text(sample.name)
      row.append $("<td>").text(sample.description)
      @$('.bv_sampleListBody').append row

  handleSampleSelectionChanged: (e) ->
    checkbox = $(e.target)
    sampleId = checkbox.data('sampleid')
    
    if checkbox.is(':checked')
      # Load and add sample
      $.ajax
        type: 'GET'
        url: "/api/samples/#{sampleId}"
        success: (sample) =>
          @model.addSample(sample)
    else
      # Remove sample
      @model.removeSample(sampleId) 