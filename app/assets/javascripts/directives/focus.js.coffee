KarmaTracker.directive "focus", ->
  {
    restrict: "A",
    link: (scope, element, attrs) ->
      scope.$watch("focus", (value) ->
        if parseInt(value) > 0
          element[0].focus()
      )
  }
