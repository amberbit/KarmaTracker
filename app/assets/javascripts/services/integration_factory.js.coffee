KarmaTracker.factory 'Integration', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Integration
    constructor: ->
      @service = $resource("/api/v1/integrations/:id", {}, {
        #update:
        #  method: 'PUT'
      })
      @token = $cookieStore.get TOKEN_NAME


    query: (type) =>
      if @token
        @service.query(token: @token, type: type)

    remove: (id) =>
      if @token
        @service.remove(token: @token, id: id)

    save: (integration) =>
      if @token
        @service.save(token: @token, integration: integration)

]
