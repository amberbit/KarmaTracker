KarmaTracker.factory 'Project', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Project
    constructor: ->
      @service = $resource("/api/v1/projects", {}, {
        update:
          method: 'PUT'
        query:
          method: 'GET'
          isArray: false
      })
      @token = $cookieStore.get TOKEN_NAME


    query: (searchString, archive, pageNr) =>
      if @token
        @service.query(token: @token, archive: archive, page: pageNr)
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
