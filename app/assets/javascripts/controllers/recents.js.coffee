KarmaTracker.controller "RecentsController", ['$scope', '$http', '$cookieStore', '$location', 'BroadcastService', '$rootScope', 'TimeLogEntry', 'Task', ($scope, $http, $cookieStore, $location, BroadcastService, $rootScope, TimeLogEntry, Task) ->
  $scope.lastTasks = []
  $scope.lastProjects = []
  $scope.noTasks = true
  $rootScope.noRecentProjects = true
  $scope.tokenName = 'token'
  $scope.alsoWorking = []
  $scope.location = null
  timeLogEntryService = new TimeLogEntry
  taskService = new Task

  $scope.showAllProjects = ->
    document.getElementById("projectspage").classList.remove("hide-for-small")
    document.getElementById("recentspage").classList.add("hide-for-small")

  $scope.startTracking = (task) ->
    if task.id == $scope.runningTask.id
      timeLogEntryService.stop().$promise.then ->
        $scope.notice "You stopped tracking #{task.name}."
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        BroadcastService.prepForBroadcast('recentClicked')
    else
      timeLogEntryService.save({task_id: task.id}).$promise.then ->
        $scope.notice "You started tracking #{task.name}."
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        BroadcastService.prepForBroadcast('recentClicked')

  $scope.getRecentTasks = ->
    taskService.recent().$promise
      .then (result) ->
        $scope.lastTasks = result.tasks
      .catch ->
        $scope.lastTasks = []
        $scope.noTasks = true


   # $http.get(
      #'/api/v1/tasks/recent?token='+$cookieStore.get($scope.tokenName)
    #).success((data, status, headers, config) ->
      #$scope.lastTasks = []
      #for task in data['tasks']
        #$scope.lastTasks.push task.task
      #$scope.noTasks = false if $scope.lastTasks.length > 0
    #).error((data, status, headers, config) ->
      #$scope.lastTasks = []
      #$scope.noTasks = true
   # )

  $scope.getRecentProjects = ->
    $http.get(
      '/api/v1/projects/recent?token='+$cookieStore.get($scope.tokenName)
    ).success((data, status, headers, config) ->
      $scope.lastProjects = data.projects
      $rootScope.noRecentProjects = false if $scope.lastProjects.length > 0
    ).error((data, status, headers, config) ->
      $scope.lastProjects = []
      $rootScope.noRecentProjects = true
    )

  $scope.$on "handleBroadcast", () ->
    if BroadcastService.message == 'refreshRecent'
      $scope.getRecentTasks()
      $scope.getRecentProjects()


  if $cookieStore.get($scope.tokenName)?
    $scope.getRecentTasks()
    $scope.getRecentProjects()
]
