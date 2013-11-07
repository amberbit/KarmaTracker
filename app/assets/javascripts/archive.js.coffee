KarmaTracker.controller "ArchiveController", ($rootScope, $scope, $http, $cookieStore, $location) ->
  $rootScope.pullAllowed = true
  $scope.projects = []
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.currentPage = 0
  $scope.totalCount = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.timer = 0
  $scope.items = []
  
  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)
  
  $scope.reloadProjects = (pageNr = 0) ->
    #
  
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


  $scope.$watch("recent", $scope.reloadProjects)
  $scope.$watch("query.string", $scope.queryChanged)
