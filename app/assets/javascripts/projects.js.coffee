KarmaTracker.controller "ProjectsController", ($rootScope, $scope, $http, $cookieStore, $location) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.currentPage = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.recent = true if document.documentElement.clientWidth <= 768

  $scope.numberOfPages = () ->
    return Math.ceil($scope.projects.length/$scope.pageSize)             
  
  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  filter_visible = ->
    any_visible = false

    for project in $scope.projects
      project.visible = $scope.matchesQuery(project.name)
      any_visible = true if project.visible

    $scope.projects.none_visible = !any_visible

  $scope.reloadProjects = () ->
    $rootScope.loading = true
    $http.get(
      "/api/v1/projects#{if $scope.recent then "/recent" else "" }?token="+$cookieStore.get($scope.tokenName)
    ).success((data, status, headers, config) ->
      $scope.projects = []
      for project in data
        project.project.visible = $scope.matchesQuery(project.project.name)
        $scope.projects.push project.project
      $rootScope.loading = false
      filter_visible()
    ).error((data, status, headers, config) ->
      if $scope.recent
        $scope.recent = false
      $rootScope.loading = false
    )

  $scope.$watch("query.string", filter_visible  )
  $scope.$watch("recent", $scope.reloadProjects)