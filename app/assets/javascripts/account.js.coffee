KarmaTracker.controller "AccountController", ($scope, $http, $cookies, $location) ->
  $scope.enabledDestroy = KarmaTrackerConfig.registration_destroy
  $scope.user = {}
  $scope.errors = {}
  $scope.newEmail = ""
  $scope.newPassword = ""
  $scope.confirmation = ""
  $scope.message = ''

  $scope.getUserInfo = () ->
    $http.get(
      '/api/v1/user?token='+$cookies.token
    ).success((data, status, headers, config) ->
      $scope.user = data.user
    ).error((data, status, headers, config) ->
    )

  $scope.remove = () ->
    if confirm("Are you sure to delete your account?")
      $http.delete(
        '/api/v1/user?token='+$cookies.token
      ).success((data, status, headers, config) ->
        window.location = '#/logout'
      ).error((data, status, headers, config) ->
      )

  $scope.changeEmail = () ->
    if !$scope.newEmail? or $scope.newEmail != ''
      $http.put(
        "/api/v1/user?token="+$cookies.token+"&user[email]="+$scope.newEmail
      ).success((data, status, headers, config) ->
        $scope.success("E-mail successfully changed")
        $scope.getUserInfo()
        $scope.newEmail = ""
      ).error((data, status, headers, config) ->
        $scope.errors.email = data.user.errors.email[0]
      )
    else
      $scope.errors.email = "can't be blank"

  $scope.changePassword = () ->
    $scope.errors = {}
    if !$scope.newPassword? or $scope.newPassword != ''
      if $scope.newPassword == $scope.confirmation
        $http.put(
          "/api/v1/user",
          token: $cookies.token,
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
