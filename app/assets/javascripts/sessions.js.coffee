KarmaTracker.controller "SessionController", ($scope, $http, $cookies, $location) ->
  $scope.session = { email: null, password: null }
  $scope.message = ''
  $scope.focusPassword = false

  $scope.signInSuccess = (token) ->
    $cookies.token = token
    $scope.session.email = $scope.session.password = null
    window.location = '/'

  $scope.signInFailure = (message) ->
    $scope.alert message
    $scope.session.password = null

    if $scope.session.email != '' && $scope.session.email != null
      $scope.focus_email = -Math.random()*100
      $scope.focus_password = Math.random()*100
    else
      $scope.focus_password = -Math.random()*100
      $scope.focus_email = Math.random()*100

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


KarmaTracker.directive "focus", ->
  {
    restrict: "A",
    scope: { focus: "@"},
    link: (scope, element, attrs) ->
      scope.$watch("focus", (value) ->
        if parseInt(value) > 0
          element[0].focus()
      )
  }
