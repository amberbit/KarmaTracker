KarmaTracker.factory 'User', ['$resource', '$q', '$cookieStore', 'TOKEN_NAME', ($resource, $q, $cookieStore, TOKEN_NAME) ->
  class User
    constructor: ->
      @service = $resource("/api/v1/user", {}, {})
      @token = $cookieStore.get TOKEN_NAME


    get: =>
      if @token
        @service.get(token: @token)


]
