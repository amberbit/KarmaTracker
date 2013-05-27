KarmaTracker.controller "TimelogController", ($scope, $http, $cookies, $location, $routeParams, $filter) ->
  $scope.started_at = ''
  $scope.entries = {}
  $scope.task = {}
  $scope.today = $filter('date')(new Date(),'yyyy-MM-dd 00:00:00')
  tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate()+1)
  tomorrow = $filter('date')(tomorrow,'yyyy-MM-dd 00:00:00')

  $scope.selectedProject = ""
  $scope.fromDate = $scope.today
  $scope.toDate = tomorrow
  $scope.totalTime = 0

  $scope.editing = false
  $scope.alreadyShowing = false
  $scope.errors = {}

  $scope.getTaskForEntry = (entry) ->
    $http.get(
      "/api/v1/tasks/#{entry.time_log_entry.task_id}?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      entry.task = data.task
      $scope.getProjectForEntry(entry)
    ).error((data, status, headers, config) ->
    )

  $scope.getProjectForEntry = (entry) ->
    $http.get(
      "/api/v1/projects/#{entry.task.project_id}?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      entry.project = data.project
    ).error((data, status, headers, config) ->
    )

  $scope.getProjects = () ->
    $http.get(
      '/api/v1/projects?token='+$cookies.token
    ).success((data, status, headers, config) ->
      $scope.projects = data
    ).error((data, status, headers, config) ->
    )


  pad = (number) ->
    str = '' + number
    while (str.length < 2)
      str = '0' + str
    return str


  $scope.getTime = (seconds) ->
    hours = Math.floor(seconds / 3600)
    seconds = seconds - hours * 3600
    minutes = Math.floor(seconds/60)

    return pad(hours) + ":" + pad(minutes) + " hours"

  $scope.edit = (entry) ->
    $scope.errors = {}
    for eachentry in $scope.entries
      eachentry.editing = false
    entry.editing = true


  $scope.close = (entry) ->
    entry.editing = false
    entry.time_log_entry.newStartedAt = entry.time_log_entry.started_at.replace("T", " ").replace("Z", "")
    entry.time_log_entry.newStoppedAt = entry.time_log_entry.stopped_at.replace("T", " ").replace("Z", "")
    $scope.errors = {}



  $scope.getEntries = () ->
    $scope.errors = {}
    $scope.totalTime = 0
    $scope.selectedProject = "" if !$scope.selectedProject?
    $http.get(
      "/api/v1/time_log_entries?token=#{$cookies.token}&project_id=#{$scope.selectedProject}&started_at=#{$scope.fromDate}&stopped_at=#{$scope.toDate}"
    ).success((data, status, headers, config) ->
      $scope.entries = data
      for entry in $scope.entries
        $scope.getTaskForEntry(entry)
        $scope.totalTime += entry.time_log_entry.seconds

        entry.editing = false
        entry.time_log_entry.newStartedAt = entry.time_log_entry.started_at.replace("T", " ").replace("Z", "")
        entry.time_log_entry.newStoppedAt = entry.time_log_entry.stopped_at.replace("T", " ").replace("Z", "")
    ).error((data, status, headers, config) ->
    )


  $scope.deleteEntry = (entry) ->
    if confirm("Are you sure to delete '#{entry.task.name}' entry from the log?")
      $http.delete(
        "/api/v1/time_log_entries/#{entry.time_log_entry.id}?token=#{$cookies.token}"
      ).success((data, status, headers, config) ->
        $scope.getEntries()
      ).error((data, status, headers, config) ->
      )

  $scope.updateEntry = (entry) ->
    $scope.errors = {}
    $http.put(
      "/api/v1/time_log_entries/#{entry.time_log_entry.id}?token=#{$cookies.token}&time_log_entry[started_at]=#{entry.time_log_entry.newStartedAt}&time_log_entry[stopped_at]=#{entry.time_log_entry.newStoppedAt}"
    ).success((data, status, headers, config) ->
      $scope.getEntries()
    ).error((data, status, headers, config) ->
      for field in ["started_at", "stopped_at"]
        $scope.errors[field] = data.time_log_entry.errors[field][0]
    )




  $scope.getEntries()
  $scope.getProjects()

