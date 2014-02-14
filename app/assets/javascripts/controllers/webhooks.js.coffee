KarmaTracker.controller "WebhooksController", ['$scope', '$http', '$cookieStore', '$location', '$rootScope', '$routeParams', 'FlashMessage', ($scope, $http, $cookieStore, $location, $rootScope, $routeParams, FlashMessage) ->
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

  initWebhookBox = ->
    if $location.path().match(/^\/projects\/\d+\/tasks$/)?
      $http.get(
        "api/v1/projects/#{$location.path().split('/')[2]}/pivotal_tracker_activity_web_hook_url?token=#{$cookieStore.get $scope.tokenName}"
      ).success((data, status, headers, config) ->
        $scope.webhookProjectURL = data.url
      ).error((data, status, headers, config) ->
        $scope.webhookProjectURL = null
        $rootScope.$broadcast("webhookProjectURLupdated")
      )
    else
      $scope.webhookProjectURL = null
      $rootScope.$broadcast("webhookProjectURLupdated")

  $scope.$on '$routeChangeStart', initWebhookBox

]
