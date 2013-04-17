#= require_self
#= require routes
#= require sessions
#= require projects
#= require tasks

window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies'])

# Root controller handles authorization
# will redirect user to login page if $cookie.token is not set
# otherwise, will redirect user to projects listing
KarmaTracker.controller "RootController", ($scope, $location, $cookies) ->
  if typeof($cookies.token) == 'undefined'
    return if $location.path() == '/login'
    $location.path '/login'
  else
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'

  $scope.matchesQuery = (string) ->
    string.toLowerCase().indexOf($scope.query.string.toLowerCase()) != -1


  $scope.query = {}
