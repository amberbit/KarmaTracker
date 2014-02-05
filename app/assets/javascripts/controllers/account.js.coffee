KarmaTracker.controller "AccountController",['$scope', '$http', '$cookieStore', '$location', '$rootScope', '$resource', 'User', ($scope, $http, $cookieStore, $location, $rootScope, $resource, User) ->
  $rootScope.pullAllowed = false
  $scope.enabledDestroy = KarmaTrackerConfig.registration_destroy
  $scope.user = {}
  $scope.errors = {}
  $scope.newEmail = ""
  $scope.newPassword = ""
  $scope.confirmation = ""
  $scope.message = ''
  $scope.tokenName = 'token'
  userService = new User

  $scope.getUserInfo = ->
    userService.get().$promise.then (result) ->
      $scope.user = result.user

  $scope.remove = ->
    if confirm("Are you sure to delete your account?")
      userService.remove().$promise.then (result) ->
        $scope.user = {}
        $location.path 'logout'

  $scope.changeEmail = ->
    if !$scope.newEmail? or $scope.newEmail != ''
      $http.put(
        "/api/v1/user?token="+$cookieStore.get($scope.tokenName)+"&user[email]="+$scope.newEmail
      ).success((data, status, headers, config) ->
      ).error((data, status, headers, config) ->
        $scope.errors.email = data.user.errors.email[0]
      )
    else

  $scope.updateUser = (user) ->
    if !$scope.user.email? or $scope.user.email != ''
      userService.update(user).$promise
        .then (result) ->
          $scope.success("User successfully updated")
          $scope.getUserInfo()
        .catch (reason) ->
          console.log "a" + reason
          $scope.errors.email = "can't be blank"


  $scope.changePassword = ->
    $scope.errors = {}
    if !$scope.newPassword? or $scope.newPassword != ''
      if $scope.newPassword == $scope.confirmation
        $http.put(
          "/api/v1/user",
          token: $cookieStore.get $scope.tokenName,
          user: {
            password: $scope.newPassword
          }
        ).success((data, status, headers, config) ->
          $scope.success("Password successfully changed")
          $scope.getUserInfo()
          $scope.newPassword = ""
          $scope.confirmation = ""
        ).error((data, status, headers, config) ->
          $scope.errors.password = data.user.errors.password[0]
        )
      else
        if !$scope.confirmation? or $scope.confirmation != ''
          $scope.errors.confirmation = "can't be blank"
        else
          $scope.errors.confirmation = "passwords does not match"

    else
      $scope.errors.password = "can't be blank"


  $scope.getUserInfo()
]
