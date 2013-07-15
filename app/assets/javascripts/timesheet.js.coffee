KarmaTracker.controller "TimesheetController", ($scope, $http, $cookies, $location, $routeParams, $filter) ->
  $scope.started_at = ''
  $scope.entries = {}
  $scope.task = {}
  $scope.today = $filter('date')(new Date(),'yyyy-MM-dd 00:00:00')
  tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate()+1)
  tomorrow = $filter('date')(tomorrow,'yyyy-MM-dd 00:00:00')
  offset = moment().zone()

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
    entry.time_log_entry.newStartedAt = moment(entry.time_log_entry.started_at).format('YYYY-MM-DD HH:mm:ss')
    entry.time_log_entry.newStoppedAt = moment(entry.time_log_entry.stopped_at).format('YYYY-MM-DD HH:mm:ss')
    $scope.errors = {}



  $scope.getEntries = () ->
    $scope.errors = {}
    $scope.totalTime = 0
    $scope.selectedProject = "" if !$scope.selectedProject?

    $http.get(
      "/api/v1/time_log_entries?token=#{$cookies.token}&project_id=#{$scope.selectedProject}&started_at=#{moment($scope.fromDate).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}&stopped_at=#{moment($scope.toDate).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}"
    ).success((data, status, headers, config) ->
      $scope.entries = data
      for entry in $scope.entries
        $scope.getTaskForEntry(entry)
        $scope.totalTime += entry.time_log_entry.seconds

        entry.editing = false
        entry.time_log_entry.newStartedAt = moment(entry.time_log_entry.started_at).format('YYYY-MM-DD HH:mm:ss')
        entry.time_log_entry.newStoppedAt = moment(entry.time_log_entry.stopped_at).format('YYYY-MM-DD HH:mm:ss')
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
      "/api/v1/time_log_entries/#{entry.time_log_entry.id}?token=#{$cookies.token}&time_log_entry[started_at]=#{moment(entry.time_log_entry.newStartedAt).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}&time_log_entry[stopped_at]=#{moment(entry.time_log_entry.newStoppedAt).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}"
    ).success((data, status, headers, config) ->
      $scope.getEntries()
    ).error((data, status, headers, config) ->
      for field in ["started_at", "stopped_at"]
        $scope.errors[field] = data.time_log_entry.errors[field][0]
    )

  $scope.showLocalDate = (date) ->
    result = moment(date).add('minutes', -offset).format('YYYY-MM-DD HH:mm:ss')




  #$scope.getEntries()
  $scope.getProjects()

