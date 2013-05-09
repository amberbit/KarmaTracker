KarmaTracker.config ($routeProvider) ->
  $routeProvider.when('/',
    template: 'Loading...'
  ).when("/login",
    controller: 'SessionController',
    templateUrl: '/session.html'
  ).when('/logout',
    controller: 'LogoutController',
    template: 'Logging out...'
  ).when("/projects",
    controller: 'ProjectsController',
    templateUrl: '/projects.html'
  ).when("/projects/:project_id/tasks",
    controller: 'TasksController',
    templateUrl: '/tasks.html'
  ).when('/refresh',
    controller: 'RefreshController',
    templateUrl: '/refresh.html'
  ).when('/register',
    controller: 'RegisterController',
    templateUrl: '/register.html'
  )



