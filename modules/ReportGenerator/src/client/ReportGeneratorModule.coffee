class ReportGeneratorModule extends AbstractModule
  controller: ReportGeneratorController

  init: ->
    # Only initialize if we're explicitly on report generator page
    if window.location.hash.indexOf('report_generator') > -1
      @controller = new @controller
        el: $('#moduleContainer')
    
  fetch: ->
    # Only fetch if controller exists
    @controller?.fetch()

# Export only this module
window.ReportGeneratorModule = ReportGeneratorModule
