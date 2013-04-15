window.KarmaTracker = angular.module('KarmaTracker', ['ngCookies'])

KarmaTracker.controller "SessionController", ($scope, $http, $cookies, $location) ->
  $scope.session = { email: null, password: null }
  $scope.message = ''

  $scope.signInSuccess = (token) ->
    $cookies.token = token
    $scope.message = 'Logged in, redirecting...'
    $scope.session.email = $scope.session.password = null
    window.location = '/'

  $scope.signInFailure = (message) ->
    $scope.message = message
    $scope.session.email = $scope.session.password = null

  $scope.signIn = ->
    $http.post(
      '/api/v1/session',
      session: {
        email: $scope.session.email,
        password: $scope.session.password
      }
    ).success((data, status, headers, config) ->
      $scope.signInSuccess(data.user.token)
    ).error((data, status, headers, config) ->
      $scope.signInFailure(data.message)
    )

KarmaTracker.controller "RootController", ($scope, $location, $cookies) ->
  if typeof($cookies.token) == 'undefined'
    return if $location.path() == '/login'
    $location.path '/login'
  else
    return if $location.path() == '/logout'
    $scope.signed_in = true
    if $location.path() == '/' || $location.path() == ''
      $location.path '/projects'

KarmaTracker.controller "LogoutController", ($scope, $location, $cookies) ->
  delete $cookies['token']
  window.location = '/'

KarmaTracker.config ($routeProvider) ->
  $routeProvider.when('/',
    template: 'Loading...'
  ).when("/login",
    controller: 'SessionController',
    templateUrl: '/session.html'
  ).when('/logout',
    controller: 'LogoutController',
    template: 'Logging out...'
  )


