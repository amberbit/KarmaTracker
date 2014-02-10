KarmaTracker.factory 'TimeLogEntry', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Integration
    constructor: ->
      @service = $resource("/api/v1/time_log_entries", {}, {
        stop:
          method: 'POST'
          url: '/api/v1/time_log_entries/stop'
      })
      @token = $cookieStore.get TOKEN_NAME

    stop: =>
      @service.stop(token: @token) if @token

    save: (time_log_entry) =>
      @service.save(token: @token, time_log_entry: time_log_entry) if @token

]
