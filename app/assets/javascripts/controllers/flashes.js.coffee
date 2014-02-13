KarmaTracker.controller "FlashesController", ($scope, FlashMessage, $timeout) ->
  $scope.message = FlashMessage

  $scope.isAlert = ->
    $scope.message.type

  $scope.hideMsg = ->
    $scope.$apply ->
      $scope.message.string = ''
      $scope.message.type = null

  $scope.$watch "message.string", ->
    $scope.timeout = $timeout($scope.hideMsg, 4000) if $scope.message.string != ''

