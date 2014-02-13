KarmaTracker.controller "SessionController", ($scope, $http, $cookieStore, $location, $routeParams, $rootScope, $timeout) ->
  $rootScope.pullAllowed = false

  $scope.session = { email: null, password: null, remember_me: false }
  $scope.message = ''
  $scope.errors = {}
  $scope.confirmation_message = ""
  $scope.focusPassword = false
  $scope.registrationEnabled = KarmaTrackerConfig.registration_enabled
  $scope.tokenName = 'token'

  $scope.signInSuccess = (token, remember_me) ->
    if remember_me
      $cookieStore.set 'token', token, { expires: 30 }
    else
      $cookieStore.set 'token', token
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
        email: $scope.session.email
        password: $scope.session.password
      }
    ).success((data, status, headers, config) ->
      $scope.signInSuccess data.token, $scope.session.remember_me
    ).error((data, status, headers, config) ->
      $scope.signInFailure data.message
    )


  if $routeParams.confirmation_token?
    $http.get(
      '/api/v1/user/confirm?confirmation_token='+$routeParams.confirmation_token
    ).success((data, status, headers, config) ->
      $scope.confirmation_message = "Your e-mail is now confirmed, please sign in."
    ).error((data, status, headers, config) ->
      $scope.confirmation_message = "Confirmation token provided is not valid, or your e-mail is already confirmed. Please, sign in."
    )

  if $location.path().endsWith('/oauth') && $routeParams.email? && $routeParams.oauth_token?
    $rootScope.loading = true
    $timeout (->
      $http.post(
        '/api/v1/session/oauth_verify',
        {
          email: $routeParams.email
          token: $routeParams.oauth_token
        }
      ).success((data, status, headers, config) ->
        $rootScope.loading = false
        $scope.signInSuccess data.token
      ).error((data, status, headers, config) ->
        $rootScope.loading = false
        $scope.signInFailure data.message
      )
    ), 2000


KarmaTracker.controller "LogoutController", ($scope, $location, $cookieStore) ->
  $cookieStore.remove 'token'
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
