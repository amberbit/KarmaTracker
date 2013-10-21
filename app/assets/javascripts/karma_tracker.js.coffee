#= require_self
#= require routes
#= require sessions
#= require projects
#= require refresh
#= require register
#= require identities
#= require pivotal_tracker_identities
#= require git_hub_identities
#= require account
#= require timesheet
#= require tasks
#= require flashes
#= require recents
#= require password_resets
#= require cookieStore_override

window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies', 'ngMobile', 'ngRoute', 'ui.bootstrap'])


# Flashe message passed from other controllers to FlashesController
KarmaTracker.factory "FlashMessage", ->
  { string: "", type: null }

KarmaTracker.controller "RootController", ($scope, $http, $location, $cookieStore, $routeParams, FlashMessage, broadcastService, $rootScope, $timeout) ->
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
  $scope.location = null


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
      ).error((data, status, headers, config) ->
        console.debug("Error refreshing project #{$location.path().split('/')[2]}")
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
      ).error((data, status, headers, config) ->
        console.debug('Error refreshing projects')
        $scope.refreshing = false
        $rootScope.loading = false
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
        console.debug("Error refreshing project #{$location.path().split('/')[2]}")
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
        console.debug('Error refreshing projects')
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


  $scope.checkIdentities = ->
    $http.get(
      "/api/v1/identities?token=#{$cookieStore.get $scope.tokenName}"
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
    if broadcastService.message == 'recentClicked'
      $scope.getRunningTask()

  $rootScope.pull = (value, element) ->
    if value && !$scope.menuIsDroppedDown
      $(element).hook(
        reloadPage: false,
        reloadEl: ->
          refreshWithPull()
        )
    else
      $(element).hook("destroy")

  $scope.$on '$routeChangeStart', ->
    if $location.path().indexOf('tasks') != -1
      $http.get(
        "api/v1/projects/#{$location.path().split('/')[2]}/pivotal_tracker_activity_web_hook_url?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.webhookProjectURL = data.url
      ).error((data, status, headers, config) ->
        $scope.webhookProjectURL = null
      )
    else
      $scope.webhookProjectURL = null

  $scope.setAlsoWorking = ->
    $http.get(
      "/api/v1/projects/also_working?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.alsoWorking = if data == '' || Object.keys(data).length == 0 then [] else data
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

  if $cookieStore.get($scope.tokenName)?
    $scope.getRunningTask()
    $scope.checkIdentities()
    $rootScope.checkRefreshingProjects()

  $scope.$on "$locationChangeSuccess", (event, currentLocation) ->
    if currentLocation.match(/projects$/) or currentLocation.match(/projects\/\d*\/tasks$/)
      $scope.setAlsoWorking()
    else
      $scope.alsoWorking = null


KarmaTracker.directive "pullToRefresh", ($rootScope) ->
  {
    restrict: "A",
    link: (scope, element, attrs) ->
      $rootScope.$watch("pullAllowed", (value) ->
        $rootScope.pull(value, element)
      , true)
  }


KarmaTracker.filter 'startFrom', ->
  (input, start) ->
    start = +start
    input.slice start 


# This controller just has to redirect user to proper place
KarmaTracker.controller "HomeController", ($scope, $http, $location, $cookieStore, FlashMessage) ->
  if !$cookieStore.get($scope.tokenName)?
    return if $location.path().match(/oauth/) ||
      $location.path() == '/login' ||
      $location.path() == '/password_reset' ||
      /\/edit_password_reset(\/.*)?/.test $location.path()
    $location.path '/login'

KarmaTracker.factory 'broadcastService', ($rootScope) ->
  broadcastService = {message: ""}

  broadcastService.prepForBroadcast = (msg) ->
    @message = msg
    @broadcastItem()

  broadcastService.broadcastItem = ->
    $rootScope.$broadcast('handleBroadcast')

  broadcastService
