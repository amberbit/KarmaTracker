KarmaTracker.controller "RecentsController", ($scope, $http, $cookies, $location, broadcastService) ->
  $scope.lastTasks = []
  $scope.lastProjects = []

  $scope.startTracking = (task) ->
    if !task.running
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookies.token}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        broadcastService.prepForBroadcast('recentClicked')
      ).error((data, status, headers, config) ->
        console.debug('Error when starting tracking time on tasks')
      )
    else
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookies.token}"
      ).success((data, status, headers, config) ->
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        broadcastService.prepForBroadcast('recentClicked')
      ).error((data, status, headers, config) ->
        console.debug('Error when stopping time log entries')
      )

  $scope.getRecentTasks = ->
    $http.get(
      '/api/v1/tasks/recent?token='+$cookies.token
    ).success((data, status, headers, config) ->
      $scope.lastTasks = []
      for task in data
        $scope.lastTasks.push task.task
    ).error((data, status, headers, config) ->
      $scope.lastTasks = []
    )

  $scope.getRecentProjects = ->
    $http.get(
      '/api/v1/projects/recent?token='+$cookies.token
    ).success((data, status, headers, config) ->
      $scope.lastProjects = []
      for project in data
        $scope.lastProjects.push project.project
    ).error((data, status, headers, config) ->
      $scope.lastProjects = []
    )

  $scope.$on "handleBroadcast", () ->
    if broadcastService.message == 'refreshRecent'
      $scope.getRecentTasks()
      $scope.getRecentProjects()

  $scope.getRecentTasks()
  $scope.getRecentProjects()

