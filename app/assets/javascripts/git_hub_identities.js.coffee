KarmaTracker.controller "GitHubIdentitiesController", ($scope, $http, $cookies, $location) ->
  $scope.identities = []
  $scope.newIdentity = { name: null, username: null, password: null }
  $scope.addFormShown = false
  $scope.errors = {}

  $scope.updateIdentities = () ->
    $http.get(
      '/api/v1/identities?token='+$cookies.token+'&service=git_hub'
    ).success((data, status, headers, config) ->
      $scope.identities = data
    ).error((data, status, headers, config) ->
    )

  $scope.remove = (name, id) ->
    answer = confirm("Are you sure to remove '"+name+"'?")
    if answer
      $http.delete(
        '/api/v1/identities/'+id+'?token='+$cookies.token
      ).success((data, status, headers, config) ->
        $scope.updateIdentities()
      ).error((data, status, headers, config) ->
      )

  $scope.formLooksValid = () ->
    valid = true
    $scope.errors = {}

    if !$scope.newIdentity.name? or $scope.newIdentity.name == ''
      $scope.errors['name'] = "can't be blank"
      valid = false

    for field in ["username", "password"]
      unless $scope.newIdentity[field]? and $scope.newIdentity[field] != ''
        $scope.errors[field] = "can't be blank"
        valid = false

    valid

  $scope.add = () ->
    if $scope.formLooksValid()
      $http.post(
        '/api/v1/identities/git_hub?token='+$cookies.token+'&identity[name]='+$scope.newIdentity.name+'&identity[username]='+$scope.newIdentity.username+'&identity[password]='+$scope.newIdentity.password
      ).success((data, status, headers, config) ->
        $scope.cleanForm()
        $scope.openAddForm()
        $scope.updateIdentities()
      ).error((data, status, headers, config) ->
        console.debug data
        $scope.newIdentity.username = ''
        $scope.newIdentity.password = ''
        if data.git_hub.errors.api_key?
          $scope.errors.password = data.git_hub.errors.api_key[0]
        else
          $scope.errors.password = data.git_hub.errors.password[0]
      )

  $scope.openAddForm = () ->
    $scope.addFormShown = !$scope.addFormShown
    $scope.cleanForm()

  $scope.cleanForm = () ->
    $scope.newIdentity.name  = ''
    $scope.newIdentity.username = ''
    $scope.newIdentity.password = ''
    $scope.newIdentity.api_key =''
    $scope.errors = {}


  $scope.updateIdentities()
