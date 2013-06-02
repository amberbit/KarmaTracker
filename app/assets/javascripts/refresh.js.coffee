KarmaTracker.controller "RefreshController", ($scope, $http, $cookies, $location) ->
  $http.get(
    '/api/v1/projects/refresh?token='+$cookies.token
  ).success((data, status, headers, config) ->
  ).error((data, status, headers, config) ->
    console.debug('Error refreshing projects')
  )


