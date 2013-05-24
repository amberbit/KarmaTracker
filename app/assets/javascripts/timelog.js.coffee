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

  $scope.getTaskForEntry = (entry) ->
    $http.get(
      "/api/v1/tasks/#{entry.time_log_entry.task_id}?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      entry.task = data.task
      $scope.getProjectForEntry(entry)
    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )

  $scope.getProjectForEntry = (entry) ->
    $http.get(
      "/api/v1/projects/#{entry.task.project_id}?token=#{$cookies.token}"
    ).success((data, status, headers, config) ->
      entry.project = data.project
    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
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

  $scope.getEntries = () ->
    $scope.totalTime = 0
    $scope.selectedProject = "" if !$scope.selectedProject?
    $http.get(
      "/api/v1/time_log_entries?token=#{$cookies.token}&project_id=#{$scope.selectedProject}&started_at=#{$scope.fromDate}&stopped_at=#{$scope.toDate}"
    ).success((data, status, headers, config) ->
      console.debug data, status
      $scope.entries = data
      for entry in $scope.entries
        $scope.getTaskForEntry(entry)
        $scope.totalTime += entry.time_log_entry.seconds

    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )



  $scope.getEntries()
  $scope.getProjects()

