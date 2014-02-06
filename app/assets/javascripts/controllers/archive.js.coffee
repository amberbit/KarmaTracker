KarmaTracker.controller "ArchiveController", ['$rootScope', '$scope', '$resource', 'Project', ($rootScope, $scope, $resource, Project) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
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
    projectService.toggleActive(project.id).$promise.then (result) ->
      project.active = result.active

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
