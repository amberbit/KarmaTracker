KarmaTracker.factory 'BroadcastService', ($rootScope) ->
  broadcastService = {message: ""}

  broadcastService.prepForBroadcast = (msg) ->
    @message = msg
    @broadcastItem()

  broadcastService.broadcastItem = ->
    $rootScope.$broadcast('handleBroadcast')

  broadcastService
