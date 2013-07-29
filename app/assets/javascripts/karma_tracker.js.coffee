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

window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies', 'ngMobile'])


# Flashe message passed from other controllers to FlashesController
KarmaTracker.factory "FlashMessage", ->
  { string: "", type: null }

KarmaTracker.controller "RootController", ($scope, $http, $location, $cookieStore, $routeParams, FlashMessage, broadcastService, $rootScope) ->
  $rootScope.pullAllowed = true
  $scope.runningTask = {}
  $scope.runningVisible = false
  $scope.firstTipVisible = false
  $scope.tokenName = 'token'
  $scope.menuIsDroppedDown = document.getElementById("top-bar").classList.contains("expanded")
  $scope.matchesQuery = (string) ->
    string.toLowerCase().indexOf($scope.query.string.toLowerCase()) != -1

  $scope.query = {}
  
  refreshProjects = () ->
    $http.get(
      '/api/v1/projects/refresh?token='+$cookieStore.get('token')
    ).success((data, status, headers, config) ->
      window.location.reload(true)
    ).error((data, status, headers, config) ->
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

  $scope.getRunningTask = () ->
    $http.get(
        "/api/v1/tasks/running?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.runningTask = data.task
        $scope.runningVisible = true
      ).error((data, status, headers, config) ->
        $scope.runningTask = {}
        $scope.runningVisible = false
      )

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

  $scope.stopTracking = (task) ->
    if task.running
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())
      ).error((data, status, headers, config) ->
      )

  $scope.highlightCurrentPage = (url) ->
    if $location.url().indexOf(url) != -1
      return "current"
    else
      return ""

  $scope.expandMenu = () ->
    if window.getComputedStyle(document.getElementById("toggle-menu")).getPropertyValue("display") != "none"
      document.getElementById("top-bar").classList.toggle("expanded")
      $scope.menuIsDroppedDown = document.getElementById("top-bar").classList.contains("expanded")
      element = $("div").find("[pull-to-refresh]")
      $rootScope.$watch("pullAllowed", (value) ->
        $rootScope.pull(value, element)
      , true)
    
    

  $scope.moveMenu = () ->
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
  else
    return if $location.path() == '/login' ||
      $location.path() == '/password_reset' ||
      /\/edit_password_reset(\/.*)?/.test $location.path()
    $location.path '/login'


  $scope.checkIdentities = () ->
    $http.get(
      "/api/v1/identities?token=#{$cookieStore.get $scope.tokenName}"
    ).success((data, status, headers, config) ->
      if data.length == 0
        $scope.firstTipVisible = true

    ).error((data, status, headers, config) ->
    )

    $scope.hideFirstTip = () ->
      $scope.firstTipVisible = false

  $scope.$on "handleBroadcast", () ->
    if broadcastService.message == 'recentClicked'
      $scope.getRunningTask()
 
  $rootScope.pull = (value, element) ->
    if value && !$scope.menuIsDroppedDown
      $(element).hook(
        reloadPage: false,
        reloadEl: ->
          refreshProjects()
        )
    else
      $(element).hook("destroy")
      
      
  $scope.getRunningTask()
  $scope.checkIdentities()


KarmaTracker.directive "pullToRefresh", ($rootScope) ->
  {
    restrict: "A",
    link: (scope, element, attrs) ->
      $rootScope.$watch("pullAllowed", (value) ->
        $rootScope.pull(value, element)
      , true)
  }



# This controller just has to redirect user to proper place
KarmaTracker.controller "HomeController", ($scope, $http, $location, $cookieStore, FlashMessage) ->
  if $cookieStore.get($scope.tokenName)?
    $location.path '/projects'
  else
    $location.path '/login'

KarmaTracker.factory 'broadcastService', ($rootScope) ->
  broadcastService = {message: ""}

  broadcastService.prepForBroadcast = (msg) ->
    @message = msg
    @broadcastItem()

  broadcastService.broadcastItem = () ->
    $rootScope.$broadcast('handleBroadcast')

  broadcastService

