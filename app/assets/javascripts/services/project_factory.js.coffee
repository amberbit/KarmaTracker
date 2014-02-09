KarmaTracker.factory 'Project', ['$resource', '$cookieStore', 'TOKEN_NAME', ($resource, $cookieStore, TOKEN_NAME) ->
  class Project
    constructor: ->
      @service = $resource("/api/v1/projects/:id", {id: '@id'}, {
        update:
          method: 'PUT'
        query:
          method: 'GET'
          isArray: false
        toggleActive:
          method: 'PUT'
          url: "api/v1/projects/:id/toggle_active"
      })
      @token = $cookieStore.get TOKEN_NAME


    query: (searchString, archive, pageNr) =>
      if @token
        @service.query(token: @token, query: searchString, archive: archive, page: pageNr)

    toggleActive: (project_id) =>
      if @token
        @service.toggleActive(id: project_id, token: @token)


]
