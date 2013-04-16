KarmaTracker.controller "TasksController", ($scope, $http, $cookies, $location, $routeParams) ->
  $scope.tasks = []

  $http.get(
    "/api/v1/projects/#{$routeParams.project_id}/tasks?token=#{$cookies.token}"
  ).success((data, status, headers, config) ->
    $scope.tasks = []
    for task in data.tasks
      $scope.tasks.push task
  ).error((data, status, headers, config) ->
    console.debug('Error fetching tasks')
  )

