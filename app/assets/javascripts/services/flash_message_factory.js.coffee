# Flashe message passed from other controllers to FlashesController
KarmaTracker.factory "FlashMessage", ->
  { notice: (message) ->
      this.string = message
      this.type = null
    alert: (message) ->
      this.string = message
      this.type = 'alert'
    success: (message) ->
      this.string = message
      this.type = 'success'

    string: ""
    type: null
  }
