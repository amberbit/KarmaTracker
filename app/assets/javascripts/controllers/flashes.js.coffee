KarmaTracker.controller "FlashesController", ($scope, FlashMessage) ->
  $scope.message = FlashMessage

  $scope.isAlert = ->
    $scope.message.type

  $scope.hideMsg = ->
    $scope.$apply ->
      $scope.message.string = ''
      $scope.message.type = null

  $scope.$watch "message.string", ->
    $scope.timeout = setTimeout($scope.hideMsg, 4000) if $scope.message.string != ''

