KarmaTracker.controller "RefreshController", ($scope, $http, $cookieStore, $location) ->
  $http.get(
    '/api/v1/projects/refresh?token='+$cookieStore.get('token')
  ).success((data, status, headers, config) ->
  ).error((data, status, headers, config) ->
    console.debug('Error refreshing projects')
  )


