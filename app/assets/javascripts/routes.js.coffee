KarmaTracker.config ($routeProvider) ->
  $routeProvider.when('/',
    template: 'Loading...'
  ).when("/login",
    controller: 'SessionController',
    templateUrl: '/session.html'
  ).when('/logout',
    controller: 'LogoutController',
    template: 'Logging out...'
  )

