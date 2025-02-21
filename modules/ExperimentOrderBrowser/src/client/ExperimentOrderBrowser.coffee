class ExperimentOrderSearch extends Backbone.Model
  defaults:
    experimentOrderCode: null

class ExperimentOrderSimpleSearchController extends AbstractFormController
  template: _.template($("#ExperimentOrderSimpleSearchView").html())
  genericSearchUrl: "/api/v1/experimentorder/search/"

  events:
    'keyup .bv_experimentOrderSearchTerm': 'updateExperimentOrderSearchTerm'
    'click .bv_doSearch': 'handleDoSearchClicked'

  render: =>
    $(@el).empty()
    $(@el).html @template()

  updateExperimentOrderSearchTerm: (e) =>
    ENTER_KEY = 13
    searchTerm = $.trim(@$(".bv_experimentOrderSearchTerm").val())
    if searchTerm isnt ""
      @$(".bv_doSearch").attr("disabled", false)
      if e.keyCode is ENTER_KEY
        $(':focus').blur()
        @handleDoSearchClicked()
    else
      @$(".bv_doSearch").attr("disabled", true)

  handleDoSearchClicked: =>
    $(".bv_experimentOrderTableController").addClass "hide"
    $(".bv_errorOccurredPerformingSearch").addClass "hide"
    searchTerm = $.trim(@$(".bv_experimentOrderSearchTerm").val())
    $(".bv_searchTerm").val ""
    if searchTerm isnt ""
      $(".bv_noMatchesFoundMessage").addClass "hide"
      $(".bv_searchInstructions").addClass "hide"
      $(".bv_searchStatusIndicator").removeClass "hide"
      $(".bv_searchingMessage").removeClass "hide"
      $(".bv_searchTerm").html _.escape(searchTerm)
      @doSearch searchTerm

  doSearch: (searchTerm) =>
    @trigger 'find'
    @$(".bv_experimentOrderSearchTerm").attr "disabled", true
    @$(".bv_doSearch").attr "disabled", true

    unless searchTerm is ""
      $.ajax
        type: 'GET'
        url: @genericSearchUrl + searchTerm
        dataType: "json"
        success: (orders) =>
          @trigger "searchReturned", orders
        error: (result) =>
          @trigger "searchReturned", null
        complete: =>
          @$(".bv_experimentOrderSearchTerm").attr "disabled", false
          @$(".bv_doSearch").attr "disabled", false

class ExperimentOrderRowController extends Backbone.View
  tagName: 'tr'
  className: 'dataTableRow'
  
  events:
    "click": "handleClick"

  handleClick: =>
    @trigger "gotClick", @model
    $(@el).closest("table").find("tr").removeClass "info"
    $(@el).addClass "info"

  initialize: ->
    @template = _.template($("#ExperimentOrderRowView").html())

  render: =>
    toDisplay =
      orderCode: @model.get('trackingId')
      status: @model.get('status')
      submittedBy: @model.get('submittedBy')
      submittedDate: UtilityFunctions::convertMSToYMDDate(@model.get('submittedDate'))
      
    $(@el).html(@template(toDisplay))
    @

class ExperimentOrderTableController extends Backbone.View
  initialize: ->
    @template = _.template($("#ExperimentOrderTableView").html())

  selectedRowChanged: (row) =>
    @trigger "selectedRowUpdated", row

  render: =>
    $(@el).html @template()
    if @collection.models.length is 0
      @$(".bv_noMatchesFoundMessage").removeClass "hide"
    else
      @$(".bv_noMatchesFoundMessage").addClass "hide"
      @collection.each (order) =>
        prsc = new ExperimentOrderRowController
          model: order
        prsc.on "gotClick", @selectedRowChanged
        @$("tbody").append prsc.render().el
      @$("table").dataTable oLanguage:
        sSearch: "Filter results: "
    @

class ExperimentOrderBrowserController extends Backbone.View
  template: _.template($("#ExperimentOrderBrowserView").html())

  initialize: ->
    $(@el).html @template()
    @searchController = new ExperimentOrderSimpleSearchController
      model: new ExperimentOrderSearch()
      el: @$('.bv_experimentOrderSearchController')
    @searchController.render()
    @searchController.on "searchReturned", @setupExperimentOrderTable

  setupExperimentOrderTable: (orders) =>
    @destroyExperimentOrderTable()
    $(".bv_searchingMessage").addClass "hide"
    if orders is null
      @$(".bv_errorOccurredPerformingSearch").removeClass "hide"
    else if orders.length is 0
      @$(".bv_noMatchesFoundMessage").removeClass "hide"
      @$(".bv_experimentOrderTableController").html ""
    else
      $(".bv_searchStatusIndicator").addClass "hide"
      @$(".bv_experimentOrderTableController").removeClass "hide"
      @experimentOrderTable = new ExperimentOrderTableController
        collection: new ExperimentOrderList orders
        el: @$(".bv_experimentOrderTableController")
      @experimentOrderTable.render()

  destroyExperimentOrderTable: =>
    if @experimentOrderTable?
      @experimentOrderTable.remove()
    $(".bv_experimentOrderTableController").addClass("hide")
    $(".bv_noMatchesFoundMessage").addClass("hide")

  render: =>
    @
 