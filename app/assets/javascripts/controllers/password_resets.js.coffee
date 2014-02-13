KarmaTracker.controller "PasswordResetsController", ['$scope', '$routeParams', 'FlashMessage', '$rootScope', 'PasswordReset', '$location', ($scope, $routeParams, FlashMessage, $rootScope, PasswordReset, $location) ->
  $rootScope.pullAllowed = false
  $scope.errors = {}
  $scope.data = { password: null, password_confirmation: null }
  passwordResetService = new PasswordReset

  $scope.resetPassword = ->
    $scope.password_reset = null
    $scope.errors.email = null
    if validateEmail($scope.email)
      passwordResetService.create($scope.email).$promise.then (result) ->
        redirect_to_main(result.message, 'success')
    else
      $scope.errors.email = 'Email is invalid'

  $scope.changePassword = ->
    $scope.errors.password = null
    validatePasswords($scope.data.password, $scope.data.password_confirmation)

  validateEmail = (email) ->
      regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      regex.test email

  validatePasswords = (password, confirmation) ->
    if !password? || password.length < 6
      $scope.errors.password = 'Password too short, minimal length is 6 characters'
    else if password != confirmation
      $scope.errors.password = 'Password and confirmation are NOT identical'
    else
      token = $routeParams.token
      passwordResetService.update(token, password, confirmation).$promise
        .then (result) ->
          console.log result
          redirect_to_main(result.message, 'success')
        .catch (result) ->
          redirect_to_main(result.message, 'alert')

  redirect_to_main = (message, type) ->
    FlashMessage.type = type
    FlashMessage.string = message
    $location.path '/'
]
