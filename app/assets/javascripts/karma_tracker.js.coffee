#= require_self
#= require routes
#= require sessions
#= require projects
#= require refresh
#= require register
#= require integrations
#= require pivotal_tracker_identities
#= require git_hub_identities
#= require account
#= require timelog
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

  $scope.success = (message) ->
    FlashMessage.type = 'success'
    FlashMessage.string = message


  $scope.openProject = (source, name, identifier) ->
    if source == 'GitHub'
      window.open('http://github.com/' + name, '_blank')
    else
      window.open('http://pivotaltracker.com/s/projects/' + identifier, '_blank')

  $scope.openTask = (source, name, identifier, task) ->
    if source == 'GitHub'
      window.open('http://github.com/' + name + '/issues/' + task.split("/")[1], '_blank')
    else
      window.open('http://pivotaltracker.com/s/projects/' + identifier + '/stories/' + task, '_blank')

  if typeof($cookies.token) == 'undefined'
    return if $location.path() == '/login'
    $location.path '/login'
  else
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'


