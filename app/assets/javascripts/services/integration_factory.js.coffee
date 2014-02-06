KarmaTracker.factory 'Integration', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Integration
    constructor: ->
      @service = $resource("/api/v1/integrations/:id", {}, {
        #update:
        #  method: 'PUT'
      })
      @token = $cookieStore.get TOKEN_NAME


    query: (integration_name) =>
      if @token
        @service.query(token: @token, service: integration_name)

    remove: (id) =>
      if @token
        @service.remove(token: @token, id: id)

    #update: (user) =>
      #if @token
        #@service.update(token: @token, user: user)

]
