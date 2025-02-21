((exports) ->
  exports.typeKindList =
    thingtypes: []
    thingkinds: []
    statetypes: []
    statekinds: []
    valuetypes: []
    valuekinds: []
    labeltypes: []
    labelkinds: []
    roletypes: []
    rolekinds: []
    lsroles: []
    ddicttypes: []
    ddictkinds: []
    codetables: []

  exports.reportGeneratorConfig =
    autoInit: false
    autoLaunch: false
    sections: [
      {id: 'introduction', name: 'Introduction'}
      {id: 'methods', name: 'Methods'} 
      {id: 'results', name: 'Results'}
      {id: 'discussion', name: 'Discussion'}
    ]
    
  exports.getReportGeneratorConfig = ->
    exports.reportGeneratorConfig

) (if typeof(process) is "undefined" or not process.versions then window.reportGeneratorConfig = window.reportGeneratorConfig or {} else exports) 