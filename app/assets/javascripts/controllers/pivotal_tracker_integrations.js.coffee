KarmaTracker.controller "PivotalTrackerIntegrationsController", ($scope, $http, $cookieStore, $location) ->
  $scope.integrations = []
  $scope.newIntegration = { api_key: null, email: null, password: null }
  $scope.addFormShown = false
  $scope.errors = {}
  $scope.tokenName = 'token'

  $scope.updateIntegrations = ->
    $http.get(
      '/api/v1/integrations?token='+$cookieStore.get($scope.tokenName)+'&service=pivotal_tracker'
    ).success((data, status, headers, config) ->
      $scope.integrations = data
    ).error((data, status, headers, config) ->
    )

  $scope.remove = (id) ->
    answer = confirm("Are you sure to remove Pivotal Tracker Integration?")
    if answer
      $http.delete(
        '/api/v1/integrations/'+id+'?token='+$cookieStore.get($scope.tokenName)+'&service=pivotal_tracker'
      ).success((data, status, headers, config) ->
        $scope.updateIntegrations()
      ).error((data, status, headers, config) ->
      )

  $scope.formLooksValid = () ->
    valid = true
    $scope.errors = {}

    unless $scope.newIntegration.api_key? or $scope.newIntegration.api_key == ''
      for field in ["email", "password"]
        unless $scope.newIntegration[field]? and $scope.newIntegration[field] != ''
          $scope.errors[field] = "can't be blank"
          valid = false

    valid

  $scope.add = () ->
    if $scope.formLooksValid()
      if $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
        $http.post(
          '/api/v1/integrations/pivotal_tracker?token='+$cookieStore.get($scope.tokenName)+'&integration[api_key]='+$scope.newIntegration.api_key
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          $scope.errors['api_key'] = data.pivotal_tracker.errors.api_key[0]
        )
      else
        $http.post(
          '/api/v1/integrations/pivotal_tracker?token='+$cookieStore.get($scope.tokenName)+'&integration[email]='+$scope.newIntegration.email+'&integration[password]='+$scope.newIntegration.password
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          $scope.newIntegration.email = ''
          $scope.newIntegration.password = ''
          if data.pivotal_tracker.errors.api_key?
            $scope.errors.password = data.pivotal_tracker.errors.api_key[0]
          else
            $scope.errors.password = data.pivotal_tracker.errors.password[0]
        )

  $scope.openAddForm = () ->
    $scope.addFormShown = !$scope.addFormShown
    $scope.cleanForm()

  $scope.cleanForm = () ->
    $scope.newIntegration.email = ''
    $scope.newIntegration.password = ''
    $scope.newIntegration.api_key =''
    $scope.errors = {}


  $scope.updateIntegrations()
