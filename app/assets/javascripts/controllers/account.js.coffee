KarmaTracker.controller "AccountController",['$scope', '$location', '$rootScope', 'User', 'FlashMessage', ($scope, $location, $rootScope, User, FlashMessage) ->
  $rootScope.pullAllowed = false
  $scope.enabledDestroy = KarmaTrackerConfig.registration_destroy
  $scope.user = {}
  $scope.message = ''
  $scope.tokenName = 'token'
  userService = new User
  flashMessageService = FlashMessage

  $scope.getUserInfo = ->
    $scope.newEmail = $scope.newPassword = $scope.newPasswordConfirmation = null
    $scope.errors = {}
    userService.get().$promise.then (result) ->
      $scope.user = result.user

  $scope.remove = ->
    if confirm("Are you sure to delete your account?")
      userService.remove().$promise.then (result) ->
        $scope.user = {}
        $location.path 'logout'

  $scope.updateUser = (user) ->
    if $scope.newEmail? or ($scope.newPassword? and $scope.newPassword? != '' and $scope.newPassword == $scope.newPasswordConfirmation)
      user.email = $scope.newEmail if $scope.newEmail?
      user.password = $scope.newPassowrd if $scope.newPassword?
      userService.update(user).$promise
        .then (result) ->
          flashMessageService.success("User successfully updated")
          $scope.getUserInfo()
        .catch (response) ->
          $scope.errors.newEmail =  response.data.errors.email[0] if response.data.errors.email?
    else if $scope.newPassword?
      $scope.errors.newPasswordConfirmation = "Passwords don't match or password confirmation is blank"

  $scope.getUserInfo()
]
