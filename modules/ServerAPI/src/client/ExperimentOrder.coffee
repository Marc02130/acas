class ExperimentOrder extends BaseEntity
  urlRoot: "/api/v1/experimentorder"

  initialize: ->
    console.log "ExperimentOrder model initializing" 
    @set subclass: "experimentorder"
    super()

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

    if errors.length > 0
      return errors
    else
      return null 