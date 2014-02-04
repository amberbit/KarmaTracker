window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies', 'ngMobile', 'ngRoute', 'ui.bootstrap', 'ngResource'])


KarmaTracker.controller "RootController", ($scope, $http, $location, $cookieStore, $routeParams, FlashMessage, BroadcastService, $rootScope, $timeout) ->
  $rootScope.pullAllowed = true
  $scope.runningTask = {}
  $scope.runningVisible = false
  $scope.refreshing = false
  $scope.firstTipVisible = false
  $scope.webhook_tip = false
  $scope.tokenName = 'token'
  $scope.menuIsDroppedDown = document.getElementById("top-bar").classList.contains("expanded")
  $scope.username = ''
  $scope.gravatar_url = ''
  $scope.query = {}
  $scope.runningStartedAt = ""
  $scope.runningTime = ""
  $scope.alsoWorking = []

  if $cookieStore.get($scope.tokenName)?
    $http.get(
      '/api/v1/user?token='+$cookieStore.get('token')
    ).success((data, status, headers, config) ->
      $scope.gravatar_url = data.user.gravatar_url
      $scope.username = data.user.email.split('@')[0].split(/\.|-|_/).join(" ")
      $scope.username = $scope.username.replace /\w+/g, (str) ->
        str.charAt(0).toUpperCase() + str.substr(1).toLowerCase()
    ).error((data, status, headers, config) ->
    )

  $scope.getRunningTask = ->
    $http.get(
        "/api/v1/tasks/running?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.runningStartedAt = data.task.started_at
        $scope.timeCounter()
        $scope.runningTask = data.task
        $scope.runningVisible = true
      ).error((data, status, headers, config) ->
        $scope.runningStartedAt = ""
        $scope.timeCounter()
        $scope.runningTask = {}
        $scope.runningVisible = false
      )

  timeFormat = (milliseconds) ->
    result = ""
    timePad = (str) ->
      while str.length < 2
        str = "0" + str
      str
    seconds = Math.floor((milliseconds / 1000) % 60).toString()
    minutes = Math.floor((milliseconds / (60000)) % 60).toString()
    hours = Math.floor(milliseconds / (3600000)).toString()
    result = timePad(hours) + ":" if hours > 0
    result = result + timePad(minutes) + ":" + timePad(seconds)

  $scope.timeCounter = () ->
    if $scope.runningStartedAt
      duration = moment().diff(moment($scope.runningStartedAt), "milliseconds")
      $scope.runningTime = timeFormat(duration)
      runningTimeout = $timeout($scope.timeCounter, 1000)
    else
      $timeout.cancel(runningTimeout) if runningTimeout
      $scope.runningTime = ""

  $scope.refresh = ->
    if $location.path().indexOf('tasks') != -1
      $rootScope.loading = true
      $http.get(
        "api/v1/projects/#{$location.path().split('/')[2]}/refresh_for_project?token="+$cookieStore.get('token')
      ).success((data, status, headers, config) ->
        $scope.refreshing = 'tasks'
        $rootScope.loading = false
        $scope.locate = window.location.href
        setTimeout(checkFetchingProjects,2000)
      ).error((data, status, headers, config) ->
        $scope.refreshing = false
        $rootScope.loading = false
      )
    else
      $rootScope.loading = true
      $http.get(
        '/api/v1/projects/refresh?token='+$cookieStore.get('token')
      ).success((data, status, headers, config) ->
        $scope.refreshing = 'projects'
        $rootScope.loading = false
        $scope.locate = window.location.href
        setTimeout(checkFetchingProjects,2000)
      ).error((data, status, headers, config) ->
        $scope.refreshing = false
        $rootScope.loading = false
      )

  checkFetchingProjects = ->
    $http.get(
      "/api/v1/user?token=#{$cookieStore.get $scope.tokenName}"
    ).success((data, status, headers, config) ->
      $scope.refreshing = if data.user.refreshing? then data.user.refreshing else null
      if ($scope.refreshing)
        setTimeout(checkFetchingProjects, 2000)
      else if $scope.locate == window.location.href
        $scope.$broadcast("reloadTasksOrProjects")
    ).error((data, status, headers, config) ->
      setTimeout(checkFetchingProjects, 2000)
    )

  refreshWithPull = ->
    if $location.path().indexOf('tasks') != -1
      $http.get(
        "api/v1/projects/#{$location.path().split('/')[2]}/refresh_for_project?token="+$cookieStore.get('token')
      ).success((data, status, headers, config) ->
        $scope.refreshing = true
        window.location.reload(true)
      ).error((data, status, headers, config) ->
        $scope.refreshing = false
        window.location.reload(true)
      )
    else
      $http.get(
        '/api/v1/projects/refresh?token='+$cookieStore.get('token')
      ).success((data, status, headers, config) ->
        $scope.refreshing = true
        window.location.reload(true)
      ).error((data, status, headers, config) ->
        $scope.refreshing = false
        window.location.reload(true)
      )
    $scope.$apply();

  $scope.notice = (message) ->
    FlashMessage.type = null
    FlashMessage.string = message

  $scope.alert = (message) ->
    FlashMessage.type = 'alert'
    FlashMessage.string = message

  $scope.success = (message) ->
    FlashMessage.type = 'success'
    FlashMessage.string = message



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

  $scope.goToLink = (path) ->
    $location.path path

  $scope.highlightCurrentPage = (url) ->
    if $location.url().indexOf(url) != -1
      return "current"
    else
      return ""

  $scope.expandMenu = ->
    if window.getComputedStyle(document.getElementById("toggle-menu")).getPropertyValue("display") != "none"
      document.getElementById("top-bar").classList.toggle("expanded")
      $scope.menuIsDroppedDown = document.getElementById("top-bar").classList.contains("expanded")
      element = $("div").find("[pull-to-refresh]")
      $rootScope.$watch("pullAllowed", (value) ->
        $rootScope.pull(value, element)
      , true)

  $scope.moveMenu = ->
    document.getElementById("profile").classList.toggle("moved")
    if  document.getElementById("top-bar-section").style.left == ""
      document.getElementById("top-bar-section").style.left = "-100%"
    else
      document.getElementById("top-bar-section").style.left = ""

  $scope.go = (hash) ->
    document.getElementById("top-bar").classList.remove("expanded")
    $location.path hash

  if $cookieStore.get($scope.tokenName)?
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'


  $scope.checkIntegrations = ->
    $http.get(
      "/api/v1/integrations?token=#{$cookieStore.get $scope.tokenName}"
    ).success((data, status, headers, config) ->
      if data.length == 0
        $scope.firstTipVisible = true
    ).error((data, status, headers, config) ->
    )

  $rootScope.checkRefreshingProjects = ->
   $http.get(
     "/api/v1/user?token=#{$cookieStore.get $scope.tokenName}"
   ).success((data, status, headers, config) ->
     $scope.refreshing = if data.user.refreshing? then data.user.refreshing else null
     setTimeout($rootScope.checkRefreshingProjects, 10000)
   ).error((data, status, headers, config) ->
     setTimeout($rootScope.checkRefreshingProjects, 10000)
   )
   if !$scope.$root.$$phase
     $scope.$apply()


  $scope.hideFirstTip = ->
    $scope.firstTipVisible = false

  $scope.$on "handleBroadcast", () ->
    if BroadcastService.message == 'recentClicked'
      $scope.getRunningTask()
    else if BroadcastService.message == 'TasksControllerStarted'
      $scope.initWebhookBox()

  $rootScope.pull = (value, element) ->
    if value && !$scope.menuIsDroppedDown
      $(element).hook(
        reloadPage: false,
        reloadEl: ->
          refreshWithPull()
        )
    else
      $(element).hook("destroy")

  $scope.initWebhookBox = ->
    if $location.path().indexOf('tasks') != -1
      $http.get(
        "api/v1/projects/#{$location.path().split('/')[2]}/pivotal_tracker_activity_web_hook_url?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.webhookProjectURL = data.url
        $rootScope.$broadcast("webhookProjectURLupdated")
      ).error((data, status, headers, config) ->
        $scope.webhookProjectURL = null
        $rootScope.$broadcast("webhookProjectURLupdated")
      )
    else
      $scope.webhookProjectURL = null
      $rootScope.$broadcast("webhookProjectURLupdated")

  $scope.$on '$routeChangeStart', $scope.initWebhookBox

  $scope.setAlsoWorking = ->
    $http.get(
      "/api/v1/projects/also_working?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.alsoWorking = if data == '' || Object.keys(data).length == 0 then [] else data
    ).error((data, status, headers, config) ->
    )

  if $cookieStore.get($scope.tokenName)?
    $scope.getRunningTask()
    $rootScope.checkRefreshingProjects()
    unless $scope.refreshing
      $scope.checkIntegrations()

  $scope.$on "$locationChangeSuccess", (event, currentLocation) ->
    if currentLocation.match(/projects$/) or currentLocation.match(/projects\/\d*\/tasks$/)
      $scope.setAlsoWorking()
    else
      $scope.alsoWorking = null
