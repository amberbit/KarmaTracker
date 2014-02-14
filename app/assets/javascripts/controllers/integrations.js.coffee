KarmaTracker.controller "IntegrationsController", ($scope, $http, $cookieStore, $location, $rootScope, Integration) ->
  $rootScope.pullAllowed = false

  integrationTypeService = (name, token_name, api_section, api_section_url) ->
    name: name
    integrations: []
    newIntegration: {username: null, password: null, api_key: null}
    addFormShown: false
    errors: {}
    token_name: token_name
    api_section: api_section
    api_section_url: api_section_url

  $scope.integrationTypes = {
    'pivotal_tracker': integrationTypeService("Pivotal Tracker", "API token", "Profile / API Token", "https://www.pivotaltracker.com/profile#api")
    'git_hub': integrationTypeService("Git Hub", "Personal Access Token", "AccountSettings / Applications", "https://github.com/settings/applications")
  }
  integrationService = new Integration

  updateIntegrationsFor = (type, service) ->
    integrationService.query(type).$promise.then (result) ->
      service.integrations = result

  $scope.updateIntegrations = ->
    for type, service of $scope.integrationTypes
      updateIntegrationsFor(type,service)

  $scope.remove = (integration_id, service) ->
    if confirm("Are you sure you want to remove #{service.name} integration")
      integrationService.remove(integration_id).$promise.then (result) ->
        index = service.integrations.map((integration) ->
          integration.id
        ).indexOf(integration_id)
        service.integrations.splice(index, 1) if index > -1

  $scope.formLooksValid = (service) ->
    valid = true
    service.errors = {}

    unless service.newIntegration.api_key? and service.newIntegration.api_key != ''
      for field in ["username", "password"]
        unless service.newIntegration[field]? and service.newIntegration[field] != ''
          service.errors[field] = "can't be blank"
          valid = false
    valid

  $scope.add = (type, service) ->
    if $scope.formLooksValid(service)
      service.newIntegration['type'] = type
      integrationService.save(service.newIntegration).$promise
        .then (result) ->
          $scope.openAddForm(service)
          service.integrations.push result
        .catch (response) ->
          data = response.data
          if data.errors.api_key?
            service.errors.api_key = data.errors.api_key[0]
          else
            service.errors.username = data.errors.username[0] if data.errors.username?
            service.errors.password = data.errors.password[0] if data.errors.password?


  $scope.openAddForm = (service) ->
    service.addFormShown = !service.addFormShown
    $scope.cleanForm(service)

  $scope.cleanForm = (service) ->
    service.newIntegration.username = ''
    service.newIntegration.password = ''
    service.newIntegration.api_key = ''
    service.errors = {}


  $scope.updateIntegrations()
