KarmaTracker.controller "PasswordResetsController", ($scope, $http, $location, $routeParams, FlashMessage, $rootScope) ->
  $rootScope.pullAllowed = false
  $scope.errors = {}
  $scope.data = { password: null, password_confirmation: null }

  $scope.resetPassword = ->
    $scope.password_reset = null
    $scope.errors.email = null
    if $scope.private.validateEmail($scope.email)
      $http(
        url: '/api/v1/password_reset'
        method: 'post'
        params: {
          email: $scope.email
        }
      ).success((data, status, headers, config) ->
        $scope.private.redirect_to_main(data.message, 'success')
      ).error((data, status, headers, config) ->
      )
    else
      $scope.errors.email = 'Email is invalid'

  $scope.changePassword = ->
    $scope.errors.password = null
    $scope.private.validatePassword($scope.data.password, $scope.data.password_confirmation)

  $scope.private = {
    validateEmail: (email) ->
      regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      regex.test email

    validatePassword: (password, confirmation) ->
      if !password? || password.length < 6
        $scope.errors.password = 'Password too short, minimal length is 6 characters'
      else if password != confirmation
        $scope.errors.password = 'Password and confirmation are NOT identical'
      else
        token = $routeParams.token
        $http(
          url: '/api/v1/password_reset'
          method: 'put'
          params: {
            token: token
            password: password
            confirmation: confirmation
          }
        ).success((data, status, headers, config) ->
          $scope.private.redirect_to_main(data, 'success')
        ).error((data, status, headers, config) ->
          $scope.private.redirect_to_main(data.message, 'alert')
        )

    redirect_to_main: (message, type) ->
      FlashMessage.type = type
      FlashMessage.string = message
      $scope.goToLink '/'
  }
