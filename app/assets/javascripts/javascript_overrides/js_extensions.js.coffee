String::endsWith = (suffix) ->
  @indexOf(suffix, @length - suffix.length) isnt -1

Number::toHHmmSS = ->
  result = ""
  timePad = (str) ->
    while str.length < 2
      str = "0" + str
    str
  seconds = Math.floor((this/ 1000) % 60).toString()
  minutes = Math.floor((this/ (60000)) % 60).toString()
  hours = Math.floor(this/ (3600000)).toString()
  result = timePad(hours) + ":" if hours > 0
  result = result + timePad(minutes) + ":" + timePad(seconds)
