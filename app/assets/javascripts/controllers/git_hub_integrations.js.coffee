KarmaTracker.controller "GitHubIntegrationsController",['$scope', 'Integration', ($scope, Integration) ->
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

  $scope.formLooksValid = ->
    valid = true
    $scope.errors = {}

    unless $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
      for field in ["username", "password"]
        unless $scope.newIntegration[field]? and $scope.newIntegration[field] != ''
          $scope.errors[field] = "can't be blank"
          valid = false
    valid

  $scope.add = ->
    if $scope.formLooksValid()
      $scope.newIntegration['type'] = 'git_hub'
      integrationService.save($scope.newIntegration).$promise
        .then (result) ->
          $scope.openAddForm()
          $scope.integrations.push result
        .catch (response) ->
          data = response.data.git_hub
          if data.errors.api_key?
            $scope.errors.api_key = data.errors.api_key[0]
          else
            $scope.errors.username_token = data.errors.username[0]
            $scope.errors.api_key = data.errors.password[0]


  $scope.openAddForm = ->
    $scope.addFormShown = !$scope.addFormShown
    $scope.cleanForm()

  $scope.cleanForm = ->
    $scope.newIntegration.username = ''
    $scope.newIntegration.password = ''
    $scope.newIntegration.api_key = ''
    $scope.newIntegration.username_token = ''
    $scope.errors = {}


  $scope.updateIntegrations()

]
