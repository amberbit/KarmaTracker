KarmaTracker.controller "TopBarController", ['$scope', 'User', '$location', ($scope, User, $location) ->
  $scope.user = {}
  userService = new User

  $scope.getUserInfo = ->
    if (requestResult = userService.get())?
      requestResult.$promise.then (result) ->
        $scope.gravatar_url = result.gravatar_url
        $scope.username = result.email.split('@')[0].split(/\.|-|_/).join(" ")
        $scope.username = $scope.username.replace /\w+/g, (str) ->
          str.charAt(0).toUpperCase() + str.substr(1).toLowerCase()

  $scope.highlightCurrentPage = (url) ->
    if $location.url().indexOf(url) != -1
      return "current"
    else
      return ""


  $scope.getUserInfo()
]
