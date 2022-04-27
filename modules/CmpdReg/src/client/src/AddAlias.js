// Generated by CoffeeScript 1.9.3
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.AliasesController = (function(superClass) {
    extend(AliasesController, superClass);

    function AliasesController() {
      this.render = bind(this.render, this);
      this.completeInitialization = bind(this.completeInitialization, this);
      this.setToReadOnly = bind(this.setToReadOnly, this);
      this.setToEditMode = bind(this.setToEditMode, this);
      this.handleEditAliasesClick = bind(this.handleEditAliasesClick, this);
      return AliasesController.__super__.constructor.apply(this, arguments);
    }

    AliasesController.prototype.events = {
      "click .bv_editAliases": "handleEditAliasesClick"
    };

    AliasesController.prototype.initialize = function() {
      if (this.options.collection != null) {
        this.collection = this.options.collection;
      } else {
        this.collection = new AliasCollection();
      }
      if (!(this.collection instanceof Backbone.Collection)) {
        this.collection = new AliasCollection(this.collection);
      }
      this.readMode = false;
      if (this.options.readMode != null) {
        this.readMode = this.options.readMode;
      }
      this.step = null;
      if (this.options.step) {
        this.step = this.options.step;
      }
      this.addAliasController = new AddAliasController({
        collection: this.collection
      });
      this.addAliasController.bind("initializationComplete", this.completeInitialization);
      this.viewAliasesController = new AliasListReadView({
        collection: this.collection
      });
      return this.addAliasController.bind("addAliasesPanelClosed", this.viewAliasesController.render);
    };

    AliasesController.prototype.handleEditAliasesClick = function() {
      return this.addAliasController.show();
    };

    AliasesController.prototype.setToEditMode = function() {
      this.$(".bv_editAliases").css("display", "");
      return $(this.el).parent().removeClass("aliasesContainerSearch");
    };

    AliasesController.prototype.setToReadOnly = function() {
      this.$(".bv_editAliases").css("display", "none");
      if (this.step === "regSearchResults") {
        return $(this.el).parent().removeClass("aliasesContainerSearch");
      } else {
        return $(this.el).parent().addClass("aliasesContainerSearch");
      }
    };

    AliasesController.prototype.completeInitialization = function() {
      this.$(".bv_addAliasContainer").html(this.addAliasController.render().el);
      this.addAliasController.hide();
      if (this.readMode) {
        return this.setToReadOnly();
      }
    };

    AliasesController.prototype.render = function() {
      $(this.el).html($('#Aliases_template').html());
      this.$(".bv_aliasReadViewContainer").html(this.viewAliasesController.render().el);
      return this;
    };

    return AliasesController;

  })(Backbone.View);

  window.AddAliasController = (function(superClass) {
    extend(AddAliasController, superClass);

    function AddAliasController() {
      this.show = bind(this.show, this);
      this.handleCancelAddNewAliasClick = bind(this.handleCancelAddNewAliasClick, this);
      this.hide = bind(this.hide, this);
      this.finishRender = bind(this.finishRender, this);
      this.render = bind(this.render, this);
      return AddAliasController.__super__.constructor.apply(this, arguments);
    }

    AddAliasController.prototype.template = $('#AddAliasPanel_template').html();

    AddAliasController.prototype.events = {
      "click .bv_cancelAddNewAlias": "handleCancelAddNewAliasClick"
    };

    AddAliasController.prototype.initialize = function() {
      this.collection = this.options.collection;
      this.listOfAliases = new AliasListList();
      this.listOfAliases.type = "aliases/parentAliasKinds";
      this.listOfAliases.bind('reset', (function(_this) {
        return function() {
          return _this.trigger("initializationComplete");
        };
      })(this));
      return this.listOfAliases.fetch();
    };

    AddAliasController.prototype.render = function() {
      $(this.el).html($('#AddAliasPanel_template').html());
      this.aliasTableController = new AddAliasTableController({
        collection: this.collection,
        listOfAliases: this.listOfAliases
      });
      this.$(".bv_aliasTableContainer").html(this.aliasTableController.render().el);
      return this;
    };

    AddAliasController.prototype.finishRender = function() {};

    AddAliasController.prototype.hide = function() {
      $(this.el).hide();
      $(this.el).dialog('close');
      return this.trigger("addAliasesPanelClosed");
    };

    AddAliasController.prototype.handleCancelAddNewAliasClick = function() {
      if (this.aliasTableController.collection.modelsAreAllValid()) {
        return this.hide();
      }
    };

    AddAliasController.prototype.show = function() {
      return $(this.el).show();
    };

    return AddAliasController;

  })(Backbone.View);

  window.AddAliasTableController = (function(superClass) {
    extend(AddAliasTableController, superClass);

    function AddAliasTableController() {
      this.render = bind(this.render, this);
      this.addRow = bind(this.addRow, this);
      this.handleAddAliasRowClick = bind(this.handleAddAliasRowClick, this);
      this.setStateOfButtons = bind(this.setStateOfButtons, this);
      this.setStateOfButtonsToDisabled = bind(this.setStateOfButtonsToDisabled, this);
      return AddAliasTableController.__super__.constructor.apply(this, arguments);
    }

    AddAliasTableController.prototype.template = $('#AddAliasTable_template').html();

    AddAliasTableController.prototype.events = {
      'click .bv_addNewAlias': 'handleAddAliasRowClick'
    };

    AddAliasTableController.prototype.initialize = function() {
      this.collection = this.options.collection;
      this.listOfAliases = this.options.listOfAliases;
      this.lastId = 0;
      this.collection.each((function(_this) {
        return function(model) {
          if (model.get('id') != null) {
            if (_this.lastId < model.get('sortId')) {
              return _this.lastId = model.get('id');
            }
          }
        };
      })(this));
      this.collection.bind('add', this.render);
      this.collection.bind('remove', this.render);
      this.collection.bind('change', this.setStateOfButtons);
      return this.collection.bind('error', this.setStateOfButtonsToDisabled);
    };

    AddAliasTableController.prototype.setStateOfButtonsToDisabled = function() {
      this.$(".bv_addNewAlias").addClass("addNewAliasOff");
      this.$(".bv_addNewAlias").removeClass("addNewAliasOn");
      $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOff");
      return $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOn");
    };

    AddAliasTableController.prototype.setStateOfButtons = function() {
      if (this.collection.modelsAreAllValid()) {
        this.$(".bv_addNewAlias").removeClass("addNewAliasOff");
        this.$(".bv_addNewAlias").addClass("addNewAliasOn");
        $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOff");
        return $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOn");
      } else {
        this.$(".bv_addNewAlias").addClass("addNewAliasOff");
        this.$(".bv_addNewAlias").removeClass("addNewAliasOn");
        $(".bv_cancelAddNewAlias").addClass("cancelAddNewAliasOff");
        return $(".bv_cancelAddNewAlias").removeClass("cancelAddNewAliasOn");
      }
    };

    AddAliasTableController.prototype.handleAddAliasRowClick = function() {
      if (this.collection.modelsAreAllValid()) {
        this.lastId++;
        return this.collection.add(new AliasModel({
          sortId: this.lastId
        }));
      }
    };

    AddAliasTableController.prototype.addRow = function(model) {
      var rowControllers;
      rowControllers = new AliasRowController({
        model: model,
        listOfAliases: this.listOfAliases
      });
      rowControllers.bind("isDirty", (function(_this) {
        return function(newAlias) {
          return _this.collection.add(newAlias);
        };
      })(this));
      rowControllers.bind("removedRow", this.render);
      return this.$(".bv_aliasTableBody").append(rowControllers.render().el);
    };

    AddAliasTableController.prototype.render = function() {
      var numRows;
      $(this.el).html($('#AddAliasTable_template').html());
      numRows = 0;
      this.collection.sort();
      this.collection.each((function(_this) {
        return function(model) {
          if (!model.get('ignored')) {
            _this.addRow(model);
            return numRows++;
          }
        };
      })(this));
      this.setStateOfButtons();
//       this.$(".bv_aliasRemove").removeClass("hide");
      return this;
    };

    return AddAliasTableController;

  })(Backbone.View);

  window.AliasRowController = (function(superClass) {
    extend(AliasRowController, superClass);

    function AliasRowController() {
      this.render = bind(this.render, this);
      this.handleInputChange = bind(this.handleInputChange, this);
      this.scrapeForm = bind(this.scrapeForm, this);
      this.handleAliasRemoveClick = bind(this.handleAliasRemoveClick, this);
      return AliasRowController.__super__.constructor.apply(this, arguments);
    }

    AliasRowController.prototype.template = $('#AddAliasRow_template').html();

    AliasRowController.prototype.tagName = 'tr';

    AliasRowController.prototype.events = {
      "click .bv_aliasRemove": "handleAliasRemoveClick",
      "change .bv_aliasTypeContainer": "handleInputChange",
      "change .bv_aliasKind": "handleInputChange"
    };

    AliasRowController.prototype.initialize = function() {
      this.model = this.options.model;
      return this.listOfAliases = this.options.listOfAliases;
    };

    AliasRowController.prototype.handleAliasRemoveClick = function() {
      if (this.model.get("id") != null) {
        this.model.set({
          "ignored": true
        });
      } else {
        this.model.destroy();
      }
      return this.trigger("removedRow");
    };

    AliasRowController.prototype.scrapeForm = function() {
      var formValues;
	  var typeKind = this.$(".bv_aliasTypeContainer").val().split(':');
	  var lsType = typeKind[0];
	  var lsKind = typeKind[1];
      formValues = {
        aliasName: this.$(".bv_aliasKind").val(),
        lsType: lsType,
		lsKind: lsKind
      };
      if (formValues.aliasName === "") {
        formValues.aliasName = " ";
      }
      return formValues;
    };

    AliasRowController.prototype.handleInputChange = function() {
      var formValues, newAlias;
      formValues = this.scrapeForm();
      if (this.model.get("id") != null) {
        this.model.set({
          "ignored": true
        });
        formValues.sortId = this.model.get("sortId");
        newAlias = new AliasModel(formValues);
        return this.trigger("isDirty", newAlias);
      } else {
        this.model.set(formValues);
        var typeKind = this.model.get('lsType') + ':' + this.model.get('lsKind');
        this.model.set({'typeKind': typeKind});
        return this;
      }
    };

    AliasRowController.prototype.render = function() {
      var cloneOfAliasTypes, optionToInsert;
      $(this.el).html(_.template($('#AddAliasRow_template').html(), this.model.toJSON()));
	  if (this.model.get('id') != null && window.configuration.metaLot.disableAliasEdit != null && window.configuration.metaLot.disableAliasEdit == true) {
		this.$('.bv_aliasTypeContainer').attr('disabled', 'disabled');
		this.$('.bv_aliasKind').attr('disabled', 'disabled');
		this.$('.bv_aliasRemove').addClass("hide");
		}
	  else {
		this.$('.bv_aliasTypeContainer').removeAttr('disabled');
		this.$('.bv_aliasKind').removeAttr('disabled');
		this.$('.bv_aliasRemove').removeClass("hide");
		}
      cloneOfAliasTypes = $.extend(true, {}, this.listOfAliases);
      optionToInsert = new AliasList({
        "kindName": "Select Type",
        "lsType": {
          "id": 0,
          "typeName": "not_set",
          "version": 0
        },
        "version": 0
      });
      this.aliasType = new AliasListSelectController({
        el: this.$('.bv_aliasTypeContainer'),
        type: "aliases/parentAliasKinds",
        collection: cloneOfAliasTypes,
        selectedCode: this.model.get("typeKind"),
        insertFirstOption: optionToInsert
      });
      this.aliasType.handleListReset();
      return this;
    };

    return AliasRowController;

  })(Backbone.View);

  window.AliasModel = (function(superClass) {
    extend(AliasModel, superClass);

    function AliasModel() {
      return AliasModel.__super__.constructor.apply(this, arguments);
    }

    AliasModel.prototype.defaults = {
      aliasName: "",
      lsType: "",
      deleted: false,
      ignored: false,
      lsKind: "Parent Common Name",
      typeKind: "",
      preferred: false,
      version: 0,
      sortId: null
    };

	AliasModel.prototype.initialize = function() {
		var typeKind = this.get('lsType') + ':' + this.get('lsKind');
		this.set({'typeKind': typeKind});
	}

    AliasModel.prototype.validate = function(attrs, options) {
      var errors;
      errors = [];
      if (attrs.lsType != null) {
        if (attrs.lsType === "not_set:Select Type") {
          errors.push("Alias Type not set");
        }
      }
      if (attrs.lsKind != null) {
        if ($.trim(attrs.aliasName) === "") {
          errors.push("Alias Name not set");
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AliasModel;

  })(Backbone.Model);

  window.AliasCollection = (function(superClass) {
    extend(AliasCollection, superClass);

    function AliasCollection() {
      return AliasCollection.__super__.constructor.apply(this, arguments);
    }

    AliasCollection.prototype.model = AliasModel;

    AliasCollection.prototype.comparator = function(item) {
      return item.get("sortId");
    };

    AliasCollection.prototype.modelsAreAllValid = function() {
      var modelsAreValid;
      modelsAreValid = true;
      this.each(function(model) {
        var isValid;
        isValid = model.validate(model.toJSON());
        if (isValid !== null) {
          return modelsAreValid = false;
        }
      });
      return modelsAreValid;
    };

    return AliasCollection;

  })(Backbone.Collection);

  window.AliasListReadView = (function(superClass) {
    extend(AliasListReadView, superClass);

    function AliasListReadView() {
      this.render = bind(this.render, this);
      this.addItem = bind(this.addItem, this);
      return AliasListReadView.__super__.constructor.apply(this, arguments);
    }

    AliasListReadView.prototype.template = $("#AliasListReadView").html();

    AliasListReadView.prototype.tagName = 'span';

    AliasListReadView.prototype.initialize = function() {
      return this.collection = this.options.collection;
    };

    AliasListReadView.prototype.addItem = function(model) {
      var item;
      item = new AliasItem({
        model: model
      });
      return this.$(".bv_aliasListContainer").append(item.render().el);
    };

    AliasListReadView.prototype.render = function() {
      $(this.el).html($("#AliasListReadView").html());
      this.collection.each((function(_this) {
        return function(model) {
          if (!model.get("ignored")) {
            return _this.addItem(model);
          }
        };
      })(this));
      return this;
    };

    return AliasListReadView;

  })(Backbone.View);

  window.AliasItem = (function(superClass) {
    extend(AliasItem, superClass);

    function AliasItem() {
      this.render = bind(this.render, this);
      return AliasItem.__super__.constructor.apply(this, arguments);
    }

    AliasItem.prototype.template = $("#AliasItemView").html();

    AliasItem.prototype.tagName = 'span';

    AliasItem.prototype.render = function() {
      $(this.el).html(_.template($('#AliasItemView').html(), this.model.toJSON()));
      return this;
    };

    return AliasItem;

  })(Backbone.View);

}).call(this);

//# sourceMappingURL=AddAlias.js.map
