KarmaTracker.controller "RefreshController", ($scope, $http, $cookieStore, $location, $rootScope) ->
  $http.get(
    '/api/v1/projects/refresh?token='+$cookieStore.get('token')
  ).success((data, status, headers, config) ->
    $rootScope.checkRefreshingProjects()
    $scope.refreshing = true
  ).error((data, status, headers, config) ->
    console.debug('Error refreshing projects')
  )
