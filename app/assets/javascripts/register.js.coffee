KarmaTracker.controller "RegisterController", ($scope, $http, $cookieStore, $location) ->
  $scope.registration = { email: null, password: null, confirmation: null }
  $scope.message = ''
  $scope.confirmation_message = ""
  $scope.errors = {}

  $scope.focusPassword = false

  $scope.registerFailure = (message) ->
    $scope.alert message
    $scope.registration.password = $scope.registration.confirmation = null

  $scope.formLooksValid = () ->
    valid = true
    $scope.errors = {}

    for field in ["email", "password", "confirmation"]
      unless $scope.registration[field]? and $scope.registration[field] != ''
        $scope.errors[field] = "can't be blank"
        valid = false

    if $scope.registration.password? && $scope.registration.confirmation? &&
       $scope.registration.password != $scope.registration.confirmation
      $scope.errors.confirmation = "does not match confirmation"
      valid = false

    if !valid
      $scope.registerFailure("Please correct the errors and try again")

    valid

  $scope.register = ->
    if $scope.formLooksValid()
      $http.post(
        '/api/v1/user',
        user: {
          email: $scope.registration.email,
          password: $scope.registration.password
        }
      ).success((data, status, headers, config) ->
        $scope.registration.email = $scope.registration.password = $scope.registration.confirmation = null
        $scope.confirmation_message = "An e-mail was sent to confirm your address, please check your mailbox and follow the instructions to log in."
      ).error((data, status, headers, config) ->
        $scope.registerFailure("Please correct the errors and try again")
        $scope.errors = {}
        for own key, messages of data.user.errors
          $scope.errors[key] = messages.join(", ")
      )

