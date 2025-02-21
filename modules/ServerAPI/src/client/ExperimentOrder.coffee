class ExperimentOrder extends BaseEntity
  urlRoot: "/api/v1/experimentorder"

  defaults: ->
    defaults = super()
    _.extend defaults,
      type: "default"
      kind: "default"
      subclass: "experimentorder"
      recordedBy: window.AppLaunchParams.loginUser.username
      recordedDate: new Date().getTime()
      shortDescription: " "
      lsLabels: new LabelList()
      lsStates: new StateList()
      lsTags: new Backbone.Collection()
      fileList: new AttachFileList()
      samples: new Backbone.Collection()
    return defaults

  initialize: ->
    console.log "ExperimentOrder model initializing"
    super()
    
    # Initialize labels after super() call
    @get('lsLabels').add new Label
      labelKind: "name"
      labelText: " "
      preferred: true
      recordedBy: @get('recordedBy')
      recordedDate: @get('recordedDate')

  # Get protocol reference
  getProtocol: ->
    @get('protocol')

  # Get project code value
  getProjectCode: ->
    projectCodeValue = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment order metadata", "codeValue", "project"
    if projectCodeValue.get('codeValue') is undefined or projectCodeValue.get('codeValue') is ""
      projectCodeValue.set
        codeValue: "unassigned"
        codeType: "project"
        codeKind: "biology"
        codeOrigin: "ACAS DDICT"
    projectCodeValue

  # Get status value  
  getStatus: ->
    statusValue = @get('lsStates').getOrCreateValueByTypeAndKind "metadata", "experiment order metadata", "codeValue", "experiment order status"
    if statusValue.get('codeValue') is undefined or statusValue.get('codeValue') is ""
      statusValue.set
        codeValue: "created"
        codeType: "experiment order"
        codeKind: "status"
        codeOrigin: "ACAS DDICT"
    statusValue

  getSamples: ->
    @get('samples')

  addSample: (sample) ->
    samples = @getSamples()
    samples.add sample unless samples.get(sample.id)?

  removeSample: (sample) ->
    @getSamples().remove sample

  validate: (attrs) ->
    errors = []
    
    # Required fields validation
    if not @getProtocol()?
      errors.push
        attribute: 'protocol'
        message: "Protocol must be selected"
        
    if @getProjectCode().get('codeValue') is "unassigned"
      errors.push
        attribute: 'projectCode'
        message: "Project must be selected"

    if @getSamples().length == 0
      errors.push
        attribute: 'samples'
        message: "At least one sample must be selected"

    if errors.length > 0
      return errors
    else
      return null 