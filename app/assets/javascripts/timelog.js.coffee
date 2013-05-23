KarmaTracker.controller "TimelogController", ($scope, $http, $cookies, $location, $routeParams, $filter) ->
  $scope.started_at = ''
  $scope.entries = {}
  $scope.today = $filter('date')(new Date(),'yyyy-MM-dd')
  $scope.task = {}
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
      console.debug data
    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
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


  todayEntries = () ->
    $scope.totalTime = 0
    $http.get(
      "/api/v1/time_log_entries?token=#{$cookies.token}&started_at=#{$scope.today}"
    ).success((data, status, headers, config) ->
      $scope.entries = data
      for entry in $scope.entries
        $scope.getTaskForEntry(entry)
        $scope.totalTime += entry.time_log_entry.seconds

    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )



  todayEntries()

