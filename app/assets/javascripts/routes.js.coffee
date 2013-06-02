KarmaTracker.config ($routeProvider) ->
  $routeProvider.when('/',
    template: 'Loading...'
  ).when("/login",
    templateUrl: '/session.html'
  ).when('/logout',
    controller: 'LogoutController',
    template: '<div class="row">
                 <div class="small-12 columns"><h5>Logging out...</h5></div>
               <div>'
  ).when("/projects",
    templateUrl: '/projects.html'
  ).when("/projects/:project_id/tasks",
    templateUrl: '/tasks.html'
  ).when('/refresh',
    templateUrl: '/refresh.html'
  ).when('/integrations',
    templateUrl: '/integrations.html'
  ).when('/account',
    templateUrl: '/account.html'
  ).when('/timesheet',
    templateUrl: '/timesheet.html'
  )




  if KarmaTrackerConfig.registration_enabled
    $routeProvider.when('/register',
      templateUrl: '/register.html'
    )



