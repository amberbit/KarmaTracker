KarmaTracker.filter 'startFrom', ->
  (input, start) ->
    start = +start
    input.slice start
