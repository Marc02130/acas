class ReportGeneratorController extends Backbone.View
  template: _.template($("#ReportGeneratorMainView").html())
  
  events:
    "click .bv_generateReport": "handleGenerateReport"
    "change input[name=reportType]": "handleReportTypeChange"
    "change .bv_experimentSelect": "handleExperimentSelect"
    "change .bv_projectSelect": "handleProjectSelect"
    "change .bv_startDate": "validateDateRange"
    "change .bv_endDate": "validateDateRange"
    "change .bv_sectionSelect": "handleSectionSelect"
  
  initialize: ->
    # Only initialize if we're on report generator page
    if window.location.hash.indexOf('report_generator') > -1
      @experiments = []
      @projects = []
      @selectedExperiments = []
      @selectedSections = []
      @loadProjects()
      @loadExperiments()
    
  loadProjects: ->
    $.ajax
      type: 'GET'
      url: "/api/v1/projects"
      success: (projects) =>
        @projects = projects
        @setupProjectSelect()
      error: (error) ->
        alert "Error loading projects: #{error}"
        
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
    @setupProjectSelect()
    @setupExperimentSelect()
    @setupSectionSelect()
    @handleReportTypeChange()
    @

  setupProjectSelect: ->
    @$(".bv_projectSelect").select2
      placeholder: "Select project"
      data: @projects.map (proj) -> 
        id: proj.id
        text: proj.name

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

  handleReportTypeChange: ->
    reportType = @$('input[name=reportType]:checked').val()
    if reportType == 'project'
      @$('.bv_projectSection').show()
      @$('.bv_experimentsSection').hide()
      @$('.bv_experimentSelect').val(null).trigger('change')
    else
      @$('.bv_projectSection').hide()
      @$('.bv_experimentsSection').show()
      @$('.bv_projectSelect').val(null).trigger('change')
      @$('.bv_startDate').val('')
      @$('.bv_endDate').val('')

  validateDateRange: ->
    startDate = @$('.bv_startDate').val()
    endDate = @$('.bv_endDate').val()
    if startDate and endDate and startDate > endDate
      alert "Start date must be before end date"
      @$('.bv_startDate').val('')
      @$('.bv_endDate').val('')
      
  handleProjectSelect: ->
    projectId = @$('.bv_projectSelect').val()
    # if projectId
      # Could load project-specific experiments here if needed
      
  handleExperimentSelect: (e) ->
    @selectedExperiments = $(e.target).val()
    
  handleSectionSelect: (e) ->
    @selectedSections = $(e.target).val()
    
  handleGenerateReport: ->
    reportType = @$('input[name=reportType]:checked').val()
    
    if reportType == 'project'
      unless @$('.bv_projectSelect').val()
        alert "Please select a project"
        return
      unless @$('.bv_startDate').val() and @$('.bv_endDate').val()
        alert "Please select both start and end dates"
        return
    else
      unless @selectedExperiments?.length > 0
        alert "Please select at least one experiment"
        return
      
    unless @selectedSections?.length > 0  
      alert "Please select at least one report section"
      return
      
    requestData =
      reportType: reportType
      projectId: if reportType == 'project' then @$('.bv_projectSelect').val() else null
      startDate: if reportType == 'project' then @$('.bv_startDate').val() else null
      endDate: if reportType == 'project' then @$('.bv_endDate').val() else null
      experimentIds: if reportType == 'experiments' then @selectedExperiments else null
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

# Export only this controller
window.ReportGeneratorController = ReportGeneratorController
