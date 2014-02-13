KarmaTracker.controller "WebhooksController", ($scope, $http, $cookieStore, $location, $rootScope, $routeParams, FlashMessage) ->
  flashMessageService = FlashMessage

  $scope.checkWebHookPTIntegration = ->
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/pivotal_tracker_get_web_hook_integration?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.webhookPTIntegration = true if data['web_hook_exists']
    ).error((data, status, headers, config) ->
      $scope.webhookPTIntegration = false
    )

  $scope.createPTWebHookIntegration = ->
    $scope.webhookSpinner = true
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/pivotal_tracker_create_web_hook_integration?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      $scope.webhookPTIntegration = true
      $scope.webhookSpinner = false
      flashMessageService.notice "Pivotal Tracker WebHook Integration was added successfully"
    ).error((data, status, headers, config) ->
      $scope.webhookPTIntegration = false
      $scope.webhookSpinner = false
      flashMessageService.notice "Pivotal Tracker WebHook Integration failed"
    )

  $rootScope.$on "webhookProjectURLupdated", ->
    if $routeParams.project_id
      $scope.checkWebHookPTIntegration()

