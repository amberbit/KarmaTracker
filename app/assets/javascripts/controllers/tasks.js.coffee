KarmaTracker.controller "TasksController", ($scope, $http, $cookieStore, $location, $routeParams, BroadcastService, $rootScope, FlashMessage) ->
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
  flashMessageService = FlashMessage

  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.$on("reloadTasksOrProjects", ->
    $scope.reloadTasks()
  )

  $scope.reloadTasks = (pageNr) ->
    $rootScope.loading = true
    if !pageNr? || isNaN(pageNr) || typeof(pageNr) == 'boolean'
      pageNr = 0

    $http.get(
      "/api/v1/projects/#{$location.path().split('/')[2]}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}&page=#{pageNr+1}"
    ).success((data, status, headers, config) ->
      $scope.totalCount = parseInt(data.total_count)
      $scope.currentPage = pageNr
      $scope.tasks = data.tasks
      $scope.initItems()
      $rootScope.loading = false
    ).error((data, status, headers, config) ->
      $rootScope.loading = false
    )


  $scope.startTracking = (task) ->
    if $rootScope.runningTask? && task.id == $rootScope.runningTask.id
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookieStore.get($scope.tokenName)}"
      ).success((data, status, headers, config) ->
        flashMessageService.notice "You stopped tracking #{task.name}."
        $rootScope.runningTask = null
        BroadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
      )
    else
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookieStore.get($scope.tokenName)}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        flashMessageService.notice "You started tracking #{task.name}."
        $rootScope.runningTask = task
        BroadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
      )

  $scope.queryChanged = () ->
    query = $scope.query.string
    clearTimeout $scope.timer if $scope.timer != 0
    $scope.timer = setTimeout (->
      $scope.reloadTasks()
      $scope.$apply()
    ), 1000

  $scope.$watch("current", $scope.reloadTasks)
  $scope.$watch("runningTask", (newValue, oldValue) ->
    $scope.reloadTasks() if newValue != oldValue
  )
  $scope.$watch("query.string", (newValue, oldValue) ->
    $scope.queryChanged() if newValue != oldValue
  )


  $http.get(
    "/api/v1/projects/#{$location.path().split('/')[2]}/?token=#{$cookieStore.get($scope.tokenName)}"
  ).success((data, status, headers, config) ->
    $scope.project = data
  ).error((data, status, headers, config) ->
  )

  $scope.initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }

  BroadcastService.prepForBroadcast "TasksControllerStarted"
