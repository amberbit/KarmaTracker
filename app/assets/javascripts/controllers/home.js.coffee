# This controller just has to redirect user to proper place
KarmaTracker.controller "HomeController", ($scope, $http, $location, $cookieStore, FlashMessage) ->
  if $cookieStore.get($scope.tokenName)?
    return if $location.path() != '/'
    $location.path '/projects'
  else
    return if $location.path().match(/oauth/) ||
      $location.path() == '/login' ||
      $location.path() == '/password_reset' ||
      /\/edit_password_reset(\/.*)?/.test $location.path()
    $location.path '/login'


