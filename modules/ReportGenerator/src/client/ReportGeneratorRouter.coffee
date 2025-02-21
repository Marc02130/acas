class ReportGeneratorRouter extends Backbone.Router
  routes:
    "reportGenerator": "reportGenerator"
    
  initialize: ->
    @bind 'route', @_trackPageview
    
  reportGenerator: ->
    if !@reportGeneratorController?
      @reportGeneratorController = new ReportGeneratorController
        el: $('#moduleContainer')
    @reportGeneratorController.render()
    
  _trackPageview: ->
    url = Backbone.history.getFragment()
    window._gaq?.push(['_trackPageview', "/#{url}"]) 