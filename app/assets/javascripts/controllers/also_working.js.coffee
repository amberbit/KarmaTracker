KarmaTracker.controller 'AlsoWorkingController', [ '$scope', 'Project', ($scope, Project) ->
  projectService = new Project
  $scope.alsoWorking = null

  $scope.setAlsoWorking = ->
    projectService.alsoWorking().$promise.then (result) ->
      $scope.alsoWorking = if Object.keys(result.also_working).length == 0 then [] else result.also_working


  $scope.$on "$locationChangeSuccess", (event, currentLocation) ->
    if currentLocation.match(/projects$/) or currentLocation.match(/projects\/\d*\/tasks$/)
      $scope.setAlsoWorking()
    else
      $scope.alsoWorking = null
]
