KarmaTracker.controller "TasksController", ($scope, $http, $cookies, $location, $routeParams) ->
  $scope.tasks = []
  $scope.current = true

  $scope.reloadTasks = () ->
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      $scope.tasks = []
      for task in data
        $scope.tasks.push task.task
    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )

  $scope.reloadTasks()
  $scope.$watch("current", $scope.reloadTasks)

  $scope.startTracking = (task) ->
    if !task.running
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookies.token}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.reloadTasks()
      ).error((data, status, headers, config) ->
        console.debug('Error when starting tracking time on tasks')
      )
    else
      $http.get(
        "/api/v1/time_log_entries/stop?token=#{$cookies.token}"
      ).success((data, status, headers, config) ->
        $scope.reloadTasks()
      ).error((data, status, headers, config) ->
        console.debug('Error when stopping time log entries')
      )

