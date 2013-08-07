KarmaTracker.controller "ProjectsController", ($rootScope, $scope, $http, $cookieStore, $location) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $rootScope.loading = true

  $scope.currentPage = 0
  $scope.pageSize = 100

  $scope.numberOfPages = () ->
    return Math.ceil($scope.projects.length/$scope.pageSize)             

  $scope.showRecents = () ->
    document.getElementById("projectspage").classList.add("hide-for-small")
    document.getElementById("recentspage").classList.remove("hide-for-small")
  
  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  filter_visible = ->
    any_visible = false

    for project in $scope.projects
      project.visible = $scope.matchesQuery(project.name)
      any_visible = true if project.visible

    $scope.projects.none_visible = !any_visible

  $http.get(
    '/api/v1/projects?token='+$cookieStore.get($scope.tokenName)
  ).success((data, status, headers, config) ->
    $scope.projects = []
    for project in data
      project.project.visible = $scope.matchesQuery(project.project.name)
      $scope.projects.push project.project
    $rootScope.loading = false
    filter_visible()
  ).error((data, status, headers, config) ->
    $rootScope.loading = false

  )

  $scope.$watch("query.string", filter_visible  )
  