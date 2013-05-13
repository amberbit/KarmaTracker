#= require_self
#= require routes
#= require sessions
#= require projects
#= require refresh
#= require register
#= require integrations
#= require pivotal_tracker_identities
#= require tasks
#= require flashes

window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies'])

# Flashe message passed from other controllers to FlashesController
KarmaTracker.factory "FlashMessage", ->
  { string: "", type: null }

# Root controller handles authorization
# will redirect user to login page if $cookie.token is not set
# otherwise, will redirect user to projects listing
KarmaTracker.controller "RootController", ($scope, $location, $cookies, FlashMessage) ->
  $scope.matchesQuery = (string) ->
    string.toLowerCase().indexOf($scope.query.string.toLowerCase()) != -1

  $scope.query = {}

  $scope.notice = (message) ->
    FlashMessage.type = null
    FlashMessage.string = message

  $scope.alert = (message) ->
    FlashMessage.type = 'alert'
    FlashMessage.string = message



  if typeof($cookies.token) == 'undefined'
    return if $location.path() == '/login'
    $location.path '/login'
  else
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'


