KarmaTracker.controller "ProjectsController", ($scope, $http, $cookies, $location) ->
  $scope.projects = []
  $scope.query.string = ""

  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  $http.get(
    '/api/v1/projects?token='+$cookies.token
  ).success((data, status, headers, config) ->
    $scope.projects = []
    for project in data
      project.project.visible = $scope.matchesQuery(project.project.name)
      $scope.projects.push project.project
  ).error((data, status, headers, config) ->
    console.debug('Error fetching projects')
  )

  $scope.$watch("query.string", ->
    for project in $scope.projects
      project.visible = $scope.matchesQuery(project.name)
  )

