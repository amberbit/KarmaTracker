KarmaTracker.controller "ArchiveController", ['$rootScope', '$scope', '$http', '$cookieStore', '$location', '$resource', 'Project', ($rootScope, $scope, $http, $cookieStore, $location, $resource, Project) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.currentPage = 0
  $scope.totalCount = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.timer = 0
  projectService = new Project

  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.reloadProjects = (pageNr = 0) ->
    $rootScope.loading = true
    projectService.query($scope.query.string, true, pageNr+1).$promise
      .then (result) ->
        $scope.totalCount = parseInt result.total_count
        $scope.currentPage = pageNr
        $scope.projects = result.projects
        initItems()
      .finally ->
        $rootScope.loading = false


  $scope.toggleActive = (project) ->
    $http.put("/api/v1/projects/#{project.id}/toggle_active?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      project.active = data.active
    ).error((data, status, headers, config) ->
    )

  queryChanged = ->
    query = $scope.query.string
    clearTimeout $scope.timer if $scope.timer != 0
    $scope.timer = setTimeout (->
      $scope.reloadProjects()
      $scope.$apply()
    ), 1000

  initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }

  $scope.$watch("query.string", queryChanged)
]
