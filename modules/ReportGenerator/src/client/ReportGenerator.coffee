class ReportGeneratorController extends Backbone.View
  template: _.template($("#ReportGeneratorView").html())
  
  events:
    "click .bv_generateReport": "handleGenerateReport"
    "change .bv_experimentSelect": "handleExperimentSelect"
    "change .bv_sectionSelect": "handleSectionSelect"
  
  initialize: ->
    @experiments = []
    @selectedExperiments = []
    @selectedSections = []
    @loadExperiments()
    
  loadExperiments: ->
    $.ajax
      type: 'GET'
      url: "/api/experiments"
      success: (experiments) =>
        @experiments = experiments
        @render()
      error: (error) ->
        alert "Error loading experiments: #{error}"
  
  render: ->
    $(@el).html @template()
    @setupExperimentSelect()
    @setupSectionSelect()
    @
    
  setupExperimentSelect: ->
    @$(".bv_experimentSelect").select2
      placeholder: "Select experiments"
      multiple: true
      data: @experiments.map (exp) -> 
        id: exp.id
        text: exp.codeName
        
  setupSectionSelect: ->
    @$(".bv_sectionSelect").select2
      placeholder: "Select report sections"
      multiple: true
      data: [
        {id: 'introduction', text: 'Introduction'},
        {id: 'methods', text: 'Methods'},
        {id: 'results', text: 'Results'}, 
        {id: 'discussion', text: 'Discussion'}
      ]
      
  handleExperimentSelect: (e) ->
    @selectedExperiments = $(e.target).val()
    
  handleSectionSelect: (e) ->
    @selectedSections = $(e.target).val()
    
  handleGenerateReport: ->
    unless @selectedExperiments.length > 0
      alert "Please select at least one experiment"
      return
      
    unless @selectedSections.length > 0  
      alert "Please select at least one report section"
      return
      
    requestData =
      experimentIds: @selectedExperiments
      sections: @selectedSections
      customNotes: @$('.bv_customNotes').val()
      
    $.ajax
      type: 'POST'
      url: "/api/v1/reports/generate"
      data: JSON.stringify(requestData)
      contentType: 'application/json'
      success: (response) =>
        @$('.bv_reportOutput').val(response)
      error: (error) ->
        alert "Error generating report: #{error.responseText}" 