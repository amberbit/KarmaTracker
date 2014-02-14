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
        recent:
          method: 'GET'
          url: "api/v1/projects/recent"
        refreshForProject:
          method: 'GET'
          url: 'api/v1/projects/:id/refresh_for_project'
        refresh:
          method: 'GET'
          url: 'api/v1/projects/:id/refresh'
        alsoWorking:
          method: 'GET'
          url: 'api/v1/projects/also_working'
      })
      @token = $cookieStore.get TOKEN_NAME


    query: (searchString, archive, pageNr) =>
      @service.query(token: @token, query: searchString, archive: archive, page: pageNr) if @token

    toggleActive: (project_id) =>
      @service.toggleActive(id: project_id, token: @token) if @token

    recent: =>
      @service.recent(token: @token) if @token

    refreshForProject: (id) =>
      @service.refreshForProject(token: @token, id: id) if @token

    refresh: (id) =>
      @service.refresh(token: @token, id: id) if @token

    alsoWorking: =>
      @service.alsoWorking(token: @token) if @token
]
