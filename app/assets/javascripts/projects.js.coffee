KarmaTracker.controller "ProjectsController", ($rootScope, $scope, $http, $cookieStore, $location) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.currentPage = 0
  $scope.totalCount = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.recent = true if document.documentElement.clientWidth <= 768
  $scope.timer = 0
  $scope.items = []
  $scope.alsoWorking = []

  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.loadTasks = (project) ->
    $location.path "/projects/#{project.id}/tasks"

  $scope.reloadProjects = (pageNr = 0) ->
    $rootScope.loading = true
    $http.get(
      "/api/v1/projects#{if $scope.recent then "/recent" else "" }?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}&page=#{pageNr+1}"
    ).success((data, status, headers, config) ->
      $scope.totalCount = parseInt data['total_count']
      $scope.currentPage = pageNr
      $scope.projects = []
      for project in data['projects']
        $scope.projects.push project.project
      $rootScope.loading = false
      $scope.initItems()
    ).error((data, status, headers, config) ->
      console.debug "Error fetching projects. Status: #{status}"
      if $scope.recent
        $scope.recent = false
      $rootScope.loading = false
    )

  $scope.queryChanged = ->
    query = $scope.query.string
    clearTimeout $scope.timer if $scope.timer != 0
    $scope.timer = setTimeout (->
      $scope.reloadProjects()
      $scope.$apply()
    ), 1000

  $scope.initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }

  $scope.alsoWorking = ->
    $http.get(
      "/api/v1/projects/also_working?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      console.log data
    ).error((data, status, headers, config) ->
      console.debug "Error fetching who is also working ATM."
    )

  $scope.$watch("recent", $scope.reloadProjects)
  $scope.$watch("query.string", $scope.queryChanged)
  $scope.alsoWorking()


