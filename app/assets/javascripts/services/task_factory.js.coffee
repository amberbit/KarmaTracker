KarmaTracker.factory 'Task', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Integration
    constructor: ->
      @service = $resource("/api/v1/tasks", {}, {
        recent:
          method: 'GET'
          url: '/api/v1/tasks/recent'
      })
      @token = $cookieStore.get TOKEN_NAME

    recent: =>
      @service.recent(token: @token) if @token

]
