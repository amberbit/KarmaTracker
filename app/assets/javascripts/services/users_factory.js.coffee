KarmaTracker.factory 'User', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class User
    constructor: ->
      @service = $resource("/api/v1/user", {}, {
        update:
          method: 'PUT'
      })
      @token = $cookieStore.get TOKEN_NAME


    get: =>
      if @token
        @service.get(token: @token)

    remove: =>
      if @token
        @service.remove(token: @token)

    update: (user) =>
      if @token
        @service.update(token: @token, user: user)

]
