KarmaTracker.controller "GitHubIntegrationsController",['$scope', '$http', '$cookieStore', '$location', 'Integration', ($scope, $http, $cookieStore, $location, Integration) ->
  $scope.integrations = []
  $scope.newIntegration = { username: null, password: null }
  $scope.addFormShown = false
  $scope.errors = {}
  $scope.tokenName = 'token'
  integrationService = new Integration

  $scope.updateIntegrations = ->
    integrationService.query('git_hub').$promise.then (result) ->
      $scope.integrations = result

  $scope.remove = (integration_id) ->
    if confirm("are you sure to remove github integration?")
      integrationService.remove(integration_id).$promise.then (result) ->
        index = $scope.integrations.map((integration) ->
          integration.git_hub.id
        ).indexOf(integration_id)
        $scope.integrations.splice(index, 1) if index > -1


  $scope.formLooksValid = () ->
    valid = true
    $scope.errors = {}

    unless $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
      for field in ["username", "password"]
        unless $scope.newIntegration[field]? and $scope.newIntegration[field] != ''
          $scope.errors[field] = "can't be blank"
          valid = false
    valid

  $scope.add = () ->
    if $scope.formLooksValid()
      if $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
        $http.post(
          '/api/v1/integrations/git_hub?token='+$cookieStore.get($scope.tokenName)+'&integration[username]='+$scope.newIntegration.username_token+'&integration[api_key]='+$scope.newIntegration.api_key
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          if data.git_hub.errors.api_key?
            $scope.errors.api_key = data.git_hub.errors.api_key[0]
          else
            $scope.errors.username_token = data.git_hub.errors.username[0]
            $scope.errors.api_key = data.git_hub.errors.password[0]
        )
      else
        $http.post(
          '/api/v1/integrations/git_hub?token='+$cookieStore.get($scope.tokenName)+'&integration[username]='+$scope.newIntegration.username+'&integration[password]='+$scope.newIntegration.password
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          $scope.newIntegration.username = ''
          $scope.newIntegration.password = ''
          if data.git_hub.errors.api_key?
            $scope.errors.password = data.git_hub.errors.api_key[0]
          else
            $scope.errors.password = data.git_hub.errors.password[0]
        )

  $scope.openAddForm = () ->
    $scope.addFormShown = !$scope.addFormShown
    $scope.cleanForm()

  $scope.cleanForm = () ->
    $scope.newIntegration.username = ''
    $scope.newIntegration.password = ''
    $scope.newIntegration.api_key = ''
    $scope.newIntegration.username_token = ''
    $scope.errors = {}


  $scope.updateIntegrations()

]
