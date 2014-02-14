KarmaTracker.controller "RootController", [ '$scope', '$http', '$location', '$cookieStore', '$routeParams', 'FlashMessage', 'BroadcastService', '$rootScope', '$timeout', 'Task', 'Project', 'User', 'Integration', ($scope, $http, $location, $cookieStore, $routeParams, FlashMessage, BroadcastService, $rootScope, $timeout, Task, Project, User, Integration) ->
  $rootScope.pullAllowed = true
  $scope.refreshing = false
  $scope.firstTipVisible = false
  $scope.webhook_tip = false
  $scope.tokenName = 'token'
  $scope.menuIsDroppedDown = document.getElementById("top-bar").classList.contains("expanded")
  $scope.query = {}
  $scope.runningStartedAt = ""
  $scope.runningTime = ""
  $scope.alsoWorking = []
  taskService = new Task
  projectService = new Project
  userService = new User
  flashMessageService = FlashMessage
  integrationService = new Integration

  $scope.getRunningTask = ->
    taskService.running().$promise
      .then (result) ->
        $rootScope.runningTask = result
        $rootScope.runningStartedAt = result.started_at
        $scope.timeCounter()
      .catch ->
        $scope.runningStartedAt = ""
        $scope.timeCounter()
        $rootScope.runningTask = {}

  $scope.timeCounter = ->
    if $scope.runningStartedAt
      duration = moment().diff(moment($scope.runningStartedAt), "milliseconds")
      $scope.runningTime = duration.toHHmmSS()
      runningTimeout = $timeout($scope.timeCounter, 1000)
    else
      $timeout.cancel(runningTimeout) if runningTimeout
      $scope.runningTime = ""

  $scope.refresh = ->
    if $location.path().indexOf('tasks') != -1
      $rootScope.loading = true
      projectService.refreshForProject($location.path().split('/')[2]).$promise
        .then ->
          $scope.refreshing = 'tasks'
          $scope.locate = window.location.href
          setTimeout(checkFetchingProjects,2000)
        .finally ->
          $scope.refreshing = $scope.refreshing = false
    else
      $rootScope.loading = true
      projectService.refresh($location.path().split('/')[2]).$promise
        .then ->
          $scope.refreshing = 'projects'
          $scope.locate = window.location.href
          setTimeout(checkFetchingProjects,2000)
        .finally ->
          $scope.refreshing = $scope.refreshing = false

  checkFetchingProjects = ->
    userService.get().$promise
      .then (result) ->
        $scope.refreshing = if result.refreshing? then result.refreshing else null
        if ($scope.refreshing)
          setTimeout(checkFetchingProjects, 2000)
        else if $scope.locate == window.location.href
          $scope.$broadcast("reloadTasksOrProjects")
      .catch ->
        setTimeout(checkFetchingProjects, 2000)

  $scope.openProject = (source, name, identifier, event) ->
    if event
      event.stopPropagation()
    if source == 'GitHub'
      window.open('http://github.com/' + name, '_blank')
    else
      window.open('http://pivotaltracker.com/s/projects/' + identifier, '_blank')

  $scope.openTask = (source, name, identifier, task, event) ->
    if event
      event.stopPropagation()
    if source == 'GitHub'
      window.open('http://github.com/' + name + '/issues/' + task.split("/")[1], '_blank')
    else
      window.open('http://pivotaltracker.com/s/projects/' + identifier + '/stories/' + task, '_blank')

  $scope.go = (path) ->
    document.getElementById("top-bar").classList.remove("expanded")
    $location.path path

  $scope.hideFirstTip = ->
    $scope.firstTipVisible = false

  if $cookieStore.get($scope.tokenName)?
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'

  $scope.checkIntegrations = ->
    integrationService.query().$promise
      .then (result) -> $scope.firstTipVisible = true if result.length == 0

  $rootScope.checkRefreshingProjects = ->
    userService.get().$promise
      .then (result) ->
       $scope.refreshing = if result.refreshing? then result.refreshing else null
      .finally ->
       setTimeout($rootScope.checkRefreshingProjects, 10000)
    if !$scope.$root.$$phase
      $scope.$apply()

  $scope.$on "handleBroadcast", ->
    if BroadcastService.message == 'recentClicked'
      $scope.getRunningTask()

  $rootScope.pull = (value, element) ->
    if value && !$scope.menuIsDroppedDown
      $(element).hook(
        reloadPage: false,
        reloadEl: ->
          $scope.refresh()
        )
    else
      $(element).hook("destroy")

  $scope.setAlsoWorking = ->
    $http.get(
      "/api/v1/projects/also_working?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.alsoWorking = if data == '' || Object.keys(data).length == 0 then [] else data
    ).error((data, status, headers, config) ->
    )

  if userService.loggedIn()
    $scope.getRunningTask()
    $rootScope.checkRefreshingProjects()
    $scope.checkIntegrations() unless $scope.refreshing

  $scope.$on "$locationChangeSuccess", (event, currentLocation) ->
    if currentLocation.match(/projects$/) or currentLocation.match(/projects\/\d*\/tasks$/)
      $scope.setAlsoWorking()
    else
      $scope.alsoWorking = null

]
