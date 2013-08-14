KarmaTracker.controller "ProjectsController", ($rootScope, $scope, $http, $cookieStore, $location) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.currentPage = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.recent = true if document.documentElement.clientWidth <= 768
  $scope.timer = 0

  $scope.numberOfPages = () ->
    return Math.ceil($scope.projects.length/$scope.pageSize)

  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  $scope.reloadProjects = () ->
    $rootScope.loading = true
    $http.get(
      "/api/v1/projects#{if $scope.recent then "/recent" else "" }?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}"
    ).success((data, status, headers, config) ->
      $scope.projects = []
      for project in data
        $scope.projects.push project.project
      $rootScope.loading = false
    ).error((data, status, headers, config) ->
      if $scope.recent
        $scope.recent = false
      $rootScope.loading = false
    )


  $scope.queryChanged = ->
    query = $scope.query.string
    clearTimeout $scope.timer
    $scope.timer = setTimeout (->
      $scope.reloadProjects()
    ), 1000

  $scope.$watch("query.string", $scope.queryChanged)
  $scope.$watch("recent", $scope.reloadProjects)
