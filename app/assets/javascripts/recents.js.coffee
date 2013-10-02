KarmaTracker.controller "RecentsController", ($scope, $http, $cookieStore, $location, broadcastService, $rootScope) ->
  $scope.lastTasks = []
  $scope.lastProjects = []
  $scope.noTasks = true
  $rootScope.noRecentProjects = true
  $scope.tokenName = 'token'
  $scope.alsoWorking = []
  $scope.location = null

  $scope.showAllProjects = ->
    document.getElementById("projectspage").classList.remove("hide-for-small")
    document.getElementById("recentspage").classList.add("hide-for-small")

  $scope.startTracking = (task) ->
    if task.id == $scope.runningTask.id
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookieStore.get($scope.tokenName)}"
      ).success((data, status, headers, config) ->
        $scope.notice "You started tracking #{task.name}."
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        broadcastService.prepForBroadcast('recentClicked')
      ).error((data, status, headers, config) ->
        console.debug('Error when stopping time log entries')
      )
    else
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookieStore.get($scope.tokenName)}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        broadcastService.prepForBroadcast('recentClicked')
      ).error((data, status, headers, config) ->
        console.debug('Error when starting tracking time on tasks')
      )

  $scope.getRecentTasks = ->
    $http.get(
      '/api/v1/tasks/recent?token='+$cookieStore.get($scope.tokenName)
    ).success((data, status, headers, config) ->
      $scope.lastTasks = []
      for task in data['tasks']
        $scope.lastTasks.push task.task
      $scope.noTasks = false if $scope.lastTasks.length > 0
    ).error((data, status, headers, config) ->
      $scope.lastTasks = []
      $scope.noTasks = true
    )

  $scope.getRecentProjects = ->
    $http.get(
      '/api/v1/projects/recent?token='+$cookieStore.get($scope.tokenName)
    ).success((data, status, headers, config) ->
      $scope.lastProjects = []
      for project in data['projects']
        $scope.lastProjects.push project.project
      $rootScope.noRecentProjects = false if $scope.lastProjects.length > 0
    ).error((data, status, headers, config) ->
      $scope.lastProjects = []
      $rootScope.noRecentProjects = true
    )

  $scope.$on "handleBroadcast", () ->
    if broadcastService.message == 'refreshRecent'
      $scope.getRecentTasks()
      $scope.getRecentProjects()

  $scope.alsoWorking = ->
    $http.get(
      "/api/v1/projects/also_working?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.alsoWorking = data
      setLocation()
    ).error((data, status, headers, config) ->
      console.debug "Error fetching who is also working ATM."
    )

  setLocation = ->
    if $location.path().match /projects\/\d*\/tasks$/
      $scope.location = $location.path().match(/projects\/(\d*)\/tasks$/)[1]
      for project, data of $scope.alsoWorking
        if $scope.location == data[0].toString()
          $scope.alsoWorking = data[1]
          break
    else if $location.path().match /projects$/
      $scope.location = 'projects'
    else
      $scope.location = null

  $scope.getRecentTasks()
  $scope.getRecentProjects()
  $scope.alsoWorking()

