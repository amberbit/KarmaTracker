KarmaTracker.controller "TasksController", ($scope, $http, $cookies, $location, $routeParams, broadcastService) ->
  $scope.tasks = []
  $scope.current = true
  $scope.query.string = ""

  $scope.reloadTasks = () ->
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      $scope.tasks = []
      for task in data
        task.task.visible = $scope.matchesQuery(task.task.name)
        $scope.tasks.push task.task

    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )

  $scope.reloadTasks()

  $scope.startTracking = (task) ->
    if !task.running
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookies.token}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.reloadTasks()
        $scope.notice "You started tracking #{task.name}."
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())
        broadcastService.prepForBroadcast "refreshRecent"
 
      ).error((data, status, headers, config) ->
        console.debug('Error when starting tracking time on tasks')
      )
    else
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookies.token}"
      ).success((data, status, headers, config) ->
        $scope.reloadTasks()
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())

        broadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
        console.debug('Error when stopping time log entries')
      )


  $scope.$watch("query.string", ->
    for task in $scope.tasks
      task.visible = $scope.matchesQuery("#{task.source_identifier} #{task.name}")
  )

  $scope.$watch("current", $scope.reloadTasks)
  $scope.$watch("runningTask", $scope.reloadTasks)

  $http.get(
    "/api/v1/projects/#{$routeParams.project_id}/?token=#{$cookies.token}"
  ).success((data, status, headers, config) ->
    $scope.project = data.project
  ).error((data, status, headers, config) ->
    console.debug('Error fetching project')
  )


