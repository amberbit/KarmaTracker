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

    unless $scope.newIdentity.api_key? and $scope.newIdentity.api_key != ''
      for field in ["username", "password"]
        unless $scope.newIdentity[field]? and $scope.newIdentity[field] != ''
          $scope.errors[field] = "can't be blank"
          valid = false




    valid

  $scope.add = () ->
    if $scope.formLooksValid()
      if $scope.newIdentity.api_key? and $scope.newIdentity.api_key != ''
        $http.post(
          '/api/v1/identities/git_hub?token='+$cookies.token+'&identity[name]='+$scope.newIdentity.name+'&identity[username]='+$scope.newIdentity.username_token+'&identity[api_key]='+$scope.newIdentity.api_key
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIdentities()
        ).error((data, status, headers, config) ->
          console.debug data
          if data.git_hub.errors.api_key?
            $scope.errors.api_key = data.git_hub.errors.api_key[0]
          else
            $scope.errors.username_token = data.git_hub.errors.username[0]
            $scope.errors.api_key = data.git_hub.errors.password[0]
        )
      else
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
    $scope.newIdentity.api_key = ''
    $scope.newIdentity.username_token = ''
    $scope.errors = {}


  $scope.updateIdentities()
