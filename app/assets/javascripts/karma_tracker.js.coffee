window.KarmaTracker = angular.module('KarmaTracker', [])

KarmaTracker.factory('SessionService', ->
  { token: null }
)

window.SessionController = ($scope, $http, SessionService) ->
  $scope.session = { email: 'a@b.com', password: 'asdf1234' }

  $scope.signIn = ->
    $http.post(
      '/api/v1/session',
      session: {
        email: $scope.session.email,
        password: $scope.session.password
      }
    ).success((data, status, headers, config) ->
      SessionService.token = data.user.token
      console.debug SessionService.token
    ).error((data, status, headers, config) ->
      alert data.message
    )
