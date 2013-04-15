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

KarmaTracker.controller "LogoutController", ($scope, $location, $cookies) ->
  delete $cookies['token']
  window.location = '/'

