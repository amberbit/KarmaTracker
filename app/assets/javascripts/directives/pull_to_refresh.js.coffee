KarmaTracker.directive "pullToRefresh", ($rootScope) ->
  {
    restrict: "A",
    link: (scope, element, attrs) ->
      $rootScope.$watch("pullAllowed", (value) ->
        $rootScope.pull(value, element)
      , true)
  }


