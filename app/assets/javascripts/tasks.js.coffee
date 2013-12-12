KarmaTracker.controller "TasksController", ($scope, $http, $cookieStore, $location, $routeParams, broadcastService, $rootScope) ->
  $rootScope.pullAllowed = true
  $scope.tasks = []
  $scope.current = true
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.timer = 0
  $scope.currentPage = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.totalCount = 0
  $scope.items = []

  $scope.checkWebHookPTIntegration = ->
    $http.get(
      "/api/v1/projects/#{$location.url().split('/')[2]}/pivotal_tracker_get_web_hook_integration?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $rootScope.webhookPTIntegration = true if data['web_hook_exists']
    ).error((data, status, headers, config) ->
      $rootScope.webhookPTIntegration = false
    )

  $scope.createPTWebHookIntegration = ->
    $rootScope.webhookSpinner = true;
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/pivotal_tracker_create_web_hook_integration?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $rootScope.webhookPTIntegration = true
      $rootScope.webhookSpinner = false;
      $scope.notice "Pivotal Tracker WebHook Integration was added successfully"
    ).error((data, status, headers, config) ->
      $rootScope.webhookPTIntegration = false
      $rootScope.webhookSpinner = false;
      $scope.notice "Pivotal Tracker WebHook Integration failed"
    )


  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.reloadTasks = (pageNr) ->
    $rootScope.loading = true
    if $routeParams.project_id?
      $scope.checkWebHookPTIntegration()
    if !pageNr? || isNaN(pageNr) || typeof(pageNr) == 'boolean'
      pageNr = 0

    $http.get(
      "/api/v1/projects/#{$location.path().split('/')[2]}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}&page=#{pageNr+1}"
    ).success((data, status, headers, config) ->
      $scope.totalCount = parseInt(data['total_count'])
      $scope.currentPage = pageNr
      $scope.tasks = []
      for task in data['tasks']
        task.task.visible = true
        $scope.tasks.push task.task
       $scope.initItems()
       $rootScope.loading = false
    ).error((data, status, headers, config) ->
      $rootScope.loading = false
    )


  $scope.startTracking = (task) ->
    if $scope.runningTask? && task.id == $scope.runningTask.id
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookieStore.get($scope.tokenName)}"
      ).success((data, status, headers, config) ->
        $scope.notice "You stopped tracking #{task.name}."
        $scope.runningTask = null
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())
        broadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
      )
    else
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookieStore.get($scope.tokenName)}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.notice "You started tracking #{task.name}."
        $scope.runningTask = task
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())
        broadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
      )

  $scope.queryChanged = () ->
    query = $scope.query.string
    clearTimeout $scope.timer if $scope.timer != 0
    $scope.timer = setTimeout (->
      $scope.reloadTasks()
      $scope.$apply()
    ), 1000

  $scope.reloadTasks()
  $scope.$watch("current", $scope.reloadTasks)
  $scope.$watch("runningTask", $scope.reloadTasks)
  $scope.$watch("query.string", $scope.queryChanged)


  $http.get(
    "/api/v1/projects/#{$location.path().split('/')[2]}/?token=#{$cookieStore.get($scope.tokenName)}"
  ).success((data, status, headers, config) ->
    $scope.project = data.project
  ).error((data, status, headers, config) ->
  )

  $scope.initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }
