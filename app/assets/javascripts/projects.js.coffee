KarmaTracker.controller "ProjectsController", ($scope, $http, $cookies, $location) ->
  $scope.projects = []
  $scope.query.string = ""

  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  filter_visible = ->
    any_visible = false

    for project in $scope.projects
      project.visible = $scope.matchesQuery(project.name)
      any_visible = true if project.visible

    $scope.projects.none_visible = !any_visible


  $http.get(
    '/api/v1/projects?token='+$cookies.token
  ).success((data, status, headers, config) ->
    $scope.projects = []
    for project in data
      project.project.visible = $scope.matchesQuery(project.project.name)
      $scope.projects.push project.project
    filter_visible()
  ).error((data, status, headers, config) ->
  )

  $scope.$watch("query.string", filter_visible  )
