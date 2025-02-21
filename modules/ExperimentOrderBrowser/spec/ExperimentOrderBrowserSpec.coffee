beforeEach ->
  @fixture = $.clone($("#fixture").get(0))

afterEach ->
  $("#fixture").remove()
  $("body").append $(@fixture)

describe "ExperimentOrder Browser module testing", ->
  describe "ExperimentOrder Search Model controller", ->
    beforeEach ->
      @eosm = new ExperimentOrderSearch()
    describe "Basic existence tests", ->
      it "should be defined", ->
        expect(@eosm).toBeDefined()
      it "should have defaults", ->
        expect(@eosm.get('experimentOrderCode')).toBeNull()

  describe "ExperimentOrder Simple Search Controller", ->
    describe "when instantiated", ->
      beforeEach ->
        @eossc = new ExperimentOrderSimpleSearchController
          model: new ExperimentOrderSearch()
          el: $('#fixture')
        @eossc.render()
      describe "basic existence tests", ->
        it "should exist", ->
          expect(@eossc).toBeDefined()
        it "should load a template", ->
          expect(@eossc.$('.bv_experimentOrderSearchTerm').length).toEqual 1

  describe "ExperimentOrderBrowserController tests", ->
    beforeEach ->
      @eobc = new ExperimentOrderBrowserController
        el: @fixture
      @eobc.render()
    describe "Basic existence and rendering tests", ->
      it "should be defined", ->
        expect(ExperimentOrderBrowserController).toBeDefined()
      it "should have a search controller div", ->
        expect(@eobc.$('.bv_experimentOrderSearchController').length).toEqual 1
    describe "Startup", ->
      it "should initialize the search controller", ->
        expect(@eobc.$('.bv_experimentOrderSearchTerm').length).toEqual 1
        expect(@eobc.searchController).toBeDefined() 