KarmaTracker.controller "TimesheetController", ($scope, $http, $cookieStore, $location, $routeParams, $filter, $rootScope) ->
  $rootScope.pullAllowed = false
  $scope.started_at = ''
  $scope.entries = {}
  $scope.task = {}
  $scope.today = moment($scope.date).format('YYYY-MM-DDT00:00:00')
  $scope.tokenName = 'token'
  tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate()+1)
  tomorrow = moment($scope.date).add('days', 1).format('YYYY-MM-DDT00:00:00')
  offset = moment().zone()
  $scope.showWorkedOnProjects = true


  $scope.selectedProject = ""
  $scope.fromDate = $scope.today
  $scope.toDate = tomorrow
  $scope.totalTime = 0

  $scope.editing = false
  $scope.alreadyShowing = false
  $scope.errors = {}

  $scope.getTaskForEntry = (entry) ->
    $http.get(
      "/api/v1/tasks/#{entry.time_log_entry.task_id}?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      entry.task = data.task
      $scope.getProjectForEntry(entry)
    ).error((data, status, headers, config) ->
    )

  $scope.getProjectForEntry = (entry) ->
    $http.get(
      "/api/v1/projects/#{entry.task.project_id}?token=#{$cookieStore.get($scope.tokenName)}"
    ).success((data, status, headers, config) ->
      entry.project = data.project
    ).error((data, status, headers, config) ->
    )

  $scope.getProjects = ->
    $http.get(
      '/api/v1/projects?token='+$cookieStore.get($scope.tokenName)+"&worked_on=#{$scope.showWorkedOnProjects}"
    ).success((data, status, headers, config) ->
      $scope.projects = data['projects']
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
    entry.time_log_entry.newStartedAt = moment(entry.time_log_entry.started_at).format('YYYY-MM-DDTHH:mm:ss')
    entry.time_log_entry.newStoppedAt = moment(entry.time_log_entry.stopped_at).format('YYYY-MM-DDTHH:mm:ss')
    $scope.errors = {}



  $scope.getEntries = ->
    $rootScope.loading = true
    $http.get(
      "/api/v1/time_log_entries?token=#{$cookieStore.get($scope.tokenName)}&project_id=#{$scope.selectedProject}&started_at=#{moment($scope.fromDate).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}&stopped_at=#{moment($scope.toDate).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
}"
    ).success((data, status, headers, config) ->
      $scope.entries = data
      $scope.errors = {}
      $scope.selectedProject = "" if !$scope.selectedProject?
      $scope.totalTime = 0
      for entry in $scope.entries
        $scope.getTaskForEntry(entry)
        $scope.totalTime += entry.time_log_entry.seconds

        entry.editing = false
        entry.time_log_entry.newStartedAt = moment(entry.time_log_entry.started_at).format('YYYY-MM-DDTHH:mm:ss')
        entry.time_log_entry.newStoppedAt = moment(entry.time_log_entry.stopped_at).format('YYYY-MM-DDTHH:mm:ss')
      $rootScope.loading = false
    ).error((data, status, headers, config) ->
      $rootScope.loading = false    
    )


  $scope.deleteEntry = (entry) ->
    if confirm("Are you sure to delete '#{entry.task.name}' entry from the log?")
      $http.delete(
        "/api/v1/time_log_entries/#{entry.time_log_entry.id}?token=#{$cookieStore.get($scope.tokenName)}"
      ).success((data, status, headers, config) ->
        $scope.getEntries()
      ).error((data, status, headers, config) ->
      )

  $scope.updateEntry = (entry) ->
    $scope.errors = {}
    $http.put(
      "/api/v1/time_log_entries/#{entry.time_log_entry.id}?token=#{$cookieStore.get($scope.tokenName)}&time_log_entry[started_at]=#{moment(entry.time_log_entry.newStartedAt).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
      }&time_log_entry[stopped_at]=#{moment(entry.time_log_entry.newStoppedAt).add('minutes', offset).format('YYYY-MM-DD HH:mm:ss')
      }"
    ).success((data, status, headers, config) ->
      $scope.getEntries()
    ).error((data, status, headers, config) ->
      for field in ["started_at", "stopped_at"]
        if data.time_log_entry.errors[field]?
          $scope.errors[field] = data.time_log_entry.errors[field][0]
          $scope.errors.id = data.time_log_entry.errors[field][1].split(':')[1] if data.time_log_entry.errors[field][1]?
    )

  $scope.showLocalDate = (date) ->
    result = moment(date).add('minutes', -offset).format('YYYY-MM-DD HH:mm:ss')


  $scope.$watch('showWorkedOnProjects', $scope.getProjects)

  $scope.getEntries()

