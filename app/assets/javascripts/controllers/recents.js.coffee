KarmaTracker.controller "RecentsController", ['$scope', 'BroadcastService', '$rootScope', 'TimeLogEntry', 'Task', 'Project', 'User', 'FlashMessage', ($scope, BroadcastService, $rootScope, TimeLogEntry, Task, Project, User, FlashMessage) ->
  $scope.lastTasks = []
  $scope.lastProjects = []
  $scope.alsoWorking = []
  timeLogEntryService = new TimeLogEntry
  taskService = new Task
  projectService = new Project
  userService = new User
  flashMessageService = FlashMessage

  $scope.showAllProjects = ->
    document.getElementById("projectspage").classList.remove("hide-for-small")
    document.getElementById("recentspage").classList.add("hide-for-small")

  $scope.startTracking = (task) ->
    if task.id == $rootScope.runningTask.id
      timeLogEntryService.stop().$promise.then ->
        flashMessageService.notice "You stopped tracking #{task.name}."
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        BroadcastService.prepForBroadcast('recentClicked')
    else
      timeLogEntryService.save({task_id: task.id}).$promise.then ->
        flashMessageService.notice "You started tracking #{task.name}."
        $scope.getRecentTasks()
        $scope.getRecentProjects()
        BroadcastService.prepForBroadcast('recentClicked')

  $scope.getRecentTasks = ->
    taskService.recent().$promise
      .then (result) ->
        $scope.lastTasks = result.tasks
      .catch ->
        $scope.lastTasks = []


  $scope.getRecentProjects = ->
    projectService.recent().$promise
      .then (result) ->
        $scope.lastProjects = result.projects

  $scope.$on "handleBroadcast", ->
    if BroadcastService.message == 'refreshRecent'
      $scope.getRecentTasks()
      $scope.getRecentProjects()

  if userService.loggedIn()
    $scope.getRecentTasks()
    $scope.getRecentProjects()
]
