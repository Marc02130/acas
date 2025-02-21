((exports) ->
  exports.typeKindList =
    experimentordertypes: [
      typeName: "default"
    ]

    experimentorderkinds: [
      typeName: "default"
      kindName: "default"
    ]

    statetypes: [
      typeName: "metadata"
    ]

    statekinds: [
      typeName: "metadata" 
      kindName: "experiment order metadata"
    ]

    valuetypes: [
      typeName: "codeValue"
    ,
      typeName: "dateValue"
    ,
      typeName: "numericValue"
    ]

    valuekinds: [
      typeName: "codeValue"
      kindName: "experiment order status"
    ,
      typeName: "codeValue" 
      kindName: "project"
    ,
      typeName: "dateValue"
      kindName: "expected completion date"
    ,
      typeName: "numericValue"
      kindName: "priority"
    ]

    codetables: [
      codeType: "experiment order"
      codeKind: "status"
      codeOrigin: "ACAS DDICT"
      code: "created"
      name: "Created"
      ignored: false
    ,
      codeType: "experiment order"
      codeKind: "status" 
      codeOrigin: "ACAS DDICT"
      code: "in progress"
      name: "In Progress"
      ignored: false
    ,
      codeType: "experiment order"
      codeKind: "status"
      codeOrigin: "ACAS DDICT"
      code: "complete"
      name: "Complete" 
      ignored: false
    ]

) (if (typeof process is "undefined" or not process.versions) then window.experimentOrderConfJSON = window.experimentOrderConfJSON or {} else exports) 