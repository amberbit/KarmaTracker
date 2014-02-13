KarmaTracker.controller "ProjectsController",['$rootScope', '$scope', '$resource', 'Project', '$location', '$timeout', ($rootScope, $scope, $resource, Project, $location, $timeout) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.currentPage = 0
  $scope.totalCount = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.recent = true if document.documentElement.clientWidth <= 768
  $scope.timer = undefined
  projectService = new Project


  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  $scope.$on("reloadTasksOrProjects", ->
    $scope.reloadProjects()
  )

  $scope.reloadProjects = (pageNr = 0) ->
    archive = if $location.path() == '/archive' then true else null
    $rootScope.loading = true
    projectService.query($scope.query.string, archive, pageNr+1).$promise
      .then (result) ->
        $scope.totalCount = parseInt result.total_count
        $scope.currentPage = pageNr
        $scope.projects = result.projects
        initItems()
      .finally ->
        $rootScope.loading = false

  queryChanged = ->
    query = $scope.query.string
    $timeout.cancel($scope.timer) if $scope.timer
    $scope.timer = $timeout (->
      $scope.reloadProjects()
      $scope.$apply()
    ), 1000

   initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }

  $scope.toggleActive = (project) ->
    projectService.toggleActive(project.id).$promise.then (result) ->
      project.active = result.active


  $scope.$watch("recent", $scope.reloadProjects)
  $scope.$watch("query.string", queryChanged)
]
